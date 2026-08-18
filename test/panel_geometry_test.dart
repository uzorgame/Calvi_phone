import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/shell.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/design/ruler.dart';
import 'package:calvi/design/wheel.dart';
import 'package:calvi/screens/settings/panels_body.dart';

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

    final hint = tester.getRect(find.textContaining('Ці числа стоять'));
    final sex = tester.getRect(find.text('Стать'));
    final picks = find.byType(CalviPick);
    // The card itself, not the ten of margin the option carries under it.
    Rect card(int i) => tester.getRect(
      find.descendant(of: picks.at(i), matching: find.byType(AnimatedContainer)).first,
    );
    final one = card(0);
    final two = card(1);
    final three = card(2);
    final age = tester.getRect(find.text('Вік'));
    final drum = tester.getRect(find.byType(CalviWheel).first);


    // Everything stands at the same gutter, the options included.
    for (final (name, r) in [('підказка', hint), ('Стать', sex), ('вибір', one)]) {
      expect(r.left, 24, reason: '$name не на відступі 24');
      expect(r.right, 366, reason: '$name не доходить до 366');
    }

    // A section gap under the hint, then twelve under the title.
    expect(sex.top - hint.bottom, closeTo(28, 2), reason: 'підказка не на секційному відступі');
    expect(one.top - sex.bottom, closeTo(12, 2), reason: 'заголовок не на 12 над вибором');

    // Ten between options.
    expect(two.top - one.bottom, closeTo(10, 0.5), reason: 'між виборами не 10');
    expect(three.top - two.bottom, closeTo(10, 0.5), reason: 'між виборами не 10');
    /* Only the one-line option is measured: a test has no Onest, so the width a
       hint wraps at is the fallback font's, not the app's. */
    expect(one.height, closeTo(70, 2), reason: 'вибір без підпису не 70 висотою');

    // A section gap below the last option, and the drum is five rows tall.
    expect(age.top - three.bottom, closeTo(28, 2), reason: 'блок не на секційному відступі');
    expect(drum.top - age.bottom, closeTo(12, 2), reason: 'заголовок не на 12 над барабаном');
    expect(drum.height, 200, reason: 'барабан не 200 висотою');
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
