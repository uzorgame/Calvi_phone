import 'dart:convert';

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
    seq: Value(_int(c['seq'])!),
    dirty: const Value(false),
    day: Value(_day(d['day'])),
    at: Value(_time(d['at'])!),
    tzOffsetMin: Value(_int(d['tz_offset_min']) ?? 0),
    slot: Value(d['slot'] as String),
    name: Value(d['name'] as String),
    canonicalName: Value(_text(d['canonical_name'])),
    icon: Value(_text(d['icon']) ?? 'plate'),
    grams: Value(_dec(d['grams'])),
    kcal: Value(_int(d['kcal'])!),
    proteinG: Value(_dec(d['protein_g']) ?? 0),
    fatG: Value(_dec(d['fat_g']) ?? 0),
    carbsG: Value(_dec(d['carbs_g']) ?? 0),
    source: Value(_text(d['source']) ?? 'manual'),
    note: Value(_text(d['note'])),
  );
}

WaterLogsCompanion waterFromChange(Map<String, dynamic> c) {
  final d = c['data'] as Map<String, dynamic>;
  return WaterLogsCompanion(
    id: Value(c['id'] as String),
    updatedAt: Value(_time(c['updated_at'])!),
    deletedAt: Value(_time(c['deleted_at'])),
    seq: Value(_int(c['seq'])!),
    dirty: const Value(false),
    day: Value(_day(d['day'])),
    at: Value(_time(d['at'])!),
    ml: Value(_int(d['ml'])!),
  );
}

WeightsCompanion weightFromChange(Map<String, dynamic> c) {
  final d = c['data'] as Map<String, dynamic>;
  return WeightsCompanion(
    id: Value(c['id'] as String),
    updatedAt: Value(_time(c['updated_at'])!),
    deletedAt: Value(_time(c['deleted_at'])),
    seq: Value(_int(c['seq'])!),
    dirty: const Value(false),
    day: Value(_day(d['day'])),
    at: Value(_time(d['at'])!),
    kg: Value(_dec(d['kg'])!),
  );
}

/// Times come back as UTC text and are stored as local, because that is what
/// every screen reads them as.
DateTime? _time(Object? value) => value is String ? DateTime.parse(value).toLocal() : null;

/// Текстове поле з дроту, яким би воно не приїхало.
///
/// Жорстке приведення `as String?` коштувало найдорожче з усього. Сервер колись
/// перетворював текстові колонки на числа, якщо значення було схоже на число, і
/// доза препарату «2.0» приїжджала числом 2. Застосунок падав на ній щоразу
/// після входу, бо після входу щоденник завантажується з нуля, і винний рядок
/// приходив у кожній спробі: вхід через Google не міг завершитись жодного разу.
///
/// Сервер полагоджено, але цей шар лишається назавжди. Чужий тип у полі має
/// коштувати одне зіпсоване значення, а не втрачений акаунт.
String? _text(Object? value) => value?.toString();

/// Ціле число з дроту, яким би воно не приїхало. Та сама причина, що й у [_text].
int? _int(Object? value) => switch (value) {
  final int v => v,
  final num v => v.toInt(),
  final String v => int.tryParse(v) ?? double.tryParse(v)?.toInt(),
  _ => null,
};

/// Дробове число з дроту. Та сама причина, що й у [_text].
double? _dec(Object? value) => switch (value) {
  final num v => v.toDouble(),
  final String v => double.tryParse(v),
  _ => null,
};

/// Календарний день, як його зберігає телефон: рівно десять символів.
///
/// Сервер уже віддає його рядком, але цей рівень лишається назавжди. Одного дня
/// звідти приїхало `2026-08-18T00:00:00.000Z`, і кожен запис Нори ліг у базу
/// під ключем, якого жоден екран не питає: людина бачила порожній сніданок
/// після того, як їй сказали «записала». Дешевше обрізати тут, ніж шукати це
/// вдруге.
String _day(Object? value) {
  final s = value?.toString() ?? '';
  return s.length >= 10 ? s.substring(0, 10) : s;
}

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
  data: {'day': r.day, 'at': r.at.toUtc().toIso8601String(), 'part': r.part, 'cm': r.cm},
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
    /* Розклад рядком, як він і лежить у базі: сервер його не тлумачить, а
       возить. Розбирати JSON у двох місцях означало б два місця, де він може
       розійтись. */
    'schedule': r.schedule,
    /* Форма власним полем, а не всередині примітки: інакше текст людини
       затирався маркером «form=tab». */
    'form': r.form,
    /* Межі курсу. Без них препарат, заведений сьогодні, зʼявлявся в кожному
       минулому дні, а закінчений курс стирав власну історію. */
    'start_day': r.startDay,
    /* Година початку: день початку рахується від неї, а не цілком. */
    'start_time': r.startTime,
    'end_day': r.endDay,
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
    seq: Value(_int(c['seq'])!),
    dirty: const Value(false),
    day: Value(_day(d['day'])),
    at: Value(_time(d['at'])!),
    part: Value(d['part'] as String),
    cm: Value(_dec(d['cm'])!),
  );
}

WorkoutsCompanion workoutFromChange(Map<String, dynamic> c) {
  final d = c['data'] as Map<String, dynamic>;
  return WorkoutsCompanion(
    id: Value(c['id'] as String),
    updatedAt: Value(_time(c['updated_at'])!),
    deletedAt: Value(_time(c['deleted_at'])),
    seq: Value(_int(c['seq'])!),
    dirty: const Value(false),
    day: Value(_day(d['day'])),
    at: Value(_time(d['at'])!),
    kind: Value(d['kind'] as String),
    minutes: Value(_int(d['minutes'])!),
    kcal: Value(_int(d['kcal']) ?? 0),
  );
}

MedicationsCompanion medFromChange(Map<String, dynamic> c) {
  final d = c['data'] as Map<String, dynamic>;
  return MedicationsCompanion(
    id: Value(c['id'] as String),
    updatedAt: Value(_time(c['updated_at'])!),
    deletedAt: Value(_time(c['deleted_at'])),
    seq: Value(_int(c['seq'])!),
    dirty: const Value(false),
    name: Value(d['name'] as String),
    amount: Value(_text(d['amount'])),
    note: Value(_text(d['note'])),
    times: Value(joinTimes(d['times'])),
    schedule: Value(_text(d['schedule']) ?? ''),
    form: Value(_text(d['form']) ?? 'tab'),
    startDay: Value(_day(d['start_day'])),
    startTime: Value(_text(d['start_time']) ?? ''),
    endDay: Value(d['end_day'] == null ? null : _day(d['end_day'])),
    remind: Value(d['remind'] as bool? ?? true),
  );
}

MedicationTakesCompanion takeFromChange(Map<String, dynamic> c) {
  final d = c['data'] as Map<String, dynamic>;
  return MedicationTakesCompanion(
    id: Value(c['id'] as String),
    updatedAt: Value(_time(c['updated_at'])!),
    deletedAt: Value(_time(c['deleted_at'])),
    seq: Value(_int(c['seq'])!),
    dirty: const Value(false),
    medicationId: Value(d['medication_id'] as String),
    day: Value(_day(d['day'])),
    at: Value(_time(d['at'])!),
    plannedTime: Value(_text(d['planned_time'])),
  );
}

AllergiesCompanion allergyFromChange(Map<String, dynamic> c) {
  final d = c['data'] as Map<String, dynamic>;
  return AllergiesCompanion(
    id: Value(c['id'] as String),
    updatedAt: Value(_time(c['updated_at'])!),
    deletedAt: Value(_time(c['deleted_at'])),
    seq: Value(_int(c['seq'])!),
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
  'address_as': r.addressAs,
  // Які поля вимірювань людина веде: інакше на другому телефоні картка показує
  // не те, що на першому.
  'tracked': r.tracked,
  // Памʼять їде списком обʼєктів, а не рядком: на дроті вона така сама, як у
  // базі сервера, і зайвого розбору по дорозі не потрібно.
  'memory': jsonDecode(r.memory),
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
  birthYear: Value(_int(p['birth_year'])),
  heightCm: Value(_int(p['height_cm'])),
  goalStartKg: Value(_real(p['goal_start_kg'])),
  targetKg: Value(_real(p['target_kg'])),
  direction: Value(p['direction'] as String),
  pace: Value(_real(p['pace'])!),
  activity: Value(_real(p['activity'])!),
  kcalManual: Value(_int(p['kcal_manual'])),
  proteinG: Value(_int(p['protein_g'])),
  fatG: Value(_int(p['fat_g'])),
  carbsG: Value(_int(p['carbs_g'])),
  waterMl: Value(_int(p['water_ml'])!),
  theme: Value(p['theme'] as String),
  addressAs: Value(_text(p['address_as'])),
  tracked: Value(_text(p['tracked']) ?? ''),
  memory: Value(jsonEncode(p['memory'] ?? const [])),
);

/// Числа з JSON приходять то цілими, то дробовими: 74 і 74.0 це той самий вага.
double? _real(Object? v) => v == null ? null : (v as num).toDouble();
