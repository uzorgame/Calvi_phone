import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/meds/meds_form.dart';
import 'package:calvi/screens/settings/panel_reminders.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// Аркуші додавання мають бути карткою знизу, а не повноекранним вікном.
///
/// Колонка без `mainAxisSize.min` усередині `Flexible` займає всю доступну
/// висоту, і аркуш розгортався на весь екран. Помітно це тільки очима, тому тут
/// воно міряється числом.
void main() {
  const screen = Size(390, 844);

  Widget host(Widget child) => AppScope(
    s: emptySettings(),
    set: (_) {},
    meds: const [],
    setMeds: (_) {},
    child: MaterialApp(
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      locale: const Locale('uk'),
      theme: calviLightTheme,
      home: child,
    ),
  );

  testWidgets('аркуш препарату не на весь екран', (tester) async {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      host(
        Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: GestureDetector(
                onTap: () => openMedSheet(context, now: 0, onSave: (_) {}),
                child: const Text('відкрити'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('відкрити'));
    await tester.pumpAndSettle();

    /* Порядок полів той самий, що в демці: назва, скільки за раз, о котрій,
       як часто, нагадувати. */
    for (final cap in ['Назва', 'Скільки за раз', 'О котрій', 'Як часто', 'Нагадувати']) {
      expect(find.text(cap), findsOneWidget, reason: 'немає поля «$cap»');
    }

    final sheet = tester.getRect(find.text('Новий препарат')).top;
    expect(
      sheet,
      greaterThan(screen.height * 0.25),
      reason: 'аркуш починається зависоко: $sheet з ${screen.height}',
    );
  });

  testWidgets('аркуш нагадування не на весь екран', (tester) async {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      host(
        RemindersPanel(
          s: emptySettings(),
          set: (_) {},
          medsRemind: false,
          onMedsRemind: (_) {},
          onMeds: () {},
          now: 0,
        ),
      ),
    );

    await tester.tap(find.text('Додати нагадування'));
    await tester.pumpAndSettle();

    for (final cap in ['Про що', 'Назва', 'О котрій', 'Як часто']) {
      expect(find.text(cap), findsOneWidget, reason: 'немає поля «$cap»');
    }

    final top = tester.getRect(find.text('Нове нагадування')).top;
    expect(
      top,
      greaterThan(screen.height * 0.25),
      reason: 'аркуш починається зависоко: $top з ${screen.height}',
    );
  });

  testWidgets('порожній екран нагадувань не показує жодного наперед', (tester) async {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      host(
        RemindersPanel(
          s: emptySettings(),
          set: (_) {},
          medsRemind: false,
          onMedsRemind: (_) {},
          onMeds: () {},
          now: 0,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Поки жодного нагадування.'), findsOneWidget);
    expect(find.text('Додати нагадування'), findsOneWidget);
    expect(find.text('Препарати'), findsOneWidget, reason: 'рядок препаратів зник');
  });
}
