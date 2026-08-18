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
}
