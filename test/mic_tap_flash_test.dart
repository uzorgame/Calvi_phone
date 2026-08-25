import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/main.dart';
import 'package:calvi/screens/voice/voice_overlay.dart';

/// Тап по мікрофону не відкриває екран запису.
///
/// Промах пальцем це не фраза, а показувати заради нього повний екран із
/// рідиною означає блимнути ним ні за чим. Слухати починаємо з першої
/// мілісекунди, а показуємо аж коли стало ясно, що палець таки тримають.
void main() {
  Future<void> openDay(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = const [Locale('uk')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const CalviApp(storage: false, hello: false));
    await tester.pump(const Duration(seconds: 1));
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.text('Далі'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Поки без входу'));
    await tester.pumpAndSettle();
  }

  testWidgets('коротке торкання не показує екран запису', (tester) async {
    await openDay(tester);

    final mic = find.bySemanticsLabel('Мікрофон');
    expect(mic, findsOneWidget);

    for (final short in const [80, 260]) {
      final press = await tester.startGesture(tester.getCenter(mic));
      await tester.pump(Duration(milliseconds: short));
      await press.up();
      await tester.pump(const Duration(milliseconds: 120));

      expect(find.byType(VoiceOverlay), findsNothing, reason: 'екран лишився після торкання в  мс');
    }
  });

  testWidgets('палець зʼїхав із кнопки, а запис триває', (tester) async {
    /* Рука ледь поїхала, і запис обривався посеред фрази: жест вважав це
       скасуванням. У месенджерах так не роблять, і саме тому там зручно. */
    await openDay(tester);

    final mic = tester.getCenter(find.bySemanticsLabel('Мікрофон'));
    final press = await tester.startGesture(mic);
    await tester.pump(const Duration(milliseconds: 300));

    // Палець поїхав на середину екрана, але з екрана не зійшов.
    await press.moveTo(mic - const Offset(120, 260));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(VoiceOverlay), findsOneWidget, reason: 'запис обірвався від руху пальця');

    await press.up();
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('а утримання показує', (tester) async {
    await openDay(tester);

    final press = await tester.startGesture(tester.getCenter(find.bySemanticsLabel('Мікрофон')));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(VoiceOverlay), findsOneWidget, reason: 'екран не зʼявився на утриманні');

    await press.up();
    await tester.pump(const Duration(seconds: 2));
  });
}
