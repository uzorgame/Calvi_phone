import 'day.dart';
import 'fixtures.dart';
import 'goal_at.dart';
import 'measure.dart';
import 'nutrients.dart';
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
    this.nutrients = const {},
    required this.water,
    required this.weights,
    this.burned = const {},
    this.measures = const [],
    this.goals = const [],
    this.lastKcal,
    required this.demo,
  });

  /// Порожньо, поки база ще не відповіла. Не фікстури: показати чужий день
  /// замість свого гірше, ніж показати порожній.
  static const empty = DayStats(totals: {}, water: {}, weights: {}, measures: [], demo: false);

  /// Демонстраційний тиждень із фікстур, для режиму «демо».
  factory DayStats.demo() => DayStats(
    totals: {for (final d in weekDates) d: totalsFor(d)},
    /* Другий рівень теж із фікстур: без нього демонстраційний тиждень показував
       би пʼять знаків питання там, де в живому застосунку стоять числа. */
    nutrients: {
      for (final d in weekDates)
        d: nutrientsOver([for (final m in dayFor(d).meals) m.nutrients]).sum,
    },
    water: {for (final d in weekDates) d: dayFor(d).waterMl},
    burned: {for (final d in weekDates) d: dayFor(d).burned},
    weights: {
      for (final m in demoMeasures)
        if (m['weightKg'] != null) m.date: m['weightKg']!,
    },
    measures: demoMeasures,
    goals: demoGoals,
    demo: true,
  );

  final Map<int, DayTotals> totals;

  /* Другий рівень за днями: сума пʼяти чисел на кожен день окремо.
   *
   * Окремо від [totals], а не полем у них, і причина не в охайності. Макроси в
   * дні є завжди: страва без білка це нуль білка. Нутрієнти бувають невідомі, і
   * невідоме тут не нуль: усе, записане до появи підрахунку, цих чисел не має і
   * вже не матиме. Порожнє поле в [Nutrients] означає саме це, і зведення
   * тижня ділить середнє тільки на ті дні, де число є. */
  final Map<int, Nutrients> nutrients;

  final Map<int, int> water;

  /// Спалене на тренуваннях за днями. Без нього минулі дні судились би так,
  /// ніби людина не рухалась, а сьогоднішній інакше.
  final Map<int, int> burned;

  /// Ранкова вага за днями, коли вона є. Порожньо там, де не важились.
  final Map<int, double> weights;

  /// Заміри сантиметром, від найдавнішого. Тут вони живуть разом із вагою, бо
  /// стрічка вимірювань показує їх в одному ряду і питає про них одночасно.
  final List<Measure> measures;

  /// Історія цілей, від найдавнішої. Картка дня показує будь-який день, і дуга
  /// на ній міряє шлях до тієї цілі, яка діяла тоді, а не до сьогоднішньої.
  final List<GoalAt> goals;

  /* Ціль, яка діяла на цей день.
   *
   * Найпізніша з тих, що почались не пізніше за нього. Якщо день старший за
   * найпершу ціль, береться вона ж: до її появи шляху не було, а порожня картка
   * гірша за найдавнішу відому.
   *
   * Порожньо буває, поки історії немає взагалі: у застосунку, який щойно
   * оновився, вона зʼявиться з першим збереженням налаштувань або приїде
   * синхронізацією. Тоді картка бере поточну ціль, як і раніше. */
  GoalAt? goalOn(int date) {
    GoalAt? found;
    for (final g in goals) {
      if (g.from > date) continue;
      if (found == null || g.from >= found.from) found = g;
    }
    return found ?? (goals.isEmpty ? null : goals.first);
  }

  /// Звідки взялись ці числа. Екранам це потрібно рівно для одного: не малювати
  /// «немає даних» там, де їх ще просто не встигли прочитати.
  final bool demo;

  /* Скільки калорій в останньому сьогоднішньому записі, або порожньо, коли
     сьогодні ще нічого не записували.
   *
     Потрібне рівно одному місцю: розгорнутому живому запису на острівці. Назви
     страви тут немає навмисно: острівець видно й тому, кому він не
     призначений, а число саме по собі не каже нічого. */
  final int? lastKcal;

  static const _zero = DayTotals(kcal: 0, protein: 0, fat: 0, carbs: 0);

  DayTotals totalsOn(int date) => totals[date] ?? _zero;

  /// Пʼять чисел цього дня. Усі порожні там, де дня немає або він не рахований.
  Nutrients nutrientsOn(int date) => nutrients[date] ?? Nutrients.none;
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
