import 'package:drift/drift.dart';

import 'synced.dart';

/// The allergen id comes from our own reference, the same one the app carries.
/// The warning has to fire on a code, not on a spelling: «фундук» and «лісовий
/// горіх» are the same nut.
class Allergies extends Table with Synced {
  TextColumn get allergenId => text()();

  /// Severe stops a record and says so. Mild warns in the text.
  BoolColumn get severe => boolean().withDefault(const Constant(false))();
}
