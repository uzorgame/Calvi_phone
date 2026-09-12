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
    required this.names,
    required this.groups,
    required this.akas,
  });

  /// Stable code. This is what the matcher compares, not the label.
  final String id;

  /// Назва мовою: ключ це код мови, як у `dataLang`.
  final Map<String, String> names;
  final Map<String, String> groups;

  /* Синоніми, кожною мовою окремо.
   *
   * Показується список своєї мови, а шукається [aka], тобто всі мови разом.
   * Це навмисно: склад продукту зі штрихкоду приходить так, як його написав
   * виробник, і на українській банці цілком буває `soy lecithin`, а на
   * іспанській `lecitina de soja`. Зайвий синонім у пошуку не коштує нічого,
   * пропущений алерген коштує дорого. */
  final Map<String, List<String>> akas;

  /* Мова, якої в довіднику немає, дістає англійську: та сама запасна, що й у
     `supportedLocales`. */
  String get name => names[dataLang] ?? names['en']!;
  String get group => groups[dataLang] ?? groups['en']!;

  /// Синоніми мовою інтерфейсу: те, що стоїть під назвою на екрані.
  List<String> get akaShown => akas[dataLang] ?? akas['en'] ?? const [];

  /// Усі синоніми, всіма мовами. Саме за цим шукає зіставлювач складу.
  List<String> get aka => [for (final one in akas.values) ...one];
}

const allergens = <Allergen>[
  Allergen(
    id: 'peanut',
    names: {'uk': 'Арахіс', 'en': 'Peanut', 'es': 'Cacahuete', 'it': 'Arachide', 'de': 'Erdnuss', 'fr': 'Arachide', 'pt': 'Amendoim', 'pl': 'Orzeszki ziemne', 'cs': 'Arašídy', 'ru': 'Арахис', 'be': 'Арахіс'},
    groups: {'uk': 'Горіхи', 'en': 'Nuts', 'es': 'Frutos secos', 'it': 'Frutta secca', 'de': 'Nüsse', 'fr': 'Fruits à coque', 'pt': 'Castanhas', 'pl': 'Orzechy', 'cs': 'Ořechy', 'ru': 'Орехи', 'be': 'Арэхі'},
    akas: {'uk': ['земляний горіх', 'арахісова паста'], 'en': ['groundnut', 'peanut butter'], 'es': ['maní', 'crema de cacahuete'], 'it': ['burro di arachidi'], 'de': ['Erdnussbutter'], 'fr': ['cacahuète', 'beurre de cacahuète'], 'pt': ['pasta de amendoim'], 'pl': ['masło orzechowe', 'fistaszki'], 'cs': ['podzemnice olejná', 'arašídové máslo'], 'ru': ['земляной орех', 'арахисовая паста'], 'be': ['земляны арэх', 'арахісавая паста']},
  ),
  Allergen(
    id: 'hazelnut',
    names: {'uk': 'Фундук', 'en': 'Hazelnut', 'es': 'Avellana', 'it': 'Nocciola', 'de': 'Haselnuss', 'fr': 'Noisette', 'pt': 'Avelã', 'pl': 'Orzech laskowy', 'cs': 'Lískový ořech', 'ru': 'Фундук', 'be': 'Фундук'},
    groups: {'uk': 'Горіхи', 'en': 'Nuts', 'es': 'Frutos secos', 'it': 'Frutta secca', 'de': 'Nüsse', 'fr': 'Fruits à coque', 'pt': 'Castanhas', 'pl': 'Orzechy', 'cs': 'Ořechy', 'ru': 'Орехи', 'be': 'Арэхі'},
    akas: {'uk': ['лісовий горіх'], 'en': ['filbert', 'cobnut'], 'es': [], 'it': [], 'de': [], 'fr': [], 'pt': [], 'pl': [], 'cs': [], 'ru': ['лесной орех'], 'be': ['лясны арэх']},
  ),
  Allergen(
    id: 'almond',
    names: {'uk': 'Мигдаль', 'en': 'Almond', 'es': 'Almendra', 'it': 'Mandorla', 'de': 'Mandel', 'fr': 'Amande', 'pt': 'Amêndoa', 'pl': 'Migdał', 'cs': 'Mandle', 'ru': 'Миндаль', 'be': 'Міндаль'},
    groups: {'uk': 'Горіхи', 'en': 'Nuts', 'es': 'Frutos secos', 'it': 'Frutta secca', 'de': 'Nüsse', 'fr': 'Fruits à coque', 'pt': 'Castanhas', 'pl': 'Orzechy', 'cs': 'Ořechy', 'ru': 'Орехи', 'be': 'Арэхі'},
    akas: {'uk': ['мигдальне молоко'], 'en': ['almond milk', 'marzipan'], 'es': ['leche de almendras', 'mazapán'], 'it': ['latte di mandorla', 'marzapane'], 'de': ['Mandelmilch', 'Marzipan'], 'fr': ['lait d\'amande', 'massepain'], 'pt': ['leite de amêndoa', 'marzipã'], 'pl': ['mleko migdałowe', 'marcepan'], 'cs': ['mandlové mléko', 'marcipán'], 'ru': ['миндальное молоко', 'марципан'], 'be': ['міндальнае малако', 'марцыпан']},
  ),
  Allergen(
    id: 'walnut',
    names: {'uk': 'Волоський горіх', 'en': 'Walnut', 'es': 'Nuez', 'it': 'Noce', 'de': 'Walnuss', 'fr': 'Noix', 'pt': 'Noz', 'pl': 'Orzech włoski', 'cs': 'Vlašský ořech', 'ru': 'Грецкий орех', 'be': 'Грэцкі арэх'},
    groups: {'uk': 'Горіхи', 'en': 'Nuts', 'es': 'Frutos secos', 'it': 'Frutta secca', 'de': 'Nüsse', 'fr': 'Fruits à coque', 'pt': 'Castanhas', 'pl': 'Orzechy', 'cs': 'Ořechy', 'ru': 'Орехи', 'be': 'Арэхі'},
    akas: {'uk': [], 'en': [], 'es': [], 'it': [], 'de': [], 'fr': [], 'pt': [], 'pl': [], 'cs': [], 'ru': [], 'be': []},
  ),
  Allergen(
    id: 'cashew',
    names: {'uk': 'Кешʼю', 'en': 'Cashew', 'es': 'Anacardo', 'it': 'Anacardo', 'de': 'Cashew', 'fr': 'Noix de cajou', 'pt': 'Castanha de caju', 'pl': 'Nerkowiec', 'cs': 'Kešu', 'ru': 'Кешью', 'be': 'Кешʼю'},
    groups: {'uk': 'Горіхи', 'en': 'Nuts', 'es': 'Frutos secos', 'it': 'Frutta secca', 'de': 'Nüsse', 'fr': 'Fruits à coque', 'pt': 'Castanhas', 'pl': 'Orzechy', 'cs': 'Ořechy', 'ru': 'Орехи', 'be': 'Арэхі'},
    akas: {'uk': [], 'en': [], 'es': [], 'it': [], 'de': [], 'fr': [], 'pt': [], 'pl': [], 'cs': [], 'ru': [], 'be': []},
  ),
  Allergen(
    id: 'pistachio',
    names: {'uk': 'Фісташки', 'en': 'Pistachio', 'es': 'Pistacho', 'it': 'Pistacchio', 'de': 'Pistazie', 'fr': 'Pistache', 'pt': 'Pistache', 'pl': 'Pistacja', 'cs': 'Pistácie', 'ru': 'Фисташки', 'be': 'Фісташкі'},
    groups: {'uk': 'Горіхи', 'en': 'Nuts', 'es': 'Frutos secos', 'it': 'Frutta secca', 'de': 'Nüsse', 'fr': 'Fruits à coque', 'pt': 'Castanhas', 'pl': 'Orzechy', 'cs': 'Ořechy', 'ru': 'Орехи', 'be': 'Арэхі'},
    akas: {'uk': [], 'en': [], 'es': [], 'it': [], 'de': [], 'fr': [], 'pt': [], 'pl': [], 'cs': [], 'ru': [], 'be': []},
  ),
  Allergen(
    id: 'pecan',
    names: {'uk': 'Пекан', 'en': 'Pecan', 'es': 'Pacana', 'it': 'Noce pecan', 'de': 'Pekannuss', 'fr': 'Noix de pécan', 'pt': 'Noz-pecã', 'pl': 'Orzech pekan', 'cs': 'Pekanový ořech', 'ru': 'Пекан', 'be': 'Пекан'},
    groups: {'uk': 'Горіхи', 'en': 'Nuts', 'es': 'Frutos secos', 'it': 'Frutta secca', 'de': 'Nüsse', 'fr': 'Fruits à coque', 'pt': 'Castanhas', 'pl': 'Orzechy', 'cs': 'Ořechy', 'ru': 'Орехи', 'be': 'Арэхі'},
    akas: {'uk': [], 'en': [], 'es': [], 'it': [], 'de': [], 'fr': [], 'pt': [], 'pl': [], 'cs': [], 'ru': [], 'be': []},
  ),
  Allergen(
    id: 'macadamia',
    names: {'uk': 'Макадамія', 'en': 'Macadamia', 'es': 'Macadamia', 'it': 'Macadamia', 'de': 'Macadamia', 'fr': 'Macadamia', 'pt': 'Macadâmia', 'pl': 'Makadamia', 'cs': 'Makadamový ořech', 'ru': 'Макадамия', 'be': 'Макадамія'},
    groups: {'uk': 'Горіхи', 'en': 'Nuts', 'es': 'Frutos secos', 'it': 'Frutta secca', 'de': 'Nüsse', 'fr': 'Fruits à coque', 'pt': 'Castanhas', 'pl': 'Orzechy', 'cs': 'Ořechy', 'ru': 'Орехи', 'be': 'Арэхі'},
    akas: {'uk': [], 'en': [], 'es': [], 'it': [], 'de': [], 'fr': [], 'pt': [], 'pl': [], 'cs': [], 'ru': [], 'be': []},
  ),
  Allergen(
    id: 'brazilnut',
    names: {'uk': 'Бразильський горіх', 'en': 'Brazil nut', 'es': 'Nuez de Brasil', 'it': 'Noce del Brasile', 'de': 'Paranuss', 'fr': 'Noix du Brésil', 'pt': 'Castanha-do-pará', 'pl': 'Orzech brazylijski', 'cs': 'Para ořech', 'ru': 'Бразильский орех', 'be': 'Бразільскі арэх'},
    groups: {'uk': 'Горіхи', 'en': 'Nuts', 'es': 'Frutos secos', 'it': 'Frutta secca', 'de': 'Nüsse', 'fr': 'Fruits à coque', 'pt': 'Castanhas', 'pl': 'Orzechy', 'cs': 'Ořechy', 'ru': 'Орехи', 'be': 'Арэхі'},
    akas: {'uk': [], 'en': [], 'es': [], 'it': [], 'de': [], 'fr': [], 'pt': [], 'pl': [], 'cs': ['brazilský ořech'], 'ru': [], 'be': []},
  ),
  Allergen(
    id: 'pinenut',
    names: {'uk': 'Кедровий горіх', 'en': 'Pine nut', 'es': 'Piñón', 'it': 'Pinolo', 'de': 'Pinienkern', 'fr': 'Pignon de pin', 'pt': 'Pinoli', 'pl': 'Orzeszki piniowe', 'cs': 'Piniové oříšky', 'ru': 'Кедровый орех', 'be': 'Кедравы арэх'},
    groups: {'uk': 'Горіхи', 'en': 'Nuts', 'es': 'Frutos secos', 'it': 'Frutta secca', 'de': 'Nüsse', 'fr': 'Fruits à coque', 'pt': 'Castanhas', 'pl': 'Orzechy', 'cs': 'Ořechy', 'ru': 'Орехи', 'be': 'Арэхі'},
    akas: {'uk': ['песто'], 'en': ['pesto', 'pignoli'], 'es': ['pesto'], 'it': ['pesto'], 'de': ['Pesto'], 'fr': ['pesto'], 'pt': ['pinhão europeu', 'pesto'], 'pl': ['pesto'], 'cs': ['pesto'], 'ru': ['песто'], 'be': ['пэста']},
  ),
  Allergen(
    id: 'coconut',
    names: {'uk': 'Кокос', 'en': 'Coconut', 'es': 'Coco', 'it': 'Cocco', 'de': 'Kokosnuss', 'fr': 'Noix de coco', 'pt': 'Coco', 'pl': 'Kokos', 'cs': 'Kokos', 'ru': 'Кокос', 'be': 'Какос'},
    groups: {'uk': 'Горіхи', 'en': 'Nuts', 'es': 'Frutos secos', 'it': 'Frutta secca', 'de': 'Nüsse', 'fr': 'Fruits à coque', 'pt': 'Castanhas', 'pl': 'Orzechy', 'cs': 'Ořechy', 'ru': 'Орехи', 'be': 'Арэхі'},
    akas: {'uk': ['кокосове молоко', 'кокосова стружка'], 'en': ['coconut milk', 'desiccated coconut'], 'es': ['leche de coco', 'coco rallado'], 'it': ['latte di cocco', 'cocco grattugiato'], 'de': ['Kokosmilch', 'Kokosraspeln'], 'fr': ['lait de coco', 'coco râpé'], 'pt': ['leite de coco', 'coco ralado'], 'pl': ['mleko kokosowe', 'wiórki kokosowe'], 'cs': ['kokosové mléko', 'strouhaný kokos'], 'ru': ['кокосовое молоко', 'кокосовая стружка'], 'be': ['какосавае малако', 'какосавая стружка']},
  ),
  Allergen(
    id: 'milk',
    names: {'uk': 'Молоко', 'en': 'Milk', 'es': 'Leche', 'it': 'Latte', 'de': 'Milch', 'fr': 'Lait', 'pt': 'Leite', 'pl': 'Mleko', 'cs': 'Mléko', 'ru': 'Молоко', 'be': 'Малако'},
    groups: {'uk': 'Молочне', 'en': 'Dairy', 'es': 'Lácteos', 'it': 'Latticini', 'de': 'Milchprodukte', 'fr': 'Produits laitiers', 'pt': 'Laticínios', 'pl': 'Nabiał', 'cs': 'Mléčné', 'ru': 'Молочное', 'be': 'Малочнае'},
    akas: {'uk': ['вершки', 'сметана', 'сир', 'масло', 'сироватка'], 'en': ['cream', 'sour cream', 'cheese', 'butter', 'whey'], 'es': ['nata', 'crema agria', 'queso', 'mantequilla', 'suero'], 'it': ['panna', 'panna acida', 'formaggio', 'burro', 'siero'], 'de': ['Sahne', 'Schmand', 'Käse', 'Butter', 'Molke'], 'fr': ['crème', 'crème fraîche', 'fromage', 'beurre', 'lactosérum'], 'pt': ['creme de leite', 'queijo', 'manteiga', 'soro de leite'], 'pl': ['śmietana', 'ser', 'masło', 'serwatka'], 'cs': ['smetana', 'zakysaná smetana', 'sýr', 'máslo', 'syrovátka'], 'ru': ['сливки', 'сметана', 'сыр', 'масло', 'сыворотка'], 'be': ['вяршкі', 'смятана', 'сыр', 'масла', 'сыроватка']},
  ),
  Allergen(
    id: 'lactose',
    names: {'uk': 'Лактоза', 'en': 'Lactose', 'es': 'Lactosa', 'it': 'Lattosio', 'de': 'Laktose', 'fr': 'Lactose', 'pt': 'Lactose', 'pl': 'Laktoza', 'cs': 'Laktóza', 'ru': 'Лактоза', 'be': 'Лактоза'},
    groups: {'uk': 'Молочне', 'en': 'Dairy', 'es': 'Lácteos', 'it': 'Latticini', 'de': 'Milchprodukte', 'fr': 'Produits laitiers', 'pt': 'Laticínios', 'pl': 'Nabiał', 'cs': 'Mléčné', 'ru': 'Молочное', 'be': 'Малочнае'},
    akas: {'uk': ['молочний цукор'], 'en': ['milk sugar'], 'es': ['azúcar de la leche'], 'it': ['zucchero del latte'], 'de': ['Milchzucker'], 'fr': ['sucre du lait'], 'pt': ['açúcar do leite'], 'pl': ['cukier mleczny'], 'cs': ['mléčný cukr'], 'ru': ['молочный сахар'], 'be': ['малочны цукар']},
  ),
  Allergen(
    id: 'casein',
    names: {'uk': 'Казеїн', 'en': 'Casein', 'es': 'Caseína', 'it': 'Caseina', 'de': 'Kasein', 'fr': 'Caséine', 'pt': 'Caseína', 'pl': 'Kazeina', 'cs': 'Kasein', 'ru': 'Казеин', 'be': 'Казеін'},
    groups: {'uk': 'Молочне', 'en': 'Dairy', 'es': 'Lácteos', 'it': 'Latticini', 'de': 'Milchprodukte', 'fr': 'Produits laitiers', 'pt': 'Laticínios', 'pl': 'Nabiał', 'cs': 'Mléčné', 'ru': 'Молочное', 'be': 'Малочнае'},
    akas: {'uk': ['казеїнат'], 'en': ['caseinate'], 'es': ['caseinato'], 'it': ['caseinato'], 'de': ['Kaseinat'], 'fr': ['caséinate'], 'pt': ['caseinato'], 'pl': ['kazeinian'], 'cs': ['kaseinát'], 'ru': ['казеинат'], 'be': ['казеінат']},
  ),
  Allergen(
    id: 'gluten',
    names: {'uk': 'Глютен', 'en': 'Gluten', 'es': 'Gluten', 'it': 'Glutine', 'de': 'Gluten', 'fr': 'Gluten', 'pt': 'Glúten', 'pl': 'Gluten', 'cs': 'Lepek', 'ru': 'Глютен', 'be': 'Глютэн'},
    groups: {'uk': 'Злаки', 'en': 'Grains', 'es': 'Cereales', 'it': 'Cereali', 'de': 'Getreide', 'fr': 'Céréales', 'pt': 'Cereais', 'pl': 'Zboża', 'cs': 'Obiloviny', 'ru': 'Злаки', 'be': 'Збожжа'},
    akas: {'uk': ['клейковина'], 'en': ['seitan'], 'es': ['seitán'], 'it': ['seitan'], 'de': ['Seitan'], 'fr': ['seitan'], 'pt': ['seitan'], 'pl': ['seitan'], 'cs': ['gluten', 'seitan'], 'ru': ['клейковина', 'сейтан'], 'be': ['клейкавіна', 'сейтан']},
  ),
  Allergen(
    id: 'wheat',
    names: {'uk': 'Пшениця', 'en': 'Wheat', 'es': 'Trigo', 'it': 'Grano', 'de': 'Weizen', 'fr': 'Blé', 'pt': 'Trigo', 'pl': 'Pszenica', 'cs': 'Pšenice', 'ru': 'Пшеница', 'be': 'Пшаніца'},
    groups: {'uk': 'Злаки', 'en': 'Grains', 'es': 'Cereales', 'it': 'Cereali', 'de': 'Getreide', 'fr': 'Céréales', 'pt': 'Cereais', 'pl': 'Zboża', 'cs': 'Obiloviny', 'ru': 'Злаки', 'be': 'Збожжа'},
    akas: {'uk': ['борошно', 'манка', 'булгур', 'кускус'], 'en': ['flour', 'semolina', 'bulgur', 'couscous', 'spelt'], 'es': ['harina', 'sémola', 'bulgur', 'cuscús', 'espelta'], 'it': ['farina', 'semola', 'bulgur', 'couscous', 'farro'], 'de': ['Mehl', 'Grieß', 'Bulgur', 'Couscous', 'Dinkel'], 'fr': ['farine', 'semoule', 'boulgour', 'couscous', 'épeautre'], 'pt': ['farinha', 'sêmola', 'bulgur', 'cuscuz', 'espelta'], 'pl': ['mąka', 'kasza manna', 'bulgur', 'kuskus', 'orkisz'], 'cs': ['mouka', 'krupice', 'bulgur', 'kuskus', 'špalda'], 'ru': ['мука', 'манка', 'булгур', 'кускус', 'полба'], 'be': ['мука', 'манка', 'булгур', 'кускус', 'палба']},
  ),
  Allergen(
    id: 'rye',
    names: {'uk': 'Жито', 'en': 'Rye', 'es': 'Centeno', 'it': 'Segale', 'de': 'Roggen', 'fr': 'Seigle', 'pt': 'Centeio', 'pl': 'Żyto', 'cs': 'Žito', 'ru': 'Рожь', 'be': 'Жыта'},
    groups: {'uk': 'Злаки', 'en': 'Grains', 'es': 'Cereales', 'it': 'Cereali', 'de': 'Getreide', 'fr': 'Céréales', 'pt': 'Cereais', 'pl': 'Zboża', 'cs': 'Obiloviny', 'ru': 'Злаки', 'be': 'Збожжа'},
    akas: {'uk': ['житнє борошно'], 'en': ['rye flour'], 'es': ['harina de centeno'], 'it': ['farina di segale'], 'de': ['Roggenmehl'], 'fr': ['farine de seigle'], 'pt': ['farinha de centeio'], 'pl': ['mąka żytnia'], 'cs': ['žitná mouka'], 'ru': ['ржаная мука'], 'be': ['жытняя мука']},
  ),
  Allergen(
    id: 'barley',
    names: {'uk': 'Ячмінь', 'en': 'Barley', 'es': 'Cebada', 'it': 'Orzo', 'de': 'Gerste', 'fr': 'Orge', 'pt': 'Cevada', 'pl': 'Jęczmień', 'cs': 'Ječmen', 'ru': 'Ячмень', 'be': 'Ячмень'},
    groups: {'uk': 'Злаки', 'en': 'Grains', 'es': 'Cereales', 'it': 'Cereali', 'de': 'Getreide', 'fr': 'Céréales', 'pt': 'Cereais', 'pl': 'Zboża', 'cs': 'Obiloviny', 'ru': 'Злаки', 'be': 'Збожжа'},
    akas: {'uk': ['солод', 'перловка'], 'en': ['malt', 'pearl barley'], 'es': ['malta', 'cebada perlada'], 'it': ['malto', 'orzo perlato'], 'de': ['Malz', 'Perlgraupen'], 'fr': ['malt', 'orge perlé'], 'pt': ['malte', 'cevadinha'], 'pl': ['słód', 'kasza jęczmienna'], 'cs': ['slad', 'kroupy'], 'ru': ['солод', 'перловка'], 'be': ['солад', 'перлоўка']},
  ),
  Allergen(
    id: 'oat',
    names: {'uk': 'Овес', 'en': 'Oats', 'es': 'Avena', 'it': 'Avena', 'de': 'Hafer', 'fr': 'Avoine', 'pt': 'Aveia', 'pl': 'Owies', 'cs': 'Oves', 'ru': 'Овёс', 'be': 'Авёс'},
    groups: {'uk': 'Злаки', 'en': 'Grains', 'es': 'Cereales', 'it': 'Cereali', 'de': 'Getreide', 'fr': 'Céréales', 'pt': 'Cereais', 'pl': 'Zboża', 'cs': 'Obiloviny', 'ru': 'Злаки', 'be': 'Збожжа'},
    akas: {'uk': ['вівсянка', 'вівсяне борошно'], 'en': ['oatmeal', 'oat flour'], 'es': ['copos de avena', 'harina de avena'], 'it': ['fiocchi d\'avena', 'farina d\'avena'], 'de': ['Haferflocken', 'Hafermehl'], 'fr': ['flocons d\'avoine', 'farine d\'avoine'], 'pt': ['flocos de aveia', 'farinha de aveia'], 'pl': ['płatki owsiane', 'mąka owsiana'], 'cs': ['ovesné vločky', 'ovesná mouka'], 'ru': ['овсянка', 'овсяная мука'], 'be': ['аўсянка', 'аўсяная мука']},
  ),
  Allergen(
    id: 'buckwheat',
    names: {'uk': 'Гречка', 'en': 'Buckwheat', 'es': 'Trigo sarraceno', 'it': 'Grano saraceno', 'de': 'Buchweizen', 'fr': 'Sarrasin', 'pt': 'Trigo-sarraceno', 'pl': 'Gryka', 'cs': 'Pohanka', 'ru': 'Гречка', 'be': 'Грэчка'},
    groups: {'uk': 'Злаки', 'en': 'Grains', 'es': 'Cereales', 'it': 'Cereali', 'de': 'Getreide', 'fr': 'Céréales', 'pt': 'Cereais', 'pl': 'Zboża', 'cs': 'Obiloviny', 'ru': 'Злаки', 'be': 'Збожжа'},
    akas: {'uk': ['гречане борошно', 'соба'], 'en': ['buckwheat flour', 'soba'], 'es': ['harina de trigo sarraceno', 'soba'], 'it': ['farina di grano saraceno', 'soba'], 'de': ['Buchweizenmehl', 'Soba'], 'fr': ['farine de sarrasin', 'soba'], 'pt': ['farinha de trigo-sarraceno', 'soba'], 'pl': ['mąka gryczana', 'kasza gryczana'], 'cs': ['pohanková mouka', 'soba'], 'ru': ['гречневая мука', 'соба'], 'be': ['грэцкая мука', 'соба']},
  ),
  Allergen(
    id: 'corn',
    names: {'uk': 'Кукурудза', 'en': 'Corn', 'es': 'Maíz', 'it': 'Mais', 'de': 'Mais', 'fr': 'Maïs', 'pt': 'Milho', 'pl': 'Kukurydza', 'cs': 'Kukuřice', 'ru': 'Кукуруза', 'be': 'Кукуруза'},
    groups: {'uk': 'Злаки', 'en': 'Grains', 'es': 'Cereales', 'it': 'Cereali', 'de': 'Getreide', 'fr': 'Céréales', 'pt': 'Cereais', 'pl': 'Zboża', 'cs': 'Obiloviny', 'ru': 'Злаки', 'be': 'Збожжа'},
    akas: {'uk': ['кукурудзяний крохмаль', 'попкорн', 'полента'], 'en': ['corn starch', 'popcorn', 'polenta', 'maize'], 'es': ['almidón de maíz', 'palomitas', 'polenta'], 'it': ['amido di mais', 'popcorn', 'polenta'], 'de': ['Maisstärke', 'Popcorn', 'Polenta'], 'fr': ['amidon de maïs', 'pop-corn', 'polenta'], 'pt': ['amido de milho', 'pipoca', 'polenta'], 'pl': ['skrobia kukurydziana', 'popcorn', 'polenta'], 'cs': ['kukuřičný škrob', 'popcorn', 'polenta'], 'ru': ['кукурузный крахмал', 'попкорн', 'полента'], 'be': ['кукурузны крухмал', 'попкорн', 'палента']},
  ),
  Allergen(
    id: 'egg',
    names: {'uk': 'Яйця', 'en': 'Egg', 'es': 'Huevo', 'it': 'Uovo', 'de': 'Ei', 'fr': 'Œuf', 'pt': 'Ovo', 'pl': 'Jajko', 'cs': 'Vejce', 'ru': 'Яйца', 'be': 'Яйкі'},
    groups: {'uk': 'Тваринні', 'en': 'Animal', 'es': 'Animales', 'it': 'Animali', 'de': 'Tierisch', 'fr': 'Animaux', 'pt': 'Animais', 'pl': 'Zwierzęce', 'cs': 'Živočišné', 'ru': 'Животные', 'be': 'Жывёльныя'},
    akas: {'uk': ['білок', 'жовток', 'меланж', 'майонез'], 'en': ['egg white', 'yolk', 'albumen', 'mayonnaise'], 'es': ['clara', 'yema', 'mayonesa'], 'it': ['albume', 'tuorlo', 'maionese'], 'de': ['Eiweiß', 'Eigelb', 'Mayonnaise'], 'fr': ['blanc d\'œuf', 'jaune d\'œuf', 'mayonnaise'], 'pt': ['clara', 'gema', 'maionese'], 'pl': ['białko jaja', 'żółtko', 'majonez'], 'cs': ['bílek', 'žloutek', 'majonéza'], 'ru': ['белок', 'желток', 'меланж', 'майонез'], 'be': ['бялок', 'жаўток', 'меланж', 'маянэз']},
  ),
  Allergen(
    id: 'fish',
    names: {'uk': 'Риба', 'en': 'Fish', 'es': 'Pescado', 'it': 'Pesce', 'de': 'Fisch', 'fr': 'Poisson', 'pt': 'Peixe', 'pl': 'Ryba', 'cs': 'Ryba', 'ru': 'Рыба', 'be': 'Рыба'},
    groups: {'uk': 'Тваринні', 'en': 'Animal', 'es': 'Animales', 'it': 'Animali', 'de': 'Tierisch', 'fr': 'Animaux', 'pt': 'Animais', 'pl': 'Zwierzęce', 'cs': 'Živočišné', 'ru': 'Животные', 'be': 'Жывёльныя'},
    akas: {'uk': ['тунець', 'лосось', 'оселедець', 'анчоуси'], 'en': ['tuna', 'salmon', 'herring', 'anchovy'], 'es': ['atún', 'salmón', 'arenque', 'anchoas'], 'it': ['tonno', 'salmone', 'aringa', 'acciughe'], 'de': ['Thunfisch', 'Lachs', 'Hering', 'Sardellen'], 'fr': ['thon', 'saumon', 'hareng', 'anchois'], 'pt': ['atum', 'salmão', 'arenque', 'anchova'], 'pl': ['tuńczyk', 'łosoś', 'śledź', 'anchois'], 'cs': ['tuňák', 'losos', 'sleď', 'ančovičky'], 'ru': ['тунец', 'лосось', 'сельдь', 'анчоусы'], 'be': ['тунец', 'ласось', 'селядзец', 'анчоусы']},
  ),
  Allergen(
    id: 'crustacean',
    names: {'uk': 'Ракоподібні', 'en': 'Crustaceans', 'es': 'Crustáceos', 'it': 'Crostacei', 'de': 'Krebstiere', 'fr': 'Crustacés', 'pt': 'Crustáceos', 'pl': 'Skorupiaki', 'cs': 'Korýši', 'ru': 'Ракообразные', 'be': 'Ракападобныя'},
    groups: {'uk': 'Тваринні', 'en': 'Animal', 'es': 'Animales', 'it': 'Animali', 'de': 'Tierisch', 'fr': 'Animaux', 'pt': 'Animais', 'pl': 'Zwierzęce', 'cs': 'Živočišné', 'ru': 'Животные', 'be': 'Жывёльныя'},
    akas: {'uk': ['креветки', 'краби', 'лангустини'], 'en': ['shrimp', 'prawn', 'crab', 'lobster'], 'es': ['gambas', 'cangrejo', 'langosta'], 'it': ['gamberi', 'granchio', 'astice'], 'de': ['Garnelen', 'Krabben', 'Hummer'], 'fr': ['crevettes', 'crabe', 'homard'], 'pt': ['camarão', 'caranguejo', 'lagosta'], 'pl': ['krewetka', 'krab', 'homar'], 'cs': ['krevety', 'krab', 'humr'], 'ru': ['креветки', 'крабы', 'лангустины'], 'be': ['крэветкі', 'крабы', 'лангусціны']},
  ),
  Allergen(
    id: 'mollusc',
    names: {'uk': 'Молюски', 'en': 'Molluscs', 'es': 'Moluscos', 'it': 'Molluschi', 'de': 'Weichtiere', 'fr': 'Mollusques', 'pt': 'Moluscos', 'pl': 'Mięczaki', 'cs': 'Měkkýši', 'ru': 'Моллюски', 'be': 'Малюскі'},
    groups: {'uk': 'Тваринні', 'en': 'Animal', 'es': 'Animales', 'it': 'Animali', 'de': 'Tierisch', 'fr': 'Animaux', 'pt': 'Animais', 'pl': 'Zwierzęce', 'cs': 'Živočišné', 'ru': 'Животные', 'be': 'Жывёльныя'},
    akas: {'uk': ['мідії', 'кальмар', 'устриці', 'восьминіг'], 'en': ['mussels', 'squid', 'oyster', 'octopus'], 'es': ['mejillones', 'calamar', 'ostras', 'pulpo'], 'it': ['cozze', 'calamaro', 'ostriche', 'polpo'], 'de': ['Muscheln', 'Tintenfisch', 'Austern', 'Oktopus'], 'fr': ['moules', 'calmar', 'huîtres', 'poulpe'], 'pt': ['mexilhão', 'lula', 'ostra', 'polvo'], 'pl': ['małże', 'kalmar', 'ostryga', 'ośmiornica'], 'cs': ['mušle', 'slávky', 'oliheň', 'ústřice', 'chobotnice'], 'ru': ['мидии', 'кальмар', 'устрицы', 'осьминог'], 'be': ['мідыі', 'кальмар', 'вустрыцы', 'васьміног']},
  ),
  Allergen(
    id: 'honey',
    names: {'uk': 'Мед', 'en': 'Honey', 'es': 'Miel', 'it': 'Miele', 'de': 'Honig', 'fr': 'Miel', 'pt': 'Mel', 'pl': 'Miód', 'cs': 'Med', 'ru': 'Мёд', 'be': 'Мёд'},
    groups: {'uk': 'Тваринні', 'en': 'Animal', 'es': 'Animales', 'it': 'Animali', 'de': 'Tierisch', 'fr': 'Animaux', 'pt': 'Animais', 'pl': 'Zwierzęce', 'cs': 'Živočišné', 'ru': 'Животные', 'be': 'Жывёльныя'},
    akas: {'uk': ['прополіс'], 'en': ['propolis'], 'es': ['propóleo'], 'it': ['propoli'], 'de': ['Propolis'], 'fr': ['propolis'], 'pt': ['própolis'], 'pl': ['propolis'], 'cs': ['propolis'], 'ru': ['прополис'], 'be': ['прапаліс']},
  ),
  Allergen(
    id: 'gelatin',
    names: {'uk': 'Желатин', 'en': 'Gelatin', 'es': 'Gelatina', 'it': 'Gelatina', 'de': 'Gelatine', 'fr': 'Gélatine', 'pt': 'Gelatina', 'pl': 'Żelatyna', 'cs': 'Želatina', 'ru': 'Желатин', 'be': 'Жэлаціна'},
    groups: {'uk': 'Тваринні', 'en': 'Animal', 'es': 'Animales', 'it': 'Animali', 'de': 'Tierisch', 'fr': 'Animaux', 'pt': 'Animais', 'pl': 'Zwierzęce', 'cs': 'Živočišné', 'ru': 'Животные', 'be': 'Жывёльныя'},
    akas: {'uk': ['желе', 'маршмелоу'], 'en': ['jelly', 'marshmallow', 'gelatine'], 'es': ['gominolas', 'malvavisco'], 'it': ['gelatine', 'marshmallow'], 'de': ['Gelee', 'Marshmallow'], 'fr': ['gelée', 'guimauve'], 'pt': ['geleia', 'marshmallow'], 'pl': ['galaretka', 'pianki'], 'cs': ['želé', 'marshmallow'], 'ru': ['желе', 'маршмеллоу'], 'be': ['жэле', 'маршмэлоу']},
  ),
  Allergen(
    id: 'soy',
    names: {'uk': 'Соя', 'en': 'Soy', 'es': 'Soja', 'it': 'Soia', 'de': 'Soja', 'fr': 'Soja', 'pt': 'Soja', 'pl': 'Soja', 'cs': 'Sója', 'ru': 'Соя', 'be': 'Соя'},
    groups: {'uk': 'Бобові', 'en': 'Legumes', 'es': 'Legumbres', 'it': 'Legumi', 'de': 'Hülsenfrüchte', 'fr': 'Légumineuses', 'pt': 'Leguminosas', 'pl': 'Strączkowe', 'cs': 'Luštěniny', 'ru': 'Бобовые', 'be': 'Бабовыя'},
    akas: {'uk': ['соєвий соус', 'тофу', 'соєвий лецитин'], 'en': ['soy sauce', 'tofu', 'soy lecithin', 'edamame'], 'es': ['salsa de soja', 'tofu', 'lecitina de soja', 'edamame'], 'it': ['salsa di soia', 'tofu', 'lecitina di soia', 'edamame'], 'de': ['Sojasoße', 'Tofu', 'Sojalecithin', 'Edamame'], 'fr': ['sauce soja', 'tofu', 'lécithine de soja', 'édamame'], 'pt': ['molho de soja', 'tofu', 'lecitina de soja', 'edamame'], 'pl': ['sos sojowy', 'tofu', 'lecytyna sojowa', 'edamame'], 'cs': ['sójová omáčka', 'tofu', 'sójový lecitin', 'edamame'], 'ru': ['соевый соус', 'тофу', 'соевый лецитин'], 'be': ['соевы соус', 'тофу', 'соевы лецыцін']},
  ),
  Allergen(
    id: 'lupin',
    names: {'uk': 'Люпин', 'en': 'Lupin', 'es': 'Altramuz', 'it': 'Lupino', 'de': 'Lupine', 'fr': 'Lupin', 'pt': 'Tremoço', 'pl': 'Łubin', 'cs': 'Vlčí bob', 'ru': 'Люпин', 'be': 'Лубін'},
    groups: {'uk': 'Бобові', 'en': 'Legumes', 'es': 'Legumbres', 'it': 'Legumi', 'de': 'Hülsenfrüchte', 'fr': 'Légumineuses', 'pt': 'Leguminosas', 'pl': 'Strączkowe', 'cs': 'Luštěniny', 'ru': 'Бобовые', 'be': 'Бабовыя'},
    akas: {'uk': ['люпинове борошно'], 'en': ['lupin flour'], 'es': ['harina de altramuz'], 'it': ['farina di lupino'], 'de': ['Lupinenmehl'], 'fr': ['farine de lupin'], 'pt': ['farinha de tremoço'], 'pl': ['mąka łubinowa'], 'cs': ['lupina', 'lupinová mouka'], 'ru': ['люпиновая мука'], 'be': ['лубінавая мука']},
  ),
  Allergen(
    id: 'legume',
    names: {'uk': 'Бобові', 'en': 'Pulses', 'es': 'Legumbres', 'it': 'Legumi', 'de': 'Hülsenfrüchte', 'fr': 'Légumineuses', 'pt': 'Leguminosas', 'pl': 'Strączkowe', 'cs': 'Luštěniny', 'ru': 'Бобовые', 'be': 'Бабовыя'},
    groups: {'uk': 'Бобові', 'en': 'Legumes', 'es': 'Legumbres', 'it': 'Legumi', 'de': 'Hülsenfrüchte', 'fr': 'Légumineuses', 'pt': 'Leguminosas', 'pl': 'Strączkowe', 'cs': 'Luštěniny', 'ru': 'Бобовые', 'be': 'Бабовыя'},
    akas: {'uk': ['квасоля', 'горох', 'нут', 'сочевиця'], 'en': ['beans', 'peas', 'chickpeas', 'lentils'], 'es': ['judías', 'guisantes', 'garbanzos', 'lentejas'], 'it': ['fagioli', 'piselli', 'ceci', 'lenticchie'], 'de': ['Bohnen', 'Erbsen', 'Kichererbsen', 'Linsen'], 'fr': ['haricots', 'pois', 'pois chiches', 'lentilles'], 'pt': ['feijão', 'ervilha', 'grão-de-bico', 'lentilha'], 'pl': ['fasola', 'groch', 'ciecierzyca', 'soczewica'], 'cs': ['fazole', 'hrách', 'cizrna', 'čočka'], 'ru': ['фасоль', 'горох', 'нут', 'чечевица'], 'be': ['фасоля', 'гарох', 'нут', 'сачавіца']},
  ),
  Allergen(
    id: 'sesame',
    names: {'uk': 'Кунжут', 'en': 'Sesame', 'es': 'Sésamo', 'it': 'Sesamo', 'de': 'Sesam', 'fr': 'Sésame', 'pt': 'Gergelim', 'pl': 'Sezam', 'cs': 'Sezam', 'ru': 'Кунжут', 'be': 'Кунжут'},
    groups: {'uk': 'Рослинні', 'en': 'Plants', 'es': 'Vegetales', 'it': 'Vegetali', 'de': 'Pflanzlich', 'fr': 'Végétaux', 'pt': 'Vegetais', 'pl': 'Roślinne', 'cs': 'Rostlinné', 'ru': 'Растительные', 'be': 'Раслінныя'},
    akas: {'uk': ['тахіні', 'кунжутна олія'], 'en': ['tahini', 'sesame oil'], 'es': ['tahini', 'aceite de sésamo'], 'it': ['tahina', 'olio di sesamo'], 'de': ['Tahini', 'Sesamöl'], 'fr': ['tahini', 'huile de sésame'], 'pt': ['tahine', 'óleo de gergelim'], 'pl': ['tahini', 'olej sezamowy'], 'cs': ['tahini', 'sezamový olej'], 'ru': ['тахини', 'кунжутное масло'], 'be': ['тахіні', 'кунжутны алей']},
  ),
  Allergen(
    id: 'mustard',
    names: {'uk': 'Гірчиця', 'en': 'Mustard', 'es': 'Mostaza', 'it': 'Senape', 'de': 'Senf', 'fr': 'Moutarde', 'pt': 'Mostarda', 'pl': 'Gorczyca', 'cs': 'Hořčice', 'ru': 'Горчица', 'be': 'Гарчыца'},
    groups: {'uk': 'Рослинні', 'en': 'Plants', 'es': 'Vegetales', 'it': 'Vegetali', 'de': 'Pflanzlich', 'fr': 'Végétaux', 'pt': 'Vegetais', 'pl': 'Roślinne', 'cs': 'Rostlinné', 'ru': 'Растительные', 'be': 'Раслінныя'},
    akas: {'uk': ['гірчичний порошок'], 'en': ['mustard powder'], 'es': ['mostaza en polvo'], 'it': ['senape in polvere'], 'de': ['Senfpulver'], 'fr': ['moutarde en poudre'], 'pt': ['mostarda em pó'], 'pl': ['musztarda'], 'cs': ['hořčičný prášek'], 'ru': ['горчичный порошок'], 'be': ['гарчычны парашок']},
  ),
  Allergen(
    id: 'celery',
    names: {'uk': 'Селера', 'en': 'Celery', 'es': 'Apio', 'it': 'Sedano', 'de': 'Sellerie', 'fr': 'Céleri', 'pt': 'Aipo', 'pl': 'Seler', 'cs': 'Celer', 'ru': 'Сельдерей', 'be': 'Салера'},
    groups: {'uk': 'Рослинні', 'en': 'Plants', 'es': 'Vegetales', 'it': 'Vegetali', 'de': 'Pflanzlich', 'fr': 'Végétaux', 'pt': 'Vegetais', 'pl': 'Roślinne', 'cs': 'Rostlinné', 'ru': 'Растительные', 'be': 'Раслінныя'},
    akas: {'uk': ['корінь селери'], 'en': ['celeriac'], 'es': ['apionabo'], 'it': ['sedano rapa'], 'de': ['Knollensellerie'], 'fr': ['céleri-rave'], 'pt': ['aipo-rábano'], 'pl': ['seler korzeniowy'], 'cs': ['celerová bulva'], 'ru': ['корень сельдерея'], 'be': ['корань салеры']},
  ),
  Allergen(
    id: 'citrus',
    names: {'uk': 'Цитрусові', 'en': 'Citrus', 'es': 'Cítricos', 'it': 'Agrumi', 'de': 'Zitrusfrüchte', 'fr': 'Agrumes', 'pt': 'Cítricos', 'pl': 'Cytrusy', 'cs': 'Citrusy', 'ru': 'Цитрусовые', 'be': 'Цытрусавыя'},
    groups: {'uk': 'Рослинні', 'en': 'Plants', 'es': 'Vegetales', 'it': 'Vegetali', 'de': 'Pflanzlich', 'fr': 'Végétaux', 'pt': 'Vegetais', 'pl': 'Roślinne', 'cs': 'Rostlinné', 'ru': 'Растительные', 'be': 'Раслінныя'},
    akas: {'uk': ['апельсин', 'лимон', 'мандарин', 'грейпфрут'], 'en': ['orange', 'lemon', 'mandarin', 'grapefruit'], 'es': ['naranja', 'limón', 'mandarina', 'pomelo'], 'it': ['arancia', 'limone', 'mandarino', 'pompelmo'], 'de': ['Orange', 'Zitrone', 'Mandarine', 'Grapefruit'], 'fr': ['orange', 'citron', 'mandarine', 'pamplemousse'], 'pt': ['laranja', 'limão', 'tangerina', 'toranja'], 'pl': ['pomarańcza', 'cytryna', 'mandarynka', 'grejpfrut'], 'cs': ['pomeranč', 'citron', 'mandarinka', 'grapefruit'], 'ru': ['апельсин', 'лимон', 'мандарин', 'грейпфрут'], 'be': ['апельсін', 'лімон', 'мандарын', 'грэйпфрут']},
  ),
  Allergen(
    id: 'strawberry',
    names: {'uk': 'Полуниця', 'en': 'Strawberry', 'es': 'Fresa', 'it': 'Fragola', 'de': 'Erdbeere', 'fr': 'Fraise', 'pt': 'Morango', 'pl': 'Truskawka', 'cs': 'Jahoda', 'ru': 'Клубника', 'be': 'Трускаўка'},
    groups: {'uk': 'Рослинні', 'en': 'Plants', 'es': 'Vegetales', 'it': 'Vegetali', 'de': 'Pflanzlich', 'fr': 'Végétaux', 'pt': 'Vegetais', 'pl': 'Roślinne', 'cs': 'Rostlinné', 'ru': 'Растительные', 'be': 'Раслінныя'},
    akas: {'uk': ['суниця'], 'en': ['wild strawberry'], 'es': ['fresa silvestre'], 'it': ['fragolina di bosco'], 'de': ['Walderdbeere'], 'fr': ['fraise des bois'], 'pt': ['morango silvestre'], 'pl': ['poziomka'], 'cs': ['lesní jahoda'], 'ru': ['земляника'], 'be': ['суніцы']},
  ),
  Allergen(
    id: 'kiwi',
    names: {'uk': 'Ківі', 'en': 'Kiwi', 'es': 'Kiwi', 'it': 'Kiwi', 'de': 'Kiwi', 'fr': 'Kiwi', 'pt': 'Kiwi', 'pl': 'Kiwi', 'cs': 'Kiwi', 'ru': 'Киви', 'be': 'Ківі'},
    groups: {'uk': 'Рослинні', 'en': 'Plants', 'es': 'Vegetales', 'it': 'Vegetali', 'de': 'Pflanzlich', 'fr': 'Végétaux', 'pt': 'Vegetais', 'pl': 'Roślinne', 'cs': 'Rostlinné', 'ru': 'Растительные', 'be': 'Раслінныя'},
    akas: {'uk': [], 'en': [], 'es': [], 'it': [], 'de': [], 'fr': [], 'pt': [], 'pl': [], 'cs': [], 'ru': [], 'be': []},
  ),
  Allergen(
    id: 'apple',
    names: {'uk': 'Яблуко', 'en': 'Apple', 'es': 'Manzana', 'it': 'Mela', 'de': 'Apfel', 'fr': 'Pomme', 'pt': 'Maçã', 'pl': 'Jabłko', 'cs': 'Jablko', 'ru': 'Яблоко', 'be': 'Яблык'},
    groups: {'uk': 'Рослинні', 'en': 'Plants', 'es': 'Vegetales', 'it': 'Vegetali', 'de': 'Pflanzlich', 'fr': 'Végétaux', 'pt': 'Vegetais', 'pl': 'Roślinne', 'cs': 'Rostlinné', 'ru': 'Растительные', 'be': 'Раслінныя'},
    akas: {'uk': ['яблучний сік', 'пюре'], 'en': ['apple juice', 'cider'], 'es': ['zumo de manzana', 'sidra'], 'it': ['succo di mela', 'sidro'], 'de': ['Apfelsaft', 'Cidre'], 'fr': ['jus de pomme', 'cidre'], 'pt': ['suco de maçã', 'sidra'], 'pl': ['sok jabłkowy', 'cydr'], 'cs': ['jablečný džus', 'cider'], 'ru': ['яблочный сок', 'сидр'], 'be': ['яблычны сок', 'сідр']},
  ),
  Allergen(
    id: 'banana',
    names: {'uk': 'Банан', 'en': 'Banana', 'es': 'Plátano', 'it': 'Banana', 'de': 'Banane', 'fr': 'Banane', 'pt': 'Banana', 'pl': 'Banan', 'cs': 'Banán', 'ru': 'Банан', 'be': 'Банан'},
    groups: {'uk': 'Рослинні', 'en': 'Plants', 'es': 'Vegetales', 'it': 'Vegetali', 'de': 'Pflanzlich', 'fr': 'Végétaux', 'pt': 'Vegetais', 'pl': 'Roślinne', 'cs': 'Rostlinné', 'ru': 'Растительные', 'be': 'Раслінныя'},
    akas: {'uk': [], 'en': ['plantain'], 'es': ['plátano macho'], 'it': ['platano'], 'de': ['Kochbanane'], 'fr': ['banane plantain'], 'pt': ['banana-da-terra'], 'pl': ['plantan'], 'cs': ['plantain'], 'ru': ['плантан'], 'be': ['плантан']},
  ),
  Allergen(
    id: 'avocado',
    names: {'uk': 'Авокадо', 'en': 'Avocado', 'es': 'Aguacate', 'it': 'Avocado', 'de': 'Avocado', 'fr': 'Avocat', 'pt': 'Abacate', 'pl': 'Awokado', 'cs': 'Avokádo', 'ru': 'Авокадо', 'be': 'Авакада'},
    groups: {'uk': 'Рослинні', 'en': 'Plants', 'es': 'Vegetales', 'it': 'Vegetali', 'de': 'Pflanzlich', 'fr': 'Végétaux', 'pt': 'Vegetais', 'pl': 'Roślinne', 'cs': 'Rostlinné', 'ru': 'Растительные', 'be': 'Раслінныя'},
    akas: {'uk': ['гуакамоле'], 'en': ['guacamole'], 'es': ['guacamole'], 'it': ['guacamole'], 'de': ['Guacamole'], 'fr': ['guacamole'], 'pt': ['guacamole'], 'pl': ['guacamole'], 'cs': ['guacamole'], 'ru': ['гуакамоле'], 'be': ['гуакамоле']},
  ),
  Allergen(
    id: 'peach',
    names: {'uk': 'Персик', 'en': 'Peach', 'es': 'Melocotón', 'it': 'Pesca', 'de': 'Pfirsich', 'fr': 'Pêche', 'pt': 'Pêssego', 'pl': 'Brzoskwinia', 'cs': 'Broskev', 'ru': 'Персик', 'be': 'Персік'},
    groups: {'uk': 'Рослинні', 'en': 'Plants', 'es': 'Vegetales', 'it': 'Vegetali', 'de': 'Pflanzlich', 'fr': 'Végétaux', 'pt': 'Vegetais', 'pl': 'Roślinne', 'cs': 'Rostlinné', 'ru': 'Растительные', 'be': 'Раслінныя'},
    akas: {'uk': ['нектарин'], 'en': ['nectarine'], 'es': ['nectarina'], 'it': ['nettarina'], 'de': ['Nektarine'], 'fr': ['nectarine'], 'pt': ['nectarina'], 'pl': ['nektarynka'], 'cs': ['nektarinka'], 'ru': ['нектарин'], 'be': ['нектарын']},
  ),
  Allergen(
    id: 'apricot',
    names: {'uk': 'Абрикос', 'en': 'Apricot', 'es': 'Albaricoque', 'it': 'Albicocca', 'de': 'Aprikose', 'fr': 'Abricot', 'pt': 'Damasco', 'pl': 'Morela', 'cs': 'Meruňka', 'ru': 'Абрикос', 'be': 'Абрыкос'},
    groups: {'uk': 'Рослинні', 'en': 'Plants', 'es': 'Vegetales', 'it': 'Vegetali', 'de': 'Pflanzlich', 'fr': 'Végétaux', 'pt': 'Vegetais', 'pl': 'Roślinne', 'cs': 'Rostlinné', 'ru': 'Растительные', 'be': 'Раслінныя'},
    akas: {'uk': ['курага', 'урюк'], 'en': ['dried apricot'], 'es': ['orejones'], 'it': ['albicocche secche'], 'de': ['Trockenaprikosen'], 'fr': ['abricots secs'], 'pt': ['damasco seco'], 'pl': ['suszona morela'], 'cs': ['sušená meruňka'], 'ru': ['курага'], 'be': ['курага']},
  ),
  Allergen(
    id: 'plum',
    names: {'uk': 'Слива', 'en': 'Plum', 'es': 'Ciruela', 'it': 'Prugna', 'de': 'Pflaume', 'fr': 'Prune', 'pt': 'Ameixa', 'pl': 'Śliwka', 'cs': 'Švestka', 'ru': 'Слива', 'be': 'Сліва'},
    groups: {'uk': 'Рослинні', 'en': 'Plants', 'es': 'Vegetales', 'it': 'Vegetali', 'de': 'Pflanzlich', 'fr': 'Végétaux', 'pt': 'Vegetais', 'pl': 'Roślinne', 'cs': 'Rostlinné', 'ru': 'Растительные', 'be': 'Раслінныя'},
    akas: {'uk': ['чорнослив', 'алича'], 'en': ['prune'], 'es': ['ciruela pasa'], 'it': ['prugna secca'], 'de': ['Backpflaume'], 'fr': ['pruneau'], 'pt': ['ameixa seca'], 'pl': ['suszona śliwka'], 'cs': ['sušená švestka'], 'ru': ['чернослив'], 'be': ['чарнасліў']},
  ),
  Allergen(
    id: 'cherry',
    names: {'uk': 'Вишня', 'en': 'Cherry', 'es': 'Cereza', 'it': 'Ciliegia', 'de': 'Kirsche', 'fr': 'Cerise', 'pt': 'Cereja', 'pl': 'Wiśnia', 'cs': 'Višeň', 'ru': 'Вишня', 'be': 'Вішня'},
    groups: {'uk': 'Рослинні', 'en': 'Plants', 'es': 'Vegetales', 'it': 'Vegetali', 'de': 'Pflanzlich', 'fr': 'Végétaux', 'pt': 'Vegetais', 'pl': 'Roślinne', 'cs': 'Rostlinné', 'ru': 'Растительные', 'be': 'Раслінныя'},
    akas: {'uk': ['черешня'], 'en': ['sweet cherry'], 'es': ['guinda'], 'it': ['amarena'], 'de': ['Sauerkirsche'], 'fr': ['griotte'], 'pt': ['cereja azeda'], 'pl': ['czereśnia'], 'cs': ['třešeň'], 'ru': ['черешня'], 'be': ['чарэшня']},
  ),
  Allergen(
    id: 'tomato',
    names: {'uk': 'Помідор', 'en': 'Tomato', 'es': 'Tomate', 'it': 'Pomodoro', 'de': 'Tomate', 'fr': 'Tomate', 'pt': 'Tomate', 'pl': 'Pomidor', 'cs': 'Rajče', 'ru': 'Помидор', 'be': 'Памідор'},
    groups: {'uk': 'Рослинні', 'en': 'Plants', 'es': 'Vegetales', 'it': 'Vegetali', 'de': 'Pflanzlich', 'fr': 'Végétaux', 'pt': 'Vegetais', 'pl': 'Roślinne', 'cs': 'Rostlinné', 'ru': 'Растительные', 'be': 'Раслінныя'},
    akas: {'uk': ['томатна паста', 'кетчуп'], 'en': ['tomato paste', 'ketchup'], 'es': ['tomate concentrado', 'kétchup'], 'it': ['concentrato di pomodoro', 'ketchup'], 'de': ['Tomatenmark', 'Ketchup'], 'fr': ['concentré de tomate', 'ketchup'], 'pt': ['extrato de tomate', 'ketchup'], 'pl': ['koncentrat pomidorowy', 'ketchup'], 'cs': ['rajčatový protlak', 'kečup'], 'ru': ['томатная паста', 'кетчуп'], 'be': ['таматная паста', 'кетчуп']},
  ),
  Allergen(
    id: 'cocoa',
    names: {'uk': 'Какао', 'en': 'Cocoa', 'es': 'Cacao', 'it': 'Cacao', 'de': 'Kakao', 'fr': 'Cacao', 'pt': 'Cacau', 'pl': 'Kakao', 'cs': 'Kakao', 'ru': 'Какао', 'be': 'Какава'},
    groups: {'uk': 'Рослинні', 'en': 'Plants', 'es': 'Vegetales', 'it': 'Vegetali', 'de': 'Pflanzlich', 'fr': 'Végétaux', 'pt': 'Vegetais', 'pl': 'Roślinne', 'cs': 'Rostlinné', 'ru': 'Растительные', 'be': 'Раслінныя'},
    akas: {'uk': ['шоколад'], 'en': ['chocolate'], 'es': ['chocolate'], 'it': ['cioccolato'], 'de': ['Schokolade'], 'fr': ['chocolat'], 'pt': ['chocolate'], 'pl': ['czekolada'], 'cs': ['čokoláda'], 'ru': ['шоколад'], 'be': ['шакалад']},
  ),
  Allergen(
    id: 'sulphite',
    names: {'uk': 'Сульфіти', 'en': 'Sulphites', 'es': 'Sulfitos', 'it': 'Solfiti', 'de': 'Sulfite', 'fr': 'Sulfites', 'pt': 'Sulfitos', 'pl': 'Siarczyny', 'cs': 'Siřičitany', 'ru': 'Сульфиты', 'be': 'Сульфіты'},
    groups: {'uk': 'Додатки', 'en': 'Additives', 'es': 'Aditivos', 'it': 'Additivi', 'de': 'Zusatzstoffe', 'fr': 'Additifs', 'pt': 'Aditivos', 'pl': 'Dodatki', 'cs': 'Přídatné látky', 'ru': 'Добавки', 'be': 'Дадаткі'},
    akas: {'uk': ['діоксид сірки', 'E220', 'E221'], 'en': ['sulfur dioxide', 'E220', 'E221'], 'es': ['dióxido de azufre', 'E220', 'E221'], 'it': ['anidride solforosa', 'E220', 'E221'], 'de': ['Schwefeldioxid', 'E220', 'E221'], 'fr': ['dioxyde de soufre', 'E220', 'E221'], 'pt': ['dióxido de enxofre', 'E220', 'E221'], 'pl': ['dwutlenek siarki', 'E220', 'E221'], 'cs': ['oxid siřičitý', 'E220', 'E221'], 'ru': ['диоксид серы', 'E220', 'E221'], 'be': ['дыяксід серы', 'E220', 'E221']},
  ),
  Allergen(
    id: 'msg',
    names: {'uk': 'Глутамат натрію', 'en': 'Monosodium glutamate', 'es': 'Glutamato monosódico', 'it': 'Glutammato monosodico', 'de': 'Mononatriumglutamat', 'fr': 'Glutamate monosodique', 'pt': 'Glutamato monossódico', 'pl': 'Glutaminian sodu', 'cs': 'Glutaman sodný', 'ru': 'Глутамат натрия', 'be': 'Глутамат натрыю'},
    groups: {'uk': 'Додатки', 'en': 'Additives', 'es': 'Aditivos', 'it': 'Additivi', 'de': 'Zusatzstoffe', 'fr': 'Additifs', 'pt': 'Aditivos', 'pl': 'Dodatki', 'cs': 'Přídatné látky', 'ru': 'Добавки', 'be': 'Дадаткі'},
    akas: {'uk': ['E621'], 'en': ['MSG', 'E621'], 'es': ['E621'], 'it': ['E621'], 'de': ['E621'], 'fr': ['E621'], 'pt': ['E621'], 'pl': ['E621'], 'cs': ['MSG', 'E621'], 'ru': ['E621'], 'be': ['E621']},
  ),
  Allergen(
    id: 'benzoate',
    names: {'uk': 'Бензоати', 'en': 'Benzoates', 'es': 'Benzoatos', 'it': 'Benzoati', 'de': 'Benzoate', 'fr': 'Benzoates', 'pt': 'Benzoatos', 'pl': 'Benzoesany', 'cs': 'Benzoany', 'ru': 'Бензоаты', 'be': 'Бензааты'},
    groups: {'uk': 'Додатки', 'en': 'Additives', 'es': 'Aditivos', 'it': 'Additivi', 'de': 'Zusatzstoffe', 'fr': 'Additifs', 'pt': 'Aditivos', 'pl': 'Dodatki', 'cs': 'Přídatné látky', 'ru': 'Добавки', 'be': 'Дадаткі'},
    akas: {'uk': ['E210', 'E211'], 'en': ['E210', 'E211'], 'es': ['E210', 'E211'], 'it': ['E210', 'E211'], 'de': ['E210', 'E211'], 'fr': ['E210', 'E211'], 'pt': ['E210', 'E211'], 'pl': ['E210', 'E211'], 'cs': ['E210', 'E211'], 'ru': ['E210', 'E211'], 'be': ['E210', 'E211']},
  ),
  Allergen(
    id: 'tartrazine',
    names: {'uk': 'Тартразин', 'en': 'Tartrazine', 'es': 'Tartrazina', 'it': 'Tartrazina', 'de': 'Tartrazin', 'fr': 'Tartrazine', 'pt': 'Tartrazina', 'pl': 'Tartrazyna', 'cs': 'Tartrazin', 'ru': 'Тартразин', 'be': 'Тартразін'},
    groups: {'uk': 'Додатки', 'en': 'Additives', 'es': 'Aditivos', 'it': 'Additivi', 'de': 'Zusatzstoffe', 'fr': 'Additifs', 'pt': 'Aditivos', 'pl': 'Dodatki', 'cs': 'Přídatné látky', 'ru': 'Добавки', 'be': 'Дадаткі'},
    akas: {'uk': ['E102', 'жовтий барвник'], 'en': ['E102', 'yellow 5'], 'es': ['E102', 'amarillo 5'], 'it': ['E102', 'giallo 5'], 'de': ['E102', 'Gelb 5'], 'fr': ['E102', 'jaune 5'], 'pt': ['E102', 'amarelo 5'], 'pl': ['E102', 'żółcień 5'], 'cs': ['E102', 'žluť'], 'ru': ['E102', 'жёлтый краситель'], 'be': ['E102', 'жоўты фарбавальнік']},
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
      if (a.names.values.any((n) => n.toLowerCase().contains(s)) ||
          a.aka.any((k) => k.toLowerCase().contains(s)))
        a,
  ];
}
