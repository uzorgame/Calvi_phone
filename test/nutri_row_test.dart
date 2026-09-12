import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/meal.dart';
import 'package:calvi/data/nutrients.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/screens/settings/panels_account.dart';
import 'package:calvi/design/icons.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/design/nutri_row.dart';

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
    bool pro = true,
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
              pro: pro,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /* Ряд середніх на тижні й в аналітиці: те саме правило, що на дні.
   *
   * Без Pro цифр немає в дереві віджетів, з Pro вони на місці. Перевіряється
   * саме це, а не оформлення: розмиття знімається однією властивістю, а
   * відсутність числа ні. */
  Future<void> showAvg(WidgetTester tester, {required bool pro}) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: Scaffold(
          body: Center(
            child: NutriAvgRow(
              avg: const Nutrients(fiber: 12, sugar: 44, added: 7, sodiumMg: 3248, sat: 33),
              goal: nutrientGoals(2000),
              pro: pro,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('середні нутрієнти показують числа в Pro', (tester) async {
    await showAvg(tester, pro: true);

    expect(find.textContaining('12'), findsWidgets, reason: 'клітковина зникла');
    expect(find.textContaining('3.2'), findsWidgets, reason: 'натрій має бути в грамах');
  });

  testWidgets('середні нутрієнти без Pro не показують жодної цифри', (tester) async {
    await showAvg(tester, pro: false);

    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      final said = text.data ?? '';
      expect(RegExp(r'[0-9]').hasMatch(said), isFalse, reason: 'цифра «$said» у замкненому ряду');
    }

    await tester.tap(find.byType(CalviIcon).first);
    await tester.pumpAndSettle();
    expect(find.text('Нутрієнти в Pro'), findsOneWidget);
  });

  /* Замкнена смуга рівно такої самої висоти, як відкрита.
   *
   * Без цього сторінка стрибала б у мить покупки, а в замкненому малому ряду
   * взагалі поїхала верстка: `Center` усередині клітинки розтягував її на всю
   * доступну висоту, і смуга виходила на шістсот пікселів замість тридцяти
   * девʼяти. Число тут одне на обидва стани, тому воно й перевіряється разом. */
  for (final large in [false, true]) {
    testWidgets('замкнена смуга ${large ? 'велика' : 'мала'} така сама заввишки', (tester) async {
      final meals = [dish('Борщ', const Nutrients(fiber: 4, sugar: 5, added: 0, sodiumMg: 1300, sat: 9))];

      await show(tester, meals, large: large);
      final open = tester.getSize(find.byType(NutriRow)).height;

      await show(tester, meals, large: large, pro: false);
      final shut = tester.getSize(find.byType(NutriRow)).height;

      /* Піксель допуску, і він чесний. Місце під число тримає порожній рядок
         того самого кегля, а порожній рядок на піксель нижчий за рядок із
         цифрами: висоту задають самі гліфи. Домалювати їх невидимими не можна,
         бо тоді число повернулось би в дерево, а саме його тут і немає.
         Сторожа це не послаблює: він ловив шістсот пікселів замість тридцяти
         девʼяти, а не одиницю. */
      expect(
        (shut - open).abs(),
        lessThanOrEqualTo(1),
        reason: 'замкнена смуга $shut проти відкритої $open',
      );
    });
  }

  /* Замок без Pro, і перевіряється тут одне: чисел немає.
   *
   * Не схованих, не розмитих, не підмінених нулями. Розмите число це все одно
   * число в дереві віджетів, і якби ми ховали його оформленням, ця перевірка
   * впала б: вона шукає цифри, а не те, як вони виглядають. */
  testWidgets('без Pro у смузі немає жодної цифри', (tester) async {
    await show(
      tester,
      [dish('Борщ', const Nutrients(fiber: 4, sugar: 5, added: 0, sodiumMg: 1300, sat: 9))],
      pro: false,
    );

    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      final said = text.data ?? '';
      expect(
        RegExp(r'[0-9]').hasMatch(said),
        isFalse,
        reason: 'цифра «$said» у замкненій смузі',
      );
    }
  });

  /* І слова теж тільки на дотик: на головному екрані про підписку не сказано
     нічого, поки по смузі не натиснули. */
  testWidgets('без Pro про підписку мовчать, поки не натиснути', (tester) async {
    await show(
      tester,
      [dish('Борщ', const Nutrients(fiber: 4, sugar: 5, added: 0, sodiumMg: 1300, sat: 9))],
      pro: false,
    );

    expect(find.textContaining('Pro'), findsNothing, reason: 'напис висить на екрані щодня');

    await tester.tap(find.byType(CalviIcon).first);
    await tester.pumpAndSettle();

    expect(find.text('Нутрієнти в Pro'), findsOneWidget);
    expect(
      find.textContaining('без підписки теж'),
      findsOneWidget,
      reason: 'головне речення: числа рахуються і без Pro',
    );
  });

  /* День із записами, у яких цих чисел немає, виглядає як порожній: самі знаки.
   *
   * Тут очікувався рядок «Ці страви не рахували». Він розповідав про нашу
   * власну неповноту, стояв на головному екрані замість чисел і не пропонував
   * людині нічого: зробити з ним вона не може нічого. Ряд знаків каже те саме
   * без слів. */
  testWidgets('день без жодного з пʼяти показує самі знаки, без слів і без нулів', (tester) async {
    await show(tester, [dish('Борщ', Nutrients.none), dish('Хліб', Nutrients.none)]);

    expect(find.text('Ці страви не рахували'), findsNothing);
    expect(find.byType(CalviIcon), findsNWidgets(5), reason: 'пʼять знаків, по одному на нутрієнт');
    expect(find.textContaining('?'), findsNothing, reason: 'знак питання це не порожнеча');
    expect(find.textContaining('0'), findsNothing, reason: 'нуль тут означав би «цього не було»');
  });

  /* Порожній день мовчить.
   *
   * Тут очікувався рядок «Нутрієнти зʼявляться з першим записом». Він
   * повідомляв те, що людина й так бачить: у дні немає жодного запису. Тепер на
   * тому самому місці стоять самі знаки, без чисел і без слів: вони кажуть, що
   * саме тут зʼявиться, і не забирають рядок екрана на пояснення очевидного. */
  testWidgets('порожній день показує самі знаки, без слів і без чисел', (tester) async {
    await show(tester, []);

    expect(find.text('Нутрієнти зʼявляться з першим записом'), findsNothing);
    expect(find.text('Ці страви не рахували'), findsNothing);
    expect(find.byType(CalviIcon), findsNWidgets(5), reason: 'пʼять знаків, по одному на нутрієнт');
    expect(find.textContaining('?'), findsNothing, reason: 'знак питання це не порожнеча');
    expect(find.textContaining('0'), findsNothing, reason: 'нуль тут означав би «цього не було»');
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
