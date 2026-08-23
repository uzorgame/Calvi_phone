import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/day_reader.dart';

/// Записана вага має доходити до всіх, хто її показує.
///
/// Людина ставила 76 кг, а картка на головному лишалась на 75.0, і в аналітиці
/// теж. Вага живе у двох місцях: рядком зважування в базі, з якого будується
/// крива, і поточним числом у налаштуваннях, яке малює картка. Записувалось
/// тільки перше.
void main() {
  late CalviDb db;

  setUp(() => db = CalviDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('зважування доходить до підсумків одразу, без жодної страви', () async {
    /* Тут була друга половина тієї ж біди: потік підсумків перебудовувався
       тільки від змін у стравах. Вага лягала в базу і чекала, поки людина
       запише якусь їжу. */
    final stats = DayReader(db).watchStats();
    final second = stats.skip(1).first;

    await db.diaryDao.setWeight(kg: 76);

    final after = await second.timeout(const Duration(seconds: 5));
    expect(after.weightOn(0), 76);
  });

  test('замір сантиметром теж рухає підсумки', () async {
    final stats = DayReader(db).watchStats();
    final second = stats.skip(1).first;

    await db.diaryDao.setMeasure(part: 'waist', cm: 88);

    final after = await second.timeout(const Duration(seconds: 5));
    expect(after.measures, hasLength(1));
  });

  test('вода теж рухає підсумки', () async {
    final stats = DayReader(db).watchStats();
    final second = stats.skip(1).first;

    await db.diaryDao.addWater(ml: 250);

    final after = await second.timeout(const Duration(seconds: 5));
    expect(after.waterOn(0), 250);
  });
}
