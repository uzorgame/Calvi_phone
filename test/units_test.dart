import 'package:calvi/data/settings.dart';
import 'package:calvi/data/units.dart';
import 'package:calvi/format.dart';
import 'package:calvi/l10n/data_lang.dart';
import 'package:flutter_test/flutter_test.dart';

/* Units are a view on metric data. The tests pin the two things that matter:
   the numbers people read, and that a ruler or a stepper lands back on the
   same kilogram, millilitre or gram after a round trip. */
void main() {
  setUp(() => dataLang = 'uk');

  test('metric shows what it always showed', () {
    const u = metricUnits;
    expect(u.metric, isTrue);
    expect(u.massText(72.5), '72.5 кг');
    expect(u.heightText(175), '175 см');
    expect(u.volText(1500), '${thousands(1500)} мл');
    expect(u.porText(350), '350 г');
    expect(u.enText(1850), '${thousands(1850)} ккал');
    expect(u.line, 'кг · см · мл · г · ккал');
    expect(u.wire, isNull, reason: 'метричне на сервер не їде');
  });

  test('pounds, inches, ounces, kilojoules', () {
    const u = Units(mass: 'lb', length: 'in', volume: 'floz', portion: 'oz', energy: 'kj');
    expect(u.metric, isFalse);
    expect(u.massText(72.5), '159.8 lb');
    expect(u.massDelta(-0.4), '-0.9 lb');
    expect(u.heightText(175), '5′9″');
    expect(u.lenText(80), '31.5 in');
    expect(u.volText(1500), '51 fl oz');
    expect(u.porText(350), '12.3 oz');
    expect(u.enText(1850), '${thousands(7740)} кДж');
    expect(u.wire, {'mass': 'lb', 'length': 'in', 'volume': 'floz', 'portion': 'oz', 'energy': 'kj'});
  });

  test('stones read as a decimal', () {
    const u = Units(mass: 'st');
    expect(u.massText(72.5), '11.4 st');
    expect(u.massBound(40), 6);
    expect(u.massBound(180), 28);
  });

  test('a ruler notch lands on the same kilogram after the round trip', () {
    const lb = Units(mass: 'lb');
    for (var kg = 40.0; kg <= 180; kg += 0.1) {
      final shown = double.parse(lb.massOut(kg).toStringAsFixed(1));
      expect(lb.massOut(lb.massIn(shown)).toStringAsFixed(1), shown.toStringAsFixed(1));
    }
    const inch = Units(length: 'in');
    for (var cm = 130; cm <= 220; cm++) {
      final shown = inch.heightOut(cm);
      expect(inch.heightOut(inch.heightIn(shown)), shown);
    }
  });

  test('water steps by a small cup in either unit', () {
    expect(metricUnits.volStep, 100);
    const floz = Units(volume: 'floz');
    expect(floz.volStep, 118);
    expect(floz.volOut(floz.volStep), 4);
    expect(floz.volText(floz.volStep), '4 fl oz');
  });

  test('portion wheel: ounces are whole, grams go by five', () {
    const oz = Units(portion: 'oz');
    expect(oz.porWheel.first, 1);
    expect(oz.porWheel.last, 100);
    expect(oz.porNotch(350), 12);
    expect(oz.porIn(12), 340);
    expect(metricUnits.porNotch(347), 345);
    expect(metricUnits.porIn(345), 345);
  });

  test('energy stepper: 50 kcal or 200 kJ, and 1200 kcal stays the floor', () {
    const kj = Units(energy: 'kj');
    expect(kj.enStep, 200);
    expect(kj.enOut(1200), 5021);
    expect(kj.enIn(5021), 1200);
    expect(metricUnits.enStep, 50);
  });

  test('macros stay grams whatever the portions read in', () {
    const oz = Units(portion: 'oz');
    expect(oz.gramsText(126), '126 г');
  });
}
