/// The tape: what a body is measured with, and what was written down.
library;

/// One field of the tape.
class MeasureField {
  const MeasureField({
    required this.key,
    required this.label,
    required this.unit,
    required this.icon,
    required this.min,
    required this.max,
  });

  final String key;
  final String label;
  final String unit;
  final String icon;

  /// Anything outside is dropped rather than stored: a slipped digit in one
  /// field would bend the chart for months.
  final double min;
  final double max;
}

const measureFields = <MeasureField>[
  MeasureField(key: 'weightKg', label: 'Вага', unit: 'кг', icon: 'scale', min: 30, max: 250),
  MeasureField(key: 'chest', label: 'Груди', unit: 'см', icon: 'user', min: 50, max: 180),
  MeasureField(key: 'waist', label: 'Талія', unit: 'см', icon: 'user', min: 40, max: 200),
  MeasureField(key: 'hips', label: 'Стегна', unit: 'см', icon: 'user', min: 50, max: 200),
  MeasureField(key: 'thigh', label: 'Стегно', unit: 'см', icon: 'user', min: 30, max: 100),
  MeasureField(key: 'wrist', label: 'Запʼясток', unit: 'см', icon: 'user', min: 10, max: 30),
  MeasureField(key: 'neck', label: 'Шия', unit: 'см', icon: 'user', min: 25, max: 70),
  MeasureField(key: 'biceps', label: 'Біцепс', unit: 'см', icon: 'gym', min: 15, max: 70),
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

/// What this person actually measures. Most people measure one thing, and eight
/// fields open at once assumes everybody takes a full set.
const defaultTracked = ['weightKg', 'waist'];

/// Demo history, one session a month, moving the way the weight story does.
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
  Measure(
    date: -5,
    values: {
      'weightKg': 78.6,
      'chest': 102.5,
      'waist': 85,
      'hips': 99,
      'thigh': 58.5,
      'wrist': 17.5,
      'neck': 39,
      'biceps': 34.5,
    },
  ),
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

/// How long ago a session was, in words.
String measureAgo(int offset) {
  final d = -offset;
  if (d <= 0) return 'сьогодні';
  if (d == 1) return 'учора';
  if (d < 7) return '$d дні тому';
  final w = (d / 7).round();
  if (w == 1) return 'тиждень тому';
  return w < 5 ? '$w тижні тому' : '$w тижнів тому';
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
