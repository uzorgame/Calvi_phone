import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/fixtures.dart';
import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/data/day_stats.dart';
import 'package:calvi/data/week.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/today/hero_card.dart';
import 'package:calvi/l10n/app_localizations.dart';

/* The weight side reads the person's own figures, so the card needs the scope
   the app puts above every screen. */
Widget _wrap(Widget child) => AppScope(
  s: initialSettings(),
  set: (_) {},
  meds: const [],
  setMeds: (_) {},
  child: MaterialApp(
    localizationsDelegates: L.localizationsDelegates,
    supportedLocales: L.supportedLocales,
    locale: const Locale('uk'),
    theme: calviLightTheme,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('картка стоїть на боці калорій і має висоту', (tester) async {
    await tester.pumpWidget(
      _wrap(
        HeroCard(
          day: dayFor(0),
          burned: dayFor(0).burned,
          goal: goalOf(initialSettings()),
          week: _week,
          onWeek: () {},
        ),
      ),
    );
    await tester.pump();
    /* Великим числом стоїть зараховане, залишок рядком під ним.
     *
     * Людина відкриває застосунок, щоб побачити, скільки вона вже зʼїла, і саме
     * це шукає очима першим. Залишок це висновок, і він буває відʼємним:
     * тримати найбільшою цифрою на екрані те, що змінює знак, означало б, що
     * ввечері вона означає не те, що вранці.
     *
     * 314 зарахованих і 1966 лишку: 624 зʼїдених мінус 310 спалених на пробіжці,
     * і 2280 норми з налаштувань мінус це нетто. Норма стоїть на місці, спалене
     * знімається зі зʼїденого. Норма рахується з ваги на старті цілі (81 кг у
     * демо-людини), а не з живої: зважування її не рухають. */
    expect(find.textContaining('314', findRichText: true), findsWidgets, reason: 'нетто');
    expect(
      find.textContaining('лишилось', findRichText: true),
      findsWidgets,
      reason: 'залишок має стояти рядком під числом',
    );
    expect(
      find.textContaining('1 966', findRichText: true),
      findsWidgets,
      reason: 'розряди відділяються нерозривним пробілом',
    );

    final texts = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList();
    expect(texts, contains('днів'));

    // A card that collapses to nothing is the failure this catches.
    expect(tester.getSize(find.byType(HeroCard)).height, greaterThan(100));
  });

  testWidgets('змах угору перевертає картку на вагу', (tester) async {
    await tester.pumpWidget(
      _wrap(
        HeroCard(
          day: dayFor(0),
          burned: dayFor(0).burned,
          goal: goalOf(initialSettings()),
          week: _week,
          onWeek: () {},
        ),
      ),
    );
    await tester.pump();

    await tester.drag(find.byType(HeroCard), const Offset(0, -60));
    await tester.pumpAndSettle();

    final texts = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList();
    expect(texts, contains('ціль, кг'), reason: 'бік ваги не вийшов уперед');

    /* The calorie side is faded out, not taken out. It is the side the stack
       measures itself by, and a card whose front side leaves the tree collapses
       to nothing: that was the card disappearing the moment it turned. */
    expect(texts, contains('днів'), reason: 'бік калорій має лишитись у дереві');
    final faded = tester
        .widgetList<Opacity>(find.ancestor(of: find.text('днів'), matching: find.byType(Opacity)))
        .map((o) => o.opacity);
    expect(faded, contains(closeTo(0, 0.01)), reason: 'бік калорій не згас');
  });
}

/// Показовий тиждень для картки: сторона тижня читає готове зведення.
final _week = weekSummary(DayStats.demo(), initialSettings());
