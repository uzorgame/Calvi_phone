import 'package:drift/drift.dart';

/// Where this device got to.
///
/// One row. The cursor is the server's «seq», never a timestamp: two clocks and
/// one daylight saving change are enough to lose a week of records forever.
class SyncMeta extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();

  /// The last «seq» this device has seen from the server.
  IntColumn get cursor => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  /// Set when the account is signed in, so a fresh install can tell «my data»
  /// from «data left by whoever used this phone before me».
  TextColumn get userId => text().nullable()();

  /* The way back into this account. Kept in the app's own database rather than
     in the platform keystore for now: the file is inside the app sandbox, and a
     keystore is a dependency and a platform setup that buys little while the
     account is anonymous. It moves before the account carries a name. */
  TextColumn get accessToken => text().nullable()();
  TextColumn get refreshToken => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
