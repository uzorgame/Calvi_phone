import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/day.dart' show dataLang;
import 'package:calvi/main.dart';

/// Якою мовою застосунок відкривається на чужому телефоні.
///
/// Питання просте, а відповідь на нього дає не наш код, а `basicLocaleListResolution`
/// усередині Flutter, і поводиться він не так, як здається. Мову він шукає за
/// списком `supportedLocales`, а коли не знаходить жодної, бере **перший
/// рядок зі списку**, а не англійську і не якусь «типову». Тобто порядок у
/// тому списку це і є правило про запасну мову, записане місцем у масиві.
///
/// Тому англійська там стоїть першою. Якщо колись хтось пересуне українську
/// нагору «щоб була головною», японський телефон відкриє застосунок
/// українською, і жодна перевірка рядків цього не побачить: усі вісім мов на
/// місці, просто вибрана не та.
///
/// Перевіряється саме результат добору, а не написи на екрані: напис залежить
/// ще й від того, який екран устиг намалюватись, а тут питання одне.
void main() {
  Locale shown(WidgetTester tester) =>
      Localizations.localeOf(tester.element(find.byType(Navigator).first));

  Future<void> boot(WidgetTester tester, List<Locale> device) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    tester.platformDispatcher.localesTestValue = device;
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const CalviApp(storage: false, hello: false));
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('телефон українською відкриває застосунок українською', (tester) async {
    await boot(tester, const [Locale('uk')]);
    expect(shown(tester).languageCode, 'uk');
    expect(dataLang, 'uk', reason: 'шар даних говорить іншою мовою, ніж екран');
  });

  /* По тесту на мову, а не цикл усередині одного.
   *
   * Другий `pumpWidget` у тому самому тесті піднімає новий застосунок поверх
   * живого старого, і старий при знесенні шукає предків у вже неживому дереві.
   * Це шум самого тесту, а не застосунку, але він ховає справжні збої. */
  for (final code in ['en', 'uk', 'es', 'it', 'de', 'fr', 'pt', 'pl', 'cs']) {
    testWidgets('телефон $code відкриває застосунок мовою $code', (tester) async {
      await boot(tester, [Locale(code)]);
      expect(shown(tester).languageCode, code);
    });
  }

  /* Область не мова. «uk-UA», «pt-BR» і «en-GB» це ті самі вісім мов, просто з
     країною поруч, і добір має впізнати їх за мовою. Особливо «pt-BR»:
     переклад у нас саме бразильський. */
  for (final locale in const [
    Locale('uk', 'UA'),
    Locale('pt', 'BR'),
    Locale('en', 'GB'),
    Locale('de', 'AT'),
  ]) {
    testWidgets('${locale.toLanguageTag()}: країна поруч із мовою нічого не ламає', (
      tester,
    ) async {
      await boot(tester, [locale]);
      expect(shown(tester).languageCode, locale.languageCode);
    });
  }

  for (final code in ['ja', 'zh', 'ar', 'tr', 'sk', 'ro', 'hu']) {
    testWidgets('телефон $code, мови якого в застосунку немає, отримує англійську', (
      tester,
    ) async {
      await boot(tester, [Locale(code)]);
      expect(shown(tester).languageCode, 'en');
      expect(dataLang, 'en', reason: 'шар даних говорить іншою мовою, ніж екран');
    });
  }

  /* Телефон називає не одну мову, а список: перша це та, якою людина хоче
     читати, далі запасні. Добір має пройти список згори вниз і взяти першу, яку
     ми вміємо, а не спинитись на першій же незнайомій. */
  testWidgets('зі списку мов телефона береться перша, яку застосунок знає', (tester) async {
    await boot(tester, const [Locale('ja'), Locale('sk'), Locale('pl'), Locale('en')]);
    expect(shown(tester).languageCode, 'pl');
  });
}
