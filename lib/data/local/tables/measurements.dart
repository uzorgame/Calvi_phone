import 'package:drift/drift.dart';

import 'synced.dart';

/// Tape measurements. The spot is text rather than an enum: the list grows with
/// the product, and a schema migration for a new place on the body is silly.
class Measurements extends Table with Synced {
  TextColumn get day => text().withLength(min: 10, max: 10)();
  DateTimeColumn get at => dateTime()();
  TextColumn get part => text()();
  RealColumn get cm => real()();
}
