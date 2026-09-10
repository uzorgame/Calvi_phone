import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/main.dart';
import 'package:calvi/screens/start/start_screen.dart';

import 'first_run.dart';

/* Шапка «Старту» і екран «Ласкаво просимо».
 *
 * Три речі, які легко зламати мовчки. Мова в кутку шапки: без неї той, хто
 * відкрив застосунок і побачив чужу мову, проходить анкету навпомацки, бо з
 * першого екрана в налаштування не дістатись. Документи в іншому кутку: згоду
 * дали на реєстрації, і прочитати те, на що погодились, треба вміти там же, а
 * не колись потім. І сам екран вітання, який на маленькому телефоні мусить
 * поміститись цілком: гортати на ньому нема чого, а кнопка нижче краю читалась
 * би як відсутня.
 */
void main() {
  Future<void> open(WidgetTester tester, int step, {Size size = const Size(390, 844)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        scrollBehavior: const CalviScroll(),
        home: StartScreen(step: step, onFinish: (_) {}),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('вітання стоїть другим кроком і веде до першого питання', (tester) async {
    await open(tester, 1);

    expect(find.text('Ласкаво просимо в'), findsOneWidget);
    expect(find.text('Calvi'), findsOneWidget);
    expect(find.text('Почати'), findsOneWidget);

    await tester.tap(find.text('Почати'));
    await tester.pumpAndSettle();

    expect(find.text('Про тебе'), findsOneWidget, reason: 'кнопка веде на перше питання');
  });

  testWidgets('вітання вміщається на малому екрані цілком', (tester) async {
    // Найменший телефон, який ми тримаємо: iPhone SE.
    await open(tester, 1, size: const Size(320, 568));

    expect(tester.takeException(), isNull, reason: 'екран не вилазить за краї');
    expect(find.text('Почати'), findsOneWidget);
  });

  testWidgets('на вітанні стрілки назад немає, є документи', (tester) async {
    await open(tester, 1);

    /* Повертати з вітання нема куди: акаунт уже створено, і стрілка обіцяла б
       скасувати те, чого скасувати не можна. */
    expect(find.bySemanticsLabel('Назад'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Документи'));
    await tester.pumpAndSettle();

    expect(find.text('Умови користування'), findsOneWidget);
    expect(find.text('Політика приватності'), findsOneWidget);

    await tester.tap(find.text('Умови користування'));
    await tester.pumpAndSettle();

    // Заголовок документа англійський: редакція одна, незалежно від мови.
    expect(find.text('Terms of Use'), findsOneWidget, reason: 'аркуш не піднявся');
  });

  testWidgets('мова перемикається просто з шапки, до першого питання', (tester) async {
    // Шапка на всіх кроках одна, тому годиться будь-який, крім нульового: на
    // ньому «Старт» ще догрує заставку і шапки не показує.
    await open(tester, 1);

    /* Код мови, а не назва: на коло в шапці назва не влазить, а «UK» читають
       як «зараз тут ця мова». */
    expect(find.text('UK'), findsOneWidget);

    await tester.tap(find.text('UK'));
    await tester.pumpAndSettle();

    expect(find.text('English'), findsOneWidget);
    expect(find.text('Português do Brasil'), findsOneWidget);
    expect(find.text('Українська'), findsOneWidget);
    // Рядка «Мова пристрою» в списку немає: режим лишився, рядок пішов.
    expect(find.text('Мова пристрою'), findsNothing);
  });

  testWidgets('обрана в шапці мова міняє застосунок одразу', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = const [Locale('uk')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const CalviApp(storage: false, hello: false));
    await tester.pump(const Duration(seconds: 1));
    await welcomeOut(tester);

    expect(find.text('Вхід'), findsOneWidget);

    await tester.tap(find.text('UK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    /* Вибір іде в той самий профіль, що й у налаштуваннях: обрана на першому
       екрані, вона лишається обраною далі, а не питається вдруге. */
    // Двічі: заголовок сторінки і кнопка під полями.
    expect(find.text('Sign in'), findsWidgets, reason: 'застосунок не перейшов на англійську');
    expect(find.text('EN'), findsOneWidget, reason: 'кнопка не показує нову мову');
  });
}
