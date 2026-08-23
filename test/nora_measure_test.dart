import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/daos/diary_dao.dart';
import 'package:calvi/data/local/day_reader.dart';
import 'package:calvi/data/remote/api.dart';
import 'package:calvi/data/remote/chat_repository.dart';

/// Замір, записаний Норою, має бути на телефоні одразу.
///
/// Інструмента не було зовсім, і Нора казала «записала вагу: 77.5 кг», а не
/// мінялось нічого: ні картка на головному, ні крива в аналітиці, ні прогрес до
/// цілі. Обіцянка, за якою нічого не стоїть, гірша за чесне «не вмію».
void main() {
  late CalviDb db;

  setUp(() => db = CalviDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  CalviApi answering(List<Map<String, dynamic>> measures) => CalviApi(
    base: Uri.parse('https://x.test'),
    client: MockClient(
      (req) async => http.Response(
        jsonEncode({'text': 'Записала.', 'balance': 29, 'logged': [], 'measures': measures}),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    ),
  );

  String today() => DiaryDao.dayKey(DateTime.now());

  test('вага лягає в базу і в підсумки', () async {
    final api = answering([
      {
        'id': 'w1',
        'part': 'weight',
        'value': 77.5,
        'day': today(),
        'at': DateTime.now().toUtc().toIso8601String(),
      },
    ]);

    await ChatRepository(db, api).send(text: 'запиши вагу 77.5', slot: 'lunch');

    final row = await db.select(db.weights).getSingle();
    expect(row.kg, 77.5);

    final stats = await DayReader(db).watchStats().first;
    expect(stats.weightOn(0), 77.5);
  });

  test('обхват лягає своєю частиною тіла', () async {
    final api = answering([
      {
        'id': 'm1',
        'part': 'waist',
        'value': 88,
        'day': today(),
        'at': DateTime.now().toUtc().toIso8601String(),
      },
    ]);

    await ChatRepository(db, api).send(text: 'талія 88', slot: 'lunch');

    final row = await db.select(db.measurements).getSingle();
    expect(row.part, 'waist');
    expect(row.cm, 88);

    final stats = await DayReader(db).watchStats().first;
    expect(stats.measures.single['waist'], 88);
  });

  test('кілька замірів за раз лягають усі', () async {
    final at = DateTime.now().toUtc().toIso8601String();
    final api = answering([
      {'id': 'w1', 'part': 'weight', 'value': 77.5, 'day': today(), 'at': at},
      {'id': 'm1', 'part': 'waist', 'value': 88, 'day': today(), 'at': at},
      {'id': 'm2', 'part': 'chest', 'value': 104, 'day': today(), 'at': at},
    ]);

    await ChatRepository(db, api).send(text: 'вага 77.5, талія 88, груди 104', slot: 'lunch');

    expect(await db.select(db.weights).get(), hasLength(1));
    expect(await db.select(db.measurements).get(), hasLength(2));
  });

  test('замір від сервера не їде на сервер назад', () async {
    final api = answering([
      {
        'id': 'w1',
        'part': 'weight',
        'value': 77.5,
        'day': today(),
        'at': DateTime.now().toUtc().toIso8601String(),
      },
    ]);
    await ChatRepository(db, api).send(text: 'вага 77.5', slot: 'lunch');

    expect(await db.syncDao.pendingWeights(), isEmpty);
    expect(await db.syncDao.pendingMeasures(), isEmpty);
  });

  test('повторний замір за той самий день заміняє перший', () async {
    final at = DateTime.now().toUtc().toIso8601String();
    await ChatRepository(
      db,
      answering([
        {'id': 'w1', 'part': 'weight', 'value': 77.5, 'day': today(), 'at': at},
      ]),
    ).send(text: 'вага 77.5', slot: 'lunch');

    await ChatRepository(
      db,
      answering([
        {'id': 'w1', 'part': 'weight', 'value': 77.2, 'day': today(), 'at': at},
      ]),
    ).send(text: 'вага 77.2', slot: 'lunch');

    final rows = await db.select(db.weights).get();
    expect(rows, hasLength(1));
    expect(rows.single.kg, 77.2);
  });
}
