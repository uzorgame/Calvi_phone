import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/profile_store.dart';
import 'package:calvi/data/remote/sync_mapping.dart';
import 'package:calvi/data/measure.dart';
import 'package:calvi/data/settings.dart';

/// Які поля вимірювань людина веде: це вибір, а не налаштування вигляду.
///
/// Жило тільки в памʼяті екрана. Людина додавала груди й біцепс, місяць їх
/// записувала, а після перезапуску картка показувала знову вагу й талію. Самі
/// заміри лишались у базі, тобто дані були цілі, а побачити їх було ніде.
void main() {
  late CalviDb db;
  late ProfileStore store;

  setUp(() {
    db = CalviDb(NativeDatabase.memory());
    store = ProfileStore(db);
  });
  tearDown(() => db.close());

  test('вибір полів переживає перезапуск', () async {
    await store.save(emptySettings().copyWith(tracked: const ['weightKg', 'chest', 'biceps']));

    final back = (await store.load())!;
    expect(back.tracked, ['weightKg', 'chest', 'biceps']);
  });

  test('на першому запуску стоять вага і талія', () async {
    await store.save(emptySettings());
    expect((await store.load())!.tracked, defaultTracked);
  });

  test('порожній рядок читається як типовий набір, а не як порожньо', () async {
    /* Інакше телефон, який оновився з давнішої версії, показав би картку без
       жодного поля, і людина вирішила б, що заміри зникли. */
    await store.save(emptySettings());
    await db.customStatement("update profile set tracked = ''");

    expect((await store.load())!.tracked, defaultTracked);
  });

  test('вибір їде на сервер і повертається', () async {
    await store.save(emptySettings().copyWith(tracked: const ['weightKg', 'waist', 'neck']));

    final row = await db.select(db.profile).getSingle();
    final wire = profileToWire(row);
    expect(wire['tracked'], 'weightKg,waist,neck');

    await db
        .into(db.profile)
        .insertOnConflictUpdate(
          profileFromWire({
            ...wire,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          }, id: row.id),
        );

    expect((await store.load())!.tracked, ['weightKg', 'waist', 'neck']);
  });
}
