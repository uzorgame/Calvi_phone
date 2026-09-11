import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/day_reader.dart';
import 'package:calvi/data/local/profile_store.dart';
import 'package:calvi/data/nutrients.dart';
import 'package:calvi/data/remote/api.dart';
import 'package:calvi/data/remote/sync_mapping.dart';
import 'package:calvi/data/settings.dart';

/// Другий рівень нутрієнтів від дроту до екрана.
///
/// Одне правило перевіряється тут знову і знову, в кожному місці, де числа
/// міняють руки: порожнє і нуль це різні речі. Нуль каже «цього тут немає», а
/// порожнє каже «ще не знаємо», і сплутати їх означає намалювати людині чужий
/// день. Один `?? 0` у розборі відповіді зробив би всі минулорічні записи
/// стравами без клітковини, і побачити це на екрані було б уже неможливо.
void main() {
  group('сума за день', () {
    test('порожнє не рахується нулем, а рахується окремо', () {
      final day = nutrientsOver(const [
        Nutrients(fiber: 4, sugar: 6, sodiumMg: 300),
        Nutrients(sugar: 2),
        Nutrients.none,
      ]);

      expect(day.sum.fiber, 4);
      expect(day.sum.sugar, 8);
      expect(day.unknown[NutrientKey.fiber], 2, reason: 'двох страв бракує, а не нуля');
      expect(day.unknown[NutrientKey.sugar], 1);
      expect(day.counted, 3);

      expect(day.known(NutrientKey.fiber), isTrue);
      expect(day.whole(NutrientKey.fiber), isFalse, reason: 'картина неповна, і це має бути видно');
    });

    test('день, про який не відомо нічого, не показує нуль', () {
      final day = nutrientsOver(const [Nutrients.none, Nutrients.none]);
      expect(day.sum.fiber, isNull);
      expect(day.known(NutrientKey.sat), isFalse);
    });

    test('чесний нуль лишається нулем', () {
      final day = nutrientsOver(const [Nutrients(fiber: 0)]);
      expect(day.sum.fiber, 0, reason: 'у мʼясі справді немає клітковини');
      expect(day.known(NutrientKey.fiber), isTrue);
      expect(day.whole(NutrientKey.fiber), isTrue);
    });

    test('порожній день не падає', () {
      final day = nutrientsOver(const []);
      expect(day.counted, 0);
      expect(day.sum.knownAny, isFalse);
    });
  });

  group('норми', () {
    test('клітковина рахується від калорій, але не нижче двадцяти пʼяти', () {
      expect(nutrientGoals(1400).fiber, 25, reason: 'нижня межа EFSA, а не 19.6');
      expect(nutrientGoals(2500).fiber, 35);
    });

    test('доданий цукор це десята частина калорій, а бажаніше двадцята', () {
      final g = nutrientGoals(2000);
      expect(g.added, 50);
      expect(g.addedBetter, 25);
      expect(g.sat, 22);
    });

    test('натрій не залежить від калорій', () {
      expect(nutrientGoals(1500).sodiumMg, nutrientGoals(3000).sodiumMg);
    });

    test('у загального цукру норми немає навмисно', () {
      expect(nutrientGoals(2000).of(NutrientKey.sugar), isNull);
      expect(nutrientGoals(2000).of(NutrientKey.added), 50);
    });

    test('сіль це натрій, помножений на два з половиною', () {
      expect(saltFrom(2000), closeTo(5, 0.001));
    });
  });

  group('відповідь Нори', () {
    Map<String, dynamic> reply(Map<String, dynamic> meal) => {
      'text': 'Записала',
      'balance': 10,
      'logged': [
        {'id': 'm1', 'slot': 'lunch', 'day': '2026-09-11', 'name': 'Борщ', 'kcal': 210, ...meal},
      ],
    };

    test('пʼять чисел приїжджають разом із рештою рядка', () {
      final answer = NoraReply.fromWire(
        reply({'fiber_g': 3.4, 'sugar_g': 5, 'added_sugar_g': 0, 'sodium_mg': 820, 'sat_fat_g': 2}),
        slot: 'lunch',
        day: '2026-09-11',
      );

      final m = answer.logged.single.nutrients;
      expect(m.fiber, 3.4);
      expect(m.added, 0, reason: 'нуль сказаний сервером це відповідь, а не мовчання');
      expect(m.sodiumMg, 820);
    });

    test('стара відповідь без цих полів лишає їх порожніми', () {
      final answer = NoraReply.fromWire(reply(const {}), slot: 'lunch', day: '2026-09-11');
      final m = answer.logged.single.nutrients;
      expect(m.knownAny, isFalse, reason: 'сервер мовчав, а не сказав нуль');
      expect(m.fiber, isNull);
    });

    test('виправлений рядок везе перерахований другий рівень', () {
      final answer = NoraReply.fromWire({
        'text': 'Виправила',
        'balance': 9,
        'fixed': [
          {'id': 'm1', 'name': 'Борщ', 'kcal': 420, 'grams': 600, 'fiber_g': 6.8, 'sodium_mg': 1640},
        ],
      }, slot: 'lunch', day: '2026-09-11');

      expect(answer.fixed.single.nutrients.fiber, 6.8);
      expect(answer.fixed.single.nutrients.sugar, isNull);
    });
  });

  group('довідник', () {
    FoodHit hit(Map<String, dynamic> extra) => FoodHit.fromJson({
      'id': 'f1',
      'name': 'Хліб',
      'canonicalName': 'хліб пшеничний',
      'kcal': 260,
      'proteinG': 8.0,
      'fatG': 3.0,
      'carbsG': 49.0,
      ...extra,
    });

    test('пʼятірка приїжджає окремим обʼєктом і своїми іменами', () {
      final food = hit({
        'tier': {'fiberG': 2.7, 'sugarG': 3.1, 'addedSugarG': null, 'sodiumMg': 480.0},
      });

      expect(food.tier.fiber, 2.7);
      expect(food.tier.added, isNull, reason: 'null у полі це не нуль');
      expect(food.tier.sat, isNull, reason: 'поля не було взагалі');
    });

    test('гілка вимкнена: обʼєкта немає, і це не падіння', () {
      expect(hit(const {}).tier.knownAny, isFalse);
    });

    test('вага множить відоме і не робить відомим порожнє', () {
      final plate = hit({
        'tier': {'fiberG': 2.0, 'sodiumMg': 400.0},
      }).forGrams(250);

      expect(plate.tier.fiber, closeTo(5, 0.001));
      expect(plate.tier.sodiumMg, closeTo(1000, 0.001));
      expect(plate.tier.sugar, isNull, reason: 'множення порожнього дало число');
    });
  });

  group('база телефона', () {
    late CalviDb db;

    setUp(() => db = CalviDb(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('записане з відповіді читається назад тим самим', () async {
      final at = DateTime(2026, 9, 11, 13, 5);
      await db.diaryDao.putServerMeal(
        id: 'm1',
        day: '2026-09-11',
        slot: 'lunch',
        name: 'Борщ',
        kcal: 210,
        at: at,
        grams: 300,
        nutrients: const Nutrients(fiber: 3.4, sugar: 5, added: 0, sodiumMg: 820, sat: 2.1),
      );

      final day = await DayReader(db).read(at);
      final meal = day.meals.single;
      expect(meal.nutrients.fiber, 3.4, reason: 'дробове не має округлятись до цілих');
      expect(meal.nutrients.added, 0);
      expect(meal.nutrients.sat, 2.1);
    });

    test('страва без цих чисел лишається без них', () async {
      final at = DateTime(2026, 9, 11, 8, 20);
      await db.diaryDao.putServerMeal(
        id: 'm2',
        day: '2026-09-11',
        slot: 'breakfast',
        name: 'Яєчня',
        kcal: 214,
        at: at,
      );

      final day = await DayReader(db).read(at);
      expect(day.meals.single.nutrients.knownAny, isFalse);
    });

    test('виправлення без цих чисел не стирає вже відомі', () async {
      final at = DateTime(2026, 9, 11, 13, 5);
      await db.diaryDao.putServerMeal(
        id: 'm3',
        day: '2026-09-11',
        slot: 'lunch',
        name: 'Борщ',
        kcal: 210,
        at: at,
        nutrients: const Nutrients(fiber: 3.4, sodiumMg: 820),
      );

      /* Гілка вимкнена або відповідає стара версія: про другий рівень не сказано
         нічого. Калорії міняються, клітковина лишається. */
      await db.diaryDao.patchServerMeal(id: 'm3', name: 'Борщ', kcal: 420, grams: 600);

      final day = await DayReader(db).read(at);
      expect(day.meals.single.kcal, 420);
      expect(day.meals.single.nutrients.fiber, 3.4, reason: 'мовчання стерло відоме число');
    });

    test('вага, поправлена рукою, тягне за собою і пʼятірку', () async {
      final at = DateTime(2026, 9, 11, 13, 5);
      await db.diaryDao.putServerMeal(
        id: 'm6',
        day: '2026-09-11',
        slot: 'lunch',
        name: 'Борщ',
        kcal: 210,
        at: at,
        grams: 300,
        nutrients: const Nutrients(fiber: 3, sodiumMg: 840),
      );

      /* Людина відкрила картку і сказала «шістсот». Калорії подвоїлись на
         екрані, і другий рівень має подвоїтись разом із ними. */
      final before = (await DayReader(db).read(at)).meals.single;
      await db.diaryDao.reweighMeal(
        'm6',
        grams: 600,
        kcal: 420,
        protein: 28,
        fat: 16,
        carbs: 40,
        nutrients: before.nutrients.scaled(2),
      );

      final after = (await DayReader(db).read(at)).meals.single;
      expect(after.nutrients.fiber, 6, reason: 'клітковина лишилась від старої ваги');
      expect(after.nutrients.sodiumMg, 1680);
      expect(after.nutrients.sugar, isNull, reason: 'множення порожнього дало число');
    });

    test('виправлення з числами переписує всю пʼятірку', () async {
      final at = DateTime(2026, 9, 11, 13, 5);
      await db.diaryDao.putServerMeal(
        id: 'm4',
        day: '2026-09-11',
        slot: 'lunch',
        name: 'Борщ',
        kcal: 210,
        at: at,
        nutrients: const Nutrients(fiber: 3.4, sugar: 5, sodiumMg: 820),
      );

      /* Вага подвоїлась, сервер перерахував усе разом. Цукор у новій пʼятірці
         порожній, і лишити старий означало б тримати в рядку число від
         попередньої ваги. */
      await db.diaryDao.patchServerMeal(
        id: 'm4',
        name: 'Борщ',
        kcal: 420,
        grams: 600,
        nutrients: const Nutrients(fiber: 6.8, sodiumMg: 1640),
      );

      final day = await DayReader(db).read(at);
      expect(day.meals.single.nutrients.fiber, 6.8);
      expect(day.meals.single.nutrients.sugar, isNull);
    });
  });

  group('синхронізація', () {
    test('порожнє їде порожнім в обидва боки', () {
      final wire = mealFromChange({
        'id': 'm5',
        'updated_at': '2026-09-11T10:05:00Z',
        'seq': 12,
        'data': {
          'day': '2026-09-11',
          'at': '2026-09-11T10:05:00Z',
          'slot': 'lunch',
          'name': 'Борщ',
          'kcal': 210,
          'fiber_g': 3.4,
          'sugar_g': null,
        },
      });

      expect(wire.fiberG.value, 3.4);
      expect(wire.sugarG.value, isNull, reason: 'null з сервера це не нуль на телефоні');
    });
  });

  group('профіль проводом', () {
    Map<String, dynamic> wire(Map<String, dynamic> extra) => {
      'updated_at': '2026-09-11T10:05:00Z',
      'sex': 'm',
      'direction': 'lose',
      'pace': 0.5,
      'activity': 1.55,
      'water_ml': 2200,
      'theme': 'system',
      ...extra,
    };

    test('сервер, який про руку з сіллю не знає, не скидає вибір', () {
      final back = profileFromWire(wire(const {}), id: 'me');
      expect(
        back.saltHand.present,
        isFalse,
        reason: 'мовчання старого сервера стерло вибір людини',
      );
    });

    test('а коли він її прислав, слово за ним', () {
      expect(profileFromWire(wire({'salt_hand': 'less'}), id: 'me').saltHand.value, 'less');
      expect(profileFromWire(wire({'salt_hand': null}), id: 'me').saltHand.value, isNull);
    });

    test('вигляд нутрієнтів лишається на телефоні', () {
      /* Це вибір вигляду, а не властивість людини: сервер про нього не знає і
         не має знати, тому синхронізація його не чіпає взагалі. */
      expect(profileFromWire(wire(const {}), id: 'me').nutri.present, isFalse);
    });
  });

  group('профіль', () {
    late CalviDb db;

    setUp(() => db = CalviDb(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('вибір вигляду і рука з сіллю переживають перезапуск', () async {
      final store = ProfileStore(db);
      await store.save(
        initialSettings().copyWith(nutri: NutriLevel.large, saltHand: SaltHand.less),
      );

      final back = await store.load();
      expect(back!.nutri, NutriLevel.large);
      expect(back.saltHand, SaltHand.less);
    });

    test('той, хто вже живе в застосунку, отримує малий вигляд і звичайну сіль', () async {
      final store = ProfileStore(db);
      await store.save(initialSettings());

      final back = await store.load();
      expect(back!.nutri, NutriLevel.small, reason: 'стандарт це малий рядок');
      expect(back.saltHand, SaltHand.usual);
    });
  });
}
