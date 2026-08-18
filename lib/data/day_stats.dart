import 'day.dart';
import 'fixtures.dart';
import 'measure.dart';
import 'settings.dart';

/// Про що екрани питають дні, яких вони не показують.
///
/// Стрічка тижня фарбує кружечки за днями назад, аналітика рахує по трьох
/// місяцях. Жоден із них не тримає цих днів у себе, і жоден не має ходити в базу
/// сам: обидва отримують уже зібрану картину і читають її синхронно, бо малюють
/// щокадрово.
///
/// Ключ це зсув дня від сьогодні, як і всюди в застосунку: 0 сьогодні, -1 учора.
class DayStats {
  const DayStats({
    required this.totals,
    required this.water,
    required this.weights,
    required this.demo,
  });

  /// Порожньо, поки база ще не відповіла. Не фікстури: показати чужий день
  /// замість свого гірше, ніж показати порожній.
  static const empty = DayStats(totals: {}, water: {}, weights: {}, demo: false);

  /// Демонстраційний тиждень із фікстур, для режиму «демо».
  factory DayStats.demo() => DayStats(
    totals: {for (final d in weekDates) d: totalsFor(d)},
    water: {for (final d in weekDates) d: dayFor(d).waterMl},
    weights: {
      for (final m in demoMeasures)
        if (m['weightKg'] != null) m.date: m['weightKg']!,
    },
    demo: true,
  );

  final Map<int, DayTotals> totals;
  final Map<int, int> water;

  /// Ранкова вага за днями, коли вона є. Порожньо там, де не важились.
  final Map<int, double> weights;

  /// Звідки взялись ці числа. Екранам це потрібно рівно для одного: не малювати
  /// «немає даних» там, де їх ще просто не встигли прочитати.
  final bool demo;

  static const _zero = DayTotals(kcal: 0, protein: 0, fat: 0, carbs: 0);

  DayTotals totalsOn(int date) => totals[date] ?? _zero;
  int waterOn(int date) => water[date] ?? 0;
  double? weightOn(int date) => weights[date];

  /// Чи знає застосунок про цей день хоч щось.
  bool has(int date) => (totals[date]?.kcal ?? 0) > 0 || (water[date] ?? 0) > 0;

  /// Як день читається в стрічці. Саме правило живе в [verdictFor]: воно одне
  /// на застосунок, бо кружечок у стрічці і будь-яка інша оцінка дня мають
  /// говорити те саме.
  DayState stateOn(
    int date, {
    required int goalKcal,
    required Direction direction,
    int burned = 0,
  }) => verdictFor(
    eaten: totalsOn(date).kcal,
    // Тренування піднімає норму дня: спалене повертається в неї, як і на
    // головній картці.
    norm: goalKcal + burned,
    direction: direction,
    logged: has(date),
    // Нуль це сьогодні, і сьогодні ще не закінчилось.
    finished: date < 0,
  );
}
