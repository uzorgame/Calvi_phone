import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/theme.dart';
import 'package:calvi/design/tokens.dart';
import 'package:calvi/design/wheel.dart';

/// Пелена на кінцях барабана бере колір того, на чому барабан лежить.
///
/// Довго брала колір сторінки завжди. Барабан стоїть переважно в аркуші, а
/// аркуш у темряві світліший за сторінку: замість того щоб зникнути, пелена
/// лягала на кінці барабана видимою темною смугою. Те саме в світлій темі,
/// тільки тихіше: сірий на білому.
void main() {
  Widget wheel({Color? on}) {
    final drum = CalviWheel(values: const [1, 2, 3], value: 2, suffix: 'кг', onPick: (_) {});
    return MaterialApp(
      theme: calviDarkTheme,
      home: Scaffold(
        body: on == null ? drum : CalviOn(color: on, child: drum),
      ),
    );
  }

  /// Непрозорі кінці всіх пелен на екрані.
  List<Color> veils(WidgetTester tester) {
    final out = <Color>[];
    void walk(RenderObject node) {
      if (node is RenderDecoratedBox) {
        final d = node.decoration;
        final g = d is BoxDecoration ? d.gradient : null;
        if (g is LinearGradient) out.addAll(g.colors.where((x) => x.a == 1));
      }
      node.visitChildren(walk);
    }

    walk(tester.binding.rootElement!.findRenderObject()!);
    return out;
  }

  testWidgets('без позначки пелена кольору сторінки', (tester) async {
    await tester.pumpWidget(wheel());
    await tester.pumpAndSettle();
    expect(veils(tester), everyElement(calviDark.bg));
  });

  testWidgets('в аркуші пелена кольору аркуша', (tester) async {
    await tester.pumpWidget(wheel(on: calviDark.card));
    await tester.pumpAndSettle();

    expect(veils(tester), isNotEmpty, reason: 'пелени не знайшлись, перевіряти нічого');
    expect(
      veils(tester),
      everyElement(calviDark.card),
      reason: 'барабан в аркуші й далі згасає в колір сторінки',
    );
  });
}
