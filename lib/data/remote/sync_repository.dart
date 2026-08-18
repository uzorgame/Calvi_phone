import '../local/database.dart';
import 'api.dart';
import 'sync_mapping.dart';

/// One round of syncing, and the rules about when it is safe to stop.
///
/// **The screens never call this.** They write to the local database and carry
/// on; this runs behind them, and whether it succeeded changes nothing about
/// what the person sees. That is the difference between an app that works on a
/// train and one that spins.
class SyncRepository {
  SyncRepository(this.db, this.api);

  final CalviDb db;
  final CalviApi api;

  /// How many rounds one call will do before leaving the rest for the next one.
  /// A device that has been away for a season should not hold the phone hostage
  /// while it catches up.
  static const _maxRounds = 10;

  /// Makes sure this device has an account, and that the api knows its token.
  ///
  /// Returns false when there is no account and none could be made, which on a
  /// phone with no signal is the ordinary case rather than a failure.
  Future<bool> ensureAccount({String? deviceName}) async {
    final state = await db.syncDao.state();

    if (state.userId != null && state.accessToken != null) {
      api.token = state.accessToken;
      return true;
    }

    try {
      final account = await api.registerDevice(
        tz: DateTime.now().timeZoneName,
        device: deviceName,
      );
      await db.syncDao.setAccount(
        userId: account.userId,
        accessToken: account.accessToken,
        refreshToken: account.refreshToken,
      );
      await db.syncDao.putTokens(balance: account.balance);
      api.token = account.accessToken;
      return true;
    } on ApiFailure {
      return false;
    }
  }

  /// Pushes what this device wrote and applies what it has not seen.
  ///
  /// Returns what happened, because the caller may want to show it and the tests
  /// certainly want to check it.
  Future<SyncOutcome> run() async {
    if (!await ensureAccount()) return const SyncOutcome.offline();

    var pushed = 0;
    var pulled = 0;

    for (var round = 0; round < _maxRounds; round++) {
      final state = await db.syncDao.state();
      final outgoing = await _outgoing();

      final SyncAnswer answer;
      try {
        answer = await api.sync(cursor: state.cursor, changes: outgoing);
      } on ApiFailure catch (e) {
        // Nothing was written locally, so stopping here loses nothing: the rows
        // are still dirty and the cursor has not moved.
        return SyncOutcome(pushed: pushed, pulled: pulled, failure: e);
      }

      /* Accepted rows are marked clean against the moment the request left. A
         row edited while it was in flight stays dirty and goes next round. */
      final sentAt = DateTime.now();
      /* Сервер відповідає одним списком на всі таблиці, але ми знаємо, під якою
         таблицею відправляли кожен рядок, тому позначаємо саме там. Раніше цей
         список віддавали кожній таблиці по черзі, і з вісьмома таблицями це
         було б вісім проходів по всьому, що прийняли. */
      for (final entry in _byTable(outgoing, answer.accepted).entries) {
        await db.syncDao.accept(entry.key, entry.value, sentAt);
      }
      pushed += answer.accepted.length;

      await _apply(answer.changes);
      pulled += answer.changes.length;

      await db.syncDao.setCursor(answer.cursor);

      // Done when the server has nothing more and this device has nothing left.
      if (!answer.hasMore && outgoing.isEmpty) break;
      if (!answer.hasMore && answer.accepted.length == outgoing.length) break;
    }

    /* Профіль після щоденника і навмисно не разом із ним. Невдача тут не має
     * скасовувати вдалий обмін записами: людина побачить свої сніданки, навіть
     * якщо ціль цього разу не доїхала.
     *
     * Ловиться все, а не тільки [ApiFailure].
     *
     * Раніше тут стояв `on ApiFailure`, і будь-яка інша біда вилітала з `run` у
     * порожнечу: викликають його через `unawaited`, тому виняток нікуди не
     * потрапляв і ніде не з'являвся. Профіль міг не доїжджати місяцями, а
     * застосунок про це навіть не здогадувався. */
    Object? trouble;
    try {
      await _profile();
    } catch (e) {
      trouble = e;
    }

    return SyncOutcome(pushed: pushed, pulled: pulled, profileTrouble: trouble);
  }

  /// Ціль, темп, норма, вода і тема: один запис, і питання про нього одне.
  ///
  /// Тут немає ні курсора, ні сторінок, бо нема чого гортати. Є тільки час
  /// останньої зміни, і перемагає новіший, хай навіть він чужий: другий телефон
  /// тієї ж людини має таке саме право змінити ціль.
  Future<void> _profile() async {
    final mine = await (db.select(db.profile)..limit(1)).getSingleOrNull();

    // «Старт» ще не пройдено. Але профіль міг лишитись від іншого пристрою, і
    // тоді людині не треба відповідати на ті самі питання вдруге.
    if (mine == null) {
      final theirs = await api.profile();
      if (theirs != null) await _takeProfile(theirs, id: 'me');
      return;
    }

    if (!mine.dirty) {
      final theirs = await api.profile();
      final at = theirs == null ? null : DateTime.parse(theirs['updated_at'] as String).toLocal();
      if (at != null && at.isAfter(mine.updatedAt)) await _takeProfile(theirs!, id: mine.id);
      return;
    }

    await _takeProfile(await api.putProfile(profileToWire(mine)), id: mine.id);
  }

  Future<void> _takeProfile(Map<String, dynamic> wire, {required String id}) =>
      db.into(db.profile).insertOnConflictUpdate(profileFromWire(wire, id: id));

  /// Everything this device has changed, oldest first, capped so one request
  /// stays a request rather than a migration.
  Future<List<Map<String, dynamic>>> _outgoing() async {
    const perTable = 100;
    /* Порядок не випадковий: препарат має дістатись сервера раніше за прийом,
       бо прийом посилається на нього зовнішнім ключем. Решта таблиць одна від
       одної не залежить. */
    return [
      for (final row in await db.syncDao.pendingMeals(limit: perTable)) mealToChange(row),
      for (final row in await db.syncDao.pendingWater(limit: perTable)) waterToChange(row),
      for (final row in await db.syncDao.pendingWeights(limit: perTable)) weightToChange(row),
      for (final row in await db.syncDao.pendingMeasures(limit: perTable)) measureToChange(row),
      for (final row in await db.syncDao.pendingWorkouts(limit: perTable)) workoutToChange(row),
      for (final row in await db.syncDao.pendingMeds(limit: perTable)) medToChange(row),
      for (final row in await db.syncDao.pendingTakes(limit: perTable)) takeToChange(row),
      for (final row in await db.syncDao.pendingAllergies(limit: perTable)) allergyToChange(row),
    ];
  }

  /// Розкладає прийняте по таблицях, під якими воно відправлялось.
  Map<String, Map<String, int>> _byTable(
    List<Map<String, dynamic>> sent,
    Map<String, int> accepted,
  ) {
    final tableOf = {for (final c in sent) c['id'] as String: c['table'] as String};
    final out = <String, Map<String, int>>{};

    for (final e in accepted.entries) {
      final table = tableOf[e.key];
      if (table == null) continue;
      (out[table] ??= {})[e.key] = e.value;
    }
    return out;
  }

  /// Writes what the server sent. One transaction: a half applied page would
  /// move the cursor past rows that never landed.
  Future<void> _apply(List<Map<String, dynamic>> changes) async {
    if (changes.isEmpty) return;

    await db.transaction(() async {
      for (final change in changes) {
        switch (change['table'] as String) {
          case 'meals':
            await db.into(db.meals).insertOnConflictUpdate(mealFromChange(change));
          case 'water_logs':
            await db.into(db.waterLogs).insertOnConflictUpdate(waterFromChange(change));
          case 'weights':
            await db.into(db.weights).insertOnConflictUpdate(weightFromChange(change));
          case 'measurements':
            await db.into(db.measurements).insertOnConflictUpdate(measureFromChange(change));
          case 'workouts':
            await db.into(db.workouts).insertOnConflictUpdate(workoutFromChange(change));
          case 'medications':
            await db.into(db.medications).insertOnConflictUpdate(medFromChange(change));
          case 'medication_takes':
            await db.into(db.medicationTakes).insertOnConflictUpdate(takeFromChange(change));
          case 'allergies':
            await db.into(db.allergies).insertOnConflictUpdate(allergyFromChange(change));
          // A table this version does not know about is skipped rather than
          // fatal: an older app must survive a newer server.
        }
      }
    });
  }
}

/// What one run did.
class SyncOutcome {
  const SyncOutcome({
    required this.pushed,
    required this.pulled,
    this.failure,
    this.profileTrouble,
  });

  const SyncOutcome.offline()
    : pushed = 0,
      pulled = 0,
      failure = const ApiFailure.offline(),
      profileTrouble = null;

  final int pushed;
  final int pulled;
  final ApiFailure? failure;

  /// Що сталось із профілем, якщо сталось. Окремо від [failure], бо щоденник міг
  /// доїхати цілим: це різні невдачі й різні наслідки.
  final Object? profileTrouble;

  bool get ok => failure == null;

  /// Worth trying again shortly, as opposed to a request the server refused.
  bool get retry => failure?.temporary ?? false;
}
