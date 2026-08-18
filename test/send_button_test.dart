import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/chat.dart';
import 'package:calvi/design/icons.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/today/bottom_bar.dart';

/// Один круг на дві дії.
///
/// Поки поле порожнє, сказати можна тільки голосом. З першою ж літерою наміром
/// стає «надіслати», і кнопка має стати саме нею: дві кнопки поруч питали б
/// людину, якою з них вона хоче зробити те саме.
void main() {
  Widget bar({VoidCallback? onVoice, ValueChanged<String>? onSend}) => MaterialApp(
    theme: calviLightTheme,
    home: Scaffold(
      body: BottomBar(
        slot: 'Обід',
        messages: const <Msg>[],
        onSend: onSend ?? (_) {},
        onCamera: () {},
        onVoice: onVoice ?? () {},
        open: false,
        onOpen: (_) {},
        onClose: () {},
      ),
    ),
  );

  testWidgets('порожнє поле лишає мікрофон', (tester) async {
    await tester.pumpWidget(bar());
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Мікрофон'), findsOneWidget);
    expect(find.bySemanticsLabel('Надіслати'), findsNothing);
  });

  testWidgets('перша ж літера робить із мікрофона надсилання', (tester) async {
    await tester.pumpWidget(bar());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'б');
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Надіслати'), findsOneWidget);
    expect(find.bySemanticsLabel('Мікрофон'), findsNothing, reason: 'дві кнопки одночасно');
  });

  testWidgets('порожній рядок із пробілів це порожнє поле', (tester) async {
    await tester.pumpWidget(bar());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Мікрофон'), findsOneWidget);
  });

  testWidgets('стерте поле повертає мікрофон', (tester) async {
    await tester.pumpWidget(bar());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'борщ');
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Надіслати'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Мікрофон'), findsOneWidget);
  });

  /* --- Як саме знак намальовано ---
   *
   * Семантика каже, чим кнопка себе вважає, і цього мало: вона казала «Мікрофон»
   * і тоді, коли мікрофон лежав на боку. Тут перевіряється сама картинка.
   *
   * Причина була в `AnimatedSwitcher`: він викликає будівника переходу один раз,
   * коли зʼявляється новий знак, і зберігає готовий віджет. Кут повороту
   * підставлявся числом і застигав назавжди. Знак народжувався під -90° і під
   * ними ж і лишався, з першого кадру застосунку. */

  /// Усе, що зроблено зі знаком дорогою від кнопки до пікселів.
  ({int count, double turnDeg, double width}) drawn(WidgetTester tester) {
    final found = find.byWidgetPredicate(
      (w) => w is CalviIcon && (w.name == 'mic' || w.name == 'send'),
    );
    final elements = found.evaluate().toList();
    if (elements.isEmpty) return (count: 0, turnDeg: 0, width: 0);

    final m = Matrix4.identity();
    elements.first.visitAncestorElements((a) {
      final w = a.widget;
      if (w is Transform) m.multiply(w.transform);
      return w is! BottomBar;
    });

    return (
      count: elements.length,
      turnDeg: math.atan2(m.entry(1, 0), m.entry(0, 0)) * 180 / math.pi,
      width: math.sqrt(m.entry(0, 0) * m.entry(0, 0) + m.entry(1, 0) * m.entry(1, 0)),
    );
  }

  testWidgets('знак на кнопці стоїть рівно, а не боком', (tester) async {
    await tester.pumpWidget(bar());
    await tester.pumpAndSettle();

    var it = drawn(tester);
    expect(it.count, 1);
    expect(it.turnDeg, closeTo(0, 0.01), reason: 'мікрофон лежить на боці');
    expect(it.width, closeTo(1, 0.01), reason: 'мікрофон сплюснуто');

    await tester.enterText(find.byType(TextField), 'борщ');
    await tester.pumpAndSettle();

    it = drawn(tester);
    expect(it.count, 1);
    expect(it.turnDeg, closeTo(0, 0.01), reason: 'літак лежить на боці');
    expect(it.width, closeTo(1, 0.01));
  });

  testWidgets('на кнопці ніколи не буває двох знаків і ніколи жодного', (tester) async {
    await tester.pumpWidget(bar());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'б');
    // Крок по 20 мс через увесь перехід: раніше тут бували два знаки під різними
    // кутами, і обидва бліді, від чого кнопка виглядала порожньою.
    for (var ms = 0; ms <= 300; ms += 20) {
      expect(drawn(tester).count, 1, reason: 'на $ms мс переходу');
      await tester.pump(const Duration(milliseconds: 20));
    }
  });

  testWidgets('стерте на півдорозі повертає мікрофон, а не лишає знак у кутку', (tester) async {
    await tester.pumpWidget(bar());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'б');
    // Людина передумала швидше, ніж перехід дійшов до кінця.
    await tester.pump(const Duration(milliseconds: 90));
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    final it = drawn(tester);
    expect(it.count, 1);
    expect(it.turnDeg, closeTo(0, 0.01), reason: 'саме так знак і застрягав боком');
    expect(it.width, closeTo(1, 0.01));
    expect(find.bySemanticsLabel('Мікрофон'), findsOneWidget);
  });

  testWidgets('перехід справді рухається щокадру', (tester) async {
    await tester.pumpWidget(bar());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'б');

    /* Раніше і поворот, і масштаб були числами, підставленими один раз, тому
       ширина стояла на місці весь перехід. Рухалась тільки прозорість, бо вона
       єдина слухала анімацію сама. */
    final widths = <double>[];
    for (var ms = 0; ms < 240; ms += 8) {
      await tester.pump(const Duration(milliseconds: 8));
      widths.add(drawn(tester).width);
    }

    expect(widths.toSet().length, greaterThan(10), reason: 'знак не рухається під час переходу');
    expect(widths.first, lessThan(0.7), reason: 'знак не приходить меншим, як у демці');

    await tester.pumpAndSettle();
    expect(drawn(tester).width, closeTo(1, 0.01), reason: 'лишився сплюснутим');
  });

  testWidgets('кнопка надсилання справді надсилає, а не слухає', (tester) async {
    var said = '';
    var listened = false;

    await tester.pumpWidget(
      bar(onSend: (text) => said = text, onVoice: () => listened = true),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'два яйця');
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Надіслати'));
    await tester.pumpAndSettle();

    expect(said, 'два яйця');
    expect(listened, isFalse, reason: 'натиснули надіслати, а відкрилось диктування');
  });
}
