import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/day.dart';
import 'package:calvi/data/evening.dart';
import 'package:calvi/data/meal.dart';

/// Вечірнє питання рахується з дня, а не завчене.
///
/// Питати «як минув день» у того, хто все записав, означає навчити людину
/// змахувати сповіщення не читаючи.
void main() {
  const goal = DayGoal(kcal: 2000, protein: 120, fat: 60, carbs: 200, waterMl: 2000);

  Meal dish(String slot) => Meal(
    id: '$slot-1',
    icon: 'plate',
    title: 'Щось',
    time: '12:00',
    slotId: slot,
    grams: 200,
    kcal: 400,
    protein: 20,
    fat: 10,
    carbs: 40,
  );

  DayModel day({List<String> ate = const [], int water = 0}) => DayModel(
    slots: [for (final id in alwaysSlots) baseSlots[id]!],
    meals: [for (final s in ate) dish(s)],
    waterMl: water,
  );

  test('порожній день не розбирається по частинах', () {
    expect(eveningAsk(day: day(), goal: goal), 'День порожній. Що сьогодні їв?');
  });

  test('питає рівно про те, чого бракує', () {
    final ask = eveningAsk(
      day: day(ate: ['breakfast', 'lunch'], water: 2000),
      goal: goal,
    );
    expect(ask, 'Записала вечерю?');
  });

  test('двох карток бракує, питання одне', () {
    final ask = eveningAsk(
      day: day(ate: ['breakfast'], water: 2000),
      goal: goal,
    )!;
    expect(ask.contains('обід'), true);
    expect(ask.contains('вечер'), true);
    expect(ask.split('?').length, 2, reason: 'анкета замість одного питання');
  });

  test('усе записано, крім води', () {
    final ask = eveningAsk(
      day: day(ate: alwaysSlots, water: 500),
      goal: goal,
    );
    expect(ask, 'Скільки води вийшло за день?');
  });

  test('повний день не питають ні про що', () {
    expect(
      eveningAsk(
        day: day(ate: alwaysSlots, water: 2000),
        goal: goal,
      ),
      isNull,
    );
  });
}
