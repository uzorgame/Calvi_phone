import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/voice/level_source.dart';
import 'package:calvi/screens/voice/voice_overlay.dart';

/// Диктування слухає телефон, а не вигадує.
///
/// Сам двигун розпізнавання в тесті недосяжний, тож перевіряється те, за що
/// відповідає застосунок: екран бере рівень із того джерела, яке йому дали, і
/// віддає нагору саме почуте, а не показову фразу.
class _Loud implements LevelSource {
  const _Loud(this.value);

  final double value;

  @override
  double level(Duration elapsed) => value;

  @override
  void dispose() {}
}

void main() {
  Widget overlay({required ValueChanged<String> onDone, LevelSource? source}) => MaterialApp(
    theme: calviLightTheme,
    home: Scaffold(body: VoiceOverlay(onDone: onDone, source: source)),
  );

  testWidgets('накладка бере рівень зі свого джерела', (tester) async {
    await tester.pumpWidget(overlay(onDone: (_) {}, source: const _Loud(0.9)));
    await tester.pump(const Duration(milliseconds: 100));

    // Смуги малюються, екран живий і не впав на відсутньому мікрофоні.
    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.bySemanticsLabel('Зупинити запис'), findsOneWidget);
  });

  testWidgets('дотик зупиняє і віддає почуте', (tester) async {
    var said = '?';
    await tester.pumpWidget(overlay(onDone: (text) => said = text, source: const _Loud(0.4)));

    // Показова розшифровка набирається словами, тож даємо їй прозвучати.
    await tester.pump(const Duration(seconds: 3));
    await tester.tap(find.bySemanticsLabel('Зупинити запис'));
    await tester.pump();

    expect(said, isNot('?'), reason: 'зупинка нічого не віддала');
    expect(said.trim(), said, reason: 'по краях лишились пробіли');
  });

  testWidgets('дотик повз мікрофон не обриває запис', (tester) async {
    /* Диктують із телефоном у руці, а не поклавши його на стіл. Дотик долонею
       чи великим пальцем обривав фразу посеред слова, бо зупиняло геть будь-де.
       Тепер вимикає рівно той мікрофон, яким увімкнули. */
    var said = '?';
    await tester.pumpWidget(overlay(onDone: (text) => said = text, source: const _Loud(0.4)));
    await tester.pump(const Duration(seconds: 1));

    // Верх екрана, середина, підказка під смугами: усе повз кнопку.
    for (final spot in const [Offset(200, 80), Offset(200, 400), Offset(200, 640)]) {
      await tester.tapAt(spot);
      await tester.pump();
      expect(said, '?', reason: 'дотик у $spot обірвав диктування');
    }

    // А кнопка зупиняє.
    await tester.tap(find.bySemanticsLabel('Зупинити запис'));
    await tester.pump();
    expect(said, isNot('?'));
  });

  testWidgets('підказка каже, чим зупиняти', (tester) async {
    await tester.pumpWidget(overlay(onDone: (_) {}, source: const _Loud(0.2)));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Говори. Торкнись мікрофона, щоб зупинити'), findsOneWidget);
  });

  test('дихання без голосу лишається ледь помітним', () {
    const idle = BreathingLevel();

    for (var ms = 0; ms < 2000; ms += 137) {
      final v = idle.level(Duration(milliseconds: ms));
      expect(v, greaterThanOrEqualTo(0));
      expect(v, lessThanOrEqualTo(1));
    }
  });
}
