import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/remote/api.dart';
import 'package:calvi/data/remote/food_repository.dart';

/// An entry typed by hand must not stay at «0 ккал».
///
/// The row is written before the network is touched, so these tests care about
/// two things: that the entry survives a server that is not there, and that when
/// the reference does answer, the numbers land on the row that was already in
/// the day.
void main() {
  late CalviDb db;

  setUp(() => db = CalviDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// The reference, as a function. Counts calls, because asking the server the
  /// same two words twice is the thing the cache exists to prevent.
  ({CalviApi api, List<String> asked}) fake({
    List<Map<String, dynamic>> foods = const [],
    bool offline = false,
  }) {
    final asked = <String>[];

    final client = MockClient((req) async {
      if (offline) throw const SocketFailure();
      asked.add(req.url.queryParameters['q'] ?? req.url.path);
      return http.Response.bytes(
        utf8.encode(jsonEncode({'foods': foods})),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    return (
      api: CalviApi(base: Uri.parse('https://api.calvi.test'), client: client)..token = 'a',
      asked: asked,
    );
  }

  Map<String, dynamic> borsch({double? portion = 300}) => {
    'id': 'f-1',
    'source': 'canonical',
    'canonicalName': 'борщ',
    'name': 'Борщ',
    'kcal': 58,
    'proteinG': 2.1,
    'fatG': 2.8,
    'carbsG': 6.2,
    'icon': 'soup',
    'portionG': portion,
  };

  test('запис отримує калорії з довідника', () async {
    final id = await db.diaryDao.addMeal(slot: 'lunch', name: 'борщ', kcal: 0);
    final server = fake(foods: [borsch()]);

    final done = await FoodRepository(api: server.api, db: db).enrich(id, 'борщ');
    expect(done, isTrue);

    final row = await (db.select(db.meals)..where((m) => m.id.equals(id))).getSingle();

    // 58 ккал на 100 г, порція 300 г.
    expect(row.kcal, 174, reason: 'калорії не перерахувались на порцію');
    expect(row.grams, 300);
    expect(row.proteinG, closeTo(6.3, 0.01));
    expect(row.icon, 'soup', reason: 'картинка лишилась тарілкою');
    expect(row.canonicalName, 'борщ');
    expect(row.name, 'борщ', reason: 'назву людини переписали');
    expect(row.dirty, isTrue, reason: 'виправлений рядок не поїде на сервер');
  });

  test('без порції рахується сто грамів', () async {
    final id = await db.diaryDao.addMeal(slot: 'lunch', name: 'борщ', kcal: 0);
    final server = fake(foods: [borsch(portion: null)]);

    await FoodRepository(api: server.api, db: db).enrich(id, 'борщ');
    final row = await (db.select(db.meals)..where((m) => m.id.equals(id))).getSingle();

    expect(row.kcal, 58);
    expect(row.grams, 100);
  });

  test('невідома страва лишається як записали', () async {
    final id = await db.diaryDao.addMeal(slot: 'dinner', name: 'щось своє', kcal: 0);
    final server = fake();

    expect(await FoodRepository(api: server.api, db: db).enrich(id, 'щось своє'), isFalse);

    final row = await (db.select(db.meals)..where((m) => m.id.equals(id))).getSingle();
    expect(row.name, 'щось своє');
    expect(row.kcal, 0);
  });

  test('без мережі запис не втрачається і не падає', () async {
    final id = await db.diaryDao.addMeal(slot: 'dinner', name: 'борщ', kcal: 0);
    final server = fake(offline: true);

    expect(await FoodRepository(api: server.api, db: db).enrich(id, 'борщ'), isFalse);
    expect(
      await (db.select(db.meals)..where((m) => m.id.equals(id))).getSingle(),
      isNotNull,
    );
  });

  test('те саме слово не питають у сервера двічі', () async {
    final server = fake(foods: [borsch()]);
    final foods = FoodRepository(api: server.api, db: db);

    await foods.suggest('борщ');
    await foods.suggest('Борщ ');

    expect(server.asked.length, 1, reason: 'кеш не спрацював');
  });

  test('короткий запит не турбує сервер', () async {
    final server = fake(foods: [borsch()]);

    expect(await FoodRepository(api: server.api, db: db).suggest('б'), isEmpty);
    expect(server.asked, isEmpty);
  });
}

/// What `http` throws when there is no way out of the phone.
class SocketFailure implements Exception {
  const SocketFailure();
}
