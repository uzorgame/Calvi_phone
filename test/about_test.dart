import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:calvi/data/legal.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/settings/panel_about.dart';
import 'package:calvi/screens/settings/panel_legal.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// «Про застосунок»: версія, назва і автор.
///
/// Раніше внизу налаштувань стояв рядок «Calvi 0.1 · демо інтерфейсу», вписаний
/// руками. Він застарів у день першої збірки й відтоді брехав кожному, хто
/// відкривав налаштування. Версія тепер читається з самого пакета, і цей тест
/// стежить, щоб вона на екран таки доїхала.
void main() {
  setUp(() {
    /* Пакет за межами телефона нічого не знає про застосунок, тому підкладаємо
       відповідь: перевіряємо екран, а не платформу. */
    PackageInfo.setMockInitialValues(
      appName: 'Calvi',
      packageName: 'com.calvi.calvi',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  Widget wrap(Widget child) => MaterialApp(
    localizationsDelegates: L.localizationsDelegates,
    supportedLocales: L.supportedLocales,
    locale: const Locale('uk'),
    theme: calviLightTheme,
    home: child,
  );

  testWidgets('версія приходить із пакета, а не з константи', (tester) async {
    await tester.pumpWidget(wrap(const AboutPanel()));
    await tester.pumpAndSettle();

    expect(find.text('1.0.0 (1)'), findsOneWidget);
  });

  testWidgets('імʼя розробника стоїть на екрані', (tester) async {
    await tester.pumpWidget(wrap(const AboutPanel()));
    await tester.pumpAndSettle();

    expect(find.text('Nahreba Mykhailo'), findsWidgets);
  });

  /* Документи звідси пішли. Вони стоять власними рядками в налаштуваннях і
     повним текстом, а не посиланням у браузер, тому «Про застосунок» лишився
     тим, чим і мав бути: версією, автором і поштою. */
  testWidgets('документів тут більше немає', (tester) async {
    await tester.pumpWidget(wrap(const AboutPanel()));
    await tester.pumpAndSettle();

    expect(find.text('Умови користування'), findsNothing);
    expect(find.text('Не медичний засіб'), findsNothing);
  });

  /* Текст документів приходить із `tools/legal.mjs`, який пише його з демки.
     Якщо генератор не запускали після правки слів, застосунок покаже старе, і
     цей тест лишиться зеленим. Він стежить за іншим: що екран узагалі показує
     текст, а не порожню рамку. */
  testWidgets('умови і приватність показуються повним текстом', (tester) async {
    for (final doc in [terms, privacy]) {
      await tester.pumpWidget(wrap(LegalPanel(doc: doc)));
      await tester.pumpAndSettle();

      expect(find.text(doc.title), findsOneWidget);
      expect(find.text(doc.lede), findsOneWidget);
      expect(find.text(doc.parts.first.h), findsOneWidget);
      expect(doc.parts.length, greaterThan(3));
    }
  });
}
