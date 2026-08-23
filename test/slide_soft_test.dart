import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/slide.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/design/tokens.dart';

/// Переходи мʼякі, тобто рух видно весь час, поки він триває.
///
/// Тут стояли множники 1.6 і 1.8, від яких обидві прозорості добігали за перші
/// сорок мілісекунд із двохсот шістдесяти. Рух після цього тривав, але дивитись
/// у ньому вже було ні на що, і перехід читався як обрив. У демці інакше: та,
/// що приходить, наростає з нуля до одиниці за весь час, а та, що йде, зникає
/// одразу. На екрані в кожен момент рівно одна сторінка, і вона наростає.
void main() {
  /// Прозорості обох комірок посеред руху.
  Future<List<double>> mid(WidgetTester tester, {required bool fade}) async {
    var page = 'перша';
    late StateSetter set;

    await tester.pumpWidget(
      MaterialApp(
        theme: calviLightTheme,
        home: StatefulBuilder(
          builder: (context, setState) {
            set = setState;
            return Slide(value: page, dir: 1, fade: fade, child: Text(page));
          },
        ),
      ),
    );

    set(() => page = 'друга');
    await tester.pump();
    // Половина шляху: рівно та мить, у якій має бути на що дивитись.
    await tester.pump(CalviMotion.screen ~/ 2);

    return tester.widgetList<Opacity>(find.byType(Opacity)).map((o) => o.opacity).toList();
  }

  testWidgets('посеред руху нова сторінка ще проявляється', (tester) async {
    final at = await mid(tester, fade: true);

    expect(at.length, 2, reason: 'комірок не дві, перевірка дивиться не туди');
    expect(
      at.any((o) => o > 0.02 && o < 0.98),
      isTrue,
      reason: 'обидві прозорості вже в кінці: перехід обривається, а не пливе',
    );
  });

  testWidgets('та, що йде, не лежить під новою напівпрозорою', (tester) async {
    final at = await mid(tester, fade: true);

    /* Рівно одна сторінка на екрані. Дві напівпрозорі одна на одній це той
       самий двоїстий текст, від якого й пішли. */
    expect(at.where((o) => o > 0.02).length, 1);
  });

  testWidgets('без розчинення обидві сторінки непрозорі', (tester) async {
    // Там, де сторінка має власне тло, розчиняти нічого не треба.
    final at = await mid(tester, fade: false);
    expect(at, everyElement(1.0));
  });

  testWidgets('у кінці руху нова сторінка повністю видима', (tester) async {
    var page = 'перша';
    late StateSetter set;

    await tester.pumpWidget(
      MaterialApp(
        theme: calviLightTheme,
        home: StatefulBuilder(
          builder: (context, setState) {
            set = setState;
            return Slide(value: page, dir: 1, fade: true, child: Text(page));
          },
        ),
      ),
    );

    set(() => page = 'друга');
    await tester.pumpAndSettle();

    expect(find.text('друга'), findsOneWidget);
    expect(
      tester.widgetList<Opacity>(find.byType(Opacity)).map((o) => o.opacity),
      everyElement(1.0),
    );
  });
}
