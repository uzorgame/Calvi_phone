import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/main.dart';

/// Згода на непрочитане це не згода.
///
/// Під галочкою «Погоджуюсь з умовами» два слова, і кожне має відкривати
/// документ. Досі вони вели в браузер: людина йшла читати і поверталась у
/// знайомство, яке доводилось починати спочатку, а без мережі не поверталась
/// узагалі. Тепер текст піднімається аркушем поверх того самого екрана.
void main() {
  Future<void> toSignIn(WidgetTester tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('uk')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const CalviApp(storage: false, hello: false));
    await tester.pump(const Duration(seconds: 1));

    // Про тебе, Вага, Ціль, Темп, Спосіб життя, Норма.
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.text('Далі'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Збережімо це'), findsOneWidget, reason: 'не дійшли до входу');
  }

  testWidgets('умови відкриваються аркушем просто з екрана входу', (tester) async {
    await toSignIn(tester);

    /* Фрагмент усередині складеного рядка, а не окремий віджет: звичайний
       find.text його не бачить. */
    await tester.tapOnText(find.textRange.ofSubstring('умовами користування'));
    await tester.pumpAndSettle();

    expect(find.text('Умови користування'), findsOneWidget, reason: 'аркуш не піднявся');
    /* Найважливіший розділ документа, і саме його перевіряємо на місці. Тут
       стояв «Токени», тобто випадковий заголовок: він доводив, що аркуш не
       порожній, і мовчки зник разом із перейменуванням розділу. Медичне
       застереження перейменувати непомітно не вийде. */
    expect(
      find.text('Це не медичний застосунок'),
      findsOneWidget,
      reason: 'аркуш порожній або в ньому немає медичного застереження',
    );

    /* Екран входу лишається під аркушем. Якби документ приїхав окремим екраном,
       людина втратила б те, з чого його відкрила. */
    expect(find.text('Збережімо це'), findsOneWidget);
  });

  testWidgets('приватність відкривається тим самим шляхом', (tester) async {
    await toSignIn(tester);

    await tester.tapOnText(find.textRange.ofSubstring('політикою приватності'));
    await tester.pumpAndSettle();

    expect(find.text('Політика приватності'), findsOneWidget);
    expect(find.textContaining('Оновлено'), findsOneWidget);
  });
}
