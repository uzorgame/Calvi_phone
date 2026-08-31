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
import 'tables/server_snapshots.dart';
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
    ServerSnapshots,
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
   * екран.
   *
   * **Обидва файли треба покласти в `web/` руками.** Тут стояло, що їх копіює
   * drift під час збірки, і це неправда: `flutter build web` не знає про них
   * нічого. У зібраному застосунку `GET /sqlite3.wasm` віддавав 404, drift
   * пробував знову і знову, і сторінка крутила той самий необроблений виняток
   * без кінця. Знайшлось це не з коду, а з мережевої панелі браузера.
   *
   * `sqlite3.wasm` береться з релізів пакета `sqlite3`, `drift_worker.js`
   * збирається командою `dart run drift_dev make-worker`. Версії обох мають
   * збігатись із версіями пакетів у `pubspec.lock`.
   *
   * Android це не зачіпає, і саме тому воно прожило так довго непоміченим. */
  static QueryExecutor _open() => driftDatabase(
    name: 'calvi',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );

  @override
  int get schemaVersion => 14;

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

      /* 3: полагодити дні, які приїхали з сервера повним часом.
       *
       * Сервер віддавав календарний день як `2026-08-18T00:00:00.000Z`, і кожен
       * запис, зроблений Норою, лягав під ключем, якого жоден екран не питає.
       * Сервер уже виправлено, але зіпсовані рядки лишились лежати в людей на
       * телефонах: без цього кроку вони так і не побачать свій сніданок. */
      if (from < 3) {
        for (final table in [
          'meals',
          'water_logs',
          'weights',
          'measurements',
          'workouts',
          'medication_takes',
        ]) {
          await customStatement(
            'update $table set day = substr(day, 1, 10) where length(day) > 10',
          );
        }
      }

      /* Памʼять Нори і звертання. Обидва в профілі, обидва новими колонками:
         на телефонах, які вже живуть, профіль лишається на місці, а поля
         додаються порожніми. */
      if (from < 4) {
        await m.addColumn(profile, profile.addressAs);
        await m.addColumn(profile, profile.memory);
      }

      // Розклад препарату: до цього він умів тільки години.
      if (from < 5) {
        await m.addColumn(medications, medications.schedule);
      }

      // Нагадування: доти вони жили тільки в памʼяті екрана.
      if (from < 6) {
        await m.addColumn(profile, profile.reminders);
      }

      /* Форма препарату, межі курсу і перелік полів вимірювань.
       *
       * Форму дістаємо з примітки, куди вона колись була вписана рядком
       * «form=tab», і примітку тут же чистимо: інакше людина побачила б цей
       * маркер як власний текст. Початком курсу для вже заведених препаратів
       * стає день оновлення: коли саме їх завели, ми не знаємо, а зробити
       * вигляд, що знаємо, гірше. */
      if (from < 7) {
        await m.addColumn(medications, medications.form);
        await m.addColumn(medications, medications.startDay);
        await m.addColumn(medications, medications.endDay);
        await m.addColumn(profile, profile.tracked);

        for (final f in ['tab', 'cap', 'drop', 'ml', 'shot']) {
          await customStatement("update medications set form = '$f' where note like '%form=$f%'");
        }
        await customStatement("update medications set note = null where note like 'form=%'");

        final today = DateTime.now();
        final key =
            '${today.year.toString().padLeft(4, '0')}-'
            '${today.month.toString().padLeft(2, '0')}-'
            '${today.day.toString().padLeft(2, '0')}';
        await customStatement("update medications set start_day = '$key'");
      }

      /* Пошта акаунта і дата його створення.
       *
       * Порожні для тих, хто вже увійшов до цього оновлення: сервер віддає їх
       * при вході, а не при синхронізації, тому заповняться вони наступним
       * входом. Профіль на це готовий і показує в такому разі саму пошту без
       * дати, а не рядок «невідомо». */
      if (from < 8) {
        await m.addColumn(syncMeta, syncMeta.email);
        await m.addColumn(syncMeta, syncMeta.joinedAt);
      }

      /* Мова інтерфейсу. Доти вона жила тільки в памʼяті екрана і злітала при
         кожному перезапуску: вибір, який не переживає закриття застосунку, це не
         вибір. Тим, хто вже користується, дістається `system`, і для української
         аудиторії на українських телефонах нічого не змінюється. */
      if (from < 9) {
        await m.addColumn(profile, profile.lang);
      }

      /* Ким увійшли. Порожньо для тих, хто вже всередині: сервер віддає це при
         вході, тому заповниться наступним. Доти картка показує пошту без значка
         провайдера, а не вигадує його. */
      if (from < 10) {
        await m.addColumn(syncMeta, syncMeta.provider);
      }

      /* Година початку курсу. Порожня для вже заведених препаратів, і це
         правильна відповідь: коли саме їх завели, ми не знаємо, а порожня
         година означає «день початку рахується цілком», тобто рівно те, як вони
         й поводились досі. */
      if (from < 11) {
        await m.addColumn(medications, medications.startTime);
      }

      /* Платний доступ. Порожньо, тобто «ні», для всіх, хто вже живе: підписки
         на той момент ще не існувало, і вигадувати її нікому не треба. Справжнє
         значення приїде з першою ж відповіддю сервера. */
      if (from < 12) {
        await m.addColumn(tokenState, tokenState.unlimited);
      }

      /* Закладка «чернетка чекає на це питання про вагу». Порожня для всіх
         наявних рядків: старі чернетки свого питання вже не памʼятають, і
         вигадати звʼязок заднім числом не можна. */
      if (from < 13) {
        await m.addColumn(meals, meals.askId);
      }

      /* Знімки серверних списків (книга рецептів, минулі розбори). Порожні на
         старті і це правильно: перше ж відкриття сторінки їх наповнить. */
      if (from < 14) {
        await m.createTable(serverSnapshots);
      }
    },
    beforeOpen: (details) async {
      // Foreign keys are off by default in SQLite, which is a footgun rather
      // than a feature.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
