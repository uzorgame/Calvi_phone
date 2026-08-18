import 'package:drift/drift.dart';

import '../local/database.dart';

/// How a stored row becomes a change on the wire, and back.
///
/// One file, both directions, per table. Split across two, the day would come
/// when a field is added to the way up and forgotten on the way down, and the
/// symptom is a value that survives on one phone and not on another.

/// The envelope every row travels in. See the server's `sync.schema.ts`.
Map<String, dynamic> envelope({
  required String table,
  required String id,
  required DateTime updatedAt,
  required DateTime? deletedAt,
  required Map<String, dynamic> data,
}) => {
  'table': table,
  'id': id,
  'updated_at': updatedAt.toUtc().toIso8601String(),
  if (deletedAt != null) 'deleted_at': deletedAt.toUtc().toIso8601String(),
  'data': data,
};

Map<String, dynamic> mealToChange(MealRow r) => envelope(
  table: 'meals',
  id: r.id,
  updatedAt: r.updatedAt,
  deletedAt: r.deletedAt,
  data: {
    'day': r.day,
    'at': r.at.toUtc().toIso8601String(),
    'tz_offset_min': r.tzOffsetMin,
    'slot': r.slot,
    'name': r.name,
    'canonical_name': r.canonicalName,
    'icon': r.icon,
    'grams': r.grams,
    'kcal': r.kcal,
    'protein_g': r.proteinG,
    'fat_g': r.fatG,
    'carbs_g': r.carbsG,
    'source': r.source,
    'note': r.note,
  },
);

Map<String, dynamic> waterToChange(WaterLog r) => envelope(
  table: 'water_logs',
  id: r.id,
  updatedAt: r.updatedAt,
  deletedAt: r.deletedAt,
  data: {'day': r.day, 'at': r.at.toUtc().toIso8601String(), 'ml': r.ml},
);

Map<String, dynamic> weightToChange(Weight r) => envelope(
  table: 'weights',
  id: r.id,
  updatedAt: r.updatedAt,
  deletedAt: r.deletedAt,
  data: {'day': r.day, 'at': r.at.toUtc().toIso8601String(), 'kg': r.kg},
);

/// A change from the server, ready to be written locally.
///
/// It arrives already accepted: the server settled the conflict, so the row is
/// stored as it came and marked clean. Marking it dirty would send it straight
/// back and the two devices would talk forever.
MealsCompanion mealFromChange(Map<String, dynamic> c) {
  final d = c['data'] as Map<String, dynamic>;
  return MealsCompanion(
    id: Value(c['id'] as String),
    updatedAt: Value(_time(c['updated_at'])!),
    deletedAt: Value(_time(c['deleted_at'])),
    seq: Value(c['seq'] as int),
    dirty: const Value(false),
    day: Value(d['day'] as String),
    at: Value(_time(d['at'])!),
    tzOffsetMin: Value((d['tz_offset_min'] as num?)?.toInt() ?? 0),
    slot: Value(d['slot'] as String),
    name: Value(d['name'] as String),
    canonicalName: Value(d['canonical_name'] as String?),
    icon: Value(d['icon'] as String? ?? 'plate'),
    grams: Value((d['grams'] as num?)?.toDouble()),
    kcal: Value((d['kcal'] as num).toInt()),
    proteinG: Value((d['protein_g'] as num?)?.toDouble() ?? 0),
    fatG: Value((d['fat_g'] as num?)?.toDouble() ?? 0),
    carbsG: Value((d['carbs_g'] as num?)?.toDouble() ?? 0),
    source: Value(d['source'] as String? ?? 'manual'),
    note: Value(d['note'] as String?),
  );
}

WaterLogsCompanion waterFromChange(Map<String, dynamic> c) {
  final d = c['data'] as Map<String, dynamic>;
  return WaterLogsCompanion(
    id: Value(c['id'] as String),
    updatedAt: Value(_time(c['updated_at'])!),
    deletedAt: Value(_time(c['deleted_at'])),
    seq: Value(c['seq'] as int),
    dirty: const Value(false),
    day: Value(d['day'] as String),
    at: Value(_time(d['at'])!),
    ml: Value((d['ml'] as num).toInt()),
  );
}

WeightsCompanion weightFromChange(Map<String, dynamic> c) {
  final d = c['data'] as Map<String, dynamic>;
  return WeightsCompanion(
    id: Value(c['id'] as String),
    updatedAt: Value(_time(c['updated_at'])!),
    deletedAt: Value(_time(c['deleted_at'])),
    seq: Value(c['seq'] as int),
    dirty: const Value(false),
    day: Value(d['day'] as String),
    at: Value(_time(d['at'])!),
    kg: Value((d['kg'] as num).toDouble()),
  );
}

/// Times come back as UTC text and are stored as local, because that is what
/// every screen reads them as.
DateTime? _time(Object? value) =>
    value is String ? DateTime.parse(value).toLocal() : null;

/* --- Решта щоденника ---
 *
 * Ті самі два напрямки, та сама обгортка. Єдина розбіжність із сервером тут
 * навмисна і одна: години прийому препарату телефон тримає рядком через кому, а
 * на дроті і в базі це масив. Склеювання й розбирання живуть тут, а не в
 * таблиці, бо це питання протоколу, а не сховища. */

Map<String, dynamic> measureToChange(Measurement r) => envelope(
  table: 'measurements',
  id: r.id,
  updatedAt: r.updatedAt,
  deletedAt: r.deletedAt,
  data: {
    'day': r.day,
    'at': r.at.toUtc().toIso8601String(),
    'part': r.part,
    'cm': r.cm,
  },
);

Map<String, dynamic> workoutToChange(WorkoutRow r) => envelope(
  table: 'workouts',
  id: r.id,
  updatedAt: r.updatedAt,
  deletedAt: r.deletedAt,
  data: {
    'day': r.day,
    'at': r.at.toUtc().toIso8601String(),
    'kind': r.kind,
    'minutes': r.minutes,
    'kcal': r.kcal,
  },
);

Map<String, dynamic> medToChange(Medication r) => envelope(
  table: 'medications',
  id: r.id,
  updatedAt: r.updatedAt,
  deletedAt: r.deletedAt,
  data: {
    'name': r.name,
    'amount': r.amount,
    'note': r.note,
    'times': splitTimes(r.times),
    'remind': r.remind,
  },
);

Map<String, dynamic> takeToChange(MedicationTake r) => envelope(
  table: 'medication_takes',
  id: r.id,
  updatedAt: r.updatedAt,
  deletedAt: r.deletedAt,
  data: {
    'medication_id': r.medicationId,
    'day': r.day,
    'at': r.at.toUtc().toIso8601String(),
    'planned_time': r.plannedTime,
  },
);

Map<String, dynamic> allergyToChange(Allergy r) => envelope(
  table: 'allergies',
  id: r.id,
  updatedAt: r.updatedAt,
  deletedAt: r.deletedAt,
  data: {'allergen_id': r.allergenId, 'severe': r.severe},
);

MeasurementsCompanion measureFromChange(Map<String, dynamic> c) {
  final d = c['data'] as Map<String, dynamic>;
  return MeasurementsCompanion(
    id: Value(c['id'] as String),
    updatedAt: Value(_time(c['updated_at'])!),
    deletedAt: Value(_time(c['deleted_at'])),
    seq: Value(c['seq'] as int),
    dirty: const Value(false),
    day: Value(d['day'] as String),
    at: Value(_time(d['at'])!),
    part: Value(d['part'] as String),
    cm: Value((d['cm'] as num).toDouble()),
  );
}

WorkoutsCompanion workoutFromChange(Map<String, dynamic> c) {
  final d = c['data'] as Map<String, dynamic>;
  return WorkoutsCompanion(
    id: Value(c['id'] as String),
    updatedAt: Value(_time(c['updated_at'])!),
    deletedAt: Value(_time(c['deleted_at'])),
    seq: Value(c['seq'] as int),
    dirty: const Value(false),
    day: Value(d['day'] as String),
    at: Value(_time(d['at'])!),
    kind: Value(d['kind'] as String),
    minutes: Value((d['minutes'] as num).toInt()),
    kcal: Value((d['kcal'] as num?)?.toInt() ?? 0),
  );
}

MedicationsCompanion medFromChange(Map<String, dynamic> c) {
  final d = c['data'] as Map<String, dynamic>;
  return MedicationsCompanion(
    id: Value(c['id'] as String),
    updatedAt: Value(_time(c['updated_at'])!),
    deletedAt: Value(_time(c['deleted_at'])),
    seq: Value(c['seq'] as int),
    dirty: const Value(false),
    name: Value(d['name'] as String),
    amount: Value(d['amount'] as String?),
    note: Value(d['note'] as String?),
    times: Value(joinTimes(d['times'])),
    remind: Value(d['remind'] as bool? ?? true),
  );
}

MedicationTakesCompanion takeFromChange(Map<String, dynamic> c) {
  final d = c['data'] as Map<String, dynamic>;
  return MedicationTakesCompanion(
    id: Value(c['id'] as String),
    updatedAt: Value(_time(c['updated_at'])!),
    deletedAt: Value(_time(c['deleted_at'])),
    seq: Value(c['seq'] as int),
    dirty: const Value(false),
    medicationId: Value(d['medication_id'] as String),
    day: Value(d['day'] as String),
    at: Value(_time(d['at'])!),
    plannedTime: Value(d['planned_time'] as String?),
  );
}

AllergiesCompanion allergyFromChange(Map<String, dynamic> c) {
  final d = c['data'] as Map<String, dynamic>;
  return AllergiesCompanion(
    id: Value(c['id'] as String),
    updatedAt: Value(_time(c['updated_at'])!),
    deletedAt: Value(_time(c['deleted_at'])),
    seq: Value(c['seq'] as int),
    dirty: const Value(false),
    allergenId: Value(d['allergen_id'] as String),
    severe: Value(d['severe'] as bool? ?? false),
  );
}

/// «08:00,20:00» у список. Порожній рядок це порожній список, а не список із
/// порожнім рядком: сервер такого не прийме, і правильно зробить.
List<String> splitTimes(String times) =>
    times.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

List<String> _asStrings(Object? value) =>
    value is List ? [for (final t in value) t.toString()] : const [];

/// І назад, у той вигляд, у якому години зберігає телефон.
String joinTimes(Object? value) => _asStrings(value).join(',');

/* --- Профіль ---
 *
 * Не рядок щоденника і тому не в конверті: у нього немає ні свого
 * ідентифікатора на сервері, ні мʼякого видалення. Їде цілим записом, і єдине
 * питання про нього це чий час новіший. */

Map<String, dynamic> profileToWire(ProfileData r) => {
  'updated_at': r.updatedAt.toUtc().toIso8601String(),
  'sex': r.sex,
  'birth_year': r.birthYear,
  'height_cm': r.heightCm,
  'goal_start_kg': r.goalStartKg,
  'target_kg': r.targetKg,
  'direction': r.direction,
  'pace': r.pace,
  'activity': r.activity,
  'kcal_manual': r.kcalManual,
  'protein_g': r.proteinG,
  'fat_g': r.fatG,
  'carbs_g': r.carbsG,
  'water_ml': r.waterMl,
  'theme': r.theme,
};

/// Профіль із сервера, готовий лягти на диск.
///
/// Чистий: він приїхав звідти, де конфлікт уже вирішено, і позначити його
/// брудним означало б відправити назад те саме, що ми щойно отримали.
ProfileCompanion profileFromWire(Map<String, dynamic> p, {required String id}) => ProfileCompanion(
  id: Value(id),
  updatedAt: Value(_time(p['updated_at'])!),
  deletedAt: const Value(null),
  dirty: const Value(false),
  sex: Value(p['sex'] as String),
  birthYear: Value(p['birth_year'] as int?),
  heightCm: Value(p['height_cm'] as int?),
  goalStartKg: Value(_real(p['goal_start_kg'])),
  targetKg: Value(_real(p['target_kg'])),
  direction: Value(p['direction'] as String),
  pace: Value(_real(p['pace'])!),
  activity: Value(_real(p['activity'])!),
  kcalManual: Value(p['kcal_manual'] as int?),
  proteinG: Value(p['protein_g'] as int?),
  fatG: Value(p['fat_g'] as int?),
  carbsG: Value(p['carbs_g'] as int?),
  waterMl: Value(p['water_ml'] as int),
  theme: Value(p['theme'] as String),
);

/// Числа з JSON приходять то цілими, то дробовими: 74 і 74.0 це той самий вага.
double? _real(Object? v) => v == null ? null : (v as num).toDouble();
