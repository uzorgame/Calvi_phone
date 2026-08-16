import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/fixtures.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/data/measure.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/data/app_scope.dart';
import 'package:calvi/screens/analytics/analytics_screen.dart';
import 'package:calvi/screens/analytics/charts.dart';

void main() {
  testWidgets('стовпчики БЖВ мають висоту', (tester) async {
    final rows = [
      for (final r in weekRows)
        (
          label: r.label,
          protein: totalsFor(r.date).protein,
          fat: totalsFor(r.date).fat,
          carbs: totalsFor(r.date).carbs,
        ),
    ];
    expect(rows.where((r) => r.protein > 0).length, greaterThan(3), reason: 'дані є');

    await tester.pumpWidget(
      MaterialApp(
        theme: calviLightTheme,
        home: Scaffold(
          body: Center(child: MacroBars(rows: rows)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final bars = find.byType(FractionallySizedBox);
    expect(bars, findsWidgets);
    final heights = tester
        .widgetList<FractionallySizedBox>(bars)
        .map((w) => w.heightFactor)
        .toList();
    final sizes = <double>[];
    for (var i = 0; i < tester.widgetList(bars).length; i++) {
      sizes.add(tester.getSize(bars.at(i)).height);
    }
    expect(heights.any((h) => (h ?? 0) > 0.5), true, reason: 'частки: $heights');
    expect(sizes.any((h) => h > 40), true, reason: 'висоти: $sizes');
  });

  testWidgets('стовпчики видно і на самому екрані аналітики', (tester) async {
    tester.view.physicalSize = const Size(390, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      AppScope(
        s: initialSettings(),
        set: (_) {},
        meds: const [],
        setMeds: (_) {},
        child: MaterialApp(
          theme: calviLightTheme,
          home: AnalyticsScreen(measures: demoMeasures, onSettings: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final bars = tester
        .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
        .map((w) => w.heightFactor)
        .toList();
    expect(bars.any((h) => (h ?? 0) > 0.5), true, reason: 'частки на екрані: $bars');

    /* A childless ColoredBox takes the smallest size its constraints allow, so
       the bug that hid these bars was zero WIDTH with a correct height. */
    final painted = tester
        .widgetList<ColoredBox>(find.byType(ColoredBox))
        .where((_) => true)
        .toList();
    final widths = [
      for (var i = 0; i < painted.length; i++)
        tester.getSize(find.byType(ColoredBox).at(i)).width,
    ];
    expect(widths.where((w) => w > 4).length, greaterThan(6), reason: 'ширини: $widths');
  });
}
