import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/start/start_screen.dart';

/* Норма рахується з відповідей, а не з прикладу.
 *
 * Екран «Твоя норма» показує чотири рядки того, що Нора «читає»: зріст, вагу,
 * вік і спосіб життя. Виглядають вони як текст, і саме тому їх легко колись
 * забити константами, які збігаються зі стандартними значеннями анкети: на
 * екрані буде правильно, а насправді неправда, і помітить це перша ж людина
 * зростом не сто сімдесят вісім.
 *
 * Тому перевірка міняє відповідь і дивиться, чи змінився рядок.
 */
void main() {
  Future<void> open(WidgetTester tester, int step) async {
    tester.view.physicalSize = const Size(390, 900);
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
    await tester.pump();
  }

  testWidgets('прочитані рядки беруться з відповідей людини', (tester) async {
    // Крок «Спосіб життя»: звідси одним дотиком міняється те, що потім читає
    // Нора, і одним «Далі» видно результат.
    await open(tester, 6);

    await tester.tap(find.text('Сидячий'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Далі'));
    await tester.pump();

    /* Півсекунди: рядки заходять із затримкою за своїм номером, і останній
       зʼявляється приблизно на сімсот міліcекундах. Далі йде саме число. */
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('Сидячий'), findsOneWidget, reason: 'спосіб життя той, який обрали');
    expect(find.text('Зріст 178 см'), findsOneWidget);
    expect(find.text('Вага 80 кг'), findsOneWidget, reason: 'без нульового хвоста');
    expect(find.text('Вік 26 років'), findsOneWidget);

    /* І поки вона рахує, іти нема куди: кнопки немає взагалі. */
    expect(find.text('Далі'), findsNothing, reason: 'кнопка приходить після числа');

    // А після рахунку рядки йдуть, і на їхнє місце стає результат.
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(find.text('Зріст 178 см'), findsNothing);
    expect(find.text('ккал на день'), findsOneWidget);
    expect(find.text('Далі'), findsOneWidget);
  });

  testWidgets('інша активність дає інший рядок', (tester) async {
    await open(tester, 6);

    await tester.tap(find.text('Дуже висока'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Далі'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('Дуже висока'), findsOneWidget);
    expect(find.text('Сидячий'), findsNothing);

    // Домотати таймери, щоб тест не завершився з живим годинником.
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();
  });
}
