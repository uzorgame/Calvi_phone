import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/day_stats.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/data/week.dart';
import 'package:calvi/design/fold.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/week/week_screen.dart';

/// Стани блока Нори на сторінці тижня.
///
/// У будні прогрес-лінія «буде доступна в пʼятницю», з вечора пʼятниці кнопка
/// з ціною, а «Минулі» стоять унизу завжди. Стан, показаний не в свій час, це
/// обіцянка, яку сторінка не стримає.
void main() {
  Widget wrap({bool real = false, DateTime? now}) => AppScope(
    s: initialSettings(),
    set: (_) {},
    meds: const [],
    setMeds: (_) {},
    stats: DayStats.demo(),
    real: real,
    child: MaterialApp(
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      locale: const Locale('uk'),
      theme: calviLightTheme,
      home: WeekScreen(
        summary: weekSummary(DayStats.demo(), initialSettings()),
        onSettings: () {},
        now: now,
      ),
    ),
  );

  testWidgets('у середу замість кнопки прогрес-лінія', (tester) async {
    await tester.pumpWidget(wrap(real: true, now: DateTime(2026, 8, 26, 12)));
    await tester.pumpAndSettle();

    final l = await L.delegate.load(const Locale('uk'));
    expect(find.text(l.wkNoraLocked), findsOneWidget, reason: 'лінії очікування немає');
    expect(find.byKey(const Key('wk-locked')), findsOneWidget);
    expect(find.text(l.wkNoraBtn), findsNothing, reason: 'кнопка стоїть у зачинений час');
  });

  testWidgets('у пʼятницю ввечері кнопка з ціною у два токени', (tester) async {
    await tester.pumpWidget(wrap(real: true, now: DateTime(2026, 8, 28, 19)));
    await tester.pumpAndSettle();

    final l = await L.delegate.load(const Locale('uk'));
    expect(find.text(l.wkNoraBtn), findsOneWidget, reason: 'кнопки немає у відчинений час');
    expect(find.text(l.wkNoraPromise), findsOneWidget, reason: 'запрошення без обіцянки');
    expect(find.text(l.wkNoraLocked), findsNothing);
  });

  testWidgets('шапка розбору стоїть у кожному стані', (tester) async {
    /* Блок Нори не міняє своєї подоби: заголовок картки той самий і в будні,
       коли розбір ще зачинений, і у вихідні, коли його пропонують збудувати, і
       коли він уже написаний. Доти сторінка на першому вході встигала показати
       дві різні картки поспіль і смикалась. */
    final l = await L.delegate.load(const Locale('uk'));
    final head = l.wkNoraTitle.toUpperCase();

    // Середа: зачинено.
    await tester.pumpWidget(wrap(real: true, now: DateTime(2026, 8, 26, 12)));
    await tester.pumpAndSettle();
    expect(find.text(head), findsOneWidget, reason: 'у будні картка без шапки');
    expect(find.text(l.wkNoraLocked), findsOneWidget);

    // Пʼятниця ввечері: відчинено, і в тій самій картці стоїть кнопка.
    await tester.pumpWidget(wrap(real: true, now: DateTime(2026, 8, 28, 19)));
    await tester.pumpAndSettle();
    expect(find.text(head), findsOneWidget, reason: 'у вихідні картка без шапки');
    expect(find.text(l.wkNoraBtn), findsOneWidget);
  });

  testWidgets('демо не замикається на будні: вітрина показує кнопку', (tester) async {
    await tester.pumpWidget(wrap(now: DateTime(2026, 8, 26, 12)));
    await tester.pumpAndSettle();

    final l = await L.delegate.load(const Locale('uk'));
    expect(find.text(l.wkNoraBtn), findsOneWidget, reason: 'демо сховало кнопку в середу');
  });

  testWidgets('картка розбору згортається і розгортається стрілкою', (tester) async {
    /* Розбір читають раз, а сторінку відкривають усі вихідні: картка мусить
       вміти складатись тим самим рухом, що й картки дня, і казати стрілкою,
       куди поведе дотик. */
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(now: DateTime(2026, 8, 28, 19)));
    await tester.pumpAndSettle();

    final l = await L.delegate.load(const Locale('uk'));
    await tester.tap(find.text(l.wkNoraBtn));
    await tester.pump(const Duration(milliseconds: 2400));
    await tester.pumpAndSettle();

    // Щойно збудований розбір відкритий: його ще не читали.
    CalviFold fold() => tester.widget<CalviFold>(
      find
          .ancestor(
            of: find.textContaining('Основа в тебе здорова'),
            matching: find.byType(CalviFold),
          )
          .first,
    );
    expect(fold().open, isTrue, reason: 'свіжий розбір зустрічає згорнутим');

    // Дотик по шапці складає, другий розкладає.
    await tester.tap(find.text(l.wkNoraTitle.toUpperCase()));
    await tester.pumpAndSettle();
    expect(fold().open, isFalse, reason: 'шапка не згорнула картку');

    await tester.tap(find.text(l.wkNoraTitle.toUpperCase()));
    await tester.pumpAndSettle();
    expect(fold().open, isTrue, reason: 'шапка не розгорнула назад');
  });

  testWidgets('«Минулі» стоять унизу, і в демо їх видно з текстом', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(now: DateTime(2026, 8, 28, 19)));
    await tester.pumpAndSettle();

    final l = await L.delegate.load(const Locale('uk'));
    /* До самого рядка, а не до заголовка секції: заголовок може стояти
       останнім видимим рядком, і тап по рядку під ним піде в порожнечу.
       scrollUntilVisible зупиняється на першому видимому пікселі, тому далі
       ensureVisible витягає рядок цілим. */
    await tester.scrollUntilVisible(
      find.text(l.wkPastRow('17.08.2026')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text(l.wkPastRow('17.08.2026')));
    await tester.pumpAndSettle();

    // Два показові тижні, назвами їхніх понеділків.
    expect(find.text(l.wkPastRow('17.08.2026')), findsOneWidget, reason: 'минулого тижня немає');
    expect(find.text(l.wkPastRow('10.08.2026')), findsOneWidget);

    // Рядок відкривається аркушем із текстом розбору.
    await tester.tap(find.text(l.wkPastRow('17.08.2026')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Основа в тебе здорова'),
      findsOneWidget,
      reason: 'аркуш минулого розбору порожній',
    );
  });

  testWidgets('порожній тиждень не ховає «Минулих»', (tester) async {
    /* Кожен новий тиждень починається порожнім. Якби порожня сторінка ховала
       архів, минулі розбори зникали б рівно з понеділка: саме тоді, коли туди
       переїхав свіжий. */
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      AppScope(
        s: initialSettings(),
        set: (_) {},
        meds: const [],
        setMeds: (_) {},
        stats: DayStats.empty,
        child: MaterialApp(
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          locale: const Locale('uk'),
          theme: calviLightTheme,
          home: WeekScreen(
            summary: weekSummary(DayStats.empty, initialSettings()),
            onSettings: () {},
            now: DateTime(2026, 8, 31, 9),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final l = await L.delegate.load(const Locale('uk'));
    expect(find.text(l.wkEmpty), findsOneWidget, reason: 'порожній тиждень не сказав про себе');
    expect(find.text(l.wkPastTitle), findsOneWidget, reason: 'архів зник разом із записами');
  });

  testWidgets('у «моїх» без жодного розбору «Минулі» чесно порожні', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(real: true, now: DateTime(2026, 8, 26, 12)));
    await tester.pumpAndSettle();

    final l = await L.delegate.load(const Locale('uk'));
    await tester.scrollUntilVisible(
      find.text(l.wkPastTitle),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(l.wkPastEmpty), findsOneWidget, reason: 'порожній архів мовчить');
  });
}
