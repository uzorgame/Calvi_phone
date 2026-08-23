import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/voice/level_source.dart';
import 'package:calvi/screens/voice/voice_overlay.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// Відкритий екран запису не пропускає дотиків крізь себе.
///
/// Тут стояв `IgnorePointer`, і поки екран світився, натискалось геть усе, що
/// під ним: розмита картка дня ловила дотик і відкривалась.
void main() {
  testWidgets('крізь накладку нічого не натискається', (tester) async {
    var behind = 0;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => behind++),
              ),
              const VoiceOverlay(
                origin: VoiceOrigin(at: Offset(337, 793), size: 42),
                leaving: false,
                onClosed: _nothing,
                source: BreathingLevel(),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    for (final spot in const [Offset(200, 120), Offset(200, 400), Offset(200, 700)]) {
      await tester.tapAt(spot);
      await tester.pump();
    }

    expect(behind, 0, reason: 'дотик пройшов крізь екран запису');
  });
}

void _nothing() {}
