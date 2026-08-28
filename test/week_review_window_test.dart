import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/week.dart';

/// Вікно тижневого розбору і прогрес до нього.
///
/// Правила ті самі, що на сервері: з пʼятниці 18:00 до кінця неділі відчинено,
/// в будні прогрес-лінія. Помилка на годину тут не дрібниця: кнопка, за якою
/// зачинено, гірша за відсутню.
void main() {
  test('вікно відчиняється у пʼятницю о 18:00 і живе до кінця неділі', () {
    expect(reviewOpen(DateTime(2026, 8, 24, 9)), isFalse, reason: 'понеділок відчинений');
    expect(reviewOpen(DateTime(2026, 8, 26, 23, 59)), isFalse, reason: 'середа відчинена');
    expect(
      reviewOpen(DateTime(2026, 8, 28, 17, 59)),
      isFalse,
      reason: 'пʼятниця відчинилась зарано',
    );
    expect(reviewOpen(DateTime(2026, 8, 28, 18)), isTrue, reason: 'пʼятниця 18:00 зачинена');
    expect(reviewOpen(DateTime(2026, 8, 29, 0, 10)), isTrue, reason: 'субота зачинена');
    expect(reviewOpen(DateTime(2026, 8, 30, 23, 59)), isTrue, reason: 'неділя зачинилась зарано');
  });

  test('прогрес іде від понеділка 00:00 до пʼятниці 18:00', () {
    expect(reviewProgress(DateTime(2026, 8, 24, 0, 0)), 0);
    expect(reviewProgress(DateTime(2026, 8, 28, 18)), 1);

    // Середа опівдні: половина шляху з невеликим хвостом, не нуль і не одиниця.
    final mid = reviewProgress(DateTime(2026, 8, 26, 12));
    expect(mid, greaterThan(0.4));
    expect(mid, lessThan(0.6));

    // На вихідних лінії вже немає, але число не має вилазити за одиницю.
    expect(reviewProgress(DateTime(2026, 8, 30, 12)), 1);
  });

  test('тиждень зветься своїм понеділком', () {
    expect(reviewWeekKey(DateTime(2026, 8, 28)), '2026-08-24', reason: 'пʼятниця не свого тижня');
    expect(reviewWeekKey(DateTime(2026, 8, 30, 23)), '2026-08-24', reason: 'неділя втекла вперед');
    expect(reviewWeekKey(DateTime(2026, 8, 31, 0, 5)), '2026-08-31', reason: 'понеділок у старому');
    // Перехід місяця: понеділок 31 серпня тримає вересневі дні.
    expect(reviewWeekKey(DateTime(2026, 9, 2)), '2026-08-31');
  });
}
