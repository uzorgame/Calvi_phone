import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import '../../l10n/data_lang.dart';

/// The one server this app talks to.
///
/// Everything here is a plain call that either returns a body or throws
/// [ApiFailure]. Deciding what to do about a failure is the repository's job:
/// an offline phone is not an error, it is Tuesday on a train.
class CalviApi {
  CalviApi({required this.base, http.Client? client, this.timeout = const Duration(seconds: 20)})
    : _client = client ?? http.Client();

  final Uri base;

  /* Скільки чекати звичайного запиту. Синхронізація і довідник відповідають за
     частки секунди, тож двадцяти вистачає з запасом. */
  final Duration timeout;

  /* А Норі стільки не вистачає. Вона ходить до моделі, та може викликати
     інструмент і піти на друге коло, і на фото це десяток секунд легко. Раніше
     термін був один на всіх, і застосунок казав «не дістаю мережі» тому, хто
     сидить у прекрасній мережі й чекає на відповідь. */
  static const _thinking = Duration(seconds: 75);

  final http.Client _client;

  /* Каже серверу, що це телефон.
   *
   * Сервер рахує навантаження окремо по клієнтах, і здогадка по user-agent
   * ламається на першому ж оновленні системи. Заголовок дешевший і чесніший:
   * телефон представляється сам. */
  static const _client_ = {'x-calvi-client': 'mobile'};

  /// The access token, once this device has an account. Kept by the caller and
  /// handed back in, so the api holds no session of its own.
  String? token;

  void close() => _client.close();

  /// Asks for an account of this device's own.
  ///
  /// No Google, no email: the app is usable from the first second, and signing
  /// in later attaches a name to this same account rather than making a second.
  Future<DeviceAccount> registerDevice({String? tz, String? device}) async {
    final body = await _post('/v1/devices', {
      if (tz != null) 'tz': tz,
      if (device != null) 'device': device,
    }, auth: false);

    return DeviceAccount(
      userId: body['user_id'] as String,
      accessToken: body['access_token'] as String,
      refreshToken: body['refresh_token'] as String,
      balance: (body['tokens'] as Map<String, dynamic>)['balance'] as int,
    );
  }

  /// One exchange: what this device wrote goes up, what it has not seen comes
  /// down, and the cursor moves.
  Future<SyncAnswer> sync({
    required int cursor,
    required List<Map<String, dynamic>> changes,
  }) async {
    final body = await _post('/v1/sync', {'cursor': cursor, 'changes': changes});

    return SyncAnswer(
      cursor: body['cursor'] as int,
      accepted: {
        for (final a in (body['accepted'] as List<dynamic>).cast<Map<String, dynamic>>())
          a['id'] as String: a['seq'] as int,
      },
      changes: (body['changes'] as List<dynamic>).cast<Map<String, dynamic>>(),
      hasMore: body['has_more'] as bool? ?? false,
    );
  }

  /* Профіль возиться своїм маршрутом, а не в загальному обміні.
   *
   * У щоденнику їздять рядки: свій ідентифікатор, своя черга, мʼяке видалення.
   * Профіль один на людину, і єдине питання про нього це чий запис новіший. */

  /// Профіль, який лежить на сервері. Порожньо, якщо його там ще немає.
  Future<Map<String, dynamic>?> profile() async {
    final body = await _get('/v1/profile');
    return body['profile'] as Map<String, dynamic>?;
  }

  /// Відправляє свій профіль і повертає той, що лишився в базі.
  ///
  /// Це не завжди наш: якщо другий телефон тієї ж людини записав пізніше, сервер
  /// лишить його і віддасть нам, і саме його ми маємо взяти собі.
  Future<Map<String, dynamic>> putProfile(Map<String, dynamic> wire) async {
    final body = await _put('/v1/profile', wire);
    return body['profile'] as Map<String, dynamic>;
  }

  /// One message to Nora. The key never leaves the server, so this is the only
  /// way the app reaches a model at all.
  Future<NoraReply> chat({
    required String text,
    required String slot,
    required String day,
    required String idempotencyKey,
    Shot? image,
    List<Map<String, String>> history = const [],
  }) async {
    final body = await _post('/v1/chat', {
      'text': text,
      'slot': slot,
      'day': day,
      /* Кілька попередніх реплік, щоб розмова була розмовою.
       *
       * Доти кожне повідомлення йшло саме по собі, і Нора не памʼятала навіть
       * власного питання. На «скільки це було?» відповідь «тарілка» приходила
       * без страви, і відповісти на неї не було чим. */
      if (history.isNotEmpty) 'history': history,
      /* Пояс телефона. «О восьмій ранку» це восьма там, де живе людина, а не
         там, де стоїть сервер. */
      'tz_offset_min': DateTime.now().timeZoneOffset.inMinutes,
      'idempotency_key': idempotencyKey,
      'lang': dataLang,
      /* Знімок їде в тілі запиту і ніде не зберігається: ні тут, ні на сервері.
         База64 замість multipart, бо це один невеликий кадр у складі звичайного
         повідомлення, а не завантаження файлу. */
      if (image != null) 'image': {'mime': image.mime, 'data': base64Encode(image.bytes)},
    }, wait: _thinking);

    return NoraReply.fromWire(body, slot: slot, day: day);
  }

  /// Вхід через Google: міняє токен від Google на наш обліковий запис.
  ///
  /// Заголовок із нашим токеном іде разом із запитом, якщо він уже є. Це не
  /// формальність: саме за ним сервер розуміє, що людина приходить зі своїм
  /// пристроєм, і підписує наявний щоденник її іменем, а не заводить другий
  /// порожній.
  Future<GoogleAccount> signInWithGoogle({required String idToken, String? device}) =>
      _signIn('/v1/auth/google', idToken: idToken, device: device);

  /// Той самий обмін, що і з Google: токен від Apple на наш акаунт.
  Future<GoogleAccount> signInWithApple({required String idToken, String? device}) =>
      _signIn('/v1/auth/apple', idToken: idToken, device: device);

  Future<GoogleAccount> _signIn(String path, {required String idToken, String? device}) async {
    final body = await _post(path, {
      'id_token': idToken,
      'tz': DateTime.now().timeZoneName,
      if (device != null) 'device': device,
    }, auth: token != null);

    return GoogleAccount(
      userId: body['user_id'] as String,
      accessToken: body['access_token'] as String,
      refreshToken: body['refresh_token'] as String,
      outcome: body['outcome'] as String? ?? 'returned',
      provider: body['provider'] as String?,
      previousUserId: body['previous_user_id'] as String?,
      email: body['email'] as String?,
      joinedAt: DateTime.tryParse(body['created_at'] as String? ?? '')?.toLocal(),
      balance: ((body['tokens'] as Map<String, dynamic>?)?['balance'] as num?)?.round() ?? 0,
    );
  }

  /// Вага, обрана дотиком у відповідь на питання Нори.
  ///
  /// Окремий маршрут, а не повідомлення в чат, і саме тому він не коштує токена:
  /// страву вже розібрано попереднім повідомленням, її числа лежать на сервері,
  /// і лишилось помножити їх на названу вагу. Чекати на модель тут теж немає за
  /// чим, тому відповідь приходить одразу.
  Future<NoraReply> weigh({
    required int grams,
    required String slot,
    required String day,
    String? askId,
  }) async {
    final body = await _post('/v1/chat/weigh', {
      'grams': grams,
      /* Яке питання закриває ця вага. Порожньо лишається для старих відповідей,
         які ще висять у розмові з часів, коли питання було одне. */
      if (askId != null) 'ask_id': askId,
      'lang': dataLang,
    });
    return NoraReply.fromWire(body, slot: slot, day: day);
  }

  /// Розбір знімка без запису: числа повертаються, щоденник не чіпається.
  ///
  /// Окремий маршрут, а не режим чату. Тут інша дія: чат розмовляє і пише, а це
  /// дивиться і мовчить. Числа показуються поруч зі знімком, поки його ще видно
  /// очима, і в день лягають тільки якщо людина скаже.
  Future<Analysis> analyze({required Shot shot, required String idempotencyKey}) async {
    final body = await _post('/v1/analyze', {
      'idempotency_key': idempotencyKey,
      'image': {'mime': shot.mime, 'data': base64Encode(shot.bytes)},
      'lang': dataLang,
    }, wait: _thinking);

    final balance = body['balance'] as int? ?? 0;
    final e = body['estimate'] as Map<String, dynamic>?;

    /* Модель подивилась і не побачила страви. Це відповідь, а не поломка: далі
       людина або знімає ще раз, або пише словами. */
    if (e == null) {
      return Analysis(
        balance: balance,
        trouble: body['trouble'] as String? ?? dataL.photoNotRecognized,
      );
    }

    return Analysis(
      balance: balance,
      estimate: Estimate(
        name: e['name'] as String? ?? dataL.photoDish,
        canonicalName: e['canonical_name'] as String?,
        grams: (e['grams'] as num?)?.toDouble(),
        kcal: (e['kcal'] as num?)?.round() ?? 0,
        protein: (e['protein_g'] as num?)?.toDouble() ?? 0,
        fat: (e['fat_g'] as num?)?.toDouble() ?? 0,
        carbs: (e['carbs_g'] as num?)?.toDouble() ?? 0,
        icon: e['icon'] as String? ?? 'plate',
        note: e['note'] as String? ?? '',
      ),
    );
  }

  /// What the reference knows about a typed name.
  ///
  /// Costs no tokens: this is a lookup in our own table, and it is what keeps a
  /// hand written entry from staying at zero calories. An empty list means the
  /// dish is not in the reference, not that anything failed.
  Future<List<FoodHit>> searchFoods(String query) async {
    final q = query.trim();
    if (q.length < 2) return const [];

    final body = await _get('/v1/foods/search?q=${Uri.encodeQueryComponent(q)}');
    return [
      for (final f in (body['foods'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>())
        FoodHit.fromJson(f),
    ];
  }

  /// A scanned barcode. Exact, so it is the one answer we never estimate.
  Future<FoodHit?> foodByBarcode(String code) async {
    try {
      final body = await _get('/v1/foods/barcode/$code');
      final food = body['food'] as Map<String, dynamic>?;
      return food == null
          ? null
          : FoodHit.fromJson(food, warns: body['warns'] as Map<String, dynamic>?);
    } on ApiFailure catch (e) {
      // Nobody has ever scanned it: an answer, not a breakage.
      if (e.status == 404) return null;
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final http.Response res;
    try {
      res = await _client
          .get(
            base.resolve(path),
            headers: {..._client_, if (token != null) 'authorization': 'Bearer $token'},
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const ApiFailure.slow();
    } catch (e) {
      throw const ApiFailure.offline();
    }

    if (res.statusCode >= 400) {
      throw ApiFailure(code: _errorCode(res.body), status: res.statusCode);
    }

    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
    Duration? wait,
  }) async {
    final headers = {
      ..._client_,
      'content-type': 'application/json',
      if (auth && token != null) 'authorization': 'Bearer $token',
    };

    final http.Response res;
    try {
      res = await _client
          .post(base.resolve(path), headers: headers, body: jsonEncode(body))
          .timeout(wait ?? timeout);
    } on TimeoutException {
      /* Терпіння скінчилось, але мережа була. Це різні біди й різні поради:
         «зачекай» проти «увімкни інтернет». */
      throw const ApiFailure.slow();
    } catch (e) {
      // No signal, no server, no route: all the same thing to the caller.
      throw const ApiFailure.offline();
    }

    if (res.statusCode >= 400) {
      final code = _errorCode(res.body);
      throw ApiFailure(code: code, status: res.statusCode);
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// «Видалити дані» з налаштувань: сервер гасить щоденник на всіх пристроях.
  ///
  /// Відповідь несе список погашеного по таблицях: людині показується, що
  /// зроблено, а не бадьоре «готово».
  Future<Map<String, dynamic>> eraseDiary() async {
    final http.Response res;
    try {
      res = await _client
          .delete(
            base.resolve('/v1/diary'),
            headers: {..._client_, if (token != null) 'authorization': 'Bearer $token'},
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const ApiFailure.slow();
    } catch (e) {
      throw const ApiFailure.offline();
    }

    if (res.statusCode >= 400) {
      throw ApiFailure(code: _errorCode(res.body), status: res.statusCode);
    }

    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _put(String path, Map<String, dynamic> body) async {
    final http.Response res;
    try {
      res = await _client
          .put(
            base.resolve(path),
            headers: {
              ..._client_,
              'content-type': 'application/json',
              if (token != null) 'authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const ApiFailure.slow();
    } catch (e) {
      throw const ApiFailure.offline();
    }

    if (res.statusCode >= 400) {
      throw ApiFailure(code: _errorCode(res.body), status: res.statusCode);
    }

    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  String _errorCode(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final error = json['error'] as Map<String, dynamic>;
      final code = error['code'] as String? ?? 'unknown';
      /* Перша деталь перевірки їде разом із кодом: «bad_request» сам по собі
         не каже, яке поле не сподобалось серверу, і кожен такий випадок
         перетворювався на розслідування з логами на сервері. */
      final details = error['details'];
      if (details is List && details.isNotEmpty) {
        final first = details.first;
        if (first is Map<String, dynamic>) {
          final where = first['path'] ?? '';
          final what = first['message'] ?? '';
          return '$code: $where $what';
        }
      }
      return code;
    } catch (_) {
      return 'unknown';
    }
  }
}

/// The account this device got, and the way back into it.
class DeviceAccount {
  const DeviceAccount({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.balance,
  });

  final String userId;
  final String accessToken;
  final String refreshToken;
  final int balance;
}

/// What one sync came back with.
class SyncAnswer {
  const SyncAnswer({
    required this.cursor,
    required this.accepted,
    required this.changes,
    required this.hasMore,
  });

  final int cursor;

  /// Which pushed rows the server took, and the number each was given. A row
  /// that is missing here lost to a newer version and stays dirty.
  final Map<String, int> accepted;
  final List<Map<String, dynamic>> changes;
  final bool hasMore;
}

/// What Nora said, and what it changed.
/// Запис, який Нора переписала на прохання людини.
class FixedMeal {
  const FixedMeal({
    required this.id,
    required this.name,
    required this.kcal,
    this.grams,
    this.protein = 0,
    this.fat = 0,
    this.carbs = 0,
  });

  final String id;
  final String name;
  final int kcal;
  final double? grams;
  final double protein;
  final double fat;
  final double carbs;
}

/// Обліковий запис після входу через Google.
class GoogleAccount {
  const GoogleAccount({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.outcome,
    required this.balance,
    this.provider,
    this.previousUserId,
    this.email,
    this.joinedAt,
  });

  final String userId;
  final String accessToken;
  final String refreshToken;

  /* Що саме сталося: `created` це перший вхід у житті, `linked` це підпис
     наявного щоденника, `returned` це повернення до старого. Застосунок питає
     про місцеві записи тільки в третьому випадку. */
  final String outcome;

  /// Ким увійшли: 'google' або 'apple'. Порожньо на старому сервері.
  final String? provider;

  /// Запис, який був на цьому пристрої до входу, якщо він інший.
  final String? previousUserId;
  final String? email;

  /// Коли зʼявився обліковий запис, а не коли людина увійшла.
  final DateTime? joinedAt;
  final int balance;

  /// Чи щоденник на телефоні належить не тому, хто щойно увійшов.
  bool get switched => previousUserId != null && previousUserId != userId;
}

/// Запис, який переїхав в іншу картку або на інший день. Числа не міняються.
class MovedMeal {
  const MovedMeal({
    required this.id,
    required this.name,
    required this.slot,
    required this.day,
    this.at,
  });

  final String id;
  final String name;
  final String slot;
  final String day;

  /// Час після переносу: він переїжджає разом із карткою, щоб не стояти не там.
  final String? at;
}

/// Питання про вагу однієї страви: номер у черзі, назва і три ваги на вибір.
///
/// Номер потрібен, щоб відповідь закрила рівно своє питання. Коли страв кілька,
/// людина відповідає в тому порядку, у якому їй зручно, і без номера друга
/// відповідь лягла б на першу страву.
class WeightAsk {
  const WeightAsk({required this.id, required this.name, required this.weights});

  final String id;

  /// Слова людини про цю страву. З них складається саме питання.
  final String name;

  final List<int> weights;
}

class NoraReply {
  const NoraReply({
    required this.text,
    required this.balance,
    required this.logged,
    this.deleted = const [],
    this.fixed = const [],
    this.moved = const [],
    this.asks = const [],
    this.water,
    this.workouts = const [],
    this.remembered = const [],
    this.measures = const [],
    this.warning,
  });

  /// Відповідь сервера, як вона приходить проводом.
  ///
  /// Один розбір на два маршрути: звичайне повідомлення і вагу, обрану дотиком.
  /// Другий повертає ту саму форму, і дублювати сюди її розбір означало б рано чи
  /// пізно розійтись у полях.
  factory NoraReply.fromWire(
    Map<String, dynamic> body, {
    required String slot,
    required String day,
  }) {
    return NoraReply(
      text: body['text'] as String? ?? '',
      balance: body['balance'] as int? ?? 0,
      logged: [
        for (final m in (body['logged'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>())
          LoggedMeal(
            id: m['id'] as String? ?? '',
            slot: m['slot'] as String? ?? slot,
            day: m['day'] as String? ?? day,
            at: m['at'] as String?,
            name: m['name'] as String? ?? '',
            kcal: (m['kcal'] as num?)?.round() ?? 0,
            grams: (m['grams'] as num?)?.toDouble(),
            protein: (m['protein_g'] as num?)?.toDouble() ?? 0,
            fat: (m['fat_g'] as num?)?.toDouble() ?? 0,
            carbs: (m['carbs_g'] as num?)?.toDouble() ?? 0,
            icon: m['icon'] as String? ?? 'plate',
            fromReference: m['from'] == 'reference',
          ),
      ],
      deleted: [
        for (final m in (body['deleted'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>())
          m['id'] as String? ?? '',
      ]..removeWhere((id) => id.isEmpty),
      fixed: [
        for (final m in (body['fixed'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>())
          FixedMeal(
            id: m['id'] as String? ?? '',
            name: m['name'] as String? ?? '',
            kcal: (m['kcal'] as num?)?.round() ?? 0,
            grams: (m['grams'] as num?)?.toDouble(),
            protein: (m['protein_g'] as num?)?.toDouble() ?? 0,
            fat: (m['fat_g'] as num?)?.toDouble() ?? 0,
            carbs: (m['carbs_g'] as num?)?.toDouble() ?? 0,
          ),
      ]..removeWhere((m) => m.id.isEmpty),
      moved: [
        for (final m in (body['moved'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>())
          MovedMeal(
            id: m['id'] as String? ?? '',
            name: m['name'] as String? ?? '',
            slot: m['slot'] as String? ?? slot,
            day: m['day'] as String? ?? day,
            at: m['at'] as String?,
          ),
      ]..removeWhere((m) => m.id.isEmpty),
      asks: [
        for (final a in (body['asks'] as List<dynamic>? ?? []))
          if (a is Map<String, dynamic>)
            WeightAsk(
              id: a['id'] as String? ?? '',
              name: a['name'] as String? ?? '',
              weights: [for (final g in (a['weights'] as List<dynamic>? ?? [])) (g as num).round()],
            ),
      ]..removeWhere((a) => a.id.isEmpty || a.weights.isEmpty),
      water: body['water'] == null
          ? null
          : PouredWater(
              id: (body['water'] as Map<String, dynamic>)['id'] as String? ?? '',
              ml: ((body['water'] as Map<String, dynamic>)['ml'] as num?)?.round() ?? 0,
              totalMl: ((body['water'] as Map<String, dynamic>)['total_ml'] as num?)?.round() ?? 0,
            ),
      workouts: [
        for (final w in (body['workouts'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>())
          DoneWorkout(
            id: w['id'] as String? ?? '',
            kind: w['kind'] as String? ?? 'gym',
            minutes: (w['minutes'] as num?)?.round() ?? 0,
            kcal: (w['kcal'] as num?)?.round() ?? 0,
          ),
      ],
      measures: [
        for (final m in (body['measures'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>())
          TakenMeasure(
            id: m['id'] as String? ?? '',
            part: m['part'] as String? ?? '',
            value: (m['value'] as num?)?.toDouble() ?? 0,
            day: m['day'] as String? ?? day,
            at: m['at'] as String?,
          ),
      ],
      remembered: [
        for (final n in (body['remembered'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>())
          Remembered(
            id: n['id'] as String? ?? '',
            text: n['text'] as String? ?? '',
            pinned: n['pinned'] as bool? ?? false,
            name: n['name'] as String?,
          ),
      ],
      warning: body['warning'] as String?,
    );
  }

  final String text;

  /// What is left after this message. The server's number, never ours.
  final int balance;
  final List<LoggedMeal> logged;

  /// Ідентифікатори прибраного. Застосунок гасить ці рядки в себе одразу, тим
  /// самим ключем, і не чекає синхронізації, щоб показати результат прохання.
  final List<String> deleted;

  /* Виправлені записи. Приходять цілим рядком, а не самою різницею: половина
     полів лишила б запис неузгодженим із тим, що лежить на сервері. */
  final List<FixedMeal> fixed;

  /* Перенесені записи: та сама страва, інша картка або інший день.
   *
   * Окремо від виправлених, бо застосунок робить із ними різне: виправлений
   * рядок перемальовується на місці, а перенесений має зникнути з однієї картки
   * і зʼявитись в іншій. */
  final List<MovedMeal> moved;

  /* Питання про вагу, по одному на кожну страву, вагу якої не назвали і не
     памʼятають.
   *
   * Список, а не один набір ваг. Одне повідомлення легко несе три страви, і
   * доти в застосунок доїжджало питання лише про останню: набір був один, і
   * кожна наступна страва його перезаписувала. */
  final List<WeightAsk> asks;

  /// Випите, якщо Нора записала воду. Окремо від їжі, бо в застосунку це своя
  /// картка і своя норма.
  final PouredWater? water;

  /// Записані тренування. Своя картка і свій внесок у баланс дня.
  final List<DoneWorkout> workouts;

  /// Записані заміри: вага і обхвати. Картка вимірювань бере їх звідси, і бере
  /// одразу, бо «записала вагу 77.5» без зміни числа на екрані це обіцянка, за
  /// якою нічого не стоїть.
  final List<TakenMeasure> measures;

  /// Що Нора запамʼятала цим повідомленням. Сторінка памʼяті бере це звідси, і
  /// бере одразу: обіцянка «запамʼятаю» має бути видною тут же, а не після
  /// наступної синхронізації.
  final List<Remembered> remembered;

  /// «Тут важкий алерген», when the allergen check saw one.
  final String? warning;
}

/// Один запис памʼяті, який щойно зробила Нора.
class Remembered {
  const Remembered({required this.id, required this.text, required this.pinned, this.name});

  final String id;
  final String text;
  final bool pinned;

  /// Імʼя, якщо його щойно дізнались.
  final String? name;
}

/// Записане тренування: вид, тривалість і скільки з нього вийшло калорій.
class DoneWorkout {
  const DoneWorkout({
    required this.id,
    required this.kind,
    required this.minutes,
    required this.kcal,
  });

  final String id;
  final String kind;
  final int minutes;
  final int kcal;
}

/// Записана вода: скільки цього разу і скільки стало за день.
class PouredWater {
  const PouredWater({required this.id, required this.ml, required this.totalMl});

  /// Ідентифікатор рядка, який сервер уже створив. Без нього телефон записав би
  /// ту саму склянку вдруге, і в день лягла б подвійна вода.
  final String id;

  final int ml;
  final int totalMl;
}

/// Страва, яку Нора щойно записала, з усіма її числами.
///
/// Числа тут не для звірки, а для показу: у чаті вони малюються смужкою під
/// відповіддю. «Записала яєчню» без жодної цифри це половина відповіді.
class LoggedMeal {
  const LoggedMeal({
    required this.id,
    required this.slot,
    required this.day,
    this.at,
    required this.name,
    required this.kcal,
    this.grams,
    this.protein = 0,
    this.fat = 0,
    this.carbs = 0,
    this.icon = 'plate',
    this.fromReference = false,
  });

  /// Ідентифікатор рядка, який сервер уже створив. За ним та сама страва
  /// лягає на телефон одразу і не подвоюється, коли приїде синхронізацією.
  final String id;

  /* Куди і на коли це лягло на сервері.
   *
   * Телефон бере саме ці три, а не картку, відкриту на екрані. Людина казала
   * «запиши на сніданок», сервер чесно писав у сніданок, а на телефоні страва
   * зʼявлялась в обіді, бо обід був відкритий: відповідь і щоденник розходились
   * на очах. */
  final String slot;
  final String day;

  /// Момент часу, як його вирішив сервер. Порожньо для старих відповідей.
  final String? at;

  final String name;
  final int kcal;
  final double? grams;
  final double protein;
  final double fat;
  final double carbs;
  final String icon;

  /// Числа з довідника, а не оцінка на око. Різниця варта того, щоб її сказати.
  final bool fromReference;
}

/// Знімок дорогою до моделі. Живе рівно стільки, скільки триває запит.
class Shot {
  const Shot({required this.mime, required this.bytes});

  final String mime;
  final Uint8List bytes;
}

/// Відповідь на розбір знімка: або оцінка, або чесне «не впізнала».
class Analysis {
  const Analysis({required this.balance, this.estimate, this.trouble});

  final int balance;
  final Estimate? estimate;

  /// Чому оцінки немає, якщо її немає. Людською мовою, від самої Нори.
  final String? trouble;
}

/// Що Нора побачила на знімку. Оцінка, а не запис.
class Estimate {
  const Estimate({
    required this.name,
    required this.kcal,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.icon,
    required this.note,
    this.canonicalName,
    this.grams,
  });

  final String name;
  final String? canonicalName;

  /// Вага порції, як її оцінила модель. Порожньо, якщо оцінити не вийшло.
  final double? grams;

  final int kcal;
  final double protein;
  final double fat;
  final double carbs;
  final String icon;

  /// Одне речення від Нори про те, наскільки вона впевнена.
  final String note;
}

/// One row of the food reference, per 100 g.
///
/// [portionG] is what one usual serving weighs, so «борщ» typed without a weight
/// is still a number and not a question back to the person.
class FoodHit {
  const FoodHit({
    required this.id,
    required this.name,
    required this.kcal,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
    required this.icon,
    required this.canonicalName,
    this.portionG,
    this.ingredients,
    this.warnContains = const [],
    this.warnTraces = const [],
    this.warnSevere = false,
  });

  factory FoodHit.fromJson(Map<String, dynamic> j, {Map<String, dynamic>? warns}) => FoodHit(
    id: j['id'] as String,
    name: j['name'] as String,
    canonicalName: j['canonicalName'] as String? ?? '',
    kcal: (j['kcal'] as num).round(),
    proteinG: (j['proteinG'] as num?)?.toDouble() ?? 0,
    fatG: (j['fatG'] as num?)?.toDouble() ?? 0,
    carbsG: (j['carbsG'] as num?)?.toDouble() ?? 0,
    icon: j['icon'] as String? ?? 'plate',
    portionG: (j['portionG'] as num?)?.toDouble(),
    ingredients: j['ingredients'] as String?,
    warnContains: [...?(warns?['contains'] as List?)?.cast<String>()],
    warnTraces: [...?(warns?['traces'] as List?)?.cast<String>()],
    warnSevere: warns?['severe'] == true,
  );

  final String id;
  final String name;
  final String canonicalName;
  final int kcal;
  final double proteinG;
  final double fatG;
  final double carbsG;
  final String icon;
  final double? portionG;

  /// Склад з упаковки, дослівно і мовою джерела. Порожньо, коли база його
  /// не знає.
  final String? ingredients;

  /* Перетин алергенів продукту з алергіями цієї людини, кодами. Звіряє
     сервер: у нього і список алергій, і алергени продукту вже поруч. */
  final List<String> warnContains;
  final List<String> warnTraces;
  final bool warnSevere;

  /// The numbers for a real plate. Without a weight the usual portion is used,
  /// and if the reference has none either, 100 g is the honest default.
  ({int kcal, double protein, double fat, double carbs, double grams}) forGrams([double? grams]) {
    final g = grams ?? portionG ?? 100;
    final k = g / 100;
    return (
      kcal: (kcal * k).round(),
      protein: proteinG * k,
      fat: fatG * k,
      carbs: carbsG * k,
      grams: g,
    );
  }
}

class ApiFailure implements Exception {
  const ApiFailure({required this.code, required this.status});
  const ApiFailure.offline() : code = 'offline', status = 0;

  /// Мережа була, відповіді не дочекались.
  const ApiFailure.slow() : code = 'slow', status = 0;

  final String code;
  final int status;

  /// Worth trying again later: the network, or the server having a bad minute.
  bool get temporary => status == 0 || status >= 500 || code == 'rate_limited';

  @override
  String toString() => 'ApiFailure($code, $status)';
}

/// Один замір, який щойно записала Нора: вага або обхват.
class TakenMeasure {
  const TakenMeasure({
    required this.id,
    required this.part,
    required this.value,
    required this.day,
    this.at,
  });

  final String id;

  /// «weight» або ключ частини тіла: «waist», «chest» і так далі.
  final String part;

  /// Кілограми для ваги, сантиметри для обхватів.
  final double value;

  final String day;
  final String? at;
}
