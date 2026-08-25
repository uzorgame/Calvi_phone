import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/settings.dart';
import 'package:calvi/design/shell.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/settings/panel_about.dart';
import 'package:calvi/screens/settings/panels_account.dart';

/// The main button holds the bottom on a short page too.
///
/// It used to follow the content when the screen had room, and on tall phones
/// every short settings page put it mid-screen. That also cut the theme in
/// half: the veil under the button dissolves into the flat page colour, and
/// mid-screen the ground is not flat, so a flat band lay straight across the
/// coal gradient and across the new grounds' clouds. The fix rests on one
/// rule: the veil lands only in the bottom zone, where every ground is flat.
void main() {
  Future<void> open(WidgetTester tester, Widget page, ThemeData theme) async {
    // A tall phone on purpose: short pages only float their button when there
    // is plenty of room, which is exactly where the bug lived.
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: theme,
        home: CalviGround(child: page),
      ),
    );
    await tester.pumpAndSettle();
  }

  final shorts = <String, Widget Function()>{
    'Мова': () => LangPanel(s: initialSettings(), set: (_) {}, onBack: () {}),
    'Про застосунок': () => const AboutPanel(),
  };

  for (final (themeName, theme) in [
    ('темній', calviDarkTheme),
    ('акварельній', calviAquaTheme),
    ('світанковій', calviDawnTheme),
  ]) {
    testWidgets('у $themeName темі кнопка коротких сторінок стоїть унизу', (tester) async {
      for (final page in shorts.entries) {
        await open(tester, page.value(), theme);

        final button = find.byType(CalviButton).last;
        final bottom = tester.getRect(button).bottom;

        /* Не «нижче середини», а по-справжньому внизу: кнопка плюс її нижній
           відступ мають упиратись у край екрана. Шість пікселів це відступ
           підвалу, безпечної зони в тесті немає. */
        expect(
          bottom,
          closeTo(900 - 6, 1),
          reason:
              '${page.key}: кнопка спливла з низу, і її підкладка ріже тему '
              'там, де ґрунт не рівний',
        );
      }
    });
  }
}
