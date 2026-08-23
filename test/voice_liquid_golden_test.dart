import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/voice/level_source.dart';
import 'package:calvi/screens/voice/voice_overlay.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// Кадри рідини, знятими очима того самого рушія, що малює на телефоні.
///
/// Дивитись на це в браузері виявилось довше, ніж зняти: тут кожен кадр
/// відтворюваний до пікселя і не залежить від того, скільки встигла намалювати
/// панель попереднього перегляду.
Widget _screen({required bool leaving}) => MaterialApp(
  localizationsDelegates: L.localizationsDelegates,
  supportedLocales: L.supportedLocales,
  locale: const Locale('uk'),
  theme: calviLightTheme,
  home: Scaffold(
    body: VoiceOverlay(
      origin: const VoiceOrigin(at: Offset(337, 793), size: 42),
      leaving: leaving,
      onClosed: () {},
      source: const BreathingLevel(),
    ),
  ),
);

void main() {
  Future<void> shoot(WidgetTester tester, String name, List<Duration> at) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_screen(leaving: false));

    var seen = Duration.zero;
    for (final t in at) {
      await tester.pump(t - seen);
      seen = t;
      await expectLater(
        find.byType(VoiceOverlay),
        matchesGoldenFile('goldens/voice_$name${t.inMilliseconds}.png'),
      );
    }
  }

  testWidgets('рідина від кнопки до метра', (tester) async {
    await shoot(tester, 'in', const [
      Duration(milliseconds: 220),
      Duration(milliseconds: 480),
      Duration(milliseconds: 760),
      Duration(milliseconds: 1400),
    ]);
  });

  testWidgets('і назад у кнопку, коли палець прибрали', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_screen(leaving: false));
    await tester.pump(const Duration(milliseconds: 1400));

    await tester.pumpWidget(_screen(leaving: true));
    for (final t in const [120, 300, 560]) {
      await tester.pump(const Duration(milliseconds: 120));
      await expectLater(find.byType(VoiceOverlay), matchesGoldenFile('goldens/voice_back$t.png'));
    }
    // Дожити до кінця зворотного шляху, щоб не лишити таймер у повітрі.
    await tester.pump(const Duration(milliseconds: 400));
  });
}
