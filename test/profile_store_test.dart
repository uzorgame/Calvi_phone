import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/local/database.dart' hide Allergy;
import 'package:calvi/data/local/profile_store.dart';
import 'package:calvi/data/settings.dart';

/// Профіль, який переживає закриття застосунку.
///
/// Доти його не переживало нічого: налаштування були полем у памʼяті, і кожен
/// запуск починався тією самою демонстраційною людиною, а «Старт» питав ті самі
/// питання щодня. Тести тут саме про це і ні про що більше: чи повернеться
/// збережене, чи відрізняє сховище перший запуск від решти, і чи стає все
/// записане в чергу на сервер.
void main() {
  late CalviDb db;
  late ProfileStore store;

  setUp(() {
    db = CalviDb(NativeDatabase.memory());
    store = ProfileStore(db);
  });
  tearDown(() => db.close());

  test('порожнє сховище означає перший запуск', () async {
    expect(await store.load(), isNull);
  });

  test('збережене повертається тим самим', () async {
    final mine = emptySettings().copyWith(
      sex: Sex.f,
      age: 34,
      heightCm: 167,
      weightKg: 61.4,
      goalStartKg: 63,
      targetKg: 58,
      direction: Direction.lose,
      pace: 0.4,
      activity: 1.375,
      protein: 110,
      fat: 55,
      carbs: 190,
      waterMl: 2400,
      theme: AppTheme.dark,
      allergies: const [Allergy(id: 'peanut', severe: true)],
    );

    await store.save(mine);
    final back = await store.load();

    expect(back, isNotNull);
    expect(back!.sex, Sex.f);
    expect(back.age, 34);
    expect(back.heightCm, 167);
    expect(back.weightKg, closeTo(61.4, 0.001));
    expect(back.goalStartKg, closeTo(63, 0.001));
    expect(back.targetKg, closeTo(58, 0.001));
    expect(back.direction, Direction.lose);
    expect(back.pace, closeTo(0.4, 0.001));
    expect(back.activity, closeTo(1.375, 0.001));
    expect(back.protein, 110);
    expect(back.fat, 55);
    expect(back.carbs, 190);
    expect(back.waterMl, 2400);
    expect(back.theme, AppTheme.dark);
    expect(back.allergies.single.id, 'peanut');
    expect(back.allergies.single.severe, isTrue);
  });

  test('нікого чужого в профілі немає', () async {
    /* Демонстраційна людина має алергію на фундук і чотири спогади помічника
       про свої звички. Побачити їх у своєму профілі на першому запуску означало
       б прочитати про себе неправду. */
    await store.save(emptySettings());
    final back = await store.load();

    expect(back!.allergies, isEmpty);
    expect(back.memory, isEmpty);
    expect(initialSettings().allergies, isNotEmpty, reason: 'демо лишається демо');
    expect(initialSettings().memory, isNotEmpty);
  });

  test('другий запис оновлює той самий рядок, а не додає новий', () async {
    await store.save(emptySettings().copyWith(waterMl: 2000));
    await store.save(emptySettings().copyWith(waterMl: 2600));

    final rows = await db.select(db.profile).get();
    expect(rows, hasLength(1));
    expect(rows.single.waterMl, 2600);
  });

  test('усе записане стає в чергу на сервер', () async {
    await store.save(
      emptySettings().copyWith(allergies: const [Allergy(id: 'milk', severe: false)]),
    );

    final profile = await db.select(db.profile).getSingle();
    final weight = await db.select(db.weights).getSingle();
    final allergy = await db.select(db.allergies).getSingle();

    expect(profile.dirty, isTrue);
    expect(weight.dirty, isTrue);
    expect(allergy.dirty, isTrue);
  });

  test('знятий алерген видаляється мʼяко, а не зникає', () async {
    await store.save(
      emptySettings().copyWith(allergies: const [Allergy(id: 'milk', severe: false)]),
    );
    await store.save(emptySettings().copyWith(allergies: const []));

    final rows = await db.select(db.allergies).get();
    expect(rows, hasLength(1), reason: 'рядок лишається, щоб інший пристрій дізнався про зняття');
    expect(rows.single.deletedAt, isNotNull);
    expect(rows.single.dirty, isTrue);

    final back = await store.load();
    expect(back!.allergies, isEmpty);
  });

  test('вага пишеться раз на день, а не щоразу', () async {
    await store.save(emptySettings().copyWith(weightKg: 70));
    await store.save(emptySettings().copyWith(weightKg: 70.5));

    final rows = await db.select(db.weights).get();
    expect(rows, hasLength(1));
    expect(rows.single.kg, closeTo(70.5, 0.001));
  });
}
