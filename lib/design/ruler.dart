import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme.dart';
import 'tokens.dart';

/// Distance between ticks. One tick is one step of the value.
const _gap = 12.0;

/// A value set on a tape.
///
/// The tape is a flat strip of ticks standing on a baseline, the way a scale is
/// printed: minor ticks every step, taller ones every whole unit, and the
/// needle standing fixed in the middle while the strip moves under it. The
/// figure above the needle is the answer; the strip is only the hand turning it.
///
/// **It never rebuilds while it moves.** The number and the strip both listen to
/// the scroll position directly, so a fling repaints two leaf widgets and
/// nothing else. The first version rebuilt the whole card every frame, and on a
/// phone that read as lag.
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

  /// Off where the figure already stands in a heading above the tape.
  final bool showValue;

  @override
  State<CalviRuler> createState() => _CalviRulerState();
}

class _CalviRulerState extends State<CalviRuler> {
  late final double _initial = (widget.value - widget.min) / widget.step * _gap;
  late final ScrollController _c = ScrollController(initialScrollOffset: _initial);

  late final int _count = ((widget.max - widget.min) / widget.step).round() + 1;
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

  /* No setState here on purpose: the strip and the figure repaint off the
     controller by themselves, and rebuilding the subtree per frame is the lag
     the first version shipped with. */
  void _onScroll() {
    final idx = (_c.offset / _gap).round().clamp(0, _count - 1);
    if (idx == _last) return;
    _last = idx;
    // One tick under the needle is one detent, whatever the scroll speed.
    HapticFeedback.selectionClick();
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

    return Column(
      children: [
        if (widget.showValue) ...[
          AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Text.rich(
              TextSpan(
                text: widget.step < 1
                    ? _shown().toStringAsFixed(1)
                    : _shown().toStringAsFixed(0),
                children: [TextSpan(text: ' ${widget.suffix}', style: context.t.headlineLarge)],
              ),
              style: context.t.displayLarge?.copyWith(height: 1),
            ),
          ),
          const SizedBox(height: 14),
        ],
        SizedBox(
          height: 64,
          child: LayoutBuilder(
            builder: (context, box) => Stack(
              // Ticks stand on the floor of the strip, the way a scale is read.
              alignment: Alignment.bottomCenter,
              children: [
                /* The strip does not scroll, the values do: an empty scroll view
                   owns the gesture and the physics, and one painter reads its
                   offset. One layer for the whole tape. */
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TapePainter(
                      scroll: _c,
                      fallback: _initial,
                      count: _count,
                      /* Whole units stand out on a fractional tape; on a tape
                         of whole numbers every fifth does, or every tick is a
                         major and the strip reads as a black comb. */
                      major: widget.step >= 1 ? 5 : (1 / widget.step).round(),
                      width: box.maxWidth,
                      ink: c.text,
                      faint: c.textSecondary,
                    ),
                  ),
                ),
                ScrollConfiguration(
                  // The tape is dragged with whatever is at hand, mouse included.
                  behavior: const _AnyPointerScroll(),
                  child: SingleChildScrollView(
                    controller: _c,
                    scrollDirection: Axis.horizontal,
                    physics: _DetentPhysics(gap: _gap),
                    child: SizedBox(width: (_count - 1) * _gap + box.maxWidth, height: 64),
                  ),
                ),
                // The needle. It never moves, which is what makes the tape move.
                IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      width: 3,
                      height: 44,
                      decoration: BoxDecoration(
                        color: c.accent,
                        borderRadius: BorderRadius.circular(CalviSize.rPill),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AnyPointerScroll extends MaterialScrollBehavior {
  const _AnyPointerScroll();

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}

/// The strip itself: ticks standing on a floor near the bottom.
class _TapePainter extends CustomPainter {
  _TapePainter({
    required this.scroll,
    required this.fallback,
    required this.count,
    required this.major,
    required this.width,
    required this.ink,
    required this.faint,
  }) : super(repaint: scroll);

  final ScrollController scroll;

  /// Offset before the scroll view has attached on the first frame.
  final double fallback;
  final int count;
  final int major;
  final double width;
  final Color ink;
  final Color faint;

  @override
  void paint(Canvas canvas, Size size) {
    final offset = scroll.hasClients ? scroll.offset : fallback;
    final mid = width / 2;

    // Every tick rises from the same floor; only the height tells them apart.
    final floor = size.height - 6;
    const minorLen = 22.0;
    const midLen = 30.0;
    const majorLen = 44.0;

    final minorPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6
      ..color = faint.withValues(alpha: 0.55);
    final majorPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2
      ..color = ink.withValues(alpha: 0.9);

    final first = math.max(0, ((offset - mid) / _gap).floor() - 1);
    final last = math.min(count - 1, ((offset + mid) / _gap).ceil() + 1);

    for (var i = first; i <= last; i++) {
      final x = i * _gap - offset + mid;
      final whole = i % major == 0;
      final half = major >= 10 && i % (major ~/ 2) == 0;
      final len = whole
          ? majorLen
          : half
          ? midLen
          : minorLen;
      canvas.drawLine(
        Offset(x, floor),
        Offset(x, floor - len),
        whole ? majorPaint : minorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_TapePainter old) =>
      old.ink != ink || old.count != count || old.major != major || old.width != width;
}

/// Rests on a tick, never between two.
class _DetentPhysics extends ScrollPhysics {
  const _DetentPhysics({required this.gap, super.parent});

  final double gap;

  @override
  _DetentPhysics applyTo(ScrollPhysics? ancestor) =>
      _DetentPhysics(gap: gap, parent: buildParent(ancestor));

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final proposed = super.createBallisticSimulation(position, velocity);
    final landing = proposed?.x(double.infinity) ?? position.pixels;
    final bounded = landing.clamp(position.minScrollExtent, position.maxScrollExtent);
    final snapped = (bounded / gap).round() * gap;
    if ((snapped - position.pixels).abs() < toleranceFor(position).distance) return proposed;
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      snapped,
      velocity,
      tolerance: toleranceFor(position),
    );
  }
}
