import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/settings.dart';

/// Знак між «поточна» і «ціль»: напрямок руху ваги і вердикт про нього.
///
/// Перевіряється саме розділення цих двох: стрілка вниз тому, хто худне, це
/// успіх, а тому, хто набирає, невдача. Один і той самий знак, різний колір.
void main() {
  SettingsState at({
    required Direction direction,
    required double start,
    required double now,
    double target = 74,
  }) => initialSettings().copyWith(
    direction: direction,
    goalStartKg: start,
    weightKg: now,
    targetKg: target,
  );

  test('худне і справді худне: стрілка вниз, зелена', () {
    final t = goalTrend(at(direction: Direction.lose, start: 81, now: 78.6));
    expect(t.icon, 'trend-down');
    expect(t.good, isTrue);
  });

  test('худне, а вагу набирає: стрілка вгору, червона', () {
    final t = goalTrend(at(direction: Direction.lose, start: 81, now: 83.2));
    expect(t.icon, 'trend-up');
    expect(t.good, isFalse);
  });

  test('набирає і справді набирає: стрілка вгору, зелена', () {
    final t = goalTrend(at(direction: Direction.gain, start: 60, now: 62.5, target: 68));
    expect(t.icon, 'trend-up');
    expect(t.good, isTrue);
  });

  test('набирає, а вагу втрачає: стрілка вниз, червона', () {
    final t = goalTrend(at(direction: Direction.gain, start: 60, now: 58.4, target: 68));
    expect(t.icon, 'trend-down');
    expect(t.good, isFalse);
  });

  /* Ціль «тримати»: знака руху немає взагалі, бо успіх тут це його
     відсутність. Півкілограма в обидва боки це та сама вага. */
  test('тримає вагу і тримає: знак рівності, зелений', () {
    for (final now in [74.0, 74.5, 73.5]) {
      final t = goalTrend(at(direction: Direction.keep, start: 74, now: now));
      expect(t.icon, 'equal', reason: 'на $now кг знак не рівності');
      expect(t.good, isTrue, reason: 'на $now кг вердикт не зелений');
    }
  });

  test('тримає вагу, а вона поїхала: знак рівності, червоний', () {
    for (final now in [74.6, 73.4, 78.0]) {
      final t = goalTrend(at(direction: Direction.keep, start: 74, now: now));
      expect(t.icon, 'equal');
      expect(t.good, isFalse, reason: 'на $now кг відхилення пораховано як норма');
    }
  });

  test('ціль щойно поставлена: знак рівності без вердикту', () {
    final t = goalTrend(at(direction: Direction.lose, start: 81, now: 81));
    expect(t.icon, 'equal');
    expect(t.good, isNull, reason: 'оцінено те, чого ще не сталось');
  });
}
