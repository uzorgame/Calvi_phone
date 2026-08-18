import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';
import '../tables/meals.dart';
import '../tables/water_logs.dart';
import '../tables/weights.dart';
import '../tables/workouts.dart';

part 'diary_dao.g.dart';

const _uuid = Uuid();

/// Reading and writing a day.
///
/// Every write here does the same three things and does them in one place: it
/// stamps `updatedAt`, marks the row dirty, and leaves the id alone. A screen
/// that sets those by hand is a screen that will one day forget to, and a row
/// that forgets to be dirty is a record that silently never reaches the server.
@DriftAccessor(tables: [Meals, WaterLogs, Weights, Workouts])
class DiaryDao extends DatabaseAccessor<CalviDb> with _$DiaryDaoMixin {
  DiaryDao(super.db);

  /// The day as the local calendar sees it, which is how every row is filed.
  static String dayKey(DateTime at) =>
      '${at.year.toString().padLeft(4, '0')}-'
      '${at.month.toString().padLeft(2, '0')}-'
      '${at.day.toString().padLeft(2, '0')}';

  /// Everything eaten on a day, oldest first, deleted rows left out.
  Stream<List<MealRow>> watchMeals(DateTime day) {
    final key = dayKey(day);
    return (select(meals)
          ..where((m) => m.day.equals(key) & m.deletedAt.isNull())
          ..orderBy([(m) => OrderingTerm(expression: m.at)]))
        .watch();
  }

  /* Разове читання це справжній запит, а не `first` на потоці.
   *
   * `first` підписується на потік запиту, бере одне значення і відписується, і
   * поки на нього ніхто більше не дивиться, drift той запит закриває. Читання,
   * яке почалось за мить до того, як екран пішов з дня, отримувало «Bad state:
   * No element» замість числа. */
  Future<List<MealRow>> mealsOn(DateTime day) {
    final key = dayKey(day);
    return (select(meals)
          ..where((m) => m.day.equals(key) & m.deletedAt.isNull())
          ..orderBy([(m) => OrderingTerm(expression: m.at)]))
        .get();
  }

  /// Adds an entry and returns the id it was given, so the caller can undo it.
  Future<String> addMeal({
    required String slot,
    required String name,
    required int kcal,
    DateTime? at,
    double? grams,
    double protein = 0,
    double fat = 0,
    double carbs = 0,
    String icon = 'plate',
    String source = 'manual',
    String? canonicalName,
    String? note,
  }) async {
    final when = at ?? DateTime.now();
    final id = _uuid.v4();

    await into(meals).insert(
      MealsCompanion.insert(
        id: id,
        updatedAt: when,
        day: dayKey(when),
        at: when,
        tzOffsetMin: Value(when.timeZoneOffset.inMinutes),
        slot: slot,
        name: name,
        kcal: kcal,
        grams: Value(grams),
        proteinG: Value(protein),
        fatG: Value(fat),
        carbsG: Value(carbs),
        icon: Value(icon),
        source: Value(source),
        canonicalName: Value(canonicalName),
        note: Value(note),
      ),
    );
    return id;
  }

  /// Puts real numbers on an entry that was written without them.
  ///
  /// The typed entry is saved the moment the person presses send, because a
  /// diary that waits for a network is a diary that loses what you told it. The
  /// reference answers a moment later, and this is where its answer lands. The
  /// name is left alone: the person's own wording is theirs, and only the
  /// canonical name underneath is ours.
  Future<void> applyFood(
    String id, {
    required int kcal,
    required double protein,
    required double fat,
    required double carbs,
    required String icon,
    required String canonicalName,
    double? grams,
  }) async {
    await (update(meals)..where((m) => m.id.equals(id) & m.deletedAt.isNull())).write(
      MealsCompanion(
        kcal: Value(kcal),
        proteinG: Value(protein),
        fatG: Value(fat),
        carbsG: Value(carbs),
        icon: Value(icon),
        canonicalName: Value(canonicalName),
        grams: Value(grams),
        source: const Value('reference'),
        updatedAt: Value(DateTime.now()),
        dirty: const Value(true),
      ),
    );
  }

  /// Removes an entry the way the server has to hear about it: the row stays,
  /// marked gone, until every device has been told.
  Future<void> removeMeal(String id) async {
    final now = DateTime.now();
    await (update(meals)..where((m) => m.id.equals(id))).write(
      MealsCompanion(deletedAt: Value(now), updatedAt: Value(now), dirty: const Value(true)),
    );
  }

  Future<void> addWater({required int ml, DateTime? at}) async {
    final when = at ?? DateTime.now();
    await into(waterLogs).insert(
      WaterLogsCompanion.insert(
        id: _uuid.v4(),
        updatedAt: when,
        day: dayKey(when),
        at: when,
        ml: ml,
      ),
    );
  }

  /// Записує тренування дня.
  ///
  /// Назва в таблиці не зберігається: вона є в довіднику видів під тим самим
  /// ключем, і два місця для одного рядка це два місця, де він може розійтись.
  Future<String> addWorkout({
    required String kind,
    required int minutes,
    required int kcal,
    DateTime? at,
  }) async {
    final when = at ?? DateTime.now();
    final id = _uuid.v4();
    await into(workouts).insert(
      WorkoutsCompanion.insert(
        id: id,
        updatedAt: when,
        day: dayKey(when),
        at: when,
        kind: kind,
        minutes: minutes,
        kcal: Value(kcal),
      ),
    );
    return id;
  }

  Future<List<WorkoutRow>> workoutsOn(DateTime day) {
    final key = dayKey(day);
    return (select(workouts)
          ..where((w) => w.day.equals(key) & w.deletedAt.isNull())
          ..orderBy([(w) => OrderingTerm(expression: w.at)]))
        .get();
  }

  Stream<List<WorkoutRow>> watchWorkouts(DateTime day) {
    final key = dayKey(day);
    return (select(workouts)
          ..where((w) => w.day.equals(key) & w.deletedAt.isNull())
          ..orderBy([(w) => OrderingTerm(expression: w.at)]))
        .watch();
  }

  /// Приводить воду дня до вказаного числа.
  ///
  /// Картка води показує підсумок за день і міняє його кроками, тому сюди
  /// приходить не «скільки випито зараз», а «скільки має стати». Різницю
  /// рахуємо тут, і рахуємо саме рядками, а не одним числом у дні: склянка це
  /// подія, у неї є час, і саме з подій збирається графік.
  ///
  /// Назад забирається з найсвіжішого: людина, яка натиснула «менше», скасовує
  /// те, що щойно додала, а не ранкову склянку.
  Future<void> setWaterTotal(int want, {DateTime? at}) async {
    final when = at ?? DateTime.now();
    final rows =
        await (select(waterLogs)
              ..where((w) => w.day.equals(dayKey(when)) & w.deletedAt.isNull())
              ..orderBy([(w) => OrderingTerm(expression: w.at)]))
            .get();

    final have = rows.fold<int>(0, (sum, r) => sum + r.ml);
    final diff = want.clamp(0, 1 << 30) - have;
    if (diff == 0) return;
    if (diff > 0) return addWater(ml: diff, at: when);

    var left = -diff;
    for (final row in rows.reversed) {
      if (left <= 0) break;

      if (row.ml <= left) {
        // Склянки більше не було. Рядок ховається, а не зникає: інший пристрій
        // має дізнатись про скасування, а з відсутнього рядка він не дізнається.
        left -= row.ml;
        await (update(waterLogs)..where((w) => w.id.equals(row.id))).write(
          WaterLogsCompanion(
            deletedAt: Value(when),
            updatedAt: Value(when),
            dirty: const Value(true),
          ),
        );
        continue;
      }

      // Склянка була, але меншою, ніж записали.
      await (update(waterLogs)..where((w) => w.id.equals(row.id))).write(
        WaterLogsCompanion(
          ml: Value(row.ml - left),
          updatedAt: Value(when),
          dirty: const Value(true),
        ),
      );
      left = 0;
    }
  }

  Future<int> waterOn(DateTime day) async {
    final key = dayKey(day);
    final sum = waterLogs.ml.sum();
    final row = await (selectOnly(waterLogs)
          ..addColumns([sum])
          ..where(waterLogs.day.equals(key) & waterLogs.deletedAt.isNull()))
        .getSingle();
    return row.read(sum) ?? 0;
  }

  Stream<int> watchWater(DateTime day) {
    final key = dayKey(day);
    final sum = waterLogs.ml.sum();
    return (selectOnly(waterLogs)
          ..addColumns([sum])
          ..where(waterLogs.day.equals(key) & waterLogs.deletedAt.isNull()))
        .map((row) => row.read(sum) ?? 0)
        .watchSingle();
  }

  /// One weight a day: a second reading replaces the first rather than adding a
  /// second point to the graph, because the product asks for a morning weight.
  Future<void> setWeight({required double kg, DateTime? at}) async {
    final when = at ?? DateTime.now();
    final key = dayKey(when);

    final existing = await (select(weights)
          ..where((w) => w.day.equals(key) & w.deletedAt.isNull()))
        .getSingleOrNull();

    if (existing == null) {
      await into(weights).insert(
        WeightsCompanion.insert(
          id: _uuid.v4(),
          updatedAt: when,
          day: key,
          at: when,
          kg: kg,
        ),
      );
      return;
    }

    await (update(weights)..where((w) => w.id.equals(existing.id))).write(
      WeightsCompanion(
        kg: Value(kg),
        at: Value(when),
        updatedAt: Value(when),
        dirty: const Value(true),
      ),
    );
  }

  /// Усе, що записано з [from], одним махом.
  ///
  /// Для підсумків за період: три вибірки замість трьох запитів на кожен день.
  /// Потік, бо стрічка тижня і аналітика мають міняти числа тієї ж миті, коли
  /// щось записали, а не після повернення на екран.
  Stream<({List<MealRow> meals, List<WaterLog> water, List<Weight> weights})> watchSince(
    DateTime from,
  ) {
    final m = (select(meals)..where((t) => t.at.isBiggerOrEqualValue(from) & t.deletedAt.isNull()))
        .watch();
    final w = (select(waterLogs)
          ..where((t) => t.at.isBiggerOrEqualValue(from) & t.deletedAt.isNull()))
        .watch();
    final k = (select(weights)
          ..where((t) => t.at.isBiggerOrEqualValue(from) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.at)]))
        .watch();

    return m.asyncMap((meals) async => (
      meals: meals,
      water: await w.first,
      weights: await k.first,
    ));
  }

  Stream<Weight?> watchWeight(DateTime day) {
    final key = dayKey(day);
    return (select(weights)..where((w) => w.day.equals(key) & w.deletedAt.isNull()))
        .watchSingleOrNull();
  }
}
