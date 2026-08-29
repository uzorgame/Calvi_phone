import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/theme.dart';
import 'package:calvi/format.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/analytics/charts.dart';

/* Числа в банері калорій живуть на дотик.
 *
 * Сім колонок по чотири цифри це таблиця, а не графік, тому число зʼявляється
 * тільки там, куди спитали. Помилка тут тиха: банер лишається гарним і просто
 * перестає відповідати, а перевірити це оком на кожній збірці нема кому. */

const _rows = [
  (label: 'ПН', protein: 100, fat: 50, carbs: 200),
  (label: 'ВТ', protein: 80, fat: 40, carbs: 150),
];

/// ПН: 100*4 + 50*9 + 200*4 = 1650, з них вуглеводи 800.
final _mondayTotal = thousands(1650);
final _mondayCarbs = thousands(800);
final _norm = thousands(2000);

Widget _wrap() => MaterialApp(
  localizationsDelegates: L.localizationsDelegates,
  supportedLocales: L.supportedLocales,
  locale: const Locale('uk'),
  theme: calviLightTheme,
  home: const Scaffold(
    body: Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 320,
        child: MacroBars(rows: _rows, norm: 2000),
      ),
    ),
  ),
);

/* Складники в стопці лежать згори донизу: вуглеводи, жири, білок. Отже перший
   дотиковий осередок першої колонки це її вуглеводи. */
Finder _carbsOf(int column) => find.byType(GestureDetector).at(column * 3);

void main() {
  testWidgets('норма стоїть числом, а калорії мовчать до дотику', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text(_norm), findsOneWidget, reason: 'лінія норми без числа');
    expect(find.text(_mondayTotal), findsNothing, reason: 'числа стоять без питання');
  });

  testWidgets('перший дотик каже день, другий складник, третій знову день', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    // Перший дотик: калорії всього дня, і колонка виходить наперед.
    await tester.tap(_carbsOf(0));
    await tester.pumpAndSettle();
    expect(find.text(_mondayTotal), findsOneWidget, reason: 'день не назвався');
    final scales = tester
        .widgetList<AnimatedScale>(find.byType(AnimatedScale))
        .map((w) => w.scale)
        .toList();
    expect(scales.first > scales.last, isTrue, reason: 'вибрана колонка не виросла: $scales');

    // Другий, по тому самому складнику: калорії самого складника.
    await tester.tap(_carbsOf(0));
    await tester.pumpAndSettle();
    expect(find.text(_mondayCarbs), findsOneWidget, reason: 'складник не назвався');
    expect(find.text(_mondayTotal), findsNothing, reason: 'два числа одночасно');

    // Той самий складник ще раз повертає день.
    await tester.tap(_carbsOf(0));
    await tester.pumpAndSettle();
    expect(find.text(_mondayTotal), findsOneWidget, reason: 'повернення до дня не працює');
  });

  testWidgets('дотик по сусідній колонці переносить вибір одним разом', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(_carbsOf(0));
    await tester.pumpAndSettle();
    await tester.tap(_carbsOf(1));
    await tester.pumpAndSettle();

    // ВТ: 80*4 + 40*9 + 150*4 = 1280.
    expect(find.text(thousands(1280)), findsOneWidget, reason: 'сусідня колонка не взялась');
    expect(find.text(_mondayTotal), findsNothing, reason: 'стара колонка не відпустила');
  });

  testWidgets('число стоїть над колонкою і не втискається в її ширину', (tester) async {
    /* Найдорожча помилка цього банера була тиха: пігулку малювали всередині
       колонки, а колонка обрізає все, що з неї виходить, і «2 510» ставало
       «2 51». На довгих періодах числа пʼятизначні, і в тонку смугу не влізуть
       ніяк, тому число живе над нею і своєї ширини не питає ні в кого. */
    /* Сім колонок, як на справжньому екрані: саме вузька колонка і різала
       число. Перша важить 2800 + 5600 + 3150 = 11 550 ккал. */
    const wide = [
      (label: 'ПН', protein: 700, fat: 350, carbs: 1400),
      (label: 'ВТ', protein: 500, fat: 250, carbs: 1000),
      (label: 'СР', protein: 480, fat: 240, carbs: 960),
      (label: 'ЧТ', protein: 520, fat: 260, carbs: 1040),
      (label: 'ПТ', protein: 460, fat: 230, carbs: 920),
      (label: 'СБ', protein: 540, fat: 270, carbs: 1080),
      (label: 'НД', protein: 500, fat: 250, carbs: 1000),
    ];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: const Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(width: 300, child: MacroBars(rows: wide, norm: 2000, span: 7)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    final tip = find.text(thousands(11550));
    expect(tip, findsOneWidget, reason: 'число дня не показалось повністю');

    final bar = tester.getRect(find.byType(ClipRRect).first);
    final label = tester.getRect(tip);

    expect(
      label.bottom <= bar.top + 1,
      isTrue,
      reason: 'число стоїть у колонці, а не над нею: $label проти $bar',
    );
    expect(
      label.width > bar.width,
      isTrue,
      reason: 'число втиснуте в ширину колонки: ${label.width} проти ${bar.width}',
    );
  });

  testWidgets('дотик поза колонками знімає вибір', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(_carbsOf(0));
    await tester.pumpAndSettle();
    expect(find.text(_mondayTotal), findsOneWidget);

    // Кут екрана: банера там немає.
    await tester.tapAt(const Offset(10, 590));
    await tester.pumpAndSettle();
    expect(find.text(_mondayTotal), findsNothing, reason: 'вибір не гасне поза банером');
  });
}
