import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/main.dart';
import 'package:calvi/screens/start/hello.dart';

/* Заставка запуску.
 *
 * Чотири речі, які мають триматись, і кожна вже колись ламалась деінде:
 *
 * 1. Вона зникає сама. Заставка, яка чекає дотику, це не заставка.
 * 2. Поки вона є, дотики до застосунку під нею не доходять.
 * 3. Її зникнення **не перебудовує** застосунок. Це те саме правило, через яке
 *    налаштування колись викидало на початок списку: шар, що зʼявляється або
 *    зникає посеред дерева, вбиває все, що під ним. Перевіряється буквально,
 *    звіркою елемента до і після.
 * 4. Кожен із пʼяти варіантів влазить у будь-який телефон будь-якою мовою.
 */
void main() {
  /// Застосунок під заставкою: одна кнопка, яка вміє рахувати, скільки разів по
  /// ній справді потрапили.
  Widget rig(void Function() onTap, {Hello? only}) => MaterialApp(
    theme: calviLightTheme,
    // Переклад тут потрібен: чотири з пʼяти заставок мають слова.
    localizationsDelegates: L.localizationsDelegates,
    supportedLocales: L.supportedLocales,
    locale: const Locale('uk'),
    home: HelloOverlay(
      only: only,
      shown: Future<void>.value(),
      child: Scaffold(
        body: Center(
          child: ElevatedButton(key: const Key('під'), onPressed: onTap, child: const Text('тиць')),
        ),
      ),
    ),
  );

  testWidgets('поки заставка на екрані, дотик до застосунку не доходить', (tester) async {
    var taps = 0;
    await tester.pumpWidget(rig(() => taps++, only: Hello.table));
    await tester.pump();

    expect(find.text('Calvi'), findsOneWidget, reason: 'заставки немає на першому кадрі');

    await tester.tap(find.byKey(const Key('під')), warnIfMissed: false);
    await tester.pump();
    expect(taps, 0, reason: 'дотик пройшов крізь заставку до кнопки, якої ще не видно');

    // Середина заставки: ще стоїть і досі не пускає.
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.tap(find.byKey(const Key('під')), warnIfMissed: false);
    await tester.pump();
    expect(taps, 0);

    await tester.pumpAndSettle();

    expect(find.text('Calvi'), findsNothing, reason: 'заставка не пішла сама, отже чогось чекає');

    await tester.tap(find.byKey(const Key('під')));
    await tester.pump();
    expect(taps, 1, reason: 'заставка пішла, а дотики так і не доходять');
  });

  testWidgets('застосунок під заставкою не перестворюється, коли вона йде', (tester) async {
    await tester.pumpWidget(rig(() {}, only: Hello.note));
    await tester.pump();

    /* Сам елемент, а не віджет: віджет перебудовується щокадру і про збереження
       стану не каже нічого. Елемент переживає перебудову і вмирає рівно тоді,
       коли дерево змінює форму. */
    final before = tester.element(find.byKey(const Key('під')));

    await tester.pumpAndSettle();

    expect(
      tester.element(find.byKey(const Key('під'))),
      same(before),
      reason: 'застосунок перестворено: заставка міняє форму дерева, а не лежить над ним',
    );
  });

  /* --- Кожен варіант, у кожній мові, темі й розмірі --- */

  Future<void> play(
    WidgetTester tester,
    Hello which, {
    required Locale locale,
    required ThemeData theme,
    required Size size,
    required double scale,
    required int atMs,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: locale,
        theme: theme,
        builder: (context, child) => MediaQuery.withNoTextScaling(
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
            child: child ?? const SizedBox(),
          ),
        ),
        home: HelloOverlay(
          key: ValueKey(which),
          only: which,
          shown: Future<void>.value(),
          child: const SizedBox.expand(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(Duration(milliseconds: atMs));
  }

  for (final (theme, tone) in [(calviLightTheme, 'світлій'), (calviDarkTheme, 'темній')]) {
    for (final (lang, locale) in [('українською', Locale('uk')), ('англійською', Locale('en'))]) {
      testWidgets('усі пʼять заставок влазять $lang у $tone темі', (tester) async {
        for (final (name, size, scale) in [
          ('на звичайному телефоні', const Size(390, 844), 1.0),
          ('на найменшому телефоні', const Size(320, 568), 1.0),
          ('зі збільшеним шрифтом', const Size(390, 844), 1.3),
          /* Найменший екран разом зі збільшеним шрифтом. Цього поєднання немає в
             загальній перевірці екранів, і для тижня воно якраз найгірше: сім
             підписів по три літери на 320 пікселях. Перевіряти окремо кожну з
             двох тісностей і не перевірити обидві разом означало б розминутись
             саме з тим випадком, заради якого перевірка й існує. */
          ('на найменшому зі збільшеним шрифтом', const Size(320, 568), 1.3),
        ]) {
          for (final which in Hello.values) {
            /* Три миті на кожен варіант: щойно почалось, усе вже на місці, і
               перший кадр зникання. Розкладка ламається саме на другій, але
               перевіряти лише її означало б проґавити переповнення, яке живе
               рівно доти, доки триває поява. */
            for (final atMs in [200, 1300, 1450]) {
              await play(
                tester,
                which,
                locale: locale,
                theme: theme,
                size: size,
                scale: scale,
                atMs: atMs,
              );
              expect(
                tester.takeException(),
                isNull,
                reason: 'заставка ${which.name} не влазить $name, $lang, у $tone темі, на $atMs мс',
              );
            }
          }
        }
      });
    }
  }

  testWidgets('назва стоїть у кожному варіанті', (tester) async {
    for (final which in Hello.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: calviLightTheme,
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          locale: const Locale('uk'),
          home: HelloOverlay(
            key: ValueKey(which),
            only: which,
            shown: Future<void>.value(),
            child: const SizedBox.expand(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));

      expect(
        find.text('Calvi'),
        findsOneWidget,
        reason:
            'у заставці ${which.name} немає назви: пʼять різних заставок без неї '
            'перестають бути заставками одного застосунку',
      );
      await tester.pumpAndSettle();
    }
  });

  /* Тут перевіряється лише підключення: що заставка справді стоїть над усім
   * застосунком і що вимикач її знімає.
   *
   * Її життя перевіряється вище, на підставному застосунку, і не випадково.
   * Заставка чекає на мить, коли перший кадр справді ляже на екран, а в
   * тестовому каркасі растеризації не існує взагалі: підставити цю мить можна
   * тільки ззовні, а тягнути таку підпорку крізь `CalviApp` заради одного тесту
   * означало б завести в бойовий код поле, потрібне тільки тесту. */
  testWidgets('справжній застосунок відкривається заставкою над собою', (tester) async {
    await tester.pumpWidget(const CalviApp(storage: false));
    await tester.pump();

    expect(find.byType(HelloOverlay), findsOneWidget);
    expect(
      find.descendant(of: find.byType(HelloOverlay), matching: find.byType(Navigator)),
      findsWidgets,
      reason: 'застосунок не під заставкою, отже вона не шар над ним, а щось інше',
    );
  });

  testWidgets('вимкнена заставка не зʼявляється зовсім', (tester) async {
    await tester.pumpWidget(const CalviApp(storage: false, hello: false));
    await tester.pump();

    expect(find.byType(HelloOverlay), findsNothing);
  });

  /* Вибір справді випадковий.
   *
   * Двадцять запусків підряд одного й того самого варіанта означали б, що
   * випадковості немає, а є забутий сталий вибір: помилка, яку видно тільки на
   * живому телефоні і тільки якщо довго відкривати застосунок. */
  testWidgets('за багато запусків випадають різні заставки', (tester) async {
    final seen = <Hello>{};
    for (var i = 0; i < 25 && seen.length < 3; i++) {
      await tester.pumpWidget(
        MaterialApp(
          key: ValueKey(i),
          theme: calviLightTheme,
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          locale: const Locale('uk'),
          home: HelloOverlay(key: ValueKey('run-$i'), child: const SizedBox.expand()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));

      // Сама сцена каже, ким вона є: ключем із назвою варіанта.
      for (final h in Hello.values) {
        if (find.byKey(ValueKey(h)).evaluate().isNotEmpty) seen.add(h);
      }
      await tester.pumpAndSettle();
    }

    expect(seen.length, greaterThanOrEqualTo(3), reason: 'за 25 запусків випало лише $seen');
  });

  /* Назви страв у «Записці» вміщаються цілком, без трикрапки.
   *
   * `MealRow` обрізає задовгу назву трикрапкою, і на екрані дня це правильно:
   * там назви пише людина, і вони бувають будь-які. Тут навпаки, назви наші
   * власні й одні на всіх, тому обрізана назва означає не довгий текст, а
   * недогляд. Українська стоїть впритул до числа, англійська має запас, і без
   * цієї перевірки будь-яка зміна шрифту чи ширини картки зʼїла б хвіст слова
   * так, що ніхто б не помітив. */
  for (final (lang, locale) in [('українською', Locale('uk')), ('англійською', Locale('en'))]) {
    testWidgets('назви страв у «Записці» не обрізаються $lang', (tester) async {
      /* Саме тут потрібен справжній шрифт, і тільки тут.
       *
       * Тестовий шрифт малює кожну літеру повним квадратом, тобто набагато
       * ширше за Onest: перевірки на переповнення від цього лише суворіші, і це
       * добре. Але питання «чи вміщається назва» на ньому не має сенсу: не
       * вміщається жодна. Тому Onest вантажиться саме в цю перевірку, а решта
       * файлу лишається на суворому квадратному. */
      /* Файл читається **синхронно**, і це не дрібниця. Усередині віджет-тесту
         час несправжній, і звичайне асинхронне читання диска не завершується
         ніколи: тест просто висить, поки його не вбʼє межа часу. Саме так він і
         повівся з першої спроби. */
      final font = FontLoader('Onest');
      for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
        final bytes = File('assets/fonts/Onest-$weight.ttf').readAsBytesSync();
        font.addFont(Future.value(ByteData.sublistView(bytes)));
      }
      await font.load();

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          locale: locale,
          theme: calviLightTheme,
          home: HelloOverlay(
            only: Hello.note,
            shown: Future<void>.value(),
            child: const SizedBox.expand(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1350));

      final l = L.of(tester.element(find.byType(HelloOverlay)));
      for (final title in [l.helloDishEggs, l.helloDishBread]) {
        final para = tester.renderObject<RenderParagraph>(find.text(title));
        expect(
          para.didExceedMaxLines,
          isFalse,
          reason: '«$title» не вміщається в картку і показується з трикрапкою',
        );
      }
    });
  }

  /* Усе встигає зʼявитись до початку зникання.
   *
   * Це головне число всієї заставки і єдине, що легко зіпсувати непомітно:
   * затримка, яка виходить за межу, дає найгірше з можливого, коли елемент
   * проступає вже крізь згасання, тобто блимає і зникає. Оком це майже не
   * ловиться, тому ловиться тут. */
  test('жодна поява не заходить у час зникання', () {
    const span = 2000;
    const leaveAt = 1400;

    /* Ті самі числа, що в `hello.dart`: початок і тривалість кожної появи.
       Список руками навмисно. Якби він читався з коду, тест перевіряв би, що
       код дорівнює сам собі. */
    const entrances = <(String, int, int)>[
      ('назва', 0, 700),
      ('стіл, остання страва', 5 * 80, 620),
      ('записка, бульбашка', 300, 480),
      ('записка, картка', 560, 560),
      ('записка, друга страва', 820 + 180, 360),
      ('колода, третя картка', 380 + 2 * 180, 560),
      ('тиждень, останній стовпчик', 380 + 6 * 70, 520),
      ('чисто, третій рядок', 460 + 2 * 170, 460),
    ];

    for (final (what, from, len) in entrances) {
      expect(
        from + len,
        lessThanOrEqualTo(leaveAt),
        reason: '«$what» доростає на ${from + len} мс, а зникання починається на $leaveAt',
      );
      expect(from + len, lessThan(span));
    }
  });
}
