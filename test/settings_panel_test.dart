import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/shell.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/settings/settings_screen.dart';

/// A panel of settings is a swap inside settings, not a screen on top of it.
///
/// Pushed as a route, the panel arrived over a list that was still there and
/// sliding its own way, and the entrance looked nothing like the one that
/// carries settings or analytics in.
void main() {
  Widget wrap() {
    var s = initialSettings();
    return StatefulBuilder(
      builder: (context, setState) => AppScope(
        s: s,
        set: (patch) => setState(() => s = patch(s)),
        meds: const [],
        setMeds: (_) {},
        child: MaterialApp(
          theme: calviLightTheme,
          scrollBehavior: const CalviScroll(),
          home: const SettingsScreen(),
        ),
      ),
    );
  }

  testWidgets('рядок відкриває панель усередині налаштувань', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Профіль'));
    await tester.pumpAndSettle();

    expect(find.text('Стать'), findsOneWidget, reason: 'панель профілю не відкрилась');
    expect(
      find.text('Налаштування'),
      findsNothing,
      reason: 'список лишився під панеллю, тобто панель приїхала окремим екраном',
    );
  });

  testWidgets('панель закривається назад у список', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Вага'));
    await tester.pumpAndSettle();
    expect(find.text('Налаштування'), findsNothing);

    await tester.tap(find.byType(CalviBack).last);
    await tester.pumpAndSettle();

    expect(find.text('Налаштування'), findsOneWidget, reason: 'назад не повернуло список');
    expect(find.text('Профіль'), findsOneWidget);
  });
}
