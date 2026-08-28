import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/meal.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/l10n/labels.dart';
import 'package:calvi/screens/today/meal_card.dart';

/// Переклад і вибір мови.
///
/// Єдиний тест, який навмисно не прив'язаний до української: решта перевіряє
/// поведінку і читає український текст, а цей перевіряє сам переклад.
void main() {
  Widget wrap(Locale? locale, Widget child) => MaterialApp(
    localizationsDelegates: L.localizationsDelegates,
    supportedLocales: const [Locale('en'), Locale('uk')],
    locale: locale,
    theme: calviLightTheme,
    home: Scaffold(body: child),
  );

  Widget card(int meals) => MealCard(
    slot: baseSlots['breakfast']!,
    meals: [
      for (var i = 0; i < meals; i++)
        Meal(
          id: 'm$i',
          icon: 'grain',
          title: 'Вівсянка',
          time: '08:2$i',
          slotId: 'breakfast',
          grams: 100,
          kcal: 100,
        ),
    ],
    open: false,
    onToggle: () {},
    onAdd: (_) {},
    onManual: (_) {},
    noraCan: true,
  );

  testWidgets('українською картка називається своїм словом', (tester) async {
    await tester.pumpWidget(wrap(const Locale('uk'), card(2)));
    await tester.pumpAndSettle();

    expect(find.text('Сніданок'), findsOneWidget);
    expect(find.text('2 записи'), findsOneWidget);
  });

  testWidgets('англійською тим самим місцем стоїть англійське', (tester) async {
    await tester.pumpWidget(wrap(const Locale('en'), card(2)));
    await tester.pumpAndSettle();

    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('2 entries'), findsOneWidget);
  });

  /* Три форми множини це і є причина, чому переклад зроблений через ARB, а не
     через мапу рядків. Один запис, два записи, п'ять записів. */
  testWidgets('українська множина має три форми', (tester) async {
    for (final (count, want) in [(1, '1 запис'), (3, '3 записи'), (5, '5 записів')]) {
      await tester.pumpWidget(wrap(const Locale('uk'), card(count)));
      await tester.pumpAndSettle();
      expect(find.text(want), findsOneWidget, reason: 'для $count очікували «$want»');
    }
  });

  /* Головна вимога: мова пристрою, якщо вона в нас є, інакше англійська. Саме
     тому англійська стоїть першою в `supportedLocales`. */
  testWidgets('мова пристрою береться, коли вона в нас є', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('uk')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(wrap(null, card(2)));
    await tester.pumpAndSettle();

    expect(find.text('Сніданок'), findsOneWidget);
  });

  testWidgets('чужа мова пристрою падає на англійську, а не на українську', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('de'), Locale('fr')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(wrap(null, card(2)));
    await tester.pumpAndSettle();

    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Сніданок'), findsNothing);
  });

  /* Українська відмінює іменник після прийменника, а сам прийменник чергується
     для звучання. Складене в коді з «в» плюс назва, це давало «в вечеря». */
  testWidgets('назва картки в реченні стоїть у правильному відмінку', (tester) async {
    late L uk;
    await tester.pumpWidget(
      wrap(
        const Locale('uk'),
        Builder(
          builder: (context) {
            uk = L.of(context);
            return Column(
              children: [
                for (final id in ['breakfast', 'lunch', 'dinner', 'snack'])
                  Text(slotInto(context, baseSlots[id]!)),
              ],
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('в сніданок'), findsOneWidget);
    expect(find.text('в обід'), findsOneWidget);
    expect(find.text('у вечерю'), findsOneWidget, reason: 'не «в вечеря» і не «в вечерю»');
    expect(find.text('в перекус'), findsOneWidget);

    // І в реченні цілком, як його бачить людина.
    expect(uk.todayLoggedAskWeight('у вечерю'), startsWith('Записала у вечерю.'));
  });

  /* Помічниця вміє перейменувати картку за фактичним часом. Такий напис
     приходить її словами, і підміняти його перекладом не можна. */
  testWidgets('перейменована карткa лишається зі своїм написом', (tester) async {
    await tester.pumpWidget(
      wrap(
        const Locale('en'),
        Builder(
          builder: (context) =>
              Text(slotTitle(context, baseSlots['breakfast']!.renamed('Пізній сніданок'))),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Пізній сніданок'), findsOneWidget);
  });
}
