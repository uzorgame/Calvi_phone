import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/fixtures.dart';
import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/today/hero_card.dart';

/* The weight side reads the person's own figures, so the card needs the scope
   the app puts above every screen. */
Widget _wrap(Widget child) => AppScope(
  s: initialSettings(),
  set: (_) {},
  meds: const [],
  setMeds: (_) {},
  child: MaterialApp(
    theme: calviLightTheme,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('картка стоїть на боці калорій і має висоту', (tester) async {
    await tester.pumpWidget(
      _wrap(
        HeroCard(day: dayFor(0), burned: dayFor(0).burned, goal: goalOf(initialSettings())),
      ),
    );
    await tester.pump();

    /* 2240 норми з налаштувань плюс 310 спалених мінус 624 зʼїдених. Спалене
       повертається в норму, тому воно тут доданок, а не окремий рядок. Число
       береться з налаштувань, а не з фікстур: інакше картка міряла б день
       проти однієї норми, а екран норми показував іншу. */
    final texts = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList();
    expect(texts, contains('1\u00A0926'), reason: 'розряди відділяються нерозривним пробілом');
    expect(texts, contains('днів'));

    // A card that collapses to nothing is the failure this catches.
    expect(tester.getSize(find.byType(HeroCard)).height, greaterThan(100));
  });

  testWidgets('змах угору перевертає картку на вагу', (tester) async {
    await tester.pumpWidget(
      _wrap(
        HeroCard(day: dayFor(0), burned: dayFor(0).burned, goal: goalOf(initialSettings())),
      ),
    );
    await tester.pump();

    await tester.drag(find.byType(HeroCard), const Offset(0, -60));
    await tester.pumpAndSettle();

    final texts = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList();
    expect(texts, contains('ціль, кг'), reason: 'бік ваги не вийшов уперед');

    /* The calorie side is faded out, not taken out. It is the side the stack
       measures itself by, and a card whose front side leaves the tree collapses
       to nothing: that was the card disappearing the moment it turned. */
    expect(texts, contains('днів'), reason: 'бік калорій має лишитись у дереві');
    final faded = tester
        .widgetList<Opacity>(
          find.ancestor(of: find.text('днів'), matching: find.byType(Opacity)),
        )
        .map((o) => o.opacity);
    expect(faded, contains(closeTo(0, 0.01)), reason: 'бік калорій не згас');
  });
}
