import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/recipes/recipes_screen.dart';

/* Рецепт із алергеном людини мусить казати про це сам, ще зі списку.
 *
 * Демо-людина має алергію на фундук, а вівсянка демо-книги навмисно тримає
 * фундук у складниках: вітрина і цей тест ходять по одній дошці. Якщо матчер
 * зламається або мітку загублять при верстці, картка змовкне, і тест впаде. */
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
    home: const RecipesScreen(),
  ),
);

void main() {
  testWidgets('картка рецепта з алергеном називає алерген', (tester) async {
    await tester.pumpWidget(_wrap(const SizedBox()));
    await tester.pumpAndSettle();

    // Мітка стоїть на картці вівсянки: слово з реєстру, не зі складника.
    expect(find.text('Фундук'), findsOneWidget, reason: 'мітка алергену зникла з картки');

    // Сусідні картки без алергенів мовчать: одна вівсянка, одна мітка.
    expect(find.text('Молоко'), findsNothing, reason: 'мітки не мають вигадуватись');
  });

  testWidgets('сторінка рецепта попереджає і підсвічує складник', (tester) async {
    await tester.pumpWidget(_wrap(const SizedBox()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.textContaining('Вівсянка'), 120);
    await tester.tap(find.textContaining('Вівсянка'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('а це у твоїх алергіях'),
      findsOneWidget,
      reason: 'подушка попередження не стала над числами',
    );
    // «Фундук» двічі: мітка-складник у продуктах і слово в подушці окремо не
    // рахуються, досить того, що він десь підсвічений поза подушкою.
    expect(find.text('Фундук'), findsWidgets, reason: 'складник не підсвічено');
  });
}
