import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/meds.dart';
import 'package:calvi/data/repeat.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/meds/meds_screen.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// Розділи курсів розгортаються так само, як картки дня.
///
/// Розгортання повільне й мʼяке, згортання швидке й рівне: розділ, що
/// закривається так само ліниво, як відкривався, читається так, ніби застосунок
/// над цим думає. Числа взяті з карток сніданку й вечері: 440 мс на підйомі
/// проти 220 мс на закритті, і вміст, який доїжджає ще сорок мілісекунд після
/// того, як висота вже стала.
void main() {
  final today = DateTime.now();

  final med = Med(
    id: 'm1',
    name: 'Магній B6',
    dose: 2,
    form: MedForm.tab,
    remind: true,
    repeat: const DailyRepeat(),
    startDay: dayKeyOf(today.subtract(const Duration(days: 3))),
    times: const [MedTime(at: '08:00', taken: false)],
  );

  Future<void> open(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      locale: const Locale('uk'),
      theme: calviLightTheme,
      home: MedsScreen(
        meds: [med],
        onToggle: (_, _) {},
        onSave: (_) {},
        onFinish: (_) {},
        onRevive: (_) {},
      ),
    ),
  );

  /* Наскільки розійшлись два заголовки. Росте рівно на висоту розгорнутого
     списку, і саме тому міряється так: висота самої картки залежить від того, що
     Flutter вважає її межами, а відстань між двома написами це те, що бачить
     людина. */
  double gap(WidgetTester tester) =>
      tester.getTopLeft(find.text('Минулі')).dy - tester.getTopLeft(find.text('Мої препарати')).dy;

  testWidgets('розгортається довше, ніж згортається', (tester) async {
    await open(tester);
    await tester.pump();

    final shut = gap(tester);

    await tester.tap(find.text('Мої препарати'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 240));

    final midway = gap(tester);
    expect(midway, greaterThan(shut), reason: 'розділ не поїхав');

    await tester.pump(const Duration(milliseconds: 400));
    final full = gap(tester);
    expect(
      midway,
      lessThan(full),
      reason: 'розгортання скінчилось за 240 мс, тобто взято тривалість згортання',
    );

    /* А тепер назад. Ті самі 240 мс, і на цей раз їх має вистачити з запасом. */
    await tester.tap(find.text('Мої препарати'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 240));

    expect(gap(tester), shut, reason: 'згортання не встигло за 240 мс');
  });

  testWidgets('вміст піднімається на такт пізніше за висоту', (tester) async {
    await open(tester);
    await tester.pump();

    await tester.tap(find.text('Мої препарати'));
    await tester.pump();
    // Перші вісімдесят мілісекунд висота вже їде, а вміст іще стоїть на місці.
    await tester.pump(const Duration(milliseconds: 80));

    /* Шукаємо по підпису рядка списку, а не по назві препарату: назва стоїть ще
       й на рейці, всередині власного проявлення, і саме його ми б і зміряли. */
    final fade = tester.widget<Opacity>(
      find.ancestor(of: find.textContaining('· 08:00'), matching: find.byType(Opacity)).first,
    );
    expect(fade.opacity, lessThan(0.35), reason: 'вміст зʼявився разом із висотою, а не за нею');
    expect(gap(tester), greaterThan(0), reason: 'висота не рушила');
  });
}
