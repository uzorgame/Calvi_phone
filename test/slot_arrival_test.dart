import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/today/slot_card.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// Картка перекусу виростає в список, а не зʼявляється між кадрами.
///
/// Без цього все, що під нею, стрибає вниз на висоту цілої картки, і стрибок
/// читається як збій верстки, а не як «зʼявилось нове».
void main() {
  Widget wrap({required bool play}) => MaterialApp(
    localizationsDelegates: L.localizationsDelegates,
    supportedLocales: L.supportedLocales,
    locale: const Locale('uk'),
    theme: calviLightTheme,
    home: Scaffold(
      body: Arriving(
        play: play,
        child: const SizedBox(height: 120, width: 300, child: Text('Перекус')),
      ),
    ),
  );

  testWidgets('нова картка починає з нульової висоти і доростає', (tester) async {
    await tester.pumpWidget(wrap(play: true));
    await tester.pump();

    final start = tester.getSize(find.byType(Arriving)).height;
    expect(start, lessThan(20), reason: 'картка зʼявилась одразу на повну висоту');

    await tester.pump(const Duration(milliseconds: 230));
    final middle = tester.getSize(find.byType(Arriving)).height;
    expect(middle, greaterThan(start), reason: 'висота не росте');
    expect(middle, lessThan(120), reason: 'виросла миттєво, анімації немає');

    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.getSize(find.byType(Arriving)).height, 120);
  });

  testWidgets('картка, яка вже стояла, не грає нічого', (tester) async {
    /* Інакше весь день вивалювався б анімацією на кожному відкритті, і поява
       перекусу загубилась би серед неї. */
    await tester.pumpWidget(wrap(play: false));
    await tester.pump();

    expect(tester.getSize(find.byType(Arriving)).height, 120);
  });

  testWidgets('поява не лишає по собі помилок верстки', (tester) async {
    await tester.pumpWidget(wrap(play: true));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 80));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('вміст видно ще до кінця росту', (tester) async {
    /* Прозорість добігає раніше за висоту: картка не має проявлятись уже
       дорісши. */
    await tester.pumpWidget(wrap(play: true));
    await tester.pump(const Duration(milliseconds: 200));

    final opacity = tester.widget<Opacity>(find.byType(Opacity).first);
    expect(opacity.opacity, 1.0);
    expect(tester.getSize(find.byType(Arriving)).height, lessThan(120));
  });
}
