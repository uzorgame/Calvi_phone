import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/remote/api.dart';
import 'package:calvi/data/remote/apple_login.dart';
import 'package:calvi/data/remote/google_login.dart';
import 'package:calvi/data/remote/login_service.dart';

/// Вхід через Apple і доля місцевого щоденника.
///
/// Конвеєр той самий, що і в Google, і тести навмисно перевіряють ті самі
/// гарантії: спершу все доїжджає нагору, перемикання лише з порожньою чергою,
/// відмова людини це не помилка. Якщо котрась із гарантій колись розійдеться
/// між входами, ці тести скажуть, у якому з двох вона зламалась.

/// Apple, який завжди повертає той самий токен. Аркуша на тестах немає.
class _FakeApple extends AppleLogin {
  _FakeApple({this.token = 'apple-token'});

  final String? token;

  @override
  bool get available => true;

  @override
  Future<String?> identityToken() async => token;
}

/// Google, якого в цих тестах ніхто не кличе.
class _MuteGoogle extends GoogleLogin {
  _MuteGoogle() : super(serverClientId: 'web-client');

  @override
  Future<String?> idToken() async => fail('вхід через Apple покликав вікно Google');
}

void main() {
  late CalviDb db;

  setUp(() => db = CalviDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  CalviApi answering(Map<String, dynamic> account, {List<String>? log, List<Object?>? pushed}) =>
      CalviApi(
        base: Uri.parse('https://x.test'),
        client: MockClient((req) async {
          log?.add(req.url.path);
          switch (req.url.path) {
            case '/v1/auth/apple':
              return http.Response(jsonEncode(account), 200);
            case '/v1/auth/google':
              return http.Response('{"error":{"code":"unauthorized"}}', 401);
            case '/v1/devices':
              return http.Response(
                jsonEncode({
                  'user_id': 'device-user',
                  'access_token': 'device-access',
                  'refresh_token': 'device-refresh',
                  'tokens': {'balance': 30},
                }),
                200,
              );
            case '/v1/sync':
              final body = jsonDecode(req.body) as Map<String, dynamic>;
              final changes = (body['changes'] as List<dynamic>);
              pushed?.addAll(changes);
              return http.Response(
                jsonEncode({
                  'cursor': 0,
                  'accepted': [
                    for (var i = 0; i < changes.length; i++)
                      {'id': (changes[i] as Map<String, dynamic>)['id'], 'seq': i + 1},
                  ],
                  'changes': <Object?>[],
                  'has_more': false,
                }),
                200,
              );
            case '/v1/profile':
              return http.Response(jsonEncode({'profile': null}), 200);
          }
          return http.Response('{}', 200);
        }),
      );

  Map<String, dynamic> reply({
    required String userId,
    String outcome = 'returned',
    String? previous,
  }) => {
    'user_id': userId,
    'access_token': 'access',
    'refresh_token': 'refresh',
    'outcome': outcome,
    'previous_user_id': previous,
    'email': 'me@icloud.com',
    'tokens': {'balance': 30},
  };

  LoginService service(CalviApi api, {AppleLogin? apple}) =>
      LoginService(db: db, api: api, google: _MuteGoogle(), apple: apple ?? _FakeApple());

  test('перший вхід зберігає акаунт і йде на маршрут Apple, а не Google', () async {
    final log = <String>[];
    final api = answering(reply(userId: 'u1', outcome: 'created'), log: log);
    final login = service(api);

    expect(await login.signInApple(), LoginResult.done);

    final state = await db.syncDao.state();
    expect(state.userId, 'u1');
    expect(api.token, 'access');
    expect(log, contains('/v1/auth/apple'));
    expect(log, isNot(contains('/v1/auth/google')));
  });

  test('привʼязка не чіпає щоденник на телефоні', () async {
    await db.diaryDao.addMeal(slot: 'lunch', name: 'борщ', kcal: 300);

    final api = answering(reply(userId: 'u1', outcome: 'linked'));
    final login = service(api);

    expect(await login.signInApple(), LoginResult.done);
    expect((await db.select(db.meals).get()).length, 1, reason: 'щоденник зник при привʼязці');
  });

  test('інший акаунт: спершу все доїжджає нагору, і лише тоді перемикаємось', () async {
    await db.diaryDao.addMeal(slot: 'lunch', name: 'борщ', kcal: 300);

    final log = <String>[];
    final pushed = <Object?>[];
    final api = answering(
      reply(userId: 'old-account', previous: 'local-device'),
      log: log,
      pushed: pushed,
    );
    final login = service(api);

    expect(await login.signInApple(), LoginResult.done);

    final firstSync = log.indexOf('/v1/sync');
    final auth = log.indexOf('/v1/auth/apple');
    expect(firstSync, isNot(-1));
    expect(firstSync < auth, isTrue, reason: 'перемкнулись раніше, ніж дотисли записи');
    expect(
      pushed.map((c) => (c as Map<String, dynamic>)['data']).toString(),
      contains('борщ'),
      reason: 'борщ не доїхав на сервер до злиття',
    );
  });

  test('людина закрила аркуш Apple, і нічого не сталось', () async {
    final log = <String>[];
    final api = answering(reply(userId: 'u1'), log: log);
    final login = service(api, apple: _FakeApple(token: null));

    expect(await login.signInApple(), LoginResult.canceled);
    expect(log, isNot(contains('/v1/auth/apple')), reason: 'відмова пішла на сервер');

    final state = await db.syncDao.state();
    expect(state.userId, isNull, reason: 'акаунт зʼявився без входу');
  });

  test('без мережі вхід падає, а записи лишаються на місці', () async {
    await db.diaryDao.addMeal(slot: 'lunch', name: 'борщ', kcal: 300);

    final api = CalviApi(
      base: Uri.parse('https://x.test'),
      client: MockClient((req) async => throw http.ClientException('немає мережі')),
    );
    final login = service(api);

    expect(await login.signInApple(), LoginResult.failed);
    expect((await db.select(db.meals).get()).length, 1, reason: 'збій мережі зʼїв записи');
  });
}
