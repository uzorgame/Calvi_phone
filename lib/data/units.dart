/// Units on screen. The data underneath stays metric.
///
/// The database keeps kilograms, centimetres, millilitres, grams and
/// kilocalories, and it always will: a person who switches to pounds a year
/// from now must see every old weigh-in in pounds too, and the only way to get
/// that for free is to convert at the last moment, where a number becomes a
/// string. Nothing here changes what is stored; the tape, the diary and the
/// server keep counting the way they did.
///
/// Every screen reads [dataUnits], which `main` refreshes together with the
/// settings. The extension gives each quantity three things: the number the way
/// it should read (`massNum`), the unit word (`massLabel`) and both together
/// (`mass`), plus the way back for the rulers and steppers (`massIn`).
library;

import '../format.dart' show thousands;
import '../l10n/app_localizations.dart';
import '../l10n/data_lang.dart';
import 'settings.dart' show Units, metricUnits;

/// What the screens show in. Set by `main`, read everywhere.
Units dataUnits = metricUnits;

const _lbPerKg = 2.2046226;
const _kgPerSt = 6.3502932;
const _cmPerIn = 2.54;
const _mlPerFloz = 29.5735;
const _gPerOz = 28.349523;
const _kjPerKcal = 4.184;

/// The pickers on the start screen and in settings share one table.
///
/// Values are what the database stores, labels are what the person reads.
/// Metric labels come from the translation: «кг» in Ukrainian is not `kg`.
/* Позначка і повна назва, і потрібні обидві.
 *
 * Позначка стоїть поруч із кожним числом на екрані. Назва потрібна там, де
 * вибір показаний рядками: «st» саме по собі це не питання і не відповідь, а
 * «Стоуни» з прикладом під ними це і те, і те. */
List<({String key, String title, List<String> labels, List<String> names, List<String> values})>
unitGroups(L l) => [
  (
    key: 'mass',
    title: l.unitsMass,
    labels: [l.unitKg, 'lb', 'st'],
    names: [l.unitKgName, l.unitLbName, l.unitStName],
    values: ['kg', 'lb', 'st'],
  ),
  (
    key: 'length',
    title: l.unitsLength,
    labels: [l.unitCm, 'in'],
    names: [l.unitCmName, l.unitInName],
    values: ['cm', 'in'],
  ),
  (
    key: 'volume',
    title: l.unitsVolume,
    labels: [l.unitMl, 'fl oz'],
    names: [l.unitMlName, l.unitFlozName],
    values: ['ml', 'floz'],
  ),
  (
    key: 'portion',
    title: l.unitsPortion,
    labels: [l.unitG, 'oz'],
    names: [l.unitGName, l.unitOzName],
    values: ['g', 'oz'],
  ),
  (
    key: 'energy',
    title: l.unitsEnergy,
    labels: [l.unitKcal, l.unitKj],
    names: [l.unitKcalName, l.unitKjName],
    values: ['kcal', 'kj'],
  ),
];

/* Як виглядатиме число в цих одиницях.
 *
 * Рахується тим самим кодом, що й усі числа застосунку: приклад, вписаний
 * рукою, розійшовся б із дійсністю на першій же правці округлення, і побачити
 * це було б нікому.
 *
 * Числа передаються ззовні, бо вони різні в двох місцях. В анкеті своїх ще
 * немає, там ідуть звичайні; у налаштуваннях приходять власні, і приклад із
 * чужою вагою виглядав би там як чужий. */
String unitSample(String key, Units units, {
  required double weightKg,
  required int heightCm,
  required int waterMl,
  required int kcal,
}) => switch (key) {
  'mass' => units.massText(weightKg),
  'length' => units.heightText(heightCm),
  'volume' => units.volText(waterMl),
  'portion' => units.porText(300),
  _ => units.enText(kcal),
};

extension UnitsShow on Units {
  bool get metric =>
      mass == 'kg' && length == 'cm' && volume == 'ml' && portion == 'g' && energy == 'kcal';

  /// One line for the settings row: «кг · см · мл · г · ккал».
  String get line => [massLabel, lenLabel, volLabel, porLabel, enLabel].join(' · ');

  // MARK: Body mass

  String get massLabel => switch (mass) { 'lb' => 'lb', 'st' => 'st', _ => dataL.unitKg };

  /* Stones as a decimal, not «11 st 6 lb». One reading for the ruler, the
     chart, the hero card and the notes; two spellings of the same weight in one
     app would read as two different weights. */
  double massOut(double kg) => switch (mass) {
    'lb' => kg * _lbPerKg,
    'st' => kg / _kgPerSt,
    _ => kg,
  };

  /* Back to kilograms, to the hundredth. A ruler notch is a tenth of a pound,
     and the kilograms behind it would otherwise carry a tail of twelve digits
     into the database; a hundredth of a kilogram is finer than the notch, so
     the ruler lands on the same mark after the round trip. */
  double massIn(double shown) => switch (mass) {
    'lb' => _hundredths(shown / _lbPerKg),
    'st' => _hundredths(shown * _kgPerSt),
    _ => shown,
  };

  String massNum(double kg, {int decimals = 1}) => massOut(kg).toStringAsFixed(decimals);

  /// The end of a ruler: a round number, not 88.18 lb.
  double massBound(double kg) => massOut(kg).roundToDouble();

  String massText(double kg, {int decimals = 1}) =>
      '${massNum(kg, decimals: decimals)} $massLabel';

  /// A change, signed: «+0.4 кг», «-0.9 lb».
  String massDelta(double kg) =>
      '${kg > 0 ? '+' : ''}${massNum(kg)} $massLabel';

  // MARK: Length

  String get lenLabel => length == 'in' ? 'in' : dataL.unitCm;

  double lenOut(double cm) => length == 'in' ? cm / _cmPerIn : cm;

  double lenIn(double shown) => length == 'in' ? _hundredths(shown * _cmPerIn) : shown;

  String lenNum(double cm) => lenOut(cm).toStringAsFixed(1);

  String lenText(double cm) => '${lenNum(cm)} $lenLabel';

  /* Height is the one length people say in feet: «5′9″», never «69 in». The
     wheel still turns in whole inches, because that is what it can hold, and
     the label on each notch is what makes it readable. */
  int heightOut(int cm) => length == 'in' ? (cm / _cmPerIn).round() : cm;

  int heightIn(int shown) => length == 'in' ? (shown * _cmPerIn).round() : shown;

  String heightNum(int shown) =>
      length == 'in' ? '${shown ~/ 12}′${shown % 12}″' : '$shown';

  String heightText(int cm) =>
      length == 'in' ? heightNum(heightOut(cm)) : '$cm ${dataL.unitCm}';

  /// What the height wheel turns through: centimetres, or whole inches from
  /// 4′3″ to 8′2″, which is the same span the metric list covers.
  List<int> get heightWheel =>
      length == 'in' ? List.generate(48, (i) => i + 51) : List.generate(91, (i) => i + 130);

  // MARK: Water

  String get volLabel => volume == 'floz' ? 'fl oz' : dataL.unitMl;

  int volOut(int ml) => volume == 'floz' ? (ml / _mlPerFloz).round() : ml;

  int volIn(int shown) => volume == 'floz' ? (shown * _mlPerFloz).round() : shown;

  /// One press on the water card. Four fluid ounces is the same small cup that
  /// a hundred millilitres is; a hundred millilitres in ounces is «3.4», and
  /// nobody drinks in 3.4s.
  int get volStep => volume == 'floz' ? volIn(4) : 100;

  String volNum(int ml) => thousands(volOut(ml));

  String volText(int ml) => '${volNum(ml)} $volLabel';

  // MARK: Portions

  String get porLabel => portion == 'oz' ? 'oz' : dataL.unitG;

  double porOut(num g) => portion == 'oz' ? g / _gPerOz : g.toDouble();

  int porIn(num shown) => portion == 'oz' ? (shown * _gPerOz).round() : shown.round();

  /// Grams are whole, ounces keep one decimal: a 30 g spoon is 1.1 oz, and a
  /// whole «1 oz» would be a different spoon.
  String porNum(num g) => portion == 'oz' ? porOut(g).toStringAsFixed(1) : '${g.round()}';

  String porText(num g) => '${porNum(g)} $porLabel';

  /// What the portion wheel turns through: fives of grams, or whole ounces.
  List<int> get porWheel =>
      portion == 'oz' ? List.generate(100, (i) => i + 1) : List.generate(299, (i) => (i + 2) * 5);

  /// The nearest notch of [porWheel] for a stored weight.
  int porNotch(num g) => portion == 'oz'
      ? porOut(g).round().clamp(1, 100)
      : (g / 5).round().clamp(2, 300) * 5;

  // MARK: Energy

  String get enLabel => energy == 'kj' ? dataL.unitKj : dataL.unitKcal;

  int enOut(int kcal) => energy == 'kj' ? (kcal * _kjPerKcal).round() : kcal;

  int enIn(int shown) => energy == 'kj' ? (shown / _kjPerKcal).round() : shown;

  String enNum(int kcal) => thousands(enOut(kcal));

  String enText(int kcal) => '${enNum(kcal)} $enLabel';

  /// One press on the norm stepper: fifty kilocalories, or the two hundred
  /// kilojoules that read as the same round step.
  int get enStep => energy == 'kj' ? 200 : 50;

  /// Grams that stay grams: protein, fat and carbohydrate are counted in grams
  /// on every label in the world, ounces included.
  String gramsText(int g) => '$g ${dataL.unitG}';

  /// What the person sends to the server, and only when it is not metric:
  /// an absent field means «as always», so nobody who never chose has to send
  /// anything.
  Map<String, dynamic>? get wire => metric ? null : toJson();
}

double _hundredths(double v) => (v * 100).round() / 100;
