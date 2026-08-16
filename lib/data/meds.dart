/// Medication journal. A log, never an advisor.
///
/// The app records what the user says they take and when they say they took it.
/// It does not calculate doses, does not suggest changes and does not comment on
/// a regimen. That boundary is in section 3 of the spec and it is not a style
/// preference: we are not doctors and a wrong number here is not a wrong number,
/// it is harm.
library;

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
  const FormInfo({
    required this.id,
    required this.one,
    required this.few,
    required this.many,
    required this.step,
    required this.max,
  });

  final MedForm id;
  final String one;
  final String few;
  final String many;
  final double step;
  final double max;
}

/* Forms the amount can be counted in. Anything that cannot be counted has no
   place here: the home card adds doses up, and «трохи» does not add up. */
const medForms = <FormInfo>[
  FormInfo(
    id: MedForm.tab,
    one: 'таблетка',
    few: 'таблетки',
    many: 'таблеток',
    step: 0.5,
    max: 6,
  ),
  FormInfo(id: MedForm.cap, one: 'капсула', few: 'капсули', many: 'капсул', step: 1, max: 6),
  FormInfo(id: MedForm.drop, one: 'крапля', few: 'краплі', many: 'крапель', step: 1, max: 40),
  FormInfo(id: MedForm.ml, one: 'мл', few: 'мл', many: 'мл', step: 0.5, max: 20),
  FormInfo(id: MedForm.shot, one: 'укол', few: 'уколи', many: 'уколів', step: 1, max: 4),
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

  /// When it is meant to be taken, in order.
  final List<MedTime> times;
  final String? note;

  Med copyWith({
    String? name,
    double? dose,
    MedForm? form,
    bool? remind,
    List<MedTime>? times,
    String? note,
  }) => Med(
    id: id,
    name: name ?? this.name,
    dose: dose ?? this.dose,
    form: form ?? this.form,
    remind: remind ?? this.remind,
    times: times ?? this.times,
    note: note ?? this.note,
  );
}

/// Demo regimen. Empty by default: the fourth card only exists if this does.
const demoMeds = <Med>[
  Med(
    id: 'm1',
    name: 'Магній B6',
    dose: 2,
    form: MedForm.tab,
    remind: true,
    times: [
      MedTime(at: '08:00', taken: true),
      MedTime(at: '21:00', taken: false),
    ],
  ),
  Med(
    id: 'm2',
    name: 'Вітамін D3',
    dose: 1,
    form: MedForm.drop,
    remind: false,
    times: [MedTime(at: '08:00', taken: true)],
    note: 'Разом зі сніданком',
  ),
];

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
