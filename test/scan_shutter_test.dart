import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/camera/camera_screen.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// У режимі штрихкоду кнопки «зняти» немає.
///
/// Код читається сам, щойно потрапив у рамку, і кнопка тут обіцяла дію, якої не
/// існує: знімок у цьому режимі нікуди не йде. Людина тисла її і не розуміла,
/// чому нічого не відбувається.
///
/// Місце кнопки при цьому лишається порожнім, і це друга половина перевірки:
/// прибрати її зовсім означало б, що спалах і підпис картки роз'їдуться до
/// країв, а нижній ряд стрибатиме щоразу, коли міняють режим.
void main() {
  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: CameraScreen(slot: 'Вечеря', onSend: (_) {}),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('у штрихкоді затвора немає, у страві є', (tester) async {
    await open(tester);
    expect(find.bySemanticsLabel('Зняти'), findsOneWidget, reason: 'страву нічим зняти');

    await tester.tap(find.bySemanticsLabel('Штрихкод'));
    // Не `pumpAndSettle`: у цьому режимі промінь у рамці ходить без кінця, і
    // чекати спокою означало б чекати вічно.
    await tester.pump(const Duration(milliseconds: 600));

    expect(
      find.bySemanticsLabel('Зняти'),
      findsNothing,
      reason: 'кнопка обіцяє знімок, якого в цьому режимі не буде',
    );

    // І назад: у фото вона на місці, бо там знімок і є вся суть.
    await tester.tap(find.bySemanticsLabel('Фото'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.bySemanticsLabel('Зняти'), findsOneWidget);
  });

  testWidgets('нижній ряд не стрибає на зміні режиму', (tester) async {
    await open(tester);
    final was = tester.getRect(find.bySemanticsLabel('Спалах'));

    await tester.tap(find.bySemanticsLabel('Штрихкод'));
    // Не `pumpAndSettle`: у цьому режимі промінь у рамці ходить без кінця, і
    // чекати спокою означало б чекати вічно.
    await tester.pump(const Duration(milliseconds: 600));

    expect(
      tester.getRect(find.bySemanticsLabel('Спалах')),
      was,
      reason: 'разом із кнопкою поїхав увесь ряд',
    );
  });
}
