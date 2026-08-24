import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/day.dart';
import 'package:calvi/main.dart';

import 'goldens.dart';

/// Кадр посеред перемикання дати.
///
/// Знімок, а не число: людина скаржилась саме на побачене, і побачити це можна
/// тільки очима. Дні лежали один на одному повністю непрозорими, і картки
/// подвоювались.
void main() {
  /* Годинник закріплений: без цього знімок розходився щодоби, бо в стрічці
     стоять числа місяця, і завтра вони інші. */
  setUp(() => dayClock = () => DateTime(2026, 8, 19, 12));
  tearDown(() => dayClock = DateTime.now);

  testWidgets('перехід між датами', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = const [Locale('uk')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const CalviApp(storage: false));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Почати'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.text('Далі'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Поки без входу'));
    await tester.pumpAndSettle();

    /* Сусідній день у стрічці: рівно те, що робить людина пальцем.
     *
     * Число береться із закріпленого годинника, а не зі справжнього. Тут стояв
     * `DateTime.now()`, і тест проходив лише того дня, коли знімок записали:
     * назавтра він тицяв у число, якого в стрічці немає, влучав у якесь інше і
     * порівнював знімок геть іншого екрана. */
    final strip = find.text('${dayClock().subtract(const Duration(days: 1)).day}');
    await tester.tap(strip.first);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    /* Знімок має сенс лише тоді, коли перехід справді йде: два дні в дереві.
       Ця перевірка працює на будь-якій системі, і на чужій машині лишається
       єдиною в тесті. */
    expect(find.text('Сніданок'), findsNWidgets(2), reason: 'перехід не почався, знімок ні про що');
    await matchesGolden(find.byType(MaterialApp), 'day_switch.png');
  });
}
