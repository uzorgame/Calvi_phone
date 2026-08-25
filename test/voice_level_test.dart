import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/screens/voice/dictation.dart';

/// Метр рухається на обох системах, бо число від них приходить різне.
///
/// Android дає щось на кшталт децибелів у проміжку приблизно від мінус двох до
/// десяти, тобто здебільшого додатне. iOS рахує `20 * log10(rms)`, а це
/// децибели відносно максимуму, і вони завжди відʼємні. На обидві стояла одна
/// андроїдна формула, `raw / 10` із притисканням до нуля, тож на iOS кожне
/// значення ставало нулем і метр стояв, поки людина говорила.
void main() {
  double android(double raw) => Dictation.levelOf(raw, on: TargetPlatform.android);
  double ios(double raw) => Dictation.levelOf(raw, on: TargetPlatform.iOS);

  /* Найважливіше в цьому файлі. На Android метр працював правильно, і полагодження
     iOS не має права зрушити його ані на крок. Числа тут не вигадані, а взяті з
     тієї самої формули, яка стояла до правки: `(raw / 10).clamp(0, 1)`. */
  test('андроїдна шкала лишилась точно такою, якою була', () {
    for (final raw in [-2.0, -0.5, 0.0, 1.0, 2.5, 5.0, 7.5, 9.9, 10.0, 12.0]) {
      expect(
        android(raw),
        (raw / 10).clamp(0.0, 1.0),
        reason: 'андроїдне $raw поїхало, а на Android усе працювало',
      );
    }
  });

  test('на iOS тиша це нуль, а не мовчазний метр під час мови', () {
    // Тиха кімната в мікрофон.
    expect(ios(-60), 0);
    expect(ios(-50), 0);

    /* А ось те, заради чого все: звичайна мова має рухати метр. Доти всі ці
       числа давали рівно нуль. */
    expect(ios(-35), greaterThan(0.2));
    expect(ios(-25), closeTo(0.5, 0.001));
    expect(ios(-12), greaterThan(0.7));
    expect(ios(0), 1);
  });

  test('на iOS шкала росте разом із голосом, без провалів', () {
    var last = -1.0;
    for (var db = -50.0; db <= 0; db += 2.5) {
      final now = ios(db);
      expect(now, greaterThanOrEqualTo(last), reason: 'на $db дБ метр пішов назад');
      last = now;
    }
    expect(last, 1);
  });

  /* Цифрова тиша це `log10(0)`, тобто мінус нескінченність. Ділення її на що
     завгодно лишається нескінченністю, і метр застряг би на ній назавжди. */
  test('нескінченність і не-число не ламають метр', () {
    expect(ios(double.negativeInfinity), 0);
    expect(ios(double.infinity), 0);
    expect(ios(double.nan), 0);
    expect(android(double.negativeInfinity), 0);
  });

  /* Не за знаком числа, а за системою. Спокуса була саме така: «відʼємне значить
     iOS». Але тихий Android теж присилає відʼємне, і за знаком воно потрапило б
     у чужу шкалу, де мінус два дає 0.96 замість нуля. */
  test('тихий Android не плутається з iOS', () {
    expect(android(-2), 0, reason: 'тиша на Android має бути тишею');
    expect(ios(-2), greaterThan(0.9), reason: 'мінус два децибели на iOS це майже крик');
  });

  test('macOS рахується разом з iOS, бо там той самий код плагіна', () {
    expect(Dictation.levelOf(-25, on: TargetPlatform.macOS), closeTo(0.5, 0.001));
  });
}
