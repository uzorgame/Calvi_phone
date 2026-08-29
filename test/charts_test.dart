import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/fixtures.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/data/day_stats.dart';
import 'package:calvi/data/measure.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/data/app_scope.dart';
import 'package:calvi/screens/analytics/analytics_screen.dart';
import 'package:calvi/screens/analytics/charts.dart';
import 'package:calvi/l10n/app_localizations.dart';

void main() {
  testWidgets('стовпчики БЖВ мають висоту', (tester) async {
    final rows = [
      for (final r in weekRows)
        (
          label: r.label,
          protein: totalsFor(r.date).protein,
          fat: totalsFor(r.date).fat,
          carbs: totalsFor(r.date).carbs,
        ),
    ];
    expect(rows.where((r) => r.protein > 0).length, greaterThan(3), reason: 'дані є');

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: Scaffold(
          body: Center(child: MacroBars(rows: rows, norm: 2380)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final bars = find.byType(FractionallySizedBox);
    expect(bars, findsWidgets);
    final heights = tester
        .widgetList<FractionallySizedBox>(bars)
        .map((w) => w.heightFactor)
        .toList();
    final sizes = <double>[];
    for (var i = 0; i < tester.widgetList(bars).length; i++) {
      sizes.add(tester.getSize(bars.at(i)).height);
    }
    expect(heights.any((h) => (h ?? 0) > 0.5), true, reason: 'частки: $heights');
    expect(sizes.any((h) => h > 40), true, reason: 'висоти: $sizes');
  });

  testWidgets('стовпчики видно і на самому екрані аналітики', (tester) async {
    /* Зі справжніми підсумками, а не з порожнім осередком. Екран більше не
       бере чисел із фікстур: на порожній базі він чесно каже, що записів немає,
       і жодного стовпчика там бути не повинно. Питання цього тесту інше, про
       ширину намальованого, і воно має ставитись там, де є що малювати. */
    tester.view.physicalSize = const Size(390, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      AppScope(
        s: initialSettings(),
        set: (_) {},
        meds: const [],
        setMeds: (_) {},
        stats: DayStats.demo(),
        child: MaterialApp(
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          locale: const Locale('uk'),
          theme: calviLightTheme,
          home: AnalyticsScreen(measures: demoMeasures, onSettings: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final bars = tester
        .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
        .map((w) => w.heightFactor)
        .toList();
    expect(bars.any((h) => (h ?? 0) > 0.5), true, reason: 'частки на екрані: $bars');

    /* A childless ColoredBox takes the smallest size its constraints allow, so
       the bug that hid these bars was zero WIDTH with a correct height. */
    final painted = tester
        .widgetList<ColoredBox>(find.byType(ColoredBox))
        .where((_) => true)
        .toList();
    final widths = [
      for (var i = 0; i < painted.length; i++) tester.getSize(find.byType(ColoredBox).at(i)).width,
    ];
    expect(widths.where((w) => w > 4).length, greaterThan(6), reason: 'ширини: $widths');
  });
  testWidgets('вода завжди синя, і недобраний день теж', (tester) async {
    /* Сірий стовпчик читався як «даних немає». День на півтора літра виглядав
       так само, як день, коли не пито взагалі: обидва сірі, різні лише
       висотою, і різницю не було видно без лінійки. */
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: Scaffold(
          body: HydrationBars(
            rows: const [(label: 'ПН', ml: 0), (label: 'ВТ', ml: 900), (label: 'СР', ml: 2400)],
            goalMl: 2200,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    final colours = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((w) => (w.decoration as BoxDecoration).color)
        .whereType<Color>()
        .toList();

    final water = calviLightTheme.extension<CalviTheme>()!.c.fats;
    final blue = colours.where((c) => c.r == water.r && c.g == water.g && c.b == water.b);

    expect(blue.length, greaterThanOrEqualTo(2), reason: 'недобраний день лишився сірим');
    expect(blue.any((c) => c.a == 1.0), true, reason: 'день, що перекрив норму, не виділений');
  });

  testWidgets('сухий тиждень не малює нічого, крім підписів', (tester) async {
    /* Сіра доріжка під стовпчиком тут була, і вона мала сенс, поки вода була
       ледь помітною. Поруч із синьою вона читалась як заповнений стовпчик,
       тобто як дані, яких немає. Порожньо має виглядати порожньо. */
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: Scaffold(
          body: HydrationBars(
            rows: const [(label: 'ПН', ml: 0), (label: 'ВТ', ml: 0)],
            goalMl: 2200,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('ПН'), findsOneWidget);
    expect(find.text('ВТ'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final water = calviLightTheme.extension<CalviTheme>()!.c;
    final painted = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((w) => (w.decoration as BoxDecoration).color)
        .whereType<Color>()
        .where((col) => col.a > 0.02)
        .toList();

    expect(
      painted.any((col) => col.r == water.track.r && col.g == water.track.g),
      false,
      reason: 'під стовпчиками лишився сірий фон',
    );
  });
  testWidgets('стовпчик води має ширину, а не тільки висоту', (tester) async {
    /* Той самий дефект, що колись ховав стовпчики БЖВ: віджет без вмісту бере
       найменший розмір, який дозволяють обмеження, і смуга виходила з
       правильною висотою і нульовою шириною. На екрані лишались самі доріжки,
       однакові й порожні, і день на тисячу триста мілілітрів виглядав так само,
       як день без жодної склянки. */
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: Scaffold(
          body: SizedBox(
            width: 350,
            child: HydrationBars(
              rows: const [(label: 'ПН', ml: 0), (label: 'ВТ', ml: 1300), (label: 'СР', ml: 2400)],
              goalMl: 2200,
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    final bars = tester
        .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
        .toList();
    expect(bars, isNotEmpty);

    final painted = <Size>[];
    for (var i = 0; i < bars.length; i++) {
      painted.add(tester.getSize(find.byType(FractionallySizedBox).at(i)));
    }

    expect(
      painted.any((s) => s.width > 20 && s.height > 20),
      true,
      reason: 'жодного видимого стовпчика: $painted',
    );
  });

  testWidgets('більше води означає контрастніший стовпчик', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: Scaffold(
          body: SizedBox(
            width: 350,
            child: HydrationBars(
              rows: const [(label: 'ПН', ml: 400), (label: 'ВТ', ml: 2200)],
              goalMl: 2200,
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    final water = calviLightTheme.extension<CalviTheme>()!.c.fats;
    final blues = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((w) => (w.decoration as BoxDecoration).color)
        .whereType<Color>()
        .where((col) => col.r == water.r && col.g == water.g && col.b == water.b)
        .toList();

    expect(blues, hasLength(2));
    expect(blues.first.a, lessThan(blues.last.a), reason: 'насиченість не росте з водою');
    expect(blues.last.a, closeTo(1.0, 0.01), reason: 'день у нормі не на повну силу');
  });
}
