import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/day.dart';
import 'package:calvi/data/local/daos/diary_dao.dart';
import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/day_reader.dart';
import 'package:calvi/data/settings.dart';

/// Який день застосунок вважає сьогоднішнім.
///
/// Тут стояла дата, зашита в код: `DateTime(2026, 8, 15)`. Вона тримала числа
/// нерухомими під знімками екрана, поки застосунок малювався, і коштувала
/// більше, ніж здавалось. Стрічка днів завмерла на пʼятнадцятому серпні, а
/// записи весь цей час лягали в базу за справжнім годинником: людина писала
/// сніданок вісімнадцятого, а екран питав базу про пʼятнадцяте і показував
/// порожній день.
void main() {
  tearDown(() => dayClock = DateTime.now);

  test('нуль це справжнє сьогодні, а не дата з коду', () {
    final now = DateTime.now();
    final today = calendarDay(todayDate);

    expect(today.year, now.year);
    expect(today.month, now.month);
    expect(today.day, now.day);
  });

  test('екран і база кажуть про той самий день', () {
    /* Саме тут усе й ламалось. Ліворуч те, чим екран питає базу, праворуч те,
       чим база підписує новий запис. Ці два рядки мають збігатись завжди. */
    expect(DiaryDao.dayKey(calendarDay(todayDate)), DiaryDao.dayKey(DateTime.now()));
  });

  test('стрічка стоїть на тижні, у якому сьогодні', () {
    dayClock = () => DateTime(2026, 8, 18, 7, 19);

    expect(dayInfo(todayDate).day, 18);
    expect(dayInfo(todayDate).label, 'ВТ');
    expect(dayInfo(todayDate).full, '18 серпня');

    // Понеділок того тижня це сімнадцяте, а не десяте.
    expect(dayInfo(mondayOf(todayDate)).day, 17);
    expect(dayInfo(mondayOf(todayDate)).label, 'ПН');
  });

  test('новий день настає сам, без перезапуску застосунку', () {
    var now = DateTime(2026, 8, 18, 23, 59);
    dayClock = () => now;
    expect(dayInfo(todayDate).day, 18);

    // Хвилина по тому. Застосунок ніхто не закривав.
    now = DateTime(2026, 8, 19, 0, 1);
    expect(dayInfo(todayDate).day, 19, reason: 'сьогодні порахували один раз при запуску');
    expect(calendarDay(todayDate).day, 19);
  });

  test('перше число місяця не ламає тиждень назад', () {
    dayClock = () => DateTime(2026, 9, 1, 10);

    expect(dayInfo(todayDate).full, '1 вересня');
    expect(dayInfo(-1).full, '31 серпня');
    expect(dayInfo(-7).full, '25 серпня');
  });

  test('перехід на зимовий час не зсуває числа', () {
    /* Доба буває на годину довшою. Дні додавались як [Duration], тобто як
       абсолютні години, і в цю ніч доба плюс двадцять чотири години це двадцять
       третя того самого дня. Число виходило на одиницю меншим, і не в одному
       місці, а в усій стрічці. */
    dayClock = () => DateTime(2026, 10, 24, 12);

    expect(dayInfo(todayDate).day, 24);
    expect(dayInfo(1).day, 25);
    expect(dayInfo(2).day, 26);
    expect(dayInfo(3).day, 27);
  });

  test('записане сьогодні видно на сьогоднішньому екрані', () async {
    /* Наскрізна перевірка тієї самої розбіжності, тільки вже з базою. Запис
       підписується справжнім годинником, екран питає базу через `calendarDay`,
       і поки ці двоє розходились, людина писала сніданок і бачила порожній
       день. */
    final db = CalviDb(NativeDatabase.memory());
    addTearDown(db.close);

    await db.diaryDao.addMeal(slot: 'breakfast', name: 'Яєчня', kcal: 160);

    final day = await DayReader(db).watch(calendarDay(todayDate)).first;
    expect(day.meals, hasLength(1));
    expect(day.meals.single.title, 'Яєчня');
    expect(day.totals.kcal, 160);
  });

  test('прогноз цілі рахується від сьогодні', () {
    dayClock = () => DateTime(2026, 8, 18);

    expect(targetDay(1), '25 серпня');
    expect(targetDay(4), '15 вересня');
    expect(targetDate(4), '15 вересня 2026');
  });

  test('тиждень аналітики закінчується сьогодні', () {
    dayClock = () => DateTime(2026, 8, 18);

    expect(weekDates.last, todayDate);
    expect(dayInfo(weekDates.first).day, 12, reason: 'сім днів включно з сьогоднішнім');
    expect(dayInfo(weekDates.last).day, 18);
  });
}
