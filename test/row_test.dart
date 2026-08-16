import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/shell.dart';
import 'package:calvi/design/theme.dart';

/// One row of settings, sized the way the demo sizes it.
///
/// Two ways of getting it wrong, both of which shipped: the value taking half
/// the line and floating in the middle of it, and the value sizing itself with
/// no ceiling, which pushed the title out of the row altogether.
Future<Rect?> _rowOf(WidgetTester tester, String title, String value, Finder of) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: calviLightTheme,
      home: Scaffold(
        body: SizedBox(
          width: 358,
          child: CalviRow(icon: 'user', title: title, value: value, onTap: () {}),
        ),
      ),
    ),
  );
  await tester.pump();
  return of.evaluate().isEmpty ? null : tester.getRect(of);
}

void main() {
  testWidgets('значення стоїть біля шеврона, а не посеред рядка', (tester) async {
    final value = await _rowOf(tester, 'Профіль', 'Ч, 26, 183 см', find.text('Ч, 26, 183 см'));
    expect(value, isNotNull);

    /* Against the chevron: the gap left after it is the row padding plus the
       mark itself, and nothing like the third of the line it used to leave. */
    expect(
      358 - value!.right,
      lessThan(48),
      reason: 'значення відірване від шеврона: правий край ${value.right}',
    );
  });

  testWidgets('довге значення не виштовхує назву з рядка', (tester) async {
    final title = await _rowOf(
      tester,
      'Нагадування',
      'їжа, вода, препарати, зважування, підсумок',
      find.text('Нагадування'),
    );

    expect(title, isNotNull, reason: 'назву рядка з\'їло довге значення');
    expect(title!.width, greaterThan(60), reason: 'від назви лишився огризок');
  });
}
