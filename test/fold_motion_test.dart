import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/fold.dart';

/// Згортання: один рух на застосунок.
///
/// Так розкриваються картки дня, так само відкривається форма ручного запису.
/// Перевіряється саме рух, а не кінцевий стан: висота посеред дороги, і те, що
/// закриття швидше за відкриття. Тест, який дивиться тільки на «до» і «після»,
/// пропустив би і миттєвий стрибок, і застрягання на півдорозі.
void main() {
  const inside = 200.0;

  Widget wrap(bool open) => MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: CalviFold(
          open: open,
          child: const SizedBox(height: inside, width: 300),
        ),
      ),
    ),
  );

  double height(WidgetTester tester) => tester.getSize(find.byType(CalviFold)).height;

  testWidgets('розкривається поступово, а не стрибком', (tester) async {
    await tester.pumpWidget(wrap(false));
    expect(height(tester), 0, reason: 'закрита складка займає місце');

    await tester.pumpWidget(wrap(true));
    await tester.pump();

    /* Посеред дороги: вже не нуль і ще не вся. Саме це відрізняє розкриття від
       підміни одного стану іншим. */
    await tester.pump(const Duration(milliseconds: 200));
    final mid = height(tester);
    expect(mid, greaterThan(0), reason: 'на середині шляху висота ще нульова');
    expect(mid, lessThan(inside), reason: 'висота стрибнула до кінця одразу');

    await tester.pumpAndSettle();
    expect(height(tester), inside, reason: 'складка не доїхала до повного розміру');
  });

  testWidgets('вміст піднімається на такт пізніше за висоту', (tester) async {
    await tester.pumpWidget(wrap(false));
    await tester.pumpWidget(wrap(true));
    await tester.pump();

    /* Прозорість має затримку в 90 мс і йде 260: на сотій мілісекунді висота
       вже росте, а вміст ще напівпрозорий. Саме через це картка розгортається,
       а не просто стає вищою. */
    await tester.pump(const Duration(milliseconds: 100));
    /* Шукається всередині складки: сторінка має власні згасання, і `byType` без
       прив''язки хапає перше-ліпше з них. */
    final inFold = find.descendant(
      of: find.byType(CalviFold),
      matching: find.byType(FadeTransition),
    );

    final shown = tester.widget<FadeTransition>(inFold.first).opacity.value;
    expect(shown, greaterThan(0));
    expect(shown, lessThan(1), reason: 'вміст зʼявився разом із висотою, без такту');

    await tester.pumpAndSettle();
    final settled = tester
        .widget<FadeTransition>(
          find.descendant(of: find.byType(CalviFold), matching: find.byType(FadeTransition)).first,
        )
        .opacity
        .value;
    expect(settled, 1);
  });

  testWidgets('закривається швидше, ніж відкривається', (tester) async {
    /* Відкриття це запрошення, закриття це вже прийняте рішення. Повільне
       закриття читається як застрягле, і саме тому тривалості різні. */
    Future<int> run(bool open) async {
      await tester.pumpWidget(wrap(!open));
      await tester.pumpAndSettle();
      await tester.pumpWidget(wrap(open));
      await tester.pump();

      var ms = 0;
      final want = open ? inside : 0.0;
      while (ms < 1000 && (height(tester) - want).abs() > 0.5) {
        await tester.pump(const Duration(milliseconds: 20));
        ms += 20;
      }
      return ms;
    }

    final opening = await run(true);
    final closing = await run(false);

    expect(opening, greaterThan(closing), reason: 'закриття не швидше за відкриття');
    expect(opening, greaterThan(300), reason: 'відкриття підозріло швидке');
    expect(closing, lessThan(opening), reason: 'закриття тягнеться як відкриття');
  });
}
