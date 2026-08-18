import 'package:drift/drift.dart';

/// What every row that travels to the server carries.
///
/// **The id is made here, on the phone.** An entry written on a train keeps its
/// identity when it finally reaches the server, so a retry cannot turn one
/// breakfast into two.
///
/// **Deletes are soft.** A device that was offline for a week has to learn that
/// something is gone, and a row that is simply missing teaches it nothing.
///
/// **Dirty is the outbox.** Rather than a second table of pending changes, the
/// row itself says whether the server has seen this version of it. One less
/// table to keep in step, and no way for the queue and the data to disagree.
mixin Synced on Table {
  TextColumn get id => text()();

  /// When this device last changed the row. Not a sync cursor: the server's
  /// [seq] is the cursor, because a phone clock is not evidence.
  DateTimeColumn get updatedAt => dateTime()();

  /// Set instead of deleting the row.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// True while the server has not acknowledged this version.
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  /// The number the server gave this version, null while it has never been sent.
  IntColumn get seq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
