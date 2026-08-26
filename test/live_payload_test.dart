import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/remote/api.dart';
import 'package:calvi/data/remote/google_login.dart';
import 'package:calvi/data/remote/login_service.dart';

/// Справжня відповідь бойового сервера, прогнана крізь застосунок.
///
/// Решта тестів годують застосунок тим, що написав я, і саме тому вони були
/// зелені того дня, коли вхід не працював жодного разу: мій підроблений сервер
/// повертав рядок рядком, а справжній перетворював його на число. Тест, який
/// вигадує відповідь, перевіряє мою уяву, а не сумісність.
///
/// Тому цей зліпок знято з calvi.uk дослівно, разом із полями, про які застосунок
/// не питав (`food_id`, `note`, `end_day`), і разом із дозою «2.0», яка колись
/// приїжджала числом. Оновлювати його треба тоді, коли міняється формат обміну,
/// і знімати заново з живого сервера, а не правити руками.
const _live =
    '{"cursor":4,"accepted":[],"changes":['
    '{"table":"medications","id":"704d69c0-a803-459d-b14e-25161c832795",'
    '"updated_at":"2026-08-26T19:00:37.255Z","deleted_at":null,"seq":1,'
    '"data":{"name":"Магній","amount":"2.0","note":null,"times":["08:00","20:00"],'
    '"remind":true,"schedule":"","form":"tab","start_day":"2026-08-26","end_day":null}},'
    '{"table":"meals","id":"9d6ee08e-c651-4f58-87ea-44238ffdca37",'
    '"updated_at":"2026-08-26T19:00:37.255Z","deleted_at":null,"seq":2,'
    '"data":{"day":"2026-08-26","at":"2026-08-26T19:00:37.255Z","tz_offset_min":180,'
    '"slot":"lunch","name":"борщ","canonical_name":null,"food_id":null,"icon":"soup",'
    '"grams":300.5,"kcal":250,"protein_g":12.5,"fat_g":8.5,"carbs_g":30.5,'
    '"source":"manual","note":null}},'
    '{"table":"weights","id":"ffb698b7-c531-46a7-9edf-484ba30e00a1",'
    '"updated_at":"2026-08-26T19:00:37.255Z","deleted_at":null,"seq":3,'
    '"data":{"day":"2026-08-26","at":"2026-08-26T19:00:37.255Z","kg":80.5}},'
    '{"table":"medication_takes","id":"4477d3c3-3926-42e4-a2c0-da6199f086f1",'
    '"updated_at":"2026-08-26T19:00:37.255Z","deleted_at":null,"seq":4,'
    '"data":{"medication_id":"704d69c0-a803-459d-b14e-25161c832795","day":"2026-08-26",'
    '"at":"2026-08-26T19:00:37.255Z","planned_time":"08:00"}}],"has_more":false}';

class _FakeGoogle extends GoogleLogin {
  _FakeGoogle() : super(serverClientId: 'web-client');

  @override
  Future<String?> idToken() async => 'id-token';
}

void main() {
  late CalviDb db;

  setUp(() => db = CalviDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  CalviApi serving({required String sync}) => CalviApi(
    base: Uri.parse('https://x.test'),
    client: MockClient((req) async {
      switch (req.url.path) {
        case '/v1/auth/google':
          return http.Response(
            jsonEncode({
              'user_id': 'u1',
              'access_token': 'access',
              'refresh_token': 'refresh',
              'outcome': 'linked',
              'provider': 'google',
              'previous_user_id': null,
              'email': 'me@gmail.com',
              'created_at': '2026-08-20T10:00:00.000Z',
              'tokens': {'balance': 30},
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
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
          return http.Response(sync, 200, headers: {
            'content-type': 'application/json; charset=utf-8',
          });
        case '/v1/profile':
          return http.Response(jsonEncode({'profile': null}), 200);
      }
      return http.Response('{}', 200);
    }),
  );

  test('вхід із дійсною відповіддю бойового сервера доходить до кінця', () async {
    final login = LoginService(db: db, api: serving(sync: _live), google: _FakeGoogle());

    expect(await login.signIn(), LoginResult.done, reason: login.error ?? '');

    /* Акаунт на місці, разом із провайдером: саме його картка малює значком. */
    final state = await db.syncDao.state();
    expect(state.userId, 'u1');
    expect(state.provider, 'google');
    expect(state.email, 'me@gmail.com');

    /* Кожен рядок ліг у базу неушкодженим. Доза окремо: саме вона валила вхід. */
    final med = (await db.select(db.medications).get()).single;
    expect(med.amount, '2.0', reason: 'доза не пережила дороги з сервера');
    expect(med.name, 'Магній');
    expect(med.times, '08:00,20:00', reason: 'години прийому розсипались');
    expect(med.form, 'tab');
    expect(med.startDay, '2026-08-26');

    final meal = (await db.select(db.meals).get()).single;
    expect(meal.name, 'борщ');
    expect(meal.grams, 300.5);
    expect(meal.kcal, 250);
    expect(meal.proteinG, 12.5);
    expect(meal.day, '2026-08-26', reason: 'день приїхав повним часом');

    expect((await db.select(db.weights).get()).single.kg, 80.5);
    expect((await db.select(db.medicationTakes).get()).single.plannedTime, '08:00');

    /* Курсор зрушив: наступний обмін не потягне те саме вдруге. */
    expect(state.cursor, 4);
  });

  test('доза числом більше не валить вхід, навіть якщо сервер знову зіпсується', () async {
    /* Захист другим шаром. Сервер полагоджено, але застосунок живе на телефонах
       довше за будь-яку серверну версію, і зустріти старий сервер він ще може. */
    final broken = _live.replaceAll('"amount":"2.0"', '"amount":2');
    final login = LoginService(db: db, api: serving(sync: broken), google: _FakeGoogle());

    expect(await login.signIn(), LoginResult.done, reason: login.error ?? '');
    expect((await db.select(db.medications).get()).single.amount, '2');
    expect((await db.syncDao.state()).userId, 'u1', reason: 'акаунт втрачено через чужий тип');
  });
}
