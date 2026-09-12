/// Тиждень, зведений у кілька чисел.
///
/// Одне місце на картку дня і на сторінку тижня. Інакше кожна з них рахувала б
/// своє середнє, і рано чи пізно вони розійшлись би: картка казала б «1 840», а
/// сторінка під нею «1 870», і повірити не можна було б жодній.
library;

import 'day.dart';
import 'day_stats.dart';
import 'nutrients.dart';
import 'settings.dart';

/// Один день у ряду тижня.
class WeekDay {
  const WeekDay({
    required this.date,
    required this.label,
    required this.kcal,
    this.burned = 0,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.logged,
    required this.ok,
  });

  /// Зсув від сьогодні, як усюди в застосунку.
  final int date;

  /// Дві літери, як їх друкує стрічка: «ПН», «ВТ».
  final String label;

  /// Зʼїдене мінус спалене: те саме число, що на картці дня і в кружечку.
  final int kcal;

  /// Скільки з зʼїденого пішло на тренування.
  final int burned;

  /// Грами складників цього дня: стовпчик каже, з чого склались калорії.
  final int protein;
  final int fat;
  final int carbs;

  /// Чи є за цей день бодай щось. День без запису це прогалина, а не нуль.
  final bool logged;

  /// Чи день закінчився всередині вікна цілі.
  ///
  /// Три стани, а не два. Порожньо означає, що вердикту нема на чому будувати:
  /// день без запису або сьогодні, яке ще триває. Пофарбувати сьогоднішній
  /// ранок у червоне за недобір означало б лаяти людину за те, що вона ще не
  /// пообідала.
  ///
  /// Правило те саме, що фарбує кружечки в стрічці дня і рахує серію: одна
  /// відповідь на питання «чи вдався день» на весь застосунок.
  final bool? ok;
}

class WeekSummary {
  const WeekSummary({
    required this.avgKcal,
    required this.avgProtein,
    required this.avgFat,
    required this.avgCarbs,
    required this.avgWaterMl,
    required this.avgNutrients,
    required this.daysLogged,
    required this.daysOnGoal,
    required this.daysFinished,
    required this.normKcal,
    required this.weightFrom,
    required this.weightTo,
    required this.byDay,
  });

  /// Середнє за добу по тих днях, де щось записано.
  final int avgKcal;
  final double avgProtein;
  final double avgFat;
  final double avgCarbs;
  final int avgWaterMl;

  /* Пʼять нутрієнтів, теж середні за добу.
   *
   * Ділиться не на сім днів і не на записані, а на ті, у яких це число взагалі
   * є. Страва, записана до появи підрахунку, його не має і вже не матиме, і
   * ділити на такий день означало б занижувати середнє за нашу власну
   * неповноту. Порожньо там, де таких днів немає жодного: нуль сказав би, що
   * клітковини за тиждень не було. */
  final Nutrients avgNutrients;

  /// Скільки днів тижня мають хоч якийсь запис.
  final int daysLogged;

  /// Скільки завершених днів минули всередині вікна цілі.
  final int daysOnGoal;

  /// Скільки записаних днів уже завершились. Сьогодні сюди не входить.
  final int daysFinished;

  final int normKcal;

  /// Вага на початку і в кінці тижня, коли зважувань було хоча б два.
  final double? weightFrom;
  final double? weightTo;

  /// Ряд калорій по днях, від найдавнішого. Для смужок на сторінці.
  final List<WeekDay> byDay;

  /// Частка витриманих днів. Порожній тиждень не є ідеальним.
  double get onGoalShare => daysFinished == 0 ? 0 : daysOnGoal / daysFinished;

  /// Наскільки середнє відхилилось від норми. Додатне означає перебір.
  int get offNorm => avgKcal - normKcal;

  /* Де стоїть тиждень на шкалі недобору й перебору: від -1 до 1.
   *
   * Шкала та сама, що й вердикт дня. Середня третина шкали це вікно вдалого
   * дня цілком: середнє всередині вікна стоїть у зеленому, і тільки за його
   * межами позначка йде в червоне, доїжджаючи до краю за [_far] калорій поза
   * вікном. Доти шкала мала свою власну міру, чотириста від норми до краю, і
   * людина, що щодня їла норму мінус двісті п'ятдесят (усі кружечки зелені),
   * бачила позначку на дві третини шляху до червоного. */
  double meterOn(Direction direction) {
    final w = goalWindow(direction);
    final lo = -w.under.toDouble();
    final hi = w.over.toDouble();
    final center = (lo + hi) / 2;
    final half = (hi - lo) / 2;
    final off = offNorm - center;

    // Усередині вікна: рівномірно по середній третині.
    if (off.abs() <= half) return half == 0 ? 0 : off / half / 3;

    // Поза вікном: решта шкали за [_far] калорій від краю вікна.
    final beyond = (off.abs() - half) / _far;
    return off.sign * (1 / 3 + (2 / 3) * (beyond > 1 ? 1 : beyond));
  }

  /// Скільки поза вікном це вже край шкали. Приблизно повноцінний прийом їжі:
  /// далі за нього деталі не важливі, важливо тільки те, що людина далеко.
  static const _far = 400.0;

  /// Скільки ваги пішло або прийшло за тиждень. Без двох зважувань `null`.
  double? get weightChange =>
      weightFrom == null || weightTo == null ? null : weightTo! - weightFrom!;
}

/// Зводить останні сім днів.
///
/// Середнє рахується **по записаних днях, а не по семи**. День, який людина
/// забула записати, це не день, коли вона нічого не їла, і ділити на нього
/// означало б занижувати середнє за те, що вона не відкрила застосунок.
///
/// **І без сьогодні.** День, що триває, це не день, а його початок: о десятій
/// ранку в ньому лежить самий сніданок, і середнє з ним щоранку провалювалось
/// у «недобір», а позначка на шкалі їхала вліво. Сьогодні входить у середнє
/// лише тоді, коли інших записаних днів у тижні ще немає: інакше картка в
/// понеділок мовчала б цілий день.
///
/// Калорії тут нетто: зʼїдене мінус спалене, як на картці дня і в кружечках.
WeekSummary weekSummary(
  DayStats stats,
  SettingsState s, [
  /* Який тиждень зводити: той, у якому лежить цей день. Нуль це сьогодні, і
     тоді виходить поточний тиждень, як було завжди.

     Тиждень тут календарний, від понеділка до неділі, а не «сім днів назад від
     вибраного». Причина проста: рівно такий тиждень показує стрічка дат угорі,
     і дві різні сімки на одному екрані читались би як помилка. */
  int pick = todayDate,
]) {
  final norm = dailyKcal(s);

  var kcal = 0;
  var protein = 0;
  var fat = 0;
  var carbs = 0;
  var water = 0;
  var logged = 0;

  /// Дні, які пішли в середнє. Потрібні нутрієнтам: вони рахуються окремо.
  final counted = <int>[];
  var finished = 0;
  var onGoal = 0;

  final byDay = <WeekDay>[];

  bool hit(int date, DayTotals totals) =>
      dayHit(kcal: totals.kcal, burned: stats.burnedOn(date), norm: norm, direction: s.direction);

  final monday = mondayOf(pick);

  for (final date in List.generate(7, (i) => monday + i)) {
    final totals = stats.totalsOn(date);
    final has = stats.has(date);

    byDay.add(
      WeekDay(
        date: date,
        label: dayInfo(date).label,
        kcal: stats.netOn(date),
        burned: stats.burnedOn(date),
        protein: totals.protein,
        fat: totals.fat,
        carbs: totals.carbs,
        logged: has,
        ok: !has || date >= 0 ? null : hit(date, totals),
      ),
    );
    // Сьогодні ще триває: ні в середнє, ні в норму його зараховувати зарано.
    if (!has || date >= 0) continue;

    kcal += stats.netOn(date);
    protein += totals.protein;
    fat += totals.fat;
    carbs += totals.carbs;
    water += stats.waterOn(date);
    counted.add(date);
    logged++;
    finished++;
    if (hit(date, totals)) onGoal++;
  }

  // Тиждень щойно почався: сьогодні це все, що є, і мовчати гірше.
  /* Виняток працює тільки для тижня, у якому лежить сьогодні: у минулому тижні
     завершились усі сім днів, і рятувати там нема чого. */
  if (monday <= todayDate && monday + 6 >= todayDate && logged == 0 && stats.has(todayDate)) {
    final totals = stats.totalsOn(todayDate);
    kcal = stats.netOn(todayDate);
    protein = totals.protein;
    fat = totals.fat;
    carbs = totals.carbs;
    water = stats.waterOn(todayDate);
    counted
      ..clear()
      ..add(todayDate);
    logged = 1;
  }

  /* Вага береться з тих самих зважувань, що й картка ваги, а не окремим рядом:
     два джерела однієї ваги розійдуться на першому ж записі.

     Потрібні саме два зважування, а не одне. З одним початок і кінець тижня це
     той самий запис, різниця виходить рівно нуль, і сторінка каже «0.0 кг»,
     ніби вага трималась. Насправді вона не трималась, а просто не міряна: одне
     зважування не описує тижня, і чесна відповідь тут «не зважувались». */
  final weighed = List.generate(7, (i) => monday + i)
      .where((d) => stats.weightOn(d) != null)
      .toList()
    ..sort();

  final div = logged == 0 ? 1 : logged;

  return WeekSummary(
    avgKcal: (kcal / div).round(),
    avgProtein: protein / div,
    avgFat: fat / div,
    avgCarbs: carbs / div,
    avgWaterMl: (water / div).round(),
    /* Ті самі дні, що й у решти середніх: сьогодні не входить, бо день, що
       триває, це його початок. Функція спільна з аналітикою. */
    avgNutrients: nutrientsAvg(stats, counted),
    daysLogged: logged,
    daysOnGoal: onGoal,
    daysFinished: finished,
    normKcal: norm,
    weightFrom: weighed.length >= 2 ? stats.weightOn(weighed.first) : null,
    weightTo: weighed.length >= 2 ? stats.weightOn(weighed.last) : null,
    byDay: byDay,
  );
}

/// Скільки тижня вже прожито, від нуля в понеділок до одиниці о 23:59 неділі.
///
/// Цілі дні від понеділка плюс частка сьогоднішнього. Саме доданок за сьогодні
/// робить наповнення поступовим, а не стрибками опівночі: кільце повзе цілий
/// день, а не смикається раз на добу.
///
/// Понеділок береться з календаря застосунку через [mondayOf], тим самим, яким
/// малюється стрічка дат: два різні уявлення про те, де починається тиждень,
/// суперечили б одне одному на одному екрані.
double weekRun([int pick = todayDate, DateTime? now]) {
  final clock = now ?? DateTime.now();

  /* Відлік від понеділка того тижня, у якому лежить вибраний день, а не від
     сьогоднішнього. Інакше картка минулого тижня показувала б, скільки минуло
     цього: числа з одного тижня, а кільце з іншого.

     Частка дня додається лише сьогоднішньому. Минулий день прожитий цілком,
     майбутній не прожитий зовсім, і тільки сьогодні триває просто зараз. */
  final sinceMonday = pick - mondayOf(pick);
  final dayShare = (clock.hour * 60 + clock.minute) / 1440;
  final share = pick == todayDate
      ? dayShare
      : pick < todayDate
      ? 1.0
      : 0.0;
  final run = (sinceMonday + share) / 7;
  return run < 0 ? 0 : (run > 1 ? 1 : run);
}

/* Вікно тижневого розбору. Правила ті самі, що на сервері, слово в слово:
   тут вони малюють кнопку і прогрес-лінію, там тримають двері. Розійтись їм
   не можна, бо кнопка, за якою зачинено, гірша за відсутню. */

/// З якої години пʼятниці відкривається розбір.
const reviewOpensHour = 18;

/// Чи відкрите зараз вікно: з пʼятниці 18:00 до кінця неділі.
bool reviewOpen([DateTime? now]) {
  final c = now ?? DateTime.now();
  if (c.weekday == DateTime.saturday || c.weekday == DateTime.sunday) return true;
  return c.weekday == DateTime.friday && c.hour >= reviewOpensHour;
}

/// Поступ до вікна: нуль у понеділок 00:00, одиниця в пʼятницю 18:00.
///
/// Це шлях прогрес-лінії, яка стоїть на місці кнопки в будні: тиждень
/// набирається, і з ним набирається те, про що буде розбір.
double reviewProgress([DateTime? now]) {
  final c = now ?? DateTime.now();
  final minutes = (c.weekday - 1) * 1440 + c.hour * 60 + c.minute;
  const span = 4 * 1440 + reviewOpensHour * 60;
  final run = minutes / span;
  return run < 0 ? 0 : (run > 1 ? 1 : run);
}

/// Імʼя тижня: його понеділок, yyyy-mm-dd. Те саме слово, яким тиждень зветься
/// на сервері і в «Минулих».
String reviewWeekKey([DateTime? now]) {
  final c = now ?? DateTime.now();
  final monday = DateTime(c.year, c.month, c.day - (c.weekday - 1));
  return '${monday.year.toString().padLeft(4, '0')}-'
      '${monday.month.toString().padLeft(2, '0')}-'
      '${monday.day.toString().padLeft(2, '0')}';
}

/// Середнє по тих днях, де це число взагалі є. Порожньо, коли таких немає.
double? _mean(Map<NutrientKey, double> sum, Map<NutrientKey, int> days, NutrientKey k) =>
    days[k] == 0 ? null : sum[k]! / days[k]!;

/* Середні нутрієнти за довільний набір днів.
 *
 * Те саме правило, що всередині зведення тижня, і тому воно тут одне на обидва
 * місця: ділиться не на всі дні вікна, а на ті, у яких це число взагалі є.
 * Страва, записана до появи підрахунку, його не має і вже не матиме, і ділити
 * на такий день означало б занижувати середнє за нашу власну неповноту.
 */
Nutrients nutrientsAvg(DayStats stats, Iterable<int> dates) {
  final sum = {for (final k in NutrientKey.values) k: 0.0};
  final days = {for (final k in NutrientKey.values) k: 0};

  for (final date in dates) {
    final n = stats.nutrientsOn(date);
    for (final k in NutrientKey.values) {
      final v = n[k];
      if (v == null) continue;
      sum[k] = sum[k]! + v;
      days[k] = days[k]! + 1;
    }
  }

  return Nutrients(
    fiber: _mean(sum, days, NutrientKey.fiber),
    sugar: _mean(sum, days, NutrientKey.sugar),
    added: _mean(sum, days, NutrientKey.added),
    sodiumMg: _mean(sum, days, NutrientKey.sodium),
    sat: _mean(sum, days, NutrientKey.sat),
  );
}
