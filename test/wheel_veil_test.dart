import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/theme.dart';
import 'package:calvi/design/tokens.dart';
import 'package:calvi/design/wheel.dart';

/// Барабан нічого не малює під собою і нічим не замальовує свої краї.
///
/// Раніше тут було два малювання, і обидва пішли. Під обраним значенням лежала
/// сіра смуга: вона читалась як окрема поверхня поверх теми, а на екрані з
/// двома барабанами робила з нього дві смуги. А кінці барабана накривали двома
/// пеленами кольору тієї поверхні, на якій він лежить: це працює, поки під ним
/// рівна фарба, але наші ґрунти градієнтні, і на «Світанку» пелени лягали
/// блідими плямами поверх переходу.
///
/// Тепер краї згасають маскою, тобто справжньою прозорістю, а фоном лишається
/// сам ґрунт, яким би він не був. Ці тести стережуть, щоб фарба не повернулась.
void main() {
  Widget wheel({Color? on, ThemeData? theme}) {
    final drum = CalviWheel(values: const [1, 2, 3], value: 2, suffix: 'кг', onPick: (_) {});
    return MaterialApp(
      theme: theme ?? calviDarkTheme,
      home: Scaffold(
        body: on == null ? drum : CalviOn(color: on, child: drum),
      ),
    );
  }

  /// Непрозорі заливки й градієнти всередині барабана.
  List<Color> paint(WidgetTester tester) {
    final out = <Color>[];
    void walk(RenderObject node) {
      if (node is RenderDecoratedBox) {
        final d = node.decoration;
        if (d is BoxDecoration) {
          final g = d.gradient;
          if (g is LinearGradient) out.addAll(g.colors.where((x) => x.a > 0));
          final fill = d.color;
          if (fill != null && fill.a > 0) out.add(fill);
        }
      }
      node.visitChildren(walk);
    }

    walk(tester.binding.rootElement!.findRenderObject()!);
    return out;
  }

  testWidgets('під обраним значенням немає смуги', (tester) async {
    await tester.pumpWidget(wheel());
    await tester.pumpAndSettle();

    expect(
      paint(tester),
      isNot(contains(calviDark.fillSecondary)),
      reason: 'сіра смуга під обраним значенням повернулась',
    );
  });

  testWidgets('краї не замальовуються, а згасають маскою', (tester) async {
    await tester.pumpWidget(wheel(on: calviDark.card));
    await tester.pumpAndSettle();

    expect(
      paint(tester),
      isEmpty,
      reason: 'барабан знову щось малює замість того, щоб бути прозорим',
    );
    expect(
      find.byType(ShaderMask),
      findsOneWidget,
      reason: 'маска зникла, тобто краї більше не згасають',
    );
  });

  testWidgets('те саме у світлій темі', (tester) async {
    await tester.pumpWidget(wheel(theme: calviLightTheme));
    await tester.pumpAndSettle();

    expect(paint(tester), isEmpty);
    expect(find.byType(ShaderMask), findsOneWidget);
  });
}
