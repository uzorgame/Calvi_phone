import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/design/tokens.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/today/today_screen.dart';

/// Перемикання теми на живому екрані.
///
/// Тема не перекидається, вона пливе: MaterialApp розводить кольори за чверть
/// секунди. Усе, що зроблене не на кольорах, а на `brightness`, стрибає
/// посередині цього шляху, коли решта екрана ще напівсвітла. Тому міряється
/// кожен кадр переходу, а не два його кінці.
void main() {
  testWidgets('день пливе зі світлої теми в темну, кадр за кадром', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var dark = false;
    late StateSetter set;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          set = setState;
          return AppScope(
            s: initialSettings(),
            set: (_) {},
            meds: const [],
            setMeds: (_) {},
            real: false,
            setReal: (_) {},
            child: MaterialApp(
              localizationsDelegates: L.localizationsDelegates,
              supportedLocales: L.supportedLocales,
              locale: const Locale('uk'),
              theme: calviLightTheme,
              darkTheme: calviDarkTheme,
              themeMode: dark ? ThemeMode.dark : ThemeMode.light,
              scrollBehavior: const CalviScroll(),
              home: TodayScreen(onSettings: () {}, onMeds: () {}),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    /// Ґрунт під сторінкою просто зараз.
    Color ground() =>
        Theme.of(tester.element(find.byType(Scaffold).first)).extension<CalviTheme>()!.c.bg;

    set(() => dark = true);

    final tones = <Color>[];
    for (var frame = 0; frame < 20; frame++) {
      await tester.pump(const Duration(milliseconds: 20));
      expect(tester.takeException(), isNull, reason: 'кадр $frame переходу впав');
      tones.add(ground());
    }
    await tester.pumpAndSettle();

    expect(tones.first, isNot(calviDark.bg), reason: 'тема перекинулась одразу, без переходу');
    expect(ground(), calviDark.bg, reason: 'перехід не доїхав до темної');

    /* Проміжні тони справді проміжні: жоден не збігається ні зі світлим, ні з
       темним кінцем. Один такий кадр посередині означав би стрибок. */
    final between = tones.where((x) => x != calviLight.bg && x != calviDark.bg).length;
    expect(between, greaterThan(4), reason: 'тема стрибає, а не пливе: проміжних кадрів $between');
  });

  testWidgets('день пливе назад у світлу так само', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var dark = true;
    late StateSetter set;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          set = setState;
          return AppScope(
            s: initialSettings(),
            set: (_) {},
            meds: const [],
            setMeds: (_) {},
            real: false,
            setReal: (_) {},
            child: MaterialApp(
              localizationsDelegates: L.localizationsDelegates,
              supportedLocales: L.supportedLocales,
              locale: const Locale('uk'),
              theme: calviLightTheme,
              darkTheme: calviDarkTheme,
              themeMode: dark ? ThemeMode.dark : ThemeMode.light,
              scrollBehavior: const CalviScroll(),
              home: TodayScreen(onSettings: () {}, onMeds: () {}),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    set(() => dark = false);
    for (var frame = 0; frame < 20; frame++) {
      await tester.pump(const Duration(milliseconds: 20));
      expect(tester.takeException(), isNull, reason: 'кадр $frame зворотного переходу впав');
    }
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(Scaffold).first)).extension<CalviTheme>()!.c.bg,
      calviLight.bg,
    );
  });
}
