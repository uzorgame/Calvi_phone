import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/today/slot_card.dart';

/// Поява картки і те, що буває після неї.
///
/// Картка, яка щойно з'явилась, відкривалась ривком: без плавного росту, і не
/// щоразу, а тільки після появи. Причина в дереві. `Arriving` тримає картку під
/// шаром обгорток, поки грає поява, і віддає її голою, коли та добігла. Голе
/// дерево і обгорнуте це різні дерева, тож на першому ж перемальовуванні після
/// появи Flutter будує картку заново. Разом із нею народжується заново і її
/// стан, а неявні анімації відлічують рух від того, що бачили минулого разу:
/// новонароджена не бачила нічого і одразу стоїть у кінці.
///
/// Перемальовування після появи це і є той самий дотик, яким картку відкривають.
void main() {
  Widget page(bool open, VoidCallback toggle, {required bool play}) => MaterialApp(
    theme: calviLightTheme,
    home: Scaffold(
      body: SingleChildScrollView(
        child: Arriving(
          play: play,
          child: SlotCard(
            icon: 'banana',
            title: 'Сніданок',
            sub: 'порожньо',
            badge: '0',
            open: open,
            onToggle: toggle,
            child: const SizedBox(height: 200),
          ),
        ),
      ),
    ),
  );

  Future<double> heightAfterOpen(WidgetTester tester, {required bool play}) async {
    var open = false;
    late StateSetter set;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          set = setState;
          return page(open, () => setState(() => open = true), play: play);
        },
      ),
    );
    // Поява добігає до кінця, і саме тут дерево міняє форму.
    await tester.pumpAndSettle();

    set(() => open = true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    return tester.getSize(find.byType(SlotCard)).height;
  }

  testWidgets('картка, що з\'явилась, відкривається так само плавно', (tester) async {
    final midPlayed = await heightAfterOpen(tester, play: true);
    final midStill = await heightAfterOpen(tester, play: false);

    await tester.pumpAndSettle();
    final full = tester.getSize(find.byType(SlotCard)).height;

    expect(midStill, lessThan(full), reason: 'картка не росте зовсім');
    expect(
      midPlayed,
      lessThan(full),
      reason: 'картка після появи відкривається ривком, без анімації',
    );
    expect(midPlayed, closeTo(midStill, 1), reason: 'росте не так, як решта карток');
  });
}
