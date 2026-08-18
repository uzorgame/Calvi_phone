import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/slide.dart';
import 'package:calvi/design/theme.dart';

/// A swap inside a screen moves the way a route does.
///
/// The arriving page travels in opaque and the one it covers is kept underneath
/// for the length of the run. Fading the new page up from nothing is what made
/// every settings panel blink: with the old one already disposed, the first
/// frames of the run were the bare window showing through the new one.
void main() {
  Widget page(String text, int dir) => MaterialApp(
    theme: calviLightTheme,
    home: Scaffold(
      body: Slide(value: text, dir: dir, child: Text(text)),
    ),
  );

  testWidgets('нова сторінка їде непрозорою, стара лишається під нею', (tester) async {
    await tester.pumpWidget(page('перша', 1));
    await tester.pumpAndSettle();

    await tester.pumpWidget(page('друга', 1));
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.text('друга'), findsOneWidget);
    expect(find.text('перша'), findsOneWidget, reason: 'під новою сторінкою порожньо, буде спалах');

    // Nothing in the swap is half transparent: the page travels, it does not fade.
    final fades = tester
        .widgetList<Opacity>(find.descendant(of: find.byType(Slide), matching: find.byType(Opacity)))
        .where((o) => o.opacity < 1);
    expect(fades, isEmpty, reason: 'сторінка проявляється, а має просто їхати');

    // And the new page is the one on top, or the old one would cover it.
    final stack = tester.widget<Stack>(
      find.descendant(of: find.byType(Slide), matching: find.byType(Stack)).first,
    );
    expect(
      find
          .descendant(of: find.byWidget(stack.children.last), matching: find.text('друга'))
          .evaluate(),
      isNotEmpty,
      reason: 'стара сторінка лежить поверх нової',
    );
  });

  testWidgets('після переходу стара сторінка знята', (tester) async {
    await tester.pumpWidget(page('перша', 1));
    await tester.pumpAndSettle();
    await tester.pumpWidget(page('друга', 1));
    await tester.pumpAndSettle();

    expect(find.text('перша'), findsNothing, reason: 'стара сторінка лишилась у дереві');
    expect(find.text('друга'), findsOneWidget);
  });
}
