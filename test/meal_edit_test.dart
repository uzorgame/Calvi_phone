import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/meal.dart';
import 'package:calvi/data/workout.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/today/meal_card.dart';
import 'package:calvi/screens/today/workout_card.dart';

/* Хто відкриває аркуш запису, а хто ні.
 *
 * Порахований рядок відкривається дотиком: вага і видалення в руках людини.
 * Чернетка «Нора рахує…» не відкривається ніколи: у ній ще нема чисел, які
 * можна було б посунути, і аркуш над нею обіцяв би редагування порожнечі. */

const _counted = Meal(
  id: 'm1',
  icon: 'plate',
  title: 'Борщ з куркою',
  time: '13:05',
  slotId: 'lunch',
  grams: 300,
  kcal: 258,
  protein: 14,
  fat: 12,
  carbs: 22,
);

const _draft = Meal(
  id: 'm2',
  icon: 'plate',
  title: 'мідії 300 грам',
  time: '12:02',
  slotId: 'lunch',
  pending: true,
);

Widget _wrap(List<Meal> meals, {ValueChanged<Meal>? onEdit}) => MaterialApp(
  localizationsDelegates: L.localizationsDelegates,
  supportedLocales: L.supportedLocales,
  locale: const Locale('uk'),
  theme: calviLightTheme,
  home: Scaffold(
    body: ListView(
      children: [
        MealCard(
          slot: baseSlots['lunch']!,
          meals: meals,
          open: true,
          onToggle: () {},
          onAdd: (_) {},
          onManual: (_) {},
          noraCan: true,
          onEdit: onEdit,
        ),
      ],
    ),
  ),
);

void main() {
  testWidgets('дотик по порахованому рядку відкриває його аркуш', (tester) async {
    Meal? opened;
    await tester.pumpWidget(_wrap([_counted], onEdit: (m) => opened = m));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Борщ з куркою'));
    await tester.pumpAndSettle();

    expect(opened?.id, 'm1', reason: 'рядок не відкрився');
  });

  testWidgets('чернетка на дотик не відкривається', (tester) async {
    Meal? opened;
    await tester.pumpWidget(_wrap([_draft], onEdit: (m) => opened = m));
    await tester.pumpAndSettle();

    await tester.tap(find.text('мідії 300 грам'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(opened, isNull, reason: 'аркуш відкрився над рядком без чисел');
  });

  testWidgets('сесія тренування відкривається дотиком, без тривалості ні', (tester) async {
    const run = Workout(
      id: 'w1',
      activity: 'run',
      title: 'Біг',
      minutes: 34,
      kcal: 310,
      time: '07:20',
    );
    const bare = Workout(
      id: 'w2',
      activity: 'gym',
      title: 'Зал',
      minutes: 0,
      kcal: 0,
      time: '19:00',
    );

    Workout? opened;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: Scaffold(
          body: ListView(
            children: [
              WorkoutCard(
                workouts: const [run, bare],
                onAdd: (_) {},
                onEdit: (w) => opened = w,
                open: true,
                onToggle: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Біг'));
    await tester.pumpAndSettle();
    expect(opened?.id, 'w1', reason: 'сесія не відкрилась');

    opened = null;
    await tester.tap(find.text('Зал'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(opened, isNull, reason: 'сесія без тривалості відкрилась, а нема чого крутити');
  });
}
