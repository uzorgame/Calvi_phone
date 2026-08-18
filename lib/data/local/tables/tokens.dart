import 'package:drift/drift.dart';

/// What the server last said about the balance.
///
/// **Not synced, mirrored.** The balance is money-like, so the server owns it:
/// this table is a copy so the screen has something to draw offline, and it is
/// overwritten by every answer the server gives. Nothing here is ever sent up.
class TokenState extends Table {
  /// Always 1. One row, replaced rather than appended to.
  IntColumn get id => integer().withDefault(const Constant(1))();

  IntColumn get balance => integer().withDefault(const Constant(0))();

  /// When the next two arrive. The countdown on screen is drawn from this, but
  /// the grant itself is the server's to make.
  DateTimeColumn get nextGrantAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
