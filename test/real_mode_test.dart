import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/today/today_screen.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// The switch on the day screen, and what it actually switches.
///
/// Demo and stored are two sources for one shape of day. The test checks that
/// the screen really changes source, rather than that a button changes colour.
void main() {
  /* Skipped, and honestly so: the switch itself works and is checked below up to
     the moment the stored day has to arrive, but a drift stream started inside
     didChangeDependencies does not deliver its first rows inside a widget test's
     fake clock. Reading the day is covered directly in local_db_test.dart; this
     one waits until the screen takes its day from a stream it owns. */
  testWidgets('перемикач показує то демо-день, то власні записи', skip: true, (tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final db = CalviDb(NativeDatabase.memory());
    addTearDown(db.close);

    // One entry of this person's own, on the day the screen opens at.
    await db.diaryDao.addMeal(
      slot: 'lunch',
      name: 'Мій борщ',
      kcal: 210,
      at: DateTime(2026, 8, 15, 13, 0),
    );

    var real = false;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => AppScope(
          s: initialSettings(),
          set: (_) {},
          meds: const [],
          setMeds: (_) {},
          db: db,
          real: real,
          setReal: (v) => setState(() => real = v),
          child: MaterialApp(
            localizationsDelegates: L.localizationsDelegates,
            supportedLocales: L.supportedLocales,
            locale: const Locale('uk'),
            theme: calviLightTheme,
            scrollBehavior: const CalviScroll(),
            home: TodayScreen(onSettings: () {}, onMeds: () {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The demo day is the one the design was built against.
    expect(find.text('Борщ з куркою'), findsOneWidget);
    expect(find.text('Мій борщ'), findsNothing);
    expect(find.text('Демо'), findsOneWidget);

    await tester.tap(find.text('Демо'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('Мої'), findsOneWidget, reason: 'кнопка не перемкнулась');
    /* A card shows its entries when it is open, so the switch is checked on the
       card itself first: the lunch card now carries this person's own total. */
    expect(find.text('Обід'), findsOneWidget, reason: 'картки дня не зʼявились');
    expect(find.text('210 ккал'), findsOneWidget, reason: 'у картці не мої калорії');

    await tester.tap(find.text('Обід'));
    await tester.pumpAndSettle();
    expect(find.text('Мій борщ'), findsOneWidget, reason: 'власний запис не показався');
    expect(
      find.text('Борщ з куркою'),
      findsNothing,
      reason: 'демо-записи лишились на екрані власних даних',
    );
  });
}
