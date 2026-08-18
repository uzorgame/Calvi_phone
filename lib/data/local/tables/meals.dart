import 'package:drift/drift.dart';

import 'synced.dart';

/// One line in the day: «Яєчня з двох яєць, 214».
///
/// Flat on purpose. The interface never shows a dish inside a dish, and a table
/// of ingredients that no screen reads is a table that rots.
// The generated row is «MealRow»: «Meal» is already the app's own domain
// object, and two classes with one name is a file that has to be read twice.
@DataClassName('MealRow')
class Meals extends Table with Synced {
  /// The local calendar day it belongs to, as yyyy-mm-dd. Stored apart from the
  /// instant so that moving to another timezone does not move last week's
  /// breakfasts to another hour.
  TextColumn get day => text().withLength(min: 10, max: 10)();
  DateTimeColumn get at => dateTime()();
  IntColumn get tzOffsetMin => integer().withDefault(const Constant(0))();

  /// breakfast, lunch, dinner, snack.
  TextColumn get slot => text()();

  TextColumn get name => text()();

  /// What the food reference knows it by, which is what keeps «борщ» at the same
  /// numbers every time. Null while nothing matched.
  TextColumn get canonicalName => text().nullable()();
  TextColumn get icon => text().withDefault(const Constant('plate'))();

  RealColumn get grams => real().nullable()();
  IntColumn get kcal => integer()();
  RealColumn get proteinG => real().withDefault(const Constant(0))();
  RealColumn get fatG => real().withDefault(const Constant(0))();
  RealColumn get carbsG => real().withDefault(const Constant(0))();

  /// manual, chat, photo, barcode, copy. Decides whether it cost a token.
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get note => text().nullable()();
}
