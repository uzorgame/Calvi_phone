import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/remote/api.dart';
import 'package:calvi/data/remote/google_login.dart';
import 'package:calvi/data/remote/login_service.dart';

/// Вхід через Google і доля місцевого щоденника.
///
/// Найдорожчий випадок такий: людина три дні писала на новому телефоні, а тоді
/// увійшла і виявилось, що в неї є старий акаунт із трьома місяцями. Викинути
/// мовчки не можна ні той, ні той. Порожній місцевий забирається без питань, а
/// непорожній стає питанням до людини, і саме це тут перевіряється.

/// Google, який завжди повертає той самий токен. Вікна на тестах немає.
class _FakeGoogle extends GoogleLogin {
  _FakeGoogle({this.token = 'id-token'}) : super(serverClientId: 'web-client');

  final String? token;
  bool forgotten = false;

  @override
  Future<String?> idToken() async => token;

  @override
  Future<void> forget() async {
    forgotten = true;
  }
}

void main() {
  late CalviDb db;

  setUp(() => db = CalviDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  CalviApi answering(Map<String, dynamic> account) => CalviApi(
    base: Uri.parse('https://x.test'),
    client: MockClient((req) async => http.Response(jsonEncode(account), 200)),
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
    'email': 'me@gmail.com',
    'tokens': {'balance': 30},
  };

  test('перший вхід просто зберігає акаунт', () async {
    final api = answering(reply(userId: 'u1', outcome: 'created'));
    final login = LoginService(db: db, api: api, google: _FakeGoogle());

    expect(await login.signIn(), LoginResult.done);

    final state = await db.syncDao.state();
    expect(state.userId, 'u1');
    expect(api.token, 'access');
  });

  test('привʼязка не чіпає щоденник на телефоні', () async {
    await db.diaryDao.addMeal(slot: 'lunch', name: 'борщ', kcal: 300);

    final api = answering(reply(userId: 'u1', outcome: 'linked'));
    final login = LoginService(db: db, api: api, google: _FakeGoogle());

    expect(await login.signIn(), LoginResult.done);
    expect((await db.select(db.meals).get()).length, 1, reason: 'щоденник зник при привʼязці');
  });

  test('порожній телефон переходить у старий акаунт мовчки', () async {
    final api = answering(reply(userId: 'old-account', previous: 'empty-device'));
    final login = LoginService(db: db, api: api, google: _FakeGoogle());

    expect(await login.signIn(), LoginResult.done, reason: 'спитали про порожній щоденник');

    final state = await db.syncDao.state();
    expect(state.userId, 'old-account');
  });

  test('непорожній телефон і чужий акаунт означають питання, а не втрату', () async {
    await db.diaryDao.addMeal(slot: 'lunch', name: 'борщ', kcal: 300);

    final api = answering(reply(userId: 'old-account', previous: 'local-device'));
    final login = LoginService(db: db, api: api, google: _FakeGoogle());

    expect(await login.signIn(), LoginResult.needsChoice);

    /* Найважливіше: до відповіді людини не змінилось нічого. Ні акаунт, ні
       записи, бо будь-яка з двох дій тут незворотна. */
    expect((await db.select(db.meals).get()).length, 1, reason: 'стерли до питання');
    expect(
      (await db.syncDao.state()).userId,
      isNot('old-account'),
      reason: 'перемкнули до питання',
    );
  });

  test('обрали старий щоденник: місцевий стирається', () async {
    await db.diaryDao.addMeal(slot: 'lunch', name: 'борщ', kcal: 300);

    final api = answering(reply(userId: 'old-account', previous: 'local-device'));
    final login = LoginService(db: db, api: api, google: _FakeGoogle());
    await login.signIn();

    await login.keepAccount();

    expect((await db.select(db.meals).get()), isEmpty);
    expect((await db.syncDao.state()).userId, 'old-account');
  });

  test('обрали місцевий: вхід скасовується, записи на місці', () async {
    await db.diaryDao.addMeal(slot: 'lunch', name: 'борщ', kcal: 300);

    final api = answering(reply(userId: 'old-account', previous: 'local-device'));
    final google = _FakeGoogle();
    final login = LoginService(db: db, api: api, google: google);
    await login.signIn();

    await login.keepLocal();

    expect((await db.select(db.meals).get()).length, 1, reason: 'стерли те, що просили лишити');
    expect((await db.syncDao.state()).userId, isNot('old-account'));
    expect(google.forgotten, isTrue, reason: 'Google памʼятає вхід, якого не сталося');
  });

  test('людина закрила вікно Google, і нічого не сталось', () async {
    final api = answering(reply(userId: 'u1'));
    final login = LoginService(db: db, api: api, google: _FakeGoogle(token: null));

    expect(await login.signIn(), LoginResult.canceled);
    expect((await db.syncDao.state()).userId, isNull);
  });
}
