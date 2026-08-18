import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:calvi/data/local/database.dart' hide Allergy;
import 'package:calvi/data/local/profile_store.dart';
import 'package:calvi/data/remote/api.dart';
import 'package:calvi/data/remote/sync_repository.dart';
import 'package:calvi/data/settings.dart';

/// Профіль між телефоном і сервером.
///
/// Він їздить окремо від щоденника, іншим маршрутом і за іншим правилом, тому й
/// перевіряється окремо. Правило одне: перемагає новіший запис, і байдуже, чий
/// він. Другий телефон тієї ж людини має таке саме право змінити ціль.
void main() {
  late CalviDb db;

  setUp(() => db = CalviDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// Сервер, який памʼятає один профіль і каже, про що його питали.
  ({CalviApi api, List<String> calls, Map<String, dynamic>? Function() stored}) fake({
    Map<String, dynamic>? has,
    bool refuse = false,
  }) {
    var kept = has;
    final calls = <String>[];

    final client = MockClient((req) async {
      final path = req.url.path;

      if (path.endsWith('/devices')) {
        return http.Response(
          jsonEncode({
            'user_id': 'u-1',
            'access_token': 'access-1',
            'refresh_token': 'refresh-1',
            'tokens': {'balance': 30, 'next_grant_at': DateTime.now().toIso8601String()},
          }),
          201,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }

      if (path.endsWith('/sync')) {
        return http.Response(
          jsonEncode({'cursor': 0, 'accepted': [], 'changes': [], 'has_more': false}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }

      calls.add('${req.method} $path');

      if (req.method == 'GET') {
        return http.Response(
          jsonEncode({'profile': kept}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }

      // Відмова означає, що на сервері новіший запис. Тоді він і повертається.
      if (!refuse) kept = jsonDecode(req.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({'profile': kept, 'accepted': !refuse}),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    return (
      api: CalviApi(base: Uri.parse('https://api.calvi.test'), client: client),
      calls: calls,
      stored: () => kept,
    );
  }

  Map<String, dynamic> wire({
    required String at,
    int waterMl = 2000,
    String theme = 'light',
    double target = 74,
  }) => {
    'updated_at': at,
    'sex': 'm',
    'birth_year': 1998,
    'height_cm': 180,
    'goal_start_kg': 80.0,
    'target_kg': target,
    'direction': 'lose',
    'pace': 0.5,
    'activity': 1.55,
    'kcal_manual': null,
    'protein_g': 130,
    'fat_g': 60,
    'carbs_g': 300,
    'water_ml': waterMl,
    'theme': theme,
  };

  test('свій профіль їде на сервер', () async {
    await ProfileStore(db).save(emptySettings().copyWith(waterMl: 2600, targetKg: 71));

    final server = fake();
    await SyncRepository(db, server.api).run();

    expect(server.calls, ['PUT /v1/profile']);
    expect(server.stored()!['water_ml'], 2600);
    expect(server.stored()!['target_kg'], 71);

    final row = await db.select(db.profile).getSingle();
    expect(row.dirty, isFalse, reason: 'прийнятий профіль поїде вдруге на кожному синку');
  });

  test('чистий профіль не відправляється, а тільки звіряється', () async {
    await ProfileStore(db).save(emptySettings());
    await SyncRepository(db, fake().api).run();

    final server = fake(has: wire(at: DateTime(2020).toUtc().toIso8601String()));
    await SyncRepository(db, server.api).run();

    expect(server.calls, ['GET /v1/profile']);
  });

  test('новіший профіль із сервера перемагає свій', () async {
    await ProfileStore(db).save(emptySettings().copyWith(waterMl: 2000, theme: AppTheme.light));
    await SyncRepository(db, fake().api).run();

    final later = DateTime.now().add(const Duration(hours: 1)).toUtc().toIso8601String();
    final server = fake(has: wire(at: later, waterMl: 3100, theme: 'dark'));
    await SyncRepository(db, server.api).run();

    final back = await ProfileStore(db).load();
    expect(back!.waterMl, 3100);
    expect(back.theme, AppTheme.dark);
  });

  test('старіший профіль із сервера не чіпає свій', () async {
    await ProfileStore(db).save(emptySettings().copyWith(waterMl: 2400));
    await SyncRepository(db, fake().api).run();

    final older = DateTime(2020).toUtc().toIso8601String();
    await SyncRepository(db, fake(has: wire(at: older, waterMl: 1000)).api).run();

    expect((await ProfileStore(db).load())!.waterMl, 2400);
  });

  test('новий телефон забирає профіль і не питає «Старт» удруге', () async {
    expect(await ProfileStore(db).load(), isNull, reason: 'починаємо з чистого пристрою');

    final server = fake(has: wire(at: DateTime.now().toUtc().toIso8601String(), waterMl: 2800));
    await SyncRepository(db, server.api).run();

    final back = await ProfileStore(db).load();
    expect(back, isNotNull, reason: 'профіль із сервера не забрано, людину спитають усе спочатку');
    expect(back!.waterMl, 2800);
  });

  test('відмова сервера повертає нам його версію, а не лишає суперечку', () async {
    await ProfileStore(db).save(emptySettings().copyWith(waterMl: 2000));

    final later = DateTime.now().add(const Duration(hours: 1)).toUtc().toIso8601String();
    final server = fake(has: wire(at: later, waterMl: 3300), refuse: true);
    await SyncRepository(db, server.api).run();

    final back = await ProfileStore(db).load();
    expect(back!.waterMl, 3300);
  });

  test('щоденник доїжджає, навіть коли профіль не доїхав', () async {
    await ProfileStore(db).save(emptySettings());
    final id = await db.diaryDao.addMeal(slot: 'lunch', name: 'Борщ', kcal: 210);

    // Сервер, у якого профіль зламаний, а обмін записами цілий.
    final client = MockClient((req) async {
      if (req.url.path.endsWith('/devices')) {
        return http.Response(
          jsonEncode({
            'user_id': 'u-1',
            'access_token': 'a',
            'refresh_token': 'r',
            'tokens': {'balance': 30, 'next_grant_at': DateTime.now().toIso8601String()},
          }),
          201,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
      if (req.url.path.endsWith('/profile')) return http.Response('нема', 500);

      // Приймає все, що надіслали: вагу «Старт» пише разом із профілем, і
      // сервер, який мовчки губить її, зробив би цей тест про інше.
      final sent = (jsonDecode(req.body) as Map<String, dynamic>)['changes'] as List<dynamic>;
      return http.Response(
        jsonEncode({
          'cursor': 4,
          'accepted': [
            for (final c in sent.cast<Map<String, dynamic>>()) {'id': c['id'], 'seq': 1},
          ],
          'changes': [],
          'has_more': false,
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final result = await SyncRepository(
      db,
      CalviApi(base: Uri.parse('https://api.calvi.test'), client: client),
    ).run();

    expect(result.pushed, 2, reason: 'страва і вага');
    expect(await db.syncDao.pendingMeals(), isEmpty);
    expect(await db.syncDao.pendingWeights(), isEmpty);
    expect(id, isNotEmpty);
    expect((await db.select(db.profile).getSingle()).dirty, isTrue, reason: 'поїде наступного разу');
  });
}
