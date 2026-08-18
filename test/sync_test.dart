import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/remote/api.dart';
import 'package:calvi/data/remote/sync_repository.dart';

/// The phone's half of syncing, against a server that is a function.
///
/// A fake rather than a live API on purpose: what is being checked here is what
/// the phone does with the answers, including the answers a real server gives
/// rarely and at the worst moment.
void main() {
  late CalviDb db;

  setUp(() => db = CalviDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// A server that records what it was asked and answers as told.
  ({CalviApi api, List<Map<String, dynamic>> pushes}) fake({
    required Map<String, dynamic> Function(Map<String, dynamic> body) onSync,
    bool offline = false,
  }) {
    final pushes = <Map<String, dynamic>>[];

    final client = MockClient((req) async {
      if (offline) throw const SocketFailure();

      if (req.url.path.endsWith('/devices')) {
        return jsonResponse({
            'user_id': 'u-1',
            'access_token': 'access-1',
            'refresh_token': 'refresh-1',
            'tokens': {'balance': 30, 'next_grant_at': DateTime.now().toIso8601String()},
          }, 201);
      }

      final body = jsonDecode(req.body) as Map<String, dynamic>;
      pushes.add(body);
      return jsonResponse(onSync(body), 200);
    });

    return (api: CalviApi(base: Uri.parse('https://api.calvi.test'), client: client), pushes: pushes);
  }

  Map<String, dynamic> answer({
    Map<String, int> accepted = const {},
    List<Map<String, dynamic>> changes = const [],
    int cursor = 0,
    bool hasMore = false,
  }) => {
    'cursor': cursor,
    'accepted': [for (final e in accepted.entries) {'id': e.key, 'seq': e.value}],
    'changes': changes,
    'has_more': hasMore,
  };

  test('перший синк заводить акаунт і віддає записи', () async {
    final id = await db.diaryDao.addMeal(slot: 'lunch', name: 'Борщ', kcal: 210);

    final server = fake(onSync: (body) => answer(accepted: {id: 1}, cursor: 1));
    final result = await SyncRepository(db, server.api).run();

    expect(result.ok, isTrue);
    expect(result.pushed, 1);

    final state = await db.syncDao.state();
    expect(state.userId, 'u-1', reason: 'акаунт не збережено, наступний запуск заведе новий');
    expect(state.accessToken, 'access-1');
    expect(state.cursor, 1, reason: 'курсор не зрушив, наступний синк забере те саме');

    expect(await db.syncDao.pendingMeals(), isEmpty, reason: 'прийнятий запис лишився брудним');

    final sent = server.pushes.single['changes'] as List<dynamic>;
    expect((sent.single as Map<String, dynamic>)['table'], 'meals');
    expect(((sent.single as Map<String, dynamic>)['data'] as Map)['name'], 'Борщ');
  });

  test('записи з сервера лягають у базу і не їдуть назад', () async {
    final server = fake(
      onSync: (body) => answer(
        cursor: 7,
        changes: [
          {
            'table': 'meals',
            'id': 'from-server',
            'updated_at': DateTime(2026, 8, 17, 12).toUtc().toIso8601String(),
            'deleted_at': null,
            'seq': 7,
            'data': {
              'day': '2026-08-17',
              'at': DateTime(2026, 8, 17, 12).toUtc().toIso8601String(),
              'slot': 'lunch',
              'name': 'З іншого телефона',
              'kcal': 300,
              'icon': 'soup',
            },
          },
        ],
      ),
    );

    final result = await SyncRepository(db, server.api).run();
    expect(result.pulled, 1);

    final day = await db.diaryDao.mealsOn(DateTime(2026, 8, 17));
    expect(day.single.name, 'З іншого телефона');
    expect(
      day.single.dirty,
      isFalse,
      reason: 'прийшле з сервера позначено на відправку, два телефони говоритимуть вічно',
    );
    expect(day.single.seq, 7);
  });

  test('відхилений запис лишається в черзі', () async {
    await db.diaryDao.addMeal(slot: 'lunch', name: 'Мій', kcal: 100);

    // The server held a newer version: nothing accepted.
    final server = fake(onSync: (body) => answer(cursor: 0));
    final result = await SyncRepository(db, server.api).run();

    expect(result.pushed, 0);
    expect(
      (await db.syncDao.pendingMeals()).length,
      1,
      reason: 'відхилений запис зник із черги і більше ніколи не поїде',
    );
  });

  test('без мережі нічого не втрачається', () async {
    await db.diaryDao.addMeal(slot: 'dinner', name: 'Вечеря', kcal: 400);

    final server = fake(onSync: (_) => answer(), offline: true);
    final result = await SyncRepository(db, server.api).run();

    expect(result.ok, isFalse);
    expect(result.retry, isTrue, reason: 'офлайн має бути тимчасовим, а не поразкою');
    expect((await db.syncDao.pendingMeals()).length, 1);
    expect((await db.syncDao.state()).cursor, 0);
  });

  test('другий запуск не заводить другий акаунт', () async {
    var devices = 0;
    final client = MockClient((req) async {
      if (req.url.path.endsWith('/devices')) {
        devices++;
        return jsonResponse({
            'user_id': 'u-1',
            'access_token': 'access-1',
            'refresh_token': 'refresh-1',
            'tokens': {'balance': 30},
          }, 201);
      }
      return jsonResponse(answer(), 200);
    });

    final api = CalviApi(base: Uri.parse('https://api.calvi.test'), client: client);
    await SyncRepository(db, api).run();
    await SyncRepository(db, api).run();

    expect(devices, 1, reason: 'кожен синк заводить новий акаунт, історія розсипається');
  });
}

/// Bytes with a charset, the way a server answers. A Response made from a
/// String is latin-1, and «З іншого телефона» does not fit in latin-1.
http.Response jsonResponse(Map<String, dynamic> body, int status) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

/// What `http` throws when there is no way out of the phone.
class SocketFailure implements Exception {
  const SocketFailure();
}
