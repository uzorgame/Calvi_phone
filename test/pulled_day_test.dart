import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/day.dart';
import 'package:calvi/data/local/database.dart' hide Allergy;
import 'package:calvi/data/local/day_reader.dart';
import 'package:calvi/data/remote/sync_mapping.dart';

/// Записане Норою має зʼявитись у дні, а не зникнути.
///
/// Найдорожча помилка з усіх: сервер віддавав календарний день повним часом,
/// `2026-08-18T00:00:00.000Z`, а телефон питає свій щоденник за ключем
/// `2026-08-18`. Кожна страва, записана Норою, лягала під ключем, якого жоден
/// екран не шукає. Людина бачила «Записала два яйця на сніданок» і порожній
/// сніданок під ним.
void main() {
  late CalviDb db;

  setUp(() => db = CalviDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  final today =
      '${calendarDay(todayDate).year.toString().padLeft(4, '0')}-'
      '${calendarDay(todayDate).month.toString().padLeft(2, '0')}-'
      '${calendarDay(todayDate).day.toString().padLeft(2, '0')}';

  Map<String, dynamic> mealChange(Object day) => {
    'table': 'meals',
    'id': 'from-server-1',
    'updated_at': DateTime.now().toUtc().toIso8601String(),
    'deleted_at': null,
    'seq': 1,
    'data': {
      'day': day,
      'at': DateTime.now().toUtc().toIso8601String(),
      'tz_offset_min': 180,
      'slot': 'breakfast',
      'name': 'Два яйця',
      'canonical_name': 'яйце',
      'icon': 'egg',
      'grams': 110,
      'kcal': 143,
      'protein_g': 12.6,
      'fat_g': 9.6,
      'carbs_g': 0.8,
      'source': 'chat',
    },
  };

  test('день із сервера обрізається до самої дати', () {
    final row = mealFromChange(mealChange('2026-08-18T00:00:00.000Z'));
    expect(row.day.value, '2026-08-18');
  });

  test('звичайна дата лишається собою', () {
    final row = mealFromChange(mealChange('2026-08-18'));
    expect(row.day.value, '2026-08-18');
  });

  test('записане Норою видно на екрані дня', () async {
    /* Саме той шлях, що ламався: рядок приїхав із сервера повним часом, і день
       має його знайти. */
    await db
        .into(db.meals)
        .insertOnConflictUpdate(mealFromChange(mealChange('${today}T00:00:00.000Z')));

    final day = await DayReader(db).read(calendarDay(todayDate));
    expect(day.meals, hasLength(1), reason: 'страва не потрапила в сьогоднішній день');
    expect(day.meals.single.title, 'Два яйця');
    expect(day.totals.kcal, 143);
  });

  test('зіпсовані ключі, що вже лежать на телефоні, лікуються', () async {
    /* Сервер уже віддає день правильно, але в людей на телефонах лишились
       рядки з повним часом. Без цього кроку вони так і не побачать свій
       сніданок: оновлення застосунку саме по собі їх не полагодить. */
    await db.customStatement(
      "insert into meals (id, updated_at, deleted_at, dirty, seq, day, at, tz_offset_min, "
      "slot, name, canonical_name, icon, grams, kcal, protein_g, fat_g, carbs_g, source, note) "
      "values ('old-1', 0, null, 0, 1, '${today}T00:00:00.000Z', 0, 180, 'breakfast', "
      "'Яєчня', 'яєчня', 'egg', 110, 216, 14, 17, 1, 'chat', null)",
    );

    // Те, що робить міграція третьої версії.
    await db.customStatement('update meals set day = substr(day, 1, 10) where length(day) > 10');

    final rows = await db.select(db.meals).get();
    expect(rows.single.day, today);
  });

  test('вода і вага з сервера теж лягають у свій день', () async {
    final at = DateTime.now().toUtc().toIso8601String();

    await db
        .into(db.waterLogs)
        .insertOnConflictUpdate(
          waterFromChange({
            'id': 'w1',
            'updated_at': at,
            'deleted_at': null,
            'seq': 2,
            'data': {'day': '${today}T00:00:00.000Z', 'at': at, 'ml': 300},
          }),
        );
    await db
        .into(db.weights)
        .insertOnConflictUpdate(
          weightFromChange({
            'id': 'g1',
            'updated_at': at,
            'deleted_at': null,
            'seq': 3,
            'data': {'day': '${today}T00:00:00.000Z', 'at': at, 'kg': 75.0},
          }),
        );

    expect(await db.diaryDao.waterOn(calendarDay(todayDate)), 300);

    final rows = await db.select(db.weights).get();
    expect(rows.single.day, today);
  });
}
