import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/meal.dart';
import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/day_reader.dart';

/// Каркас дня стоїть нерухомо, а перекус зʼявляється разом із записом.
void main() {
  late CalviDb db;

  setUp(() => db = CalviDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('запис в обід не піднімає обід над порожнім сніданком', () async {
    /* «Додай в обід шашлик» перебудовувало день: обід ставав першим, бо
       сортування йшло за часом першого запису, а сніданок був порожній. Картка,
       яку щойно шукали очима внизу, опинялась зверху, і кожен наступний запис
       доводилось шукати заново. */
    await db.diaryDao.addMeal(slot: 'lunch', name: 'шашлик', kcal: 500);

    final day = await DayReader(db).read(DateTime.now());
    final order = [for (final s in day.ordered) s.id];

    expect(order.take(3).toList(), ['breakfast', 'lunch', 'dinner']);
  });

  test('порожній день стоїть у своєму порядку', () async {
    final day = await DayReader(db).read(DateTime.now());
    expect([for (final s in day.ordered) s.id], ['breakfast', 'lunch', 'dinner']);
  });

  test('перекус зʼявляється, щойно в нього щось записали', () async {
    /* Нора писала бутерброд у перекус, рядок лягав у базу, а картки під нього не
       було: запис ставав невидимим. */
    final before = await DayReader(db).read(DateTime.now());
    expect(before.slots.any((s) => s.id == 'snack'), false, reason: 'порожній перекус показали');

    await db.diaryDao.addMeal(slot: 'snack', name: 'бутерброд', kcal: 250);

    final after = await DayReader(db).read(DateTime.now());
    expect(after.slots.any((s) => s.id == 'snack'), true, reason: 'перекус не зʼявився');
    expect(after.inSlot('snack'), hasLength(1));
  });

  test('перекус стає між сніданком і обідом за своїм часом', () async {
    final ten = DateTime.now().copyWith(hour: 10, minute: 30);
    await db.diaryDao.addMeal(slot: 'snack', name: 'банан', kcal: 90, at: ten);

    final day = await DayReader(db).read(DateTime.now());
    final order = [for (final s in day.ordered) s.id];

    expect(order, ['breakfast', 'snack', 'lunch', 'dinner']);
  });

  test('пізній перекус стає під вечерею', () async {
    final late = DateTime.now().copyWith(hour: 21, minute: 30);
    await db.diaryDao.addMeal(slot: 'snack', name: 'печиво', kcal: 200, at: late);

    final day = await DayReader(db).read(DateTime.now());
    final order = [for (final s in day.ordered) s.id];

    expect(order, ['breakfast', 'lunch', 'dinner', 'snack']);
  });

  test('картки дня беруться з довідника, а не вигадуються', () {
    for (final id in alwaysSlots) {
      expect(baseSlots[id], isNotNull);
    }
  });
}
