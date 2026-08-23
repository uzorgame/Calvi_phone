import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/settings.dart';

/// Прогрес до цілі рухається в обидва боки.
///
/// Тут стояла формула тільки для схуднення, з умовою «старт більший за ціль».
/// Для набору ваги вона мовчки давала нуль: людина набрала три кілограми з
/// пʼяти і бачила порожнє кільце. Напрямок не має значення для самого питання,
/// бо пройдене це відстань від старту в бік цілі.
void main() {
  SettingsState at({required double start, required double now, required double target}) =>
      emptySettings().copyWith(goalStartKg: start, weightKg: now, targetKg: target);

  test('набір ваги: три з пʼяти це шістдесят відсотків', () {
    expect(goalProgress(at(start: 75, now: 78, target: 80)), closeTo(0.6, 0.001));
  });

  test('схуднення: три з шести це половина', () {
    expect(goalProgress(at(start: 80, now: 77, target: 74)), closeTo(0.5, 0.001));
  });

  test('на старті нуль, на цілі одиниця', () {
    expect(goalProgress(at(start: 75, now: 75, target: 80)), 0);
    expect(goalProgress(at(start: 75, now: 80, target: 80)), 1);
    expect(goalProgress(at(start: 80, now: 80, target: 74)), 0);
    expect(goalProgress(at(start: 80, now: 74, target: 74)), 1);
  });

  test('переступ через ціль лишається одиницею', () {
    expect(goalProgress(at(start: 75, now: 83, target: 80)), 1);
    expect(goalProgress(at(start: 80, now: 70, target: 74)), 1);
  });

  test('рух у зворотний бік не йде в мінус', () {
    /* Кільце показує здобуте, а не борг: відʼємне заповнення намалювати нема
       як, і людину, яка й так відкотилась, не варто тицяти носом. */
    expect(goalProgress(at(start: 75, now: 73, target: 80)), 0);
    expect(goalProgress(at(start: 80, now: 82, target: 74)), 0);
  });

  test('тримати вагу: повне, поки тримається', () {
    expect(goalProgress(at(start: 75, now: 75, target: 75)), 1);
    expect(goalProgress(at(start: 75, now: 76, target: 75)), closeTo(2 / 3, 0.001));
    expect(goalProgress(at(start: 75, now: 79, target: 75)), 0);
  });
}
