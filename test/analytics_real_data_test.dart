import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/day_stats.dart';
import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/day_reader.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/analytics/analytics_screen.dart';
import 'package:calvi/screens/analytics/charts.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// Аналітика показує те, що в базі, і мовчить, коли в базі нічого.
///
/// Тут довго стояли числа з фікстур і числа, вписані прямо в код: 96 білка, 71
/// жиру, 268 вуглеводів. Вони малювались завжди, у тому числі над порожнім
/// щоденником і поруч із чесними нулями. Найгірший різновид помилки, бо екран
/// при цьому виглядає робочим, і людина приймає по ньому рішення.
void main() {
  late CalviDb db;

  setUp(() => db = CalviDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  Widget screen(DayStats stats) => AppScope(
    s: initialSettings(),
    set: (_) {},
    meds: const [],
    setMeds: (_) {},
    stats: stats,
    child: MaterialApp(
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      locale: const Locale('uk'),
      theme: calviLightTheme,
      home: AnalyticsScreen(measures: stats.measures, onSettings: () {}),
    ),
  );

  Future<void> open(WidgetTester tester, DayStats stats) async {
    tester.view.physicalSize = const Size(390, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(screen(stats));
    /* Не pumpAndSettle: на екрані є анімації, які живуть довше за перевірку, і
       чекати їхнього кінця означає чекати вічно. Секунди досить, щоб усе
       намалювалось. */
    await tester.pump(const Duration(seconds: 1));
  }

  /* Екран це довгий список, який будує тільки видиме. Нижні картки треба
     долистати, інакше їх немає не тому, що вони порожні, а тому, що їх ще не
     створили. */
  Future<void> scrollTo(WidgetTester tester, Finder what) async {
    await tester.scrollUntilVisible(what, 260, scrollable: find.byType(Scrollable).first);
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('на порожній базі жодного стовпчика і жодного числа', (tester) async {
    await open(tester, DayStats.empty);

    expect(find.byType(MacroBars), findsNothing, reason: 'намальовано графік по нулях');
    expect(find.textContaining('Середнє зʼявиться'), findsOneWidget);
    expect(find.text('96'), findsNothing, reason: 'вписані в код числа лишились');
    expect(find.text('71'), findsNothing);
    expect(find.text('268'), findsNothing);
  });

  /* База живе у справжньому часі, а widget-тест у фальшивому: потік drift
     всередині testWidgets не дочекається свого першого значення ніколи. Тому
     все, що читається з бази, читається через runAsync. */
  Future<DayStats> fromDb(WidgetTester tester) async =>
      (await tester.runAsync(() => DayReader(db).watchStats().first))!;

  testWidgets('записане в базу доходить до середнього БЖВ', (tester) async {
    await tester.runAsync(
      () => db.diaryDao.addMeal(
        slot: 'breakfast',
        name: 'яєчня',
        kcal: 216,
        grams: 110,
        protein: 14,
        fat: 17,
        carbs: 1,
      ),
    );

    final stats = await fromDb(tester);
    await open(tester, stats);
    await scrollTo(tester, find.text('БЖВ у середньому'));

    /* Один записаний день: середнє за день дорівнює самому дню. Числа мають
       збігтись рівно, бо між базою і екраном тепер немає нічого, що б їх
       вигадувало. */
    /* Число і норма живуть в одному Text.rich, тому шукається по всьому рядку,
       а не по окремому віджету. Хвіст «/ 135г» це та сама форма, що на картках
       дня: середнє тепер малюється спільним рядом БЖВ, а не власною
       розкладкою цього екрана. */
    expect(
      find.textContaining('14 / ', findRichText: true),
      findsWidgets,
      reason: 'білок не дійшов з бази',
    );
    expect(
      find.textContaining('17 / ', findRichText: true),
      findsWidgets,
      reason: 'жири не дійшли з бази',
    );
    expect(find.byType(MacroBars), findsOneWidget);
  });

  testWidgets('гідратація рахується за записами дня', (tester) async {
    await tester.runAsync(() => db.diaryDao.addWater(ml: 800));

    final stats = await fromDb(tester);
    expect(stats.waterOn(0), 800, reason: 'вода не дійшла до підсумків');

    await open(tester, stats);
    await scrollTo(tester, find.text('Гідратація'));
    expect(
      find.text('800', findRichText: true),
      findsWidgets,
      reason: 'середнє по воді не показане',
    );
  });

  testWidgets('заміри з бази стають стрічкою вимірювань', (tester) async {
    await tester.runAsync(() async {
      await db.diaryDao.setWeight(kg: 75);
      await db.diaryDao.setMeasure(part: 'waist', cm: 88);
    });

    final stats = await fromDb(tester);
    await open(tester, stats);
    await scrollTo(tester, find.text('Заміри'));

    expect(find.text('Замірів ще немає.'), findsNothing);
    expect(find.text('Талія'), findsWidgets, reason: 'записана талія не показана');
  });
}
