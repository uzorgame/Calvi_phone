import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/design/wheel.dart';
import 'package:calvi/screens/settings/panels_body.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// A flick of the age drum travels as far as it was pushed.
///
/// The drum lives under a panel that rebuilds on every detent it reports, and a
/// rebuilt drum lays out again. Flutter restarts a fling whenever the scroll
/// view's dimensions are applied, and each restart aimed one row further along,
/// so the same flick ran further in settings than anywhere else.
void main() {
  testWidgets('кидок барабана віку не тягне далі, ніж його штовхнули', (tester) async {
    tester.view.physicalSize = const Size(390, 1400);
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
            localizationsDelegates: L.localizationsDelegates,
            supportedLocales: L.supportedLocales,
            locale: const Locale('uk'),
            theme: calviLightTheme,
            scrollBehavior: const CalviScroll(),
            home: ProfilePanel(s: s, set: (patch) => setState(() => s = patch(s))),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    /* Барабан живе в аркуші, а не в сторінці: усередині сторінки він забирав би
       собі жест гортання. Відкриваємо аркуш і крутимо там. */
    await tester.tap(find.text('Вік'));
    await tester.pumpAndSettle();

    final was = s.age;
    final drum = tester.getCenter(find.byType(CalviWheel).first);

    /* Eight frames of twenty pixels: about twelve hundred pixels a second, which
       is a normal flick and thirty rows of runway at most. */
    final g = await tester.startGesture(drum);
    for (var i = 1; i <= 8; i++) {
      await g.moveBy(const Offset(0, -20), timeStamp: Duration(milliseconds: 16 * i));
    }
    await g.up();
    await tester.pumpAndSettle();

    /* Значення застосовується на «Готово», тому спершу закриваємо аркуш. */
    await tester.tap(find.text('Готово').last);
    await tester.pumpAndSettle();

    final moved = (s.age - was).abs();
    expect(moved, greaterThan(0), reason: 'барабан не зрушив узагалі');
    expect(
      moved,
      lessThan(14),
      reason: 'кидок відкрутив $moved років: фліг перезапускається і тягне далі',
    );
  });
}
