import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/legal.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/settings/panel_about.dart';
import 'package:calvi/screens/settings/panel_allergy.dart';
import 'package:calvi/screens/settings/panel_assistant.dart';
import 'package:calvi/screens/settings/panel_legal.dart';
import 'package:calvi/screens/settings/panel_reminders.dart';
import 'package:calvi/screens/settings/panels_account.dart';
import 'package:calvi/screens/settings/panels_body.dart';

/// Підкладку, якої не видно, ставити нема сенсу.
///
/// Одна й та сама біда знаходилась уже вчетверте, щоразу в новому місці:
/// доріжка повзунка, чипи алергій, жолоб перемикача, рядок пошуку. Причина всюди
/// однакова, `fillSecondary` це `#f5f5f7`, а ґрунт сторінки `#f6f6f8`, тобто
/// різниця в один крок з 255. Людина бачить напис, який висить у повітрі, і не
/// здогадується, що по ньому можна тицяти.
///
/// Шукати такі місця очима означає знаходити пʼяте завтра. Тому тут інструмент:
/// обхід намальованого дерева, який для кожної заливки знає, на чому вона
/// лежить, і скаржиться, коли одне від одного не відрізнити.
void main() {
  final now = DateTime(2026, 8, 20).millisecondsSinceEpoch;

  Map<String, Widget> pages() {
    final s = initialSettings();
    void set(SettingsState Function(SettingsState) f) {}

    return {
      'Профіль': ProfilePanel(s: s, set: set, onBack: () {}),
      'Ціль': GoalPanel(s: s, set: set, onBack: () {}),
      'Норма': NormPanel(s: s, set: set, onBack: () {}),
      'Вага': WeightPanel(s: s, set: set, onBack: () {}),
      'Алергени': AllergyPanel(s: s, set: set, onBack: () {}),
      'Помічник': AssistantPanel(s: s, set: set, onBack: () {}),
      'Нагадування': RemindersPanel(
        s: s,
        set: set,
        onBack: () {},
        medsRemind: false,
        onMedsRemind: (_) {},
        onMeds: () {},
        now: now,
      ),
      'Підписка': const PlanPanel(),
      'Тема': ThemePanel(s: s, set: set, onBack: () {}),
      'Мова': LangPanel(s: s, set: set, onBack: () {}),
      'Приватність': PrivacyPanel(s: s, set: set, onBack: () {}),
      'Умови': LegalPanel(doc: terms, onBack: () {}),
      'Про застосунок': const AboutPanel(),
      'Видалення': const DeletePanel(),
    };
  }

  /* Скільки тонів між двома кольорами, за найбільшим із каналів.
     Один-два це та сама фарба з іншим ім'ям, сім це вже видима форма. */
  int apart(Color a, Color b) {
    int ch(double x, double y) => ((x - y).abs() * 255).round();
    return [ch(a.r, b.r), ch(a.g, b.g), ch(a.b, b.b)].reduce((x, y) => x > y ? x : y);
  }

  /// Непрозорий колір цієї коробки, якщо вона взагалі щось заливає.
  ///
  /// Градієнт віддає свій останній привал: саме він лежить під тим, що стоїть
  /// на цій поверхні нижче, а верх градієнта до сусідів не дотикається.
  Color? fillOf(RenderObject node) {
    if (node is! RenderDecoratedBox) return null;
    final d = node.decoration;
    if (d is! BoxDecoration) return null;
    final g = d.gradient;
    if (g is LinearGradient && g.colors.last.a == 1) return g.colors.last;
    final col = d.color;
    return col != null && col.a == 1 ? col : null;
  }

  /// Ім'я віджета, який цю коробку створив, щоб у скарзі було куди йти.
  String whose(RenderObject node) {
    final creator = node.debugCreator;
    if (creator is! DebugCreator) return node.runtimeType.toString();
    final chain = creator.element.debugGetCreatorChain(6);
    return chain.split('\n').first;
  }

  /// Заливки, які не відрізнити від того, на чому вони лежать.
  List<String> invisible(WidgetTester tester) {
    final out = <String>[];

    void walk(RenderObject node, Color under) {
      var next = under;
      final fill = fillOf(node);
      if (fill != null) {
        /* Нуль не рахується. Коробка, залита рівно тим самим кольором, це не
           невидима підкладка, а щит непрозорості: сторінка, яка їде поверх
           іншої, мусить мати власне тло того ж тону, інакше крізь неї видно. */
        final d = apart(fill, under);
        if (d > 0 && d <= 2) out.add('${whose(node)}: $fill на $under');
        next = fill;
      }
      node.visitChildren((child) => walk(child, next));
    }

    /* Від кореня, з кольором вікна під ним: усе, що нижче, стоїть або на ґрунті
       сторінки, або на чомусь, що ґрунт уже накрило. */
    walk(tester.binding.rootElement!.findRenderObject()!, const Color(0xFF000000));
    return out;
  }

  Future<void> open(WidgetTester tester, Widget page, ThemeData theme) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: theme,
        home: CalviGround(child: page),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final (name, theme) in [('світлій', calviLightTheme), ('темній', calviDarkTheme)]) {
    testWidgets('у $name темі кожну підкладку видно на тому, де вона лежить', (tester) async {
      final broken = <String, List<String>>{};

      for (final page in pages().entries) {
        await open(tester, page.value, theme);
        final bad = invisible(tester);
        if (bad.isNotEmpty) broken[page.key] = bad;
      }

      expect(
        broken,
        isEmpty,
        reason:
            'підкладки, які зливаються з тим, на чому стоять:\n'
            '${broken.entries.map((e) => '${e.key}:\n  ${e.value.join('\n  ')}').join('\n')}',
      );
    });
  }
}
