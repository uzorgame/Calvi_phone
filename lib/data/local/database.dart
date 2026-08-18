import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/diary_dao.dart';
import 'daos/sync_dao.dart';
import 'tables/allergies.dart';
import 'tables/chat_messages.dart';
import 'tables/meals.dart';
import 'tables/measurements.dart';
import 'tables/medication_takes.dart';
import 'tables/medications.dart';
import 'tables/profile.dart';
import 'tables/sync_meta.dart';
import 'tables/tokens.dart';
import 'tables/water_logs.dart';
import 'tables/weights.dart';
import 'tables/workouts.dart';

part 'database.g.dart';

/// The phone's own database, and the app's source of truth for everything the
/// person wrote.
///
/// **Screens never wait for the network.** They read and write here; a separate
/// worker carries the changes to the server and brings back what other devices
/// wrote. That is what makes a record on a train feel the same as a record at
/// home, and it is the whole reason this file exists.
///
/// **The server owns money.** The token balance is mirrored here so the screen
/// has something to draw offline, and never sent back up.
@DriftDatabase(
  tables: [
    Meals,
    WaterLogs,
    Weights,
    Measurements,
    Workouts,
    Medications,
    MedicationTakes,
    Allergies,
    Profile,
    ChatMessages,
    TokenState,
    SyncMeta,
  ],
  daos: [DiaryDao, SyncDao],
)
class CalviDb extends _$CalviDb {
  CalviDb([QueryExecutor? executor]) : super(executor ?? _open());

  /* Де живе база.
   *
   * На телефоні це файл, і drift знаходить його сам. У браузері бази немає
   * взагалі, поки не сказати, звідки взяти sqlite та його робітника: без цього
   * рядка `driftDatabase` кидає «When compiling to the web, the web parameter
   * needs to be set», і застосунок падає ще до першого кадру, показуючи білий
   * екран. Обидва файли кладе в build/web сам drift під час збірки. */
  static QueryExecutor _open() => driftDatabase(
    name: 'calvi',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // The two single row tables exist from the start, so nothing has to check
      // whether they are there before reading them.
      await into(syncMeta).insert(const SyncMetaCompanion(), mode: InsertMode.insertOrIgnore);
      await into(tokenState).insert(const TokenStateCompanion(), mode: InsertMode.insertOrIgnore);
    },
    onUpgrade: (m, from, to) async {
      // 2: the device's own tokens, so a sync does not start with a sign in.
      if (from < 2) {
        await m.addColumn(syncMeta, syncMeta.accessToken);
        await m.addColumn(syncMeta, syncMeta.refreshToken);
      }
    },
    beforeOpen: (details) async {
      // Foreign keys are off by default in SQLite, which is a footgun rather
      // than a feature.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
