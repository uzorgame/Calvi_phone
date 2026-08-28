import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/day.dart';
import 'package:calvi/data/meal.dart';
import 'package:calvi/data/measure.dart';
import 'package:calvi/data/workout.dart';
import 'package:calvi/design/icons.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/design/tokens.dart';
import 'package:calvi/screens/today/measure_card.dart';
import 'package:calvi/screens/today/meal_card.dart';
import 'package:calvi/screens/today/water_card.dart';
import 'package:calvi/screens/today/workout_card.dart';
import 'package:calvi/l10n/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: L.localizationsDelegates,
  supportedLocales: L.supportedLocales,
  locale: const Locale('uk'),
  theme: calviLightTheme,
  home: Scaffold(body: ListView(children: [child])),
);

void main() {
  _sendMark();
  _waterBar();

  testWidgets('вода рахує склянки і крокує по 100 мл', (tester) async {
    var ml = 900;
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, set) => WaterCard(
            ml: ml,
            goalMl: 2200,
            onChange: (v) => set(() => ml = v),
            open: true,
            onToggle: () {},
          ),
        ),
      ),
    );

    expect(find.text('близько 4 склянок'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Більше на 100 мл'));
    await tester.pump();
    expect(ml, 1000);
  });

  testWidgets('вода не йде в мінус', (tester) async {
    var ml = 50;
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, set) => WaterCard(
            ml: ml,
            goalMl: 2200,
            onChange: (v) => set(() => ml = v),
            open: true,
            onToggle: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Менше на 100 мл'));
    await tester.pump();
    expect(ml, 0, reason: 'мінус 100 від 50 має впертись у нуль');
  });

  testWidgets('тренування показує спалене зі знаком мінус', (tester) async {
    await tester.pumpWidget(
      _wrap(
        WorkoutCard(
          workouts: const [
            Workout(id: 'w', activity: 'run', title: 'Біг', minutes: 34, kcal: 310, time: '07:20'),
          ],
          onAdd: (_) {},
          open: true,
          onToggle: () {},
        ),
      ),
    );

    expect(find.text('−310 ккал'), findsOneWidget);
    expect(find.text('1 сесія'), findsOneWidget);
    expect(find.text('34 хв'), findsOneWidget);
  });

  testWidgets('оцінка спаленого рахується за MET і округлюється до пʼяти', (tester) async {
    // 9.8 MET, 78.6 кг, 30 хв -> 404.5, тобто 405.
    expect(burnEstimate(9.8, 30) % 5, 0);
    expect(burnEstimate(9.8, 30), 405);
  });

  testWidgets('вимірювання показує тільки те, що людина міряє', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MeasureCard(
          date: todayDate,
          list: demoMeasures,
          tracked: const ['weightKg'],
          onTrack: (_) {},
          onSave: (_) {},
          onStats: () {},
          open: true,
          onToggle: () {},
        ),
      ),
    );

    expect(find.text('Вага'), findsOneWidget);
    expect(find.text('Біцепс'), findsNothing, reason: 'нестежене поле не має стояти в картці');

    /* Поле порожнє, а минуле число стоїть підказкою.
     *
     * Спершу тут підставлялось останнє значення як звичайний текст, і картка
     * казала «останнє сьогодні» над числом, якого сьогодні ніхто не міряв.
     * Заміри належать дню: минуле видно, але воно ще не сьогоднішнє. */
    final field = tester.widget<TextField>(find.byType(TextField).first);
    expect(field.controller?.text, isEmpty, reason: 'учорашнє число підставили як сьогоднішнє');
    expect(field.decoration?.hintText, '78.6', reason: 'минуле мало лишитись підказкою');
    /* Nothing to save is nothing to press: the card offers the button only
       once a figure has actually been changed. */
    expect(find.text('Зберегти заміри'), findsNothing);
  });
  testWidgets('рядок страви несе грами, БЖВ і час', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MealCard(
          slot: baseSlots['breakfast']!,
          meals: const [
            Meal(
              id: 'x',
              icon: 'egg',
              title: 'Яєчня',
              time: '08:20',
              slotId: 'breakfast',
              grams: 160,
              kcal: 214,
              protein: 14,
              fat: 16,
              carbs: 2,
            ),
          ],
          open: true,
          onToggle: () {},
          onAdd: (_) {},
          onManual: (_) {},
          noraCan: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('160 г'), findsOneWidget);
    expect(find.text('14'), findsOneWidget, reason: 'білок');
    expect(find.text('16'), findsOneWidget, reason: 'жири');
    expect(find.text('214'), findsOneWidget, reason: 'калорії');
    expect(find.text('08:20'), findsOneWidget);
  });

  testWidgets('нерозібраний запис не вигадує чисел', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MealCard(
          slot: baseSlots['lunch']!,
          meals: const [
            Meal(
              id: 'y',
              icon: 'soup',
              title: 'Борщ',
              time: '13:05',
              slotId: 'lunch',
              pending: true,
            ),
          ],
          open: true,
          onToggle: () {},
          onAdd: (_) {},
          onManual: (_) {},
          noraCan: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Нора рахує…'), findsOneWidget);
    expect(find.text('···'), findsOneWidget, reason: 'нуль калорій був би вигадкою');
  });
}

/// The send mark in an opened card.
///
/// It used to fade with the button: a grey plus on the grey disabled ground,
/// which is a button you have to hunt for. The demo dims the ground and leaves
/// the mark in the button's own ink.
void _sendMark() {
  testWidgets('плюс у картці читається і поки нічого не написано', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: Scaffold(
          body: ListView(
            children: [
              MealCard(
                slot: baseSlots['breakfast']!,
                meals: const [],
                open: true,
                onToggle: () {},
                onAdd: (_) {},
                onManual: (_) {},
                noraCan: true,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final mark = tester.widget<CalviIcon>(
      find.descendant(of: find.bySemanticsLabel('Записати'), matching: find.byType(CalviIcon)),
    );
    expect(mark.color, calviLight.buttonText, reason: 'знак злився з тлом кнопки');
  });
}

/// The water bar: a full-width track with the fill growing from its left edge.
///
/// The stack sized itself by the fill, so at forty per cent the whole bar came
/// out forty per cent wide and sat centred in the card, with no track to either
/// side of it.
void _waterBar() {
  testWidgets('смуга води на всю ширину, заповнення зліва', (tester) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: Scaffold(
          body: ListView(
            children: [
              WaterCard(ml: 900, goalMl: 2200, open: true, onToggle: () {}, onChange: (_) {}),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    /* Смуга це склянки, а не суцільне заповнення: воду рахують склянками, і
       норма 2 200 мл це дев'ять їх, з яких 900 мл це чотири. */
    final marks = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer)).toList();
    expect(marks.length, 9, reason: 'поділок не за нормою');

    final full = marks
        .where((m) => (m.decoration as BoxDecoration).color == calviLight.fats)
        .length;
    expect(full, 4, reason: 'налито не стільки склянок, скільки випито');

    /* Ряд поділок займає всю ширину картки: доріжка, що стиснулась до
       заповнення, це та сама помилка, яку ловив попередній тест. */
    final row = tester.getRect(
      find.ancestor(of: find.byType(AnimatedContainer).first, matching: find.byType(Row)).first,
    );
    expect(row.width, greaterThan(200), reason: 'ряд склянок стиснувся');
  });
}
