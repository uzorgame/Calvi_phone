import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/today/manual_form.dart';
import 'package:calvi/screens/today/slot_card.dart';

/// Ручний запис: числа вписує людина.
///
/// На цьому шляху стоїть безкоштовний тариф. Після пробника людині лишається
/// саме він, тому перевіряється не «чи малюється форма», а чи доходять числа з
/// полів до запису цілими.
Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: L.localizationsDelegates,
  supportedLocales: L.supportedLocales,
  locale: const Locale('uk'),
  theme: calviLightTheme,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets('поки Норі є чим платити, плюс віддає їй', (tester) async {
    final toNora = <String>[];
    final byHand = <ManualEntry>[];

    await tester.pumpWidget(
      _wrap(SlotInput(onSend: toNora.add, onManual: byHand.add, noraCan: true)),
    );

    await tester.enterText(find.byType(TextField).first, 'Борщ 500 грам');
    await tester.pump();
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    expect(toNora, ['Борщ 500 грам'], reason: 'рядок не дійшов до Нори');
    expect(byHand, isEmpty, reason: 'відкрилась форма там, де мала рахувати Нора');
  });

  testWidgets('без токенів той самий плюс відкриває форму', (tester) async {
    final toNora = <String>[];

    await tester.pumpWidget(_wrap(SlotInput(onSend: toNora.add, onManual: (_) {}, noraCan: false)));

    await tester.enterText(find.byType(TextField).first, 'Борщ 500 грам');
    await tester.pump();
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    expect(toNora, isEmpty, reason: 'запис пішов Норі, хоч платити нічим');

    final l = await L.delegate.load(const Locale('uk'));
    // Пʼять полів, і назва вже стоїть заголовком: її не питають удруге.
    expect(find.text('Борщ 500 грам'), findsOneWidget);
    for (final label in [
      l.slotGrams,
      l.slotKcal,
      l.macroProteinCaps,
      l.macroFatCaps,
      l.macroCarbsCaps,
    ]) {
      expect(find.text(label), findsOneWidget, reason: 'немає поля «$label»');
    }
  });

  testWidgets('калорії підказуються з БЖВ, поки їх не чіпали', (tester) async {
    ManualEntry? saved;

    await tester.pumpWidget(
      _wrap(ManualForm(title: 'Плов', onCancel: () {}, onSave: (e) => saved = e)),
    );

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '350'); // вага
    await tester.enterText(fields.at(2), '20'); // білок
    await tester.enterText(fields.at(3), '15'); // жири
    await tester.enterText(fields.at(4), '60'); // вуглеводи
    await tester.pump();

    // 20*4 + 15*9 + 60*4 за Етвотером.
    expect(find.text('455'), findsOneWidget, reason: 'калорії не підказались');

    final l = await L.delegate.load(const Locale('uk'));
    await tester.tap(find.text(l.slotLog));
    await tester.pumpAndSettle();

    expect(saved, isNotNull, reason: 'запис не зберігся');
    expect(saved!.kcal, 455);
    expect(saved!.grams, 350);
    expect((saved!.protein, saved!.fat, saved!.carbs), (20, 15, 60));
  });

  testWidgets('вписані калорії перебивають підказку', (tester) async {
    ManualEntry? saved;

    await tester.pumpWidget(
      _wrap(ManualForm(title: 'Плов', onCancel: () {}, onSave: (e) => saved = e)),
    );

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(2), '20');
    await tester.pump();
    /* На упаковці буває інакше, ніж дає формула, і сперечатися з тим, що людина
       бачить очима, не наша справа. */
    await tester.enterText(fields.at(1), '480');
    await tester.pump();
    await tester.enterText(fields.at(3), '15');
    await tester.pump();

    final l = await L.delegate.load(const Locale('uk'));
    await tester.tap(find.text(l.slotLog));
    await tester.pumpAndSettle();

    expect(saved?.kcal, 480, reason: 'підказка затерла число людини');
  });

  testWidgets('без калорій записати не можна', (tester) async {
    var saves = 0;

    await tester.pumpWidget(
      _wrap(ManualForm(title: 'Плов', onCancel: () {}, onSave: (_) => saves++)),
    );

    final l = await L.delegate.load(const Locale('uk'));

    // Сама вага без калорій це той самий нуль, від якого ми йдемо.
    await tester.enterText(find.byType(TextField).at(0), '350');
    await tester.pump();
    await tester.tap(find.text(l.slotLog));
    await tester.pumpAndSettle();

    expect(saves, 0, reason: 'записався нуль калорій');
  });

  testWidgets('«Ввести числа самому» стоїть біля лівого краю', (tester) async {
    await tester.pumpWidget(_wrap(SlotInput(onSend: (_) {}, onManual: (_) {}, noraCan: false)));

    await tester.enterText(find.byType(TextField).first, 'Плов');
    await tester.pumpAndSettle();

    /* Складка міряє висоту через Align і центрує вузьких дітей: лінк, який
       вужчий за картку, стояв посередині, а в демці він біля лівого краю. */
    final l = await L.delegate.load(const Locale('uk'));
    final link = tester.getTopLeft(find.text(l.slotByHand)).dx;
    final card = tester.getTopLeft(find.byType(SlotInput)).dx;
    expect(link, moreOrLessEquals(card, epsilon: 1), reason: 'лінк зʼїхав із лівого краю');
  });

  testWidgets('наступна страва відкривається з порожніми полями', (tester) async {
    await tester.pumpWidget(_wrap(SlotInput(onSend: (_) {}, onManual: (_) {}, noraCan: false)));

    Future<void> log(String name, String kcal) async {
      await tester.enterText(find.byType(TextField).first, name);
      await tester.pump();
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(1), kcal);
      await tester.pump();
      final l = await L.delegate.load(const Locale('uk'));
      await tester.tap(find.text(l.slotLog));
      await tester.pumpAndSettle();
    }

    await log('Плов', '480');
    await log('Каша', '');

    /* Форма лишається в дереві, поки згортається, тому сама вона свої поля не
       чистить. Без ключа наступна страва відкривалась би з чужими числами. */
    final kcal = tester.widget<TextField>(find.byType(TextField).at(1));
    expect(kcal.controller?.text, isEmpty, reason: 'числа попередньої страви лишились');
    expect(find.text('Каша'), findsOneWidget);
  });
}
