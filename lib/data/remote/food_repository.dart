import '../local/database.dart';
import 'api.dart';

/// The food reference, as the app uses it.
///
/// One job: an entry the person typed by hand must not stay at «0 ккал». The
/// entry is written locally first and this fills it in afterwards, so the diary
/// never waits for a network and the numbers arrive when they arrive.
class FoodRepository {
  FoodRepository({required this.api, required this.db});

  final CalviApi api;
  final CalviDb db;

  /// The same two words asked twice in a minute are the same question.
  final Map<String, List<FoodHit>> _seen = {};

  /// What the reference has for a typed name, best match first.
  Future<List<FoodHit>> suggest(String query) async {
    final q = query.trim().toLowerCase();
    if (q.length < 2) return const [];

    final cached = _seen[q];
    if (cached != null) return cached;

    try {
      final hits = await api.searchFoods(q);
      // Only worth remembering if it says something; an offline minute must not
      // be cached as «this dish does not exist».
      if (hits.isNotEmpty) _seen[q] = hits;
      return hits;
    } on ApiFailure {
      return const [];
    }
  }

  /// Looks the entry up and, if the reference knows it, puts real numbers on it.
  ///
  /// Silent by design. The entry is already in the day; failing to improve it is
  /// not something to interrupt a person with.
  Future<bool> enrich(String mealId, String text, {double? grams}) async {
    final hits = await suggest(text);

    /* Неповний рядок довідником не є.
     *
     * Відколи порожнє поле перестало вдавати нуль, у довіднику бувають картки з
     * калоріями і без білка. Підставити таку означало б дописати людині страву
     * з нулем білка тому, що хтось у народній базі не заповнив одну клітинку.
     * Краще лишити запис як був: його ще виправить Нора або сама людина. */
    FoodHit? food;
    for (final f in hits) {
      if (f.complete) {
        food = f;
        break;
      }
    }
    if (food == null) return false;

    final n = food.forGrams(grams);

    await db.diaryDao.applyFood(
      mealId,
      kcal: n.kcal,
      protein: n.protein ?? 0,
      fat: n.fat ?? 0,
      carbs: n.carbs ?? 0,
      icon: food.icon,
      canonicalName: food.canonicalName,
      grams: n.grams,
    );
    return true;
  }

  /// A scanned code, which is exact.
  ///
  /// Повертає те, що справді сталось, а не «є або немає».
  ///
  /// Доти тут стояло `on ApiFailure { return null; }`, і шість різних подій
  /// зливались в одну: коду немає в базі, коду не тієї форми, сесія протухла,
  /// сервер упав, мережа зникла, відповідь не встигла. Усе це виглядало як
  /// «не знаю цього коду», і поки причини були нерозрізненні, полагодити не
  /// можна було жодну: людина бачила той самий екран, а ми не бачили нічого.
  Future<ScanResult> byBarcode(String code) async {
    try {
      final hit = await api.foodByBarcode(code);
      if (hit == null) return const ScanResult(Scanned.unknown);
      return ScanResult(hit.complete ? Scanned.found : Scanned.partial, hit);
    } on ApiFailure catch (e) {
      return ScanResult(switch (e.code) {
        'offline' => Scanned.offline,
        'slow' => Scanned.slow,
        _ => switch (e.status) {
          401 || 403 => Scanned.signedOut,
          400 || 422 => Scanned.notAProduct,
          _ => Scanned.broken,
        },
      });
    }
  }

  /// Етикетка з тієї самої пачки. Не коштує токена і лягає в спільну базу.
  ///
  /// Причина невдачі доїжджає цілою, як і в скані: «не видно таблиці» і «немає
  /// мережі» це різні речі, і виправляють їх по-різному.
  Future<LabelRead> readLabel({required String barcode, required Shot shot}) async {
    try {
      return await api.readLabel(barcode: barcode, shot: shot);
    } on ApiFailure catch (e) {
      return LabelRead(failure: e);
    }
  }
}

/// Чим скінчився скан штрихкоду.
///
/// Сім станів замість одного, і кожен веде людину кудись в інше місце: повну
/// картку записують, неповну дочитують з етикетки, незнайомий код знімають
/// етикеткою, а протухлу сесію не полагодить ні те, ні інше.
enum Scanned {
  /// Товар знайдено, і всі три числа в ньому названі.
  found,

  /// Товар знайдено, але якогось із трьох чисел не знає жодна база.
  partial,

  /// Коду не знає ніхто. Далі етикетка.
  unknown,

  /// Прочиталось щось, що не є штрихкодом товару: QR із посиланням, код складу.
  notAProduct,

  /// Мережі немає.
  offline,

  /// Мережа є, відповіді не дочекались.
  slow,

  /// Сесія недійсна. Жодне сканування не працюватиме, доки не зайти наново.
  signedOut,

  /// Сервер відповів помилкою. Не провина людини і не її камери.
  broken,
}

class ScanResult {
  const ScanResult(this.state, [this.food]);

  final Scanned state;

  /// Те, що знайшлось. Порожньо у всіх станах, крім [Scanned.found] і
  /// [Scanned.partial].
  final FoodHit? food;
}
