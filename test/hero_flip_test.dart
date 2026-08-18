import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/fixtures.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/today/hero_card.dart';

/// The deck holds both of its sides.
///
/// The two faces share one box, and the weight side says more than the calorie
/// side does. Sized by the front alone, the back spilled out of the card and
/// what spills is clipped: on a phone the card read as gone.
void main() {
  testWidgets('обидві сторони колоди вміщаються в картку', (tester) async {
    tester.view.physicalSize = const Size(390, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      AppScope(
        // Long figures on purpose: three digits and a decimal is what a person
        // starting at over a hundred kilograms sees.
        s: initialSettings().copyWith(weightKg: 177.8, goalStartKg: 180, targetKg: 75),
        set: (_) {},
        meds: const [],
        setMeds: (_) {},
        child: MaterialApp(
          theme: calviLightTheme,
          // The phone can be set to a bigger font, and the card has to survive it.
          builder: (context, child) => MediaQuery.withNoTextScaling(
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.6)),
              child: child!,
            ),
          ),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HeroCard(
                  day: dayFor(0),
                  burned: dayFor(0).burned,
                  goal: goalOf(initialSettings()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // Turn the deck to the weight side and let it land.
    await tester.drag(find.byType(HeroCard), const Offset(0, -60));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    /* Height, not presence. The side that faded out used to leave the tree,
       and since it is what the stack measures, the card collapsed to nothing the
       moment the turn finished: the weight side was still there, stretched over
       zero pixels. */
    expect(
      tester.getRect(find.byType(HeroCard)).height,
      greaterThan(100),
      reason: 'картка склалася, коли повернулась на кілограми',
    );
    expect(find.textContaining('177.8'), findsOneWidget, reason: 'сторона ваги не показалась');
    expect(
      tester.takeException(),
      isNull,
      reason: 'сторона ваги не вміщається в картку і обрізається',
    );
  });
}
