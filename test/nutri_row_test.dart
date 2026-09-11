import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/meal.dart';
import 'package:calvi/data/nutrients.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/screens/settings/panels_account.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/today/nutri_row.dart';

/// Смуга другого рівня: три стани і жодного вигаданого нуля.
///
/// Перевіряється тут не оформлення, а те, що екран каже правду про власну
/// неповноту. Страв без цих чисел буде багато: усе, записане до появи такого
/// підрахунку, лишиться без них назавжди. Смуга, яка змовчить про це, покаже
/// недобір клітковини там, де ми просто не рахували половину дня.
void main() {
  Meal dish(String title, Nutrients n) =>
      Meal(id: title, icon: 'plate', title: title, time: '13:00', slotId: 'lunch', nutrients: n);

  Future<void> show(
    WidgetTester tester,
    List<Meal> meals, {
    bool large = false,
    String lang = 'uk',
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: Locale(lang),
        theme: calviLightTheme,
        home: Scaffold(
          body: Center(
            child: NutriRow(
              day: nutrientsOver([for (final m in meals) m.nutrients]),
              goal: nutrientGoals(2000),
              meals: meals,
              large: large,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('день без жодного з пʼяти каже про це словами, а не нулями', (tester) async {
    await show(tester, [dish('Борщ', Nutrients.none), dish('Хліб', Nutrients.none)]);

    expect(find.text('Ці страви не рахували'), findsOneWidget);
    expect(find.textContaining('0'), findsNothing, reason: 'нуль тут означав би «цього не було»');
  });

  testWidgets('порожній день чекає на перший запис', (tester) async {
    await show(tester, []);
    expect(find.text('Нутрієнти зʼявляться з першим записом'), findsOneWidget);
  });

  /* Неповний день не позначається в самому ряду.
   *
   * Тут стояв плюс після одиниці, і його довелось прибрати: знак, про який
   * питають «а що це?», не пояснює нічого, а стояв би він майже в кожному дні,
   * бо все, записане до появи підрахунку, лишається без цих чисел. Число в ряду
   * лишається числом, а про межу точності каже шторка, і каже реченням. */
  testWidgets('неповний день не ставить у ряду жодних позначок', (tester) async {
    await show(tester, [
      dish('Борщ', const Nutrients(fiber: 3, sugar: 4, added: 0, sodiumMg: 840, sat: 2.8)),
      dish('Кава', Nutrients.none),
    ]);

    expect(find.textContaining('+'), findsNothing);
    expect(find.textContaining('?'), findsNothing, reason: 'числа тут є, питати нема про що');
  });

  testWidgets('дотик відкриває шторку, і вона каже, чого в числі бракує', (tester) async {
    await show(tester, [
      dish('Борщ', const Nutrients(fiber: 3, sugar: 4, added: 0, sodiumMg: 840, sat: 2.8)),
      dish('Кава', Nutrients.none),
    ]);

    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    expect(find.text('Клітковина'), findsWidgets);
    /* Саме «щонайменше», а не голе число: у дні є страва без цих чисел, і три
       грами це нижня межа. Норма своя, з калорій цієї людини. */
    expect(find.text('щонайменше 3 г сьогодні з 28'), findsOneWidget);
    expect(find.text('Одна страва без цих чисел, тому це нижня межа.'), findsOneWidget);
    // Звідки саме: єдина частина шторки, яка перетворює число на дію.
    expect(find.text('Борщ'), findsOneWidget);
  });

  testWidgets('великий вигляд підписує стовпчики', (tester) async {
    await show(tester, [
      dish('Борщ', const Nutrients(fiber: 3, sugar: 4, added: 0, sodiumMg: 840, sat: 2.8)),
    ], large: true);

    expect(find.text('Натрій'), findsOneWidget);
    expect(find.text('Доданий'), findsOneWidget);
  });

  /* Пʼять стовпчиків на найменшому телефоні і найдовшою мовою.
   *
   * «Ballaststoffe» і «Gesättigt» під кільцем на трьохстах двадцяти пікселях це
   * шістдесят чотири пікселі на слово. Німецьке «KOHLENHYDRA» вже було, і
   * коштувало воно літери в підписі макроса. */
  for (final lang in ['de', 'pl', 'fr', 'pt', 'es', 'it', 'en', 'uk']) {
    testWidgets('стовпчики влазять мовою «$lang» на найменшому телефоні', (tester) async {
      await show(tester, [
        dish('Борщ', const Nutrients(fiber: 3, sugar: 4, added: 0, sodiumMg: 840, sat: 2.8)),
      ], large: true, lang: lang, size: const Size(320, 568));

      expect(tester.takeException(), isNull);
    });
  }

  /* Шторка найдовшою мовою на найменшому телефоні.
   *
   * Аркуш має стелю у три чверті екрана, а всередині опис, норма, джерело,
   * список страв і нотатка внизу. Німецькою це переростає стелю, і без
   * прокрутки на екран поїхала б жовто-чорна смуга переповнення. */
  for (final lang in ['de', 'fr', 'pt']) {
    testWidgets('шторка не переповнюється мовою «$lang» на найменшому телефоні', (tester) async {
      await show(tester, [
        dish('Ковбаса', const Nutrients(fiber: 0, sugar: 1, added: 1, sodiumMg: 2400, sat: 22)),
        dish('Хліб', const Nutrients(fiber: 1.8, sugar: 1.6, added: 0.8, sodiumMg: 288, sat: 0.2)),
        dish('Кава', Nutrients.none),
      ], lang: lang, size: const Size(320, 568));

      // Натрій: у нього найдовший опис і єдиний має нотатку внизу.
      await tester.tap(find.byType(GestureDetector).at(3));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('рівно на нормі стеля ще не перебрана', (tester) async {
    /* Норма натрію стала: дві тисячі міліграмів. Рівно на ній число лишається
       звичайним, і смуга в шторці має казати те саме. Червоніє воно з першим
       міліграмом понад норму, а не на ній. */
    await show(tester, [dish('Сир', const Nutrients(sodiumMg: 2000))]);

    final exact = tester
        .widgetList<Text>(find.byType(Text))
        .where((t) => t.textSpan?.toPlainText().startsWith('2.0') ?? false);
    expect(exact.length, 1);
    expect(
      exact.first.style?.color,
      isNot(calviLightTheme.extension<CalviTheme>()!.c.protein),
      reason: 'норма це ще не перебір',
    );
  });

  testWidgets('перебрана стеля видно кольором, а не тільки числом', (tester) async {
    /* Натрію вдвічі більше за норму. Тон міняється саме тут: під межею він
       однаковий для всіх, бо «мало» на неповному дні сказати не можна. */
    await show(tester, [dish('Ковбаса', const Nutrients(sodiumMg: 4200))]);

    final over = tester
        .widgetList<Text>(find.byType(Text))
        .where((t) => t.textSpan?.toPlainText().startsWith('4.2') ?? false);
    expect(over.length, 1);
    expect(over.first.style?.color, calviLightTheme.extension<CalviTheme>()!.c.protein);
  });

  /* Панель персоналізації кожною мовою на найменшому телефоні.
   *
   * Сусідній `every_language_fits_test` відкриває налаштування, але не заходить
   * у підсторінки, а саме тут стоять найдовші підписи: три вибори з поясненням
   * під кожним і два розділи на одному екрані. */
  for (final lang in ['de', 'pl', 'fr', 'pt', 'es', 'it', 'en', 'uk']) {
    testWidgets('персоналізація влазить мовою «$lang» на найменшому телефоні', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      var state = initialSettings();
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (_, setState) => MaterialApp(
            localizationsDelegates: L.localizationsDelegates,
            supportedLocales: L.supportedLocales,
            locale: Locale(lang),
            theme: calviLightTheme,
            scrollBehavior: const CalviScroll(),
            home: CustomPanel(s: state, set: (patch) => setState(() => state = patch(state))),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}
