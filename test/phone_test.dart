import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/fixtures.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/shell.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/today/bottom_bar.dart';
import 'package:calvi/screens/today/hero_card.dart';

Widget _wrap(Widget child) => AppScope(
  s: initialSettings(),
  set: (_) {},
  meds: const [],
  setMeds: (_) {},
  child: MaterialApp(
    theme: calviLightTheme,
    scrollBehavior: const CalviScroll(),
    home: Scaffold(body: child),
  ),
);

/// Things that only showed themselves on a phone.
void main() {
  testWidgets('колода повертається на бік, коли жест забрала сторінка', (tester) async {
    tester.view.physicalSize = const Size(390, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _wrap(
        ListView(
          children: [
            HeroCard(day: dayFor(0), burned: dayFor(0).burned, goal: goalOf(initialSettings())),
            const SizedBox(height: 900),
          ],
        ),
      ),
    );
    await tester.pump();
    final was = tester.getRect(find.byType(HeroCard)).height;

    /* A drag that starts on the card and is taken over by the list never gets an
       end event. The card used to stay wherever the finger left it, and half a
       turn is a card standing edge on: invisible. */
    final grip = await tester.startGesture(tester.getCenter(find.byType(HeroCard)));
    await grip.moveBy(const Offset(0, -60));
    await tester.pump();
    await grip.cancel();
    await tester.pump(const Duration(milliseconds: 800));

    expect(
      tester.getRect(find.byType(HeroCard)).height,
      closeTo(was, 1),
      reason: 'картка лишилася перевернутою і зникла',
    );
  });

  testWidgets('верх панелі Нори заокруглений, коли чат відкритий', (tester) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _wrap(
        Align(
          alignment: Alignment.bottomCenter,
          child: BottomBar(
            slot: 'Обід',
            messages: const [],
            open: true,
            onOpen: (_) {},
            onClose: () {},
            onSend: (_) {},
            onCamera: () {},
            onVoice: () {},
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));

    /* The corners are cut, not merely painted: a rounded decoration rounds
       only what it draws itself, and anything the bar lays on top keeps its own
       square edge. The clip is what makes the corner close. */
    final clips = tester
        .widgetList<ClipRRect>(find.byType(ClipRRect))
        .where((w) => (w.borderRadius as BorderRadius?) != null)
        .map((w) => w.borderRadius as BorderRadius)
        .where((r) => r.topLeft.x > 0)
        .toList();

    expect(clips, isNotEmpty, reason: 'верх панелі нічим не обрізаний');
    expect(
      clips.first.topLeft.x,
      closeTo(clips.first.topRight.x, 0.01),
      reason: 'кути панелі різні: один заокруглений, другий ні',
    );
  });

  testWidgets('натискання відповідає одразу, не чекаючи арени жестів', (tester) async {
    var down = false;
    await tester.pumpWidget(
      _wrap(
        ListView(
          children: [
            CalviPress(
              onTap: () {},
              builder: (context, isDown) {
                down = isDown;
                return const SizedBox(width: 60, height: 60);
              },
            ),
            const SizedBox(height: 900),
          ],
        ),
      ),
    );
    await tester.pump();

    /* A tap recogniser inside a scrolling list holds its press back until it
       wins the arena, and a quick tap is over before that: the mark never
       moved. The raw pointer has no arena to wait for. */
    final touch = await tester.startGesture(tester.getCenter(find.byType(CalviPress)));
    await tester.pump();
    expect(down, isTrue, reason: 'натискання не показалося на першому ж кадрі');

    await touch.up();
    await tester.pump();
    expect(down, isFalse, reason: 'натискання не відпустилося');
  });
}
