import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/slide.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/design/tokens.dart';

/// Вихід зі сторінки гасне, а не обривається.
///
/// Сторінка, що йде, доти зсувалась на двадцять шість пікселів і зникала
/// останнім кадром. Двадцять шість пікселів око майже не читає, тож виглядало
/// це так, ніби екран просто вимкнули. Тепер вона гасне за весь час руху, а
/// той, що під нею, проступає крізь неї.
///
/// На вхід розчинення лишається забороненим: попередня сторінка ще змонтована
/// під новою, і напівпрозора нова пропускає її текст крізь себе.
void main() {
  Future<double> opacityDuring(WidgetTester tester, {required bool back}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: calviLightTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  slideRoute(
                    Builder(
                      builder: (inner) => Scaffold(
                        body: Center(
                          child: TextButton(
                            onPressed: () => Navigator.of(inner).pop(),
                            child: const Text('назад'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                child: const Text('уперед'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('уперед'));
    await tester.pump();
    if (!back) {
      await tester.pump(CalviMotion.screen ~/ 2);
    } else {
      await tester.pumpAndSettle();
      await tester.tap(find.text('назад'));
      await tester.pump();
      await tester.pump(CalviMotion.screen ~/ 2);
    }

    // Прозорість, яку ставить сам маршрут: вона одна на всю сторінку.
    final layers = tester
        .widgetList<Opacity>(
          find.descendant(of: find.byType(RepaintBoundary), matching: find.byType(Opacity)),
        )
        .map((o) => o.opacity)
        .toList();
    return layers.isEmpty ? 1 : layers.reduce((a, b) => a < b ? a : b);
  }

  testWidgets('на вхід сторінка непрозора весь час', (tester) async {
    expect(
      await opacityDuring(tester, back: false),
      1,
      reason: 'нова сторінка напівпрозора: попередня читатиметься крізь неї',
    );
  });

  testWidgets('на вихід сторінка гасне', (tester) async {
    final at = await opacityDuring(tester, back: true);
    expect(at, lessThan(0.98), reason: 'сторінка не гасне, вихід читається обривом');
    expect(at, greaterThan(0.02), reason: 'сторінка зникла одразу, це той самий обрив');
  });
}
