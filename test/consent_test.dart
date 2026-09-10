import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'first_run.dart';

import 'package:calvi/main.dart';

/// Згода на непрочитане це не згода.
///
/// Під галочкою «Погоджуюсь з умовами» два слова, і кожне має відкривати
/// документ. Досі вони вели в браузер: людина йшла читати і поверталась у
/// знайомство, яке доводилось починати спочатку, а без мережі не поверталась
/// узагалі. Тепер текст піднімається аркушем поверх того самого екрана.
///
/// Сама галочка стоїть на реєстрації, а не на вході: згоду дають один раз,
/// коли акаунт заводять. Той, хто повертається, її вже дав, і питати вдруге
/// означало б ставити умову на дорозі до власного щоденника.
void main() {
  Future<void> toSignUp(WidgetTester tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('uk')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const CalviApp(storage: false, hello: false));
    await tester.pump(const Duration(seconds: 1));

    /* Вхід стоїть першим кроком, одразу за вітанням, тому йти до нього більше
       нікуди: воно догрується і саме його показує. */
    await welcomeOut(tester);

    expect(find.text('Вхід'), findsOneWidget, reason: 'не дійшли до входу');

    await tester.tap(find.text('Зареєструватись'));
    await tester.pumpAndSettle();

    expect(find.text('Заведімо акаунт'), findsOneWidget, reason: 'не дійшли до реєстрації');
  }

  testWidgets('умови відкриваються аркушем просто з екрана реєстрації', (tester) async {
    await toSignUp(tester);

    /* Фрагмент усередині складеного рядка, а не окремий віджет: звичайний
       find.text його не бачить. */
    await tester.tapOnText(find.textRange.ofSubstring('умовами користування'));
    await tester.pumpAndSettle();

    // Заголовок документа англійський: редакція одна, незалежно від мови застосунку.
    expect(find.text('Terms of Use'), findsOneWidget, reason: 'аркуш не піднявся');
    /* Найважливіший розділ документа, і саме його перевіряємо на місці. Тут
       стояв «Токени», тобто випадковий заголовок: він доводив, що аркуш не
       порожній, і мовчки зник разом із перейменуванням розділу. Медичне
       застереження перейменувати непомітно не вийде. */
    expect(
      find.text('No medical purpose'),
      findsOneWidget,
      reason: 'аркуш порожній або в ньому немає медичного застереження',
    );

    /* Реєстрація лишається під аркушем. Якби документ приїхав окремим екраном,
       людина втратила б те, з чого його відкрила. */
    expect(find.text('Заведімо акаунт'), findsOneWidget);
  });

  testWidgets('приватність відкривається тим самим шляхом', (tester) async {
    await toSignUp(tester);

    await tester.tapOnText(find.textRange.ofSubstring('політикою приватності'));
    await tester.pumpAndSettle();

    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.textContaining('Updated'), findsOneWidget);
  });
}
