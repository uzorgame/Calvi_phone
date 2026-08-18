import 'package:drift/drift.dart';

import 'synced.dart';

/// A glass, a bottle, a cup. Kept as separate entries rather than a running
/// total for the day, because the day's total is a sum and an entry is a fact.
class WaterLogs extends Table with Synced {
  TextColumn get day => text().withLength(min: 10, max: 10)();
  DateTimeColumn get at => dateTime()();
  IntColumn get ml => integer()();
}
