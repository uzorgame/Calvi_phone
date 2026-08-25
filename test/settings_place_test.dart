import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/shell.dart';
import 'package:calvi/design/icons.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/main.dart';
import 'package:calvi/screens/settings/settings_screen.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// Налаштування памʼятають, де ти був.
///
/// Дві скарги, і вони різні. Вибір усередині панелі викидав із неї назад у
/// список, ніби кожен варіант це «обрати і вийти». А повернення зі сторінки
/// щоразу приземляло на початок списку, хоч «Тема» лежить у ньому далеко внизу:
/// щоб повернутись туди, звідки пішов, доводилось гортати наново.
void main() {
  Widget wrap() {
    var s = initialSettings();
    return StatefulBuilder(
      builder: (context, setState) => AppScope(
        s: s,
        set: (patch) => setState(() => s = patch(s)),
        meds: const [],
        setMeds: (_) {},
        child: MaterialApp(
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          locale: const Locale('uk'),
          /* Обидві теми і режим від налаштувань, як у `main.dart`. Стенд лише зі
             світлою темою нічого не перемикає, тому скарга «вибрав тему і мене
             викинуло» на ньому не відтворюється: вибір проходить, а застосунок
             при цьому не перебудовується. */
          theme: calviLightTheme,
          darkTheme: calviDarkTheme,
          themeMode: switch (s.theme) {
            AppTheme.light || AppTheme.aquarelle || AppTheme.dawn => ThemeMode.light,
            AppTheme.dark => ThemeMode.dark,
            AppTheme.system => ThemeMode.system,
          },
          scrollBehavior: const CalviScroll(),
          home: const SettingsScreen(),
        ),
      ),
    );
  }

  /* Прокрут усередині налаштувань, хай там зараз список чи панель.
   *
   * Не `Scrollable.first`: у справжньому застосунку під налаштуваннями лишається
   * день зі стрічкою тижня і власним списком, і перший-ліпший прокрут виявився
   * чужим. І не пошук від напису «Налаштування»: прогорнутий заголовок виходить
   * із дерева, і прив'язка до нього розсипається саме тоді, коли потрібна. */
  final list = find.descendant(of: find.byType(SettingsScreen), matching: find.byType(Scrollable)).first;

  /// Скільки той список прогорнули.
  double where(WidgetTester tester) =>
      tester.state<ScrollableState>(list).position.pixels;

  /// Прогорнути список і відкрити рядок, який після цього видно.
  Future<void> openThemeFarDown(WidgetTester tester) async {
    await tester.drag(list, const Offset(0, -420));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Тема'));
    await tester.pumpAndSettle();
  }

  testWidgets('вибір усередині панелі лишає в панелі', (tester) async {
    // Низький екран навмисно: список має не вміщатись, інакше немає що губити.
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
    await openThemeFarDown(tester);

    expect(find.text('Темна'), findsOneWidget, reason: 'панель теми не відкрилась');

    await tester.tap(find.text('Темна'));
    await tester.pumpAndSettle();

    /* Найважливіше: людина лишається там, де обирала, і бачить, що змінилось.
       Вибір теми це не вихід. */
    expect(
      find.text('Темна'),
      findsOneWidget,
      reason: 'вибір теми викинув із панелі назад у список',
    );
    expect(find.text('Налаштування'), findsNothing, reason: 'список виліз поверх панелі');
  });

  testWidgets('повернення зі сторінки приземляє туди, звідки пішов', (tester) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.drag(list, const Offset(0, -420));
    await tester.pumpAndSettle();
    final left = where(tester);
    expect(left, greaterThan(100), reason: 'список не прогорнувся, перевіряти нічого');

    await tester.tap(find.text('Тема'));
    await tester.pumpAndSettle();
    expect(find.text('Налаштування'), findsNothing);

    await tester.tap(find.byType(CalviBack).last);
    await tester.pumpAndSettle();

    /* Не по слову «Налаштування»: коли все правильно, заголовок лишається
       прогорнутим за верхній край і його в дереві немає. Ознака повернення це
       зниклий вміст панелі й видимий рядок, з якого пішли. */
    expect(find.text('Темна'), findsNothing, reason: 'панель не закрилась');
    expect(find.text('Тема'), findsOneWidget, reason: 'рядка, з якого пішли, не видно');
    /* З допуском на піксель: важить те, що людина бачить те саме місце, а не
       побітова рівність числа. */
    expect(
      where(tester),
      closeTo(left, 1),
      reason: 'список відкрився згори, а не там, де його лишили',
    );
  });

  /* І те саме після зміни значення, бо саме так це роблять: заходять, міняють,
     виходять. Дві попередні перевірки поодинці цього не ловлять. */
  testWidgets('змінив і вийшов: місце в списку теж на місці', (tester) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.drag(list, const Offset(0, -420));
    await tester.pumpAndSettle();
    final left = where(tester);

    await tester.tap(find.text('Тема'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Темна'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CalviBack).last);
    await tester.pumpAndSettle();

    expect(find.text('Тема'), findsOneWidget, reason: 'рядка, з якого пішли, не видно');
    expect(where(tester), closeTo(left, 1), reason: 'після зміни місце загубилось');
  });

  /* І те саме на самому застосунку, а не на стенді.
   *
   * Стенд тримає налаштування в `home`, а насправді вони їдуть окремим
   * маршрутом поверх дня, і зміна теми перебудовує все дерево від кореня. Саме
   * тут скарга «змінив тему і мене викинуло» мала б проявитись, якщо вона про
   * втрату стану, а не про втрату місця в списку. */
  testWidgets('у справжньому застосунку вибір теми теж лишає в панелі', (tester) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = const [Locale('uk')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const CalviApp(storage: false));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Почати'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.text('Далі'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Поки без входу'));
    await tester.pumpAndSettle();

    await tester.tap(find.byWidgetPredicate((w) => w is CalviIcon && w.name == 'settings'));
    await tester.pumpAndSettle();
    expect(find.text('Налаштування'), findsOneWidget, reason: 'налаштування не відкрились');

    await tester.drag(list, const Offset(0, -420));
    await tester.pumpAndSettle();
    final left = where(tester);

    await tester.tap(find.text('Тема'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Темна'));
    await tester.pumpAndSettle();

    expect(find.text('Темна'), findsOneWidget, reason: 'вибір теми викинув із панелі');

    /* І тонована світла так само. Її ґрунт малюється окремим шаром поверх
       сторінки, і якби шар зʼявлявся тільки на цій темі, форма дерева мінялась
       би на перемиканні, і вся ця історія повторилася б із нею. */
    await tester.tap(find.text('Акварель'));
    await tester.pumpAndSettle();
    expect(find.text('Акварель'), findsOneWidget, reason: 'вибір акварелі викинув із панелі');

    await tester.tap(find.byType(CalviBack).last);
    await tester.pumpAndSettle();
    expect(where(tester), closeTo(left, 1), reason: 'місце в списку загубилось');
  });
}
