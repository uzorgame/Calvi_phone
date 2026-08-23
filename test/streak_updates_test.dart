import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/day.dart';
import 'package:calvi/data/day_stats.dart';
import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/day_reader.dart';
import 'package:calvi/data/settings.dart';

/// Серія слухає щоденник, а не свою памʼять.
///
/// Людина записала зайве помилково, або Нора зрозуміла її не так. І те, і те
/// виправляється: запис міняють або прибирають. Число серії має піти за
/// виправленням тієї ж миті, інакше воно каже неправду про день, який людина
/// щойно власноруч полагодила.
void main() {
  late CalviDb db;

  setUp(() => db = CalviDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// Профіль із рівною нормою, щоб числа в тесті читались очима.
  final me = initialSettings().copyWith(direction: Direction.lose, kcalManual: 2000);

  /// Підсумки так, як їх бачить екран: через той самий потік.
  Future<DayStats> stats() => DayReader(db).watchStats().first;

  Future<String> eat({required int offset, required int kcal}) => db.diaryDao.addMeal(
    slot: 'lunch',
    name: 'Обід',
    kcal: kcal,
    // Полудень свого дня: запис має лежати всередині доби, до якої належить.
    at: calendarDay(offset).add(const Duration(hours: 12)),
  );

  test('прибраний запис повертає серію, яку він обірвав', () async {
    await eat(offset: -1, kcal: 1900);
    await eat(offset: -2, kcal: 1900);
    expect((await stats()).streakOn(me), 2, reason: 'два вчорашні дні в межах вікна');

    // Записали зайве сьогодні: перебір необоротний, поки він у щоденнику.
    final oops = await eat(offset: 0, kcal: 2400);
    expect((await stats()).streakOn(me), 0, reason: 'перебір не обірвав серію');

    // Помилку виправили.
    await db.diaryDao.removeMeal(oops);
    expect((await stats()).streakOn(me), 2, reason: 'запис прибрано, а серія лишилась обірваною');
  });

  test('прибраний вчорашній запис так само перераховує серію', () async {
    await eat(offset: -1, kcal: 1900);
    final extra = await eat(offset: -1, kcal: 900);
    await eat(offset: -2, kcal: 1900);

    expect((await stats()).streakOn(me), 0, reason: '2800 за вчора це перебір');

    await db.diaryDao.removeMeal(extra);
    expect((await stats()).streakOn(me), 2, reason: 'вчора знову 1900, серія має бути ціла');
  });

  /* Той самий шлях, яким користується Нора, коли виправляє вагу страви: запис
     не додається наново, а міняється на місці. */
  test('виправлені числа запису рахуються новими', () async {
    await eat(offset: -2, kcal: 1900);
    final lunch = await eat(offset: -1, kcal: 2600);
    expect((await stats()).streakOn(me), 0);

    await db.diaryDao.patchServerMeal(id: lunch, name: 'Обід', kcal: 1900);
    expect((await stats()).streakOn(me), 2, reason: 'виправлення ваги не доїхало до серії');
  });
}
