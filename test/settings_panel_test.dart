import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/shell.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/settings/settings_screen.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// A panel of settings is a swap inside settings, not a screen on top of it.
///
/// Pushed as a route, the panel arrived over a list that was still there and
/// sliding its own way, and the entrance looked nothing like the one that
/// carries settings or analytics in.
void main() {
  Widget wrap() {
    var s = initialSettings();
    return StatefulBuilder(
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
          home: const SettingsScreen(),
        ),
      ),
    );
  }

  testWidgets('рядок відкриває панель усередині налаштувань', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Профіль'));
    await tester.pumpAndSettle();

    expect(find.text('Стать'), findsOneWidget, reason: 'панель профілю не відкрилась');
    expect(
      find.text('Налаштування'),
      findsNothing,
      reason: 'список лишився під панеллю, тобто панель приїхала окремим екраном',
    );
  });

  testWidgets('панель закривається назад у список', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ціль'));
    await tester.pumpAndSettle();
    expect(find.text('Налаштування'), findsNothing);

    await tester.tap(find.byType(CalviBack).last);
    await tester.pumpAndSettle();

    expect(find.text('Налаштування'), findsOneWidget, reason: 'назад не повернуло список');
    expect(find.text('Профіль'), findsOneWidget);
  });

  /* Документи стоять у налаштуваннях, а не всередині «Про застосунок».
   *
   * І поруч із ними не має бути другого слова «Приватність»: рядок із
   * перемикачами статистики називається інакше саме тому, що два однакові
   * написи на одному екрані означають, що людина відкриє не той. */
  testWidgets('документи стоять окремою групою', (tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Умови користування'), findsOneWidget);
    expect(find.text('Політика приватності'), findsOneWidget);
    expect(find.text('Про застосунок'), findsOneWidget);
    expect(find.text('Дані і аналітика'), findsOneWidget);
    expect(find.text('Приватність'), findsNothing, reason: 'два однакові написи на одному екрані');
  });

  testWidgets('умови відкриваються повним текстом усередині налаштувань', (tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Умови користування'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Оновлено'), findsOneWidget, reason: 'документ не відкрився');
    /* Медичне застереження, а не випадковий заголовок. Тут стояли «Токени»,
       і перейменування розділу зняло перевірку разом із ним. */
    expect(
      find.text('Це не медичний застосунок'),
      findsOneWidget,
      reason: 'у документі немає медичного застереження',
    );
  });
}
