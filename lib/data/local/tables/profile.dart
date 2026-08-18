import 'package:drift/drift.dart';

import 'synced.dart';

/// One row, the person's own settings and goal.
///
/// Columns rather than a settings blob: the daily norm is calculated from these
/// fields on both sides, and a blob cannot be checked by either.
class Profile extends Table with Synced {
  TextColumn get sex => text().withDefault(const Constant('m'))();
  IntColumn get birthYear => integer().nullable()();
  IntColumn get heightCm => integer().nullable()();

  RealColumn get goalStartKg => real().nullable()();
  RealColumn get targetKg => real().nullable()();
  TextColumn get direction => text().withDefault(const Constant('lose'))();
  RealColumn get pace => real().withDefault(const Constant(0.5))();
  RealColumn get activity => real().withDefault(const Constant(1.55))();

  /// Null means «count it», a number means the person overrode it.
  IntColumn get kcalManual => integer().nullable()();
  IntColumn get proteinG => integer().nullable()();
  IntColumn get fatG => integer().nullable()();
  IntColumn get carbsG => integer().nullable()();
  IntColumn get waterMl => integer().withDefault(const Constant(2000))();

  TextColumn get theme => text().withDefault(const Constant('system'))();
}
