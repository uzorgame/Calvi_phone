import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/camera/camera_screen.dart';

/// The sheet under the viewfinder is the bottom of the screen, not a card near
/// it: floating with a margin, it read as something that had failed to land.
void main() {
  testWidgets('картка розбору стоїть урівень із краями екрана', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: calviLightTheme,
        home: CameraScreen(slot: 'Вечеря', onSend: (_) {}),
      ),
    );
    await tester.pumpAndSettle();

    // The shutter is what produces the sheet.
    await tester.tap(find.bySemanticsLabel('Зняти'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    /* У режимі страви розбору тут немає: його зробить модель. Кнопка так і
       каже, а картка перевіряється за геометрією, а не за вигаданим числом. */
    final sheet = find.text('Надіслати Норі');
    expect(sheet, findsOneWidget, reason: 'картка розбору не зʼявилась');

    final box = tester.getRect(
      find.ancestor(of: sheet, matching: find.byType(Container)).last,
    );

    expect(box.left, 0, reason: 'ліворуч лишилась смуга видошукача');
    expect(box.right, 390, reason: 'праворуч лишилась смуга видошукача');
    expect(box.bottom, 844, reason: 'під карткою лишилась смуга видошукача');
  });
}
