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
    if (hits.isEmpty) return false;

    final food = hits.first;
    final n = food.forGrams(grams);

    await db.diaryDao.applyFood(
      mealId,
      kcal: n.kcal,
      protein: n.protein,
      fat: n.fat,
      carbs: n.carbs,
      icon: food.icon,
      canonicalName: food.canonicalName,
      grams: n.grams,
    );
    return true;
  }

  /// A scanned code, which is exact. Returns null when nobody has scanned it
  /// before and Open Food Facts has never heard of it either.
  Future<FoodHit?> byBarcode(String code) async {
    try {
      return await api.foodByBarcode(code);
    } on ApiFailure {
      return null;
    }
  }
}
