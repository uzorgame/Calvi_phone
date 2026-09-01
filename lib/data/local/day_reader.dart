import 'dart:async';

import '../day.dart';
import '../day_stats.dart';
import '../measure.dart';
import '../meal.dart';
import '../workout.dart';
import 'database.dart';

/// The day, built from what is actually on this phone.
///
/// The screens do not know whether a day came from the fixtures or from the
/// database, and that is the point of this file: one shape in, one shape out,
/// so «real data» is a switch and not a second version of the day screen.
class DayReader {
  const DayReader(this.db);

  final CalviDb db;

  /// Everything recorded for [date], as the day screen expects it.
  ///
  /// A stream rather than a read: an entry written by the chat, by the camera or
  /// by another screen has to appear on the day without anybody asking it to.
  ///
  /// **Три джерела, і день перебудовується від будь-якого з них.** Тут стояло
  /// `watchMeals(...).asyncMap(...)`, тобто новий день народжувався лише тоді,
  /// коли мінялись страви, а воду й тренування просто дочитували в ту саму мить.
  /// Виглядало це так, ніби вода взагалі не записується: людина тиснула
  /// «більше», запис у базу йшов, а число на картці не рухалось до наступної
  /// страви. З «менше» так само, і саме тому це помітно найшвидше.
  Stream<DayModel> watch(DateTime date) {
    final controller = StreamController<DayModel>();
    final subs = <StreamSubscription<void>>[];

    /* Перебудова по одному за раз, із позначкою «прийшло ще». Дві зміни поспіль
       читали б базу назустріч одна одній, і на екран міг би лягти старіший з
       двох днів, бо запити не зобовʼязані завершуватись у тому ж порядку, у
       якому їх почали. */
    var busy = false;
    var again = false;

    Future<void> rebuild() async {
      if (busy) {
        again = true;
        return;
      }
      busy = true;
      try {
        do {
          again = false;
          final day = await read(date);
          if (!controller.isClosed) controller.add(day);
        } while (again);
      } finally {
        busy = false;
      }
    }

    controller.onListen = () {
      for (final source in <Stream<Object?>>[
        db.diaryDao.watchMeals(date),
        db.diaryDao.watchWater(date),
        db.diaryDao.watchWorkouts(date),
        db.diaryDao.watchTakes(date),
      ]) {
        subs.add(source.listen((_) => unawaited(rebuild())));
      }
    };

    controller.onCancel = () async {
      for (final s in subs) {
        await s.cancel();
      }
      subs.clear();
    };

    return controller.stream;
  }

  /// Один знімок дня, без потоку.
  Future<DayModel> read(DateTime date) async {
    final meals = [for (final row in await db.diaryDao.mealsOn(date)) _toMeal(row)];

    /* Сніданок, обід і вечеря стоять завжди. Решта карток зʼявляється разом із
       першим записом у них.
     *
     * Перекус довго не зʼявлявся зовсім: Нора писала бутерброд у `snack`, рядок
     * лягав у базу, а картки під нього не було, і запис ставав невидимим.
     * Порожнього перекусу показувати не треба, бо він не щоденний, але щойно в
     * ньому щось є, він має бути на екрані. */
    final extra = {
      for (final m in meals)
        if (!alwaysSlots.contains(m.slotId)) m.slotId,
    };

    final takes = await db.diaryDao.takesOn(date);

    return DayModel(
      medTakes: takes,
      slots: [
        for (final id in alwaysSlots) baseSlots[id]!,
        for (final id in extra) baseSlots[id] ?? baseSlots['snack']!,
      ],
      meals: meals,
      workouts: [for (final row in await db.diaryDao.workoutsOn(date)) _toWorkout(row)],
      waterMl: await db.diaryDao.waterOn(date),
    );
  }

  /// Підсумки багатьох днів одним запитом, для стрічки тижня і аналітики.
  ///
  /// Не цикл із [watch] по кожному дню: тримісячний період це дев'яносто днів, а
  /// значить дев'яносто запитів на кожну перемальовку. Тут пʼять запитів на всю
  /// картину, і вона оновлюється сама, щойно щось записали.
  ///
  /// Глибина покриває найдовше вікно аналітики: період «Рік» рахує 364 дні
  /// назад, і зі старими ста двадцятьма все старше просто випадало з річної
  /// суми, щойно історія ставала довшою. Мовчки: числа виглядали як повні.
  Stream<DayStats> watchStats({int days = 365}) {
    final from = DateTime.now().subtract(Duration(days: days));

    return db.diaryDao.changes().asyncMap((_) => db.diaryDao.readSince(from)).map((rows) {
      final totals = <int, DayTotals>{};
      final water = <int, int>{};
      final burned = <int, int>{};
      final weights = <int, double>{};

      for (final w in rows.workouts) {
        final key = _dayOffset(w.day);
        burned[key] = (burned[key] ?? 0) + w.kcal;
      }

      for (final m in rows.meals) {
        final key = _dayOffset(m.day);
        final was = totals[key];
        totals[key] = DayTotals(
          kcal: (was?.kcal ?? 0) + m.kcal,
          protein: (was?.protein ?? 0) + m.proteinG.round(),
          fat: (was?.fat ?? 0) + m.fatG.round(),
          carbs: (was?.carbs ?? 0) + m.carbsG.round(),
        );
      }

      for (final w in rows.water) {
        final key = _dayOffset(w.day);
        water[key] = (water[key] ?? 0) + w.ml;
      }

      // Одна вага на день: пізніший запис витісняє ранішній, як і в застосунку.
      for (final w in rows.weights) {
        weights[_dayOffset(w.day)] = w.kg;
      }

      /* Заміри складаються в один запис на день: людина міряє талію і груди за
         один підхід, і в стрічці це один рядок, а не два. Вага входить туди ж,
         бо в картці вимірювань вона стоїть першим полем. */
      final byDay = <int, Map<String, double>>{};
      for (final m in rows.measures) {
        (byDay[_dayOffset(m.day)] ??= {})[m.part] = m.cm;
      }
      for (final e in weights.entries) {
        (byDay[e.key] ??= {})['weightKg'] = e.value;
      }

      final measures = [for (final e in byDay.entries) Measure(date: e.key, values: e.value)]
        ..sort((a, b) => a.date.compareTo(b.date));

      return DayStats(
        totals: totals,
        water: water,
        burned: burned,
        weights: weights,
        measures: measures,
        demo: false,
      );
    });
  }

  /* Зсув дня рахується з календарного ключа, а не з часової позначки.
   *
   * Це та сама розбіжність, що ховалась між екраном і базою. Позначка часу несе
   * годину і пояс: запис, зроблений о пів на першу ночі, в іншому поясі легко
   * стає вчорашнім, і аналітика розходиться з тим самим днем на головному
   * екрані. Колонка `day` це вже вирішений календарний день, і саме за ним
   * щоденник питають усі інші екрани. */
  static int _dayOffset(String day) {
    final parts = day.split('-');
    if (parts.length < 3) return 0;

    final at = DateTime(
      int.tryParse(parts[0]) ?? 0,
      int.tryParse(parts[1]) ?? 1,
      int.tryParse(parts[2].substring(0, 2)) ?? 1,
    );

    final now = DateTime.now();
    return at.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  Meal _toMeal(MealRow row) => Meal(
    id: row.id,
    // The key travels as it is; an unknown one draws the plate where it is drawn.
    icon: row.icon,
    title: row.name,
    time: _clock(row.at),
    slotId: row.slot,
    grams: row.grams?.round() ?? 0,
    kcal: row.kcal,
    protein: row.proteinG.round(),
    fat: row.fatG.round(),
    carbs: row.carbsG.round(),
    auto: row.source != 'manual',
    /* Про запис не відомо нічого: ні калорій, ні макросів, ні ваги. Отже, його
       ще не порахували, і показувати впевнений нуль було б брехнею. Картка
       намалює «Нора рахує…» замість числа.
     *
     * Виводиться, а не зберігається окремою колонкою: «нічого не відомо» це не
       властивість запису, а спостереження про його числа, і тримати про це
       прапорець означало б мати два джерела однієї правди, які колись
       розійдуться. Страви, у якої справді нуль усього і без ваги, не існує:
       навіть трав'яний чай має свої два кілокалорії, а порожній рядок це рядок,
       який ще чекає. */
    pending:
        row.kcal == 0 &&
        row.proteinG == 0 &&
        row.fatG == 0 &&
        row.carbsG == 0 &&
        (row.grams ?? 0) == 0,
  );

  Workout _toWorkout(WorkoutRow row) => Workout(
    id: row.id,
    activity: row.kind,
    // Назва береться з довідника видів, а не з рядка: в таблиці її немає саме
    // для того, щоб один вид не звався по-різному в різних записах.
    title: activityFor(row.kind)?.label ?? row.kind,
    minutes: row.minutes,
    kcal: row.kcal,
    time: _clock(row.at),
  );

  static String _clock(DateTime at) =>
      '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';

  /// Writes what somebody typed by hand.
  ///
  /// Manual entries cost no tokens, so this path never touches the network: it
  /// is the one that has to keep working with no signal and no balance.
  /// Returns the id, so the caller can put real numbers on it once the food
  /// reference has answered.
  Future<String> addTyped({required String slotId, required String text}) =>
      db.diaryDao.addMeal(slot: slotId, name: text.trim(), kcal: 0);

  /// Страва з числами, які вписала людина.
  ///
  /// Ні мережі, ні токенів, ні очікування: числа вже є, і додавати до них нема
  /// чого. Саме цим ручний запис відрізняється від [addTyped], після якого
  /// рядок ще чекає, поки довідник або Нора його наповнять.
  Future<String> addManual({
    required String slotId,
    required String title,
    required int kcal,
    required int grams,
    required int protein,
    required int fat,
    required int carbs,
  }) => db.diaryDao.addMeal(
    slot: slotId,
    name: title.trim(),
    kcal: kcal,
    // Нуль грамів це «не сказали», а не «нічого не важило»: у сховищі вага
    // необовʼязкова саме для таких записів.
    grams: grams > 0 ? grams.toDouble() : null,
    protein: protein.toDouble(),
    fat: fat.toDouble(),
    carbs: carbs.toDouble(),
  );
}
