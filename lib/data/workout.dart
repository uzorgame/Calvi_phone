/// Training, and the calories it gives back to the day.
library;

import '../l10n/data_lang.dart';
import 'fixtures.dart';

/// One kind of activity. `met` is the metabolic equivalent used to turn minutes
/// into calories.
class Activity {
  const Activity({required this.key, required this.met});

  /// Also the name of its mark in the icon set.
  final String key;
  final double met;

  /// Назва береться з перекладу, а не лежить у сталій разом із коефіцієнтом.
  String get label => switch (key) {
    'gym' => dataL.actGym,
    'run' => dataL.actRun,
    'bike' => dataL.actBike,
    'walk' => dataL.actWalk,
    'swim' => dataL.actSwim,
    'yoga' => dataL.actYoga,
    'hiit' => dataL.actHiit,
    'jumprope' => dataL.actJumprope,
    'stretch' => dataL.actStretch,
    'football' => dataL.actFootball,
    'basketball' => dataL.actBasketball,
    'tennis' => dataL.actTennis,
    'dance' => dataL.actDance,
    _ => dataL.actSki,
  };
}

/* Коефіцієнти описують звичайну людину, а не спортсмена.
 *
 * Велосипед і біг доти стояли на спортивних числах: 7.5 це темп 19 до 22
 * км/год, 9.8 це біг на 9.7 км/год. Той, хто годину катався містом, отримував
 * 670 ккал замість справжніх трьохсот з чимось, тобто дозвіл на зайву вечерю.
 * У застосунку, який рахує дефіцит, завищене спалене шкодить прямо: воно
 * дописується до денної норми.
 *
 * Тепер велосипед це 4.5, трохи вище за довідникове «їзда на роботу або для
 * задоволення» (4.0), а біг це 8.0, тобто близько 8 км/год, темп аматора, а не
 * марафонця. Решта рядків звірена з Компендіумом фізичної активності і
 * лишилась як була.
 *
 * Помиляємось навмисно вниз. Занижене спалене коштує трохи повільнішого
 * відчуття прогресу, і самокорекція норми його виправить. Завищене коштує
 * переїдання, і його не виправить ніщо.
 */
const activities = <Activity>[
  Activity(key: 'gym', met: 5),
  Activity(key: 'run', met: 8),
  Activity(key: 'bike', met: 4.5),
  Activity(key: 'walk', met: 3.5),
  Activity(key: 'swim', met: 7),
  Activity(key: 'yoga', met: 2.5),
  Activity(key: 'hiit', met: 8),
  Activity(key: 'jumprope', met: 11),
  Activity(key: 'stretch', met: 2.3),
  Activity(key: 'football', met: 7),
  Activity(key: 'basketball', met: 6.5),
  Activity(key: 'tennis', met: 7.3),
  Activity(key: 'dance', met: 5),
  Activity(key: 'ski', met: 7),
];

Activity? activityFor(String key) {
  for (final a in activities) {
    if (a.key == key) return a;
  }
  return null;
}

class Workout {
  const Workout({
    required this.id,
    required this.activity,
    required this.title,
    required this.minutes,
    required this.kcal,
    required this.time,
  });

  final String id;

  /// Key into [activities], and the icon name.
  final String activity;
  final String title;
  final int minutes;
  final int kcal;
  final String time;
}

/// The standard MET formula, rounded to five.
///
/// The input is a guess about effort, so a figure like 337 would claim a
/// precision the estimate does not have.
///
/// Вага тут не стала. У формулі MET вона множник, тому людина на 55 кілограмів
/// і людина на сто спалюють за ту саму годину бігу помітно різне. Раніше сюди
/// підставлялась вага демонстраційної людини, і всі спалені калорії в
/// застосунку були про неї.
int burnEstimate(double met, int minutes, {double weightKg = profileWeightKg}) {
  final raw = met * 3.5 * weightKg / 200 * minutes;
  return (raw / 5).round() * 5;
}
