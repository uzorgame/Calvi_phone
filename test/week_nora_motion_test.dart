import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/day_stats.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/data/week.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/week/week_screen.dart';

/// Розбір від Нори росте на місці кнопки і штовхає сторінку вниз.
///
/// Перевіряється сам рух, а не те, що текст урешті зʼявився. Кнопка, яка
/// підміняється карткою між двома кадрами, читається як збій верстки: усе, що
/// під нею, стрибає на висоту цілого абзацу, і людина не встигає помітити, що
/// саме змінилось.
void main() {
  Widget wrap() => AppScope(
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
      home: WeekScreen(summary: weekSummary(DayStats.demo(), initialSettings()), onSettings: () {}),
    ),
  );

  testWidgets('розбір розгортається поступово, а не підміняє кнопку', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    final l = await L.delegate.load(const Locale('uk'));
    final block = find.byType(AnimatedSize);
    final was = tester.getSize(block.first).height;

    await tester.tap(find.text(l.wkNoraBtn));
    await tester.pump();

    // Очікування живе всередині кнопки, і кнопка не міняє розміру під ним.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.getSize(block.first).height, was, reason: 'кнопка стрибнула під час очікування');

    // Пауза, за яку в застосунку відповідає модель.
    await tester.pump(const Duration(milliseconds: 2400));
    await tester.pump();

    /* Посеред розгортання: вже вище за кнопку і ще нижче за повну картку. */
    await tester.pump(const Duration(milliseconds: 200));
    final mid = tester.getSize(block.first).height;
    expect(mid, greaterThan(was), reason: 'розбір не почав рости');

    await tester.pumpAndSettle();
    final full = tester.getSize(block.first).height;

    expect(full, greaterThan(mid), reason: 'висота стрибнула до кінця одразу');
    expect(find.text(l.wkNoraBtn), findsNothing, reason: 'кнопка лишилась поверх розбору');
    expect(find.text(l.wkNoraTalk), findsOneWidget);
  });
}
