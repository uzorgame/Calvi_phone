import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/settings/panels_account.dart';

/// Редизайн на малому телефоні і з великим системним шрифтом.
///
/// Тіні й відступи, додані редизайном, коштують місця, а найтісніші місця це
/// два плани підписки поруч і три гарантії приватності: у них по кілька рядків
/// у вузькій колонці. Перевірка саме на переповнення, а не на вигляд: смугастий
/// жовто-чорний бар це те, що людина побачить замість екрана.
void main() {
  Future<void> open(WidgetTester tester, Widget screen, {double scale = 1}) async {
    // Найменший телефон, який ще продають, і збільшений шрифт системи.
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        builder: (context, child) => MediaQuery.withNoTextScaling(
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
        ),
        home: screen,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('картки планів не переповнюються на вузькому екрані', (tester) async {
    await open(tester, const PlanPanel());
    expect(tester.takeException(), isNull);
  });

  testWidgets('картки планів витримують збільшений шрифт', (tester) async {
    await open(tester, const PlanPanel(), scale: 1.4);
    expect(tester.takeException(), isNull);
  });

  testWidgets('гарантії приватності витримують збільшений шрифт', (tester) async {
    await open(tester, PrivacyPanel(s: initialSettings(), set: (_) {}), scale: 1.4);
    expect(tester.takeException(), isNull);
  });
  testWidgets('тема і мова витримують збільшений шрифт', (tester) async {
    await open(tester, ThemePanel(s: initialSettings(), set: (_) {}), scale: 1.4);
    expect(tester.takeException(), isNull);

    await open(tester, LangPanel(s: initialSettings(), set: (_) {}), scale: 1.4);
    expect(tester.takeException(), isNull);
  });

  testWidgets('видалення акаунта витримує збільшений шрифт', (tester) async {
    await open(tester, const DeletePanel(), scale: 1.4);
    expect(tester.takeException(), isNull);
  });
}
