import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/local/database.dart' hide Allergy;
import 'package:calvi/data/local/profile_store.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/screens/start/start_screen.dart';

/// Те, що людина ввела на «Старті», має дійти до диска без втрат.
///
/// Шлях довгий і кожен його стик мовчазний: чернетка «Старту» кладеться в
/// налаштування, налаштування пишуться в базу, база читається на наступному
/// запуску. Загублене поле ніде не падає, воно просто тихо стає типовим, і
/// людина бачить чужий зріст у своєму профілі.
void main() {
  late CalviDb db;
  late ProfileStore store;

  setUp(() {
    db = CalviDb(NativeDatabase.memory());
    store = ProfileStore(db);
  });
  tearDown(() => db.close());

  const draft = StartDraft(
    sex: Sex.f,
    age: 34,
    heightCm: 167,
    weightKg: 61.4,
    direction: Direction.gain,
    targetKg: 65,
    pace: 0.3,
    activity: 1.375,
    allergies: ['peanut', 'milk'],
    protein: 110,
    fat: 55,
    carbs: 190,
  );

  test('чернетка «Старту» доходить до диска цілою', () async {
    await store.save(draft.applyTo(emptySettings()));
    final back = await store.load();

    expect(back, isNotNull, reason: 'профіль не записався зовсім');
    expect(back!.sex, Sex.f);
    expect(back.age, 34);
    expect(back.heightCm, 167);
    expect(back.weightKg, closeTo(61.4, 0.001));
    expect(back.direction, Direction.gain);
    expect(back.targetKg, closeTo(65, 0.001));
    expect(back.pace, closeTo(0.3, 0.001));
    expect(back.activity, closeTo(1.375, 0.001));
    expect(back.protein, 110);
    expect(back.fat, 55);
    expect(back.carbs, 190);
  });

  test('вага на старті стає початком цілі, а не тільки сьогоднішнім числом', () async {
    /* Кільце цілі рахується від ваги на момент, коли ціль поставили. Якби сюди
       підставлялась поточна вага, воно завжди показувало б нуль пройденого. */
    await store.save(draft.applyTo(emptySettings()));
    final back = await store.load();

    expect(back!.goalStartKg, closeTo(61.4, 0.001));
  });

  test('алергії зі «Старту» лягають у базу, а не лишаються в памʼяті', () async {
    await store.save(draft.applyTo(emptySettings()));
    final back = await store.load();

    expect(back!.allergies.map((a) => a.id).toSet(), {'peanut', 'milk'});
  });

  test('норма лишається порахованою, а не зафіксованою числом', () async {
    /* `kcalManual` порожній означає «рахуй щоразу». Якби «Старт» записав туди
       число, норма застигла б назавжди: вага падає, ціль наближається, а
       застосунок і далі показує ту саму цифру, що й у перший день. */
    await store.save(draft.applyTo(emptySettings()));
    final back = await store.load();

    expect(back!.kcalManual, isNull);
  });

  test('нічого чужого зі «Старту» не приїжджає', () async {
    await store.save(draft.applyTo(emptySettings()));
    final back = await store.load();

    expect(back!.memory, isEmpty, reason: 'спогади демонстраційної людини');
    expect(back.allergies.any((a) => a.id == 'hazelnut'), isFalse);
  });
}
