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
    this.burned = const {},
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
    burned: {for (final d in weekDates) d: dayFor(d).burned},
    weights: {
      for (final m in demoMeasures)
        if (m['weightKg'] != null) m.date: m['weightKg']!,
    },
    measures: demoMeasures,
    demo: true,
  );

  final Map<int, DayTotals> totals;
  final Map<int, int> water;

  /// Спалене на тренуваннях за днями. Без нього минулі дні судились би так,
  /// ніби людина не рухалась, а сьогоднішній інакше.
  final Map<int, int> burned;

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
  int burnedOn(int date) => burned[date] ?? 0;
  double? weightOn(int date) => weights[date];

  /// Зʼїдене мінус спалене: те, з чим день порівнюється з нормою.
  int netOn(int date) => totalsOn(date).kcal - burnedOn(date);

  /// Скільки днів поспіль людина завершила всередині вікна своєї цілі.
  ///
  /// **Сьогодні рахується, щойно воно у вікні.** Перший день із застосунком,
  /// норма набрана, і картка каже «1» того ж вечора, а не наступного ранку:
  /// людина зробила те, про що її просили, і чекати доби, щоб це визнати,
  /// означало б хвалити із запізненням. Наступного ранку число не падає: день
  /// ще триває, норму ще можна набрати, і вчорашня серія стоїть, доки
  /// сьогодні не скінчиться. Не набрали до півночі, і день, ставши вчорашнім,
  /// обриває серію сам.
  ///
  /// Перебір натомість обриває одразу. Він необоротний: зʼїдене не
  /// роззʼїдається, і день, який перебрав об одинадцятій ранку, до вечора
  /// вдалим уже не стане. Показувати після цього вчорашню серію означало б
  /// брехати людині цілий день.
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
    if (today != null &&
        dayOver(kcal: today.kcal, burned: burnedOn(todayDate), norm: norm, direction: s.direction)) {
      return 0;
    }

    // Сьогодні вже у вікні: воно перше в серії, ще до того, як скінчилось.
    var days = today != null &&
            dayHit(kcal: today.kcal, burned: burnedOn(todayDate), norm: norm, direction: s.direction)
        ? 1
        : 0;

    for (var at = -1; at > -400; at--) {
      final logged = totals[at];
      if (logged == null) break;
      if (!dayHit(kcal: logged.kcal, burned: burnedOn(at), norm: norm, direction: s.direction)) {
        break;
      }
      days++;
    }

    return days;
  }

  /// Чи знає застосунок про цей день хоч щось.
  bool has(int date) => (totals[date]?.kcal ?? 0) > 0 || (water[date] ?? 0) > 0;

  /// Як день читається в стрічці. Саме правило живе в [verdictFor]: воно одне
  /// на застосунок, бо кружечок у стрічці і будь-яка інша оцінка дня мають
  /// говорити те саме.
  DayState stateOn(int date, {required int goalKcal, required Direction direction}) => verdictFor(
    eaten: totalsOn(date).kcal,
    // Тренування зменшує зʼїдене, а норма стоїть на місці, як і на головній картці.
    burned: burnedOn(date),
    norm: goalKcal,
    direction: direction,
    logged: has(date),
    // Нуль це сьогодні, і сьогодні ще не закінчилось.
    finished: date < 0,
  );
}
