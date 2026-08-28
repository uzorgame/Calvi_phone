/// Everything the settings screens edit, in one place.
library;

import 'measure.dart';
import 'repeat.dart';

import 'day.dart';
import 'fixtures.dart';

enum Sex { m, f, x }

/* `aquarelle` and `dawn` are the light theme with weather on the ground: same
   ink, same cards, only the page behind everything changes. They were picked
   off the welcome screen candidates, where the two grounds looked too good to
   throw away with the rest. */
enum AppTheme { light, aquarelle, dawn, dark, system }

/// Мова інтерфейсу.
///
/// `system` це не «жодна» і не середнє між двома: це відмова вибирати за людину.
/// Застосунок бере мову телефона, якщо вона в нас є, і англійську, якщо немає.
/// Саме тому англійська стоїть першою в `supportedLocales`: Flutter бере першу
/// підтримувану як запасну.
enum Lang { system, uk, en }

enum Direction { lose, keep, gain }

class Allergy {
  const Allergy({required this.id, required this.severe});

  /// Code from the allergen reference, never a typed-in name.
  final String id;
  final bool severe;
}

/// One thing the assistant remembers about the user.
class Memo {
  const Memo({required this.id, required this.text, required this.pinned});

  final String id;
  final String text;

  /// Pinned memories survive context compaction; the rest can age out.
  final bool pinned;

  Memo toggled() => Memo(id: id, text: text, pinned: !pinned);
}

/// What the reminder is FOR. A bare bell that says nothing gets switched off.
enum ReminderKind { meal, water, meds, workout, weigh, summary }

class Reminder {
  const Reminder({
    required this.id,
    required this.kind,
    required this.label,
    required this.times,
    required this.on,
    this.repeat = const DailyRepeat(),
  });

  final String id;
  final ReminderKind kind;

  /// What exactly, within the kind: «Сніданок», «Після роботи».
  final String label;

  /* Години, а не одна година.
   *
   * Ліки пʼють двічі на день, воду пʼють увесь день, і робити з цього два
   * окремі нагадування означає змусити людину заводити те саме двічі й вимикати
   * теж двічі. */
  final List<String> times;

  /// Як часто. Спільна модель із препаратами: питання там і тут одне.
  final Repeat repeat;

  final bool on;

  Reminder copyWith({List<String>? times, Repeat? repeat, String? label, bool? on}) => Reminder(
    id: id,
    kind: kind,
    label: label ?? this.label,
    times: times ?? this.times,
    repeat: repeat ?? this.repeat,
    on: on ?? this.on,
  );
}

/* Вид нагадування і його значок.
 *
 * Слів тут немає навмисно: назва й підказка живуть у `l10n/labels.dart`, як і
 * все інше, що шар даних називає кодом, а екран показує словами. */
class ReminderKindInfo {
  const ReminderKindInfo({required this.id, required this.icon});

  final ReminderKind id;
  final String icon;
}

const reminderKinds = <ReminderKindInfo>[
  ReminderKindInfo(id: ReminderKind.meal, icon: 'utensils'),
  ReminderKindInfo(id: ReminderKind.water, icon: 'drink'),
  ReminderKindInfo(id: ReminderKind.meds, icon: 'pill'),
  ReminderKindInfo(id: ReminderKind.workout, icon: 'gym'),
  ReminderKindInfo(id: ReminderKind.weigh, icon: 'scale'),
  ReminderKindInfo(id: ReminderKind.summary, icon: 'chart'),
];

class SettingsState {
  const SettingsState({
    required this.sex,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.targetKg,
    required this.goalStartKg,
    required this.direction,
    required this.pace,
    required this.activity,
    required this.kcalManual,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.waterMl,
    required this.allergies,
    required this.memory,
    this.addressAs,
    this.tracked = defaultTracked,
    required this.reminders,
    required this.analytics,
    required this.crash,
    required this.theme,
    required this.lang,
  });

  final Sex sex;
  final int age;
  final int heightCm;
  final double weightKg;
  final double targetKg;

  /// Weight at the moment this goal was set. Fixed for the goal's life so the
  /// progress ring cannot jump when the scale moves.
  final double goalStartKg;
  final Direction direction;

  /// Kilograms per week, always positive; direction decides the sign.
  final double pace;
  final double activity;

  /// Manual override of the calculated norm, or null while it is calculated.
  final int? kcalManual;

  final int protein;
  final int fat;
  final int carbs;
  final int waterMl;
  final List<Allergy> allergies;
  final List<Memo> memory;

  /// Як Нора звертається до людини. Порожньо, поки та не назвалась.
  final String? addressAs;

  /* Які поля вимірювань людина веде.
   *
   * Жило тільки в памʼяті екрана: людина додавала груди й біцепс, місяць їх
   * записувала, а після перезапуску картка показувала знову вагу й талію. Самі
   * заміри при цьому лишались у базі, тобто дані були цілі, а побачити їх було
   * ніде. */
  final List<String> tracked;
  final List<Reminder> reminders;
  final bool analytics;
  final bool crash;

  /// «Тема пристрою» follows the system; the other two fix the choice.
  final AppTheme theme;

  /// Interface language. There is no translation yet, so the choice is only
  /// recorded, against the day there is one.
  final Lang lang;

  SettingsState copyWith({
    Sex? sex,
    int? age,
    int? heightCm,
    double? weightKg,
    double? targetKg,
    double? goalStartKg,
    Direction? direction,
    double? pace,
    double? activity,
    int? kcalManual,
    bool clearKcalManual = false,
    int? protein,
    int? fat,
    int? carbs,
    int? waterMl,
    List<Allergy>? allergies,
    List<Memo>? memory,
    String? addressAs,
    List<String>? tracked,
    List<Reminder>? reminders,
    bool? analytics,
    bool? crash,
    AppTheme? theme,
    Lang? lang,
  }) => SettingsState(
    sex: sex ?? this.sex,
    age: age ?? this.age,
    heightCm: heightCm ?? this.heightCm,
    weightKg: weightKg ?? this.weightKg,
    targetKg: targetKg ?? this.targetKg,
    goalStartKg: goalStartKg ?? this.goalStartKg,
    direction: direction ?? this.direction,
    pace: pace ?? this.pace,
    activity: activity ?? this.activity,
    kcalManual: clearKcalManual ? null : (kcalManual ?? this.kcalManual),
    protein: protein ?? this.protein,
    fat: fat ?? this.fat,
    carbs: carbs ?? this.carbs,
    waterMl: waterMl ?? this.waterMl,
    allergies: allergies ?? this.allergies,
    memory: memory ?? this.memory,
    addressAs: addressAs ?? this.addressAs,
    tracked: tracked ?? this.tracked,
    reminders: reminders ?? this.reminders,
    analytics: analytics ?? this.analytics,
    crash: crash ?? this.crash,
    theme: theme ?? this.theme,
    lang: lang ?? this.lang,
  );
}

/// З чого починається справжній перший запуск.
///
/// Не те саме, що [initialSettings], і різниця тут принципова. Демо показує
/// готову людину: її зріст, її вагу, її алергію на фундук і чотири спогади
/// помічника про неї. Це правильно для вітрини і неправильно для того, хто
/// щойно встановив застосунок: спогади про чужі звички і чужа алергія у своєму
/// профілі це не «заповнено наперед», а неправда.
///
/// Тілесні числа тут теж стоять, але вони живуть рівно до кінця «Старту», який
/// перепише їх усі. Порожні насправді тільки ті списки, які має наповнити сама
/// людина.
SettingsState emptySettings() => initialSettings().copyWith(allergies: const [], memory: const []);

/// Демонстраційна людина: те, що видно у вітрині і в демо-режимі застосунку.
SettingsState initialSettings() => SettingsState(
  sex: Sex.m,
  age: 26,
  heightCm: 183,
  weightKg: 78.6,
  targetKg: 74,
  goalStartKg: 81,
  direction: Direction.lose,
  pace: 0.5,
  activity: 1.55,
  kcalManual: null,
  protein: 135,
  fat: 66,
  carbs: 311,
  waterMl: 2200,
  allergies: const [Allergy(id: 'hazelnut', severe: true)],
  memory: [
    Memo(id: 'm1', text: demoDish('Не їсть свинину', 'Does not eat pork'), pinned: true),
    Memo(
      id: 'm2',
      text: demoDish(
        'Тренується вранці, снідає після тренування',
        'Trains in the morning, has breakfast after',
      ),
      pinned: false,
    ),
    Memo(
      id: 'm3',
      text: demoDish('Каву пʼє без цукру', 'Takes coffee without sugar'),
      pinned: false,
    ),
    Memo(
      id: 'm4',
      text: demoDish(
        'Вдома готує сам, на роботі бере готове',
        'Cooks at home, buys ready-made at work',
      ),
      pinned: false,
    ),
  ],
  reminders: const [],
  analytics: true,
  crash: true,
  /* Dawn on a first run, whatever the phone is set to.
     A first run is the one moment the app has no idea who it is talking to, and
     it should look the way it was designed rather than the way the device
     happens to be set. Following the system here means half the people who open
     it see a theme nobody chose for them.

     Саме «Світанок», а не рівний світлий: це той самий ґрунт, яким застосунок
     показується на calvi.uk, і перше відкриття має впізнаватись як та сама річ
     з сайту, а не її блідіша сестра. Тепле світло живе лише на ґрунті сторінки,
     картки і текст лишаються тими ж, тож ціни в читабельності це не має.
     Обраної теми це не чіпає: вибір зберігається в профілі і переживає
     перезапуск, замовчування працює рівно до першого рішення людини. */
  theme: AppTheme.dawn,
  lang: Lang.system,
);

/// Рівень активності: сам множник, без слів. Назва його в `l10n/labels.dart`.
class ActivityLevel {
  const ActivityLevel({required this.v});

  final double v;
}

/// What the age and height drums offer, at the start and in the profile.
final ages = List.generate(87, (i) => i + 14);
final heights = List.generate(91, (i) => i + 130);

const activityLevels = <ActivityLevel>[
  ActivityLevel(v: 1.2),
  ActivityLevel(v: 1.375),
  ActivityLevel(v: 1.55),
  ActivityLevel(v: 1.725),
  ActivityLevel(v: 1.9),
];

/// The assistant is Nora. Swapping personas is not on the table yet.
const assistantName = 'Nora';

/// Basal metabolic rate, Mifflin-St Jeor.
double bmr(SettingsState s) {
  final base = 10 * s.weightKg + 6.25 * s.heightCm - 5 * s.age;
  if (s.sex == Sex.m) return base + 5;
  if (s.sex == Sex.f) return base - 161;
  // Neither formula fits, so take the midpoint rather than pick one at random.
  return base - 78;
}

/// Daily norm. Calculated from the body and the goal, never asked for as a bare
/// number: most people do not know theirs, and a value invented to get past a
/// form poisons every figure downstream.
int calcKcal(SettingsState s) {
  final tdee = bmr(s) * s.activity;
  // 7700 kcal to a kilogram, spread over a week.
  final shift = s.pace * 7700 / 7;
  final raw = switch (s.direction) {
    Direction.lose => tdee - shift,
    Direction.gain => tdee + shift,
    Direction.keep => tdee,
  };
  // Nobody is sent below the floor, whatever the arithmetic says.
  final floor = s.sex == Sex.f ? 1200.0 : 1500.0;
  return (raw < floor ? floor : raw) ~/ 10 * 10;
}

int dailyKcal(SettingsState s) => s.kcalManual ?? calcKcal(s);

/// Weeks to the target at the chosen pace.
int weeksToTarget(SettingsState s) {
  if (s.direction == Direction.keep || s.pace <= 0) return 0;
  return ((s.weightKg - s.targetKg).abs() / s.pace).ceil();
}

/// Коли ціль буде досягнута, за нинішнім темпом.
///
/// Рахується від сьогодні, а не від дати, зашитої в код. Обіцянка «будеш на
/// 74 кілограмах пʼятнадцятого вересня», яка не міняється місяцями, це не
/// прогноз, а напис.
String targetDate(int weeks) {
  final d = calendarDay(weeks * 7);
  return '${d.day} ${monthName(d.month)} ${d.year}';
}

/// The same day without the year, for a sentence that is already about this one.
String targetDay(int weeks) {
  final d = calendarDay(weeks * 7);
  return '${d.day} ${monthName(d.month)}';
}

class ThemeOption {
  const ThemeOption({required this.id, required this.icon});

  final AppTheme id;
  final String icon;
}

const themeOptions = <ThemeOption>[
  ThemeOption(id: AppTheme.light, icon: 'sun'),
  ThemeOption(id: AppTheme.aquarelle, icon: 'water'),
  ThemeOption(id: AppTheme.dawn, icon: 'sunrise'),
  ThemeOption(id: AppTheme.dark, icon: 'moon'),
  ThemeOption(id: AppTheme.system, icon: 'settings'),
];

/* Порядок мов у списку сталий і не залежить від того, якою зараз говорять:
   перелік, що перетасовується на кожному перемиканні, читається як помилка. */
const langOptions = <Lang>[Lang.system, Lang.uk, Lang.en];

/* --- Where the reminder times come from ---
 *
 * They are not invented. A default hour picked out of the air is worse than no
 * reminder: it fires while the person is asleep or already eating, and the
 * first thing they learn is to switch reminders off.
 *
 * So each one is read from the person's own records: the usual hour of that meal,
 * the gaps between meals for water, the morning for the weigh-in. Until there is
 * enough history the reminder simply stays off and says why. */

int _toMins(String t) {
  final p = t.split(':');
  return int.parse(p[0]) * 60 + int.parse(p[1]);
}

/// Middle value, not the average: one 03:00 snack must not drag the hour.
int? _median(List<int> xs) {
  if (xs.isEmpty) return null;
  final s = [...xs]..sort();
  return s[s.length ~/ 2];
}

/// The usual hour of a card across the history, rounded to a quarter hour.
int? usualHour(String slotId) {
  final times = <int>[];
  for (final d in allDays.values) {
    for (final m in d.meals) {
      if (m.slotId == slotId) times.add(_toMins(m.time));
    }
  }
  final mid = _median(times);
  return mid == null ? null : (mid / 15).round() * 15;
}

/* Тут була defaultReminders: шість груп нагадувань, увімкнених наперед.
 *
 * Половина з них не стосувалась нікого конкретного, і перше, що з ними робили,
 * це вимикали. Наперед увімкнене нагадування це не турбота, а припущення про
 * чуже життя. Тепер список порожній, поки людина не заведе своє, рівно як у
 * препаратах. */

/// Скільки шляху до цілі вже пройдено, від нуля до одиниці.
///
/// Тут довго стояло `(старт - зараз) / (старт - ціль)` з умовою «тільки якщо
/// старт більший за ціль». Для схуднення це правильно, а для набору ваги знизу
/// виходило відʼємне число, умова не спрацьовувала, і кільце лишалось порожнім
/// назавжди. Людина набрала три кілограми з пʼяти і бачила нуль.
///
/// Напрямок не має значення для самого питання: пройдено це відстань від старту
/// в бік цілі, поділена на всю відстань. Рух у зворотний бік не зараховується,
/// але й не йде в мінус: кільце показує здобуте, а не борг.
/// Куди насправді йде вага, і чи це те, чого людина хотіла.
///
/// Стоїть між «поточна» і «ціль» на картці прогресу. Знак каже напрямок, колір
/// каже вердикт, і разом вони відповідають на питання, заради якого людина
/// відкриває цей екран: воно працює чи ні.
///
/// **Напрямок і вердикт це різні речі.** Стрілка вниз сама по собі не хороша й
/// не погана: тому, хто худне, вона успіх, тому, хто набирає, невдача. Тому
/// знак береться з руху ваги, а колір з того, чи збігається цей рух із ціллю.
///
/// Для цілі «тримати» знака руху немає взагалі: там успіх це відсутність руху,
/// і його показує знак рівності. Півкілограма в обидва боки це та сама вага, а
/// не зрада цілі: ваги стільки набігає за день самою водою.
({String icon, bool? good}) goalTrend(SettingsState s) {
  if (s.direction == Direction.keep) {
    return (icon: 'equal', good: (s.weightKg - s.targetKg).abs() <= 0.5);
  }

  final moved = s.weightKg - s.goalStartKg;

  /* Ціль щойно поставлена, і руху ще немає. Малювати тут вердикт означало б
     оцінювати те, чого не сталось, тому знак рівності без кольору. */
  if (moved.abs() < 0.05) return (icon: 'equal', good: null);

  final down = moved < 0;
  return (icon: down ? 'trend-down' : 'trend-up', good: down == (s.direction == Direction.lose));
}

double goalProgress(SettingsState s) {
  final total = s.targetKg - s.goalStartKg;
  final moved = s.weightKg - s.goalStartKg;

  /* Ціль «тримати вагу» це нульова відстань, і ділити на неї нема чого. Там
     пройдене міряється інакше: кільце повне, поки вага тримається біля цілі, і
     порожніє, коли відходить далі ніж на три кілограми. */
  if (total.abs() < 0.05) {
    final off = (s.weightKg - s.targetKg).abs();
    return (1 - off / 3).clamp(0.0, 1.0);
  }

  return (moved / total).clamp(0.0, 1.0);
}

/// The day's norm as the settings currently have it.
///
/// The day is measured against what the person set, not against a figure baked
/// into the fixtures: settings that change the norm and a home card that keeps
/// showing the old one are two answers to the same question.
DayGoal goalOf(SettingsState s) =>
    DayGoal(kcal: dailyKcal(s), protein: s.protein, fat: s.fat, carbs: s.carbs, waterMl: s.waterMl);
