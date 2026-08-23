import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui' show instantiateImageCodec;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/day.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/today/today_screen.dart';

/// Знімки застосунку для карток стору.
///
/// Не тест, а інструмент, і лежить він поза текою `test/` саме тому: `flutter
/// test` бере звідти все підряд, а ці знімки мають перемальовуватись тоді, коли
/// їх просять, а не спиняти роботу через зсув на піксель.
///
/// Запуск із теки Calvi_phone:
///
///     flutter test tool --update-goldens
///
/// Кладе PNG прямо в `Active/Calvi/Store/shots/`, звідки їх бере сторінка на
/// localhost:5400.
///
/// Мови розведені по двох файлах навмисно. Показові страви й заняття мають дві
/// назви, і вибирає між ними глобальна `dataLang`, але сам показовий день це
/// ліниве поле верхнього рівня: воно збирається при першому зверненні і після
/// того вже не міняється. Один процес на дві мови означав українську картку з
/// написом «Two fried eggs». Окремий файл це окремий процес.
///
/// Чому не знімки з телефона. Українську і англійську треба показати тими
/// самими екранами, з тими самими числами, і зняти таке руками означає двічі
/// перемкнути мову і двічі попасти в ту саму мить. Тут же обидві мови виходять
/// з одного джерела, у нашому шрифті, без системної смуги чужого пристрою.
///
/// Розмір. Малюється логічними 390×844, як телефон, і збільшується втричі
/// прямо в дереві. Збільшує `FittedBox`, а не масштаб знімка: перетворення
/// лягає на текст до растеризації, тож літери виходять різкими, а не
/// розтягнутими.
void shots(String lang) {
  const logical = Size(390, 844);
  const zoom = 3.0;
  setUpAll(() async {
    /* Справжній Onest замість тестового шрифта. Без цього кожен напис вийшов
       би рядом чорних прямокутників: у тестах Flutter підставляє шрифт без
       гліфів. */
    for (final face in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      final bytes = await File('assets/fonts/Onest-$face.ttf').readAsBytes();
      await (FontLoader('Onest')..addFont(Future.value(ByteData.sublistView(bytes)))).load();
    }

    /* Системна смуга береться з живого знімка телефона, а не малюється.
       Намальована виходить схожою, але не тією: у неї свій годинник, свої
       значки і своя вага ліній. На картці стору це помітно одразу, бо решта
       екрана справжня. */
    final shot = await File('../Store/status-source.png').readAsBytes();
    _status = (await (await instantiateImageCodec(shot)).getNextFrame()).image;
  });

  /// Показовий день у заданій мові. Дані демо, ті самі, що на знімках із телефона.
  Widget app(String lang, {String? open}) {
    /* Мова даних окремо від мови написів, і поставити її треба руками.
       Показові страви й заняття мають дві назви, і вибирає між ними ця змінна,
       а не локаль: назва їде далі в модель страви, у підсумки і в аналітику, і
       жодне з тих місць про переклад не знає. Без цього рядка англійський
       знімок показував «Велосипед» серед англійських написів. */
    dataLang = lang;

    return AppScope(
      s: initialSettings(),
      set: (_) {},
      meds: const [],
      setMeds: (_) {},
      real: false,
      setReal: (_) {},
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: Locale(lang),
        theme: calviLightTheme,
        scrollBehavior: const CalviScroll(),
        home: CalviGround(
          child: TodayScreen(onSettings: () {}, onMeds: () {}, openCard: open),
        ),
      ),
    );
  }

  Future<void> mount(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = logical * zoom;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      Center(
        child: SizedBox(
          width: logical.width * zoom,
          height: logical.height * zoom,
          child: FittedBox(
            fit: BoxFit.fill,
            child: SizedBox(
              width: logical.width,
              height: logical.height,
              /* Поля пристрою задаються тут, і саме тому екран не починається
                 від самого краю: `SafeArea` всередині застосунку читає їх і
                 лишає місце під годинник. Без цього рядка знімок виглядав як
                 екран без телефона. */
              child: MediaQuery(
                data: MediaQueryData(
                  size: logical,
                  padding: const EdgeInsets.only(top: _statusH, bottom: 10),
                ),
                /* Напрямок письма задається тут: смуга стоїть ПОВЕРХ
                   MaterialApp, а не в ньому, тож успадкувати його нема від
                   кого. */
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Stack(children: [child, const _StatusBar()]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Прокручує день на стільки пікселів, скільки просять.
  Future<void> scroll(WidgetTester tester, double by) async {
    await tester.drag(find.byType(TodayScreen), Offset(0, -by), warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  /// Знімок сцени: поставити, зняти, прибрати за собою.
  ///
  /// Розмиття тіней у тестах вимкнене, бо там зазвичай важливе розташування, а
  /// не вигляд. Тут навпаки. Без цього кожна тінь виходила суцільною плашкою з
  /// різким краєм, і найпомітніше це було над рядком Нори: замість тихої тіні
  /// там лежала сіра смуга завширшки з відступ тіні, якої в застосунку немає.
  ///
  /// Прапорець повертається тут же, а не в `tearDown`: фреймворк перевіряє його
  /// одразу після тіла тесту і падає, якщо його лишили зміненим.
  Future<void> shot(WidgetTester tester, String scene, Future<void> Function() pose) async {
    debugDisableShadows = false;
    try {
      await pose();
      await expectLater(
        find.byType(FittedBox).first,
        matchesGoldenFile('../../Store/shots/$lang-$scene.png'),
      );
    } finally {
      debugDisableShadows = true;
    }
  }

  testWidgets('$lang: головний екран', (tester) async {
    await shot(tester, 'day', () => mount(tester, app(lang)));
  });

  testWidgets('$lang: сніданок розгорнутий', (tester) async {
    await shot(tester, 'meal', () async {
      await mount(tester, app(lang, open: 'breakfast'));
      // Трохи вниз, щоб розгорнута картка стояла в кадрі цілком.
      await scroll(tester, 150);
    });
  });

  testWidgets('$lang: вага і ціль', (tester) async {
    await shot(tester, 'weight', () async {
      await mount(tester, app(lang));
      /* Чекаємо, поки колода перевернеться сама, а не тягнемо її пальцем.
         Потягування виглядало коротшим шляхом, але воно йде через боротьбу за
         жест: картка тягне вертикально, і сторінка під нею теж, а хто виграє,
         залежить від того, що ще стоїть на екрані. Один доданий шар згори, і
         знімок «ваги» тихо почав показувати калорії. Годинник картки такої
         залежності не має. */
      await tester.pump(const Duration(seconds: 17));
      await tester.pumpAndSettle();
    });
  });

  testWidgets('$lang: тренування', (tester) async {
    await shot(tester, 'workout', () async {
      await mount(tester, app(lang, open: 'workout'));
      await scroll(tester, 830);
    });
  });
}

/// Висота смуги з годинником, у логічних пікселях.
///
/// Знімок 1080 завширшки, смуга займає в ньому близько ста тридцяти рядків.
/// Тут вона перерахована на 390 логічних: 130 / 1080 × 390.
const _statusH = 47.0;

/// Верх справжнього знімка телефона: годинник, звʼязок, батарея.
///
/// Кладеться один раз у `setUpAll` і живе до кінця запуску.
late final ui.Image _status;

/// Системна смуга, взята зі знімка, а не намальована.
///
/// Малювати її наново означає вигадувати чужий пристрій: свій годинник, свої
/// значки, своя вага ліній. Поруч зі справжнім екраном це видно одразу. Тут
/// береться верхня смужка того самого знімка, з якого починалась робота, і
/// розтягується по ширині: пропорції збігаються, бо ширина в обох та сама.
class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) => Positioned(
    top: 0,
    left: 0,
    right: 0,
    height: _statusH,
    child: IgnorePointer(
      child: ClipRect(
        child: RawImage(
          image: _status,
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
          filterQuality: FilterQuality.medium,
        ),
      ),
    ),
  );
}
