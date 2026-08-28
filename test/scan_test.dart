import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/remote/api.dart';

/// Про що говорить прочитаний штрихкод.
///
/// Сам сканер це камера, і в тесті її немає. А от що робиться зі знайденим
/// продуктом, перевірити можна й треба: саме тут числа з упаковки стають
/// записом у дні, і саме тут колись стояли вигадані «231 ккал на 130 г».
void main() {
  const yogurt = FoodHit(
    id: 'f-1',
    name: 'Йогурт грецький 5%',
    canonicalName: 'йогурт грецький',
    kcal: 97,
    proteinG: 9,
    fatG: 5,
    carbsG: 3.6,
    icon: 'yogurt',
    portionG: 130,
  );

  test('числа рахуються на порцію з упаковки, а не на сто грамів', () {
    final plate = yogurt.forGrams();

    expect(plate.grams, 130);
    expect(plate.kcal, 126, reason: '97 ккал на 100 г це 126 на 130 г');
    expect(plate.protein, closeTo(11.7, 0.01));
  });

  test('продукт без звичної порції рахується на сто грамів', () {
    const bar = FoodHit(
      id: 'f-2',
      name: 'Батончик',
      canonicalName: 'батончик',
      kcal: 480,
      proteinG: 6,
      fatG: 24,
      carbsG: 58,
      icon: 'sweet',
    );

    final plate = bar.forGrams();
    expect(plate.grams, 100);
    expect(plate.kcal, 480);
  });

  test('вагу можна назвати самому, і тоді рахується вона', () {
    final plate = yogurt.forGrams(200);

    expect(plate.grams, 200);
    expect(plate.kcal, 194);
  });

  test('розбір відповіді сервера не втрачає штрихкод і знак', () {
    final parsed = FoodHit.fromJson(const {
      'id': 'f-3',
      'source': 'off',
      'canonicalName': 'nutella',
      'name': 'Nutella',
      'kcal': 539,
      'proteinG': 6.3,
      'fatG': 30.9,
      'carbsG': 57.5,
      'icon': 'sweet',
      'portionG': null,
    });

    expect(parsed.name, 'Nutella');
    expect(parsed.kcal, 539);
    expect(parsed.icon, 'sweet');
    expect(parsed.portionG, isNull);
  });

  /* --- Порожнє поле ---
   *
   * Сир Karička, код 8586000411364. У відкритій базі в нього не заповнене поле
   * білка, а на упаковці написано 25 грамів. Застосунок малював «Б 0», і людина
   * на білковій цілі бачила число, якого не існує. */
  group('невідоме число лишається невідомим', () {
    final eidam = FoodHit.fromJson(
      const {
        'id': 'f-4',
        'canonicalName': 'eidam plátky karička',
        'name': 'Eidam plátky, KARIČKA',
        'kcal': 343,
        'proteinG': null,
        'fatG': 27,
        'carbsG': 1,
        'icon': 'cheese',
      },
      complete: false,
      missing: const ['protein'],
    );

    test('порожній білок не стає нулем', () {
      expect(eidam.proteinG, isNull, reason: 'нуль тут був би не обережністю, а неправдою');
      expect(eidam.fatG, 27);
      expect(eidam.complete, isFalse);
      expect(eidam.missing, ['protein']);
    });

    test('множення на вагу не робить невідоме відомим', () {
      final plate = eidam.forGrams(200);

      expect(plate.kcal, 686);
      expect(plate.fat, closeTo(54, 0.01));
      expect(plate.protein, isNull, reason: 'чого база не знає на 100 г, того не знає і на 200');
    });

    test('повнота за замовчуванням не ламає старий сервер', () {
      /* Старіший сервер про повноту нічого не каже. Тоді рядок вважається
         повним: так поводився застосунок і доти, і це не гірше за раптове
         «дочитай етикетку» на кожному товарі. */
      final old = FoodHit.fromJson(const {
        'id': 'f-5',
        'canonicalName': 'борщ',
        'name': 'Борщ',
        'kcal': 58,
        'proteinG': 2.1,
        'fatG': 2.6,
        'carbsG': 6.4,
        'icon': 'soup',
      });

      expect(old.complete, isTrue);
      expect(old.missing, isEmpty);
    });
  });

  /* --- Що взагалі є штрихкодом товару ---
   *
   * Сканер читає і QR, і Code128. Раніше будь-яке прочитане значення їхало на
   * сервер як штрихкод і поверталось як «не знаю цього коду»: звідси й бралось
   * відчуття, що застосунок сканує все і не знає нічого. */
  group('форма штрихкоду', () {
    final gtin = RegExp(r'^(\d{8}|\d{12,14})$');

    test('справжні коди з полиці проходять', () {
      for (final code in [
        '5201360531172', // 7DAYS, EAN-13
        '8586000411364', // Karička, EAN-13
        '4036300227645', // Kaufland, EAN-13
        '8716251043643', // яйця, EAN-13
        '049000006346', // UPC-A
        '20015823', // EAN-8
      ]) {
        expect(gtin.hasMatch(code), isTrue, reason: '$code це справжній штрихкод товару');
      }
    });

    test('усе інше штрихкодом товару не є', () {
      for (final read in [
        'https://calvi.uk/x', // QR із посиланням
        'WIFI:S:home;T:WPA;;', // QR мережі
        'L17041909 30 16', // код партії з пачки
        '1234567', // сім цифр: такого GTIN не буває
        '123456789012345', // пʼятнадцять цифр
      ]) {
        expect(gtin.hasMatch(read), isFalse, reason: '«$read» не має йти в пошук товару');
      }
    });
  });
}
