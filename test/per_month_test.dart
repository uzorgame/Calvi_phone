import 'package:calvi/data/billing/billing.dart';
import 'package:flutter_test/flutter_test.dart';

/* Місячна вартість річної підписки береться з рядка магазину, і рядки в
   магазинів різні: Play в Україні ставить пробіл між тисячами і кому перед
   копійками, App Store у США крапку і долар спереду. */
void main() {
  test('Play, гривня: пробіл між тисячами і кома перед копійками', () {
    expect(Billing.perMonthOf('1 399,99 грн', 1399.99), '116,67 грн');
  });

  test('App Store, долар спереду', () {
    expect(Billing.perMonthOf(r'$39.99', 39.99), r'$3.33');
  });

  test('євро після числа, кома десяткова', () {
    expect(Billing.perMonthOf('39,99 €', 39.99), '3,33 €');
  });

  test('англійський формат із комою між тисячами', () {
    expect(Billing.perMonthOf('UAH 1,399.99', 1399.99), 'UAH 116.67');
  });

  test('валюта без копійок округлюється до цілого', () {
    expect(Billing.perMonthOf('¥4,000', 4000), '¥333');
  });

  test('рядок без числа лишається як є', () {
    expect(Billing.perMonthOf('free', 0), 'free');
  });
}
