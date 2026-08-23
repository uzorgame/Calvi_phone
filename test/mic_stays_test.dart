import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/chat.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/today/bottom_bar.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// Круг у рядку не зникає, поки Нора думає.
///
/// Він ховається рівно на час диктування, бо його закриває збільшена кнопка.
/// Поки Нора думає, ховати нічим і нема за чим: у рядку лишалась сама камера, і
/// це читалось так, ніби сказати більше нічим.
void main() {
  Widget bar({required bool mute}) => MaterialApp(
    localizationsDelegates: L.localizationsDelegates,
    supportedLocales: L.supportedLocales,
    locale: const Locale('uk'),
    theme: calviLightTheme,
    home: Scaffold(
      body: BottomBar(
        slot: 'Обід',
        messages: const <Msg>[],
        onSend: (_) {},
        onCamera: () {},
        onHold: (_, _) {},
        onLetGo: () {},
        open: true,
        onOpen: (_) {},
        onClose: () {},
        muteMic: mute,
      ),
    ),
  );

  /* Саме зовнішній масштаб, а не той, що всередині кнопки: внутрішній стискає
     її на дотик і завжди одиниця, поки на неї не тиснуть. */
  double micScale(WidgetTester tester) => tester
      .widgetList<AnimatedScale>(
        find.ancestor(of: find.bySemanticsLabel('Мікрофон'), matching: find.byType(AnimatedScale)),
      )
      .last
      .scale;

  testWidgets('кнопка на місці, поки нічого не диктують', (tester) async {
    await tester.pumpWidget(bar(mute: false));
    await tester.pumpAndSettle();
    expect(micScale(tester), 1, reason: 'круг зник без причини');
    expect(find.bySemanticsLabel('Мікрофон'), findsOneWidget);
  });

  testWidgets('і ховається тільки на час диктування', (tester) async {
    await tester.pumpWidget(bar(mute: true));
    await tester.pumpAndSettle();
    expect(micScale(tester), 0);
  });
}
