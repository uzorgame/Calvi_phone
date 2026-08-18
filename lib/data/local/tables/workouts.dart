import 'package:drift/drift.dart';

import 'synced.dart';

/// What was burnt, and for how long.
///
/// Рядок зветься `WorkoutRow`, а не `Workout`: під останнім іменем застосунок
/// уже носить своє тренування, з назвою виду і часом рядком, і два різні
/// `Workout` в одному файлі не уживаються. Так само зроблено зі стравою.
@DataClassName('WorkoutRow')
class Workouts extends Table with Synced {
  TextColumn get day => text().withLength(min: 10, max: 10)();
  DateTimeColumn get at => dateTime()();
  TextColumn get kind => text()();
  IntColumn get minutes => integer()();
  IntColumn get kcal => integer().withDefault(const Constant(0))();
}
