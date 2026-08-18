import 'package:drift/drift.dart';

import 'synced.dart';

/// The thread, kept locally so it opens instantly and reads offline.
class ChatMessages extends Table with Synced {
  /// user, nora, system.
  TextColumn get role => text()();

  /// The message itself. Not «text»: that is the name of Drift's own column
  /// builder, and a column may not shadow it.
  TextColumn get body => text()();
  DateTimeColumn get at => dateTime()();

  /// What the exchange cost, for the «where did my tokens go» question.
  IntColumn get spent => integer().withDefault(const Constant(0))();
}
