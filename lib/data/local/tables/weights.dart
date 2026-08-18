import 'package:drift/drift.dart';

import 'synced.dart';

/// The weight of the day.
///
/// One a day is the honest resolution: the product asks people to weigh in the
/// morning, and two readings in one day are noise rather than data.
class Weights extends Table with Synced {
  TextColumn get day => text().withLength(min: 10, max: 10)();
  DateTimeColumn get at => dateTime()();
  RealColumn get kg => real()();
}
