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

/// Тема доходить до самого низу на кожній сторінці.
///
/// Раніше не доходила: під головною кнопкою лягала смуга іншого тону, і вона
/// була на «Тема», «Приватність», «Про застосунок», «Помічник», «Мова» і решті
/// налаштувань. Причина була в ґрунті. Він був градієнтним, тобто колір
/// сторінки різний на різній висоті, а підкладка під кнопкою розчиняється в
/// один колір і збігтися з градієнтом не могла ніде, крім однієї висоти.
///
/// Перевіряється саме та рівність, яка ламалась: колір, у який згасає підкладка
/// під кнопкою, і колір ґрунту під нею. Рівні означає, що підкладки не видно
/// зовсім, хай якої вона висоти. Не рівні означає смугу, і байдуже на скільки
/// тонів вони розійшлись.
void main() {
  final now = DateTime(2026, 8, 20).millisecondsSinceEpoch;

  /// Сторінки налаштувань, усі до одної.
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
      'Політика': LegalPanel(doc: privacy, onBack: () {}),
      'Про застосунок': const AboutPanel(),
      'Видалення': const DeletePanel(),
    };
  }

  Future<void> open(
    WidgetTester tester,
    Widget page,
    ThemeData theme, {
    Size size = const Size(390, 844),
    double scale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: theme,
        builder: (context, child) => MediaQuery.withNoTextScaling(
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
        ),
        home: CalviGround(child: page),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Кольори, у які згасають усі підкладки на сторінці.
  ///
  /// Береться непрозорий кінець кожного градієнта: саме він має збігтися з
  /// ґрунтом. Прозорий кінець ні на що не лягає й нічого не значить.
  List<Color> fades(WidgetTester tester) {
    final out = <Color>[];

    void walk(RenderObject node) {
      if (node is RenderDecoratedBox) {
        final d = node.decoration;
        final g = d is BoxDecoration ? d.gradient : null;
        if (g is LinearGradient && g.colors.any((x) => x.a == 0)) {
          out.addAll(g.colors.where((x) => x.a == 1));
        }
      }
      node.visitChildren(walk);
    }

    walk(tester.binding.rootElement!.findRenderObject()!);
    return out;
  }

  /// Колір ґрунту внизу сторінки, там де стоїть кнопка.
  ///
  /// Саме внизу, а не взагалі: ґрунт у темряві градієнтний, і питання про смугу
  /// це питання про той тон, який лежить під підкладкою.
  Color ground(WidgetTester tester) =>
      CalviGround.toneAt(tester.element(find.byType(CalviGround).first), 1);

  testWidgets('темна «Тема» виглядає так, як домовлено', (tester) async {
    /* Одна сторінка, зате справжніми пікселями, і саме та, на якій користувач
       побачив смугу під кнопкою «Готово». Решта перевірок тут дивиться на
       кольори у віджетах, а ця на намальований екран цілком: вугільний ґрунт
       угорі, рівне поле внизу, підкладка під кнопкою невидима.

       Через еталонне зображення, а не через читання пікселів руками: `toImage`
       у цьому оточенні рахується хвилинами, а порівняння з еталоном секунди. */
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await open(
      tester,
      ThemePanel(s: initialSettings(), set: (_) {}, onBack: () {}),
      calviDarkTheme,
    );

    await expectLater(find.byType(CalviGround), matchesGoldenFile('goldens/dark_theme_page.png'));
  });

  for (final (name, theme) in [('темній', calviDarkTheme), ('світлій', calviLightTheme)]) {
    testWidgets('у $name темі підкладки згасають рівно в ґрунт на кожній сторінці', (tester) async {
      final broken = <String, String>{};

      for (final page in pages().entries) {
        await open(tester, page.value, theme);
        final soil = ground(tester);
        final off = fades(tester).where((x) => x != soil).toList();
        if (off.isNotEmpty) broken[page.key] = 'ґрунт $soil, підкладка $off';
      }

      expect(broken, isEmpty, reason: 'сторінки зі смугою впоперек: $broken');
    });

    /* І кожна влазить у телефон. Переповнений ряд це смугаста жовто-чорна
       стрічка поперек екрана, і бачить її не розробник, а людина з найменшим
       телефоном або зі збільшеним системним шрифтом. */
    for (final (where, size, scale) in [
      ('на звичайному телефоні', const Size(390, 844), 1.0),
      ('на найменшому телефоні', const Size(320, 568), 1.0),
      ('зі збільшеним шрифтом', const Size(390, 844), 1.3),
    ]) {
      testWidgets('у $name темі кожна сторінка влазить $where', (tester) async {
        for (final page in pages().entries) {
          await open(tester, page.value, theme, size: size, scale: scale);
          expect(tester.takeException(), isNull, reason: 'сторінка «${page.key}» не влазить');
        }
      });
    }
  }
}
