import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

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
  Future<SyncAnswer> sync({required int cursor, required List<Map<String, dynamic>> changes}) async {
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
  }) async {
    final body = await _post('/v1/chat', {
      'text': text,
      'slot': slot,
      'day': day,
      'idempotency_key': idempotencyKey,
      /* Знімок їде в тілі запиту і ніде не зберігається: ні тут, ні на сервері.
         База64 замість multipart, бо це один невеликий кадр у складі звичайного
         повідомлення, а не завантаження файлу. */
      if (image != null)
        'image': {'mime': image.mime, 'data': base64Encode(image.bytes)},
    }, wait: _thinking);

    return NoraReply(
      text: body['text'] as String? ?? '',
      balance: body['balance'] as int? ?? 0,
      logged: [
        for (final m in (body['logged'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>())
          LoggedMeal(name: m['name'] as String? ?? '', kcal: m['kcal'] as int? ?? 0),
      ],
      warning: body['warning'] as String?,
    );
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
    }, wait: _thinking);

    final balance = body['balance'] as int? ?? 0;
    final e = body['estimate'] as Map<String, dynamic>?;

    /* Модель подивилась і не побачила страви. Це відповідь, а не поломка: далі
       людина або знімає ще раз, або пише словами. */
    if (e == null) {
      return Analysis(
        balance: balance,
        trouble: body['trouble'] as String? ?? 'Не впізнала страву на цьому знімку',
      );
    }

    return Analysis(
      balance: balance,
      estimate: Estimate(
        name: e['name'] as String? ?? 'Страва',
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
      return food == null ? null : FoodHit.fromJson(food);
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
      return (json['error'] as Map<String, dynamic>)['code'] as String? ?? 'unknown';
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
class NoraReply {
  const NoraReply({
    required this.text,
    required this.balance,
    required this.logged,
    this.warning,
  });

  final String text;

  /// What is left after this message. The server's number, never ours.
  final int balance;
  final List<LoggedMeal> logged;

  /// «Тут важкий алерген», when the allergen check saw one.
  final String? warning;
}

class LoggedMeal {
  const LoggedMeal({required this.name, required this.kcal});

  final String name;
  final int kcal;
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
  });

  factory FoodHit.fromJson(Map<String, dynamic> j) => FoodHit(
    id: j['id'] as String,
    name: j['name'] as String,
    canonicalName: j['canonicalName'] as String? ?? '',
    kcal: (j['kcal'] as num).round(),
    proteinG: (j['proteinG'] as num?)?.toDouble() ?? 0,
    fatG: (j['fatG'] as num?)?.toDouble() ?? 0,
    carbsG: (j['carbsG'] as num?)?.toDouble() ?? 0,
    icon: j['icon'] as String? ?? 'plate',
    portionG: (j['portionG'] as num?)?.toDouble(),
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

  /// The numbers for a real plate. Without a weight the usual portion is used,
  /// and if the reference has none either, 100 g is the honest default.
  ({int kcal, double protein, double fat, double carbs, double grams}) forGrams([
    double? grams,
  ]) {
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
