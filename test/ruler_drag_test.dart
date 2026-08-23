import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/ruler.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/settings/panels_body.dart';
import 'package:calvi/screens/start/start_screen.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// A small push on the tape moves the weight a little.
///
/// On the weight panel a nudge sent the drum to the end of its range, while the
/// same tape at the first run behaved. The difference is the panel around it, so
/// the test drags the real panel rather than a bare tape.
void main() {
  testWidgets('невеликий рух стрічки міняє вагу трохи', (tester) async {
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
            localizationsDelegates: L.localizationsDelegates,
            supportedLocales: L.supportedLocales,
            locale: const Locale('uk'),
            theme: calviLightTheme,
            scrollBehavior: const CalviScroll(),
            home: WeightPanel(s: s, set: (patch) => setState(() => s = patch(s))),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final was = s.weightKg;
    final tape = tester.getCenter(find.byType(CalviRuler));

    // Thirty pixels of tape: under three ticks at eleven pixels apiece.
    await tester.dragFrom(tape, const Offset(-30, 0));
    await tester.pumpAndSettle();

    final moved = (s.weightKg - was).abs();
    expect(
      moved,
      lessThan(1.0),
      reason: 'тридцять пікселів зсунули вагу на $moved кг: було $was, стало ${s.weightKg}',
    );
    expect(moved, greaterThan(0), reason: 'стрічка взагалі не зрушила');
  });

  testWidgets('той самий кидок дає той самий шлях у налаштуваннях і на старті', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Future<double> fling(Widget home, double Function() read) async {
      await tester.pumpWidget(home);
      await tester.pumpAndSettle();
      final was = read();
      /* A real flick: the harness's own fling packs the whole gesture into so
         few frames that the velocity tracker reports nothing. */
      final g = await tester.startGesture(tester.getCenter(find.byType(CalviRuler)));
      for (var i = 1; i <= 8; i++) {
        await g.moveBy(const Offset(-20, 0), timeStamp: Duration(milliseconds: 16 * i));
      }
      await g.up();
      await tester.pumpAndSettle();
      return (read() - was).abs();
    }

    var s = initialSettings();
    final inPanel = await fling(
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
            home: WeightPanel(s: s, set: (patch) => setState(() => s = patch(s))),
          ),
        ),
      ),
      () => s.weightKg,
    );

    var start = 0.0;
    final inStart = await fling(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        scrollBehavior: const CalviScroll(),
        home: StartScreen(step: 3, onFinish: (d) {}),
      ),
      () {
        final tape = tester.widget<CalviRuler>(find.byType(CalviRuler));
        start = tape.value;
        return start;
      },
    );

    expect(
      inPanel,
      closeTo(inStart, 1.0),
      reason: 'той самий кидок: у налаштуваннях $inPanel кг, на старті $inStart кг',
    );

    /* And a flick is a flick, not a jump to the end of the tape: forty pixels
       at six hundred pixels a second is a few kilos, not a hundred. */
    expect(
      inPanel,
      lessThan(6),
      reason: 'кидок відвіз вагу на $inPanel кг: одна риска на кидок, а не ланцюг',
    );
    expect(s.weightKg, greaterThan(40.5), reason: 'вага сіла на мінімум шкали');
    expect(s.weightKg, lessThan(179.5), reason: 'вага сіла на максимум шкали');
  });
}
