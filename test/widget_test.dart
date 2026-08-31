import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/day.dart';
import 'package:calvi/data/fixtures.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/main.dart';

void main() {
  testWidgets('застосунок відкривається першим запуском, а не днем', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('uk')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(const CalviApp(storage: false, hello: false));
    await tester.pump(const Duration(seconds: 1));

    /* Перше, що бачить новий телефон, це розвилка, а не питання про стать.
       Той, хто вже має акаунт, мусить мати куди піти з першого ж екрана:
       заповнювати анкету заради даних, які лежать на сервері, безглуздо. */
    expect(find.text('Почати'), findsOneWidget);
    expect(find.text('У мене вже є акаунт'), findsOneWidget);
    expect(find.text('Про тебе'), findsNothing, reason: 'питання ще не ставили');

    // Дорога новачка: за розвилкою починається те, заради чого «Старт» і є.
    await tester.tap(find.text('Почати'));
    await tester.pumpAndSettle();

    expect(find.text('Про тебе'), findsOneWidget);
    expect(find.text('Сніданок'), findsNothing, reason: 'день ще не заслужено');
  });

  testWidgets('«У мене вже є акаунт» веде одразу на вхід, без питань', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = const [Locale('uk')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const CalviApp(storage: false, hello: false));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('У мене вже є акаунт'));
    await tester.pumpAndSettle();

    /* Жодного питання анкети між розвилкою і входом: профіль приїде з акаунта
       разом зі щоденником. Кнопок провайдерів у тестовій збірці немає, бо вхід
       у ній не налаштований, тому екран пізнається за тим, що на ньому є
       завжди. */
    expect(find.text('Увійти без акаунту'), findsOneWidget);
    expect(find.text('Про тебе'), findsNothing);
  });

  testWidgets('той, хто повертається, не пропускає анкету повз вхід', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = const [Locale('uk')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const CalviApp(storage: false, hello: false));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('У мене вже є акаунт'));
    await tester.pumpAndSettle();

    /* Передумав входити. Профілю нема ні на телефоні, ні в акаунті, і випустити
       його на день означало б зберегти заводську чернетку «Старту»: чоловік, 26
       років, 178 см. На сервері вона затерла б справжні цілі, а на телефоні
       просто збрехала б. Тому дорога веде на перше питання, а не в день. */
    await tester.tap(find.text('Увійти без акаунту'));
    await tester.pumpAndSettle();

    expect(find.text('Про тебе'), findsOneWidget, reason: 'анкету обійшли стороною');
    expect(find.text('Сніданок'), findsNothing, reason: 'день відкрився з чужим профілем');
  });

  testWidgets('перший запуск проходиться до кінця і відкриває день', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = const [Locale('uk')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const CalviApp(storage: false, hello: false));
    await tester.pump(const Duration(seconds: 1));

    /* Перший запуск відкривається розвилкою «уперше чи повертаюсь». Тести
       йдуть дорогою новачка, тому тиснуть «Почати». */
    await tester.tap(find.text('Почати'));
    await tester.pumpAndSettle();

    // Про тебе, Вага, Ціль, Темп, Спосіб життя, Норма.
    // Settle rather than a fixed pump: the switcher keeps the outgoing step in
    // the tree for the length of the slide, and two «Далі» is an ambiguous tap.
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.text('Далі'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Збережімо це'), findsOneWidget, reason: 'акаунт останній, не перший');

    await tester.tap(find.text('Увійти без акаунту'));
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
