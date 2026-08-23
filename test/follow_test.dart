import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/theme.dart';
import 'package:calvi/design/tokens.dart';
import 'package:calvi/screens/today/slot_card.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// The page comes down with the card it was asked to open.
///
/// Opening one at the foot of the day used to push what you just asked for
/// below the screen, and the only way to see it was to scroll by hand.
void main() {
  _middle();
  _visible();
  testWidgets('картка внизу списку сама підтягує сторінку', (tester) async {
    tester.view.physicalSize = const Size(390, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var open = false;
    final scroll = ScrollController();
    addTearDown(scroll.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: ListView(
              controller: scroll,
              // The room the assistant bar takes over the foot of the day.
              padding: const EdgeInsets.only(bottom: CalviSize.barRoom),
              children: [
                const SizedBox(height: 900),
                SlotCard(
                  icon: 'ruler',
                  title: 'Вимірювання',
                  sub: 'останнє 5 днів тому',
                  badge: '2 заміри',
                  open: open,
                  onToggle: () => setState(() => open = !open),
                  child: const SizedBox(height: 260),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    /* Right to the foot, the way a person reaches the last card. Twice: the
       first settle leaves the view at its default size, and the extent it
       reports there is not the extent of a phone-sized screen. */
    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pumpAndSettle();
    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pumpAndSettle();
    final before = scroll.offset;

    await tester.tap(find.text('Вимірювання'));
    await tester.pumpAndSettle();

    expect(
      scroll.offset,
      greaterThan(before + 100),
      reason: 'сторінка не поїхала за карткою, що розкрилась',
    );
    /* The whole card, and clear of the bar: its foot has to end above the room
       the bar covers, not merely inside the screen. */
    final card = tester.getRect(find.byType(SlotCard));
    expect(
      card.bottom,
      lessThanOrEqualTo(600 - CalviSize.barRoom + 1),
      reason: 'низ картки лишився під смугою помічника',
    );
    expect(card.top, greaterThanOrEqualTo(-1), reason: 'верх картки виїхав за екран');
  });
}

/// The same when the card is not the last one and the page is not at the foot.
void _middle() {
  testWidgets('картка посеред списку теж стає видною цілком', (tester) async {
    tester.view.physicalSize = const Size(390, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var open = false;
    final scroll = ScrollController();
    addTearDown(scroll.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: ListView(
              controller: scroll,
              padding: const EdgeInsets.only(bottom: CalviSize.barRoom),
              children: [
                const SizedBox(height: 700),
                SlotCard(
                  icon: 'ruler',
                  title: 'Вимірювання',
                  sub: 'останнє 5 днів тому',
                  badge: '2 заміри',
                  open: open,
                  onToggle: () => setState(() => open = !open),
                  child: const SizedBox(height: 300),
                ),
                const SizedBox(height: 700),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    /* Parked so the card's head is just inside the screen and there is nothing
       under it yet: exactly the position a person taps from. */
    scroll.jumpTo(660);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Вимірювання'));
    await tester.pumpAndSettle();

    final card = tester.getRect(find.byType(SlotCard));
    expect(
      card.bottom,
      lessThanOrEqualTo(600 - CalviSize.barRoom + 1),
      reason: 'низ картки лишився під смугою помічника',
    );
    expect(card.top, greaterThanOrEqualTo(-1), reason: 'верх картки виїхав за екран');
  });
}

/// A card already in plain sight is left where it is.
void _visible() {
  testWidgets('картка, яку й так видно, не тягне сторінку до себе', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var open = false;
    final scroll = ScrollController();
    addTearDown(scroll.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: SingleChildScrollView(
              controller: scroll,
              padding: const EdgeInsets.only(bottom: CalviSize.barRoom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 200),
                  SlotCard(
                    icon: 'ruler',
                    title: 'Обід',
                    sub: '2 записи',
                    badge: '346 ккал',
                    open: open,
                    onToggle: () => setState(() => open = !open),
                    child: const SizedBox(height: 200),
                  ),
                  const SizedBox(height: 900),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The card sits in the middle of the screen and stays there once opened:
    // it fits, so there is nothing to correct.
    final before = scroll.offset;
    await tester.tap(find.text('Обід'));
    await tester.pumpAndSettle();

    expect(
      scroll.offset,
      closeTo(before, 1),
      reason: 'сторінка поїхала, хоча картка й так була видна цілком',
    );
  });
}
