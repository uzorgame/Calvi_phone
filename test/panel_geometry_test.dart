import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/shell.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/design/ruler.dart';
import 'package:calvi/design/wheel.dart';
import 'package:calvi/screens/settings/panels_body.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// Where the profile panel puts things, measured against the demo.
///
/// Screenshots of the two apps come back at different scales, so eyeballing them
/// side by side proves nothing about spacing. These are the demo's own numbers,
/// read off `getBoundingClientRect` at 390 wide, and the panel has to land on
/// them: gutter 24, the hint a section gap clear of the options, a title twelve
/// above what it names, ten between options, and a drum two hundred tall.
void main() {
  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var s = initialSettings();
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => AppScope(
          s: s,
          set: (patch) => setState(() => s = patch(s)),
          meds: const [],
          setMeds: (_) {},
          child: MaterialApp(
            localizationsDelegates: L.localizationsDelegates,
            supportedLocales: L.supportedLocales,
            locale: const Locale('uk'),
            theme: calviLightTheme,
            scrollBehavior: const CalviScroll(),
            home: ProfilePanel(s: s, set: (patch) => setState(() => s = patch(s))),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('профіль стоїть за розмірами демки', (tester) async {
    await open(tester);

    /* Підказки під заголовком більше немає: екран починається одразу з
       облікового запису, і міряти тепер є від чого і без неї. */
    final account = tester.getRect(find.text('Обліковий запис'));
    final sex = tester.getRect(find.text('Стать'));
    final seg = tester.getRect(find.byType(CalviSegments));

    // Everything stands at the same gutter, the segmented row included.
    for (final (name, r) in [('Обліковий запис', account), ('Стать', sex), ('вибір статі', seg)]) {
      expect(r.left, 24, reason: '$name не на відступі 24');
      expect(r.right, 366, reason: '$name не доходить до 366');
    }

    // Twelve under every title.
    expect(seg.top - sex.bottom, closeTo(12, 2), reason: 'заголовок не на 12 над вибором');

    /* Один ряд замість трьох карток. Висота тут і є вся економія: три вибори з
       іконками стояли на 230, а ряд на 43, і саме заради цього він зроблений. */
    expect(seg.height, 43, reason: 'ряд вибору не 43 висотою');

    /* Вік і зріст рядками, а не барабанами.
     *
     * Барабан це теж прокрутка, і всередині сторінки він забирав жест собі:
     * палець тягнув угору, а рухався барабан. Тепер він живе в аркуші, який
     * відкривається з цих рядків, і сторінка гортається звідусіль. */
    expect(find.byType(CalviWheel), findsNothing, reason: 'барабан повернувся всередину сторінки');
    expect(find.text('26 років'), findsOneWidget, reason: 'рядок не показує значення');
    expect(find.text('183 см'), findsOneWidget);
  });

  testWidgets('вага стоїть за розмірами демки', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var v = initialSettings();
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => AppScope(
          s: v,
          set: (patch) => setState(() => v = patch(v)),
          meds: const [],
          setMeds: (_) {},
          child: MaterialApp(
            localizationsDelegates: L.localizationsDelegates,
            supportedLocales: L.supportedLocales,
            locale: const Locale('uk'),
            theme: calviLightTheme,
            scrollBehavior: const CalviScroll(),
            home: WeightPanel(s: v, set: (patch) => setState(() => v = patch(v))),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final hint = tester.getRect(find.textContaining('Скільки ти важиш'));
    final tape = tester.getRect(find.byType(CalviRuler));
    final note = tester.getRect(find.textContaining('Записуй вагу вранці'));

    // The tape is one unlabelled block: a section gap under the hint, and the
    // demo's own 156 of figure, gap, tape and tail.
    expect(tape.top - hint.bottom, closeTo(28, 2), reason: 'стрічка не на секційному відступі');
    expect(tape.height, closeTo(156, 2), reason: 'стрічка не 156 висотою');
    expect(tape.left, 24, reason: 'стрічка не на відступі 24');

    // The note's twelve collapses into the block's gap, as it does in the demo.
    expect(note.top - tape.bottom, closeTo(28, 3), reason: 'підпис не на 28 під стрічкою');
    expect(note.left, 24, reason: 'підпис не на відступі 24');
  });
}
