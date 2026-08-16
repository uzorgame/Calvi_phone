import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/meal.dart';
import 'package:calvi/data/measure.dart';
import 'package:calvi/data/workout.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/today/measure_card.dart';
import 'package:calvi/screens/today/meal_card.dart';
import 'package:calvi/screens/today/water_card.dart';
import 'package:calvi/screens/today/workout_card.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: calviLightTheme,
  home: Scaffold(body: ListView(children: [child])),
);

void main() {
  testWidgets('вода рахує склянки і крокує по 100 мл', (tester) async {
    var ml = 900;
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, set) => WaterCard(
            ml: ml,
            goalMl: 2200,
            onChange: (v) => set(() => ml = v),
            open: true,
            onToggle: () {},
          ),
        ),
      ),
    );

    expect(find.text('близько 4 склянок'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Більше на 100 мл'));
    await tester.pump();
    expect(ml, 1000);
  });

  testWidgets('вода не йде в мінус', (tester) async {
    var ml = 50;
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, set) => WaterCard(
            ml: ml,
            goalMl: 2200,
            onChange: (v) => set(() => ml = v),
            open: true,
            onToggle: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Менше на 100 мл'));
    await tester.pump();
    expect(ml, 0, reason: 'мінус 100 від 50 має впертись у нуль');
  });

  testWidgets('тренування показує спалене зі знаком мінус', (tester) async {
    await tester.pumpWidget(
      _wrap(
        WorkoutCard(
          workouts: const [
            Workout(
              id: 'w',
              activity: 'run',
              title: 'Біг',
              minutes: 34,
              kcal: 310,
              time: '07:20',
            ),
          ],
          onAdd: (_) {},
          open: true,
          onToggle: () {},
        ),
      ),
    );

    expect(find.text('−310 ккал'), findsOneWidget);
    expect(find.text('1 сесія'), findsOneWidget);
    expect(find.text('34 хв'), findsOneWidget);
  });

  testWidgets('оцінка спаленого рахується за MET і округлюється до пʼяти', (tester) async {
    // 9.8 MET, 78.6 кг, 30 хв -> 404.5, тобто 405.
    expect(burnEstimate(9.8, 30) % 5, 0);
    expect(burnEstimate(9.8, 30), 405);
  });

  testWidgets('вимірювання показує тільки те, що людина міряє', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MeasureCard(
          list: demoMeasures,
          tracked: const ['weightKg'],
          onTrack: (_) {},
          onSave: (_) {},
          onStats: () {},
          open: true,
          onToggle: () {},
        ),
      ),
    );

    expect(find.text('Вага'), findsOneWidget);
    expect(find.text('Біцепс'), findsNothing, reason: 'нестежене поле не має стояти в картці');
    // Prefilled from the last session, not empty.
    expect(find.text('78.6'), findsOneWidget);
    expect(find.text('Нічого не змінилось'), findsOneWidget);
  });
  testWidgets('рядок страви несе грами, БЖВ і час', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MealCard(
          slot: baseSlots['breakfast']!,
          meals: const [
            Meal(
              id: 'x',
              category: FoodCategory.egg,
              title: 'Яєчня',
              time: '08:20',
              slotId: 'breakfast',
              grams: 160,
              kcal: 214,
              protein: 14,
              fat: 16,
              carbs: 2,
            ),
          ],
          open: true,
          onToggle: () {},
          onAdd: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('160 г'), findsOneWidget);
    expect(find.text('14'), findsOneWidget, reason: 'білок');
    expect(find.text('16'), findsOneWidget, reason: 'жири');
    expect(find.text('214'), findsOneWidget, reason: 'калорії');
    expect(find.text('08:20'), findsOneWidget);
  });

  testWidgets('нерозібраний запис не вигадує чисел', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MealCard(
          slot: baseSlots['lunch']!,
          meals: const [
            Meal(
              id: 'y',
              category: FoodCategory.soup,
              title: 'Борщ',
              time: '13:05',
              slotId: 'lunch',
              pending: true,
            ),
          ],
          open: true,
          onToggle: () {},
          onAdd: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Нора рахує…'), findsOneWidget);
    expect(find.text('—'), findsOneWidget, reason: 'нуль калорій був би вигадкою');
  });
}
