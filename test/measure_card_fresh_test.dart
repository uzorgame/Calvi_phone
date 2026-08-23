import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/measure.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/today/measure_card.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// Число, яке прийшло після побудови картки, має стати в поле.
///
/// Контролер поля створювався один раз і назавжди, тому запис, що зʼявився
/// пізніше, у нього вже не потрапляв. Найпомітніше це було з Норою: людина каже
/// «запиши вагу 77.5», запис лягає в базу, значок чесно пише «1 замір», а поле
/// поруч порожнє. Той самий контролер тягнувся і при перемиканні днів,
/// показуючи вчорашнє число на сьогоднішній картці.
Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: L.localizationsDelegates,
  supportedLocales: L.supportedLocales,
  locale: const Locale('uk'),
  theme: calviLightTheme,
  home: Scaffold(body: ListView(children: [child])),
);

Widget _card(int date, List<Measure> list) => MeasureCard(
  date: date,
  list: list,
  tracked: const ['weightKg'],
  onTrack: (_) {},
  onSave: (_) {},
  onStats: () {},
  open: true,
  onToggle: () {},
);

String _fieldText(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField).first).controller?.text ?? '';

void main() {
  testWidgets('замір, записаний Норою, зʼявляється в полі', (tester) async {
    await tester.pumpWidget(_wrap(_card(0, const [])));
    expect(_fieldText(tester), '', reason: 'на порожній день поле має бути порожнім');

    // Нора записала вагу, синхронізація принесла її на телефон.
    await tester.pumpWidget(
      _wrap(
        _card(0, const [
          Measure(date: 0, values: {'weightKg': 77.5}),
        ]),
      ),
    );

    expect(_fieldText(tester), '77.5', reason: 'значок каже «1 замір», а поле порожнє');
  });

  testWidgets('перемикання дня не лишає в полі вчорашнє число', (tester) async {
    const list = [
      Measure(date: -1, values: {'weightKg': 80}),
    ];

    await tester.pumpWidget(_wrap(_card(-1, list)));
    expect(_fieldText(tester), '80');

    // Той самий перелік, але дивимось уже на сьогодні, коли ще не міряли.
    await tester.pumpWidget(_wrap(_card(0, list)));
    expect(_fieldText(tester), '', reason: 'вчорашнє число лишилось на сьогоднішній картці');
  });

  testWidgets('недописане людиною не затирається новими даними', (tester) async {
    await tester.pumpWidget(_wrap(_card(0, const [])));

    await tester.enterText(find.byType(TextField).first, '76');
    await tester.pump();

    // Поки людина пише, приходить синхронізація з іншим числом.
    await tester.pumpWidget(
      _wrap(
        _card(0, const [
          Measure(date: 0, values: {'weightKg': 99}),
        ]),
      ),
    );

    expect(_fieldText(tester), '76', reason: 'набране людиною зникло під час набору');
  });
}
