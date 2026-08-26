import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/remote/api.dart';
import 'package:calvi/data/remote/google_login.dart';
import 'package:calvi/data/remote/login_service.dart';
import 'package:calvi/data/remote/sync_repository.dart';

/// Вхід через Google і доля місцевого щоденника.
///
/// Найдорожчий випадок такий: людина три дні писала на новому телефоні, а тоді
/// увійшла і виявилось, що в неї є старий акаунт із трьома місяцями. Питання з
/// двома поганими відповідями більше немає: записи дотискаються на сервер до
/// перемикання, сервер зливає безіменний акаунт у справжній, а телефон зʼїжджає
/// обʼєднане. Тут перевіряється саме цей порядок, бо в ньому вся гарантія.

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

  /* Сервер із чотирьох маршрутів, і журналом того, що до нього доїхало.
   *
   * Вхід тепер сам ходить у синхронізацію, тому одна відповідь на все не
   * годиться: кожен маршрут відповідає своїм, а тест дивиться в журнал, щоб
   * перевірити не лише результат, а й порядок. */
  CalviApi answering(
    Map<String, dynamic> account, {
    List<String>? log,
    List<Object?>? pushed,
    List<int>? sizes,
  }) =>
      CalviApi(
        base: Uri.parse('https://x.test'),
        client: MockClient((req) async {
          log?.add(req.url.path);
          switch (req.url.path) {
            case '/v1/auth/google':
              return http.Response(jsonEncode(account), 200);
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
              sizes?.add(changes.length);
              /* Справжній сервер приймає щонайбільше 500 змін за запит, і тест
                 поводиться так само: перевищення це відмова, а не мовчазне
                 «якось прийняли». Саме ця відмова одного разу зламала вхід. */
              if (changes.length > 500) {
                return http.Response(
                  jsonEncode({
                    'error': {
                      'code': 'bad_request',
                      'details': [
                        {'path': 'changes', 'message': 'Array must contain at most 500 element(s)'},
                      ],
                    },
                  }),
                  400,
                );
              }
              // Приймаємо все, що прислали: рядок отримує номер і стає чистим.
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

  test('інший акаунт: спершу все доїжджає нагору, і лише тоді перемикаємось', () async {
    await db.diaryDao.addMeal(slot: 'lunch', name: 'борщ', kcal: 300);

    final log = <String>[];
    final pushed = <Object?>[];
    final api = answering(
      reply(userId: 'old-account', previous: 'local-device'),
      log: log,
      pushed: pushed,
    );
    final login = LoginService(db: db, api: api, google: _FakeGoogle());

    expect(await login.signIn(), LoginResult.done);

    /* Порядок і є гарантія: борщ пішов на сервер ДО перемикання акаунта, тому
       серверне злиття мало що зливати. Після перемикання місцева копія чиста
       і зʼїжджає з нуля. */
    final firstSync = log.indexOf('/v1/sync');
    final auth = log.indexOf('/v1/auth/google');
    expect(firstSync, isNot(-1));
    expect(firstSync < auth, isTrue, reason: 'перемкнулись раніше, ніж дотисли записи');
    expect(
      pushed.map((c) => (c as Map<String, dynamic>)['data']).toString(),
      contains('борщ'),
      reason: 'борщ не доїхав на сервер до злиття',
    );

    expect((await db.syncDao.state()).userId, 'old-account');
    expect(
      await db.select(db.meals).get(),
      isEmpty,
      reason: 'після перемикання лишилась копія з чужими номерами черги',
    );
  });

  test('тиждень без входу: усі 250 записів доїжджають до перемикання', () async {
    /* Один обмін відвозить до сотні рядків на таблицю. Тиждень щедрого життя
       без входу це більше за сотню, і вхід зобовʼязаний дотиснути ВСЕ до того,
       як зітре місцеву копію: рядок, що лишився тільки в телефоні, злиття на
       сервері не пережив би. */
    for (var i = 0; i < 250; i++) {
      await db.diaryDao.addMeal(slot: 'lunch', name: 'страва $i', kcal: 100);
    }

    final log = <String>[];
    final pushed = <Object?>[];
    final api = answering(
      reply(userId: 'old-account', previous: 'local-device'),
      log: log,
      pushed: pushed,
    );
    final login = LoginService(db: db, api: api, google: _FakeGoogle());

    expect(await login.signIn(), LoginResult.done);

    final auth = log.indexOf('/v1/auth/google');
    final pushedBeforeAuth = pushed.length;
    expect(
      pushedBeforeAuth,
      greaterThanOrEqualTo(250),
      reason: 'перемкнулись, довізши лише $pushedBeforeAuth рядків із 250',
    );
    expect(log.take(auth).where((p) => p == '/v1/sync').length, greaterThanOrEqualTo(3),
        reason: 'сотня на обмін означає щонайменше три обміни до входу');
    expect((await db.syncDao.state()).userId, 'old-account');
  });

  test('черга понад 500: пуш іде порціями, і вхід все одно проходить', () async {
    /* Вісім таблиць по сто рядків це до восьмисот змін за раз, а сервер приймає
       пʼятсот. Рівно так вхід і зламався одного вівторка: телефон із великою
       чергою отримував відмову на кожен пуш. Тут черга свідомо більша за
       стелю, і перевіряються обидві половини: жоден запит не перевищує 500,
       і все до одного рядка доїжджає до перемикання акаунта. */
    for (var i = 0; i < 520; i++) {
      await db.diaryDao.addMeal(slot: 'lunch', name: 'страва $i', kcal: 100);
    }

    final log = <String>[];
    final pushed = <Object?>[];
    final sizes = <int>[];
    final api = answering(
      reply(userId: 'old-account', previous: 'local-device'),
      log: log,
      pushed: pushed,
      sizes: sizes,
    );
    final login = LoginService(db: db, api: api, google: _FakeGoogle());

    expect(await login.signIn(), LoginResult.done);
    expect(sizes.where((n) => n > 500), isEmpty, reason: 'запит перевищив стелю сервера');

    final auth = log.indexOf('/v1/auth/google');
    final pushedBeforeAuth = pushed.length;
    expect(pushedBeforeAuth >= 520, isTrue, reason: 'не все доїхало до перемикання');
    expect(log.sublist(0, auth).where((p) => p == '/v1/sync').length >= 2, isTrue,
        reason: 'черга такого розміру не могла піти одним запитом');
  });

  test('відмова сервера називає поле, а не лише код', () async {
    /* «bad_request» без поля перетворював кожен такий збій на розслідування з
       логами на сервері. Тепер перша причина з відповіді їде в текст помилки. */
    await db.diaryDao.addMeal(slot: 'lunch', name: 'борщ', kcal: 300);

    final paths = <String>[];
    final api = CalviApi(
      base: Uri.parse('https://x.test'),
      client: MockClient((req) async {
        paths.add('${req.method} ${req.url.path}');
        if (req.url.path == '/v1/devices') {
          return http.Response(
            jsonEncode({
              'user_id': 'device-user',
              'access_token': 'device-access',
              'refresh_token': 'device-refresh',
              'tokens': {'balance': 30},
            }),
            200,
          );
        }
        if (req.url.path == '/v1/sync') {
          /* Заголовок кодування обовʼязковий: справжній сервер його шле, а мок
             без нього кодує кирилицю в latin1 і падає ще до відповіді, що
             читається клієнтом як обрив мережі. */
          return http.Response(
            jsonEncode({
              'error': {
                'code': 'bad_request',
                'message': 'Запит не в тому вигляді',
                'details': [
                  {'path': 'changes.1.id', 'message': 'Invalid uuid'},
                ],
              },
            }),
            400,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('{}', 200);
      }),
    );
    final login = LoginService(db: db, api: api, google: _FakeGoogle());

    expect(await login.signIn(), LoginResult.failed);
    expect(login.error, contains('changes.1.id'), reason: 'поле з відповіді загубилось');
  });

  test('зіпсований ідентифікатор лікується, і вхід проходить', () async {
    /* Рівно той випадок, що поклав вхід у людини: один рядок із не-UUID
       ідентифікатором, сервер відкидає кожен пуш, черга стоїть вічно. Тепер
       такий рядок отримує новий UUID ще до пушу, і дані виживають. */
    await db.diaryDao.addMeal(slot: 'lunch', name: 'борщ', kcal: 300);
    await db.customStatement("update meals set id = 'busted-id' where 1=1");

    final pushed = <Object?>[];
    final api = answering(reply(userId: 'u1', outcome: 'linked'), pushed: pushed);
    final login = LoginService(db: db, api: api, google: _FakeGoogle());

    expect(await login.signIn(), LoginResult.done);

    final ids = pushed.map((c) => (c as Map<String, dynamic>)['id'] as String).toList();
    expect(ids, isNot(contains('busted-id')), reason: 'отрута доїхала до сервера');
    expect(ids.length, 1);
    expect(
      RegExp(r'^[0-9a-f-]{36}$').hasMatch(ids.single),
      isTrue,
      reason: 'рядок пішов без лікування: ${ids.single}',
    );
    expect(
      (await db.select(db.meals).get()).single.name,
      'борщ',
      reason: 'лікування зʼїло сам запис',
    );
  });

  test('без мережі вхід падає, а записи лишаються на місці', () async {
    await db.diaryDao.addMeal(slot: 'lunch', name: 'борщ', kcal: 300);

    final api = CalviApi(
      base: Uri.parse('https://x.test'),
      client: MockClient((req) async => throw Exception('no route to host')),
    );
    final login = LoginService(db: db, api: api, google: _FakeGoogle());

    expect(await login.signIn(), LoginResult.failed);
    expect((await db.select(db.meals).get()).length, 1, reason: 'збій мережі стер щоденник');
    expect((await db.syncDao.state()).userId, isNull, reason: 'перемкнулись без мережі');
  });

  test('людина закрила вікно Google, і нічого не сталось', () async {
    final api = answering(reply(userId: 'u1'));
    final login = LoginService(db: db, api: api, google: _FakeGoogle(token: null));

    expect(await login.signIn(), LoginResult.canceled);
    expect((await db.syncDao.state()).userId, isNull);
  });

  test('замок пропускає по одному і в порядку черги', () async {
    final gate = SyncGate();
    final trace = <String>[];

    Future<void> job(String name) => gate.run(() async {
      trace.add('$name почав');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      trace.add('$name скінчив');
    });

    await Future.wait([job('обмін'), job('вхід')]);

    expect(trace, ['обмін почав', 'обмін скінчив', 'вхід почав', 'вхід скінчив']);
  });
}
