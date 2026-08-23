import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/settings/panel_allergy.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// An allergy is set where it is read.
///
/// Tapping an allergen opens a banner under that row, and nothing is written
/// until it is confirmed: opening a row to look at it must leave the settings
/// exactly as they were.
void main() {
  Widget wrap(SettingsState Function() read, void Function(SettingsState) write) {
    return StatefulBuilder(
      builder: (context, setState) => AppScope(
        s: read(),
        set: (patch) => setState(() => write(patch(read()))),
        meds: const [],
        setMeds: (_) {},
        child: MaterialApp(
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          locale: const Locale('uk'),
          theme: calviLightTheme,
          scrollBehavior: const CalviScroll(),
          home: AllergyPanel(s: read(), set: (patch) => setState(() => write(patch(read())))),
        ),
      ),
    );
  }

  testWidgets('банер відкривається під рядком і пише лише після підтвердження', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var s = initialSettings().copyWith(allergies: const []);
    await tester.pumpWidget(wrap(() => s, (v) => s = v));
    await tester.pumpAndSettle();

    expect(find.text('Підтвердити'), findsNothing, reason: 'банер відкритий до тапу');

    await tester.tap(find.text('Мигдаль'));
    await tester.pumpAndSettle();

    expect(find.text('Підтвердити'), findsOneWidget, reason: 'банер не відкрився');
    expect(s.allergies, isEmpty, reason: 'алергію записали, хоча її ще не підтвердили');

    // The banner opens under the row it is about, not above it or elsewhere.
    expect(
      tester.getTopLeft(find.text('Підтвердити')).dy,
      greaterThan(tester.getBottomLeft(find.text('Мигдаль')).dy),
      reason: 'банер стоїть не під своїм рядком',
    );

    await tester.tap(find.text('Важка'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Підтвердити'));
    await tester.pumpAndSettle();

    expect(s.allergies.length, 1);
    expect(s.allergies.single.severe, isTrue, reason: 'записали не ту тяжкість');
    expect(find.text('Підтвердити'), findsNothing, reason: 'банер лишився відкритим');
    expect(find.text('важка'), findsOneWidget, reason: 'рядок не показує, що він активний');
  });
}
