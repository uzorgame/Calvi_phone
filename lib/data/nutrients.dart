/// Другий рівень нутрієнтів: клітковина, цукор, доданий цукор, натрій, насичені.
library;

/* Пʼять чисел, кожне з яких може бути невідомим.
 *
 * `null` тут не лінощі типу, а сама суть. Три макроси приходять майже завжди, а
 * ці пʼять приходять нерівно: сервер рахує їх лише для страв, які встиг
 * оцінити, довідник наповнюється роками, а все записане до появи цієї
 * можливості лишиться без них назавжди.
 *
 * Нуль означає «цього тут немає»: у мʼясі справді немає клітковини. Порожньо
 * означає «ще не знаємо». Показати друге як перше означає збрехати людині, яка
 * стежить за цукром, і саме цю помилку вже одного разу виправляли на сервері
 * окремою міграцією.
 */
class Nutrients {
  const Nutrients({this.fiber, this.sugar, this.added, this.sodiumMg, this.sat});

  /// Грами.
  final double? fiber;
  final double? sugar;
  final double? added;

  /// Міліграми: так друкують на пачках і так лежить на сервері.
  final double? sodiumMg;
  final double? sat;

  static const none = Nutrients();

  bool get knownAny => fiber != null || sugar != null || added != null || sodiumMg != null || sat != null;

  /// Та сама пʼятірка на іншу вагу. Невідоме множення не робить відомим: чого
  /// довідник не знає на сто грамів, того він не знає і на сто тридцять.
  Nutrients scaled(double k) => Nutrients(
    fiber: fiber == null ? null : fiber! * k,
    sugar: sugar == null ? null : sugar! * k,
    added: added == null ? null : added! * k,
    sodiumMg: sodiumMg == null ? null : sodiumMg! * k,
    sat: sat == null ? null : sat! * k,
  );

  double? operator [](NutrientKey k) => switch (k) {
    NutrientKey.fiber => fiber,
    NutrientKey.sugar => sugar,
    NutrientKey.added => added,
    NutrientKey.sodium => sodiumMg,
    NutrientKey.sat => sat,
  };
}

enum NutrientKey { fiber, sugar, added, sodium, sat }

/* Скільки набралось за день і скільки страв ми при цьому не порахували.
 *
 * Друге число не менш важливе за перше. «12 г клітковини» при трьох
 * непорахованих стравах це не «12», це «щонайменше 12», і екран, який змовчить
 * про різницю, покаже недобір там, де його може й не бути.
 */
class NutrientDay {
  const NutrientDay({required this.sum, required this.unknown, required this.counted});

  final Nutrients sum;

  /// Скільки страв дня не знають цього числа, по кожному окремо.
  final Map<NutrientKey, int> unknown;

  /// Скільки страв узагалі було в дні.
  final int counted;

  /// Чи є про це число бодай щось.
  bool known(NutrientKey k) => sum[k] != null;

  /// Чи повна картина: жодної страви без цього числа.
  bool whole(NutrientKey k) => (unknown[k] ?? 0) == 0;
}

/* Сума за день, разом із тим, скількох страв у ній бракує.
 *
 * Приймає самі пʼятірки, а не страви, щоб цей файл не знав ні про [Meal], ні
 * про профіль: інакше три файли посилались би по колу заради одного поля. */
NutrientDay nutrientsOver(Iterable<Nutrients> all) {
  final unknown = {for (final k in NutrientKey.values) k: 0};
  final sums = <NutrientKey, double?>{for (final k in NutrientKey.values) k: null};

  var counted = 0;
  for (final one in all) {
    counted += 1;
    for (final k in NutrientKey.values) {
      final v = one[k];
      if (v == null) {
        unknown[k] = unknown[k]! + 1;
      } else {
        sums[k] = (sums[k] ?? 0) + v;
      }
    }
  }

  return NutrientDay(
    sum: Nutrients(
      fiber: sums[NutrientKey.fiber],
      sugar: sums[NutrientKey.sugar],
      added: sums[NutrientKey.added],
      sodiumMg: sums[NutrientKey.sodium],
      sat: sums[NutrientKey.sat],
    ),
    unknown: unknown,
    counted: counted,
  );
}

/* Денні орієнтири від норми самої людини, а не від умовних двох тисяч калорій.
 *
 * ВООЗ і EFSA пишуть їх у відсотках від енергії або на тисячу калорій, тому
 * однакове число для того, хто їсть 1800, і для того, хто їсть 2900, було б
 * однаково неправильним для обох.
 *
 * Один із пʼяти це ціль, якої добирають, три це стеля, а загальний цукор норми
 * не має взагалі: рекомендації обмежують доданий, і шкала під загальним назвала
 * б яблуко проблемою.
 */
class NutrientGoal {
  const NutrientGoal({
    required this.fiber,
    required this.added,
    required this.addedBetter,
    required this.sodiumMg,
    required this.sat,
  });

  /// EFSA: щонайменше 25 г; США рахують 14 г на кожну тисячу калорій.
  final int fiber;

  /// ВООЗ: менше 10% калорій.
  final int added;

  /// Бажаніша стеля ВООЗ: менше 5%.
  final int addedBetter;

  /// ВООЗ: менше 2000 мг натрію, тобто близько 5 г солі. Від калорій не
  /// залежить: це про судини, а не про енергію.
  final int sodiumMg;

  /// ВООЗ 2023: менше 10% калорій із насичених.
  final int sat;

  /// Ціль чи стеля. Різні речі, і малюються по-різному.
  static bool reached(NutrientKey k) => k == NutrientKey.fiber;

  /// У загального цукру шкали немає навмисно.
  int? of(NutrientKey k) => switch (k) {
    NutrientKey.fiber => fiber,
    NutrientKey.sugar => null,
    NutrientKey.added => added,
    NutrientKey.sodium => sodiumMg,
    NutrientKey.sat => sat,
  };
}

NutrientGoal nutrientGoals(int kcal) => NutrientGoal(
  fiber: (14 * kcal / 1000).round() < 25 ? 25 : (14 * kcal / 1000).round(),
  added: (kcal * 0.1 / 4).round(),
  addedBetter: (kcal * 0.05 / 4).round(),
  sodiumMg: 2000,
  sat: (kcal * 0.1 / 9).round(),
);

/// Маса солі з натрію: натрій, помножений на 2.5, у грамах.
double saltFrom(double sodiumMg) => sodiumMg * 2.5 / 1000;

/* Як людина солить. Поправка до припущення сервера, а не смак: скільки солі в
   домашній страві, знає тільки той, хто її солив. */
enum SaltHand { less, usual, more }

const saltHandOptions = <SaltHand>[SaltHand.less, SaltHand.usual, SaltHand.more];

/// Рядок для сервера. `usual` не шлеться порожнім навмисно: вибір людини це
/// вибір, навіть коли він збігається із замовчуванням.
String saltHandKey(SaltHand v) => v.name;

SaltHand saltHandOf(String? key) => switch (key) {
  'less' => SaltHand.less,
  'more' => SaltHand.more,
  _ => SaltHand.usual,
};

/// Чи показувати другий рівень і яким. Замовчування малий: це нагляд, а не
/// план, і великий вигляд вмикають ті, хто справді добирає клітковину.
enum NutriLevel { off, small, large }

const nutriLevelOptions = <NutriLevel>[NutriLevel.off, NutriLevel.small, NutriLevel.large];

String nutriLevelKey(NutriLevel v) => v.name;

NutriLevel nutriLevelOf(String? key) => switch (key) {
  'off' => NutriLevel.off,
  'large' => NutriLevel.large,
  _ => NutriLevel.small,
};
