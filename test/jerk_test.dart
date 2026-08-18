import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/theme.dart';
import 'package:calvi/design/tokens.dart';
import 'package:calvi/screens/today/slot_card.dart';

/// Opening one card closes the other, and the day is a list: what shuts above
/// or below you moves the ground under your feet. The page has to ride that out
/// rather than snap.
void main() {
  testWidgets('відкриття верхньої картки знизу не смикає сторінку', (tester) async {
    tester.view.physicalSize = const Size(390, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // The lower card starts open, the way it is after a person opened it.
    var openId = 'low';
    final scroll = ScrollController();
    addTearDown(scroll.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: calviLightTheme,
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            /* The card being opened is off screen, which is the whole point of
               the case, so the tap is made where a tap can land. */
            floatingActionButton: FloatingActionButton(
              onPressed: () => setState(() => openId = 'high'),
              child: const Text('вгору'),
            ),
            body: SingleChildScrollView(
              controller: scroll,
              padding: const EdgeInsets.only(bottom: CalviSize.barRoom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SlotCard(
                    icon: 'ruler',
                    title: 'Верхня',
                    sub: 'угорі списку',
                    badge: '1',
                    open: openId == 'high',
                    onToggle: () => setState(() => openId = 'high'),
                    child: const SizedBox(height: 300),
                  ),
                  const SizedBox(height: 500),
                  SlotCard(
                    icon: 'ruler',
                    title: 'Нижня',
                    sub: 'внизу списку',
                    badge: '2',
                    open: openId == 'low',
                    onToggle: () => setState(() => openId = 'low'),
                    child: const SizedBox(height: 300),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pumpAndSettle();
    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pumpAndSettle();

    await tester.tap(find.text('вгору'));

    /* Frame by frame, the whole way. What reads as a jerk is not speed but a
       change of direction: the page was travelling one way, the end of the list
       moved under it, and it was yanked back the other. So the run is checked
       for reversals rather than for how fast it goes. */
    var last = scroll.offset;
    var wentUp = false;
    var wentDown = false;
    var worst = 0.0;
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      final step = scroll.offset - last;
      if (step > 1) {
        wentDown = true;
        if (wentUp && step > worst) worst = step;
      }
      if (step < -1) wentUp = true;
      last = scroll.offset;
    }
    await tester.pumpAndSettle();

    expect(
      wentUp && wentDown,
      isFalse,
      reason: 'сторінка розвернулась посеред руху і смикнулась на $worst пікселів',
    );

    final card = tester.getRect(find.byType(SlotCard).first);
    expect(card.top, greaterThanOrEqualTo(-1), reason: 'верхня картка не в кадрі');
  });
}
