import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/today/slot_card.dart';
import 'package:calvi/screens/today/today_screen.dart';

/// День влазить у телефон, а не вивалюється з нього.
///
/// Переповнений ряд це смугаста жовто-чорна стрічка поверх картки, і бачить її
/// не розробник, а людина. Знайшлось воно саме так: рядок «грами, білки, жири,
/// вуглеводи» під стравою стоїть у колонці завширшки півтораста пікселів і не
/// поступається нікому, тож на трицифрових числах вилазив за край.
///
/// Міряється на двох телефонах і з двома розмірами шрифта, бо системний шрифт
/// збільшує кожен другий, а найменший телефон досі продають.
void main() {
  Future<void> day(WidgetTester tester, {required Size size, required double scale}) async {
    tester.view.physicalSize = size;
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
          builder: (context, child) => MediaQuery.withNoTextScaling(
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
          ),
          home: TodayScreen(onSettings: () {}, onMeds: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final (name, size, scale) in [
    ('на звичайному телефоні', const Size(390, 844), 1.0),
    ('на найменшому телефоні', const Size(320, 568), 1.0),
    ('зі збільшеним шрифтом', const Size(390, 844), 1.3),
  ]) {
    testWidgets('день влазить $name', (tester) async {
      await day(tester, size: size, scale: scale);
      expect(tester.takeException(), isNull);
    });

    testWidgets('відкриті картки дня влазять $name', (tester) async {
      await day(tester, size: size, scale: scale);

      /* Закрита картка ховає майже все, що в ній є. Переповнення живе всередині,
         тому кожну треба відкрити: інакше перевірка каже «влазить» про те, чого
         на екрані немає. */
      for (var i = 0; i < tester.widgetList(find.byType(SlotCard)).length; i++) {
        final card = find.byType(SlotCard).at(i);
        await tester.ensureVisible(card);
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(of: card, matching: find.byType(GestureDetector)).first,
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'картка №${i + 1} переповнена');
      }
    });
  }
}
