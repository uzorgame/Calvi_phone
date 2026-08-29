import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/day.dart';
import 'package:calvi/data/day_stats.dart';
import 'package:calvi/data/measure.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/analytics/analytics_screen.dart';

/// Аудит екрана «Аналітика».
///
/// Питання одне на всі перевірки: **чи можна вірити тому, що на екрані**. Не
/// «чи гарно», а чи взяті числа з того самого місця, що й решта застосунку, і
/// чи мовчить екран там, де даних немає.
///
/// Найдорожча помилка тут не падіння, а правдоподібна вигадка: заповнені смуги
/// над порожнім щоденником людина читає як свої і вирішує по них, скільки ще
/// їсти сьогодні.
Widget _wrap(DayStats stats, {SettingsState? s, double scale = 1}) => AppScope(
  s: s ?? initialSettings(),
  set: (_) {},
  meds: const [],
  setMeds: (_) {},
  stats: stats,
  child: MaterialApp(
    localizationsDelegates: L.localizationsDelegates,
    supportedLocales: L.supportedLocales,
    locale: const Locale('uk'),
    theme: calviLightTheme,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: AnalyticsScreen(measures: stats.measures, onSettings: () {}),
    ),
  ),
);

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Увесь текст сторінки, зібраний прокручуванням.
///
/// Сторінка це список, а список будує тільки видиме: без прокручування нижні
/// картки не існують у дереві, і перевірка «там правильне число» мовчки
/// проходила б, не подивившись на нього жодного разу.
Future<String> _readAll(WidgetTester tester) async {
  final seen = <String>{};
  final list = find.byType(Scrollable).first;

  for (var step = 0; step < 14; step++) {
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      /* І `Text`, і `Text.rich`: числа тут майже всюди складені зі шматків
         (значення плюс одиниця іншим кеглем), і в таких `data` порожній. Тест,
         який читає тільки `data`, не бачить жодного числа на екрані і мовчки
         проходить. */
      seen.add(t.data ?? t.textSpan?.toPlainText() ?? '');
    }
    await tester.drag(list, const Offset(0, -400));
    await tester.pumpAndSettle();
  }

  // Назад угору: перемикач періоду живе там, і після читання по ньому ще
  // тиснуть.
  await tester.drag(list, const Offset(0, 6000));
  await tester.pumpAndSettle();

  return '|${seen.join('|')}|';
}

void main() {
  testWidgets('вага і ціль ті самі, що в налаштуваннях', (tester) async {
    _phone(tester);
    final s = initialSettings().copyWith(weightKg: 82.4, targetKg: 75);
    await tester.pumpWidget(_wrap(DayStats.demo(), s: s));
    await tester.pumpAndSettle();

    /* Картка прогресу читає налаштування, а не фікстури. Вага, поставлена
       людиною, і картка, яка показує зашиту в код, це два різні застосунки на
       одному екрані. */
    expect(find.text('82.4'), findsWidgets, reason: 'поточна вага не з налаштувань');
    expect(find.text('75.0'), findsWidgets, reason: 'ціль не з налаштувань');
  });

  testWidgets('порожній щоденник не малює чужих чисел', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_wrap(DayStats.empty));
    await tester.pumpAndSettle();

    final l = await L.delegate.load(const Locale('uk'));
    final seen = await _readAll(tester);

    // Замість калорій і БЖВ мають стояти чесні порожні стани.
    expect(seen.contains(l.anKcalEmpty), isTrue, reason: 'порожні калорії мовчать не так');
    expect(seen.contains(l.anMacrosEmpty), isTrue, reason: 'порожнє БЖВ мовчить не так');

    /* Числа, які колись були вписані в код і малювались завжди. Якщо вони
       повернуться, цей рядок скаже про це першим. */
    for (final invented in ['96', '71', '268', '2\u00A0240']) {
      expect(
        seen.contains('|$invented|'),
        isFalse,
        reason: 'на порожньому щоденнику стоїть вигадане число $invented',
      );
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('перемикач періоду рухає числа, а не тільки себе', (tester) async {
    _phone(tester);

    /* День на тиждень назад і день на два місяці назад. Тиждень має бачити
       перший і не бачити другий, місяць має бачити обидва: саме це відрізняє
       робочий перемикач від чотирьох пігулок, які нічого не роблять. */
    final stats = DayStats(
      totals: {
        -3: const DayTotals(kcal: 1000, protein: 50, fat: 30, carbs: 100),
        -50: const DayTotals(kcal: 2000, protein: 90, fat: 60, carbs: 200),
      },
      water: const {},
      weights: const {},
      demo: false,
    );

    await tester.pumpWidget(_wrap(stats));
    await tester.pumpAndSettle();

    final l = await L.delegate.load(const Locale('uk'));

    // Тиждень: тільки перший день.
    expect(
      (await _readAll(tester)).contains('|1\u00A0000|'),
      isTrue,
      reason: 'за тиждень сума не 1000',
    );

    await tester.tap(find.text(l.anMonth));
    await tester.pumpAndSettle();

    // Місяць це чотири тижні, і день на пʼятдесятий назад у нього не входить.
    expect(
      (await _readAll(tester)).contains('|1\u00A0000|'),
      isTrue,
      reason: 'за місяць сума змінилась, хоч не мала',
    );

    await tester.tap(find.text(l.anQuarter));
    await tester.pumpAndSettle();

    // Квартал бачить обидва дні: 1000 + 2000.
    expect(
      (await _readAll(tester)).contains('|3\u00A0000|'),
      isTrue,
      reason: 'за квартал сума не 3000',
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('картка прогресу каже три числа: старт, зараз і ціль', (tester) async {
    _phone(tester);
    final s = initialSettings().copyWith(goalStartKg: 84.5, weightKg: 80.2, targetKg: 74);
    await tester.pumpWidget(_wrap(DayStats.demo(), s: s));
    await tester.pumpAndSettle();

    /* Без стартової ваги середнє число ні з чим не порівняти: «80.2» саме по
       собі не каже, це вже пів дороги чи ще нічого. */
    expect(find.text('84.5'), findsWidgets, reason: 'старту немає');
    expect(find.text('80.2'), findsWidgets, reason: 'поточної ваги немає');
    expect(find.text('74.0'), findsWidgets, reason: 'цілі немає');

    final l = await L.delegate.load(const Locale('uk'));
    expect(find.text(l.anStartKg), findsOneWidget, reason: 'старт без підпису');
  });

  testWidgets('обидва графіки ваги показують одну й ту саму вагу', (tester) async {
    _phone(tester);

    /* На екрані дві криві ваги: у картці прогресу і в «Замірах». Дані під ними
       одні, тож і остання точка мусить бути одна. Доти верхня крива згладжувала
       період у сім середніх, і її підказка казала «79.0» там, де заголовок над
       нею казав «78.8»: два числа однієї ваги на одному екрані. */
    final s = initialSettings().copyWith(goalStartKg: 84.0, weightKg: 78.8, targetKg: 74);
    final stats = DayStats(
      totals: const {},
      water: const {},
      weights: const {-1: 78.8, -2: 79.4, -5: 79.9, -9: 80.6, -14: 81.2, -20: 82.0},
      measures: [
        for (final e in const {-1: 78.8, -2: 79.4, -5: 79.9, -9: 80.6, -14: 81.2, -20: 82.0}.entries)
          Measure(date: e.key, values: {'weightKg': e.value}),
      ],
      demo: false,
    );

    await tester.pumpWidget(_wrap(stats, s: s));
    await tester.pumpAndSettle();

    final seen = await _readAll(tester);

    // Одне число ваги на весь екран: те, що людина зважила останнім.
    expect(seen.contains('|78.8|'), isTrue, reason: 'поточної ваги немає: $seen');

    /* Жодного середнього, якого людина не записувала. 79.1 це середнє двох
       останніх зважувань, і саме такі числа малювала згладжена крива, поки
       картка прогресу жила за своїм правилом. */
    for (final invented in ['79.1', '79.0', '80.2']) {
      expect(
        seen.contains('|$invented|'),
        isFalse,
        reason: 'на екрані число, якого немає в записах: $invented',
      );
      expect(
        seen.contains('|$invented кг|'),
        isFalse,
        reason: 'на кривій число, якого немає в записах: $invented',
      );
    }
  });

  testWidgets('вага в підказці кругла, а не з хвостом', (tester) async {
    _phone(tester);

    /* Точка кривої це середнє кількох зважувань за відрізок, а середнє двох
       чесних чисел дає 78.97500000000001. Саме цей хвіст людина й бачила
       замість своєї ваги. */
    final stats = DayStats(
      totals: const {},
      water: const {},
      weights: const {-1: 78.9, -2: 79.05, -20: 80.0, -40: 81.0},
      demo: false,
    );

    await tester.pumpWidget(_wrap(stats));
    await tester.pumpAndSettle();

    final seen = await _readAll(tester);
    expect(
      RegExp(r'\d+\.\d{3,}').hasMatch(seen),
      isFalse,
      reason: 'на екрані число з довгим хвостом: $seen',
    );
  });

  testWidgets('вікно періоду рівно таке, як написано на кнопці', (tester) async {
    _phone(tester);

    /* Сім колонок ділять період націло, тому місяць це чотири тижні, а не
       тридцять пʼять днів. Доти під графіком води стояло «17 із 35» там, де
       людина обрала місяць, і пояснити те число було нічим. */
    final stats = DayStats(
      totals: const {},
      water: {for (var d = -400; d <= 0; d++) d: 2500},
      weights: const {},
      demo: false,
    );

    await tester.pumpWidget(_wrap(stats));
    await tester.pumpAndSettle();

    final l = await L.delegate.load(const Locale('uk'));

    expect((await _readAll(tester)).contains('|7/7|'), isTrue, reason: 'тиждень не сім днів');

    await tester.tap(find.text(l.anMonth));
    await tester.pumpAndSettle();
    expect((await _readAll(tester)).contains('|28/28|'), isTrue, reason: 'місяць не чотири тижні');

    await tester.tap(find.text(l.anQuarter));
    await tester.pumpAndSettle();
    expect((await _readAll(tester)).contains('|91/91|'), isTrue, reason: 'квартал не тринадцять тижнів');
  });

  testWidgets('середнє ділиться на записані дні, а не на календар', (tester) async {
    _phone(tester);

    /* Два записані дні з семи. Середнє це 1500, а не 3000/7 = 429: день, який
       людина забула записати, це не день, коли вона нічого не їла. */
    final stats = DayStats(
      totals: {
        -1: const DayTotals(kcal: 1000, protein: 0, fat: 0, carbs: 0),
        -2: const DayTotals(kcal: 2000, protein: 0, fat: 0, carbs: 0),
      },
      water: const {},
      weights: const {},
      demo: false,
    );

    await tester.pumpWidget(_wrap(stats));
    await tester.pumpAndSettle();

    expect(
      (await _readAll(tester)).contains('|1\u00A0500|'),
      isTrue,
      reason: 'середнє поділено на календар',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('екран влазить зі збільшеним шрифтом', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_wrap(DayStats.demo(), scale: 1.3));
    await tester.pumpAndSettle();

    /* Не лише перший екран: картки нижче будуються тільки коли до них
       дійшли, і перевірка без прокручування дивиться на верхню третину
       сторінки. Саме там, нижче, і ховалась легенда, яка не вміла
       переноситись. */
    await _readAll(tester);

    expect(tester.takeException(), isNull, reason: 'зі збільшеним шрифтом щось обрізається');
  });
}
