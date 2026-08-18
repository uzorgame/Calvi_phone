import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/ruler.dart';
import 'package:calvi/design/theme.dart';

/// The drum opens on the value it was given.
///
/// It is a scroll view underneath, and a scroll view that attaches before it
/// knows how wide its content is clamps whatever offset it was handed. That put
/// the weight drum forty kilograms away from the reading it was showing.
void main() {
  testWidgets('барабан відкривається на своєму значенні', (tester) async {
    tester.view.physicalSize = const Size(390, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: calviLightTheme,
        home: Scaffold(
          body: ListView(
            children: [
              CalviRuler(value: 78.6, min: 40, max: 180, suffix: 'кг', onChange: (_) {}),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.textContaining('78.6'),
      findsOneWidget,
      reason:
          'барабан з'
          'їхав зі своєї ваги',
    );
  });

  testWidgets('барабан з цілими кроками теж', (tester) async {
    tester.view.physicalSize = const Size(390, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: calviLightTheme,
        home: Scaffold(
          body: CalviRuler(
            value: 178,
            min: 120,
            max: 220,
            step: 1,
            suffix: 'см',
            onChange: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('178'), findsOneWidget, reason: 'зріст не на своєму місці');
  });
}
