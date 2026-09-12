/// The tape: what a body is measured with, and what was written down.
library;

import '../l10n/data_lang.dart';
import 'units.dart';

/// One field of the tape.
class MeasureField {
  const MeasureField({
    required this.key,
    required this.icon,
    required this.min,
    required this.max,
    this.inCm = true,
  });

  final String key;
  final String icon;

  /// Сантиметрами міряють усе, крім ваги.
  final bool inCm;

  /* Назва й одиниця геттерами, а не полями.
   *
   * Список полів це стала, і зашити в неї слово означало б зашити мову. Тут
   * лежать самі ключі, а слово під ключем береться з перекладу тієї миті, коли
   * його малюють. */
  String get label => switch (key) {
    'weightKg' => dataL.fieldWeight,
    'chest' => dataL.fieldChest,
    'waist' => dataL.fieldWaist,
    'hips' => dataL.fieldHips,
    'thigh' => dataL.fieldThigh,
    'wrist' => dataL.fieldWrist,
    'neck' => dataL.fieldNeck,
    _ => dataL.fieldBiceps,
  };

  String get unit => inCm ? dataUnits.lenLabel : dataUnits.massLabel;

  /* The tape is stored metric and read in the person's units. Both scales are
     proportional, so a difference between two readings converts the same way
     as a reading. */
  double shown(double v) => inCm ? dataUnits.lenOut(v) : dataUnits.massOut(v);

  double stored(double v) => inCm ? dataUnits.lenIn(v) : dataUnits.massIn(v);

  /// Anything outside is dropped rather than stored: a slipped digit in one
  /// field would bend the chart for months.
  final double min;
  final double max;
}

const measureFields = <MeasureField>[
  MeasureField(key: 'weightKg', icon: 'scale', min: 30, max: 250, inCm: false),
  MeasureField(key: 'chest', icon: 'user', min: 50, max: 180),
  MeasureField(key: 'waist', icon: 'user', min: 40, max: 200),
  MeasureField(key: 'hips', icon: 'user', min: 50, max: 200),
  MeasureField(key: 'thigh', icon: 'user', min: 30, max: 100),
  MeasureField(key: 'wrist', icon: 'user', min: 10, max: 30),
  MeasureField(key: 'neck', icon: 'user', min: 25, max: 70),
  MeasureField(key: 'biceps', icon: 'gym', min: 15, max: 70),
];

MeasureField fieldFor(String key) => measureFields.firstWhere((f) => f.key == key);

/// One session with the tape. Sparse on purpose: somebody who only ever weighs
/// themselves should not carry seven empty columns.
class Measure {
  const Measure({required this.date, required this.values});

  /// Offset from today, like every other date in the app.
  final int date;
  final Map<String, double> values;

  double? operator [](String key) => values[key];
}

/// Значення, яке було правдою на цей день.
///
/// Береться останній запис **на цей день або раніше**. Зважились 26-го, 27-го на
/// ваги не ставали, отже 27-го правдиве число від 26-го: вага не зникає від
/// того, що її не міряли.
///
/// Пізніші записи не беруться навмисно. Картка минулого дня, яка показує
/// сьогоднішню вагу, це не історія, а сьогодні з чужою датою.
double? measuredOn(List<Measure> list, String key, int date) {
  double? found;
  var at = -100000;
  for (final m in list) {
    final v = m[key];
    if (v == null || m.date > date || m.date < at) continue;
    at = m.date;
    found = v;
  }
  return found;
}

/// What this person actually measures. Most people measure one thing, and eight
/// fields open at once assumes everybody takes a full set.
const defaultTracked = ['weightKg', 'waist'];

/* Demo history: a tape session a month, and the scale far more often than that.
 *
 * Зважування щодня останнього тижня, і це не декорація. Картка дня показує вагу
 * того дня, і з чотирма записами за три місяці всі сім днів тижня показували б
 * одне число: перевірити, що вона справді слухає день, було б ніяк. Люди й
 * зважуються частіше, ніж міряються сантиметром.
 *
 * Сьогодні зважування немає навмисно: людина відкриває застосунок удень і на
 * ваги ще не ставала. Картка дня показує вчорашнє число, 78.6, те саме, що в
 * профілі, а поле в картці замірів лишається порожнім і тримає його підказкою.
 * Ті самі числа стоять у демці на 5300. */
const demoMeasures = <Measure>[
  Measure(
    date: -84,
    values: {
      'weightKg': 81.4,
      'chest': 104,
      'waist': 92,
      'hips': 102,
      'thigh': 60,
      'wrist': 17.5,
      'neck': 40,
      'biceps': 34,
    },
  ),
  Measure(
    date: -56,
    values: {
      'weightKg': 80.6,
      'chest': 103.5,
      'waist': 90,
      'hips': 101,
      'thigh': 59.5,
      'wrist': 17.5,
      'neck': 39.5,
      'biceps': 34,
    },
  ),
  Measure(
    date: -28,
    values: {
      'weightKg': 79.5,
      'chest': 103,
      'waist': 87.5,
      'hips': 100,
      'thigh': 59,
      'wrist': 17.5,
      'neck': 39,
      'biceps': 34.5,
    },
  ),
  Measure(date: -21, values: {'weightKg': 79.3}),
  Measure(date: -14, values: {'weightKg': 79.1}),
  Measure(date: -10, values: {'weightKg': 79.0}),
  Measure(date: -8, values: {'weightKg': 79.0}),
  Measure(date: -7, values: {'weightKg': 78.9}),
  Measure(date: -6, values: {'weightKg': 78.9}),
  Measure(
    date: -5,
    values: {
      'weightKg': 78.8,
      'chest': 102.5,
      'waist': 85,
      'hips': 99,
      'thigh': 58.5,
      'wrist': 17.5,
      'neck': 39,
      'biceps': 34.5,
    },
  ),
  Measure(date: -4, values: {'weightKg': 78.8}),
  Measure(date: -3, values: {'weightKg': 78.7}),
  Measure(date: -2, values: {'weightKg': 78.9}),
  Measure(date: -1, values: {'weightKg': 78.6}),
];

/// Newest recorded value of one field, if any.
({double v, int date})? latestMeasure(List<Measure> list, String key) {
  ({double v, int date})? best;
  for (final m in list) {
    final v = m[key];
    if (v == null) continue;
    if (best == null || m.date > best.date) best = (v: v, date: m.date);
  }
  return best;
}

/* Число і слово при ньому раніше складались тут вручну.
 *
 * «5 дні тому» стояло на головному екрані місяцями: правило зводилось до
 * «менше семи означає дні», а насправді дві-чотири це дні, а пʼять і далі
 * днів. Тепер це правило не наше: множина описана в `l10n/data.*.arb` і за
 * категорію відповідає ICU, який знає його для кожної мови, а не для однієї. */

/// How long ago a session was, in words.
String measureAgo(int offset) {
  final d = -offset;
  if (d <= 0) return dataL.agoToday;
  if (d == 1) return dataL.agoYesterday;
  if (d < 7) return dataL.agoDays(d);

  /* Рівно тиждень окремим рядком: «тиждень тому» читається краще за «1 тиждень
     тому», а всередині множини такого винятку не зробити. */
  final w = (d / 7).round();
  return w == 1 ? dataL.agoWeek : dataL.agoWeeks(w);
}

/// Change between the oldest and newest reading inside a window of days.
double? measureDelta(List<Measure> list, String key, int sinceDays) {
  final inWindow = list.where((m) => m[key] != null && m.date >= -sinceDays).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  if (inWindow.length < 2) return null;
  final first = inWindow.first[key]!;
  final last = inWindow.last[key]!;
  return double.parse((last - first).toStringAsFixed(1));
}
