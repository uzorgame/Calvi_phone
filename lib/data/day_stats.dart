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
    this.measures = const [],
    required this.demo,
  });

  /// Порожньо, поки база ще не відповіла. Не фікстури: показати чужий день
  /// замість свого гірше, ніж показати порожній.
  static const empty = DayStats(totals: {}, water: {}, weights: {}, measures: [], demo: false);

  /// Демонстраційний тиждень із фікстур, для режиму «демо».
  factory DayStats.demo() => DayStats(
    totals: {for (final d in weekDates) d: totalsFor(d)},
    water: {for (final d in weekDates) d: dayFor(d).waterMl},
    weights: {
      for (final m in demoMeasures)
        if (m['weightKg'] != null) m.date: m['weightKg']!,
    },
    measures: demoMeasures,
    demo: true,
  );

  final Map<int, DayTotals> totals;
  final Map<int, int> water;

  /// Ранкова вага за днями, коли вона є. Порожньо там, де не важились.
  final Map<int, double> weights;

  /// Заміри сантиметром, від найдавнішого. Тут вони живуть разом із вагою, бо
  /// стрічка вимірювань показує їх в одному ряду і питає про них одночасно.
  final List<Measure> measures;

  /// Звідки взялись ці числа. Екранам це потрібно рівно для одного: не малювати
  /// «немає даних» там, де їх ще просто не встигли прочитати.
  final bool demo;

  static const _zero = DayTotals(kcal: 0, protein: 0, fat: 0, carbs: 0);

  DayTotals totalsOn(int date) => totals[date] ?? _zero;
  int waterOn(int date) => water[date] ?? 0;
  double? weightOn(int date) => weights[date];

  /// Скільки днів поспіль людина завершила всередині вікна своєї цілі.
  ///
  /// **Сьогодні вміє обірвати серію, але не вміє її подовжити**, і це не
  /// половинчастість, а різниця між двома різними подіями. Перебір необоротний:
  /// зʼїдене не роззʼїдається, і день, який перебрав об одинадцятій ранку, до
  /// вечора вдалим уже не стане. Показувати після цього вчорашню серію означало
  /// б брехати людині цілий день. Недобір оборотний, тому доки перебору немає,
  /// сьогодні просто мовчить: інакше число стрибало б після кожного обіду.
  ///
  /// День, у якому не записано нічого, обриває серію так само, як перебір. Це
  /// не витриманий день, а забутий, і робити вигляд, що людина його провела в
  /// нормі, означало б хвалити за порожній щоденник.
  ///
  /// Глибина обмежена тим, що привезла база: `watchStats` бере рік, і довша
  /// серія просто впреться в цю межу. Показати менше, ніж було, чесніше, ніж
  /// домалювати дні, про які ми нічого не знаємо.
  int streakOn(SettingsState s) {
    final norm = dailyKcal(s);

    final today = totals[todayDate];
    if (today != null && dayOver(kcal: today.kcal, norm: norm, direction: s.direction)) return 0;

    var days = 0;

    for (var at = -1; at > -400; at--) {
      final logged = totals[at];
      if (logged == null) break;
      if (!dayHit(kcal: logged.kcal, norm: norm, direction: s.direction)) break;
      days++;
    }

    return days;
  }

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
