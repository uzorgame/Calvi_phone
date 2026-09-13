import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'first_run.dart';

import 'package:calvi/data/day.dart';
import 'package:calvi/data/fixtures.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/main.dart';

void main() {
  testWidgets('застосунок відкривається першим запуском, а не днем', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = const [Locale('uk')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(const CalviApp(storage: false, hello: false));
    await tester.pump(const Duration(seconds: 1));

    /* Перше, що бачить новий телефон, це вітання. Воно нічого не питає і само
       йде далі: розвилки «уперше чи повертаюсь» більше немає, бо на неї
       відповідає наступний екран, де вхід і реєстрація стоять поруч. */
    expect(find.text('Про тебе'), findsNothing, reason: 'питання ще не ставили');

    await welcomeOut(tester);

    expect(find.text('Вхід'), findsOneWidget);
    /* У тестовій збірці входу немає взагалі, і тоді лишається запобіжник:
       інакше перший запуск не мав би куди вести. У магазинній збірці
       провайдери є, і цього рядка там не буває. */
    expect(find.text('Далі без акаунту'), findsOneWidget);
    expect(find.text('Про тебе'), findsNothing, reason: 'анкета після входу, не перед');
  });

  testWidgets('реєстрація це окрема сторінка, і назад із неї є куди', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = const [Locale('uk')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const CalviApp(storage: false, hello: false));
    await tester.pump(const Duration(seconds: 1));
    await welcomeOut(tester);

    await tester.tap(find.text('Зареєструватись'));
    await tester.pumpAndSettle();

    /* Три поля і більше нічого: провайдери, розділювач і «далі без акаунту» на
       цю сторінку не переїжджають. */
    expect(find.text('Заведімо акаунт'), findsOneWidget);
    expect(find.text('ПІДТВЕРДЖЕННЯ ПАРОЛЯ'), findsOneWidget);
    expect(find.text('Далі без акаунту'), findsNothing);

    /* Стрілка згори, та сама, що на решті анкети. На самому вході її немає, бо
       позаду першого екрана нічого. */
    await tester.tap(find.bySemanticsLabel('Назад'));
    await tester.pumpAndSettle();
    expect(find.text('Вхід'), findsOneWidget);
  });

  testWidgets('перший запуск проходиться до кінця і відкриває день', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = const [Locale('uk')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const CalviApp(storage: false, hello: false));
    await tester.pump(const Duration(seconds: 1));
    await welcomeOut(tester);

    /* Вхід стоїть першим і веде на перше питання анкети, а не в день: профілю
       ще немає ні на телефоні, ні на сервері. */
    await tester.tap(find.text('Далі без акаунту'));
    await tester.pumpAndSettle();

    /* Між входом і першим питанням стоїть «Ласкаво просимо»: єдиний екран
       анкети, який нічого не питає, і тому кнопка на ньому веде далі, а не
       відповідає. */
    expect(find.text('Ласкаво просимо в'), findsOneWidget);
    await tester.tap(find.text('Почати'));
    await tester.pumpAndSettle();

    expect(find.text('Про тебе'), findsOneWidget);
    expect(find.text('Сніданок'), findsNothing, reason: 'день ще не заслужено');

    // Про тебе, Одиниці, Вага, Ціль, Темп, Спосіб життя, Норма.
    // Settle rather than a fixed pump: the switcher keeps the outgoing step in
    // the tree for the length of the slide, and two «Далі» is an ambiguous tap.
    for (var i = 0; i < 7; i++) {
      await tester.tap(find.text('Далі'));
      await tester.pumpAndSettle();
    }

    /* Пейвол останній, і з нього дві дороги в щоденник. Тест іде безкоштовною:
       пробні токени і так у кожного. */
    expect(find.text('Оформити'), findsOneWidget, reason: 'пейвол останній');

    await tester.tap(find.text('Почати із пробними 40 токенами'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    /* Кінець першого запуску це не порожній день, а розмова: штора чату
       піднімається сама, і в порожній розмові стоїть картка Нори. Пояснювати
       порожній день нічим, і показати замість нього те, заради чого застосунок
       ставили, краще за підказку поверх нулів. */
    expect(
      find.textContaining('Пиши або кажи як зазвичай'),
      findsOneWidget,
      reason: 'штора піднялась сама, без дотику до чату',
    );

    // Завісою назад у день: далі перевіряємо саме його.
    await tester.tapAt(const Offset(195, 80));
    await tester.pumpAndSettle();

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
