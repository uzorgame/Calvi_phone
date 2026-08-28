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

  /// Платний доступ: лічильника немає взагалі.
  ///
  /// Не більше число, а відсутність числа. Людина, яка заплатила, не має
  /// рахувати репліки і не має бачити нагадування про те, що колись рахувала.
  BoolColumn get unlimited => boolean().withDefault(const Constant(false))();

  /// Коли прийдуть наступні сорок. Дата, а не зворотний відлік годин: тепер це
  /// число реєстрації, і воно те саме щомісяця.
  DateTimeColumn get nextGrantAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
