import 'package:flutter/material.dart';

import 'tokens.dart';

/// How far a screen travels on the way in. Short on purpose: the eye reads a
/// direction from the first few pixels, and a screen that flies the full width
/// spends most of its time being scenery.
const _travel = 26.0;

/// How a screen arrives.
///
/// **Enter only.** The screen coming in slides and fades; the one it covers does
/// not perform. Forward means from the right, back means from the left, and that
/// direction is the whole message: it says whether you went deeper or came back.
///
/// On the way back the roles swap, and the screen being *revealed* is the one
/// that slides, from the left. That is the part people actually watch, because
/// it is the thing they asked to see again.
Route<T> slideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, _, _) => page,
    transitionDuration: CalviMotion.screen,
    reverseTransitionDuration: CalviMotion.screen,
    transitionsBuilder: (context, animation, secondary, child) {
      /* `secondary` is this screen being covered by the next one. It runs
         backwards when that screen leaves, which is exactly the moment this one
         is revealed, so the same term draws the slide in from the left. */
      final revealed = Tween(
        begin: Offset.zero,
        end: const Offset(-_travel, 0),
      ).animate(CurvedAnimation(parent: secondary, curve: CalviMotion.ease));

      final arriving = Tween(
        begin: const Offset(_travel, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: CalviMotion.ease));

      return AnimatedBuilder(
        animation: Listenable.merge([animation, secondary]),
        child: child,
        builder: (context, child) => Opacity(
          opacity: animation.value,
          child: Transform.translate(offset: arriving.value + revealed.value, child: child),
        ),
      );
    },
  );
}

/// Replays a slide inside a screen when [value] changes.
///
/// Used where the frame stays and only its contents move: picking another day
/// keeps the header and the run of days, and slides everything under them in the
/// direction the week was moved.
class Slide extends StatelessWidget {
  const Slide({super.key, required this.value, required this.dir, required this.child});

  /// Changing this replays the animation.
  final Object value;

  /// 1 forward, -1 back, 0 for a screen that is itself arriving: the outer
  /// slide already carries it, and a second one underneath would fight it.
  final int dir;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (dir == 0) return KeyedSubtree(key: ValueKey(value), child: child);

    /* Enter-only, by remount: when the key changes the old subtree is disposed
       on the spot and the new one animates in from the side. An AnimatedSwitcher
       kept the outgoing screen alive for the length of the fade, and its curve
       held it at full opacity, so every transition wore the previous screen on
       top of the next. */
    return TweenAnimationBuilder<double>(
      key: ValueKey(value),
      tween: Tween(begin: 0, end: 1),
      duration: CalviMotion.screen,
      curve: CalviMotion.ease,
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(dir * _travel * (1 - t), 0), child: child),
      ),
    );
  }
}
