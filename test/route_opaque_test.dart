import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/slide.dart';
import 'package:calvi/design/theme.dart';

/// Сторінка, що приїжджає, мусить бути непрозорою.
///
/// Попередня лишається змонтованою під нею на весь час переходу, і напівпрозора
/// нова пропускає її крізь себе: людина бачить два екрани один поверх одного.
/// Ловилось це руками і повернулось одразу, щойно тло Scaffold у темряві стало
/// прозорим заради вугільного ґрунту.
void main() {
  Future<void> push(WidgetTester tester, ThemeData theme) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        builder: (context, child) => CalviGround(child: child ?? const SizedBox()),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(
                  context,
                ).push(slideRoute(const Scaffold(body: Center(child: Text('друга'))))),
                child: const Text('перша'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('перша'));
    // Половина переходу: обидві сторінки в дереві, і саме тут ловиться просвіт.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 130));
  }

  for (final (name, theme) in [('світлій', calviLightTheme), ('темній', calviDarkTheme)]) {
    testWidgets('у $name темі сторінка, що приїжджає, має власне тло', (tester) async {
      await push(tester, theme);

      /* Обидві сторінки справді в дереві: без цього тест нічого не перевіряв
         би, бо переходу могло й не початись. */
      expect(find.text('перша'), findsOneWidget);
      expect(find.text('друга'), findsOneWidget);

      /* І та, що приїхала, малює під собою ґрунт. Саме він робить її
         непрозорою, хай би яким було тло Scaffold. */
      final arrived = find.byType(CalviGround).last;
      expect(
        find.descendant(of: arrived, matching: find.text('друга')),
        findsOneWidget,
        reason: 'нова сторінка без ґрунту: попередня просвічуватиме крізь неї',
      );

      /* І ґрунт справді непрозорий на всю висоту: прозорий ґрунт це той самий
         просвіт. Ґрунт градієнтний, тож перевіряються всі його тони. */
      final ground = CalviGround.toneAt(tester.element(arrived), 0);
      expect(ground.a, 1);
      expect(CalviGround.toneAt(tester.element(arrived), 1).a, 1);
    });
  }
}
