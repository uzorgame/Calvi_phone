import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/day.dart';
import '../../data/app_scope.dart';
import '../../data/settings.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';

/// The run of days across the top.
///
/// **One continuous run, not a page of weeks.** Cells are uniform and touch each
/// other, so there is no seam anywhere in the run, and exactly seven fill the
/// width, so the resting view is one week.
///
/// **Depth belongs to the gesture, not to the screen.** At rest every day is the
/// same size and flat. While the strip is moving, days to the left lean away,
/// shrink and fade, and when it stops they unfold back, right to left. Tilting
/// them when the screen merely opens would be decoration; tilting them under a
/// thumb is the surface answering.
class WeekStrip extends StatefulWidget {
  const WeekStrip({super.key, required this.date, required this.onPick});

  final int date;
  final ValueChanged<int> onPick;

  @override
  State<WeekStrip> createState() => _WeekStripState();
}

/// Step between one day unfolding and the next, and the cap on the wait.
///
/// Right to left, so the run reassembles from the day in front. Without a cap a
/// long strip would still be unfolding after the eye has moved on.
const _stagger = 24;
const _staggerMax = 190;
const _settleMs = 520;

/// Прозорість дорівнюється швидше за форму, і від цього рух мʼякший: день уже
/// видно повністю, поки він ще розкладається. Так само в демці.
const _fadeMs = 440;

/// Глибина, якою день відходить, коли стрічку тягнуть.
///
/// Числа зняті з демки: нахил 26 градусів, відхід на 64 пікселі вглиб,
/// зменшення на пʼяту частину, прозорість до 0.4 на самому краю.
const _tilt = 26 * math.pi / 180;
const _depthPx = 64.0;
const _shrink = 0.2;
const _fade = 0.6;

class _WeekStripState extends State<WeekStrip> with SingleTickerProviderStateMixin {
  final _controller = ScrollController();

  /* Zero is folded, one is flat. An animation rather than a flag so the strip
     can unfold instead of snapping, and so each day can take its own share of it
     through an interval. */
  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _settleMs + _staggerMax),
    value: 1,
  );

  late final List<int> _run = stripRun;

  /// Which day was last under the front edge, so a click fires once per day.
  int _front = 0;
  double _cell = 0;

  /// Whether the strip has been put on this week yet.
  ///
  /// One post-frame jump was not enough: on the web the first layout can happen
  /// at a window size that is thrown away a frame later, and the strip that
  /// landed on the end of that layout ends up somewhere in the spring. It keeps
  /// trying until a real width has been through it, and stops the moment a
  /// finger touches the run.
  bool _landed = false;

  /// Set while the strip is being moved by us rather than by a finger.
  bool _mine = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  // Opens on this week, at the end of the run, without an animation: the strip
  // is where the day already is, not somewhere it travelled to.
  void _land() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients || _landed) return;
      final end = _controller.position.maxScrollExtent;
      if (end <= 0 || _controller.offset == end) return;
      _mine = true;
      _controller.jumpTo(end);
      _mine = false;
      _front = (end / (_cell == 0 ? 1 : _cell)).round();
    });
  }

  /* Stillness is silence after the last movement, not a scroll-end event: the
     platform fires those on programmatic scrolls too, and the strip would settle
     in the middle of a gesture. The timer restarts on every movement, so it only
     ever fires once the finger has actually stopped. */
  Timer? _still;

  void _onScroll() {
    // A run that has been moved is a run the reader owns; stop putting it back.
    if (!_mine) _landed = true;
    if (_settle.value != 0) {
      _settle.stop();
      _settle.value = 0;
    }

    // One click per day crossing the front edge, whatever the scroll speed.
    if (_cell > 0) {
      final at = (_controller.offset / _cell).round();
      if (at != _front) {
        _front = at;
        HapticFeedback.lightImpact();
      }
    }

    _still?.cancel();
    _still = Timer(const Duration(milliseconds: 140), () {
      if (mounted) _settle.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _still?.cancel();
    _settle.dispose();
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 74,
      child: LayoutBuilder(
        builder: (context, box) {
          // Seven across the content width, so a week is what the strip rests on.
          final was = _cell;
          _cell = (box.maxWidth - CalviSize.gutter * 2) / 7;

          /* A scroll offset is pixels, and a cell is a different number of them
             at a different width. Left alone across a rotation or a resize the
             strip keeps its old offset and lands between days, or on a day
             nobody asked for. It is put back on the day it was showing. */
          if (!_landed) _land();

          if (was > 0 && was != _cell && _controller.hasClients) {
            final front = (_controller.offset / was).round();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || !_controller.hasClients) return;
              _controller.jumpTo((front * _cell).clamp(0.0, _controller.position.maxScrollExtent));
            });
          }
          return ShaderMask(
            // Days dissolve into the left gutter instead of being sliced by it.
            shaderCallback: (r) => LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [Color(0x00000000), Color(0xFF000000)],
              stops: [0, CalviSize.gutter / r.width],
            ).createShader(r),
            blendMode: BlendMode.dstIn,
            child: RepaintBoundary(
              child: ListView.builder(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                physics: _SnapPhysics(cell: _cell),
                padding: const EdgeInsets.symmetric(horizontal: CalviSize.gutter),
                itemExtent: _cell,
                itemCount: _run.length,
                itemBuilder: (context, i) {
                  final date = _run[i];
                  return _Day(
                    date: date,
                    selected: date == widget.date,
                    settle: _settle,
                    viewport: box.maxWidth,
                    controller: _controller,
                    index: i,
                    cell: _cell,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onPick(date);
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Snaps to whole days, so the run never rests between two.
///
/// The cell width is passed in rather than read off the position: it is decided
/// by the layout above, and a physics that guesses it would guess wrong on the
/// first frame, which is exactly when the strip is being placed.
class _SnapPhysics extends ScrollPhysics {
  const _SnapPhysics({required this.cell, super.parent});

  final double cell;

  @override
  _SnapPhysics applyTo(ScrollPhysics? ancestor) =>
      _SnapPhysics(cell: cell, parent: buildParent(ancestor));

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final proposed = super.createBallisticSimulation(position, velocity);
    if (cell <= 0) return proposed;

    final landing = proposed?.x(double.infinity) ?? position.pixels;
    final bounded = landing.clamp(position.minScrollExtent, position.maxScrollExtent);
    final snapped = (bounded / cell).round() * cell;
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

class _Day extends StatefulWidget {
  const _Day({
    required this.date,
    required this.selected,
    required this.settle,
    required this.viewport,
    required this.controller,
    required this.index,
    required this.cell,
    required this.onTap,
  });

  final int date;
  final bool selected;
  final Animation<double> settle;
  final double viewport;
  final ScrollController controller;
  final int index;
  final double cell;
  final VoidCallback onTap;

  @override
  State<_Day> createState() => _DayState();
}

class _DayState extends State<_Day> {
  /* Pressed is a state of one day, not of the run. The mark under the finger is
     the one that answers, which is what makes a tap feel aimed rather than
     broadcast to the whole strip. */
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final date = widget.date;
    final selected = widget.selected;
    final settle = widget.settle;
    final viewport = widget.viewport;
    final controller = widget.controller;
    final index = widget.index;
    final cell = widget.cell;
    final info = dayInfo(date);
    /* Стан дня береться з підсумків, а не з фікстур: у режимі «мої» кружечок
       має говорити про той день, який справді записаний. Порожній день і день,
       про який ще не прочитали, виглядають однаково, і це чесно. */
    final scope = AppScope.maybeOf(context);
    final state = scope == null
        ? DayState.empty
        : scope.stats.stateOn(date, goalKcal: goalOf(scope.s).kcal, direction: scope.s.direction);

    final ring = switch (state) {
      DayState.ok => c.success,
      // Перебір і голод обидва червоні: різні причини, однакова відповідь.
      DayState.over || DayState.under => c.protein,
      DayState.pending || DayState.empty => c.hairline,
    };

    final cellChild = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(info.label, style: context.t.labelSmall?.copyWith(fontSize: 11)),
        const SizedBox(height: 7),
        _Circle(
          day: info.day,
          selected: selected,
          pressed: _down,
          ring: ring,
          // A day with nothing in it gets a dashed ring and no verdict: a solid
          // grey circle reads as a judgement on a day nobody logged.
          dashed: state == DayState.empty && !selected,
          dim: state == DayState.empty,
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 4,
          height: 4,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: date == todayDate ? c.accent : const Color(0x00000000),
            ),
          ),
        ),
      ],
    );

    /* Raw pointer for the press, recogniser for the tap. A tap recogniser inside
       a scrolling run waits to win the arena before it reports the press, and by
       then a quick tap is already over: the circle never moved. */
    return Listener(
      onPointerDown: (_) => setState(() => _down = true),
      onPointerUp: (_) => setState(() => _down = false),
      onPointerCancel: (_) => setState(() => _down = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: Listenable.merge([controller, settle]),
          builder: (context, child) {
            if (!controller.hasClients) return child!;

            /* Distance from the right edge, in cells. The strip bends around the
             day at the front, so the far side of the run is the one that leans
             away, and geometry is arithmetic on the scroll offset rather than a
             question asked of each cell. */
            final x = index * cell - controller.offset;
            final fromRight = (viewport - CalviSize.gutter - x - cell) / viewport;
            final k = fromRight.clamp(0.0, 1.0);

            /* Each day unfolds a little after the one to its right. The delay is
             its own share of one controller, so a single animation drives the
             whole run instead of a timer per cell. */
            const total = (_settleMs + _staggerMax) * 1.0;
            final wait = math.min(k * (viewport / cell) * _stagger, _staggerMax.toDouble());

            /* Форма і прозорість розкладаються різний час, і саме звідси береться
               мʼякість. У демці це два переходи в одному рядку: transform 520 мс,
               opacity 440 мс. Прозорість добігає раніше, тож день уже видно
               повністю, поки він ще дорівнюється, і рух дочитується оком, а не
               обривається разом із проявленням. */
            double at(int ms) => Interval(
              wait / total,
              math.min(1, (wait + ms) / total),
              curve: CalviMotion.easeRise,
            ).transform(settle.value);

            final depth = 1 - at(_settleMs);
            final veil = 1 - at(_fadeMs);
            if (depth < 0.001 && veil < 0.001) return child!;

            /* Числа зняті з демки один в один: нахил 26 градусів, глибина 64
               пікселі, зменшення на пʼяту частину, прозорість до 0.4.
               Тут стояв нахил 0.9 радіана, тобто 51 градус: удвічі різкіше за
               демку, від чого крайні дні лягали майже ребром. Глибини не було
               зовсім, і без неї нахил читався як перекіс, а не як відхід удалину. */
            return Transform(
              alignment: Alignment.centerRight,
              transform: Matrix4.identity()
                // Перспектива 560 пікселів, як `perspective: 560px` у демці.
                ..setEntry(3, 2, 1 / 560)
                ..translateByDouble(0, 0, -_depthPx * k * depth, 1)
                ..rotateY(_tilt * k * depth)
                ..scaleByDouble(1 - _shrink * k * depth, 1 - _shrink * k * depth, 1, 1),
              // Квадрат навмисно: прозорість наростає пізніше за нахил.
              child: Opacity(opacity: 1 - _fade * k * k * veil, child: child),
            );
          },
          child: cellChild,
        ),
      ),
    );
  }
}

/// The number and its ring.
///
/// The chosen day and today are different things and both have to show: one is
/// filled, the other keeps a dot underneath.
class _Circle extends StatelessWidget {
  const _Circle({
    required this.day,
    required this.selected,
    required this.pressed,
    required this.ring,
    required this.dashed,
    required this.dim,
  });

  final int day;
  final bool selected;

  /// Under the finger right now, which is a different thing from chosen.
  final bool pressed;
  final Color ring;
  final bool dashed;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AnimatedScale(
      /* The chosen day stands a little proud of the row and gives way under the
         finger. Both are the same 140 ms the demo uses, so a tap reads as one
         movement rather than as a colour change somewhere in a strip. */
      scale: pressed
          ? 0.9
          : selected
          ? 1.06
          : 1,
      duration: CalviMotion.fast,
      curve: CalviMotion.ease,
      child: AnimatedContainer(
        duration: CalviMotion.fast,
        curve: CalviMotion.ease,
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? c.button : null,
          // A dashed ring is painted, not bordered: a box border has one style
          // for the whole shape and none of them is dashes.
          border: dashed ? null : Border.all(color: selected ? c.button : ring, width: 2),
        ),
        child: CustomPaint(
          painter: dashed ? _DashedRing(colour: ring) : null,
          child: Center(
            child: Text(
              '$day',
              style: context.t.titleMedium?.copyWith(
                color: selected
                    ? c.buttonText
                    : dim
                    ? c.textSecondary
                    : c.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRing extends CustomPainter {
  _DashedRing({required this.colour});

  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2 - 1;
    final centre = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = colour;

    /* Sixteen dashes: enough to read as dashed at this size, few enough that the
       gaps stay visible instead of turning the ring into a grainy line. */
    const dashes = 16;
    const arc = math.pi * 2 / dashes;
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(Rect.fromCircle(center: centre, radius: r), i * arc, arc * 0.55, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedRing old) => old.colour != colour;
}
