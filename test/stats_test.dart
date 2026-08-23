import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/day.dart';
import 'package:calvi/data/day_stats.dart';
import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/data/local/day_reader.dart';

/// Стрічка тижня і аналітика довго показували фікстури навіть на своєму акаунті:
/// екран виглядав робочим і брехав. Ці перевірки про те, що тепер там свої дні.
void main() {
  late CalviDb db;

  setUp(() => db = CalviDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  DateTime daysAgo(int n) => DateTime.now().subtract(Duration(days: n));

  test('підсумки збираються по днях, а не в купу', () async {
    await db.diaryDao.addMeal(slot: 'lunch', name: 'Борщ', kcal: 300, protein: 8, at: daysAgo(0));
    await db.diaryDao.addMeal(
      slot: 'dinner',
      name: 'Курка',
      kcal: 250,
      protein: 30,
      at: daysAgo(0),
    );
    await db.diaryDao.addMeal(slot: 'lunch', name: 'Суп', kcal: 180, at: daysAgo(2));

    final stats = await DayReader(db).watchStats().first;

    expect(stats.totalsOn(0).kcal, 550, reason: 'сьогоднішні записи не склались');
    expect(stats.totalsOn(0).protein, 38);
    expect(stats.totalsOn(-2).kcal, 180);
    expect(stats.totalsOn(-1).kcal, 0, reason: 'день без записів має лишатись порожнім');
  });

  test('вода і вага теж потрапляють у підсумки', () async {
    await db.diaryDao.addWater(ml: 250, at: daysAgo(0));
    await db.diaryDao.addWater(ml: 500, at: daysAgo(0));
    await db.diaryDao.setWeight(kg: 78.4, at: daysAgo(1));

    final stats = await DayReader(db).watchStats().first;

    expect(stats.waterOn(0), 750, reason: 'склянки не додались');
    expect(stats.weightOn(-1), closeTo(78.4, 0.001));
    expect(stats.weightOn(0), isNull, reason: 'вага зʼявилась там, де не важились');
  });

  test('видалений запис зникає з підсумків', () async {
    final id = await db.diaryDao.addMeal(slot: 'lunch', name: 'Помилка', kcal: 900);
    expect((await DayReader(db).watchStats().first).totalsOn(0).kcal, 900);

    await db.diaryDao.removeMeal(id);
    expect(
      (await DayReader(db).watchStats().first).totalsOn(0).kcal,
      0,
      reason: 'мʼяко видалений запис усе ще рахується',
    );
  });

  test('порожні підсумки не вигадують днів', () {
    expect(DayStats.empty.has(0), isFalse);
    expect(DayStats.empty.totalsOn(0).kcal, 0);
    expect(DayStats.empty.stateOn(-1, goalKcal: 2000, direction: Direction.lose), DayState.empty);
  });

  /// Учора, а не сьогодні: день, який ще триває, навмисно не оцінюється.
  const yesterday = -1;

  DayStats withKcal(int kcal) => DayStats(
    totals: {yesterday: DayTotals(kcal: kcal, protein: 0, fat: 0, carbs: 0)},
    water: const {},
    weights: const {},
    demo: false,
  );

  /* Кружечок над датою це вирок дню, і він залежить від того, куди людина йде.
     Раніше він просто порівнював з'їдене з нормою, і на схудненні голодний день
     світився зеленим так само, як вдалий. */
  group('вирок дню', () {
    test('на схудненні норма зелена, перебір червоний', () {
      expect(
        withKcal(2000).stateOn(yesterday, goalKcal: 2000, direction: Direction.lose),
        DayState.ok,
      );
      expect(
        withKcal(2100).stateOn(yesterday, goalKcal: 2000, direction: Direction.lose),
        DayState.over,
      );
    });

    test('на схудненні голод теж червоний', () {
      expect(
        withKcal(1600).stateOn(yesterday, goalKcal: 2000, direction: Direction.lose),
        DayState.ok,
        reason: 'чотириста під нормою це ще запас, а не голод',
      );
      expect(
        withKcal(1500).stateOn(yesterday, goalKcal: 2000, direction: Direction.lose),
        DayState.under,
        reason: 'день на півтори тисячі при нормі дві не має світитись зеленим',
      );
    });

    test('на наборі більше норми це і є ціль', () {
      expect(
        withKcal(2600).stateOn(yesterday, goalKcal: 2400, direction: Direction.gain),
        DayState.ok,
      );
      expect(
        withKcal(2400).stateOn(yesterday, goalKcal: 2400, direction: Direction.gain),
        DayState.ok,
      );
      expect(
        withKcal(2100).stateOn(yesterday, goalKcal: 2400, direction: Direction.gain),
        DayState.under,
      );
    });

    test('на утриманні запас працює в обидва боки', () {
      expect(
        withKcal(2300).stateOn(yesterday, goalKcal: 2000, direction: Direction.keep),
        DayState.ok,
      );
      expect(
        withKcal(2500).stateOn(yesterday, goalKcal: 2000, direction: Direction.keep),
        DayState.over,
      );
      expect(
        withKcal(1500).stateOn(yesterday, goalKcal: 2000, direction: Direction.keep),
        DayState.under,
      );
    });

    test('день, що триває, ще не судять', () {
      final today = DayStats(
        totals: const {0: DayTotals(kcal: 620, protein: 0, fat: 0, carbs: 0)},
        water: const {},
        weights: const {},
        demo: false,
      );

      expect(
        today.stateOn(0, goalKcal: 2000, direction: Direction.lose),
        DayState.pending,
        reason: 'о обіді «недоїв» це час доби, а не вирок',
      );

      final over = DayStats(
        totals: const {0: DayTotals(kcal: 2600, protein: 0, fat: 0, carbs: 0)},
        water: const {},
        weights: const {},
        demo: false,
      );

      expect(
        over.stateOn(0, goalKcal: 2000, direction: Direction.lose),
        DayState.over,
        reason: 'перебрати можна й до вечора, і це вже факт',
      );
    });

    test('тренування піднімає норму дня', () {
      expect(
        withKcal(2600).stateOn(yesterday, goalKcal: 2000, direction: Direction.lose),
        DayState.over,
      );
      expect(
        withKcal(2600).stateOn(yesterday, goalKcal: 2000, direction: Direction.lose, burned: 700),
        DayState.ok,
        reason: 'спалене на тренуванні не врахувалось',
      );
    });
  });
}
