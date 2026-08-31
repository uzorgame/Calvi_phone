import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/icons.dart';
import 'package:calvi/design/shell.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/recipes/recipes_screen.dart';

/* Видалення рецепту: три крапки на сторінці страви лише питають, стирає
 * червона згода в аркуші, і після неї картка зникає зі списку. Тест ходить
 * демо-книгою: сервера тут немає, але вся дорога від крапок до списку та
 * сама, що в бойовому режимі. */
Widget _wrap() => AppScope(
  s: initialSettings(),
  set: (_) {},
  meds: const [],
  setMeds: (_) {},
  child: MaterialApp(
    localizationsDelegates: L.localizationsDelegates,
    supportedLocales: L.supportedLocales,
    locale: const Locale('uk'),
    theme: calviLightTheme,
    home: const RecipesScreen(),
  ),
);

void main() {
  testWidgets('три крапки питають, згода стирає, список худне', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.textContaining('Скумбрія'), findsOneWidget);

    await tester.scrollUntilVisible(find.textContaining('Скумбрія'), 120);
    await tester.tap(find.textContaining('Скумбрія'));
    await tester.pumpAndSettle();

    await tester.tap(find.byWidgetPredicate((w) => w is CalviIcon && w.name == 'dots'));
    await tester.pumpAndSettle();

    expect(find.text('Видалити рецепт?'), findsOneWidget, reason: 'аркуш не спитав');
    expect(
      find.textContaining('лишаться'),
      findsOneWidget,
      reason: 'аркуш не пояснив, що станеться із щоденником',
    );

    await tester.tap(find.text('Видалити'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Скумбрія'),
      findsNothing,
      reason: 'після згоди картка мусить зникнути зі списку',
    );
  });

  testWidgets('скасування лишає рецепт на місці', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.textContaining('Скумбрія'), 120);
    await tester.tap(find.textContaining('Скумбрія'));
    await tester.pumpAndSettle();

    await tester.tap(find.byWidgetPredicate((w) => w is CalviIcon && w.name == 'dots'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Скасувати'));
    await tester.pumpAndSettle();

    // Сторінка страви лишилась відкритою, рецепт живий.
    expect(find.text('На порцію'), findsOneWidget);

    await tester.tap(find.byType(CalviBack));
    await tester.pumpAndSettle();
    expect(find.textContaining('Скумбрія'), findsOneWidget);
  });
}
