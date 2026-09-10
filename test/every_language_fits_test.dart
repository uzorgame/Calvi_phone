import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/day.dart' show dataLang;
import 'package:calvi/data/day_stats.dart';
import 'package:calvi/data/meds.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/data/week.dart';
import 'package:calvi/design/shell.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/design/tokens.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/analytics/analytics_screen.dart';
import 'package:calvi/screens/meds/meds_screen.dart';
import 'package:calvi/screens/settings/settings_screen.dart';
import 'package:calvi/screens/start/start_screen.dart';
import 'package:calvi/screens/today/today_screen.dart';
import 'package:calvi/screens/week/week_screen.dart';

/// Кожен екран кожною мовою, і не тільки «влазить», а й «дочитується».
///
/// Сусідні перевірки міряють інше: `screens_fit_test` бере найменший телефон і
/// збільшений шрифт, але однією мовою, українською. Мова змінює рівно ту саму
/// величину, що й шрифт, тобто довжину слова, і робить це сильніше: «Вуглеводи»
/// це девʼять літер, «Kohlenhydrate» тринадцять.
///
/// Перевірок дві, бо вад теж дві, і друга тихіша за першу.
///
/// Переповнення видно: жовто-чорна стрічка і виняток у тесті. Обрізання не
/// видно нікому, крім людини, яка читає: підпис із `maxLines: 1` мовчки стає
/// «KOHLENHYDRA», і жоден виняток при цьому не кидається. Саме так німецька
/// картка втратила слово, і знайшлось воно оком на знімку екрана, а не тут.
void main() {
  /// Мови, якими застосунок говорить. Не список руками: мова, додана в
  /// `supportedLocales` і забута тут, лишилась би неперевіреною.
  final langs = [for (final l in L.supportedLocales) l.languageCode];

  Map<String, Widget> screens() => {
    'Сьогодні': TodayScreen(onSettings: () {}, onMeds: () {}, onPlan: () {}),
    'Тиждень': WeekScreen(
      summary: weekSummary(DayStats.demo(), initialSettings()),
      onSettings: () {},
    ),
    'Аналітика': AnalyticsScreen(measures: const [], onSettings: () {}),
    'Препарати': MedsScreen(
      meds: demoMeds,
      onToggle: (_, _) {},
      onSave: (_) {},
      onFinish: (_) {},
      onRevive: (_) {},
    ),
    'Налаштування': const SettingsScreen(),
    'Старт': StartScreen(onFinish: (_) {}),
    /* «Ласкаво просимо» окремим рядком, бо сам «Старт» відкривається на
       заставці і до нього не доходить. Екран без прокрутки: німецьке
       привітання довше за українське, а гортати тут нема чого. */
    'Ласкаво просимо': StartScreen(step: 1, onFinish: (_) {}),
    /* Картка «токени скінчились» стоїть тут окремо, бо в самому дні вона
       зʼявляється лише у відповідь сервера, а рядки в ній довгі й на восьми
       мовах різні: німецьке «Die Tokens sind aufgebraucht» удвічі довше за
       українське, і кнопка під ним має лишитись кнопкою, а не смугою. */
    'Токени скінчились': Builder(
      builder: (context) {
        final l = L.of(context);
        return Padding(
          padding: const EdgeInsets.all(CalviSize.gutter),
          child: CalviNora(
            text: l.todayOutOfTokens,
            hint: l.todayOutOfBody,
            action: l.todayOutOfPlan,
            onAction: () {},
          ),
        );
      },
    ),
  };

  Future<void> open(WidgetTester tester, Widget screen, String lang, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    /* Мова шару даних іде окремо від локалі: її ставить `main`, і без неї дати
       лишились би українськими посеред німецького екрана. */
    dataLang = lang;
    addTearDown(() => dataLang = 'uk');

    await tester.pumpWidget(
      AppScope(
        s: initialSettings(),
        set: (_) {},
        meds: demoMeds,
        setMeds: (_) {},
        stats: DayStats.demo(),
        real: false,
        setReal: (_) {},
        child: MaterialApp(
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          locale: Locale(lang),
          theme: calviLightTheme,
          scrollBehavior: const CalviScroll(),
          builder: (context, child) =>
              MediaQuery.withNoTextScaling(child: CalviGround(child: child ?? const SizedBox())),
          home: screen,
        ),
      ),
    );
    /* Кадрами, а не до зупинки: на екрані препаратів пульсує значок курсу, і
       чекати його зупинки означає чекати вічно. */
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// Обрізані написи екрана, за їхнім місцем у дереві.
  ///
  /// Питається сам малювальник тексту, а не ширина коробки: він єдиний знає,
  /// скільки рядків справді вийшло і чи довелось останній обрубати.
  ///
  /// Ключ це порядковий номер напису, а не сам напис. Дерево екрана однакове в
  /// усіх мовах, різні в ньому лише рядки, тому номер вказує на той самий підпис
  /// і дозволяє питати «чи обрізався він саме тут», а не «чи є обрізане взагалі».
  /* Обрізати текст можна двома різними способами, і другий тихіший.
   *
   * Перший це трикрапка: рядків більше, ніж дозволено, зайве відкидається, і
   * малювальник сам про це каже прапорцем. Другий це напис, якому заборонили
   * переносити: він лягає в **один рядок будь-якої довжини**, шириною більший
   * за свою коробку, і його зрізає край. Рядків при цьому рівно стільки,
   * скільки дозволено, тому прапорець мовчить.
   *
   * Саме так до телефона доїхало польське «WĘGLOWODAN»: перевірка бачила
   * тільки перший спосіб. Другий видно з порівняння потрібної ширини з даною,
   * і питати про це можна лише там, де переносити нема куди: у звичайного
   * абзацу потрібна ширина завжди більша за дану, на те він і абзац. */
  bool cut(RenderParagraph p) {
    if (p.didExceedMaxLines) return true;
    if (p.softWrap && p.maxLines != 1) return false;
    return p.getMaxIntrinsicWidth(double.infinity) > p.constraints.maxWidth + 0.5;
  }

  Map<int, String> clipped(WidgetTester tester) {
    final out = <int, String>{};
    var i = 0;

    void walk(RenderObject node) {
      if (node is RenderParagraph) {
        if (cut(node)) out[i] = node.text.toPlainText().replaceAll('\n', ' ');
        i++;
      }
      node.visitChildren(walk);
    }

    walk(tester.binding.rootElement!.renderObject!);
    return out;
  }

  for (final (place, size) in [
    ('на звичайному телефоні', const Size(390, 844)),
    ('на найменшому телефоні', const Size(320, 568)),
  ]) {
    for (final lang in langs) {
      testWidgets('екрани влазять мовою «$lang» $place', (tester) async {
        for (final screen in screens().entries) {
          await open(tester, screen.value, lang, size);
          expect(
            tester.takeException(),
            isNull,
            reason: '«${screen.key}» переповнений мовою «$lang» $place',
          );
        }
      });
    }

    /* Порівняння з англійською, а не «обрізаного немає взагалі».
     *
     * На телефоні завширшки триста двадцять пікселів обрізається багато чого і
     * в українській, і в англійській: довга назва страви, «81.0 кг на старті
     * цілі», вага під кільцем. Це властивість тісного екрана, вона однакова в
     * усіх мовах і давно там була.
     *
     * Питання цієї перевірки вужче й відповідальніше: чи зʼїла нова мова слово
     * там, де рідна його показує. Саме таким було німецьке «KOHLENHYDRA». */
    testWidgets('нові мови не обрізають те, що англійська показує $place', (tester) async {
      for (final screen in screens().entries) {
        /* Налаштування сюди не входять, і це сказано вголос.
         *
         * Той ряд ріже значення в усіх мовах: англійською «Nora, 4 in memory»
         * дістає сто сімнадцять пікселів із двохсот двадцяти одного, а
         * «Delete account and data» двісті шістдесят із трьохсот сорока. Так
         * було до появи нових мов і так само в українській. Порівнювати тут
         * переклад означає міряти не переклад, а тісноту ряду, яка нікуди не
         * дінеться від жодного слова.
         *
         * Німецька додає до цих шести ще два обрізаних місця, «Assistentin» і
         * «2 280 kcal», на девʼять і тринадцять пікселів. Це справжня різниця,
         * але лікується вона шириною ряду, а не перекладом. */
        if (screen.key == 'Налаштування') continue;

        await open(tester, screen.value, 'en', size);
        tester.takeException();
        final fine = clipped(tester).keys.toSet();

        for (final lang in langs) {
          if (lang == 'en') continue;

          await open(tester, screen.value, lang, size);
          tester.takeException();

          final extra = [
            for (final e in clipped(tester).entries)
              if (!fine.contains(e.key)) '«${e.value}»',
          ];
          expect(
            extra,
            isEmpty,
            reason: '«${screen.key}» мовою «$lang» $place обрізає те, '
                'що англійською вміщується:\n${extra.join('\n')}',
          );
        }
      }
    });
  }
}
