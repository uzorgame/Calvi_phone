import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/meds.dart';
import 'package:calvi/data/repeat.dart';
import 'package:calvi/screens/meds/meds_screen.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// Розділ «Минулі» стоїть на екрані навіть тоді, коли минулих курсів ще немає.
/* Крапка «зараз» пульсує весь час, поки екран відкритий, тож pumpAndSettle на
   ньому не завершиться ніколи. Кадри тут відлічуються руками. */
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  Future<void> open(WidgetTester tester, List<Med> meds) => tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      locale: const Locale('uk'),
      theme: calviLightTheme,
      home: MedsScreen(
        meds: meds,
        onToggle: (_, _) {},
        onSave: (_) {},
        onFinish: (_) {},
        onRevive: (_) {},
      ),
    ),
  );

  final today = DateTime.now();
  String key(DateTime d) => dayKeyOf(d);

  final live = Med(
    id: 'm1',
    name: 'Магній B6',
    dose: 2,
    form: MedForm.tab,
    remind: true,
    repeat: const DailyRepeat(),
    startDay: key(today.subtract(const Duration(days: 3))),
    times: const [MedTime(at: '08:00', taken: false)],
  );

  final finished = Med(
    id: 'm2',
    name: 'Вітамін D3',
    dose: 1,
    form: MedForm.drop,
    remind: false,
    repeat: const DailyRepeat(),
    startDay: key(today.subtract(const Duration(days: 30))),
    endDay: key(today.subtract(const Duration(days: 2))),
    times: const [MedTime(at: '09:00', taken: false)],
  );

  testWidgets('кнопка стоїть і без жодного минулого курсу', (tester) async {
    await open(tester, [live]);
    await settle(tester);

    expect(find.text('Минулі'), findsOneWidget);
    expect(find.text('0'), findsWidgets);
  });

  testWidgets('закінчений курс лежить у «Минулих», а не серед активних', (tester) async {
    await open(tester, [live, finished]);
    await settle(tester);

    expect(find.text('Вітамін D3'), findsNothing, reason: 'закінчений курс серед активних');

    await tester.tap(find.text('Минулі'));
    await settle(tester);

    expect(find.text('Вітамін D3'), findsOneWidget, reason: 'курс не знайшовся в історії');
    expect(find.text('Магній B6'), findsWidgets, reason: 'активний курс зник');
  });
}
