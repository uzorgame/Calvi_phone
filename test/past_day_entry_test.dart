import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/day_reader.dart';

/// Запис за минулий день лягає в минулий день.
///
/// Екран показує вівторок, людина вписує в його обід страву, і страва
/// зʼявлялась у сьогодні: запис ішов без дня, а без дня сховище бере «зараз».
/// Час запису для минулого дня це його полудень, як і для води чи тренування.
void main() {
  final tuesday = DateTime.now().subtract(const Duration(days: 3));
  final noon = DateTime(tuesday.year, tuesday.month, tuesday.day, 12);

  test('надруковане в картку минулого дня лишається в тому дні', () async {
    final db = CalviDb(NativeDatabase.memory());
    addTearDown(db.close);
    final reader = DayReader(db);

    final id = await reader.addTyped(slotId: 'lunch', text: 'борщ', at: noon);

    final then = await reader.read(tuesday);
    expect(then.meals.map((m) => m.id), contains(id));

    final today = await reader.read(DateTime.now());
    expect(today.meals.map((m) => m.id), isNot(contains(id)), reason: 'втекло в сьогодні');
  });

  test('ручні числа за минулий день теж', () async {
    final db = CalviDb(NativeDatabase.memory());
    addTearDown(db.close);
    final reader = DayReader(db);

    final id = await reader.addManual(
      slotId: 'dinner',
      title: 'Плов',
      kcal: 520,
      grams: 300,
      protein: 20,
      fat: 18,
      carbs: 65,
      at: noon,
    );

    final then = await reader.read(tuesday);
    expect(then.meals.map((m) => m.id), contains(id));
    expect((await reader.read(DateTime.now())).meals.map((m) => m.id), isNot(contains(id)));
  });
}
