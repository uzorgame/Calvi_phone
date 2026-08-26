// GENERATED FILE. Не правити руками.
//
// Джерело: Demo_Flutter_001/src/data/allergens.ts
// Оновити: node tools/allergens.mjs

/// Allergen reference.
///
/// Allergies are picked from this list, never typed in free text. The whole
/// point of the feature is that a warning fires on a **code**, matched against
/// an ingredient list, and not on the model recognising a word. Free text puts
/// the model back in the loop at exactly the place where being wrong is not a
/// cosmetic problem.
library;

import '../l10n/data_lang.dart';

class Allergen {
  const Allergen({
    required this.id,
    required this.nameUk,
    required this.nameEn,
    required this.groupUk,
    required this.groupEn,
    required this.akaUk,
    required this.akaEn,
  });

  /// Stable code. This is what the matcher compares, not the label.
  final String id;

  final String nameUk;
  final String nameEn;
  final String groupUk;
  final String groupEn;

  /* Синоніми обома мовами.
   *
   * Показується назва мовою інтерфейсу, а шукається [aka] цілком, обома
   * одразу. Це навмисно: склад продукту зі штрихкоду приходить так, як його
   * написав виробник, і на українській банці цілком буває `soy lecithin`.
   * Зайвий синонім у пошуку не коштує нічого, пропущений алерген коштує
   * дорого. */
  final List<String> akaUk;
  final List<String> akaEn;

  String get name => dataLang == 'uk' ? nameUk : nameEn;
  String get group => dataLang == 'uk' ? groupUk : groupEn;

  /// Усі синоніми, обома мовами. Саме за цим шукає і людина, і зіставлювач.
  List<String> get aka => [...akaUk, ...akaEn];
}

const allergens = <Allergen>[
  Allergen(
    id: 'peanut',
    nameUk: 'Арахіс',
    nameEn: 'Peanut',
    groupUk: 'Горіхи',
    groupEn: 'Nuts',
    akaUk: ['земляний горіх', 'арахісова паста'],
    akaEn: ['groundnut', 'peanut butter'],
  ),
  Allergen(
    id: 'hazelnut',
    nameUk: 'Фундук',
    nameEn: 'Hazelnut',
    groupUk: 'Горіхи',
    groupEn: 'Nuts',
    akaUk: ['лісовий горіх'],
    akaEn: ['filbert', 'cobnut'],
  ),
  Allergen(
    id: 'almond',
    nameUk: 'Мигдаль',
    nameEn: 'Almond',
    groupUk: 'Горіхи',
    groupEn: 'Nuts',
    akaUk: ['мигдальне молоко'],
    akaEn: ['almond milk', 'marzipan'],
  ),
  Allergen(
    id: 'walnut',
    nameUk: 'Волоський горіх',
    nameEn: 'Walnut',
    groupUk: 'Горіхи',
    groupEn: 'Nuts',
    akaUk: [],
    akaEn: [],
  ),
  Allergen(
    id: 'cashew',
    nameUk: 'Кешʼю',
    nameEn: 'Cashew',
    groupUk: 'Горіхи',
    groupEn: 'Nuts',
    akaUk: [],
    akaEn: [],
  ),
  Allergen(
    id: 'pistachio',
    nameUk: 'Фісташки',
    nameEn: 'Pistachio',
    groupUk: 'Горіхи',
    groupEn: 'Nuts',
    akaUk: [],
    akaEn: [],
  ),
  Allergen(
    id: 'pecan',
    nameUk: 'Пекан',
    nameEn: 'Pecan',
    groupUk: 'Горіхи',
    groupEn: 'Nuts',
    akaUk: [],
    akaEn: [],
  ),
  Allergen(
    id: 'macadamia',
    nameUk: 'Макадамія',
    nameEn: 'Macadamia',
    groupUk: 'Горіхи',
    groupEn: 'Nuts',
    akaUk: [],
    akaEn: [],
  ),
  Allergen(
    id: 'brazilnut',
    nameUk: 'Бразильський горіх',
    nameEn: 'Brazil nut',
    groupUk: 'Горіхи',
    groupEn: 'Nuts',
    akaUk: [],
    akaEn: [],
  ),
  Allergen(
    id: 'pinenut',
    nameUk: 'Кедровий горіх',
    nameEn: 'Pine nut',
    groupUk: 'Горіхи',
    groupEn: 'Nuts',
    akaUk: ['песто'],
    akaEn: ['pesto', 'pignoli'],
  ),
  Allergen(
    id: 'coconut',
    nameUk: 'Кокос',
    nameEn: 'Coconut',
    groupUk: 'Горіхи',
    groupEn: 'Nuts',
    akaUk: ['кокосове молоко', 'кокосова стружка'],
    akaEn: ['coconut milk', 'desiccated coconut'],
  ),
  Allergen(
    id: 'milk',
    nameUk: 'Молоко',
    nameEn: 'Milk',
    groupUk: 'Молочне',
    groupEn: 'Dairy',
    akaUk: ['вершки', 'сметана', 'сир', 'масло', 'сироватка'],
    akaEn: ['cream', 'sour cream', 'cheese', 'butter', 'whey'],
  ),
  Allergen(
    id: 'lactose',
    nameUk: 'Лактоза',
    nameEn: 'Lactose',
    groupUk: 'Молочне',
    groupEn: 'Dairy',
    akaUk: ['молочний цукор'],
    akaEn: ['milk sugar'],
  ),
  Allergen(
    id: 'casein',
    nameUk: 'Казеїн',
    nameEn: 'Casein',
    groupUk: 'Молочне',
    groupEn: 'Dairy',
    akaUk: ['казеїнат'],
    akaEn: ['caseinate'],
  ),
  Allergen(
    id: 'gluten',
    nameUk: 'Глютен',
    nameEn: 'Gluten',
    groupUk: 'Злаки',
    groupEn: 'Grains',
    akaUk: ['клейковина'],
    akaEn: ['seitan'],
  ),
  Allergen(
    id: 'wheat',
    nameUk: 'Пшениця',
    nameEn: 'Wheat',
    groupUk: 'Злаки',
    groupEn: 'Grains',
    akaUk: ['борошно', 'манка', 'булгур', 'кускус'],
    akaEn: ['flour', 'semolina', 'bulgur', 'couscous', 'spelt'],
  ),
  Allergen(
    id: 'rye',
    nameUk: 'Жито',
    nameEn: 'Rye',
    groupUk: 'Злаки',
    groupEn: 'Grains',
    akaUk: ['житнє борошно'],
    akaEn: ['rye flour'],
  ),
  Allergen(
    id: 'barley',
    nameUk: 'Ячмінь',
    nameEn: 'Barley',
    groupUk: 'Злаки',
    groupEn: 'Grains',
    akaUk: ['солод', 'перловка'],
    akaEn: ['malt', 'pearl barley'],
  ),
  Allergen(
    id: 'oat',
    nameUk: 'Овес',
    nameEn: 'Oats',
    groupUk: 'Злаки',
    groupEn: 'Grains',
    akaUk: ['вівсянка', 'вівсяне борошно'],
    akaEn: ['oatmeal', 'oat flour'],
  ),
  Allergen(
    id: 'buckwheat',
    nameUk: 'Гречка',
    nameEn: 'Buckwheat',
    groupUk: 'Злаки',
    groupEn: 'Grains',
    akaUk: ['гречане борошно', 'соба'],
    akaEn: ['buckwheat flour', 'soba'],
  ),
  Allergen(
    id: 'corn',
    nameUk: 'Кукурудза',
    nameEn: 'Corn',
    groupUk: 'Злаки',
    groupEn: 'Grains',
    akaUk: ['кукурудзяний крохмаль', 'попкорн', 'полента'],
    akaEn: ['corn starch', 'popcorn', 'polenta', 'maize'],
  ),
  Allergen(
    id: 'egg',
    nameUk: 'Яйця',
    nameEn: 'Egg',
    groupUk: 'Тваринні',
    groupEn: 'Animal',
    akaUk: ['білок', 'жовток', 'меланж', 'майонез'],
    akaEn: ['egg white', 'yolk', 'albumen', 'mayonnaise'],
  ),
  Allergen(
    id: 'fish',
    nameUk: 'Риба',
    nameEn: 'Fish',
    groupUk: 'Тваринні',
    groupEn: 'Animal',
    akaUk: ['тунець', 'лосось', 'оселедець', 'анчоуси'],
    akaEn: ['tuna', 'salmon', 'herring', 'anchovy'],
  ),
  Allergen(
    id: 'crustacean',
    nameUk: 'Ракоподібні',
    nameEn: 'Crustaceans',
    groupUk: 'Тваринні',
    groupEn: 'Animal',
    akaUk: ['креветки', 'краби', 'лангустини'],
    akaEn: ['shrimp', 'prawn', 'crab', 'lobster'],
  ),
  Allergen(
    id: 'mollusc',
    nameUk: 'Молюски',
    nameEn: 'Molluscs',
    groupUk: 'Тваринні',
    groupEn: 'Animal',
    akaUk: ['мідії', 'кальмар', 'устриці', 'восьминіг'],
    akaEn: ['mussels', 'squid', 'oyster', 'octopus'],
  ),
  Allergen(
    id: 'honey',
    nameUk: 'Мед',
    nameEn: 'Honey',
    groupUk: 'Тваринні',
    groupEn: 'Animal',
    akaUk: ['прополіс'],
    akaEn: ['propolis'],
  ),
  Allergen(
    id: 'gelatin',
    nameUk: 'Желатин',
    nameEn: 'Gelatin',
    groupUk: 'Тваринні',
    groupEn: 'Animal',
    akaUk: ['желе', 'маршмелоу'],
    akaEn: ['jelly', 'marshmallow', 'gelatine'],
  ),
  Allergen(
    id: 'soy',
    nameUk: 'Соя',
    nameEn: 'Soy',
    groupUk: 'Бобові',
    groupEn: 'Legumes',
    akaUk: ['соєвий соус', 'тофу', 'соєвий лецитин'],
    akaEn: ['soy sauce', 'tofu', 'soy lecithin', 'edamame'],
  ),
  Allergen(
    id: 'lupin',
    nameUk: 'Люпин',
    nameEn: 'Lupin',
    groupUk: 'Бобові',
    groupEn: 'Legumes',
    akaUk: ['люпинове борошно'],
    akaEn: ['lupin flour'],
  ),
  Allergen(
    id: 'legume',
    nameUk: 'Бобові',
    nameEn: 'Pulses',
    groupUk: 'Бобові',
    groupEn: 'Legumes',
    akaUk: ['квасоля', 'горох', 'нут', 'сочевиця'],
    akaEn: ['beans', 'peas', 'chickpeas', 'lentils'],
  ),
  Allergen(
    id: 'sesame',
    nameUk: 'Кунжут',
    nameEn: 'Sesame',
    groupUk: 'Рослинні',
    groupEn: 'Plants',
    akaUk: ['тахіні', 'кунжутна олія'],
    akaEn: ['tahini', 'sesame oil'],
  ),
  Allergen(
    id: 'mustard',
    nameUk: 'Гірчиця',
    nameEn: 'Mustard',
    groupUk: 'Рослинні',
    groupEn: 'Plants',
    akaUk: ['гірчичний порошок'],
    akaEn: ['mustard powder'],
  ),
  Allergen(
    id: 'celery',
    nameUk: 'Селера',
    nameEn: 'Celery',
    groupUk: 'Рослинні',
    groupEn: 'Plants',
    akaUk: ['корінь селери'],
    akaEn: ['celeriac'],
  ),
  Allergen(
    id: 'citrus',
    nameUk: 'Цитрусові',
    nameEn: 'Citrus',
    groupUk: 'Рослинні',
    groupEn: 'Plants',
    akaUk: ['апельсин', 'лимон', 'мандарин', 'грейпфрут'],
    akaEn: ['orange', 'lemon', 'mandarin', 'grapefruit'],
  ),
  Allergen(
    id: 'strawberry',
    nameUk: 'Полуниця',
    nameEn: 'Strawberry',
    groupUk: 'Рослинні',
    groupEn: 'Plants',
    akaUk: ['суниця'],
    akaEn: ['wild strawberry'],
  ),
  Allergen(
    id: 'kiwi',
    nameUk: 'Ківі',
    nameEn: 'Kiwi',
    groupUk: 'Рослинні',
    groupEn: 'Plants',
    akaUk: [],
    akaEn: [],
  ),
  Allergen(
    id: 'apple',
    nameUk: 'Яблуко',
    nameEn: 'Apple',
    groupUk: 'Рослинні',
    groupEn: 'Plants',
    akaUk: ['яблучний сік', 'пюре'],
    akaEn: ['apple juice', 'cider'],
  ),
  Allergen(
    id: 'banana',
    nameUk: 'Банан',
    nameEn: 'Banana',
    groupUk: 'Рослинні',
    groupEn: 'Plants',
    akaUk: [],
    akaEn: ['plantain'],
  ),
  Allergen(
    id: 'avocado',
    nameUk: 'Авокадо',
    nameEn: 'Avocado',
    groupUk: 'Рослинні',
    groupEn: 'Plants',
    akaUk: ['гуакамоле'],
    akaEn: ['guacamole'],
  ),
  Allergen(
    id: 'peach',
    nameUk: 'Персик',
    nameEn: 'Peach',
    groupUk: 'Рослинні',
    groupEn: 'Plants',
    akaUk: ['нектарин'],
    akaEn: ['nectarine'],
  ),
  Allergen(
    id: 'apricot',
    nameUk: 'Абрикос',
    nameEn: 'Apricot',
    groupUk: 'Рослинні',
    groupEn: 'Plants',
    akaUk: ['курага', 'урюк'],
    akaEn: ['dried apricot'],
  ),
  Allergen(
    id: 'plum',
    nameUk: 'Слива',
    nameEn: 'Plum',
    groupUk: 'Рослинні',
    groupEn: 'Plants',
    akaUk: ['чорнослив', 'алича'],
    akaEn: ['prune'],
  ),
  Allergen(
    id: 'cherry',
    nameUk: 'Вишня',
    nameEn: 'Cherry',
    groupUk: 'Рослинні',
    groupEn: 'Plants',
    akaUk: ['черешня'],
    akaEn: ['sweet cherry'],
  ),
  Allergen(
    id: 'tomato',
    nameUk: 'Помідор',
    nameEn: 'Tomato',
    groupUk: 'Рослинні',
    groupEn: 'Plants',
    akaUk: ['томатна паста', 'кетчуп'],
    akaEn: ['tomato paste', 'ketchup'],
  ),
  Allergen(
    id: 'cocoa',
    nameUk: 'Какао',
    nameEn: 'Cocoa',
    groupUk: 'Рослинні',
    groupEn: 'Plants',
    akaUk: ['шоколад'],
    akaEn: ['chocolate'],
  ),
  Allergen(
    id: 'sulphite',
    nameUk: 'Сульфіти',
    nameEn: 'Sulphites',
    groupUk: 'Додатки',
    groupEn: 'Additives',
    akaUk: ['діоксид сірки', 'E220', 'E221'],
    akaEn: ['sulfur dioxide', 'E220', 'E221'],
  ),
  Allergen(
    id: 'msg',
    nameUk: 'Глутамат натрію',
    nameEn: 'Monosodium glutamate',
    groupUk: 'Додатки',
    groupEn: 'Additives',
    akaUk: ['E621'],
    akaEn: ['MSG', 'E621'],
  ),
  Allergen(
    id: 'benzoate',
    nameUk: 'Бензоати',
    nameEn: 'Benzoates',
    groupUk: 'Додатки',
    groupEn: 'Additives',
    akaUk: ['E210', 'E211'],
    akaEn: ['E210', 'E211'],
  ),
  Allergen(
    id: 'tartrazine',
    nameUk: 'Тартразин',
    nameEn: 'Tartrazine',
    groupUk: 'Додатки',
    groupEn: 'Additives',
    akaUk: ['E102', 'жовтий барвник'],
    akaEn: ['E102', 'yellow 5'],
  ),
];

/// Групи в порядку появи: список на екрані читається згори вниз саме так.
List<String> get allergenGroups {
  final seen = <String>[];
  for (final a in allergens) {
    if (!seen.contains(a.group)) seen.add(a.group);
  }
  return seen;
}

Allergen? allergenById(String id) {
  for (final a in allergens) {
    if (a.id == id) return a;
  }
  return null;
}

/// Matches the label and every synonym, so «лісовий горіх» finds Фундук.
List<Allergen> searchAllergens(String q) {
  final s = q.trim().toLowerCase();
  if (s.isEmpty) return allergens;
  return [
    for (final a in allergens)
      if (a.nameUk.toLowerCase().contains(s) ||
          a.nameEn.toLowerCase().contains(s) ||
          a.aka.any((k) => k.toLowerCase().contains(s)))
        a,
  ];
}
