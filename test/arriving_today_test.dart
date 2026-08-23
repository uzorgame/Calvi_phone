import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/today/slot_card.dart';
import 'package:calvi/screens/today/today_screen.dart';

/// Картка дня відкривається плавно на справжньому екрані.
///
/// Перевірка не на макеті, а на самому дні: між `Arriving` і карткою там стоїть
/// ще кілька рівнів, і зламати плавність можна на кожному з них. Міряється
/// висота картки посеред відкриття: якщо вона вже дорівнює кінцевій, значить
/// анімації не було і картка стала на місце ривком.
void main() {
  testWidgets('картка на головному екрані росте, а не стрибає', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      AppScope(
        s: initialSettings(),
        set: (_) {},
        meds: const [],
        setMeds: (_) {},
        real: false,
        setReal: (_) {},
        child: MaterialApp(
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          locale: const Locale('uk'),
          theme: calviLightTheme,
          scrollBehavior: const CalviScroll(),
          home: TodayScreen(onSettings: () {}, onMeds: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Перша картка їжі на дні: заголовок у ній є завжди.
    final card = find.byType(SlotCard).first;
    final shut = tester.getSize(card).height;

    await tester.tap(find.descendant(of: card, matching: find.byType(GestureDetector)).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    final mid = tester.getSize(card).height;

    await tester.pumpAndSettle();
    final open = tester.getSize(card).height;

    expect(open, greaterThan(shut), reason: 'картка взагалі не відкрилась');
    expect(mid, greaterThan(shut), reason: 'через сто п\'ятдесят мілісекунд картка ще закрита');
    expect(mid, lessThan(open), reason: 'картка стала на місце ривком, без анімації');
  });
}
