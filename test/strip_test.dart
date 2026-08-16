import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/day.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/today/week_strip.dart';

void main() {
  test('стрічка закінчується неділею поточного тижня, не пізніше', () {
    expect(dayInfo(0).label, 'СБ', reason: 'фікстури стоять на суботі');

    final last = stripRun.last;
    expect(dayInfo(last).label, 'НД', reason: 'останній день це неділя');
    expect(last, lessThanOrEqualTo(6), reason: 'неділя цього тижня: зміщення $last');
    expect(stripRun.contains(todayDate), true);
    expect(stripRun.length, historyDays + 1);
  });

  testWidgets('відкрита стрічка стоїть на цьому тижні', (tester) async {
    tester.view.physicalSize = const Size(390, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: calviLightTheme,
        home: Scaffold(
          body: WeekStrip(date: todayDate, onPick: (_) {}),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    /* Everything actually on screen, by the pixel: a cell built but scrolled out
       of the viewport is not a cell anybody can see, and the whole point of the
       run ending on Sunday is that the current week is what opens. */
    final visible = <int>[];
    for (final date in stripRun) {
      final cell = find.text('${dayInfo(date).day}');
      if (cell.evaluate().isEmpty) continue;
      final box = tester.getRect(cell);
      if (box.left >= 0 && box.right <= 390) visible.add(date);
    }

    expect(visible, isNotEmpty);
    expect(
      visible.contains(todayDate),
      true,
      reason: 'сьогодні має бути в кадрі одразу, а видно $visible',
    );
    expect(
      visible.last,
      lessThanOrEqualTo(stripRun.last),
      reason: 'стрічка не має заїжджати за кінець свого ж діапазону',
    );
  });

  testWidgets('після зміни ширини стрічка лишається на тому самому дні', (tester) async {
    tester.view.physicalSize = const Size(390, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: calviLightTheme,
        home: Scaffold(
          body: WeekStrip(date: todayDate, onPick: (_) {}),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    /* An offset is pixels, and a cell is a different number of them at a
       different width. Rotating the phone used to leave the strip wherever that
       arithmetic happened to land, which was usually not on this week. */
    tester.view.physicalSize = const Size(430, 300);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final visible = <int>[];
    for (final date in stripRun) {
      final cell = find.text('${dayInfo(date).day}');
      if (cell.evaluate().isEmpty) continue;
      final box = tester.getRect(cell);
      if (box.left >= 0 && box.right <= 430) visible.add(date);
    }

    expect(visible.contains(todayDate), true, reason: 'після зміни ширини видно $visible');
  });

  testWidgets('стрічка приземляється, навіть якщо перший кадр був іншої ширини', (tester) async {
    /* What the web does on start: one frame at whatever size the canvas was
       created with, then the real one. The strip used to take its single jump
       on that throwaway layout and spend the rest of the session parked months
       back, which is exactly what the phone showed. */
    tester.view.physicalSize = const Size(800, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: calviLightTheme,
        home: Scaffold(
          body: WeekStrip(date: todayDate, onPick: (_) {}),
        ),
      ),
    );
    tester.view.physicalSize = const Size(390, 300);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final visible = <int>[];
    for (final date in stripRun) {
      final cell = find.text('${dayInfo(date).day}');
      if (cell.evaluate().isEmpty) continue;
      final box = tester.getRect(cell);
      if (box.left >= 0 && box.right <= 390) visible.add(date);
    }

    expect(visible.contains(todayDate), true, reason: 'після першого кадру видно $visible');
  });
}
