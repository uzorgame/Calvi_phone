/// Medication journal. A log, never an advisor.
///
/// The app records what the user says they take and when they say they took it.
/// It does not calculate doses, does not suggest changes and does not comment on
/// a regimen. That boundary is in section 3 of the spec and it is not a style
/// preference: we are not doctors and a wrong number here is not a wrong number,
/// it is harm.
library;

import '../l10n/data_lang.dart';
import 'fixtures.dart';
import 'repeat.dart';

class MedTime {
  const MedTime({required this.at, required this.taken});

  /// «08:00»
  final String at;
  final bool taken;

  MedTime copyWith({String? at, bool? taken}) =>
      MedTime(at: at ?? this.at, taken: taken ?? this.taken);
}

enum MedForm { tab, cap, drop, ml, shot }

class FormInfo {
  const FormInfo({required this.id, required this.step, required this.max});

  final MedForm id;
  final double step;
  final double max;

  /* Три форми слова, а не ICU-множина.
   *
   * Доза буває дробовою, і «2.5 таблетки» українською йде тією ж формою, що й
   * «2 таблетки», хоч CLDR відносить їх до різних категорій. Правило вибору вже
   * написане в [doseLabel] і перевірене; звідси беруться самі слова.
   *
   * Англійська має дві форми, і третя тут просто повторює другу. */
  String get one => switch (id) {
    MedForm.tab => dataL.doseTabOne,
    MedForm.cap => dataL.doseCapOne,
    MedForm.drop => dataL.doseDropOne,
    MedForm.ml => dataL.doseMlOne,
    MedForm.shot => dataL.doseShotOne,
  };

  String get few => switch (id) {
    MedForm.tab => dataL.doseTabFew,
    MedForm.cap => dataL.doseCapFew,
    MedForm.drop => dataL.doseDropFew,
    MedForm.ml => dataL.doseMlFew,
    MedForm.shot => dataL.doseShotFew,
  };

  String get many => switch (id) {
    MedForm.tab => dataL.doseTabMany,
    MedForm.cap => dataL.doseCapMany,
    MedForm.drop => dataL.doseDropMany,
    MedForm.ml => dataL.doseMlMany,
    MedForm.shot => dataL.doseShotMany,
  };
}

/* Forms the amount can be counted in. Anything that cannot be counted has no
   place here: the home card adds doses up, and «трохи» does not add up. */
const medForms = <FormInfo>[
  FormInfo(id: MedForm.tab, step: 0.5, max: 6),
  FormInfo(id: MedForm.cap, step: 1, max: 6),
  FormInfo(id: MedForm.drop, step: 1, max: 40),
  FormInfo(id: MedForm.ml, step: 0.5, max: 20),
  FormInfo(id: MedForm.shot, step: 1, max: 4),
];

FormInfo formInfo(MedForm f) => medForms.firstWhere((x) => x.id == f);

/// «1 таблетка», «2.5 таблетки», «10 крапель».
String doseLabel(double dose, MedForm form) {
  final f = formInfo(form);
  final whole = dose == dose.roundToDouble();
  final last = dose.floor() % 10;
  final teen = dose.floor() % 100;
  final word = !whole || (last >= 2 && last <= 4 && !(teen >= 12 && teen <= 14))
      ? f.few
      : last == 1 && teen != 11
      ? f.one
      : f.many;
  final n = whole ? dose.toStringAsFixed(0) : dose.toString();
  return '$n $word';
}

class Med {
  const Med({
    required this.id,
    required this.name,
    required this.dose,
    required this.form,
    required this.remind,
    required this.times,
    this.repeat = const DailyRepeat(),
    this.startDay = '',
    this.endDay,
    this.note,
  });

  final String id;

  /// What the user calls it. We never normalise it into a drug database.
  final String name;

  /// How much is taken at once, in units of the chosen form. Picked, never
  /// typed: the home card counts doses, and free text cannot be counted.
  final double dose;

  /// The form it comes in. It only decides how the number is read aloud.
  final MedForm form;

  /// Reminders for this medication. The same switch appears in the reminders
  /// screen; whichever one is touched, both show the same state.
  final bool remind;

  /// Як часто приймати. Спільна модель із нагадуваннями: питання там і тут одне.
  final Repeat repeat;

  /* Межі курсу, календарними днями «РРРР-ММ-ДД».
   *
   * Препарат, заведений сьогодні, стосується сьогодні і майбутнього. Без цього
   * він зʼявлявся в кожному минулому дні, ніби людина пила його завжди, і
   * щоденник за минулий тиждень переписувався заднім числом.
   *
   * [endDay] ставиться замість видалення, коли курс закінчено: дні, коли
   * препарат справді приймали, мають лишитись такими, якими були. */
  final String startDay;
  final String? endDay;

  /// Чи триває курс: останній день або не стоїть, або ще попереду.
  bool stillRunning({DateTime? on}) =>
      endDay == null || endDay!.compareTo(dayKeyOf(on ?? DateTime.now())) > 0;

  /// Чи приймається цей препарат у названий день.
  bool activeOn(DateTime day) {
    final key = dayKeyOf(day);
    if (startDay.isNotEmpty && key.compareTo(startDay) < 0) return false;
    if (endDay != null && key.compareTo(endDay!) > 0) return false;
    return fallsOn(repeat, day);
  }

  /// When it is meant to be taken, in order.
  final List<MedTime> times;
  final String? note;

  /* Кожне поле переноситься, і це не формальність.
   *
   * Тут бракувало `repeat`, тому будь-який виклик тихо скидав розклад на
   * «щодня». Спрацьовувало у двох буденних місцях: перемикач нагадувань для
   * всіх препаратів одразу і галочка прийому дози. Людина відмічала випиту
   * таблетку і разом із цим втрачала «по понеділках і четвергах», без жодного
   * повідомлення. */
  Med copyWith({
    String? name,
    double? dose,
    MedForm? form,
    bool? remind,
    List<MedTime>? times,
    Repeat? repeat,
    String? startDay,
    String? endDay,
    bool clearEndDay = false,
    String? note,
  }) => Med(
    id: id,
    name: name ?? this.name,
    dose: dose ?? this.dose,
    form: form ?? this.form,
    remind: remind ?? this.remind,
    times: times ?? this.times,
    repeat: repeat ?? this.repeat,
    startDay: startDay ?? this.startDay,
    endDay: clearEndDay ? null : (endDay ?? this.endDay),
    note: note ?? this.note,
  );
}

/// Demo regimen. Empty by default: the fourth card only exists if this does.
final demoMeds = <Med>[
  Med(
    id: 'm1',
    name: demoDish('Магній B6', 'Magnesium B6'),
    dose: 2,
    form: MedForm.tab,
    remind: true,
    times: const [
      MedTime(at: '08:00', taken: true),
      MedTime(at: '21:00', taken: false),
    ],
  ),
  Med(
    id: 'm2',
    name: demoDish('Вітамін D3', 'Vitamin D3'),
    dose: 1,
    form: MedForm.drop,
    remind: false,
    times: const [MedTime(at: '08:00', taken: true)],
    note: demoDish('Разом зі сніданком', 'With breakfast'),
  ),
];

/// День як ключ бази: «РРРР-ММ-ДД».
String dayKeyOf(DateTime at) =>
    '${at.year.toString().padLeft(4, '0')}-'
    '${at.month.toString().padLeft(2, '0')}-'
    '${at.day.toString().padLeft(2, '0')}';

/// Ті з препаратів, які приймаються в названий день.
///
/// Розклад мав силу тільки в планувальнику сповіщень, а картка дня, стрічка і
/// кільце рахували всі препарати щодня. Препарат «через день» у неробочий день
/// висів незакритим обовʼязком, і застосунок суперечив власному сповіщенню,
/// яке в той день чесно мовчало.
/// Курси, які ще тривають.
///
/// Не те саме, що [medsOn]: там питання «чи приймається саме в цей день», тут
/// «чи взагалі ще приймається».
///
/// Останній день курсу це день, у який людина натиснула «Закінчити курс». Він
/// уже позаду як рішення, тому препарат одразу йде в «Минулі» і замовкає, але
/// [Med.activeOn] його на цей день ще пускає: сьогоднішні дози справді
/// приймались, і в щоденнику вони мають лишитись видимими.
List<Med> medsAhead(List<Med> meds, {DateTime? on}) => [
  for (final m in meds)
    if (m.stillRunning(on: on)) m,
];

/// Закінчує курс днем, у який людина натиснула кнопку.
///
/// Правило жило прямо в лямбді екрана, і одного разу правку туди зʼїв
/// форматувальник: замінився коментар над рядком, а сам рядок лишився старим.
/// Тести цього не спіймали, бо будували препарат руками, минаючи екран. Тепер
/// правило одне, і воно тут.
List<Med> finishCourse(List<Med> meds, String id) => [
  for (final m in meds)
    if (m.id == id) m.copyWith(endDay: dayKeyOf(DateTime.now())) else m,
];

/// Повертає закінчений курс в активні. Потрібне рівно для промаху по кнопці.
List<Med> reviveCourse(List<Med> meds, String id) => [
  for (final m in meds)
    if (m.id == id) m.copyWith(clearEndDay: true) else m,
];

/// Препарати, яким належить цей день.
///
/// Не те саме, що [medsOn]. Курс задає, які дні його, але день, у якому доза
/// відмічена, теж його, навіть якщо розклад каже інакше: людина могла випити
/// таблетку не за графіком, могла змінити розклад посеред курсу, могла
/// закінчити курс і мати сьогоднішню випиту дозу. Картка дня має стояти на
/// кожному такому дні й показувати, що саме тоді було, і стояти вона має
/// назавжди: закінчення курсу закриває майбутнє, а не переписує минуле.
List<Med> medsOnDay(List<Med> meds, DateTime day, Set<String> takes) {
  final touched = {for (final k in takes) k.split('|').first};
  return [
    for (final m in meds)
      if (m.activeOn(day) || touched.contains(m.id)) m,
  ];
}

List<Med> medsOn(List<Med> meds, DateTime day) => [
  for (final m in meds)
    if (m.activeOn(day)) m,
];

/// Скільки доз цього дня прийнято, за галочками самого дня.
///
/// Галочка належить дню, а не препарату. Доти вона бралася з препарату, а той
/// завантажувався один раз на сьогодні, тому будь-яка інша дата показувала
/// сьогоднішні галочки: людина закривала ранковий прийом і бачила «прийнято» в
/// кожному дні, зокрема в майбутньому.
({int done, int total, double ratio}) medProgressOn(List<Med> meds, Set<String> takes) {
  var done = 0, total = 0;
  for (final m in meds) {
    for (final t in m.times) {
      total++;
      if (takes.contains('${m.id}|${t.at}')) done++;
    }
  }
  return (done: done, total: total, ratio: total == 0 ? 0 : done / total);
}

({int done, int total, double ratio}) medProgress(List<Med> meds) {
  var done = 0, total = 0;
  for (final m in meds) {
    for (final t in m.times) {
      total++;
      if (t.taken) done++;
    }
  }
  return (done: done, total: total, ratio: total == 0 ? 0 : done / total);
}

/// The next time still outstanding today, for the card subtitle.
({String at, String name})? nextDue(List<Med> meds) {
  ({String at, String name})? best;
  for (final m in meds) {
    for (final t in m.times) {
      if (t.taken) continue;
      if (best == null || t.at.compareTo(best.at) < 0) best = (at: t.at, name: m.name);
    }
  }
  return best;
}
