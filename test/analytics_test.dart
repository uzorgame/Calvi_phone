import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/fixtures.dart';
import 'package:calvi/data/measure.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/analytics/analytics_screen.dart';
import 'package:calvi/l10n/app_localizations.dart';

Widget _wrap(Widget child) => AppScope(
  s: initialSettings(),
  set: (_) {},
  meds: const [],
  setMeds: (_) {},
  child: MaterialApp(
    localizationsDelegates: L.localizationsDelegates,
    supportedLocales: L.supportedLocales,
    locale: const Locale('uk'),
    theme: calviLightTheme,
    home: child,
  ),
);

void main() {
  test('вікно ділиться на сім стовпчиків, останній закінчується сьогодні', () {
    final week = bucketDays(7);
    expect(week.length, 7);
    expect(week.every((b) => b.dates.length == 1), true);
    expect(week.last.dates.single, 0, reason: 'останній стовпчик це сьогодні');

    final month = bucketDays(30);
    expect(month.length, 7);
    expect(month.last.dates.last, 0);
    // Five days a column covers thirty five, which is the price of seven equal
    // columns; unequal columns would read as unequal amounts.
    expect(month.first.dates.length, 5);
  });

  testWidgets('зміна періоду перераховує числа, а не тільки підпис', (tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(AnalyticsScreen(measures: demoMeasures, onSettings: () {})));
    await tester.pumpAndSettle();

    // The week holds every logged day, so a longer window cannot hold more.
    final weekTotal = _figure(tester, 'за період, ккал');

    await tester.tap(find.text('Рік'));
    await tester.pumpAndSettle();

    final yearTotal = _figure(tester, 'за період, ккал');
    expect(yearTotal, isNot(''));
    expect(
      _figure(tester, 'днів у нормі'),
      isNot(''),
      reason: 'гідратація рахується за тим самим вікном',
    );
    expect(weekTotal, isNotEmpty);
  });
}

/// The big number standing above [cap].
String _figure(WidgetTester tester, String cap) {
  final column = find.ancestor(of: find.text(cap), matching: find.byType(Column)).first;
  final texts = tester.widgetList<Text>(find.descendant(of: column, matching: find.byType(Text)));
  for (final t in texts) {
    final s = t.data ?? t.textSpan?.toPlainText() ?? '';
    if (s != cap && s.trim().isNotEmpty) return s;
  }
  return '';
}
