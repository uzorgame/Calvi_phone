import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/chat.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/today/bottom_bar.dart';
import 'package:calvi/l10n/app_localizations.dart';

Widget _wrap({
  required bool open,
  required ValueChanged<bool> onOpen,
  VoidCallback? onClose,
  int? tokensLeft,
}) =>
    MaterialApp(
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      locale: const Locale('uk'),
      theme: calviLightTheme,
      home: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Color(0xFFEEEEEE))),
            Positioned.fill(
              child: BottomBar(
                slot: 'Обід',
                tokensLeft: tokensLeft,
                open: open,
                onOpen: onOpen,
                onClose: onClose ?? () {},
                onSend: (_) {},
                onCamera: () {},
                onHold: (_, _) {},
                onLetGo: () {},
                messages: const [],
              ),
            ),
          ],
        ),
      ),
    );

void main() {
  testWidgets('тап по смузі підіймає кімнату без клавіатури', (tester) async {
    bool? focused;
    await tester.pumpWidget(_wrap(open: false, onOpen: (f) => focused = f));

    /* The room is measured even while shut: a height cannot be animated from
       nothing to a size nobody has worked out yet. So the check is that it takes
       up no room, not that it is absent from the tree. */
    expect(tester.getSize(find.byKey(const Key('chat-room'))).height, 0);

    // The slot line is rich text, so the tap goes by position: what is being
    // checked is the strip of bar above the field.
    final field = tester.getRect(find.byType(TextField));
    await tester.tapAt(Offset(field.center.dx, field.top - 14));
    await tester.pump();
    expect(focused, false, reason: 'смуга відкриває кімнату, але не просить клавіатуру');
  });

  testWidgets('тап по полю відкриває і просить клавіатуру', (tester) async {
    bool? focused;
    await tester.pumpWidget(_wrap(open: false, onOpen: (f) => focused = f));

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(focused, true);
  });

  testWidgets('каретка в полі підіймає кімнату, хай як вона там опинилась', (tester) async {
    bool? focused;
    await tester.pumpWidget(_wrap(open: false, onOpen: (f) => focused = f));

    /* Not a tap: the platform can put the caret in the field on its own, and on
       the phone the tap itself was being eaten before it reached the field. What
       raises the room is the caret being there. */
    final field = tester.widget<TextField>(find.byType(TextField));
    field.focusNode!.requestFocus();
    await tester.pump();

    expect(focused, true, reason: 'фокус у полі не підняв чат');
  });

  testWidgets('відкрита кімната несе привітання Нори', (tester) async {
    await tester.pumpWidget(_wrap(open: true, onOpen: (_) {}, tokensLeft: 19));
    await tester.pumpAndSettle();

    expect(find.text('Нора'), findsNWidgets(2), reason: 'заголовок кімнати і підказка поля');
    expect(find.text('Пиши як кажеш.'), findsOneWidget);
    expect(find.text('19'), findsOneWidget, reason: 'залишок токенів, одне число без знаменника');
  });

  testWidgets('поки сервер не відповідав, числа немає зовсім', (tester) async {
    await tester.pumpWidget(_wrap(open: true, onOpen: (_) {}));
    await tester.pumpAndSettle();

    /* Не нуль, а порожнє місце: нуль на старті читався б як «токени
       скінчились», хоча насправді про баланс ще нічого не відомо. */
    expect(find.text('0'), findsNothing);
  });

  testWidgets('тап поза чатом його згортає', (tester) async {
    var closed = false;
    await tester.pumpWidget(_wrap(open: true, onOpen: (_) {}, onClose: () => closed = true));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(200, 80));
    await tester.pump();
    expect(closed, true, reason: 'завіса має ловити тап');
  });
  testWidgets('кімната домотується до нового повідомлення', (tester) async {
    /* The list is appended to in place, so the widget the room compares against
       is the same object it already holds. A length check against the previous
       widget is always false, and the room used to sit still. */
    final messages = <Msg>[for (var i = 0; i < 12; i++) msg(from: MsgFrom.me, text: 'рядок ')];

    late StateSetter refresh;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, set) {
              refresh = set;
              return Stack(
                children: [
                  Positioned.fill(
                    child: BottomBar(
                      slot: 'Обід',
                      open: true,
                      onOpen: (_) {},
                      onClose: () {},
                      onSend: (_) {},
                      onCamera: () {},
                      onHold: (_, _) {},
                      onLetGo: () {},
                      messages: messages,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final room = tester.widget<ListView>(
      find.descendant(of: find.byType(BottomBar), matching: find.byType(ListView)),
    );
    final before = room.controller!.offset;

    messages.add(msg(from: MsgFrom.nora, text: 'відповідь'));
    refresh(() {});
    await tester.pumpAndSettle();

    expect(
      room.controller!.offset,
      greaterThan(before),
      reason: 'нова відповідь має бути тією, яку видно',
    );
  });
}
