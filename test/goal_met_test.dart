import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/day.dart';
import 'package:calvi/data/fixtures.dart';
import 'package:calvi/data/day_stats.dart';
import 'package:calvi/data/week.dart';
import 'package:calvi/screens/today/bottom_bar.dart';
import 'package:calvi/screens/today/hero_card.dart';
import 'package:calvi/data/chat.dart';

/* Ціль узята: Нора вітає і переставляє норму на утримання.
 *
 * Правило живе в корені застосунку, бо ваги в нього три дороги: картка
 * вимірювань, панель у налаштуваннях і слова Норі. Перевіряється тут його
 * арифметика і те, що вітання не спамить.
 */
void main() {
  /// Правило одним рядком, як воно стоїть у `_goalMet`.
  bool reached(SettingsState s) =>
      s.direction != Direction.keep && (s.weightKg - s.targetKg).abs() <= 0.3;

  SettingsState person({
    required double weight,
    required double target,
    required Direction dir,
  }) => initialSettings().copyWith(
    weightKg: weight,
    goalStartKg: 80,
    targetKg: target,
    direction: dir,
  );

  test('вага дійшла до цілі, і в межах трьохсот грамів це вже ціль', () {
    expect(reached(person(weight: 74.0, target: 74, dir: Direction.lose)), isTrue);
    expect(reached(person(weight: 74.3, target: 74, dir: Direction.lose)), isTrue);
    expect(reached(person(weight: 73.7, target: 74, dir: Direction.lose)), isTrue);
    expect(reached(person(weight: 86.2, target: 86, dir: Direction.gain)), isTrue);
  });

  test('поки не дійшла, мовчимо', () {
    expect(reached(person(weight: 74.4, target: 74, dir: Direction.lose)), isFalse);
    expect(reached(person(weight: 78.0, target: 74, dir: Direction.lose)), isFalse);
  });

  /* Той, хто від початку тримає вагу, не має чути цього ніколи: цілі в нього не
     було, і вітати нема з чим. Це ж і захист від повторів, бо після переходу на
     утримання напрямок саме такий. */
  test('«тримати вагу» не вітається ніколи', () {
    expect(reached(person(weight: 80, target: 80, dir: Direction.keep)), isFalse);
    expect(reached(person(weight: 74, target: 74, dir: Direction.keep)), isFalse);
  });

  test('норма після переходу рахується від досягнутої ваги, а не від старої', () {
    final before = initialSettings().copyWith(
      sex: Sex.m,
      age: 26,
      heightCm: 178,
      weightKg: 74,
      goalStartKg: 80,
      targetKg: 74,
      direction: Direction.lose,
      pace: 0.5,
      activity: 1.55,
    );

    // Те, що робить `_goalMet`: напрямок і вага старту переїжджають на досягнуту.
    final after = before.copyWith(
      direction: Direction.keep,
      goalStartKg: before.weightKg,
      targetKg: before.weightKg,
    );

    expect(calcKcal(before), 2220, reason: 'дефіцит від ваги, з якої починали');
    expect(calcKcal(after), 2670, reason: 'утримання від тіла, яке є зараз');
    expect(weeksToTarget(after), 0);

    /* Розкладка їде за нормою, а не лишається від старої.
     *
     * Калорії рахуються з напрямку щоразу заново, а білок, жири й вуглеводи
     * лежать у налаштуваннях числами: без окремого рядка в `_goalMet` картка
     * дня показувала 2670 і під ним розкладку на 2220. */
    final m = macrosFor(after);
    expect((m.protein, m.fat, m.carbs), (126, 83, 355));
    expect(
      m.protein * 4 + m.fat * 9 + m.carbs * 4,
      closeTo(calcKcal(after), 5),
      reason: 'сума розкладки сходиться з числом над нею',
    );
  });

  /* Своя норма лишається своєю. Ручне число означає, що людина взяла розкладку
     собі, і переписувати її від імені формули значило б відібрати зроблене
     руками. */
  test('ручна норма при переході не переписується', () {
    final mine = initialSettings().copyWith(
      kcalManual: 2400,
      protein: 150,
      fat: 70,
      carbs: 280,
      weightKg: 74,
      targetKg: 74,
      direction: Direction.lose,
    );

    expect(dailyKcal(mine), 2400);
    expect((mine.protein, mine.fat, mine.carbs), (150, 70, 280));
  });

  /* Разом зі словами міняється число на картці дня, і воно теж це показує:
     норма крутиться і зупиняється на новій, тим самим рухом, яким її рахували
     вперше на «Твоїй нормі». */
  testWidgets('норма на картці дня перераховується на очах', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Widget card({required bool recount}) => AppScope(
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
      home: Scaffold(
        body: HeroCard(
          date: todayDate,
          day: dayFor(0),
          burned: 0,
          goal: const DayGoal(kcal: 2670, protein: 136, fat: 83, carbs: 264, waterMl: 2000),
          week: weekSummary(DayStats.demo(), initialSettings()),
          onWeek: () {},
          recount: recount,
        ),
        ),
      ),
    );

    // Спокійна картка показує норму як є.
    await tester.pumpWidget(card(recount: false));
    await tester.pump();
    expect(find.textContaining('2 670'), findsWidgets, reason: 'норма на місці');

    // А та, якій сказали перерахувати, спершу крутить чуже число.
    await tester.pumpWidget(card(recount: true));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.textContaining('2 670'),
      findsNothing,
      reason: 'поки крутиться, справжньої норми на екрані немає',
    );

    // І зупиняється на своїй.
    await tester.pump(const Duration(milliseconds: 1600));
    expect(find.textContaining('2 670'), findsWidgets, reason: 'зупинилась на новій');
  });

  testWidgets('вітання малюється карткою, а не бульбашкою', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: Scaffold(
          body: BottomBar(
            slot: 'Обід',
            open: true,
            onOpen: (_) {},
            onClose: () {},
            onCamera: () {},
            onHold: (_, _) {},
            onLetGo: () {},
            onSend: (_) {},
            messages: [
              msg(from: MsgFrom.nora, text: 'Я вас вітаю!', card: true),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    /* Картка це той самий віджет, що вітає в порожній розмові: бейдж і текст на
       білому. Кнопки в неї немає, вона нікуди не веде. */
    expect(find.text('N'), findsOneWidget, reason: 'бейдж Нори на місці');
    expect(find.text('Я вас вітаю!'), findsOneWidget);
    expect(find.text('Підписка'), findsNothing, reason: 'це не тарифи');
  });
}
