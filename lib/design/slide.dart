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

      /* No fade on the way in. The demo replaces the page outright, so nothing
         shows through the arriving screen; here the old one is still mounted
         underneath, and a half transparent new page let its text read straight
         through the old page's for the length of the run. The arriving screen is
         opaque and simply travels. */
      return AnimatedBuilder(
        animation: Listenable.merge([animation, secondary]),
        child: child,
        builder: (context, child) => RepaintBoundary(
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
class Slide extends StatefulWidget {
  const Slide({super.key, required this.value, required this.dir, required this.child});

  /// Changing this replays the animation.
  final Object value;

  /// 1 forward, -1 back, 0 for a screen that is itself arriving: the outer
  /// slide already carries it, and a second one underneath would fight it.
  final int dir;

  final Widget child;

  @override
  State<Slide> createState() => _SlideState();
}

/// The same motion the routes make, without a route.
///
/// The arriving page travels and stays opaque; the one it covers is kept for the
/// length of the run and eases the other way underneath it. Fading the new page
/// up from nothing was what made every settings panel blink: with the old one
/// already gone, the first frames were the bare window showing through.
class _SlideState extends State<Slide> with SingleTickerProviderStateMixin {
  late final AnimationController _run = AnimationController(
    vsync: this,
    duration: CalviMotion.screen,
  );

  /* Дві комірки, і екран лишається в тій, у якій зʼявився.
   *
   * Раніше той, що йде, просто передавався далі як віджет, і Flutter будував
   * його наново на новому місці: екран, який мав тихо поїхати вбік, проживав
   * своє народження вдруге і програвав усе, що програється при появі. Найкраще
   * це було видно на кільці навколо кнопки «назад»: воно малювалось двічі
   * поспіль на кожному екрані налаштувань.
   *
   * Тепер обидві комірки постійні й ключовані, а зміна екрана це перекладання
   * нового в іншу комірку. Жоден елемент не переїжджає, тому й не оживає вдруге. */
  Widget? _a;
  Widget? _b;
  Object? _aValue;
  Object? _bValue;
  bool _currentInA = true;
  int _dir = 1;

  @override
  void initState() {
    super.initState();
    _a = widget.child;
    _aValue = widget.value;

    _run.addStatusListener((s) {
      if (s != AnimationStatus.completed) return;
      // Те, що поїхало, більше не потрібне: комірка звільняється.
      setState(() {
        if (_currentInA) {
          _b = null;
          _bValue = null;
        } else {
          _a = null;
          _aValue = null;
        }
      });
    });
  }

  @override
  void didUpdateWidget(Slide old) {
    super.didUpdateWidget(old);

    if (old.value == widget.value) {
      // Той самий екран, просто перебудований: оновлюємо його на місці.
      setState(() {
        if (_currentInA) {
          _a = widget.child;
        } else {
          _b = widget.child;
        }
      });
      return;
    }

    setState(() {
      if (widget.dir == 0) {
        // Без руху це проста підміна, і комірку міняти нема сенсу.
        if (_currentInA) {
          _a = widget.child;
          _aValue = widget.value;
        } else {
          _b = widget.child;
          _bValue = widget.value;
        }
        return;
      }

      _dir = widget.dir;
      if (_currentInA) {
        _b = widget.child;
        _bValue = widget.value;
      } else {
        _a = widget.child;
        _aValue = widget.value;
      }
      _currentInA = !_currentInA;
    });

    _run.forward(from: 0);
  }

  @override
  void dispose() {
    _run.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /* Одна форма дерева на всі стани, і це не стилістика.
     *
     * Раніше під час руху екран жив усередині `Stack`, а після завершення
     * повертався нагору без обгортки. Для Flutter це інше місце в дереві: стан
     * дитини створювався наново, і все, що програється при появі, програвалось
     * удруге. Найпомітніше на кнопці «назад»: кільце навколо неї малювалось два
     * рази поспіль на кожному екрані налаштувань.
     *
     * Тому обидві комірки тут постійні й ключовані. Порожня комірка того, що
     * пішло, коштує нічого, а екран лишається тим самим елементом від першого
     * кадру руху до останнього. */
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _run,
        builder: (context, _) {
          final t = CalviMotion.ease.transform(_run.value);
          final moving = _run.isAnimating;

          Widget cell({required bool isA}) {
            final child = isA ? _a : _b;
            final value = isA ? _aValue : _bValue;
            if (child == null) return const SizedBox.shrink();

            final current = isA == _currentInA;
            final dx = !moving
                ? 0.0
                : current
                ? _dir * _travel * (1 - t)
                : -_dir * _travel * t;

            return Transform.translate(
              offset: Offset(dx, 0),
              /* Обгортка постійна, а міняється лише її прапорець. Варіант «або
                 з IgnorePointer, або без» додавав рівень у дерево тому, хто
                 їде, і екран народжувався заново вже вкотре: та сама помилка,
                 що й нагорі, тільки глибша. */
              child: IgnorePointer(
                ignoring: !current,
                child: KeyedSubtree(key: ValueKey(value), child: child),
              ),
            );
          }

          /* Порядок малювання, а не порядок комірок: той, що приходить, має
             бути зверху. Ключі лишаються ті самі, тому перестановка міняє лише
             що поверх чого, і жоден елемент від цього не перебудовується. */
          final a = KeyedSubtree(key: const ValueKey('#a'), child: cell(isA: true));
          final b = KeyedSubtree(key: const ValueKey('#b'), child: cell(isA: false));

          return Stack(children: _currentInA ? [b, a] : [a, b]);
        },
      ),
    );
  }
}
