import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/chat.dart';
import 'package:calvi/screens/today/bottom_bar.dart';
import 'package:calvi/screens/today/meal_card.dart';
import 'package:calvi/data/meal.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// Нижня панель відходить, поки людина пише в картку, і повертається, коли
/// набирання скінчилось.
///
/// Панель разом із клавіатурою накривала саме те поле, яке людина заповнює.
/// Перевіряється і сам відхід, і кожна з доріг назад: «плюс», скасування форми,
/// збереження форми, згортання картки, клавіатура, закрита ззовні. Дорога, яку
/// забули, лишає панель унизу назавжди.
void main() {
  Widget wrap(Widget child) => MaterialApp(
    localizationsDelegates: L.localizationsDelegates,
    supportedLocales: L.supportedLocales,
    locale: const Locale('uk'),
    theme: calviLightTheme,
    home: Scaffold(body: child),
  );

  group('панель', () {
    Widget bar({required bool away, bool open = false}) => wrap(
      BottomBar(
        slot: 'Обід',
        open: open,
        away: away,
        onOpen: (_) {},
        onClose: () {},
        onCamera: () {},
        onHold: (_, _) {},
        onLetGo: () {},
        onSend: (_) {},
        messages: const <Msg>[],
      ),
    );

    testWidgets('їде вниз поступово і глухне до дотиків цілком', (tester) async {
      await tester.pumpWidget(bar(away: false));
      await tester.pumpAndSettle();

      final slide = tester.widget<AnimatedSlide>(find.byType(AnimatedSlide).first);
      expect(slide.offset, Offset.zero);

      await tester.pumpWidget(bar(away: true));
      await tester.pump();

      /* Посеред дороги: транслейт уже не нуль і ще не кінцевий. Саме це
         відрізняє відхід від зникнення між двома кадрами. */
      await tester.pump(const Duration(milliseconds: 120));
      final going = tester.widget<AnimatedSlide>(find.byType(AnimatedSlide).first);
      expect(going.offset.dy, greaterThan(0), reason: 'панель не почала їхати');

      await tester.pumpAndSettle();
      expect(
        tester.widget<AnimatedSlide>(find.byType(AnimatedSlide).first).offset.dy,
        greaterThan(1),
        reason: 'панель не заїхала за край',
      );

      /* Глуха вся, разом із зовнішнім перехоплювачем і відступом клавіатури.
         Тут жила мертва зона: сховане полотно вже не ловило дотиків, а от
         невидимий перехоплювач «тап відкриває чат» ловив далі, і з клавіатурою
         його площа накривала пів екрана. */
      final numb = tester.widget<IgnorePointer>(
        find
            .ancestor(of: find.byType(AnimatedSlide).first, matching: find.byType(IgnorePointer))
            .first,
      );
      expect(numb.ignoring, isTrue, reason: 'захована панель досі ловить дотики');
    });

    testWidgets('мертвої зони немає: тап крізь заховану панель доходить до дня', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(
          MediaQuery(
            /* Клавіатура на триста пікселів: рівно та обставина, за якої зона
               виростала до половини екрана і зʼїдала «плюс», «Ввести числа
               самому», «Скасувати» і прокрутку дня. */
            data: const MediaQueryData(
              size: Size(800, 600),
              viewInsets: EdgeInsets.only(bottom: 300),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => taps++,
                    child: const SizedBox.expand(),
                  ),
                ),
                Positioned.fill(
                  child: BottomBar(
                    slot: 'Обід',
                    open: false,
                    away: true,
                    onOpen: (_) {},
                    onClose: () {},
                    onCamera: () {},
                    onHold: (_, _) {},
                    onLetGo: () {},
                    onSend: (_) {},
                    messages: const <Msg>[],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Смуга одразу над клавіатурою: там стоять поле картки і її кнопки.
      await tester.tapAt(const Offset(400, 260));
      expect(taps, 1, reason: 'мертва зона досі їсть дотики над клавіатурою');
    });

    testWidgets('відкритий чат сильніший за відхід: панель лишається', (tester) async {
      /* Штора, піднята за краєм екрана, це розмова, якої ніхто не побачить:
         Нора питає про вагу, а людина бачить вічне «рахує». */
      await tester.pumpWidget(bar(away: true, open: true));
      await tester.pumpAndSettle();

      expect(
        tester.widget<AnimatedSlide>(find.byType(AnimatedSlide).first).offset,
        Offset.zero,
        reason: 'панель сховалась разом із відкритим чатом',
      );
    });
  });

  group('сигнал від картки', () {
    late List<bool> told;

    Widget card({bool noraCan = true, bool open = true}) {
      return wrap(
        SingleChildScrollView(
          child: MealCard(
            slot: baseSlots['dinner']!,
            meals: const [],
            open: open,
            onToggle: () {},
            onAdd: (_) {},
            onManual: (_) {},
            noraCan: noraCan,
            onWriting: told.add,
          ),
        ),
      );
    }

    setUp(() => told = []);

    testWidgets('фокус у полі опускає, «плюс» повертає', (tester) async {
      await tester.pumpWidget(card());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(told, [true], reason: 'фокус не опустив панель');

      await tester.enterText(find.byType(TextField), 'Борщ 500 грам');
      await tester.pump();
      final l = await L.delegate.load(const Locale('uk'));
      await tester.tap(find.bySemanticsLabel(l.slotLog));
      await tester.pumpAndSettle();

      expect(told.last, isFalse, reason: '«плюс» не повернув панель');
    });

    testWidgets('форма тримає панель унизу до самого кінця', (tester) async {
      await tester.pumpWidget(card(noraCan: false));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'Плов');
      await tester.pump();
      final l = await L.delegate.load(const Locale('uk'));
      await tester.tap(find.bySemanticsLabel(l.slotLog));
      await tester.pumpAndSettle();

      /* Головне поле віддало фокус формі, але панель не має блимнути вгору між
         цими двома станами: набирання триває, просто тепер по пʼяти полях. */
      expect(told.contains(false), isFalse, reason: 'панель блимнула на відкритті форми');

      await tester.tap(find.text(l.slotCancel));
      await tester.pumpAndSettle();
      expect(told.last, isFalse, reason: 'скасування не повернуло панель');
    });

    testWidgets('збереження форми повертає панель', (tester) async {
      await tester.pumpWidget(card(noraCan: false));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'Плов');
      await tester.pump();
      final l = await L.delegate.load(const Locale('uk'));
      await tester.tap(find.bySemanticsLabel(l.slotLog));
      await tester.pumpAndSettle();

      // Калорії, без яких «Записати» не працює.
      await tester.enterText(find.byType(TextField).at(2), '480');
      await tester.pump();
      await tester.tap(find.text(l.slotLog));
      await tester.pumpAndSettle();

      expect(told.last, isFalse, reason: 'збереження не повернуло панель');
    });

    testWidgets('згорнута картка закриває форму і повертає панель', (tester) async {
      /* Складка не прибирає вміст із дерева. Форма, залишена відкритою в
         згорнутій картці, жила невидимою, тримала сигнал «пишу», і панель не
         поверталась до перезапуску застосунку. */
      await tester.pumpWidget(card(noraCan: false));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'Плов');
      await tester.pump();
      final l = await L.delegate.load(const Locale('uk'));
      await tester.tap(find.bySemanticsLabel(l.slotLog));
      await tester.pumpAndSettle();

      await tester.pumpWidget(card(noraCan: false, open: false));
      await tester.pumpAndSettle();

      expect(told.last, isFalse, reason: 'згорнута картка не відпустила панель');
    });

    testWidgets('клавіатура, закрита ззовні, відпускає поле і панель', (tester) async {
      /* Жест «назад» ховає клавіатуру, не питаючи Flutter: фокус лишається в
         полі, а панель повертається саме за сигналом «фокус пішов». Сигнал не
         приходив ніколи, і панель зникала до перезапуску. */
      addTearDown(tester.view.reset);

      await tester.pumpWidget(card());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(told, [true], reason: 'фокус не опустив панель');

      // Клавіатура встала...
      tester.view.viewInsets = const FakeViewPadding(bottom: 600);
      await tester.pump();

      // ...і зникла повз застосунок, жестом «назад».
      tester.view.viewInsets = FakeViewPadding.zero;
      await tester.pumpAndSettle();

      expect(told.last, isFalse, reason: 'поле тримає фокус без клавіатури');
    });
  });
}
