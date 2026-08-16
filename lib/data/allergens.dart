/// Allergen reference.
///
/// Allergies are picked from this list, never typed in free text. The whole
/// point of the feature is that a warning fires on a **code**, matched against
/// an ingredient list, and not on the model recognising a word. Free text puts
/// the model back in the loop at exactly the place where being wrong is not a
/// cosmetic problem.
///
/// [aka] exists so the same entry is found by whatever the person calls it, and
/// so the ingredient matcher has the synonyms it needs. It never becomes a
/// separate allergen.
///
/// Generated from Demo_Flutter/src/data/allergens.ts by tools/allergens.mjs.
library;

class Allergen {
  const Allergen({
    required this.id,
    required this.name,
    required this.group,
    required this.aka,
  });

  /// Stable code. This is what the matcher compares, not the label.
  final String id;
  final String name;
  final String group;
  final List<String> aka;
}

const allergens = <Allergen>[
  Allergen(
    id: 'peanut',
    name: 'Арахіс',
    group: 'Горіхи',
    aka: ['земляний горіх', 'арахісова паста'],
  ),
  Allergen(id: 'hazelnut', name: 'Фундук', group: 'Горіхи', aka: ['лісовий горіх']),
  Allergen(id: 'almond', name: 'Мигдаль', group: 'Горіхи', aka: ['мигдальне молоко']),
  Allergen(id: 'walnut', name: 'Волоський горіх', group: 'Горіхи', aka: []),
  Allergen(id: 'cashew', name: 'Кешʼю', group: 'Горіхи', aka: []),
  Allergen(id: 'pistachio', name: 'Фісташки', group: 'Горіхи', aka: []),
  Allergen(id: 'pecan', name: 'Пекан', group: 'Горіхи', aka: []),
  Allergen(id: 'macadamia', name: 'Макадамія', group: 'Горіхи', aka: []),
  Allergen(id: 'brazilnut', name: 'Бразильський горіх', group: 'Горіхи', aka: []),
  Allergen(
    id: 'milk',
    name: 'Молоко',
    group: 'Молочне',
    aka: ['вершки', 'сметана', 'сир', 'масло'],
  ),
  Allergen(id: 'lactose', name: 'Лактоза', group: 'Молочне', aka: ['молочний цукор']),
  Allergen(id: 'casein', name: 'Казеїн', group: 'Молочне', aka: ['казеїнат']),
  Allergen(id: 'gluten', name: 'Глютен', group: 'Злаки', aka: ['клейковина']),
  Allergen(
    id: 'wheat',
    name: 'Пшениця',
    group: 'Злаки',
    aka: ['борошно', 'манка', 'булгур', 'кускус'],
  ),
  Allergen(id: 'rye', name: 'Жито', group: 'Злаки', aka: ['житнє борошно']),
  Allergen(id: 'barley', name: 'Ячмінь', group: 'Злаки', aka: ['солод', 'перловка']),
  Allergen(id: 'oat', name: 'Овес', group: 'Злаки', aka: ['вівсянка', 'вівсяне борошно']),
  Allergen(
    id: 'egg',
    name: 'Яйця',
    group: 'Тваринні',
    aka: ['білок', 'жовток', 'меланж', 'майонез'],
  ),
  Allergen(
    id: 'fish',
    name: 'Риба',
    group: 'Тваринні',
    aka: ['тунець', 'лосось', 'оселедець', 'анчоуси'],
  ),
  Allergen(
    id: 'crustacean',
    name: 'Ракоподібні',
    group: 'Тваринні',
    aka: ['креветки', 'краби', 'лангустини'],
  ),
  Allergen(
    id: 'mollusc',
    name: 'Молюски',
    group: 'Тваринні',
    aka: ['мідії', 'кальмар', 'устриці', 'восьминіг'],
  ),
  Allergen(id: 'honey', name: 'Мед', group: 'Тваринні', aka: ['прополіс']),
  Allergen(
    id: 'soy',
    name: 'Соя',
    group: 'Бобові',
    aka: ['соєвий соус', 'тофу', 'соєвий лецитин'],
  ),
  Allergen(id: 'lupin', name: 'Люпин', group: 'Бобові', aka: ['люпинове борошно']),
  Allergen(
    id: 'legume',
    name: 'Бобові',
    group: 'Бобові',
    aka: ['квасоля', 'горох', 'нут', 'сочевиця'],
  ),
  Allergen(id: 'sesame', name: 'Кунжут', group: 'Рослинні', aka: ['тахіні', 'кунжутна олія']),
  Allergen(id: 'mustard', name: 'Гірчиця', group: 'Рослинні', aka: ['гірчичний порошок']),
  Allergen(id: 'celery', name: 'Селера', group: 'Рослинні', aka: ['корінь селери']),
  Allergen(
    id: 'citrus',
    name: 'Цитрусові',
    group: 'Рослинні',
    aka: ['апельсин', 'лимон', 'мандарин', 'грейпфрут'],
  ),
  Allergen(id: 'strawberry', name: 'Полуниця', group: 'Рослинні', aka: ['суниця']),
  Allergen(id: 'kiwi', name: 'Ківі', group: 'Рослинні', aka: []),
  Allergen(id: 'peach', name: 'Персик', group: 'Рослинні', aka: ['нектарин', 'абрикос']),
  Allergen(id: 'tomato', name: 'Помідор', group: 'Рослинні', aka: ['томатна паста', 'кетчуп']),
  Allergen(id: 'cocoa', name: 'Какао', group: 'Рослинні', aka: ['шоколад']),
  Allergen(
    id: 'sulphite',
    name: 'Сульфіти',
    group: 'Додатки',
    aka: ['діоксид сірки', 'E220', 'E221'],
  ),
  Allergen(id: 'msg', name: 'Глутамат натрію', group: 'Додатки', aka: ['E621']),
  Allergen(id: 'benzoate', name: 'Бензоати', group: 'Додатки', aka: ['E210', 'E211']),
];

Allergen? allergenById(String id) {
  for (final a in allergens) {
    if (a.id == id) return a;
  }
  return null;
}

/// Group names in the order the reference lists them.
List<String> get allergenGroups {
  final seen = <String>[];
  for (final a in allergens) {
    if (!seen.contains(a.group)) seen.add(a.group);
  }
  return seen;
}

/// Found by whatever the person calls it, not only by the printed name.
List<Allergen> searchAllergens(String q) {
  final s = q.trim().toLowerCase();
  if (s.isEmpty) return allergens;
  return allergens
      .where(
        (a) =>
            a.name.toLowerCase().contains(s) || a.aka.any((k) => k.toLowerCase().contains(s)),
      )
      .toList();
}
