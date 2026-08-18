import 'package:drift/drift.dart';

import 'synced.dart';

/// One row per «taken», so the journal shows what was actually swallowed rather
/// than what was planned.
class MedicationTakes extends Table with Synced {
  TextColumn get medicationId => text()();
  TextColumn get day => text().withLength(min: 10, max: 10)();
  DateTimeColumn get at => dateTime()();

  /// Which scheduled hour this covers, or null for an unplanned one.
  TextColumn get plannedTime => text().nullable()();
}
