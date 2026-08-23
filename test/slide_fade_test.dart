import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/slide.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// Дві сторінки не мають бути видні одночасно.
///
/// День не має власного тла, а сторінки лежали одна на одній повністю
/// непрозорими, зсунуті на двадцять шість пікселів: людина перемикала дату і
/// бачила два дні разом, картка на картці.
void main() {
  /// Найбільша непрозорість серед сторінок, яких зараз не видно як головну.
  double ghost(WidgetTester tester, String leaving) {
    final layers = tester.widgetList<Opacity>(
      find.ancestor(of: find.text(leaving), matching: find.byType(Opacity)),
    );
    return layers.isEmpty ? 1 : layers.map((o) => o.opacity).reduce((a, b) => a * b);
  }

  Future<void> swap(WidgetTester tester, {required bool fade}) async {
    Widget page(int day) => Align(
      alignment: Alignment.topCenter,
      child: SizedBox(height: 200, child: Text('день $day')),
    );

    late void Function(void Function()) redraw;
    var day = 1;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        home: StatefulBuilder(
          builder: (context, setState) {
            redraw = setState;
            return Slide(value: day, dir: 1, fade: fade, child: page(day));
          },
        ),
      ),
    );

    redraw(() => day = 2);
    await tester.pump();
    // Середина руху: саме тут подвоєння було видно найкраще.
    await tester.pump(const Duration(milliseconds: 170));
  }

  testWidgets('посеред переходу старий день майже зник', (tester) async {
    await swap(tester, fade: true);

    expect(find.text('день 1'), findsOneWidget, reason: 'старий день знявся раніше часу');
    expect(find.text('день 2'), findsOneWidget);
    expect(
      ghost(tester, 'день 1'),
      lessThan(0.25),
      reason: 'старий день досі видно: ${ghost(tester, 'день 1')}',
    );

    await tester.pumpAndSettle();
    expect(find.text('день 1'), findsNothing, reason: 'старий день лишився на екрані');
    expect(ghost(tester, 'день 2'), 1, reason: 'новий день не став непрозорим');
  });

  testWidgets('без розчинення екран лишається непрозорим', (tester) async {
    /* Налаштування заповнюють вікно власним тлом: там сторінка просто їде і
       закриває собою попередню, а розчинення дало б блимання. */
    await swap(tester, fade: false);

    expect(ghost(tester, 'день 1'), 1);
    expect(ghost(tester, 'день 2'), 1);
  });
}
