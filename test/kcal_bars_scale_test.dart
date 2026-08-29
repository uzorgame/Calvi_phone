import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/theme.dart';
import 'package:calvi/format.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/analytics/charts.dart';

/* Як банер калорій стоїть на різних даних.
 *
 * Ці числа не видно оком на кожній збірці, а помилка тут тиха і дорога: день
 * на тисячу калорій, намальований урівень із нормою, каже людині, що вона
 * дотримала норму. Тому геометрія міряється, а не оглядається.
 *
 * Три випадки, які трапляються насправді: тиждень недобору, тиждень при нормі
 * і один день, що вибився далеко за неї. */

const _norm = 2200;

Widget _wrap(List<({String label, int protein, int fat, int carbs})> rows) => MaterialApp(
  localizationsDelegates: L.localizationsDelegates,
  supportedLocales: L.supportedLocales,
  locale: const Locale('uk'),
  theme: calviLightTheme,
  home: Scaffold(
    body: Align(
      alignment: Alignment.topCenter,
      child: SizedBox(width: 340, child: MacroBars(rows: rows, norm: _norm)),
    ),
  ),
);

/// День, зібраний із калорій: білок і вуглеводи по 4, жири по 9.
({String label, int protein, int fat, int carbs}) day(String label, int kcal) {
  // Половина з вуглеводів, чверть із білка, чверть із жиру: пропорція тут не
  // важлива, важлива сума.
  final carbs = (kcal * 0.5 / 4).round();
  final protein = (kcal * 0.25 / 4).round();
  final fat = (kcal * 0.25 / 9).round();
  return (label: label, protein: protein, fat: fat, carbs: carbs);
}

/// Смуга колонки: те, що обрізає її заокруглені кути.
Rect _bar(WidgetTester tester, int i) => tester.getRect(find.byType(ClipRRect).at(i));

/// Уся коробка графіка: стопка, у якій живуть смуги і лінія норми.
Rect _plot(WidgetTester tester) => tester.getRect(find.byType(Stack).at(0));

Rect _normLine(WidgetTester tester) => tester.getRect(find.text(thousands(_norm)));

void main() {
  testWidgets('стовпчики стоять на дні графіка, а не висять над ним', (tester) async {
    await tester.pumpWidget(_wrap([day('ПН', 900), day('ВТ', 1400), day('СР', 700)]));
    await tester.pumpAndSettle();

    final plot = _plot(tester);
    for (var i = 0; i < 3; i++) {
      expect(
        (_bar(tester, i).bottom - plot.bottom).abs() < 1,
        isTrue,
        reason: 'колонка $i не торкається дна: ${_bar(tester, i)} у $plot',
      );
    }

    /* Підписи днів одразу під графіком. Порожнеча в піврядка між ними колись
       і була ознакою того, що ряд стовпчиків живе своїм життям. */
    final labels = tester.getRect(find.text('ПН'));
    expect(
      labels.top - plot.bottom < 14,
      isTrue,
      reason: 'дні тижня відірвались від графіка: ${labels.top - plot.bottom}',
    );
  });

  testWidgets('тиждень недобору лишає норму вище за всі колонки', (tester) async {
    await tester.pumpWidget(_wrap([day('ПН', 900), day('ВТ', 1374), day('СР', 700)]));
    await tester.pumpAndSettle();

    final line = _normLine(tester).center.dy;
    for (var i = 0; i < 3; i++) {
      expect(
        _bar(tester, i).top > line,
        isTrue,
        reason: 'колонка $i переросла норму, якої не досягала',
      );
    }

    // Повітря над нормою: лінія не притиснута до стелі графіка.
    expect(line - _plot(tester).top > 8, isTrue, reason: 'норма лягла на стелю');
  });

  testWidgets('день понад норму переростає лінію, а не стелю', (tester) async {
    /* 2600 при нормі 2200 це перебір, який мусить бути видно: колонка вища за
       лінію і при цьому ціла, з повітрям над собою. */
    await tester.pumpWidget(_wrap([day('ПН', 2600), day('ВТ', 900)]));
    await tester.pumpAndSettle();

    final plot = _plot(tester);
    final line = _normLine(tester).center.dy;
    final over = _bar(tester, 0);

    expect(over.top < line, isTrue, reason: 'перебір не переріс лінію норми');
    expect(over.top > plot.top, isTrue, reason: 'колонка вперлась у стелю графіка');
  });

  testWidgets('день удвічі понад норму розтягує графік, а не давить колонки', (tester) async {
    await tester.pumpWidget(_wrap([day('ПН', 900), day('ВТ', 1400)]));
    await tester.pumpAndSettle();
    final calm = _plot(tester).height;

    await tester.pumpWidget(_wrap([day('ПН', 4400), day('ВТ', 1400)]));
    await tester.pumpAndSettle();
    final tall = _plot(tester);

    expect(tall.height > calm, isTrue, reason: 'графік не виріс під високий день');

    /* Ціна пікселя в калоріях лишилась та сама, тому звичайний день не
       здрібнів: 1400 ккал займають стільки ж, скільки й у спокійний тиждень. */
    final small = _bar(tester, 1).height;
    expect(small > 40, isTrue, reason: 'звичайний день став смужкою: $small');
  });
}
