/// Everything the settings screens edit, in one place.
library;

import 'day.dart';
import 'fixtures.dart';

enum Sex { m, f, x }

enum AppTheme { light, dark, system }

enum Lang { uk, en }

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
    required this.at,
    required this.on,
  });

  final String id;
  final ReminderKind kind;

  /// What exactly, within the kind: «Сніданок», «Після роботи».
  final String label;
  final String at;
  final bool on;

  Reminder copyWith({String? at, bool? on}) =>
      Reminder(id: id, kind: kind, label: label, at: at ?? this.at, on: on ?? this.on);
}

class ReminderKindInfo {
  const ReminderKindInfo({
    required this.id,
    required this.title,
    required this.icon,
    required this.hint,
  });

  final ReminderKind id;
  final String title;
  final String icon;
  final String hint;
}

const reminderKinds = <ReminderKindInfo>[
  ReminderKindInfo(
    id: ReminderKind.meal,
    title: 'Їжа',
    icon: 'utensils',
    hint: 'нагадаю записати прийом',
  ),
  ReminderKindInfo(
    id: ReminderKind.water,
    title: 'Вода',
    icon: 'drink',
    hint: 'нагадаю попити',
  ),
  ReminderKindInfo(
    id: ReminderKind.meds,
    title: 'Препарати',
    icon: 'pill',
    hint: 'за розкладом із журналу',
  ),
  ReminderKindInfo(
    id: ReminderKind.workout,
    title: 'Тренування',
    icon: 'gym',
    hint: 'нагадаю про заплановане',
  ),
  ReminderKindInfo(
    id: ReminderKind.weigh,
    title: 'Зважування',
    icon: 'scale',
    hint: 'щоб графік ваги не рвався',
  ),
  ReminderKindInfo(
    id: ReminderKind.summary,
    title: 'Підсумок дня',
    icon: 'chart',
    hint: 'коротко про день перед сном',
  ),
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
SettingsState emptySettings() => initialSettings().copyWith(
  allergies: const [],
  memory: const [],
);

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
  memory: const [
    Memo(id: 'm1', text: 'Не їсть свинину', pinned: true),
    Memo(id: 'm2', text: 'Тренується вранці, снідає після тренування', pinned: false),
    Memo(id: 'm3', text: 'Каву пʼє без цукру', pinned: false),
    Memo(id: 'm4', text: 'Вдома готує сам, на роботі бере готове', pinned: false),
  ],
  reminders: defaultReminders(),
  analytics: true,
  crash: true,
  /* Light on a first run, whatever the phone is set to.
     A first run is the one moment the app has no idea who it is talking to, and
     it should look the way it was designed rather than the way the device
     happens to be set. Following the system here means half the people who open
     it see a theme nobody chose for them. The three-way choice, «Тема пристрою»
     included, sits in settings from the first minute. */
  theme: AppTheme.light,
  lang: Lang.uk,
);

class ActivityLevel {
  const ActivityLevel({required this.v, required this.label, required this.hint});

  final double v;
  final String label;
  final String hint;
}

/// What the age and height drums offer, at the start and in the profile.
final ages = List.generate(87, (i) => i + 14);
final heights = List.generate(91, (i) => i + 130);

const activityLevels = <ActivityLevel>[
  ActivityLevel(v: 1.2, label: 'Сидячий', hint: 'майже без руху'),
  ActivityLevel(v: 1.375, label: 'Легка активність', hint: '1-2 тренування на тиждень'),
  ActivityLevel(v: 1.55, label: 'Помірна', hint: '3-4 тренування'),
  ActivityLevel(v: 1.725, label: 'Висока', hint: '5-6 тренувань'),
  ActivityLevel(v: 1.9, label: 'Дуже висока', hint: 'фізична робота або спорт щодня'),
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

const _months = [
  'січня',
  'лютого',
  'березня',
  'квітня',
  'травня',
  'червня',
  'липня',
  'серпня',
  'вересня',
  'жовтня',
  'листопада',
  'грудня',
];

/// Коли ціль буде досягнута, за нинішнім темпом.
///
/// Рахується від сьогодні, а не від дати, зашитої в код. Обіцянка «будеш на
/// 74 кілограмах пʼятнадцятого вересня», яка не міняється місяцями, це не
/// прогноз, а напис.
String targetDate(int weeks) {
  final d = calendarDay(weeks * 7);
  return '${d.day} ${_months[d.month - 1]} ${d.year}';
}

/// The same day without the year, for a sentence that is already about this one.
String targetDay(int weeks) {
  final d = calendarDay(weeks * 7);
  return '${d.day} ${_months[d.month - 1]}';
}

class ThemeOption {
  const ThemeOption({
    required this.id,
    required this.title,
    required this.hint,
    required this.icon,
  });

  final AppTheme id;
  final String title;
  final String hint;
  final String icon;
}

const themeOptions = <ThemeOption>[
  ThemeOption(
    id: AppTheme.light,
    title: 'Світла',
    hint: 'завжди світлий інтерфейс',
    icon: 'sun',
  ),
  ThemeOption(id: AppTheme.dark, title: 'Темна', hint: 'завжди темний інтерфейс', icon: 'moon'),
  ThemeOption(
    id: AppTheme.system,
    title: 'Тема пристрою',
    hint: 'слухає налаштування системи',
    icon: 'settings',
  ),
];

class LangOption {
  const LangOption({required this.id, required this.title, required this.hint});

  final Lang id;
  final String title;
  final String hint;
}

const langOptions = <LangOption>[
  LangOption(id: Lang.uk, title: 'Українська', hint: 'мова за замовчуванням'),
  LangOption(id: Lang.en, title: 'English', hint: 'переклад ще не готовий'),
];

String langLabel(Lang l) => langOptions.firstWhere((x) => x.id == l).title;

String themeLabel(AppTheme t) => themeOptions.firstWhere((x) => x.id == t).title;

String sexLabel(Sex s) => switch (s) {
  Sex.m => 'Ч',
  Sex.f => 'Ж',
  Sex.x => 'Інше',
};

/* --- Where the reminder times come from ---
 *
 * They are not invented. A default hour picked out of the air is worse than no
 * reminder: it fires while the person is asleep or already eating, and the
 * first thing they learn is to switch reminders off.
 *
 * So each one is read from the person's own records: the usual hour of that meal,
 * the gaps between meals for water, the morning for the weigh-in. Until there is
 * enough history the reminder simply stays off and says why. */

String _hhmm(int mins) =>
    '${(mins ~/ 60).toString().padLeft(2, '0')}:${(mins % 60).toString().padLeft(2, '0')}';

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

List<Reminder> defaultReminders() {
  final out = <Reminder>[];
  const meals = [('breakfast', 'Сніданок'), ('lunch', 'Обід'), ('dinner', 'Вечеря')];

  final hours = <int>[];
  for (final (id, label) in meals) {
    final h = usualHour(id);
    if (h == null) {
      // No history for this meal, so no hour to guess. Off, and honest about it.
      out.add(
        Reminder(id: 'meal-$id', kind: ReminderKind.meal, label: label, at: '--:--', on: false),
      );
    } else {
      hours.add(h);
      // Fifteen minutes after the usual hour: a nudge for a meal already eaten
      // and not written down beats one that interrupts it.
      out.add(
        Reminder(
          id: 'meal-$id',
          kind: ReminderKind.meal,
          label: label,
          at: _hhmm(h + 15),
          on: true,
        ),
      );
    }
  }

  /* Water goes in the gaps between meals, where nothing else is asking for
     attention. */
  hours.sort();
  for (var i = 0; i < hours.length - 1; i++) {
    out.add(
      Reminder(
        id: 'water-$i',
        kind: ReminderKind.water,
        label: 'Склянка води',
        at: _hhmm(((hours[i] + hours[i + 1]) / 2 / 15).round() * 15),
        on: i == 0,
      ),
    );
  }

  out.add(
    const Reminder(
      id: 'meds',
      kind: ReminderKind.meds,
      label: 'За розкладом препаратів',
      at: '--:--',
      on: true,
    ),
  );
  out.add(
    const Reminder(
      id: 'workout',
      kind: ReminderKind.workout,
      label: 'Тренування',
      at: '--:--',
      on: false,
    ),
  );

  if (hours.isNotEmpty) {
    // Before the first meal, because weight is read on an empty stomach.
    out.add(
      Reminder(
        id: 'weigh',
        kind: ReminderKind.weigh,
        label: 'Зважитись, щопонеділка',
        at: _hhmm(hours.first - 60),
        on: true,
      ),
    );
    out.add(
      Reminder(
        id: 'summary',
        kind: ReminderKind.summary,
        label: 'Підсумок дня',
        at: _hhmm(hours.last + 120),
        on: true,
      ),
    );
  }

  return out;
}

/// The day's norm as the settings currently have it.
///
/// The day is measured against what the person set, not against a figure baked
/// into the fixtures: settings that change the norm and a home card that keeps
/// showing the old one are two answers to the same question.
DayGoal goalOf(SettingsState s) => DayGoal(
  kcal: dailyKcal(s),
  protein: s.protein,
  fat: s.fat,
  carbs: s.carbs,
  waterMl: s.waterMl,
);
