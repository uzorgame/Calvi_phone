import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/design/wheel.dart';
import 'package:calvi/screens/settings/panels_body.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// Dragging a macro slider moves the macro, not the page.
///
/// The slider reads raw pointers so the handle answers the moment it is touched,
/// and raw pointers claim nothing in the gesture arena: the list behind it took
/// the same finger and scrolled the whole screen while the value was being set.
void main() {
  testWidgets('повзунок БЖВ не тягне сторінку за собою', (tester) async {
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
            home: NormPanel(s: s, set: (patch) => setState(() => s = patch(s))),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final list = tester.widget<Scrollable>(find.byType(Scrollable).first);
    final page = list.controller!;
    final scroll = page.offset;

    final slider = tester.getCenter(find.byType(CalviSlider).first);
    final was = s.protein;

    // A finger that wanders while it drags, which is what a finger does.
    final g = await tester.startGesture(slider);
    for (var i = 1; i <= 6; i++) {
      await g.moveBy(const Offset(6, -14), timeStamp: Duration(milliseconds: 16 * i));
    }
    await g.up();
    await tester.pumpAndSettle();

    expect(s.protein, isNot(was), reason: 'повзунок не зрушив');
    expect(
      page.offset,
      closeTo(scroll, 0.5),
      reason: 'сторінка поїхала на ${page.offset - scroll} під час тягання повзунка',
    );
  });
}
