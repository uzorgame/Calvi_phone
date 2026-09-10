import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/ruler.dart';
import 'package:calvi/design/shell.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/start/start_screen.dart';

/* Напрямок і цільова вага не можуть суперечити одне одному.
 *
 * Доти могли: людина обирала «Схуднути» і виставляла ціль вищу за свою вагу.
 * Картка казала «дефіцит», формула рахувала набір, а прогноз обіцяв тижні до
 * ваги, від якої людина тікає. Жодне з цих чисел окремо не було неправдою.
 *
 * Тут перевіряються три правила, і всі три про одне: сторона стрічки і є
 * напрямком.
 */
void main() {
  /// Крок «Куди рухаємось». Вага стандартна, 80 кг, ціль 74.
  Future<void> goal(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        scrollBehavior: const CalviScroll(),
        home: StartScreen(step: 5, onFinish: (_) {}),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Чи вибрана картка з таким написом.
  bool picked(WidgetTester tester, String label) => tester
      .widget<CalviPick>(
        find.ancestor(of: find.text(label), matching: find.byType(CalviPick)),
      )
      .on;

  testWidgets('ціль вища за вагу означає «Набрати», хоч би що стояло раніше', (tester) async {
    await goal(tester);
    expect(find.textContaining('74.0'), findsOneWidget, reason: 'починаємо з мінус шести');
    expect(picked(tester, 'Схуднути'), isTrue);

    /* Стрічку тягнуть вліво, і значення росте. Сімсот пікселів це шість із
       гаком кілограмів: рівно стільки, щоб перейти свою вагу. */
    await tester.drag(find.byType(CalviRuler), const Offset(-700, 0));
    await tester.pumpAndSettle();

    expect(picked(tester, 'Набрати'), isTrue, reason: 'напрямок пішов за стрічкою');
    expect(picked(tester, 'Схуднути'), isFalse);
  });

  testWidgets('«Тримати вагу» відводить стрічку до ваги і аж тоді ховає її', (tester) async {
    await goal(tester);

    await tester.tap(find.text('Тримати вагу'));
    await tester.pump();

    // Стрічка ще на екрані: рух, заради якого все це, має бути видно.
    expect(find.byType(CalviRuler), findsOneWidget, reason: 'їде, а не зникла');

    await tester.pump(const Duration(milliseconds: 700));
    expect(find.textContaining('80.0'), findsOneWidget, reason: 'доїхала рівно до ваги');

    /* Ще такт: годинник, який ховає стрічку, кадрів не планує, і сам по собі
       `pumpAndSettle` його не діжде. */
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.byType(CalviRuler), findsNothing, reason: 'доїхала і пішла');
  });

  testWidgets('назад до «Схуднути» ціль відходить від ваги сама', (tester) async {
    await goal(tester);

    await tester.tap(find.text('Тримати вагу'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Схуднути'));
    await tester.pumpAndSettle();

    /* Своєї відстані після «Тримати» немає, тому береться стандартна: шість
       кілограмів униз. */
    expect(find.textContaining('74.0'), findsOneWidget);
    expect(picked(tester, 'Схуднути'), isTrue);
  });
}
