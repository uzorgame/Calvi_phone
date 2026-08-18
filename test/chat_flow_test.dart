import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/meal.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/main.dart';
import 'package:calvi/screens/today/bottom_bar.dart';
import 'package:calvi/screens/today/meal_card.dart';

void main() {
  testWidgets('поле всередині картки віддає текст і очищається', (tester) async {
    final said = <String>[];
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
                onAdd: said.add,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'два яйця і тост');
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Записати'));
    await tester.pump();

    expect(said, ['два яйця і тост']);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '',
      reason: 'поле очищається, інакше друге «те саме» піде двічі',
    );
  });

  testWidgets('відповідь Нори приходить на такт пізніше за наше повідомлення', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const CalviApp(storage: false));
    await tester.pump(const Duration(seconds: 1));

    // Straight through the first run to the day.
    await tester.tap(find.text('Почати'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 7; i++) {
      await tester.tap(find.text('Далі'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Продовжити з Google'));
    await tester.pump(const Duration(seconds: 1));

    /* Through the bar at the bottom, which is where most sentences arrive. It
       also sits at a fixed place on the screen, so the test is not measuring
       where a list happened to scroll to. */
    final bar = find.descendant(of: find.byType(BottomBar), matching: find.byType(TextField));
    await tester.enterText(bar, 'два яйця і тост');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text('два яйця і тост'),
      findsOneWidget,
      reason: 'наше повідомлення вже в чаті',
    );
    expect(
      find.textContaining('Записав'),
      findsNothing,
      reason: 'обидва одразу означали б, що відповідь була написана наперед',
    );

    await tester.pump(const Duration(milliseconds: 900));
    expect(find.textContaining('Записав'), findsOneWidget);
  });
}
