/// Training, and the calories it gives back to the day.
library;

import 'fixtures.dart';

/// One kind of activity. `met` is the metabolic equivalent used to turn minutes
/// into calories.
class Activity {
  const Activity({required this.key, required this.label, required this.met});

  /// Also the name of its mark in the icon set.
  final String key;
  final String label;
  final double met;
}

const activities = <Activity>[
  Activity(key: 'gym', label: 'Зал', met: 5),
  Activity(key: 'run', label: 'Біг', met: 9.8),
  Activity(key: 'bike', label: 'Велосипед', met: 7.5),
  Activity(key: 'walk', label: 'Ходьба', met: 3.5),
  Activity(key: 'swim', label: 'Плавання', met: 7),
  Activity(key: 'yoga', label: 'Йога', met: 2.5),
  Activity(key: 'hiit', label: 'HIIT', met: 8),
  Activity(key: 'jumprope', label: 'Скакалка', met: 11),
  Activity(key: 'stretch', label: 'Розтяжка', met: 2.3),
  Activity(key: 'football', label: 'Футбол', met: 7),
  Activity(key: 'basketball', label: 'Баскетбол', met: 6.5),
  Activity(key: 'tennis', label: 'Теніс', met: 7.3),
  Activity(key: 'dance', label: 'Танці', met: 5),
  Activity(key: 'ski', label: 'Лижі', met: 7),
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
