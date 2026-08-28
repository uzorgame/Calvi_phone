import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/day_stats.dart';
import 'package:calvi/data/fixtures.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/data/week.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/today/hero_card.dart';

/// Поворот картки дня: «Стос» на три сторони.
///
/// Прогорнута сторона йде вгору і тане, наступна піднімається знизу їй услід.
/// Перевіряється рух, а не спокій: посеред кроку видно дві сторони, і жодна не
/// має ні зникнути раніше, ніж прийде наступна, ні лишитись висіти назавжди.
void main() {
  Widget wrap({VoidCallback? onWeek}) => AppScope(
    s: initialSettings(),
    set: (_) {},
    meds: const [],
    setMeds: (_) {},
    stats: DayStats.demo(),
    child: MaterialApp(
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      locale: const Locale('uk'),
      theme: calviLightTheme,
      home: Scaffold(
        body: Center(
          child: HeroCard(
            day: dayFor(0),
            burned: dayFor(0).burned,
            goal: goalOf(initialSettings()),
            week: weekSummary(DayStats.demo(), initialSettings()),
            onWeek: onWeek ?? () {},
          ),
        ),
      ),
    ),
  );

  /// Прозорості сторін просто зараз, у порядку колоди.
  List<double> sides(WidgetTester tester) =>
      tester.widgetList<Opacity>(find.byType(Opacity)).map((o) => o.opacity).toList();

  testWidgets('колода має три сторони, і в спокої видно рівно одну', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pump();

    final at = sides(tester);
    expect(at.length, 3, reason: 'сторін не три');
    expect(at.where((o) => o > 0.99).length, 1, reason: 'у спокої видно не одну сторону');
    expect(at.where((o) => o < 0.01).length, 2, reason: 'дві інші не сховані');
  });

  testWidgets('посеред кроку видно дві сторони, а не жодної', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pump();

    /* Палець тягне колоду на пів кроку і тримає. Саме тут стос або читається як
       поворот, або блимає: якщо на середині не видно нічого, картка на мить
       порожня. */
    final at = tester.getCenter(find.byType(HeroCard));
    final touch = await tester.startGesture(at);
    await tester.pump();
    /* Двома подіями, як веде палець: перша виграє арену в тапа (поріг руху
       зʼїдається на прийнятті), друга вже тягне колоду. Однією подією рух
       закінчувався рівно в мить прийняття, і тягнути було нічому. */
    await touch.moveBy(const Offset(0, -20));
    await tester.pump();
    await touch.moveBy(const Offset(0, -62));
    await tester.pump();

    final half = sides(tester);
    final lit = half.where((o) => o > 0.05).length;
    expect(lit, greaterThanOrEqualTo(2), reason: 'посеред кроку картка порожня: $half');

    await touch.up();
    await tester.pumpAndSettle();

    // І приземлилась на цілу сторону, а не між ними.
    final rest = sides(tester);
    expect(rest.every((o) => o < 0.01 || o > 0.99), isTrue, reason: 'колода зависла ребром: $rest');
  });

  testWidgets('один довгий рух веде через кілька сторін', (tester) async {
    /* Тут стояв затиск на пів кроку, і далі однієї сторони за раз прокрутити
       було не можна: колода впиралась у невидиму стіну. */
    await tester.pumpWidget(wrap());
    await tester.pump();

    final first = sides(tester).indexWhere((o) => o > 0.99);

    await tester.drag(find.byType(HeroCard), const Offset(0, -320));
    await tester.pumpAndSettle();

    final now = sides(tester).indexWhere((o) => o > 0.99);
    expect(now, isNot(first), reason: 'довгий рух нікуди не привів');
    expect(now, isNot(-1), reason: 'жодна сторона не видима після руху');
  });

  /* Тап, а не «трохи посовав і відпустив»: розпізнавач перетягування палець
     без руху відпускає мовчки, тож двері тижня мусять слухати власний тап.
     Саме так сторінка тижня і не відкривалась на телефоні. */
  testWidgets('тап по стороні тижня відкриває сторінку, по інших ні', (tester) async {
    var opened = 0;
    await tester.pumpWidget(wrap(onWeek: () => opened++));
    await tester.pump();

    // Зі сторони калорій тап нікуди не веде.
    await tester.tap(find.byType(HeroCard), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(opened, 0, reason: 'тиждень відкрився зі сторони калорій');

    // Два кроки вперед: калорії, вага, тиждень.
    await tester.drag(find.byType(HeroCard), const Offset(0, -60));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(HeroCard), const Offset(0, -60));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(HeroCard), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(opened, 1, reason: 'тап по стороні тижня не відкрив сторінку');
  });
}
