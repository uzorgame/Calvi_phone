/// Згортання: один рух на застосунок.
///
/// Так розкриваються картки дня, так само відкривається форма ручного запису
/// всередині картки. Написане двічі розійшлося б на першій правці, а «майже
/// така сама» анімація помітна одразу.
///
/// **Відкриття довше за закриття.** Відкриття це запрошення, закриття це вже
/// прийняте рішення, і повільне читається як застрягле.
///
/// **Вміст піднімається на такт пізніше за висоту.** Тому картка розгортається,
/// а не просто стає вищою. Він лишається в дереві весь час: на закритті його
/// обрізає, а не висмикує з-під висоти.
library;

import 'package:flutter/material.dart';

import 'tokens.dart';

class CalviFold extends StatelessWidget {
  const CalviFold({super.key, required this.open, required this.child});

  final bool open;
  final Widget child;

  /// Скільки триває розкриття. Звідси ж бере тривалість проїзд сторінки за
  /// карткою, щоб рух читався як один, а не як прокрутка навздогін.
  static const openMs = Duration(milliseconds: 440);

  @override
  Widget build(BuildContext context) => ClipRect(
    child: AnimatedAlign(
      alignment: Alignment.topCenter,
      heightFactor: open ? 1 : 0,
      duration: open ? openMs : const Duration(milliseconds: 220),
      curve: open ? CalviMotion.easeRise : CalviMotion.easeIn,
      child: AnimatedSlide(
        offset: open ? Offset.zero : const Offset(0, -0.08),
        duration: Duration(milliseconds: open ? 420 : 180),
        curve: open ? CalviMotion.easeRise : CalviMotion.easeIn,
        child: AnimatedOpacity(
          opacity: open ? 1 : 0,
          duration: Duration(milliseconds: open ? 260 : 140),
          curve: Curves.linear,
          child: child,
        ),
      ),
    ),
  );
}
