import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/meds.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/analytics/analytics_screen.dart';
import 'package:calvi/screens/meds/meds_screen.dart';
import 'package:calvi/screens/settings/settings_screen.dart';
import 'package:calvi/screens/start/start_screen.dart';

/// Решта екранів влазить у телефон, у обох темах.
///
/// Не влазить означає смугасту жовто-чорну стрічку поперек екрана, і побачить її
/// не розробник, а людина з найменшим телефоном або зі збільшеним системним
/// шрифтом. Таких людей більше, ніж здається: шрифт крутить кожен, кому за сорок.
///
/// Камери тут немає навмисно: її не чіпаємо.
void main() {
  Map<String, Widget> screens() => {
    'Налаштування': const SettingsScreen(),
    'Препарати': MedsScreen(
      meds: demoMeds,
      onToggle: (_, _) {},
      onSave: (_) {},
      onFinish: (_) {},
      onRevive: (_) {},
    ),
    'Аналітика': AnalyticsScreen(measures: const [], onSettings: () {}),
    'Старт': StartScreen(onFinish: (_) {}),
  };

  Future<void> open(
    WidgetTester tester,
    Widget screen,
    ThemeData theme, {
    required Size size,
    required double scale,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      AppScope(
        s: initialSettings(),
        set: (_) {},
        meds: demoMeds,
        setMeds: (_) {},
        real: false,
        setReal: (_) {},
        child: MaterialApp(
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          locale: const Locale('uk'),
          theme: theme,
          scrollBehavior: const CalviScroll(),
          builder: (context, child) => MediaQuery.withNoTextScaling(
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
              child: CalviGround(child: child ?? const SizedBox()),
            ),
          ),
          home: screen,
        ),
      ),
    );
    /* Кадрами, а не до зупинки: на екрані препаратів пульсує значок курсу, і
       чекати, поки він зупиниться, означає чекати вічно. Розкладка стає на
       місце з першого кадру, а решта потрібна лише щоб пожили анімації появи. */
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  for (final (theme, tone) in [(calviLightTheme, 'світлій'), (calviDarkTheme, 'темній')]) {
    for (final (name, size, scale) in [
      ('на звичайному телефоні', const Size(390, 844), 1.0),
      ('на найменшому телефоні', const Size(320, 568), 1.0),
      ('зі збільшеним шрифтом', const Size(390, 844), 1.3),
    ]) {
      testWidgets('екрани влазять $name у $tone темі', (tester) async {
        for (final screen in screens().entries) {
          await open(tester, screen.value, theme, size: size, scale: scale);
          expect(tester.takeException(), isNull, reason: 'екран «${screen.key}» не влазить');
        }
      });
    }
  }
}
