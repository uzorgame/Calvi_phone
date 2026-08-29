/// Тиждень, зведений у кілька чисел.
///
/// Одне місце на картку дня і на сторінку тижня. Інакше кожна з них рахувала б
/// своє середнє, і рано чи пізно вони розійшлись би: картка казала б «1 840», а
/// сторінка під нею «1 870», і повірити не можна було б жодній.
library;

import 'day.dart';
import 'day_stats.dart';
import 'settings.dart';

/// Один день у ряду тижня.
class WeekDay {
  const WeekDay({
    required this.date,
    required this.label,
    required this.kcal,
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

  final int kcal;

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

  /// Скільки ваги пішло або прийшло за тиждень. Без двох зважувань `null`.
  double? get weightChange =>
      weightFrom == null || weightTo == null ? null : weightTo! - weightFrom!;
}

/// Зводить останні сім днів.
///
/// Середнє рахується **по записаних днях, а не по семи**. День, який людина
/// забула записати, це не день, коли вона нічого не їла, і ділити на нього
/// означало б занижувати середнє за те, що вона не відкрила застосунок.
WeekSummary weekSummary(DayStats stats, SettingsState s) {
  final norm = dailyKcal(s);

  var kcal = 0;
  var protein = 0;
  var fat = 0;
  var carbs = 0;
  var water = 0;
  var logged = 0;
  var finished = 0;
  var onGoal = 0;

  final byDay = <WeekDay>[];

  for (final date in weekDates) {
    final totals = stats.totalsOn(date);
    final has = stats.has(date);

    byDay.add(
      WeekDay(
        date: date,
        label: dayInfo(date).label,
        kcal: totals.kcal,
        protein: totals.protein,
        fat: totals.fat,
        carbs: totals.carbs,
        logged: has,
        ok: !has || date >= 0
            ? null
            : dayHit(kcal: totals.kcal, norm: norm, direction: s.direction),
      ),
    );
    if (!has) continue;

    kcal += totals.kcal;
    protein += totals.protein;
    fat += totals.fat;
    carbs += totals.carbs;
    water += stats.waterOn(date);
    logged++;

    // Сьогодні ще триває: у норму чи в перебір його зараховувати зарано.
    if (date < 0) {
      finished++;
      if (dayHit(kcal: totals.kcal, norm: norm, direction: s.direction)) onGoal++;
    }
  }

  /* Вага береться з тих самих зважувань, що й картка ваги, а не окремим рядом:
     два джерела однієї ваги розійдуться на першому ж записі.

     Потрібні саме два зважування, а не одне. З одним початок і кінець тижня це
     той самий запис, різниця виходить рівно нуль, і сторінка каже «0.0 кг»,
     ніби вага трималась. Насправді вона не трималась, а просто не міряна: одне
     зважування не описує тижня, і чесна відповідь тут «не зважувались». */
  final weighed = weekDates.where((d) => stats.weightOn(d) != null).toList()..sort();

  final div = logged == 0 ? 1 : logged;

  return WeekSummary(
    avgKcal: (kcal / div).round(),
    avgProtein: protein / div,
    avgFat: fat / div,
    avgCarbs: carbs / div,
    avgWaterMl: (water / div).round(),
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
double weekRun([DateTime? now]) {
  final clock = now ?? DateTime.now();
  final sinceMonday = -mondayOf(todayDate);
  final dayShare = (clock.hour * 60 + clock.minute) / 1440;
  final run = (sinceMonday + dayShare) / 7;
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
