import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/meal.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/today/meal_card.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// Числа в рядку страви стоять у порядку БЖВ, як і три картки вгорі.
///
/// Тут стояло Б, В, Ж. Кольори збігались із числами, тобто рядок був правдивим,
/// але читався як неправда: людина щойно подивилась на картки в порядку БЖВ і
/// читає рядок так само, не звіряючи кольорів. Яєчня виглядала стравою на один
/// грам жиру.
void main() {
  testWidgets('білки, жири, вуглеводи саме в цьому порядку', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: Scaffold(
          body: MealCard(
            slot: baseSlots['breakfast']!,
            meals: const [
              Meal(
                id: 'm1',
                icon: 'egg',
                title: 'Яєчня з двох яєць',
                time: '08:12',
                slotId: 'breakfast',
                grams: 110,
                kcal: 196,
                protein: 13,
                fat: 15,
                carbs: 1,
              ),
            ],
            open: true,
            onToggle: () {},
            onAdd: (_) {},
            onManual: (_) {},
            noraCan: true,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    /* Числа читаються зліва направо, як їх бачить людина. Жири мають стояти
       перед вуглеводами, тобто пʼятнадцять перед одиницею. */
    final numbers = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .whereType<String>()
        .toList();

    final fat = numbers.indexOf('15');
    final carbs = numbers.indexOf('1');

    expect(fat, isNot(-1), reason: 'жирів немає в рядку');
    expect(carbs, isNot(-1), reason: 'вуглеводів немає в рядку');
    expect(fat, lessThan(carbs), reason: 'жири і вуглеводи стоять навпаки');
  });

  testWidgets('колір крапки відповідає своєму числу', (tester) async {
    final palette = calviLightTheme.extension<CalviTheme>()!.c;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: Scaffold(
          body: MealCard(
            slot: baseSlots['breakfast']!,
            meals: const [
              Meal(
                id: 'm1',
                icon: 'bread',
                title: 'Хліб житній',
                time: '08:12',
                slotId: 'breakfast',
                grams: 35,
                kcal: 82,
                protein: 3,
                fat: 1,
                carbs: 15,
              ),
            ],
            open: true,
            onToggle: () {},
            onAdd: (_) {},
            onManual: (_) {},
            noraCan: true,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    /* Порядок кольорів має бути той самий, що й у чисел: інакше перестановка
       чисел просто поміняла б місцями брехню. */
    final dots = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((w) => (w.decoration as BoxDecoration).color)
        .whereType<Color>()
        .where((col) => col == palette.protein || col == palette.fats || col == palette.carbs)
        .toList();

    expect(dots, [palette.protein, palette.fats, palette.carbs]);
  });
}
