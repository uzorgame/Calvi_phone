import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/slide.dart';
import 'package:calvi/design/theme.dart';

void main() {
  testWidgets('стара сторінка зникає одразу, нова в’їжджає', (tester) async {
    Widget page(String text, int dir) => MaterialApp(
      theme: calviLightTheme,
      home: Scaffold(body: Slide(value: text, dir: dir, child: Text(text))),
    );

    await tester.pumpWidget(page('перша', 1));
    await tester.pumpAndSettle();
    expect(find.text('перша'), findsOneWidget);

    await tester.pumpWidget(page('друга', 1));
    // Mid-transition: the whole point is that the old text is already gone.
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('перша'), findsNothing, reason: 'старий екран не має накладатись');
    expect(find.text('друга'), findsOneWidget);
  });
}
