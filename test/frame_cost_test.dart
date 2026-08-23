import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/today/today_screen.dart';

/// Скільки роботи коштує один кадр головного екрана.
///
/// Застосунок став важким після редизайну, і причина не в кількості віджетів, а
/// в тому, що з них малюється дорого. Дорогого в Flutter рівно два різновиди:
/// розмиття і збережений шар. Розмиття це кожна тінь, і воно рахується на
/// кожен кадр прокрутки заново. Збережений шар це прозорість не в одиницю,
/// згладжене обрізання і маска: кожен з них це окреме полотно, яке малюється, а
/// потім змішується з рештою.
///
/// Тут вони перелічені поіменно: на дні зараз тринадцять розмиттів і два шари.
/// Стеля не істина в останній інстанції, а межа,
/// за яку не можна зайти непомітно: наступна правка, яка додасть на головний
/// екран десять тіней, зупиниться тут, а не на телефоні.
void main() {
  /// Скільки чого малює цей екран.
  ({int blurs, int layers}) cost(WidgetTester tester) {
    var blurs = 0;
    var layers = 0;

    void walk(RenderObject node) {
      if (node is RenderDecoratedBox) {
        final d = node.decoration;
        if (d is BoxDecoration) blurs += d.boxShadow?.length ?? 0;
      }
      if (node is RenderPhysicalModel || node is RenderPhysicalShape) layers++;
      // Прозорість в одиницю шару не коштує: Flutter малює дитину напряму.
      if (node is RenderOpacity && node.opacity > 0 && node.opacity < 1) layers++;
      if (node is RenderAnimatedOpacity && node.opacity.value > 0 && node.opacity.value < 1) {
        layers++;
      }
      if (node is RenderShaderMask) layers++;
      if (node is RenderBackdropFilter) layers++;
      node.visitChildren(walk);
    }

    walk(tester.binding.rootElement!.findRenderObject()!);
    return (blurs: blurs, layers: layers);
  }

  Future<void> today(WidgetTester tester, ThemeData theme) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      AppScope(
        s: initialSettings(),
        set: (_) {},
        meds: const [],
        setMeds: (_) {},
        real: false,
        setReal: (_) {},
        child: MaterialApp(
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          locale: const Locale('uk'),
          theme: theme,
          scrollBehavior: const CalviScroll(),
          home: TodayScreen(onSettings: () {}, onMeds: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final (name, theme) in [('світлій', calviLightTheme), ('темній', calviDarkTheme)]) {
    testWidgets('кадр дня в $name темі не дорожчає непомітно', (tester) async {
      await today(tester, theme);
      final at = cost(tester);

      expect(
        at.blurs,
        lessThanOrEqualTo(15),
        reason: 'розмиттів на кадр стало більше: ${at.blurs}',
      );
      expect(
        at.layers,
        lessThanOrEqualTo(3),
        reason: 'збережених шарів на кадр стало більше: ${at.layers}',
      );
    });
  }

  testWidgets('картка, що відкривається, не перемальовує весь день', (tester) async {
    await today(tester, calviLightTheme);

    /* Межі перемальовування довкола карток. Без них одна картка, що росте,
       тягне за собою перемальовування всього дня разом із тінями під усіма
       іншими картками, і так усі двадцять шість кадрів її відкриття. */
    var walls = 0;
    void walk(RenderObject node) {
      if (node is RenderRepaintBoundary) walls++;
      node.visitChildren(walk);
    }

    walk(tester.binding.rootElement!.findRenderObject()!);
    expect(walls, greaterThanOrEqualTo(30), reason: 'карток без власного шару побільшало: $walls');
  });
}
