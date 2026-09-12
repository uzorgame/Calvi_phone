import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/day.dart';
import 'package:calvi/data/day_stats.dart';
import 'package:calvi/data/goal_at.dart';
import 'package:calvi/data/measure.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/data/week.dart';

/* Тиждень належить вибраному дню, а не сьогоднішньому.
 *
 * Картка дня має три сторони, і дві задні довго не знали, який день показано:
 * вага бралась із профілю, а тиждень зводився сталим вікном «останні сім днів».
 * Людина гортала стрічку дат, калорії слухняно мінялись, а вага і тиждень
 * стояли на місці й розповідали про сьогодні під чужою датою.
 */
void main() {
  final s = initialSettings();

  test('зводиться тиждень вибраного дня, від понеділка до неділі', () {
    final past = weekSummary(DayStats.demo(), s, -9);

    expect(past.byDay.length, 7);
    expect(past.byDay.first.date, mondayOf(-9), reason: 'тиждень починається зі свого понеділка');
    expect(past.byDay.last.date, mondayOf(-9) + 6);
    expect(
      past.byDay.map((d) => d.date),
      isNot(contains(todayDate)),
      reason: 'сьогодні не належить тому тижню',
    );
  });

  test('без дня зводиться поточний тиждень, як було завжди', () {
    final now = weekSummary(DayStats.demo(), s);
    expect(now.byDay.first.date, mondayOf(todayDate));
    expect(now.byDay.map((d) => d.date), contains(todayDate));
  });

  test('кільце тижня показує, скільки минуло до вибраного дня', () {
    /* Понеділок це початок тижня, неділя його кінець. Минулий день прожитий
       цілком, тому доданка за години в них немає: вони або були, або ні. */
    final monday = mondayOf(-9);
    expect(weekRun(monday), closeTo(1 / 7, 0.001));
    expect(weekRun(monday + 6), closeTo(1, 0.001));
  });

  test('вага береться остання на цей день або раніше', () {
    const list = [
      Measure(date: -10, values: {'weightKg': 79.0}),
      Measure(date: -3, values: {'weightKg': 78.7}),
      Measure(date: 0, values: {'weightKg': 78.6}),
    ];

    expect(measuredOn(list, 'weightKg', 0), 78.6);
    // Зважились у понеділок, у вівторок не ставали на ваги: число понеділкове.
    expect(measuredOn(list, 'weightKg', -2), 78.7);
    expect(measuredOn(list, 'weightKg', -5), 79.0);
    // До найпершого зважування правди немає, і вигадувати її нема з чого.
    expect(measuredOn(list, 'weightKg', -20), isNull);
  });

  test('картка бере ціль, яка діяла того дня', () {
    /* Одна ціль у демонстраційній історії, поставлена два місяці тому. День,
       старший за неї, дістає її ж: до появи цілі шляху не було, а порожня
       картка гірша за найдавнішу відому. */
    final stats = DayStats.demo();

    expect(stats.goalOn(todayDate)?.targetKg, 74);
    expect(stats.goalOn(-90)?.targetKg, 74, reason: 'найдавніша ціль лишається для всього, що до неї');

    /* Дві цілі: день між ними бере першу, день після другої бере другу. Саме
       це й тримає минулі картки на місці, коли ціль міняють сьогодні. */
    const two = [
      GoalAt(from: -60, startKg: 81, targetKg: 74, direction: Direction.lose),
      GoalAt(from: -7, startKg: 79, targetKg: 76, direction: Direction.lose),
    ];
    final twice = DayStats(totals: {}, water: {}, weights: {}, goals: two, demo: false);

    expect(twice.goalOn(-30)?.targetKg, 74, reason: 'місяць тому шлях вів до 74');
    expect(twice.goalOn(-3)?.targetKg, 76);
    expect(twice.goalOn(todayDate)?.targetKg, 76);
  });

  test('без історії цілей картка не падає', () {
    const bare = DayStats(totals: {}, water: {}, weights: {}, demo: false);
    expect(bare.goalOn(todayDate), isNull, reason: 'порожньо означає «бери поточну ціль»');
  });

  test('пройдений шлях рахується вагою того дня', () {
    final goal = s.copyWith(weightKg: 78.6, goalStartKg: 81, targetKg: 74);

    final now = goalProgress(goal);
    final then = goalProgress(goal, 80.0);

    expect(then, lessThan(now), reason: 'місяць тому шлях був коротший');
    expect(goalProgress(goal, 81), closeTo(0, 0.001), reason: 'на старті нуль');
    expect(goalProgress(goal, 74), closeTo(1, 0.001), reason: 'у цілі одиниця');
  });
}
