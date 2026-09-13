import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/billing/billing.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/start/start_screen.dart';

/* Пейвол: остання картка «Старту».
 *
 * Він не має прокручуватись, і саме це тут перевіряється розміром: на
 * найменшому телефоні і на звичайному екран мусить скластись без переповнень,
 * фото забирає решту, а кнопки стоять на місці. Код для перевірки тест видає
 * собі сам: у застосунку кодів немає, і чужий код струшує поле. */
void main() {
  Future<void> open(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
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
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  for (final size in const [Size(320, 568), Size(390, 844)]) {
    testWidgets('пейвол влазить на ${size.width.toInt()} без прокрутки', (tester) async {
      await open(tester, size);
      expect(tester.takeException(), isNull);
      expect(find.text('Оформити'), findsOneWidget);
      expect(find.text('Почати із пробними 40 токенами'), findsOneWidget);
      expect(find.text('Маю промокод'), findsOneWidget);
    });
  }

  testWidgets('відомий код стає міткою, чужий код лишає поле', (tester) async {
    // Перевірку коду підвішує сам тест: у застосунку жодного коду немає.
    Billing.promo = (code) async => code == 'TESTCODE' ? 20 : null;
    addTearDown(() => Billing.promo = (_) async => null);
    await open(tester, const Size(390, 844));

    await tester.tap(find.text('Маю промокод'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.tap(find.bySemanticsLabel('Застосувати'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget, reason: 'чужий код не проходить');

    await tester.enterText(find.byType(TextField), 'testcode');
    await tester.tap(find.bySemanticsLabel('Застосувати'));
    await tester.pumpAndSettle();
    expect(find.text('−20% на будь-який план'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('безкоштовна дорога веде в щоденник', (tester) async {
    var finished = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: StartScreen(step: 9, onFinish: (_) => finished = true),
      ),
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Почати із пробними 40 токенами'));
    expect(finished, isTrue);
  });
}
