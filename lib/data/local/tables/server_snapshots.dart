import 'package:drift/drift.dart';

/// The server's last word about a list, kept verbatim.
///
/// **Not synced, mirrored.** The same contract as `TokenState`, just for
/// lists: the recipe book and past week reviews belong to the server, and this
/// table keeps a copy of its latest answer so the screen has something to draw
/// the moment it opens, network or not.
///
/// Це знімок, а не журнал. Місцевих правок тут не буває: кожна зміна їде на
/// сервер, а сюди лягає лише те, що сервер відповів, і кожна наступна
/// відповідь замінює запис цілком. Саме тому сервер і телефон не бʼються за
/// ці дані: у знімка немає власної думки. Зміна акаунта стирає знімки разом
/// із рештою місцевого.
class ServerSnapshots extends Table {
  /// What this is a snapshot of: 'recipes', 'week_reviews'.
  TextColumn get key => text()();

  /// The server's list as JSON, one blob: його завжди читають цілим.
  TextColumn get body => text()();

  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}
