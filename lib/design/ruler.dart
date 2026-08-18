import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme.dart';

/// Distance between ticks. One tick is one step of the value.
const _gap = 11.0;

/// Bend of the drum at its edges, and how far the far ticks fall away.
const _tilt = 64.0;
const _depth = 120.0;
const _perspective = 560.0;
const _squash = 0.44;

/* Edges fade, but not to nothing: past about three quarters the far ticks stop
   being a drum and start being dirt. */
const _fade = 0.76;

/* How many ticks the rise under the needle spreads over, and how tall it gets.
   Wide and shallow: a narrow, tall bump reads as a tick popping out of a flat
   row, and popping is the thing this is meant to avoid. */
const _span = 3.2;
const _rise = 0.62;

/// A value set on a drum.
///
/// The strip is a cylinder seen edge on: ticks stand upright under the needle
/// and roll away at both ends, shrinking and fading as they go. A weight is a
/// value people nudge rather than enter, and a surface with depth invites the
/// nudge in a way a flat row of dashes does not.
///
/// **Every tick is a detent.** One step is one click under the thumb, so the
/// value can be found without watching the number.
///
/// **It never rebuilds while it moves.** The drum and the figure both listen to
/// the scroll position directly, so a fling repaints two leaf widgets and
/// nothing else. The first version rebuilt the whole card every frame, and on a
/// phone that read as lag. The whole cylinder is one painter for the same
/// reason: a hundred and eighty positioned widgets is a hundred and eighty
/// layout passes per frame.
class CalviRuler extends StatefulWidget {
  const CalviRuler({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.onChange,
    this.step = 0.1,
    this.showValue = true,
  });

  final double value;
  final double min;
  final double max;
  final double step;
  final String suffix;
  final ValueChanged<double> onChange;

  /// Off where the figure already stands in a heading above the drum.
  final bool showValue;

  @override
  State<CalviRuler> createState() => _CalviRulerState();
}

class _CalviRulerState extends State<CalviRuler> {
  late final double _initial = (widget.value - widget.min) / widget.step * _gap;
  late final ScrollController _c = ScrollController(initialScrollOffset: _initial);

  late final int _count = ((widget.max - widget.min) / widget.step).round() + 1;

  /* Built once and kept. Scroll physics are compared by identity, so a fresh
     instance on every build makes the scroll view rebuild its position, and a
     rebuilt position restarts the fling: one flick became a chain of them, which
     is both the jerk and the drum running much further than it was pushed. */
  late final _physics = _DetentPhysics(gap: _gap, aim: _Aim());
  int _last = -1;

  @override
  void initState() {
    super.initState();
    _c.addListener(_onScroll);
  }

  @override
  void dispose() {
    _c.removeListener(_onScroll);
    _c.dispose();
    super.dispose();
  }

  /* No setState here on purpose: the drum and the figure repaint off the
     controller by themselves, and rebuilding the subtree per frame is the lag
     the first version shipped with. */
  void _onScroll() {
    final idx = (_c.offset / _gap).round().clamp(0, _count - 1);
    if (idx == _last) return;
    _last = idx;
    // One tick under the needle is one detent, whatever the scroll speed.
    HapticFeedback.lightImpact();
    widget.onChange(_round(widget.min + idx * widget.step));
  }

  double _round(double v) {
    final snapped = (v / widget.step).round() * widget.step;
    return double.parse(snapped.toStringAsFixed(widget.step < 1 ? 1 : 0));
  }

  double _shown() {
    if (!_c.hasClients) return widget.value;
    final idx = (_c.offset / _gap).round().clamp(0, _count - 1);
    return _round(widget.min + idx * widget.step);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    // Four under the tape, so the last tick is not flush with what follows.
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        children: [
          if (widget.showValue) ...[
            AnimatedBuilder(
              animation: _c,
              builder: (context, _) => Text.rich(
                TextSpan(
                  text: widget.step < 1
                      ? _shown().toStringAsFixed(1)
                      : _shown().toStringAsFixed(0),
                  children: [
                    TextSpan(
                      text: ' ${widget.suffix}',
                      style: context.t.headlineLarge?.copyWith(fontSize: 22),
                    ),
                  ],
                ),
                style: context.t.displayLarge?.copyWith(fontSize: 38, height: 1.26),
              ),
            ),
            const SizedBox(height: 20),
          ],
          SizedBox(
            height: 84,
            child: LayoutBuilder(
              /* The stack is told to fill. Left loose it took the width of its
                 widest child, which is the scroller's content, so the scroller was
                 as wide as the whole range and had nothing left to scroll: every
                 drum opened clamped to its first value instead of its own. */
              builder: (context, box) => Stack(
                fit: StackFit.expand,
                children: [
                  /* The drum does not scroll, the values do: an empty scroll view
                     owns the gesture and the physics, and one painter reads its
                     offset. Putting the perspective inside the scroller would drag
                     the vanishing point along with the content and the cylinder
                     would shear instead of turn. */
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: _DrumPainter(
                          scroll: _c,
                          fallback: _initial,
                          count: _count,
                          width: box.maxWidth,
                          ink: c.text,
                          accent: c.button,
                        ),
                      ),
                    ),
                  ),
                  ScrollConfiguration(
                    // The drum is dragged with whatever is at hand, mouse included.
                    behavior: const _AnyPointerScroll(),
                    child: SingleChildScrollView(
                      controller: _c,
                      scrollDirection: Axis.horizontal,
                      physics: _physics,
                      child: SizedBox(width: (_count - 1) * _gap + box.maxWidth, height: 84),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnyPointerScroll extends MaterialScrollBehavior {
  const _AnyPointerScroll();

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}

/// The cylinder itself, needle and all, in one layer.
class _DrumPainter extends CustomPainter {
  _DrumPainter({
    required this.scroll,
    required this.fallback,
    required this.count,
    required this.width,
    required this.ink,
    required this.accent,
  }) : super(repaint: scroll);

  final ScrollController scroll;

  /// Offset before the scroll view has attached on the first frame.
  final double fallback;
  final int count;
  final double width;
  final Color ink;
  final Color accent;

  /// How much of a tick survives the mask at the far edges of the frame.
  double _edge(double x) {
    final t = x / width;
    if (t <= 0 || t >= 1) return 0;
    if (t < 0.22) return t / 0.22;
    if (t > 0.78) return (1 - t) / 0.22;
    return 1;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final offset = scroll.hasClients ? scroll.offset : fallback;
    final mid = width / 2;

    // The vanishing point sits at the middle of the frame and stays there.
    final originY = size.height * 0.62;
    const bottom = 16.0;
    const tall = 44.0;

    /* Where the needle actually is, in fractions of a tick. Measured from the
       rounded index the rise jumped a whole tick at a time instead of
       travelling with the thumb. */
    final centre = offset / _gap;
    final under = centre.round();

    final first = math.max(0, ((offset - mid) / _gap).floor() - 1);
    final last = math.min(count - 1, ((offset + mid) / _gap).ceil() + 1);

    final paint = Paint();

    for (var i = first; i <= last; i++) {
      // Viewport coordinates: the drum does not scroll, the values do.
      final vx = i * _gap - offset + mid;
      final d = (vx - mid) / mid;
      if (d.abs() > 1.2) continue;
      final k = math.min(1.0, d.abs());

      /* A cosine bell rather than a straight falloff: it leaves at zero and
         arrives at one with no corner at either end, so no tick has a moment
         where it suddenly starts or stops growing. */
      final away = (i - centre).abs() / _span;
      final lift = away >= 1 ? 0.0 : (1 + math.cos(away * math.pi)) / 2;

      /* One tick is one tick, whatever the step is worth. Marking every whole
         unit taller made the weight drum read as a different control from the
         age drum beside it: same gesture, same shape, two pictures. The figure
         above the needle is what says which unit this is. */
      final height = tall * (1 - _squash * k * k) * (1 + _rise * lift);

      // Perspective: the far ticks are smaller because they are further away.
      final scale = _perspective / (_perspective + _depth * k * k);
      final x = mid + (vx - mid) * scale;
      final top = originY + (size.height - bottom - height - originY) * scale;
      final foot = originY + (size.height - bottom - originY) * scale;

      // The turn narrows a tick rather than skewing it: three pixels is too
      // little to show a face.
      final half = 1.5 * math.cos(_tilt * d * math.pi / 180).abs() * scale;
      final alpha = (1 - _fade * k * k) * _edge(x);
      if (alpha <= 0 || half <= 0) continue;

      /* The one under the needle is the ink itself, so the eye lands on the
         reading rather than on a needle floating above a uniform comb. */
      final colour = i == under ? accent : ink.withValues(alpha: 0.72);
      paint.color = colour.withValues(alpha: colour.a * alpha);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(x - half, top, x + half, foot),
          const Radius.circular(2),
        ),
        paint,
      );
    }

    // A soft pool under the needle, to seat it on the drum.
    final pool = Rect.fromCenter(center: Offset(mid, size.height - 13), width: 54, height: 14);
    canvas.drawOval(
      pool,
      Paint()
        ..shader = ui.Gradient.radial(
          pool.center,
          27,
          [const Color(0x1A000000), const Color(0x00000000)],
          [0, 0.7],
          TileMode.clamp,
          Matrix4.diagonal3Values(1, pool.height / pool.width, 1).storage,
        ),
    );

    // The needle. It never moves, which is what makes the drum move.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(mid - 1.5, size.height - 12 - 56, mid + 1.5, size.height - 12),
        const Radius.circular(2),
      ),
      Paint()..color = accent,
    );
  }

  @override
  bool shouldRepaint(_DrumPainter old) =>
      old.ink != ink || old.count != count || old.width != width;
}

/// Rests on a tick, never between two.
class _DetentPhysics extends ScrollPhysics {
  const _DetentPhysics({required this.gap, required this.aim, super.parent});

  final double gap;

  /// Where the tick this flick is going to land on is remembered.
  ///
  /// Shared with every copy the framework makes of these physics, because the
  /// copies belong to the same drum.
  final _Aim aim;

  @override
  _DetentPhysics applyTo(ScrollPhysics? ancestor) =>
      _DetentPhysics(gap: gap, aim: aim, parent: buildParent(ancestor));

  /// Where a fling would come to rest.
  ///
  /// Asked at infinity, the platform's own simulation answers with a number that
  /// is not on the tape: its fling is a curve fitted to its own duration, and
  /// past that duration it runs away. So it is asked when it says it is done.
  double _landing(Simulation? sim, double from) {
    if (sim == null) return from;
    var t = 0.0;
    while (t < 4 && !sim.isDone(t)) {
      t += 1 / 60;
    }
    final x = sim.x(t);
    return x.isFinite ? x : from;
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final proposed = super.createBallisticSimulation(position, velocity);
    final tolerance = toleranceFor(position);

    /* A flick is one journey to one tick. The framework asks for the simulation
       again on every layout that touches this drum, and the panel around it
       relays out on every detent, so «again» happens several times a flick: with
       the target recomputed each time, each restart aimed further along and the
       drum both ran past where it was pushed and stuttered on the way. The tick
       is chosen once, at the start of the journey, and held until it is reached. */
    final held = aim.at;
    final going = held != null && (held - position.pixels).sign == velocity.sign;
    final target =
        going && velocity.abs() > tolerance.velocity
        ? held
        : (_landing(proposed, position.pixels).clamp(
                    position.minScrollExtent,
                    position.maxScrollExtent,
                  ) /
                  gap)
              .round() *
              gap;

    if ((target - position.pixels).abs() < tolerance.distance) {
      aim.at = null;
      return proposed;
    }
    aim.at = target;
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: tolerance,
    );
  }
}

/// The tick a flick is travelling to, kept where every copy of the physics can
/// see it.
class _Aim {
  double? at;
}
