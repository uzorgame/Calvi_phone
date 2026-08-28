import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/fixtures.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/data/day_stats.dart';
import 'package:calvi/data/week.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/today/hero_card.dart';
import 'package:calvi/screens/today/today_screen.dart';

/// Картка ккал і кг завжди доїжджає до кінця.
///
/// Дві сторони живуть в одній коробці й проявляються одна крізь одну. Поки
/// картка повертається, видно обидві, і це нормально рівно пів секунди. Якщо
/// поворот десь застряг, обидві сторони лишаються на екрані назавжди, і людина
/// читає число калорій крізь число ваги.
void main() {
  Future<void> card(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      AppScope(
        s: initialSettings(),
        set: (_) {},
        meds: const [],
        setMeds: (_) {},
        real: false,
        setReal: (_) {},
        child: MaterialApp(
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          locale: const Locale('uk'),
          theme: calviLightTheme,
          /* Тестовий шрифт ширший за справжній, і сторона ваги не влазить у
             коробку, задану стороною калорій. Тут міряється поворот, а не
             розкладка, тож шрифт трохи зменшений. За розкладку відповідає
             hero_flip_test. */
          builder: (context, child) => MediaQuery.withNoTextScaling(
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.6)),
              child: child!,
            ),
          ),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HeroCard(
                  day: dayFor(0),
                  burned: 0,
                  goal: goalOf(initialSettings()),
                  week: _week,
                  onWeek: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  /// Прозорості обох сторін просто зараз.
  List<double> sides(WidgetTester tester) =>
      tester.widgetList<Opacity>(find.byType(Opacity)).map((o) => o.opacity).toList();

  /// Чи картка стоїть на цілій стороні: одна видима, друга ні.
  bool resting(List<double> at) =>
      at.length >= 2 && at.every((o) => o < 0.01 || o > 0.99) && at.any((o) => o > 0.99);

  testWidgets('картка доїжджає до цілої сторони і не зависає між ними', (tester) async {
    await card(tester);

    /* Хвилина життя картки маленькими кроками. Калорії тримають її шістнадцять
       секунд, вага сім, а сам поворот трохи більше за пів секунди: за хвилину
       поворотів буде кілька, і кожен має закінчитись. */
    final stuck = <String>[];
    var turning = 0;

    for (var step = 0; step < 600; step++) {
      await tester.pump(const Duration(milliseconds: 100));
      final at = sides(tester);
      if (resting(at)) {
        turning = 0;
        continue;
      }
      turning++;
      // Поворот триває 520 мс. Півтори секунди це вже не поворот, а зависання.
      if (turning > 15) stuck.add('крок $step: $at');
    }

    expect(stuck, isEmpty, reason: 'картка зависла між сторонами:\n${stuck.take(3).join('\n')}');
  });

  testWidgets('згорнутий застосунок не лишає колоду ребром', (tester) async {
    await card(tester);

    /* Поворот у розпалі, і саме тут застосунок згортають. Кадри припиняються,
       і без окремого рядка колода застигає посередині: обидві сторони видно
       одночасно, і саме таким застосунок потрапляє в перелік недавніх. */
    await tester.drag(find.byType(HeroCard), const Offset(0, -60));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(resting(sides(tester)), isFalse, reason: 'поворот не почався, перевіряти нічого');

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();

    expect(resting(sides(tester)), isTrue, reason: 'колода лишилась ребром: ${sides(tester)}');

    // А на поверненні годинник заводиться назад і колода живе далі.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    var turned = false;
    for (var step = 0; step < 300; step++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (!resting(sides(tester))) turned = true;
    }
    expect(turned, isTrue, reason: 'після повернення колода більше не повертається');
  });

  testWidgets('картка й далі повертається після дотику', (tester) async {
    await card(tester);

    // Коротке потягування вгору і назад: людина зачепила картку, гортаючи день.
    await tester.drag(find.byType(HeroCard), const Offset(0, -4));
    await tester.pump(const Duration(seconds: 2));

    var turned = false;
    for (var step = 0; step < 400; step++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (!resting(sides(tester))) turned = true;
    }

    expect(turned, isTrue, reason: 'після дотику картка більше не повертається ніколи');
  });

  /* Годинник колоди на живому екрані, після всього, що надсилає система.
   *
   * Тут ховалась справжня втрата. Годинник гасився на кожному стані, крім
   * `resumed`, а заводився назад тільки на ньому. `inactive` Android надсилає
   * у геть буденних ситуаціях, від шторки сповіщень до чужого вікна поверх
   * застосунку, і `resumed` після нього приходить не завжди. Один такий
   * випадок, і колода стояла нерухомо до перезапуску.
   *
   * Перевіряється на самому TodayScreen, а не на голій картці: годинник має
   * пережити рівно те, що переживає застосунок. */
  group('годинник колоди переживає життєвий цикл', () {
    Future<void> day(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        AppScope(
          s: initialSettings(),
          set: (_) {},
          meds: const [],
          setMeds: (_) {},
          real: false,
          setReal: (_) {},
          child: MaterialApp(
            localizationsDelegates: L.localizationsDelegates,
            supportedLocales: L.supportedLocales,
            locale: const Locale('uk'),
            theme: calviLightTheme,
            scrollBehavior: const CalviScroll(),
            home: TodayScreen(onSettings: () {}, onMeds: () {}),
          ),
        ),
      );
      await tester.pump();
    }

    /// Чи колода почала повертатись протягом наступних двадцяти п'яти секунд.
    ///
    /// Прозорості беруться всередині картки, а не по всьому екрану: на дні
    /// повно інших прозорих шарів, і по них перевірка казала б «так» завжди.
    Future<bool> turns(WidgetTester tester) async {
      for (var step = 0; step < 250; step++) {
        await tester.pump(const Duration(milliseconds: 100));
        final at = tester
            .widgetList<Opacity>(
              find.descendant(of: find.byType(HeroCard), matching: find.byType(Opacity)),
            )
            .map((o) => o.opacity);
        if (at.any((o) => o > 0.02 && o < 0.98)) return true;
      }
      return false;
    }

    Future<void> send(WidgetTester tester, List<AppLifecycleState> states) async {
      for (final s in states) {
        tester.binding.handleAppLifecycleStateChanged(s);
        await tester.pump();
      }
    }

    testWidgets('без нічого', (tester) async {
      await day(tester);
      expect(await turns(tester), isTrue);
    });

    testWidgets('після повного кола у фон і назад', (tester) async {
      await day(tester);
      await send(tester, const [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]);
      expect(await turns(tester), isTrue);
    });

    testWidgets('після самого inactive, без повернення', (tester) async {
      await day(tester);
      await send(tester, const [AppLifecycleState.inactive]);
      expect(
        await turns(tester),
        isTrue,
        reason: 'годинник згас на inactive і його нікому завести',
      );
    });

    testWidgets('після кількох втрат фокуса поспіль', (tester) async {
      await day(tester);
      /* Стану hidden тут навмисно немає, і це не забудькуватість. На ньому
         система вимикає кадри взагалі, бо застосунка не видно, і нерухома
         колода там єдина правильна поведінка. А inactive це втрата фокуса при
         видимому екрані: шторка сповіщень, чуже вікно поверх, системне
         запитання. Ось після нього колода мусить жити далі. */
      await send(tester, const [
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
        AppLifecycleState.inactive,
      ]);
      expect(await turns(tester), isTrue);
    });
  });
}

/// Показовий тиждень для картки: сторона тижня читає готове зведення.
final _week = weekSummary(DayStats.demo(), initialSettings());
