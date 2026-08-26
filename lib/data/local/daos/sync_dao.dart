import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';
import '../tables/allergies.dart';
import '../tables/chat_messages.dart';
import '../tables/meals.dart';
import '../tables/measurements.dart';
import '../tables/medication_takes.dart';
import '../tables/medications.dart';
import '../tables/profile.dart';
import '../tables/sync_meta.dart';
import '../tables/tokens.dart';
import '../tables/water_logs.dart';
import '../tables/weights.dart';
import '../tables/workouts.dart';

part 'sync_dao.g.dart';

/// What the sync worker needs, and nothing else.
///
/// Kept apart from [DiaryDao] on purpose: reading a day and reconciling with a
/// server are different jobs, and the screens have no business seeing the
/// second one.
@DriftAccessor(
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
)
class SyncDao extends DatabaseAccessor<CalviDb> with _$SyncDaoMixin {
  SyncDao(super.db);

  /// Where this device got to. The cursor is the server's number, never a time.
  Future<SyncMetaData> state() async {
    final row = await select(syncMeta).getSingleOrNull();
    if (row != null) return row;
    await into(syncMeta).insert(const SyncMetaCompanion());
    return select(syncMeta).getSingle();
  }

  Future<void> setCursor(int cursor) => (update(syncMeta)..where((s) => s.id.equals(1))).write(
    SyncMetaCompanion(cursor: Value(cursor), lastSyncAt: Value(DateTime.now())),
  );

  /// Which account this data belongs to. A fresh install signing in as somebody
  /// else must not adopt the previous person's meals.
  Future<void> setUser(String? userId) => (update(
    syncMeta,
  )..where((s) => s.id.equals(1))).write(SyncMetaCompanion(userId: Value(userId)));

  /// The account this device was given, and the way back into it.
  Future<void> setAccount({
    required String userId,
    required String accessToken,
    required String refreshToken,
    String? email,
    DateTime? joinedAt,
    String? provider,
  }) => (update(syncMeta)..where((s) => s.id.equals(1))).write(
    SyncMetaCompanion(
      userId: Value(userId),
      accessToken: Value(accessToken),
      refreshToken: Value(refreshToken),
      email: Value(email),
      joinedAt: Value(joinedAt),
      provider: Value(provider),
    ),
  );

  /* Вихід з акаунта, і тільки з нього.
   *
   * Щоденник лишається на місці: людина виходить, щоб перестати синхронізувати,
   * а не щоб усе стерти. Стирання це окрема дія з окремим питанням, і плутати
   * їх не можна, бо друга необоротна.
   *
   * `userId` теж чиститься: без нього наступний вхід іншим акаунтом не вважає
   * місцеві записи своїми. */
  Future<void> clearAccount() => (update(syncMeta)..where((s) => s.id.equals(1))).write(
    const SyncMetaCompanion(
      userId: Value(null),
      accessToken: Value(null),
      refreshToken: Value(null),
      email: Value(null),
      joinedAt: Value(null),
      provider: Value(null),
    ),
  );

  /// Everything this device has changed and the server has not acknowledged.
  ///
  /// Ordered by the time it changed, so a create reaches the server before the
  /// edit that follows it.
  Future<List<MealRow>> pendingMeals({int limit = 200}) =>
      (select(meals)
            ..where((m) => m.dirty.equals(true))
            ..orderBy([(m) => OrderingTerm(expression: m.updatedAt)])
            ..limit(limit))
          .get();

  Future<List<WaterLog>> pendingWater({int limit = 200}) =>
      (select(waterLogs)
            ..where((w) => w.dirty.equals(true))
            ..orderBy([(w) => OrderingTerm(expression: w.updatedAt)])
            ..limit(limit))
          .get();

  Future<List<Weight>> pendingWeights({int limit = 200}) =>
      (select(weights)
            ..where((w) => w.dirty.equals(true))
            ..orderBy([(w) => OrderingTerm(expression: w.updatedAt)])
            ..limit(limit))
          .get();

  Future<List<Measurement>> pendingMeasures({int limit = 200}) =>
      (select(measurements)
            ..where((m) => m.dirty.equals(true))
            ..orderBy([(m) => OrderingTerm(expression: m.updatedAt)])
            ..limit(limit))
          .get();

  Future<List<WorkoutRow>> pendingWorkouts({int limit = 200}) =>
      (select(workouts)
            ..where((w) => w.dirty.equals(true))
            ..orderBy([(w) => OrderingTerm(expression: w.updatedAt)])
            ..limit(limit))
          .get();

  Future<List<Medication>> pendingMeds({int limit = 200}) =>
      (select(medications)
            ..where((m) => m.dirty.equals(true))
            ..orderBy([(m) => OrderingTerm(expression: m.updatedAt)])
            ..limit(limit))
          .get();

  Future<List<MedicationTake>> pendingTakes({int limit = 200}) =>
      (select(medicationTakes)
            ..where((t) => t.dirty.equals(true))
            ..orderBy([(t) => OrderingTerm(expression: t.updatedAt)])
            ..limit(limit))
          .get();

  Future<List<Allergy>> pendingAllergies({int limit = 200}) =>
      (select(allergies)
            ..where((a) => a.dirty.equals(true))
            ..orderBy([(a) => OrderingTerm(expression: a.updatedAt)])
            ..limit(limit))
          .get();

  /* Чи лишилось хоч щось невідправлене.
   *
   * Питання ставить вхід перед перемиканням акаунта: стерти місцеву копію
   * можна лише тоді, коли кожен рядок уже доїхав на сервер, інакше стирання
   * зʼїло б те, чого більше ніде немає. Один обмін відвозить до сотні рядків
   * на таблицю і зупиняється, тому «обмін пройшов» ще не означає «все нагорі»,
   * і перевіряється саме залишок. */
  /// Лікує брудні рядки, чий ідентифікатор не є UUID.
  ///
  /// Сервер приймає лише UUID, і один такий рядок отруює всю чергу: кожен пуш
  /// повертається з відмовою, синхронізація стоїть, вхід неможливий, і людина
  /// бачить це як «сервер зламався». Звідки береться зіпсований ідентифікатор,
  /// байдуже: стара збірка, обірваний запис, майбутня помилка. Ліки одні й ті
  /// самі: видати рядку новий UUID. Це безпечно рівно тому, що сервер такий
  /// рядок ніколи не приймав, тобто під старим імʼям його ніде немає.
  ///
  /// Повертає, скільки рядків вилікувано.
  Future<int> repairIds() async {
    final uuidLike = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    var healed = 0;

    Future<void> heal<T extends Table, R>(
      TableInfo<T, R> table,
      Column<String> Function(T t) idOf,
      String Function(R row) idFrom, {
      Future<void> Function(String from, String to)? also,
    }) async {
      final rows = await select(table).get();
      for (final row in rows) {
        final id = idFrom(row);
        if (uuidLike.hasMatch(id)) continue;

        final fresh = const Uuid().v4();
        await (update(table)..where((t) => idOf(t).equals(id))).write(
          RawValuesInsertable({'id': Variable<String>(fresh), 'dirty': const Variable<bool>(true)}),
        );
        if (also != null) await also(id, fresh);
        healed++;
      }
    }

    await transaction(() async {
      await heal<Meals, MealRow>(meals, (t) => t.id, (r) => r.id);
      await heal<WaterLogs, WaterLog>(waterLogs, (t) => t.id, (r) => r.id);
      await heal<Weights, Weight>(weights, (t) => t.id, (r) => r.id);
      await heal<Measurements, Measurement>(measurements, (t) => t.id, (r) => r.id);
      await heal<Workouts, WorkoutRow>(workouts, (t) => t.id, (r) => r.id);
      /* Препарат тягне за собою прийоми: вони тримаються за його ідентифікатор,
         і залишити їх зі старим означає відірвати історію від курсу. */
      await heal<Medications, Medication>(
        medications,
        (t) => t.id,
        (r) => r.id,
        also: (from, to) async {
          await (update(medicationTakes)..where((t) => t.medicationId.equals(from))).write(
            RawValuesInsertable({
              'medication_id': Variable<String>(to),
              'dirty': const Variable<bool>(true),
            }),
          );
        },
      );
      await heal<MedicationTakes, MedicationTake>(medicationTakes, (t) => t.id, (r) => r.id);
      await heal<Allergies, Allergy>(allergies, (t) => t.id, (r) => r.id);
    });

    return healed;
  }

  Future<bool> hasDirty() async {
    for (final rows in [
      await pendingMeals(limit: 1),
      await pendingWater(limit: 1),
      await pendingWeights(limit: 1),
      await pendingMeasures(limit: 1),
      await pendingWorkouts(limit: 1),
      await pendingMeds(limit: 1),
      await pendingTakes(limit: 1),
      await pendingAllergies(limit: 1),
    ]) {
      if (rows.isNotEmpty) return true;
    }
    return false;
  }

  /// Таблиці, які їздять, за іменем на дроті.
  ///
  /// Потрібні там, де таблиця відома лише рядком: у прийманні відповіді сервера
  /// і в записі того, що приїхало. Список закритий, і чужого імені сюди не
  /// підставити.
  Map<String, TableInfo<Table, dynamic>> get syncedTables => {
    'meals': meals,
    'water_logs': waterLogs,
    'weights': weights,
    'measurements': measurements,
    'workouts': workouts,
    'medications': medications,
    'medication_takes': medicationTakes,
    'allergies': allergies,
  };

  /// Marks rows as accepted, with the number the server gave each of them.
  ///
  /// Only rows that have not changed again in the meantime: an edit made while
  /// the request was in flight must stay dirty, or it is lost.
  ///
  /// The server answers for every table at once, so each of these is handed the
  /// whole map and picks out its own rows by id.
  /// Один метод на всі таблиці: раніше їх було по одному на кожну, і на восьмій
  /// це стало вісьмома місцями, де можна забути умову з часом. Ім'я таблиці
  /// приходить не ззовні, а з [syncedTables], тому підставити чуже не вийде.
  Future<void> accept(String table, Map<String, int> seqById, DateTime sentAt) async {
    if (seqById.isEmpty) return;
    final info = syncedTables[table];
    if (info == null) return;

    await batch((b) {
      for (final e in seqById.entries) {
        b.customStatement(
          'update ${info.actualTableName} set seq = ?, dirty = 0 '
          'where id = ? and updated_at <= ?',
          [e.value, e.key, sentAt.millisecondsSinceEpoch ~/ 1000],
        );
      }
    });
  }

  /// The balance as the server last reported it. Mirrored, never sent up.
  Future<void> putTokens({required int balance, DateTime? nextGrantAt}) =>
      (update(tokenState)..where((t) => t.id.equals(1))).write(
        TokenStateCompanion(
          balance: Value(balance),
          nextGrantAt: Value(nextGrantAt),
          syncedAt: Value(DateTime.now()),
        ),
      );

  Stream<TokenStateData?> watchTokens() => select(tokenState).watchSingleOrNull();

  /* «Видалити дані»: місцева половина чистого аркуша.
   *
   * Щоденник і розмова йдуть, а все, що робить акаунт акаунтом, лишається:
   * вхід, курсор, токени, профіль, алергії. Курсор не скидається навмисно:
   * сервер погасив ті самі рядки з новими номерами, і наступний обмін просто
   * привезе надгробки поверх уже порожнього. */
  Future<void> clearDiary() async {
    await transaction(() async {
      await delete(meals).go();
      await delete(waterLogs).go();
      await delete(weights).go();
      await delete(measurements).go();
      await delete(workouts).go();
      await delete(medicationTakes).go();
      await delete(medications).go();
      await delete(chatMessages).go();
    });
  }

  /// Everything this person wrote, gone. Used by «вийти» on a shared phone and
  /// by «видалити акаунт»: the local copy has to go with the account.
  Future<void> wipe() async {
    await transaction(() async {
      /* Listed rather than looped over `allTables`: the two single row tables
         are reset below instead of emptied, and a loop that took everything
         would take them too. */
      await delete(meals).go();
      await delete(waterLogs).go();
      await delete(weights).go();
      await delete(measurements).go();
      await delete(workouts).go();
      await delete(medicationTakes).go();
      await delete(medications).go();
      await delete(allergies).go();
      await delete(profile).go();
      await delete(chatMessages).go();
      await (update(syncMeta)..where((s) => s.id.equals(1))).write(
        const SyncMetaCompanion(cursor: Value(0), userId: Value(null)),
      );
      await (update(
        tokenState,
      )..where((t) => t.id.equals(1))).write(const TokenStateCompanion(balance: Value(0)));
    });
  }
}
