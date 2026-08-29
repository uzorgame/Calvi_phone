import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/analytics/charts.dart';

/* Число під пальцем на кривій.
 *
 * Крива каже «щось рухається», але не каже, скільки саме було у вівторок.
 * Перевіряється не малюнок, а відповідь: чи те число і та дата зʼявляються під
 * тим місцем, де стоїть палець, чи лишаються після того, як його відпустили, і
 * чи гаснуть від дотику осторонь. Помилка тут тиха: графік лишається гарним і
 * просто перестає відповідати.
 */

const _values = [81.0, 80.4, 79.6, 79.1, 78.8];
const _dates = ['1 червня', '8 червня', '15 червня', '22 червня', '29 червня'];

Widget _wrap() => MaterialApp(
  localizationsDelegates: L.localizationsDelegates,
  supportedLocales: L.supportedLocales,
  locale: const Locale('uk'),
  theme: calviLightTheme,
  home: const Scaffold(
    body: Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 320,
        child: LineChart(values: _values, labels: ['1 червня', '29 червня'], dates: _dates),
      ),
    ),
  ),
);

/// Коробка самого графіка, тією ж арифметикою, якою він рахує свої точки.
Rect _plot(WidgetTester tester) => tester.getRect(find.byType(GestureDetector).first);

/// Точка з номером [i] у координатах екрана.
Offset _spot(WidgetTester tester, int i) {
  final box = _plot(tester);
  const padX = 5.0;
  return Offset(
    box.left + padX + (box.width - padX * 2) * i / (_values.length - 1),
    box.center.dy,
  );
}

void main() {
  testWidgets('крива мовчить, поки її не спитали', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.textContaining('81.0'), findsNothing, reason: 'число стоїть без питання');
    expect(find.text('1 червня'), findsOneWidget, reason: 'підпис осі має лишатись один');
  });

  testWidgets('дотик по кривій каже число і день', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tapAt(_spot(tester, 0));
    await tester.pumpAndSettle();

    final l = await L.delegate.load(const Locale('uk'));
    expect(find.text('81.0 ${l.unitKg}'), findsOneWidget, reason: 'числа першої точки немає');
    expect(find.text('1 червня'), findsWidgets, reason: 'дня першої точки немає');
  });

  testWidgets('палець веде по кривій, і число йде за ним', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    final l = await L.delegate.load(const Locale('uk'));

    final drag = await tester.startGesture(_spot(tester, 1));
    await tester.pumpAndSettle();
    expect(find.text('80.4 ${l.unitKg}'), findsOneWidget, reason: 'друга точка не назвалась');

    await drag.moveTo(_spot(tester, 4));
    await tester.pumpAndSettle();
    expect(find.text('78.8 ${l.unitKg}'), findsOneWidget, reason: 'число не пішло за пальцем');
    expect(find.text('80.4 ${l.unitKg}'), findsNothing, reason: 'два числа одночасно');

    // Відпущений палець не забирає відповідь: коротке торкання теж має її дати.
    await drag.up();
    await tester.pumpAndSettle();
    expect(find.text('78.8 ${l.unitKg}'), findsOneWidget, reason: 'число зникло з пальцем');
  });

  testWidgets('дотик поза графіком знімає вибір', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    final l = await L.delegate.load(const Locale('uk'));

    await tester.tapAt(_spot(tester, 2));
    await tester.pumpAndSettle();
    expect(find.text('79.6 ${l.unitKg}'), findsOneWidget);

    // Низ екрана: графіка там немає.
    await tester.tapAt(const Offset(20, 560));
    await tester.pumpAndSettle();
    expect(find.text('79.6 ${l.unitKg}'), findsNothing, reason: 'вибір не гасне поза графіком');
  });

  testWidgets('на краях підказка лишається в межах графіка', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    final l = await L.delegate.load(const Locale('uk'));
    final plot = _plot(tester);

    for (final (i, v) in [(0, '81.0'), (4, '78.8')]) {
      await tester.tapAt(_spot(tester, i));
      await tester.pumpAndSettle();

      final tip = tester.getRect(find.text('$v ${l.unitKg}'));
      expect(
        tip.left >= plot.left - 1 && tip.right <= plot.right + 1,
        isTrue,
        reason: 'підказка точки $i виїхала за графік: $tip проти $plot',
      );
    }
  });
}
