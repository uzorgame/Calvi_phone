import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/today/slot_card.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// Назва картки дня тримається в один рядок на будь-якому телефоні.
///
/// На вузькому екрані «Вимірювання» ламалось посеред слова, а англійське
/// «Measurements» лишало на другому рядку саму літеру «s». Назва картки це її
/// імʼя, і зламане навпіл імʼя гірше за будь-який інший вихід: значок праворуч
/// поступається місцем першим, а далі обидва зменшуються, але лишаються цілими.
void main() {
  Future<void> open(
    WidgetTester tester, {
    required String title,
    required String sub,
    required String badge,
    required Locale locale,
    double width = 320,
  }) async {
    tester.view.physicalSize = Size(width, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: locale,
        theme: calviLightTheme,
        home: Scaffold(
          body: Padding(
            // Той самий жолоб, у якому картки стоять на екрані дня.
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SlotCard(
              icon: 'ruler',
              title: title,
              sub: sub,
              badge: badge,
              open: false,
              onToggle: () {},
              child: const SizedBox(height: 40),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  /// Скільки рядків намалював цей напис насправді.
  int lines(WidgetTester tester, String text) {
    final box = tester.renderObject<RenderParagraph>(find.text(text));
    return box.getBoxesForSelection(
      TextSelection(baseOffset: 0, extentOffset: text.length),
    ).map((b) => b.top.round()).toSet().length;
  }

  for (final (lang, title, sub, badge) in [
    ('uk', 'Вимірювання', 'останнє 2 дні тому', 'ще нічого'),
    ('en', 'Measurements', 'last one 2 days ago', 'nothing yet'),
  ]) {
    testWidgets('$lang: назва і значок лишаються в один рядок', (tester) async {
      await open(tester, title: title, sub: sub, badge: badge, locale: Locale(lang));

      expect(tester.takeException(), isNull);
      expect(lines(tester, title), 1, reason: 'назва картки переїхала на другий рядок');
      expect(lines(tester, badge), 1, reason: 'значок переїхав на другий рядок');
      expect(lines(tester, sub), 1, reason: 'підпис переїхав на другий рядок');
    });

    testWidgets('$lang: на звичайному телефоні нічого не стискається', (tester) async {
      /* Зменшення це запасний вихід, а не звичайна поведінка: на 375 пунктах усе
         має стояти власним розміром, інакше сусідні картки поїдуть різними. */
      await open(tester, title: title, sub: sub, badge: badge, locale: Locale(lang), width: 375);

      final shown = tester.renderObject<RenderParagraph>(find.text(title));
      expect(shown.text.style?.fontSize, 17, reason: 'назву зменшили там, де вона й так влазить');
    });
  }
}
