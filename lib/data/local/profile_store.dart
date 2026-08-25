import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../measure.dart';
import '../settings.dart';
/* Drift зве рядок таблиці алергій так само, як його зве застосунок, і два
   різні `Allergy` в одному файлі не уживаються. Тут потрібен той, що з
   налаштувань: у нього ходять екрани. */
import 'database.dart' hide Allergy;
import 'meds_store.dart' show repeatFromJson, repeatToJson;

const _uuid = Uuid();

/* Один рядок на профіль, і його ідентифікатор сталий.
 *
 * Профіль у людини один, тому новий випадковий `uuid` при кожному збереженні
 * створив би на сервері нову сутність замість того, щоб оновити стару. */
const _rowId = 'me';

/// Профіль людини між запусками.
///
/// Доти цього не було зовсім: `SettingsState` жив полем у `main.dart`, і
/// застосунок щоразу прокидався тією самою вигаданою людиною з демо-фікстури.
/// Вага, ціль, темп і норма трималися рівно доти, доки не закриють застосунок,
/// а онбординг питав ті самі питання щодня.
///
/// Тут не сховище налаштувань узагалі, а рівно те, що вже описане схемою по
/// обидва боки: колонки [Profile], сьогоднішня вага і список алергенів. Мова,
/// нагадування, спогади помічника і два прапорці телеметрії поки лишаються в
/// памʼяті: під них немає ні місцевої колонки, ні серверної.
class ProfileStore {
  ProfileStore(this.db);

  final CalviDb db;

  /// Що збережено, або порожньо, якщо людина ще не проходила «Старт».
  ///
  /// Порожньо це не помилка, а відповідь: саме за нею застосунок розуміє, що
  /// запуск справді перший.
  Future<SettingsState?> load() async {
    final row = await (db.select(db.profile)..where((p) => p.id.equals(_rowId))).getSingleOrNull();
    if (row == null || row.deletedAt != null) return null;

    final weight =
        await (db.select(db.weights)
              ..where((w) => w.deletedAt.isNull())
              ..orderBy([(w) => OrderingTerm(expression: w.day, mode: OrderingMode.desc)])
              ..limit(1))
            .getSingleOrNull();

    final allergies = await (db.select(db.allergies)..where((a) => a.deletedAt.isNull())).get();

    final base = emptySettings();
    return base.copyWith(
      sex: _sexOf(row.sex),
      age: row.birthYear == null ? base.age : DateTime.now().year - row.birthYear!,
      heightCm: row.heightCm ?? base.heightCm,
      weightKg: weight?.kg ?? row.goalStartKg ?? base.weightKg,
      goalStartKg: row.goalStartKg ?? base.goalStartKg,
      targetKg: row.targetKg ?? base.targetKg,
      direction: _directionOf(row.direction),
      pace: row.pace,
      activity: row.activity,
      kcalManual: row.kcalManual,
      clearKcalManual: row.kcalManual == null,
      protein: row.proteinG ?? base.protein,
      fat: row.fatG ?? base.fat,
      carbs: row.carbsG ?? base.carbs,
      waterMl: row.waterMl,
      allergies: [for (final a in allergies) Allergy(id: a.allergenId, severe: a.severe)],
      theme: _themeOf(row.theme),
      lang: _langOf(row.lang),
      /* Памʼять приходить із профілю, а не живе тільки в памʼяті екрана.
       *
       * Без цього рядка сторінка «Памʼять» лишалась порожньою назавжди: Нора
       * записувала нотатку на сервері, профіль привозив її на телефон, і ніхто
       * не діставав її з рядка. */
      memory: _memoryOf(row.memory),
      addressAs: row.addressAs,
      reminders: _remindersOf(row.reminders),
      tracked: row.tracked.isEmpty
          ? defaultTracked
          : row.tracked.split(',').where((k) => k.isNotEmpty).toList(),
    );
  }

  /// Пише профіль і все, що до нього прилягає.
  ///
  /// Кожен запис лишає рядок брудним: це вся черга на сервер, іншої немає. Вага
  /// йде своєю таблицею, бо вага це вимір дня, а не властивість людини, і
  /// сьогоднішня цифра не має переписувати вчорашню.
  Future<void> save(SettingsState s) async {
    final now = DateTime.now();

    await db
        .into(db.profile)
        .insertOnConflictUpdate(
          ProfileCompanion.insert(
            id: _rowId,
            updatedAt: now,
            dirty: const Value(true),
            deletedAt: const Value(null),
            sex: Value(s.sex.name),
            birthYear: Value(now.year - s.age),
            heightCm: Value(s.heightCm),
            goalStartKg: Value(s.goalStartKg),
            targetKg: Value(s.targetKg),
            direction: Value(s.direction.name),
            pace: Value(s.pace),
            activity: Value(s.activity),
            kcalManual: Value(s.kcalManual),
            proteinG: Value(s.protein),
            fatG: Value(s.fat),
            carbsG: Value(s.carbs),
            waterMl: Value(s.waterMl),
            theme: Value(s.theme.name),
            lang: Value(s.lang.name),
            addressAs: Value(s.addressAs),
            memory: Value(
              jsonEncode([
                for (final m in s.memory) {'id': m.id, 'text': m.text, 'pinned': m.pinned},
              ]),
            ),
            tracked: Value(s.tracked.join(',')),
            reminders: Value(
              jsonEncode([
                for (final r in s.reminders)
                  {
                    'id': r.id,
                    'kind': r.kind.name,
                    'label': r.label,
                    'times': r.times,
                    'repeat': jsonDecode(repeatToJson(r.repeat)),
                    'on': r.on,
                  },
              ]),
            ),
          ),
        );

    await db.diaryDao.setWeight(kg: s.weightKg, at: now);
    await _saveAllergies(s.allergies, now);
  }

  /// Алергени рядками, і зняте не зникає мовчки.
  ///
  /// Прибраний алерген видаляється мʼяко: пристрій, який тиждень був без
  /// мережі, з відсутнього рядка не дізнається нічого, а з поміченого дізнається
  /// саме те, що треба.
  Future<void> _saveAllergies(List<Allergy> want, DateTime now) async {
    final have = await db.select(db.allergies).get();
    final byCode = {for (final row in have) row.allergenId: row};

    for (final a in want) {
      final row = byCode[a.id];
      if (row == null) {
        await db
            .into(db.allergies)
            .insert(
              AllergiesCompanion.insert(
                id: _uuid.v4(),
                updatedAt: now,
                allergenId: a.id,
                severe: Value(a.severe),
              ),
            );
        continue;
      }
      if (row.severe == a.severe && row.deletedAt == null) continue;
      await (db.update(db.allergies)..where((x) => x.id.equals(row.id))).write(
        AllergiesCompanion(
          severe: Value(a.severe),
          deletedAt: const Value(null),
          updatedAt: Value(now),
          dirty: const Value(true),
        ),
      );
    }

    final wanted = {for (final a in want) a.id};
    for (final row in have) {
      if (wanted.contains(row.allergenId) || row.deletedAt != null) continue;
      await (db.update(db.allergies)..where((x) => x.id.equals(row.id))).write(
        AllergiesCompanion(deletedAt: Value(now), updatedAt: Value(now), dirty: const Value(true)),
      );
    }
  }
}

Sex _sexOf(String v) => switch (v) {
  'f' => Sex.f,
  'x' => Sex.x,
  _ => Sex.m,
};

Direction _directionOf(String v) => switch (v) {
  'keep' => Direction.keep,
  'gain' => Direction.gain,
  _ => Direction.lose,
};

/// Памʼять із рядка JSON. Зіпсований рядок це порожня памʼять, а не падіння:
/// сторінка без нотаток гірша за застосунок, який не відкривається.
List<Memo> _memoryOf(String raw) {
  try {
    final list = jsonDecode(raw);
    if (list is! List) return const [];
    return [
      for (final m in list.whereType<Map<String, dynamic>>())
        Memo(
          id: m['id'] as String? ?? '',
          text: m['text'] as String? ?? '',
          pinned: m['pinned'] as bool? ?? false,
        ),
    ]..removeWhere((m) => m.text.isEmpty);
  } catch (_) {
    return const [];
  }
}

/// Нагадування з рядка JSON. Зіпсований рядок це порожній список, а не падіння.
List<Reminder> _remindersOf(String raw) {
  try {
    final list = jsonDecode(raw);
    if (list is! List) return const [];

    return [
      for (final r in list.whereType<Map<String, dynamic>>())
        Reminder(
          id: r['id'] as String? ?? '',
          kind: ReminderKind.values.firstWhere(
            (k) => k.name == r['kind'],
            orElse: () => ReminderKind.water,
          ),
          label: r['label'] as String? ?? '',
          times: [for (final t in (r['times'] as List? ?? [])) t.toString()],
          repeat: repeatFromJson(jsonEncode(r['repeat'])),
          on: r['on'] as bool? ?? true,
        ),
    ]..removeWhere((r) => r.id.isEmpty);
  } catch (_) {
    return const [];
  }
}

AppTheme _themeOf(String v) => switch (v) {
  'aquarelle' => AppTheme.aquarelle,
  'dawn' => AppTheme.dawn,
  'dark' => AppTheme.dark,
  'system' => AppTheme.system,
  _ => AppTheme.light,
};

/* Невідоме значення означає мову пристрою, а не українську. Стовпець заведений
   із замовчуванням `system`, і саме таким його бачать телефони, які оновились. */
Lang _langOf(String v) => switch (v) {
  'uk' => Lang.uk,
  'en' => Lang.en,
  _ => Lang.system,
};
