import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/local/database.dart';

/// The phone's own database, checked against a real SQLite rather than a mock.
///
/// What matters here is not that a row can be written: it is that every write
/// leaves the row marked for the server, that a delete leaves evidence, and
/// that the balance the server owns cannot be edited from a screen.
void main() {
  late CalviDb db;

  setUp(() => db = CalviDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('запис у щоденник позначається як не відправлений', () async {
    final at = DateTime(2026, 8, 17, 13, 5);
    final id = await db.diaryDao.addMeal(
      slot: 'lunch',
      name: 'Борщ з куркою',
      kcal: 210,
      grams: 300,
      protein: 14,
      fat: 20,
      carbs: 8,
      icon: 'soup',
      at: at,
    );

    final today = await db.diaryDao.mealsOn(at);
    expect(today.length, 1);
    expect(today.single.name, 'Борщ з куркою');
    expect(today.single.day, '2026-08-17', reason: 'запис ліг не в той календарний день');
    expect(today.single.dirty, isTrue, reason: 'новий запис не позначено на відправку');
    expect(today.single.seq, isNull, reason: 'сервер його ще не бачив, номера бути не може');

    final pending = await db.syncDao.pendingMeals();
    expect(pending.map((m) => m.id), contains(id));
  });

  test('видалення лишає слід, а не зникає', () async {
    final at = DateTime(2026, 8, 17, 8, 20);
    final id = await db.diaryDao.addMeal(slot: 'breakfast', name: 'Яєчня', kcal: 214, at: at);

    // Pretend the server took it, so the delete has something to undo.
    await db.syncDao.accept('meals', {id: 7}, DateTime.now());
    expect((await db.syncDao.pendingMeals()), isEmpty);

    await db.diaryDao.removeMeal(id);

    expect(await db.diaryDao.mealsOn(at), isEmpty, reason: 'видалене все ще в дні');
    final pending = await db.syncDao.pendingMeals();
    expect(pending.length, 1, reason: 'сервер не дізнається, що запис прибрали');
    expect(pending.single.deletedAt, isNotNull);
  });

  test('правка під час відправки не губиться', () async {
    final at = DateTime(2026, 8, 17, 9, 0);
    final id = await db.diaryDao.addMeal(slot: 'breakfast', name: 'Кава', kcal: 64, at: at);

    /* The request left at this moment; the row was edited after it. Accepting a
       version older than what is on the phone would mark the newer text as
       sent, and it would never leave the device. */
    final sentAt = DateTime.now().subtract(const Duration(seconds: 1));
    await db.diaryDao.removeMeal(id);
    await db.syncDao.accept('meals', {id: 3}, sentAt);

    expect(
      (await db.syncDao.pendingMeals()).length,
      1,
      reason: 'правку, зроблену під час запиту, зарахували як відправлену',
    );
  });

  test('день рахує воду, а вага одна на добу', () async {
    final at = DateTime(2026, 8, 17, 10, 0);
    await db.diaryDao.addWater(ml: 250, at: at);
    await db.diaryDao.addWater(ml: 300, at: at.add(const Duration(hours: 1)));
    expect(await db.diaryDao.watchWater(at).first, 550);

    await db.diaryDao.setWeight(kg: 78.6, at: at);
    await db.diaryDao.setWeight(kg: 78.4, at: at.add(const Duration(hours: 2)));
    final weight = await db.diaryDao.watchWeight(at).first;
    expect(weight?.kg, 78.4, reason: 'другий ранковий замір мав замінити перший');
    expect((await db.syncDao.pendingWeights()).length, 1, reason: 'вага роздвоїлась');
  });

  test('баланс токенів приходить із сервера і не редагується', () async {
    await db.syncDao.putTokens(balance: 30, nextGrantAt: DateTime(2026, 8, 18, 12));
    final state = await db.syncDao.watchTokens().first;

    expect(state?.balance, 30);
    expect(state?.nextGrantAt, DateTime(2026, 8, 18, 12));
    // The mirror carries no «dirty» at all: there is nothing here to send up.
    expect(db.tokenState.$columns.map((c) => c.name), isNot(contains('dirty')));
  });

  test('вихід з акаунта не лишає чужих записів', () async {
    await db.diaryDao.addMeal(slot: 'lunch', name: 'Борщ', kcal: 210);
    await db.syncDao.setCursor(42);
    await db.syncDao.setUser('user-1');

    await db.syncDao.wipe();

    expect(await db.diaryDao.mealsOn(DateTime.now()), isEmpty);
    final state = await db.syncDao.state();
    expect(state.cursor, 0, reason: 'курсор лишився від попереднього акаунта');
    expect(state.userId, isNull);
  });
}
