import 'package:drift/drift.dart';

import 'synced.dart';

/// The regimen: what is taken and at which hours.
///
/// Doses are recorded, never calculated. The product does not do arithmetic on
/// medicine, and that is a product decision, not a missing feature.
class Medications extends Table with Synced {
  TextColumn get name => text()();
  TextColumn get amount => text().nullable()();
  TextColumn get note => text().nullable()();

  /// Wall clock times as «HH:MM», comma separated. A reminder belongs to the
  /// clock on the wall: 08:00 stays 08:00 after a flight.
  TextColumn get times => text().withDefault(const Constant(''))();
  BoolColumn get remind => boolean().withDefault(const Constant(true))();
}
