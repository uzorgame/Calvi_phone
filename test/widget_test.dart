import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/day.dart';
import 'package:calvi/data/fixtures.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/main.dart';

void main() {
  testWidgets('застосунок відкривається першим запуском, а не днем', (tester) async {
    await tester.pumpWidget(const CalviApp());
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Почати'), findsOneWidget);
    expect(find.text('Сніданок'), findsNothing, reason: 'день ще не заслужено');
  });

  testWidgets('перший запуск проходиться до кінця і відкриває день', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const CalviApp());
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Почати'));
    // Settle rather than a fixed pump: the switcher keeps the outgoing step in
    // the tree for the length of the slide, and two «Далі» is an ambiguous tap.
    await tester.pumpAndSettle();

    // Стать, Тіло, Ціль, Темп, Спосіб життя, Норма.
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.text('Далі'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Збережімо це'), findsOneWidget, reason: 'акаунт останній, не перший');

    await tester.tap(find.text('Продовжити з Google'));
    await tester.pump(const Duration(seconds: 1));

    // Breakfast, lunch and dinner stand whether or not anything went into them.
    expect(find.text('Сніданок'), findsOneWidget);
    expect(find.text('Вечеря'), findsOneWidget);

    /* The point of the extension is that widgets ask the theme rather than
       importing a palette. A null here means someone reached past it. */
    final ctx = tester.element(find.text('Calvi'));
    expect(Theme.of(ctx).extension<CalviTheme>(), isNotNull);
  });

  test('день без записів усе одно має три картки', () {
    final empty = dayFor(-40);
    expect(empty.slots.length, 3);
    expect(empty.totals.kcal, 0);
    expect(stateFor(-40), DayState.empty);
  });

  test('картки стають за фактичним часом, а не за очікуваною годиною', () {
    // The day that went over carries a snack logged before dinner.
    final d = dayFor(-3);
    final order = d.ordered.map((s) => s.id).toList();
    expect(order.indexOf('snack'), lessThan(order.indexOf('dinner')));
  });

  test('перебір рахується разом зі спаленим', () {
    final over = dayFor(-3);
    expect(stateFor(-3), DayState.over);
    expect(over.totals.kcal, greaterThan(fixtureGoal.kcal));
  });
}
