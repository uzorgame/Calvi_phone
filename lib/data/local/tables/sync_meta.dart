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

  /* Пошта акаунта Google, і більше про людину ми ззовні не знаємо: імені й фото
     ми не просимо. Порожньо тут це робочий стан, а не помилка: щоденник без
     входу працює повністю, просто живе на одному телефоні. */
  TextColumn get email => text().nullable()();

  /* Коли зʼявився обліковий запис. Не коли людина увійшла: запис існує з
     першого запуску, а вхід лише підписує його. Приходить із сервера, тому на
     новому телефоні лишається старою датою. */
  DateTimeColumn get joinedAt => dateTime().nullable()();

  /* Ким увійшли: `google` або `apple`. Порожньо, поки не входили.
   *
   * Приходить від сервера при вході, а не вгадується. Картка акаунта малює цим
   * значок і підпис, і вгадування тут неможливе в принципі: людина може дати
   * Apple свою справжню пошту, і тоді вона нічим не відрізняється від
   * гуглівської. Картка колись і показувала «Вхід через Google» тому, хто зайшов
   * через Apple. */
  TextColumn get provider => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
