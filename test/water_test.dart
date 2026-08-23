import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/day.dart';
import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/day_reader.dart';

/// Вода і тренування, які переживають закриття застосунку.
///
/// Не переживали. Таблиці в базі були, синхронізація на сервер була, картки на
/// екрані були, і не було рівно одного рядка, який поєднує кнопку зі сховищем:
/// картка води писала число в `Map` у памʼяті екрана. Людина додавала двісті
/// мілілітрів, закривала застосунок, і вода зникала разом із ним.
void main() {
  late CalviDb db;

  setUp(() => db = CalviDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> waterToday() => db.diaryDao.watchWater(calendarDay(todayDate)).first;

  test('додана вода лишається в базі', () async {
    await db.diaryDao.setWaterTotal(200);
    expect(await waterToday(), 200);

    // Так це виглядає з боку екрана: він читає день, а не свою памʼять.
    final day = await DayReader(db).watch(calendarDay(todayDate)).first;
    expect(day.waterMl, 200);
  });

  test('картка каже підсумок, а база рахує різницю', () async {
    await db.diaryDao.setWaterTotal(200);
    await db.diaryDao.setWaterTotal(300);
    await db.diaryDao.setWaterTotal(500);

    expect(await waterToday(), 500);

    /* Три рядки, а не три підсумки. Склянка це подія, у неї є час, і саме з
       подій збирається графік дня. */
    final rows = await db.select(db.waterLogs).get();
    expect(rows.where((r) => r.deletedAt == null), hasLength(3));
    expect(rows.map((r) => r.ml), containsAll([200, 100, 200]));
  });

  test('кожен запис стає в чергу на сервер', () async {
    await db.diaryDao.setWaterTotal(250);
    expect((await db.syncDao.pendingWater()).single.dirty, isTrue);
  });

  test('менше забирає з найсвіжішого, а не з ранкової склянки', () async {
    /* Не «шість годин тому»: о пів на першу ночі це вже вчора, і тест падав
       рівно тоді, коли його ганяли пізно. Ранок будується від сьогоднішньої
       опівночі, і день у нього завжди той самий. */
    final now = DateTime.now();
    final morning = DateTime(now.year, now.month, now.day, 0, 1);
    await db.diaryDao.addWater(ml: 300, at: morning);
    await db.diaryDao.setWaterTotal(500);

    // Передумали: щойно додане знімається.
    await db.diaryDao.setWaterTotal(400);
    expect(await waterToday(), 400);

    final alive = (await db.select(db.waterLogs).get()).where((r) => r.deletedAt == null);
    expect(alive.map((r) => r.ml), containsAll([300, 100]), reason: 'зачепили ранкову склянку');
  });

  test('знята склянка ховається, а не зникає', () async {
    await db.diaryDao.setWaterTotal(200);
    await db.diaryDao.setWaterTotal(0);

    expect(await waterToday(), 0);

    final rows = await db.select(db.waterLogs).get();
    expect(rows, hasLength(1), reason: 'інший пристрій не дізнається про скасування');
    expect(rows.single.deletedAt, isNotNull);
    expect(rows.single.dirty, isTrue);
  });

  test('нижче нуля вода не опускається', () async {
    await db.diaryDao.setWaterTotal(200);
    await db.diaryDao.setWaterTotal(-500);

    expect(await waterToday(), 0);
  });

  test('те саме число другий раз нічого не додає', () async {
    await db.diaryDao.setWaterTotal(300);
    await db.diaryDao.setWaterTotal(300);

    expect(await waterToday(), 300);
    expect(await db.select(db.waterLogs).get(), hasLength(1));
  });

  test('вода вчорашнього дня лишається вчорашньою', () async {
    final yesterday = calendarDay(-1).add(const Duration(hours: 12));
    await db.diaryDao.setWaterTotal(400, at: yesterday);
    await db.diaryDao.setWaterTotal(200);

    expect(await waterToday(), 200);
    expect(await db.diaryDao.watchWater(calendarDay(-1)).first, 400);
  });

  test('екран бачить і додану, і зняту воду', () async {
    /* Найдорожча з усіх помилок тут, і знайшлась вона останньою. Потік дня був
       побудований на стравах: `watchMeals(...).asyncMap(...)`. Воду й тренування
       він дочитував у ту саму мить, тому новий день народжувався тільки тоді,
       коли мінялись страви. Записи в базу йшли справно, а число на картці не
       рухалось ні від «більше», ні від «менше», і виглядало це так, ніби вода
       не зберігається зовсім. */
    final seen = <int>[];
    final sub = DayReader(db).watch(calendarDay(todayDate)).listen((d) => seen.add(d.waterMl));
    await Future<void>.delayed(const Duration(milliseconds: 80));

    await db.diaryDao.setWaterTotal(200);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(seen.last, 200, reason: 'додану воду екран не побачив');

    await db.diaryDao.setWaterTotal(500);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(seen.last, 500);

    await db.diaryDao.setWaterTotal(300);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(seen.last, 300, reason: 'зняту воду екран не побачив');

    await db.diaryDao.setWaterTotal(0);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(seen.last, 0);

    await sub.cancel();
  });

  test('екран бачить записане тренування без жодної страви', () async {
    final seen = <int>[];
    final sub = DayReader(db).watch(calendarDay(todayDate)).listen((d) => seen.add(d.burned));
    await Future<void>.delayed(const Duration(milliseconds: 80));

    await db.diaryDao.addWorkout(kind: 'run', minutes: 30, kcal: 405);
    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(seen.last, 405);
    await sub.cancel();
  });

  test('тренування теж доживає до наступного запуску', () async {
    await db.diaryDao.addWorkout(kind: 'run', minutes: 30, kcal: 405);

    final day = await DayReader(db).watch(calendarDay(todayDate)).first;
    expect(day.workouts, hasLength(1));
    expect(day.workouts.single.activity, 'run');
    expect(day.workouts.single.title, 'Біг', reason: 'назва береться з довідника видів');
    expect(day.workouts.single.minutes, 30);
    expect(day.burned, 405, reason: 'спалене не повернулось у норму дня');

    expect((await db.syncDao.pendingWorkouts()).single.dirty, isTrue);
  });
}
