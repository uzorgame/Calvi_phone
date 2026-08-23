import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../meds.dart';
import '../repeat.dart';
import 'database.dart';

/// Препарати на диску, а не в памʼяті екрана.
///
/// Тут довго не було нічого. Таблиця `medications` у базі є, відображення на
/// дріт для синхронізації є, місце в черзі на сервер є, а список жив рядком
/// `List<Med> _meds = const []` усередині застосунку, і єдине, що з ним
/// відбувалось, це `setState`. Тому препарати зникали з перезапуском і на сервер
/// не потрапляли ніколи.
///
/// Це та сама діра, що була в памʼяті Нори і в замірах: усе побудовано, крім
/// одного дроту між екраном і сховищем.
class MedsStore {
  MedsStore(this.db);

  final CalviDb db;
  static const _uuid = Uuid();

  /// Усі препарати, які людина завела, з галочками за названий день.
  ///
  /// День важливий: галочка «прийняв» належить конкретній даті, а не препарату.
  /// Доти читались завжди сьогоднішні прийоми, тому в минулому дні картка
  /// показувала сьогоднішні галочки, і виходило, що людина «прийняла» препарат
  /// у всі дні одразу, зокрема ті, коли його ще не існувало.
  Future<List<Med>> load({DateTime? on}) async {
    final day = on ?? DateTime.now();
    final rows =
        await (db.select(db.medications)
              ..where((m) => m.deletedAt.isNull())
              ..orderBy([(m) => OrderingTerm(expression: m.updatedAt)]))
            .get();

    final ticked = await _takenOn(day);

    return [
      for (final r in rows)
        Med(
          id: r.id,
          name: r.name,
          dose: double.tryParse(r.amount ?? '') ?? 1,
          form: _formOf(r.form),
          remind: r.remind,
          repeat: repeatFromJson(r.schedule),
          /* Порожній початок дочитується з дня останнього запису.
           *
           * Такі рядки лишились від збірки, у якій аркуш створював препарат без
           * початку курсу, а порожній початок означає «приймався завжди»:
           * заведений сьогодні магній світився в минулому понеділку. Дата
           * запису це найближче до правди, що тут іще можна дізнатись. */
          startDay: r.startDay.isNotEmpty ? r.startDay : _dayKey(r.updatedAt),
          endDay: r.endDay,
          note: r.note,
          times: [
            for (final at in r.times.split(',').where((t) => t.isNotEmpty))
              MedTime(at: at, taken: ticked.contains('${r.id}|$at')),
          ],
        ),
    ];
  }

  /// Пише один препарат: новий або змінений.
  Future<void> save(Med m) async {
    final now = DateTime.now();

    await db
        .into(db.medications)
        .insertOnConflictUpdate(
          MedicationsCompanion.insert(
            id: m.id,
            updatedAt: now,
            dirty: const Value(true),
            deletedAt: const Value(null),
            name: m.name,
            /* Доза і форма їдуть рядками, бо на дроті це `amount` і `note`, і
           міняти форму таблиці заради двох полів дорожче, ніж прочитати їх
           тут. Форма живе в примітці під власним ключем, щоб не плутатись із
           текстом, який людина пише сама. */
            amount: Value(m.dose.toString()),
            /* Примітка людини лишається приміткою людини.
         *
         * Форма випуску колись їхала сюди рядком «form=tab», бо своєї колонки
         * не мала, і затирала текст «разом зі сніданком» назавжди. Тепер у неї
         * власна колонка. */
            note: Value(m.note),
            form: Value(m.form.name),
            startDay: Value(m.startDay.isEmpty ? _dayKey(DateTime.now()) : m.startDay),
            endDay: Value(m.endDay),
            times: Value(m.times.map((t) => t.at).join(',')),
            schedule: Value(repeatToJson(m.repeat)),
            remind: Value(m.remind),
          ),
        );
  }

  /* Курс закінчено, а не стерто.
   *
   * Видалення прибирало препарат з усієї історії, і дні, коли людина його
   * справді приймала, ставали такими, ніби вона його не приймала ніколи. Тому
   * замість позначки «видалено» ставиться останній день: від завтра препарат не
   * приймається, а вчорашній щоденник лишається правдою.
   *
   * Мʼяке видалення нікуди не поділось, воно живе в [erase] і потрібне для
   * помилково заведеного препарату, якого не було взагалі. */
  Future<void> stop(String id, {DateTime? at}) async {
    final now = DateTime.now();
    await (db.update(db.medications)..where((m) => m.id.equals(id))).write(
      MedicationsCompanion(
        endDay: Value(_dayKey(at ?? now)),
        updatedAt: Value(now),
        dirty: const Value(true),
      ),
    );
  }

  /// Прибирає препарат зовсім, разом з історією.
  Future<void> erase(String id) async {
    final now = DateTime.now();
    await (db.update(db.medications)..where((m) => m.id.equals(id))).write(
      MedicationsCompanion(deletedAt: Value(now), updatedAt: Value(now), dirty: const Value(true)),
    );
  }

  /// Позначає прийом або знімає позначку за конкретний день.
  ///
  /// Прийом це окремий рядок, а не поле препарату: те, що людина випила
  /// таблетку о восьмій, лишається правдою і завтра, коли розклад той самий, а
  /// галочки вже нові.
  Future<void> setTaken({
    required String medId,
    required String at,
    required bool taken,
    DateTime? on,
  }) async {
    final now = DateTime.now();
    final day = _dayKey(on ?? now);

    final had =
        await (db.select(db.medicationTakes)..where(
              (t) => t.medicationId.equals(medId) & t.day.equals(day) & t.plannedTime.equals(at),
            ))
            .getSingleOrNull();

    if (taken) {
      if (had != null && had.deletedAt == null) return;
      if (had != null) {
        await (db.update(db.medicationTakes)..where((t) => t.id.equals(had.id))).write(
          MedicationTakesCompanion(
            deletedAt: const Value(null),
            updatedAt: Value(now),
            dirty: const Value(true),
          ),
        );
        return;
      }

      await db
          .into(db.medicationTakes)
          .insert(
            MedicationTakesCompanion.insert(
              id: _uuid.v4(),
              updatedAt: now,
              medicationId: medId,
              day: day,
              at: now,
              plannedTime: Value(at),
            ),
          );
      return;
    }

    if (had == null) return;
    await (db.update(db.medicationTakes)..where((t) => t.id.equals(had.id))).write(
      MedicationTakesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        dirty: const Value(true),
      ),
    );
  }

  /// Пари «препарат|година», позначені в цей день.
  Future<Set<String>> _takenOn(DateTime day) async {
    final rows = await (db.select(
      db.medicationTakes,
    )..where((t) => t.day.equals(_dayKey(day)) & t.deletedAt.isNull())).get();
    return {for (final r in rows) '${r.medicationId}|${r.plannedTime ?? ''}'};
  }

  static String _dayKey(DateTime at) =>
      '${at.year.toString().padLeft(4, '0')}-'
      '${at.month.toString().padLeft(2, '0')}-'
      '${at.day.toString().padLeft(2, '0')}';

  static MedForm _formOf(String raw) {
    for (final f in MedForm.values) {
      if (raw == f.name) return f;
    }
    return MedForm.tab;
  }
}

/// Розклад рядком, для колонки в базі і для дроту.
String repeatToJson(Repeat r) => jsonEncode(switch (r) {
  DailyRepeat() => {'kind': 'daily'},
  WeekdayRepeat(:final days) => {'kind': 'weekdays', 'days': days},
  IntervalRepeat(:final every, :final from) => {'kind': 'interval', 'every': every, 'from': from},
});

/// Зіпсований рядок читається як «щодня», а не валить екран: розклад, який не
/// вдалось прочитати, гірше показати неправильно, ніж не показати препарат
/// узагалі.
Repeat repeatFromJson(String? raw) {
  if (raw == null || raw.isEmpty) return const DailyRepeat();
  try {
    final map = jsonDecode(raw);
    if (map is! Map) return const DailyRepeat();

    return switch (map['kind']) {
      'weekdays' => WeekdayRepeat(
        days: [for (final d in (map['days'] as List? ?? [])) (d as num).toInt()],
      ),
      'interval' => IntervalRepeat(
        every: (map['every'] as num?)?.toInt() ?? 2,
        from: map['from'] as String? ?? '',
      ),
      _ => const DailyRepeat(),
    };
  } catch (_) {
    return const DailyRepeat();
  }
}
