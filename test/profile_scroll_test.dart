import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/settings/panels_body.dart';

/// Профіль має гортатися пальцем звідусіль.
///
/// Усередині нього два барабани, а барабан це теж прокрутка. Палець, який
/// почав рух на барабані, крутить барабан, і сторінка стоїть на місці: людина
/// тягне вгору, екран сіпається і не піднімається.
void main() {
  Future<double> dragUpFrom(WidgetTester tester, double y) async {
    tester.view.physicalSize = const Size(390, 844);
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

    final list = tester.widget<ListView>(find.byType(ListView));
    final before = list.controller!.offset;

    await tester.dragFrom(Offset(195, y), const Offset(0, -260));
    await tester.pumpAndSettle();

    return list.controller!.offset - before;
  }

  testWidgets('сторінка гортається, коли палець на порожньому місці', (tester) async {
    // Під заголовком, де немає жодного барабана: контрольний вимір.
    expect(await dragUpFrom(tester, 220), greaterThan(100));
  });

  /* Той самий рух, але палець починає на барабані. Саме сюди він і потрапляє,
     коли людина тягне знизу екрана: після картки акаунта барабани з'їхали вниз,
     на ту саму висоту, з якої зручно починати жест. */
  testWidgets('сторінка гортається там, де раніше стояв барабан', (tester) async {
    expect(
      await dragUpFrom(tester, 700),
      greaterThan(100),
      reason: 'усередину сторінки повернулась друга прокрутка і забрала жест собі',
    );
  });

  /* І найголовніше: те саме знизу вгору, коли сторінка вже догорнута донизу.
     Саме цей рух і не працює на телефоні. */
  testWidgets('знизу вгору сторінка теж піднімається', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
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

    final list = tester.widget<ListView>(find.byType(ListView));
    final c = list.controller!;

    c.jumpTo(c.position.maxScrollExtent);
    await tester.pumpAndSettle();
    final atBottom = c.offset;

    // Палець посередині екрана, рух донизу: сторінка має піти вгору.
    await tester.dragFrom(const Offset(195, 500), const Offset(0, 260));
    await tester.pumpAndSettle();

    expect(atBottom - c.offset, greaterThan(100), reason: 'знизу вгору сторінка не піднімається');
  });
}
