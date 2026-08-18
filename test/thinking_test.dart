import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/chat.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/today/bottom_bar.dart';
import 'package:calvi/screens/today/plate_strip.dart';

/// Чат, який не виглядає зламаним, поки Нора думає.
///
/// Розбір знімка триває секунди, а іноді й довше. Порожній чат у цей час
/// читається як «залагало», і людина тисне ще раз, платячи вдруге за ту саму
/// роботу. Тому очікування це не значок збоку, а те саме повідомлення Нори, ще
/// без слів: коли слова приходять, бульбашка доростає з кільця.
void main() {
  Widget bar(List<Msg> messages) => MaterialApp(
    theme: calviLightTheme,
    home: Scaffold(
      body: BottomBar(
        slot: 'Обід',
        messages: messages,
        onSend: (_) {},
        onCamera: () {},
        onVoice: () {},
        open: true,
        onOpen: (_) {},
        onClose: () {},
      ),
    ),
  );

  testWidgets('поки Нора думає, у чаті крутиться кільце', (tester) async {
    await tester.pumpWidget(
      bar([
        msg(from: MsgFrom.me, text: 'два яйця'),
        msg(from: MsgFrom.nora, text: '', pending: true),
      ]),
    );
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(Thinking), findsOneWidget);
    expect(find.text('думаю'), findsOneWidget);
  });

  testWidgets('відповідь приходить у ту саму бульбашку', (tester) async {
    /* Ключ у того самого повідомлення, тому бульбашка не зникає і не зʼявляється
       заново, а міняє вміст. Саме на цьому тримається переростання. */
    final waiting = msg(from: MsgFrom.nora, text: '', pending: true);

    await tester.pumpWidget(bar([msg(from: MsgFrom.me, text: 'борщ'), waiting]));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(Thinking), findsOneWidget);

    await tester.pumpWidget(
      bar([
        msg(from: MsgFrom.me, text: 'борщ'),
        waiting.answered(text: 'Записала борщ.'),
      ]),
    );
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(Thinking), findsNothing, reason: 'кільце лишилось поруч із відповіддю');
    expect(find.text('Записала борщ.'), findsOneWidget);
  });

  testWidgets('числа страви стоять смужкою, а не в тексті', (tester) async {
    await tester.pumpWidget(
      bar([
        msg(
          from: MsgFrom.nora,
          text: 'Записала млинці.',
          plate: const MealPlate(
            name: 'Млинці',
            grams: 210,
            kcal: 430,
            protein: 11,
            fat: 14,
            carbs: 66,
          ),
        ),
      ]),
    );
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(PlateStrip), findsOneWidget);
    expect(find.text('430'), findsOneWidget);
    expect(find.text('за 210 г'), findsOneWidget);

    /* Головне тут: число не вплетене в речення. Текст Нори лишається мовою, а
       все, що вимірюється, живе окремо. */
    expect(find.textContaining('430 ккал'), findsNothing);
  });

  testWidgets('смужка не вилазить за край бульбашки', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      bar([
        msg(
          from: MsgFrom.nora,
          text: 'Схоже на млинці з чорницею і медом.',
          plate: const MealPlate(
            name: 'Млинці',
            grams: 210,
            kcal: 1430,
            protein: 111,
            fat: 114,
            carbs: 166,
          ),
        ),
      ]),
    );
    await tester.pump(const Duration(milliseconds: 600));

    final strip = tester.getRect(find.byType(PlateStrip));
    expect(strip.left, greaterThanOrEqualTo(0));
    expect(strip.right, lessThanOrEqualTo(390), reason: 'смужка випирає за екран');
    expect(tester.takeException(), isNull, reason: 'смужка переповнила рядок');
  });

  testWidgets('записане Норою показується числами, а не самим словом', (tester) async {
    /* «Записала яєчню» без жодної цифри це половина відповіді, і саме та
       половина, заради якої все це робиться: людина хоче бачити, скільки саме
       їй зарахували. */
    await tester.pumpWidget(
      bar([
        msg(from: MsgFrom.me, text: 'яєчня'),
        msg(
          from: MsgFrom.nora,
          text: 'Записала яєчню на сніданок.',
          plate: const MealPlate(
            name: 'яєчня',
            grams: 110,
            kcal: 216,
            protein: 14,
            fat: 17,
            carbs: 1,
          ),
        ),
      ]),
    );
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(PlateStrip), findsOneWidget);
    expect(find.text('216'), findsOneWidget);
    expect(find.text('за 110 г'), findsOneWidget);
  });

  testWidgets('порожнє повідомлення без кільця не малює порожньої бульбашки', (tester) async {
    await tester.pumpWidget(bar([msg(from: MsgFrom.nora, text: 'Готово.')]));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(Thinking), findsNothing);
    expect(find.byType(PlateStrip), findsNothing);
    expect(find.text('Готово.'), findsOneWidget);
  });
}
