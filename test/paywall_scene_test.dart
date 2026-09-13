import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/start/start_screen.dart';

/* Сцена на фото пейволу йде за розкладом демки, і розклад тут перевіряється
   числами, а не оком: рамка входить за 620 мс, промінь іде з 0.4 до 2.0 с,
   підписи виринають о 0.9, 1.5 і 1.6 с, картка результату піднімається о 2.0
   і стоїть на місці о 2.48. Значення взяті з ключових кадрів start.css. */
void main() {
  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: StartScreen(step: 9, onFinish: (_) {}),
      ),
    );
    /* Фото розкодовується справжнім часом, і лише тоді стартує годинник
       сцени: даємо йому мить поза підробленим годинником тесту. */
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
  }

  double opacityAbove(WidgetTester tester, Finder f) =>
      tester.widget<Opacity>(find.ancestor(of: f, matching: find.byType(Opacity)).first).opacity;

  testWidgets('рамка, промінь, підписи і картка йдуть за розкладом демки', (tester) async {
    await open(tester);
    final corners = find.byWidgetPredicate((w) => w is CustomPaint && w.painter != null);
    final frame = find.byType(AspectRatio);

    // 0.31 с: рамка на половині входу, підписів ще немає, картки теж.
    await tester.pump(const Duration(milliseconds: 310));
    final half = opacityAbove(tester, corners);
    expect(half, greaterThan(0.5));
    expect(half, lessThan(1));
    expect(find.text('Рис'), findsNothing);
    expect(opacityAbove(tester, find.text('Паелья з морепродуктами')), 0);

    // 1.2 с: рамка стоїть, промінь рівно посередині вікна, «Рис» уже є,
    // «Креветки» ще ні.
    await tester.pump(const Duration(milliseconds: 890));
    expect(opacityAbove(tester, corners), 1);
    final beam = find.byWidgetPredicate(
      (w) => w is Container && w.decoration is BoxDecoration && (w.decoration! as BoxDecoration).gradient != null,
    );
    expect(beam, findsOneWidget);
    final top = tester.getTopLeft(beam).dy - tester.getTopLeft(frame).dy;
    final side = tester.getSize(frame).width;
    expect(top, closeTo(14 + (side - 28) * 0.5, 2));
    expect(find.text('Рис'), findsOneWidget);
    expect(opacityAbove(tester, find.text('Рис')), closeTo(1, 0.01));
    expect(find.text('Креветки'), findsNothing);

    // 1.75 с: усі три підписи на місці, картки ще немає.
    await tester.pump(const Duration(milliseconds: 550));
    expect(find.text('Креветки'), findsOneWidget);
    expect(find.text('Горошок'), findsOneWidget);
    expect(opacityAbove(tester, find.text('Паелья з морепродуктами')), 0);

    // 2.24 с: промінь згас, картка на половині підйому.
    await tester.pump(const Duration(milliseconds: 490));
    expect(beam, findsNothing);
    final rising = opacityAbove(tester, find.text('Паелья з морепродуктами'));
    expect(rising, greaterThan(0.5));
    expect(rising, lessThan(1));

    // 2.6 с: усе стоїть.
    await tester.pump(const Duration(milliseconds: 360));
    expect(opacityAbove(tester, find.text('Паелья з морепродуктами')), 1);
    expect(tester.takeException(), isNull);
  });
}
