import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/meal.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/today/meal_card.dart';
import 'package:calvi/screens/meds/meds_form.dart';
import 'package:calvi/screens/today/slot_card.dart';

/// Where the line actually sits inside the field it is typed into.
///
/// Measured rather than eyeballed: a field can be told to centre its text and
/// still sit it high, because what centres is the editable box and not the line
/// inside it.
void main() {
  testWidgets('рядок у полі картки стоїть по центру поля', (tester) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: calviLightTheme,
        home: Scaffold(
          body: ListView(
            children: [
              MealCard(
                slot: baseSlots['dinner']!,
                meals: const [],
                open: true,
                onToggle: () {},
                onAdd: (_) {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The pill the field lives in, and the hint drawn inside it.
    final field = tester.getRect(
      find.ancestor(of: find.byType(TextField), matching: find.byType(Container)).first,
    );
    final hint = tester.getRect(find.text('Напиши, що було'));

    expect(
      hint.center.dy - field.center.dy,
      closeTo(0, 1.5),
      reason:
          'рядок стоїть не по центру поля: '
          'поле ${field.top.toStringAsFixed(1)}..${field.bottom.toStringAsFixed(1)}, '
          'рядок ${hint.top.toStringAsFixed(1)}..${hint.bottom.toStringAsFixed(1)}',
    );
  });

  testWidgets('порожня картка не задирає підказку над полем', (tester) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: calviLightTheme,
        home: Scaffold(body: SlotInput(onSend: (_) {})),
      ),
    );
    await tester.pumpAndSettle();

    final field = tester.getRect(find.byType(Container).first);
    final hint = tester.getRect(find.text('Напиши, що було'));
    expect(hint.center.dy - field.center.dy, closeTo(0, 1.5));
  });

  testWidgets('рядок у полі препарату стоїть по центру поля', (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: calviLightTheme,
        home: Scaffold(
          body: ListView(children: [MedsForm(onSave: (_) {}, onDone: () {}, now: 0)]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    /* The same fault the day's card had: a box of a fixed height puts what is
       inside it at the top unless it is told otherwise, and the line reads as
       hanging off the field's ceiling. */
    final hint = find.text('Наприклад, Магній B6');
    final field = tester.getRect(find.ancestor(of: hint, matching: find.byType(Container)).first);
    final line = tester.getRect(hint);

    expect(
      line.center.dy - field.center.dy,
      closeTo(0, 1.5),
      reason:
          'рядок стоїть не по центру поля: '
          'поле ${field.top.toStringAsFixed(1)}..${field.bottom.toStringAsFixed(1)}, '
          'рядок ${line.top.toStringAsFixed(1)}..${line.bottom.toStringAsFixed(1)}',
    );
  });
}
