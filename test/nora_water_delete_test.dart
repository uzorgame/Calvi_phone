import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/day_reader.dart';
import 'package:calvi/data/remote/api.dart';
import 'package:calvi/data/remote/chat_repository.dart';

/// Вода в свою картку, прибране зникає одразу.
///
/// Обидві дії сервер робить у себе, і телефон має показати результат тієї ж
/// миті, а не за сорок пʼять секунд, коли доїде синхронізація. Особливо
/// видалення: людина сказала «прибери», побачила «прибрала» і порожньої картки
/// не побачила, тому скаже ще раз, і друге прохання прибере вже не те.
void main() {
  late CalviDb db;

  setUp(() => db = CalviDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  CalviApi answering(Map<String, dynamic> body) => CalviApi(
    base: Uri.parse('https://x.test'),
    client: MockClient(
      (req) async => http.Response(
        jsonEncode({'text': '', 'balance': 29, 'logged': [], ...body}),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    ),
  );

  test('вода лягає в картку води, а не стравою', () async {
    final api = answering({
      'water': {'id': 'w-1', 'ml': 500, 'total_ml': 500},
    });

    await ChatRepository(db, api).send(text: 'випив 500 мл води', slot: 'lunch');

    final day = await DayReader(db).read(DateTime.now());
    expect(day.waterMl, 500, reason: 'вода не дійшла до картки');
    expect(day.meals, isEmpty, reason: 'вода лягла стравою в обід');
  });

  test('склянка від сервера не їде на сервер назад', () async {
    final api = answering({
      'water': {'id': 'w-1', 'ml': 500, 'total_ml': 500},
    });
    await ChatRepository(db, api).send(text: '500 мл води', slot: 'lunch');

    expect(await db.syncDao.pendingWater(), isEmpty);
  });

  test('прибране гасне одразу', () async {
    final id = await db.diaryDao.addMeal(slot: 'breakfast', name: 'омлет', kcal: 200);

    final api = answering({
      'deleted': [
        {'id': id, 'name': 'омлет', 'slot': 'breakfast'},
      ],
    });
    await ChatRepository(db, api).send(text: 'видали омлет', slot: 'breakfast');

    final day = await DayReader(db).read(DateTime.now());
    expect(day.meals, isEmpty, reason: 'страва лишилась у дні');
    expect(day.totals.kcal, 0);
  });

  test('прибране лишається позначкою, а не зникає з бази', () async {
    /* Синхронізація вміє привозити зміни, а не помічати відсутність: без
       позначки запис повернувся б наступним же обміном. */
    final id = await db.diaryDao.addMeal(slot: 'breakfast', name: 'омлет', kcal: 200);

    final api = answering({
      'deleted': [
        {'id': id, 'name': 'омлет', 'slot': 'breakfast'},
      ],
    });
    await ChatRepository(db, api).send(text: 'видали омлет', slot: 'breakfast');

    final row = await db.select(db.meals).getSingle();
    expect(row.deletedAt, isNotNull);
    expect(row.dirty, false, reason: 'сервер уже знає про це видалення');
  });

  test('видалення кількох прибирає саме їх', () async {
    final a = await db.diaryDao.addMeal(slot: 'breakfast', name: 'омлет', kcal: 200);
    final b = await db.diaryDao.addMeal(slot: 'breakfast', name: 'тост', kcal: 150);
    await db.diaryDao.addMeal(slot: 'breakfast', name: 'кава', kcal: 30);

    final api = answering({
      'deleted': [
        {'id': a, 'name': 'омлет', 'slot': 'breakfast'},
        {'id': b, 'name': 'тост', 'slot': 'breakfast'},
      ],
    });
    await ChatRepository(db, api).send(text: 'видали перші два', slot: 'breakfast');

    final day = await DayReader(db).read(DateTime.now());
    expect(day.meals, hasLength(1));
    expect(day.meals.single.title, 'кава');
  });

  test('мінус води зменшує день, а не пише відʼємний рядок', () async {
    await db.diaryDao.addWater(ml: 500);

    final api = answering({
      'water': {'id': '', 'ml': -200, 'total_ml': 300},
    });
    await ChatRepository(db, api).send(text: 'я помилився, було на 200 менше', slot: 'lunch');

    final day = await DayReader(db).read(DateTime.now());
    expect(day.waterMl, 300);

    final rows = await db.select(db.waterLogs).get();
    expect(rows.every((r) => r.ml > 0), true, reason: 'зʼявився відʼємний запис');
  });

  test('відповідь без води й видалень нічого не чіпає', () async {
    await db.diaryDao.addMeal(slot: 'breakfast', name: 'омлет', kcal: 200);
    await db.diaryDao.addWater(ml: 250);

    await ChatRepository(db, answering({})).send(text: 'привіт', slot: 'lunch');

    final day = await DayReader(db).read(DateTime.now());
    expect(day.meals, hasLength(1));
    expect(day.waterMl, 250);
  });
  test('тренування від Нори лягає в свою картку', () async {
    final api = answering({
      'workouts': [
        {'id': 'w-run', 'kind': 'run', 'minutes': 30, 'kcal': 320},
      ],
    });

    await ChatRepository(db, api).send(text: 'запиши тренування 30 хвилин біг', slot: 'lunch');

    final day = await DayReader(db).read(DateTime.now());
    expect(day.workouts, hasLength(1));
    expect(day.workouts.single.minutes, 30);
    expect(day.workouts.single.kcal, 320);
    expect(day.meals, isEmpty, reason: 'тренування лягло стравою');
  });

  test('тренування від сервера не їде на сервер назад', () async {
    final api = answering({
      'workouts': [
        {'id': 'w-run', 'kind': 'run', 'minutes': 30, 'kcal': 320},
      ],
    });
    await ChatRepository(db, api).send(text: '30 хвилин біг', slot: 'lunch');

    expect(await db.syncDao.pendingWorkouts(), isEmpty);
  });
}
