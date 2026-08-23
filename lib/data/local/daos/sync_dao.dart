import 'package:drift/drift.dart';

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
  }) => (update(syncMeta)..where((s) => s.id.equals(1))).write(
    SyncMetaCompanion(
      userId: Value(userId),
      accessToken: Value(accessToken),
      refreshToken: Value(refreshToken),
      email: Value(email),
      joinedAt: Value(joinedAt),
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
