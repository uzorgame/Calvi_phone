import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/settings.dart';
import 'package:calvi/main.dart';

void main() {
  test('перший запуск світлий, а не за пристроєм', () {
    expect(initialSettings().theme, AppTheme.light);
  });

  testWidgets('темний пристрій не перефарбовує застосунок на першому запуску', (tester) async {
    /* The device is set to dark and the app still opens light: a first run is
       the one moment nobody has chosen anything, and following the phone there
       would show half the people a theme they never picked. */
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.localesTestValue = const [Locale('uk')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const CalviApp(storage: false, hello: false));
    await tester.pump();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);
  });

  testWidgets('вибір у налаштуваннях далі веде застосунок', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('uk')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(const CalviApp(storage: false, hello: false));
    await tester.pump();

    // The three-way choice is still there; only the starting point changed.
    expect(themeOptions.map((t) => t.id), containsAll(AppTheme.values));
  });
}
