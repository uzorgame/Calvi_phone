import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/voice/level_source.dart';
import 'package:calvi/screens/voice/voice_overlay.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// Диктування слухає телефон, а не вигадує.
///
/// Двигун розпізнавання в тесті недосяжний, тож перевіряється те, за що
/// відповідає застосунок: накладка бере рівень із того джерела, яке їй дали, не
/// перехоплює дотиків і не зникає раніше, ніж рідина повернулась.
class _Loud implements LevelSource {
  const _Loud(this.value);

  final double value;

  @override
  double level(Duration elapsed) => value;

  @override
  void dispose() {}
}

void main() {
  Widget overlay({
    required bool leaving,
    required VoidCallback onClosed,
    LevelSource source = const _Loud(0.4),
  }) => MaterialApp(
    localizationsDelegates: L.localizationsDelegates,
    supportedLocales: L.supportedLocales,
    locale: const Locale('uk'),
    theme: calviLightTheme,
    home: Scaffold(
      body: VoiceOverlay(
        origin: const VoiceOrigin(at: Offset(337, 793), size: 42),
        leaving: leaving,
        onClosed: onClosed,
        source: source,
      ),
    ),
  );

  testWidgets('накладка живе і малює на своєму джерелі', (tester) async {
    await tester.pumpWidget(overlay(leaving: false, onClosed: () {}, source: const _Loud(0.9)));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('дотиків не ловить жодних', (tester) async {
    /* Палець лежить на кнопці внизу, і перехопити в неї подію означало б
       обірвати запис на першому ж кадрі. */
    await tester.pumpWidget(overlay(leaving: false, onClosed: () {}));
    await tester.pump(const Duration(milliseconds: 100));

    /* Саме поглинає, а не пропускає. Тут стояв `IgnorePointer`, і крізь
       відкритий екран натискалось усе, що під ним. */
    final guard = tester.widget<AbsorbPointer>(
      find.descendant(of: find.byType(VoiceOverlay), matching: find.byType(AbsorbPointer)).first,
    );
    expect(guard.absorbing, true);
  });

  testWidgets('знімається аж тоді, коли рідина повернулась', (tester) async {
    var closed = false;
    await tester.pumpWidget(overlay(leaving: false, onClosed: () => closed = true));
    await tester.pump(const Duration(milliseconds: 900));

    await tester.pumpWidget(overlay(leaving: true, onClosed: () => closed = true));
    await tester.pump(const Duration(milliseconds: 300));
    expect(closed, false, reason: 'накладка зникла з рідиною в дорозі');

    await tester.pump(const Duration(milliseconds: 500));
    expect(closed, true, reason: 'накладка не знялась і після зворотного шляху');
  });
}
