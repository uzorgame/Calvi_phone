import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/icons.dart';
import 'package:calvi/design/shell.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/recipes/recipes_screen.dart';

/* Книга рецептів просить Нору тією самою смугою, що й день.
 *
 * Кнопка «Попросити рецепт у Нори» і аркуш «Що є на кухні?» пішли: писати Норі
 * в застосунку вміють в одному місці, унизу екрана. Тест ходить демо-книгою, бо
 * сервера тут немає, але дорога від питання до відкритого рецепта та сама, що в
 * бойовому режимі: питання, кільце очікування, страви рядками, дотик, книга.
 */
Widget _wrap() => AppScope(
  s: initialSettings(),
  set: (_) {},
  meds: const [],
  setMeds: (_) {},
  child: MaterialApp(
    localizationsDelegates: L.localizationsDelegates,
    supportedLocales: L.supportedLocales,
    locale: const Locale('uk'),
    theme: calviLightTheme,
    home: const RecipesScreen(),
  ),
);

/// Поле смуги: єдине, у яке тут пишуть.
Finder get _field => find.byType(TextField);

void main() {
  testWidgets('обкладинка відсилає до Нори, а не тисне кнопкою', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Нора тобі допоможе створити рецепт'), findsOneWidget);
    expect(
      find.text('Попросити рецепт у Нори'),
      findsNothing,
      reason: 'кнопка мала поступитись рядку і смузі внизу',
    );
  });

  testWidgets('у книзі немає ні камери, ні пігулки картки', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate((w) => w is CalviIcon && w.name == 'camera'),
      findsNothing,
      reason: 'знімати нічого: страви ще не існує',
    );
    expect(
      find.textContaining('Записую в'),
      findsNothing,
      reason: 'звідси в щоденник не йде нічого',
    );
  });

  testWidgets('питання дає страви рядками, дотик відкриває рецепт', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    // Порожня розмова вітається своїм, а не словами щоденника.
    await tester.tap(_field);
    await tester.pumpAndSettle();
    expect(find.textContaining('що є на кухні'), findsOneWidget);

    await tester.enterText(_field, 'курка, броколі, рис');
    await tester.testTextInput.receiveAction(TextInputAction.send);

    /* Сказане стає в розмову одразу, ще до відповіді. Перевіряється саме тут:
       коли Нора відповість стравами, кімната домотається до них, і питання
       піде вгору за край, як і має. */
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('курка, броколі, рис'), findsOneWidget, reason: 'сказане не стало в розмову');

    await tester.pumpAndSettle();
    expect(find.textContaining('Обери страву'), findsOneWidget, reason: 'Нора не принесла страв');

    final dish = find.text('Тепла миска з куркою і рисом');
    expect(dish, findsOneWidget);

    await tester.tap(dish);
    await tester.pumpAndSettle();

    // Обране одразу відкрилось: шукати його в списку людині не треба.
    expect(find.text('На порцію'), findsOneWidget, reason: 'рецепт не відкрився');
    expect(find.textContaining('Тепла миска'), findsWidgets);
  });

  testWidgets('обране лягає в книгу і лишається там', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(_field);
    await tester.pumpAndSettle();
    await tester.enterText(_field, 'курка, броколі, рис');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Тепла миска з куркою і рисом'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CalviBack).first);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Тепла миска'),
      findsOneWidget,
      reason: 'обрана страва мусить стати карткою книги',
    );
  });

  /* Страви на вибір мусять бути видні, а не лежати нижче краю кімнати.
   *
   * Відповідь приходить у ту саму бульбашку, у якій щойно крутилось кільце:
   * кількість повідомлень не міняється, а висота стрибає, бо під текстом
   * розкривається картка зі стравами. Доти кімната лишалась там, де стояла, і
   * людина бачила «Ось що можна приготувати», а самих страв ні. */
  testWidgets('страви на вибір видно в кімнаті, а не за її краєм', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    // Двічі, бо з одним повідомленням розмова ще вміщається і без домотування.
    for (var i = 0; i < 2; i++) {
      await tester.tap(_field);
      await tester.pumpAndSettle();
      await tester.enterText(_field, 'курка, броколі, рис');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();
    }

    final room = tester.getRect(find.byKey(const Key('chat-room')));
    final rows = find.text('Тепла миска з куркою і рисом');
    final shown = [
      for (var n = 0; n < rows.evaluate().length; n++)
        if (tester.getRect(rows.at(n)).width < room.width - 100) tester.getRect(rows.at(n)),
    ];

    expect(shown, isNotEmpty, reason: 'рядка страви немає зовсім');
    expect(
      shown.any((r) => r.top >= room.top && r.bottom <= room.bottom),
      isTrue,
      reason: 'страви лежать за краєм кімнати: домотування не спрацювало',
    );
  });

  /* Та сама страва, узята двічі, це дві картки з різними номерами.
   *
   * У вітрині номер дає не сервер, а мить вибору. Заготовлена трійка має сталі
   * номери, а список ключується саме номером: два однакові ключі в одному стосі
   * це вже не косметика. */
  testWidgets('та сама страва двічі дає дві різні картки', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    for (var i = 0; i < 2; i++) {
      await tester.tap(_field);
      await tester.pumpAndSettle();
      await tester.enterText(_field, 'курка, броколі, рис');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();

      // Рядок розмови вужчий за картку книги: обираємо саме його.
      final rows = find.text('Тепла миска з куркою і рисом');
      for (var n = 0; n < rows.evaluate().length; n++) {
        if (tester.getRect(rows.at(n)).width < 520) {
          await tester.tap(rows.at(n));
          break;
        }
      }
      await tester.pumpAndSettle();
      expect(find.text('На порцію'), findsOneWidget, reason: 'коло $i: рецепт не відкрився');

      await tester.tap(find.byType(CalviBack).first);
      await tester.pumpAndSettle();
    }

    final keys = [
      for (final el in find.byWidgetPredicate((w) => w.key is ValueKey<String>).evaluate())
        if ((el.widget.key as ValueKey<String>).value.startsWith('0:'))
          (el.widget.key as ValueKey<String>).value,
    ];
    expect(keys.length, 8, reason: 'шість демо-рецептів і дві взяті страви');
    expect(keys.toSet().length, keys.length, reason: 'два однакові ключі в одному стосі');
  });

  testWidgets('розмова переходить на відкриту страву', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.textContaining('Скумбрія'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Скумбрія'));
    await tester.pumpAndSettle();

    // Порожня розмова на сторінці страви вітається самою стравою.
    await tester.tap(_field);
    await tester.pumpAndSettle();
    expect(find.textContaining('Питай про «Скумбрія'), findsOneWidget);

    await tester.enterText(_field, 'чим замінити картоплю?');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();

    /* Відповідь про готування, а не нові страви: страву вже вибрано, і
       пропонувати натомість інші означало б не почути питання. */
    expect(find.textContaining('Заміни без втрат'), findsOneWidget);
    expect(find.textContaining('Обери страву'), findsNothing);
  });
}
