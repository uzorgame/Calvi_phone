import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';
import '../tables/meals.dart';
import '../tables/measurements.dart';
import '../tables/medication_takes.dart';
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
@DriftAccessor(tables: [Meals, WaterLogs, Weights, Measurements, Workouts, MedicationTakes])
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

  /// Страва, яку записав сервер, покладена на телефон тим самим рядком.
  ///
  /// Нора пише в базу на VPS, і доти, доки телефон не забере це синхронізацією,
  /// картка дня лишається порожньою. Між «записала» і появою запису стоїть
  /// мережа: повільна відповідь, втрачений пакет чи будь-яка розбіжність у ключі
  /// дня, і людина читає підтвердження над порожнім сніданком.
  ///
  /// Тому рядок кладеться одразу, з ідентифікатором сервера. Коли та сама страва
  /// приїде синхронізацією, вона знайде себе за цим же id і оновиться, а не
  /// подвоїться. Чистий рядок, не брудний: сервер уже його має, і відправляти
  /// його назад означало б записати ту саму їжу вдруге.
  /* Переписує запис, який уже лежить, не чіпаючи його дня і часу.
   *
   * Саме переписує, а не кладе наново: людина виправила вагу, і запис має
   * лишитись тим самим записом, на тому самому місці в картці. Час тут не
   * оновлюється навмисне, інакше виправлена о шостій вечора вчорашня вечеря
   * переїхала б на шосту вечора. */
  Future<void> patchServerMeal({
    required String id,
    required String name,
    required int kcal,
    double? grams,
    double protein = 0,
    double fat = 0,
    double carbs = 0,
  }) => (update(meals)..where((m) => m.id.equals(id))).write(
    MealsCompanion(
      name: Value(name),
      kcal: Value(kcal),
      grams: Value(grams),
      proteinG: Value(protein),
      fatG: Value(fat),
      carbsG: Value(carbs),
      updatedAt: Value(DateTime.now()),
      dirty: const Value(false),
    ),
  );

  /* Перенесений запис: міняється місце, а не зміст.
   *
   * Числа не чіпаються навмисно. Це і є суть переносу: страва та сама, вага та
   * сама, виправлення, які людина колись зробила, лишаються при ній. Час іде
   * разом із карткою, інакше вечеря стояла б у переліку дня поперед сніданку. */
  Future<void> moveServerMeal({
    required String id,
    required String day,
    required String slot,
    DateTime? at,
  }) => (update(meals)..where((m) => m.id.equals(id))).write(
    MealsCompanion(
      day: Value(day),
      slot: Value(slot),
      at: at == null ? const Value.absent() : Value(at),
      updatedAt: Value(DateTime.now()),
      dirty: const Value(false),
    ),
  );

  Future<void> putServerMeal({
    required String id,
    required String day,
    required String slot,
    required String name,
    required int kcal,
    required DateTime at,
    double? grams,
    double protein = 0,
    double fat = 0,
    double carbs = 0,
    String icon = 'plate',
  }) => into(meals).insertOnConflictUpdate(
    MealsCompanion.insert(
      id: id,
      updatedAt: at,
      dirty: const Value(false),
      day: day,
      at: at,
      tzOffsetMin: Value(at.timeZoneOffset.inMinutes),
      slot: slot,
      name: name,
      kcal: kcal,
      grams: Value(grams),
      proteinG: Value(protein),
      fatG: Value(fat),
      carbsG: Value(carbs),
      icon: Value(icon),
      source: const Value('chat'),
    ),
  );

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

  /// Прийняті дози цього дня, парами «препарат|година».
  Future<Set<String>> takesOn(DateTime day) async {
    final key = dayKey(day);
    final rows = await (select(
      medicationTakes,
    )..where((t) => t.day.equals(key) & t.deletedAt.isNull())).get();
    return {for (final r in rows) '${r.medicationId}|${r.plannedTime ?? ''}'};
  }

  /// Склянка, яку записав сервер, покладена на телефон тим самим рядком.
  ///
  /// З ідентифікатором сервера і не брудна, з тієї ж причини, що й страва:
  /// інакше телефон відправив би цю саму воду назад, і в дні її стало б удвічі
  /// більше, ніж людина випила.
  Future<void> putServerWater({
    required String id,
    required String day,
    required int ml,
    required DateTime at,
  }) => into(waterLogs).insertOnConflictUpdate(
    WaterLogsCompanion.insert(
      id: id,
      updatedAt: at,
      dirty: const Value(false),
      day: day,
      at: at,
      ml: ml,
    ),
  );

  /// Тренування, яке записав сервер, покладене на телефон тим самим рядком.
  Future<void> putServerWorkout({
    required String id,
    required String day,
    required String kind,
    required int minutes,
    required int kcal,
    required DateTime at,
  }) => into(workouts).insertOnConflictUpdate(
    WorkoutsCompanion.insert(
      id: id,
      updatedAt: at,
      dirty: const Value(false),
      day: day,
      at: at,
      kind: kind,
      minutes: minutes,
      kcal: Value(kcal),
    ),
  );

  /// Замір, який записав сервер, покладений на телефон тим самим рядком.
  ///
  /// Вага і сантиметр ідуть у різні таблиці, як і всюди в застосунку: вага це
  /// щоденний вимір, з якого будується крива, а обхвати міряються раз на місяць.
  Future<void> putServerWeight({
    required String id,
    required String day,
    required double kg,
    required DateTime at,
  }) => into(weights).insertOnConflictUpdate(
    WeightsCompanion.insert(
      id: id,
      updatedAt: at,
      dirty: const Value(false),
      day: day,
      at: at,
      kg: kg,
    ),
  );

  Future<void> putServerMeasure({
    required String id,
    required String day,
    required String part,
    required double cm,
    required DateTime at,
  }) => into(measurements).insertOnConflictUpdate(
    MeasurementsCompanion.insert(
      id: id,
      updatedAt: at,
      dirty: const Value(false),
      day: day,
      at: at,
      part: part,
      cm: cm,
    ),
  );

  /// Гасить рядок, який уже прибрав сервер.
  ///
  /// Не брудний, на відміну від [removeMeal]: сервер про це видалення знає, він
  /// його і зробив. Позначка лишається, а не рядок зникає, бо синхронізація
  /// вміє привозити зміни, а не помічати відсутність, і без неї запис
  /// повернувся б наступним же обміном.
  Future<void> forgetServerMeal(String id) async {
    final now = DateTime.now();
    await (update(meals)..where((m) => m.id.equals(id))).write(
      MealsCompanion(deletedAt: Value(now), updatedAt: Value(now), dirty: const Value(false)),
    );
  }

  /* Закладка «ця чернетка чекає на питання про вагу №такий-то».
   *
   * Без позначки брудності: сервер про чернетки-двійники знати не мусить, це
   * місцеве господарство екрана. Живе в базі, а не в памʼяті, щоб відповідь
   * після перезапуску застосунку теж знайшла, кого прибрати. */
  Future<void> bindAsk(String mealId, String askId) =>
      (update(meals)..where((m) => m.id.equals(mealId))).write(MealsCompanion(askId: Value(askId)));

  /// Чернетка, що чекає на це питання. Порожньо, якщо такої немає: питання
  /// могло прийти з чату, де ніякої чернетки не існувало.
  Future<String?> draftForAsk(String askId) async {
    final row =
        await (select(meals)
              ..where((m) => m.askId.equals(askId) & m.deletedAt.isNull())
              ..limit(1))
            .getSingleOrNull();
    return row?.id;
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
    final row =
        await (selectOnly(waterLogs)
              ..addColumns([sum])
              ..where(waterLogs.day.equals(key) & waterLogs.deletedAt.isNull()))
            .getSingle();
    return row.read(sum) ?? 0;
  }

  /// Галочки прийому цього дня, потоком.
  ///
  /// День має перебудуватись від самої галочки: людина тисне «прийняв» на
  /// картці й чекає, що картка одразу це покаже, а не після виходу з екрана.
  Stream<Set<String>> watchTakes(DateTime day) {
    final key = dayKey(day);
    return (select(medicationTakes)..where((t) => t.day.equals(key) & t.deletedAt.isNull()))
        .watch()
        .map((rows) => {for (final r in rows) '${r.medicationId}|${r.plannedTime ?? ''}'});
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

    final existing = await (select(
      weights,
    )..where((w) => w.day.equals(key) & w.deletedAt.isNull())).getSingleOrNull();

    if (existing == null) {
      await into(weights).insert(
        WeightsCompanion.insert(id: _uuid.v4(), updatedAt: when, day: key, at: when, kg: kg),
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

  /// Один замір сантиметром: одна частина тіла, один день.
  ///
  /// Правило те саме, що й для ваги: другий замір за той самий день заміняє
  /// перший, а не додає точку. Людина, яка перемірялась двічі, хотіла
  /// виправити число, а не намалювати зубець.
  ///
  /// Раніше сюди не потрапляло нічого, крім ваги: талія, груди й біцепс жили в
  /// памʼяті екрана і зникали з перезапуском. Аналітика при цьому показувала їх
  /// у стрічці, і виглядало, ніби вони записані.
  Future<void> setMeasure({required String part, required double cm, DateTime? at}) async {
    final when = at ?? DateTime.now();
    final key = dayKey(when);

    final existing =
        await (select(measurements)
              ..where((m) => m.day.equals(key) & m.part.equals(part) & m.deletedAt.isNull()))
            .getSingleOrNull();

    if (existing == null) {
      await into(measurements).insert(
        MeasurementsCompanion.insert(
          id: _uuid.v4(),
          updatedAt: when,
          day: key,
          at: when,
          part: part,
          cm: cm,
        ),
      );
      return;
    }

    await (update(measurements)..where((m) => m.id.equals(existing.id))).write(
      MeasurementsCompanion(
        cm: Value(cm),
        at: Value(when),
        updatedAt: Value(when),
        dirty: const Value(true),
      ),
    );
  }

  /// Усі заміри сантиметром, від найдавнішого.
  Stream<List<Measurement>> watchMeasures() =>
      (select(measurements)
            ..where((m) => m.deletedAt.isNull())
            ..orderBy([(m) => OrderingTerm(expression: m.at)]))
          .watch();

  /// Усе, що записано з [from], одним знімком.
  Future<
    ({List<MealRow> meals, List<WaterLog> water, List<Weight> weights, List<Measurement> measures})
  >
  readSince(DateTime from) async => (
    meals: await (select(
      meals,
    )..where((t) => t.at.isBiggerOrEqualValue(from) & t.deletedAt.isNull())).get(),
    water: await (select(
      waterLogs,
    )..where((t) => t.at.isBiggerOrEqualValue(from) & t.deletedAt.isNull())).get(),
    weights:
        await (select(weights)
              ..where((t) => t.at.isBiggerOrEqualValue(from) & t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm(expression: t.at)]))
            .get(),
    measures:
        await (select(measurements)
              ..where((t) => t.at.isBiggerOrEqualValue(from) & t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm(expression: t.at)]))
            .get(),
  );

  /// Ті самі чотири таблиці, але потоком: будь-яка зміна в будь-якій із них.
  ///
  /// Тут стояв `meals.asyncMap(...)`, тобто новий знімок народжувався тільки
  /// тоді, коли мінялись страви, а решту просто дочитували в ту саму мить. Через
  /// це записана вага не доходила ні до картки замірів, ні до аналітики, поки
  /// людина не запише якусь їжу: дані в базі були, а екран про них не дізнавався.
  /// Та сама пастка вже ловила воду, і вдруге вона обійшлась дорожче.
  Stream<void> changes() => Stream<void>.multi((out) {
    final subs = [
      select(meals).watch().listen((_) => out.add(null)),
      select(waterLogs).watch().listen((_) => out.add(null)),
      select(weights).watch().listen((_) => out.add(null)),
      select(measurements).watch().listen((_) => out.add(null)),
    ];
    out.onCancel = () async {
      for (final s in subs) {
        await s.cancel();
      }
    };
  });

  Stream<Weight?> watchWeight(DateTime day) {
    final key = dayKey(day);
    return (select(
      weights,
    )..where((w) => w.day.equals(key) & w.deletedAt.isNull())).watchSingleOrNull();
  }
}
