import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/settings/panels_body.dart';

/// Opening the goal must not move the goal.
///
/// The tape reports the value it settles on, and if it settles anywhere but the
/// value it was given, the panel decides a new target has been drafted: the
/// action turns into «Поставити нову ціль» and a note appears about replacing a
/// goal nobody touched.
void main() {
  testWidgets('відкрита ціль не створює чернетки', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var s = initialSettings();
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => AppScope(
          s: s,
          set: (patch) => setState(() => s = patch(s)),
          meds: const [],
          setMeds: (_) {},
          child: MaterialApp(
            theme: calviLightTheme,
            scrollBehavior: const CalviScroll(),
            home: GoalPanel(s: s, set: (patch) => setState(() => s = patch(s))),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Готово'), findsOneWidget, reason: 'панель вирішила, що ціль змінили');
    expect(find.textContaining('Поточна ціль'), findsNothing);
    expect(
      find.text('${s.targetKg.toStringAsFixed(1)} кг'),
      findsOneWidget,
      reason: 'стрічка стала не на цільовій вазі',
    );
  });
}
