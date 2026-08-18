import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/day.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/today/week_strip.dart';

/// A tap on a date answers on that date.
///
/// The strip used to change colours somewhere in a row of identical circles and
/// nothing else moved, so a tap read as an effect on the whole run rather than
/// on the day under the finger.
void main() {
  testWidgets('обрана дата стоїть вище за решту, натиснута сідає', (tester) async {
    tester.view.physicalSize = const Size(390, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: calviLightTheme,
        home: Scaffold(
          body: WeekStrip(date: todayDate, onPick: (_) {}),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    /* The target scale rather than the painted size: the strip also bends its
       days by their distance from the front edge, and that would be measured
       here as well. */
    double scaleOf(int date) => tester
        .widget<AnimatedScale>(
          find.ancestor(
            of: find.text('${dayInfo(date).day}'),
            matching: find.byType(AnimatedScale),
          ),
        )
        .scale;

    expect(scaleOf(todayDate), closeTo(1.06, 0.001), reason: 'обрана стоїть трохи вище');
    expect(scaleOf(todayDate - 1), closeTo(1, 0.001), reason: 'решта стоїть рівно');

    // Under the finger it gives way, and only it.
    final press = await tester.startGesture(
      // Саме сьогоднішня, хай яке сьогодні число: у тесті про натискання дата
      // не має значення, і зашита сюди вона тільки ламала його раз на добу.
      tester.getCenter(find.text('${dayInfo(todayDate).day}')),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(scaleOf(todayDate), closeTo(0.9, 0.001), reason: 'натиснута сідає');
    expect(scaleOf(todayDate - 1), closeTo(1, 0.001), reason: 'сусідів це не стосується');

    await press.up();
    await tester.pump(const Duration(milliseconds: 200));
    expect(scaleOf(todayDate), closeTo(1.06, 0.001), reason: 'після відпускання повертається');
  });
}
