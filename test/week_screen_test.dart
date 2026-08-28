import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/day_stats.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/data/week.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/week/week_screen.dart';

/// Сторінка тижня на телефоні звичайного розміру.
Widget _wrap({double scale = 1}) => AppScope(
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
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: WeekScreen(
        summary: weekSummary(DayStats.demo(), initialSettings()),
        onSettings: () {},
      ),
    ),
  ),
);

void main() {
  testWidgets('сторінка тижня показує всі свої блоки', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    final l = await L.delegate.load(const Locale('uk'));

    // Розбір найпершим: числа нижче це матеріал, а розбір це відповідь.
    expect(find.text(l.wkNoraBtn), findsOneWidget, reason: 'кнопки розбору немає');
    expect(find.text(l.wkKcalHead), findsOneWidget);
    expect(find.text(l.wkMacroHead), findsOneWidget);
    expect(find.text(l.wkFactsHead), findsOneWidget);

    /* Числа ті самі, що на третій стороні картки дня: обидва читачі беруть одне
       зведення, і розійтись їм нема на чому. */
    final w = weekSummary(DayStats.demo(), initialSettings());
    expect(
      find.textContaining('${w.daysOnGoal}', findRichText: true),
      findsWidgets,
      reason: 'днів у нормі не показано',
    );

    expect(tester.takeException(), isNull, reason: 'сторінка не вміщається');
  });

  testWidgets('кнопка розбору проходить очікування і розгортається', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    final l = await L.delegate.load(const Locale('uk'));

    await tester.tap(find.text(l.wkNoraBtn));
    await tester.pump();

    // Кільце очікування всередині самої кнопки, а не десь на екрані.
    expect(find.text(l.wkNoraLoading), findsOneWidget, reason: 'очікування не показалось');
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2400));
    await tester.pumpAndSettle();

    expect(find.text(l.wkNoraBtn), findsNothing, reason: 'кнопка лишилась поверх розбору');
    expect(find.textContaining('Основа в тебе здорова'), findsOneWidget, reason: 'розбору немає');
    expect(find.text(l.wkNoraTalk), findsOneWidget, reason: 'входу в розмову немає');

    // Розмова відкривається тут же, а не окремим екраном.
    await tester.ensureVisible(find.text(l.wkNoraTalk));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.wkNoraTalk));
    await tester.pumpAndSettle();
    expect(find.textContaining('Питай про будь-що'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget, reason: 'нема куди писати');

    expect(tester.takeException(), isNull);
  });

  testWidgets('сторінка тижня влазить зі збільшеним шрифтом', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(scale: 1.3));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull, reason: 'зі збільшеним шрифтом щось обрізається');
  });
}
