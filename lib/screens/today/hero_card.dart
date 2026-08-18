import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/day.dart';
import '../../format.dart';
import '../../data/app_scope.dart';
import '../../design/ring.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';

/// The day's main card, one side at a time.
///
/// **It is a physical object that turns.** Calories do not fade into weight:
/// the side in front leaves upward and the other rises to take its place. A
/// cross-fade would say the two figures are alternatives; a turn says they are
/// two sides of one card.
///
/// **Every step goes the same way.** On the first the front leaves and the back
/// rises; on the second the roles swap, so the back leaves and the front rises
/// from below. Without that the deck reverses on every other step: pull up twice
/// and the card comes back down. The two sides trade directions at the halfway
/// mark, where both are invisible, so the swap is never seen.
///
/// The motion is driven frame by frame from one continuous position, so a card
/// thrown by hand and a card that turned by itself move identically.
class HeroCard extends StatefulWidget {
  const HeroCard({super.key, required this.day, required this.burned, required this.goal});

  final DayModel day;

  /// What this day is measured against, as the settings currently have it.
  final DayGoal goal;

  /// Calories the day gave back. Passed in because a session logged during the
  /// session is not in the fixture the day was built from.
  final int burned;

  @override
  State<HeroCard> createState() => _HeroCardState();
}

/// Calories hold the card; weight takes it for a moment now and then. Long
/// enough that the card is never mid-turn when the eye arrives.
const _kcalHold = Duration(seconds: 16);
const _weightHold = Duration(seconds: 7);

/// How far a side travels while it leaves or arrives.
const _lift = 26.0;

/// A drag has to cross this much of a step before the release finishes it.
const _throw = 0.18;

/// How far a drag can carry the card into the next side.
const _reach = 0.46;

class _HeroCardState extends State<HeroCard> with SingleTickerProviderStateMixin {
  /* Built here rather than lazily: the deck no longer reads the controller while
     it paints, so a card that was never turned would have created it for the
     first time inside dispose, where there is no ticker to hang it on. */
  late final AnimationController _c;

  /// Where the deck stands, continuously, for the two faces to read.
  final _turn = ValueNotifier<double>(0);

  void _paint() {
    if (!_c.isAnimating) return;
    _turn.value = _origin + (_target - _origin) * Curves.easeOutQuart.transform(_c.value);
  }

  /// Continuous position. Whole numbers are the resting states.
  double _pos = 0;
  double _held = 0;
  double? _from;

  int get _side => _pos.round() % 2 == 0 ? 0 : 1;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this)..addListener(_paint);
    _wait();
  }

  /* The clock stops while the card is in hand: a turn that started by itself
     would snatch the card out from under the finger.
     A Timer and not a delayed future, because this one has to be cancellable:
     a sixteen second wait that outlives the screen is a screen still running
     after it is gone. */
  Timer? _clock;
  void _wait() {
    _clock?.cancel();
    _clock = Timer(_side == 1 ? _weightHold : _kcalHold, () {
      if (!mounted || _from != null) return;
      _glide(_pos.roundToDouble() + 1);
    });
  }

  void _glide(double to) {
    final from = _pos;
    final span = to - from;
    if (span == 0) return;

    _c
      ..stop()
      ..duration = const Duration(milliseconds: 520)
      ..removeStatusListener(_landed)
      ..addStatusListener(_landed);

    _c.value = 0;
    _target = to;
    _origin = from;
    _c.forward();
  }

  double _target = 0;
  double _origin = 0;

  void _landed(AnimationStatus s) {
    if (s != AnimationStatus.completed) return;
    // Folded back so the counter cannot grow without bound.
    setState(() => _pos = _target % 2 == 0 ? 0 : 1);
    _turn.value = _pos;
    _wait();
  }

  @override
  void dispose() {
    _clock?.cancel();
    _c.dispose();
    _turn.dispose();
    super.dispose();
  }

  /// Where the two sides sit at any point of the turn.
  ({Offset shift, double scale, double opacity}) _face(bool front, double pos) {
    final d = pos % 2 < 0 ? pos % 2 + 2 : pos % 2;
    final off = front ? (d < 2 - d ? d : 2 - d) : (d - 1).abs();
    // Second leg: the sides trade which one is leaving.
    final second = d >= 1;
    final sign = front ? (second ? 1.0 : -1.0) : (second ? -1.0 : 1.0);
    return (
      shift: Offset(0, sign * _lift * off),
      scale: 1 - 0.14 * off,
      opacity: (1 - off).clamp(0.0, 1.0),
    );
  }

  /// Puts the deck back on a whole side, whether the finger let go or the page
  /// pulled the gesture out from under it.
  void _settle() {
    if (_from == null) return;
    final over = _held;
    _pos += over;
    _from = null;
    _held = 0;
    _turn.value = _pos;
    _glide(
      over.abs() > _throw
          ? (_pos - over).roundToDouble() + (over > 0 ? 1 : -1)
          : (_pos - over).roundToDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    /* Built once per real change and handed to the builder below as a child, so
       the faces are the same widgets from frame to frame and the framework skips
       their subtrees entirely while the deck turns. */
    final kcal = _Kcal(day: widget.day, burned: widget.burned, goal: widget.goal);
    const weight = _Weight();

    /* The two faces share one box, and a system font scale the phone sets can
       push the taller of them past it: what spills is clipped, and a clipped
       card reads as a card that vanished. The figures here are already large,
       so the scale is allowed a little room and no more. */
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.15,
      child: GestureDetector(
        // The card takes the vertical drag itself. It is a small target on a long
        // page, so the scroll it costs is cheap.
        onVerticalDragStart: (d) {
          _c.stop();
          _clock?.cancel();
          _from = d.localPosition.dy;
          _held = 0;
        },
        onVerticalDragUpdate: (d) {
          if (_from == null) return;
          // Up carries the far side away, the way a deck shuffles under a thumb.
          final raw = (_from! - d.localPosition.dy) * 1.1 / 180;
          _held = raw.clamp(-_reach, _reach);
          _turn.value = _pos + _held;
        },
        onVerticalDragEnd: (_) => _settle(),
        /* The page can take the gesture away mid-drag, and when it does there is
         no end event. Without this the deck stayed wherever the finger left it,
         which on a half turn is a card standing edge on: invisible. */
        onVerticalDragCancel: _settle,
        child: ValueListenableBuilder<double>(
          valueListenable: _turn,
          builder: (context, pos, _) {
            final front = _face(true, pos);
            final back = _face(false, pos);
            return Stack(
              children: [
                _Side(
                  shift: front.shift,
                  scale: front.scale,
                  opacity: front.opacity,
                  child: kcal,
                ),
                Positioned.fill(
                  child: _Side(
                    shift: back.shift,
                    scale: back.scale,
                    opacity: back.opacity,
                    child: weight,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({
    required this.shift,
    required this.scale,
    required this.opacity,
    required this.child,
  });

  final Offset shift;
  final double scale;
  final double opacity;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    /* An invisible side still holds the card open. The front one is what the
       stack measures itself by, so returning nothing for it once it faded out
       collapsed the card to no height at all, and the weight side, stretched to
       fill that, went with it: the card vanished the moment it finished turning
       to kilograms. Opacity zero already skips the painting; the layout is the
       part that has to stay. */
    return IgnorePointer(
      ignoring: opacity <= 0.01,
      child: Transform.translate(
        offset: shift,
        child: Transform.scale(
          scale: scale,
          child: Opacity(opacity: opacity, child: child),
        ),
      ),
    );
  }
}

/// The card itself. Both sides are whole cards, border and all: turning only the
/// contents inside a frame that stays put reads as a panel flipping in a window.
class _Shell extends StatelessWidget {
  const _Shell({required this.left, required this.ring, required this.dot});

  final Widget left;
  final Widget ring;

  /// Which of the two dots in the corner is lit.
  final int dot;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(22),
      constraints: const BoxConstraints(minHeight: 132),
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: c.cardBorder),
        borderRadius: BorderRadius.circular(CalviSize.rLarge),
      ),
      child: Stack(
        /* The dots sit in the card's own padding, which is outside this stack:
           the stack clips by default, and clipping is what has been eating them.
           A card that turns by itself and never said it had another side reads
           as a glitch the first time it happens. */
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              Expanded(child: left),
              const SizedBox(width: 14),
              ring,
            ],
          ),
          // Two dots, so the card says it has another side before anyone pulls
          // it: one that turns by itself and never said so reads as a glitch.
          Positioned(
            right: -8,
            bottom: -12,
            child: Row(
              children: [
                _Dot(on: dot == 0),
                const SizedBox(width: 4),
                _Dot(on: dot == 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 5,
    height: 5,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.c.text.withValues(alpha: on ? 0.5 : 0.14),
      ),
    ),
  );
}

/// Overshoot at which the ring is fully red: a third past the norm.
const _heat = 0.33;

class _Kcal extends StatelessWidget {
  const _Kcal({required this.day, required this.burned, required this.goal});

  final DayModel day;
  final int burned;
  final DayGoal goal;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final eaten = day.totals.kcal;
    final left = goal.kcal + burned - eaten;
    final progress = eaten / (goal.kcal + burned);

    /* Up to the norm the arc measures how much of the day is spent. Past it
       there is nothing left to measure, so it fills and starts to heat: full red
       a third over, and the saturation builds, so eighty extra calories look
       like eighty rather than like a catastrophe. */
    final heat = ((progress - 1) / _heat).clamp(0.0, 1.0);
    final ink = Color.lerp(c.button, c.protein, heat)!;

    return _Shell(
      dot: 0,
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(thousands(left.abs()), style: context.t.displayLarge?.copyWith(height: 1)),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${left >= 0 ? 'лишилось' : 'перебір'} з ${thousands(goal.kcal)} ккал',
                ),
                if (burned > 0)
                  TextSpan(
                    text: ' +$burned спалено',
                    style: TextStyle(color: c.success),
                  ),
              ],
            ),
            style: context.t.bodyMedium,
          ),
        ],
      ),
      ring: CalviRing(
        progress: progress,
        color: ink,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$streak',
              style: context.t.headlineMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 24 * -0.02,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'днів',
              style: context.t.labelSmall?.copyWith(
                fontSize: 9,
                letterSpacing: 9 * 0.04,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Weight extends StatelessWidget {
  const _Weight();

  @override
  Widget build(BuildContext context) {
    /* The person's own figures, not the fixtures. A weight set in settings and a
       card still showing the one the fixtures were written with are two answers
       to the same question. */
    final s = AppScope.of(context).s;

    /* Measured from where the goal started, not from the oldest reading: the
       ring shows progress on this goal, and a weight from before it was set has
       nothing to do with it. */
    final span = s.goalStartKg - s.targetKg;
    final done = span > 0 ? ((s.goalStartKg - s.weightKg) / span).clamp(0.0, 1.0) : 0.0;

    return _Shell(
      dot: 1,
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              text: s.weightKg.toStringAsFixed(1),
              children: [TextSpan(text: ' кг', style: context.t.headlineLarge)],
            ),
            style: context.t.displayLarge?.copyWith(height: 1),
          ),
          const SizedBox(height: 6),
          Text(
            'зараз, від ${s.goalStartKg.toStringAsFixed(1)} кг на старті цілі',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.t.bodyMedium?.copyWith(height: 1.25),
          ),
        ],
      ),
      ring: CalviRing(
        progress: done,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              s.targetKg.toStringAsFixed(0),
              style: context.t.headlineMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 24 * -0.02,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'ціль, кг',
              style: context.t.labelSmall?.copyWith(
                fontSize: 9,
                letterSpacing: 9 * 0.04,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
