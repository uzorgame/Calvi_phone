import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/today/bottom_bar.dart';

/// The corners of the chat, read off the painted pixels rather than off the code.
///
/// Every earlier attempt at this checked what the widgets were asked to draw,
/// which is not the same question: a rounded decoration under a square child
/// passes that check and still shows a square corner on the screen.
void main() {
  testWidgets('верхні кути панелі справді зрізані, нижні ні', (tester) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final key = GlobalKey();

    await tester.pumpWidget(
      AppScope(
        s: initialSettings(),
        set: (_) {},
        meds: const [],
        setMeds: (_) {},
        child: MaterialApp(
          theme: calviLightTheme,
          home: Scaffold(
            // Ink behind the panel, so a corner that is cut shows it through.
            backgroundColor: const Color(0xFF000000),
            // Full height, the way the day screen mounts it: the veil needs a
            // screen to cover, or the stack shrinks to the bar alone.
            body: RepaintBoundary(
              key: key,
              child: SizedBox.expand(
                child: BottomBar(
                  slot: 'Обід',
                  messages: const [],
                  open: true,
                  onOpen: (_) {},
                  onClose: () {},
                  onSend: (_) {},
                  onCamera: () {},
                  onVoice: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    late ui.Image shot;
    late ByteData bytes;
    await tester.runAsync(() async {
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      shot = await boundary.toImage();
      bytes = (await shot.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    });

    int at(int x, int y) {
      final i = (y * shot.width + x) * 4;
      return bytes.getUint8(i) << 16 | bytes.getUint8(i + 1) << 8 | bytes.getUint8(i + 2);
    }

    /* The first bright row down the middle is the panel; everything above it is
       the scrim over black. A cut corner shows scrim, not panel. */
    bool bright(int c) => (c >> 16 & 0xFF) > 200 && (c >> 8 & 0xFF) > 200 && (c & 0xFF) > 200;

    var top = -1;
    for (var y = 0; y < shot.height; y++) {
      if (bright(at(shot.width ~/ 2, y))) {
        top = y;
        break;
      }
    }
    expect(top, greaterThan(0), reason: 'панелі не видно взагалі');

    final left = at(2, top + 2);
    final right = at(shot.width - 3, top + 2);

    expect(
      bright(left),
      isFalse,
      reason: 'лівий верхній кут не зрізаний: у ньому ${left.toRadixString(16)}',
    );
    expect(
      bright(right),
      isFalse,
      reason: 'правий верхній кут не зрізаний: у ньому ${right.toRadixString(16)}',
    );

    // And the bottom is left alone: the demo rounds only the top.
    final bottomLeft = at(2, shot.height - 3);
    expect(
      bright(bottomLeft),
      isTrue,
      reason: 'нижній кут теж зрізало, а знизу панель має бути прямою',
    );
  });

  testWidgets('опущена панель теж має зрізані верхні кути', (tester) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final key = GlobalKey();

    await tester.pumpWidget(
      AppScope(
        s: initialSettings(),
        set: (_) {},
        meds: const [],
        setMeds: (_) {},
        child: MaterialApp(
          theme: calviLightTheme,
          home: Scaffold(
            // Ink behind the panel, so a corner that is cut shows it through.
            backgroundColor: const Color(0xFF000000),
            // Full height, the way the day screen mounts it: the veil needs a
            // screen to cover, or the stack shrinks to the bar alone.
            body: RepaintBoundary(
              key: key,
              child: SizedBox.expand(
                child: BottomBar(
                  slot: 'Обід',
                  messages: const [],
                  open: false,
                  onOpen: (_) {},
                  onClose: () {},
                  onSend: (_) {},
                  onCamera: () {},
                  onVoice: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    late ui.Image shot;
    late ByteData bytes;
    await tester.runAsync(() async {
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      shot = await boundary.toImage();
      bytes = (await shot.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    });

    int at(int x, int y) {
      final i = (y * shot.width + x) * 4;
      return bytes.getUint8(i) << 16 | bytes.getUint8(i + 1) << 8 | bytes.getUint8(i + 2);
    }

    /* The first bright row down the middle is the panel; everything above it is
       the scrim over black. A cut corner shows scrim, not panel. */
    bool bright(int c) => (c >> 16 & 0xFF) > 200 && (c >> 8 & 0xFF) > 200 && (c & 0xFF) > 200;

    var top = -1;
    for (var y = 0; y < shot.height; y++) {
      if (bright(at(shot.width ~/ 2, y))) {
        top = y;
        break;
      }
    }
    expect(top, greaterThan(0), reason: 'панелі не видно взагалі');

    final left = at(2, top + 2);
    final right = at(shot.width - 3, top + 2);

    expect(
      bright(left),
      isFalse,
      reason: 'лівий верхній кут не зрізаний: у ньому ${left.toRadixString(16)}',
    );
    expect(
      bright(right),
      isFalse,
      reason: 'правий верхній кут не зрізаний: у ньому ${right.toRadixString(16)}',
    );

    // The middle of that same row is the panel, so the reading above is a
    // corner being cut and not the whole bar sitting lower than we looked.
    expect(
      bright(at(shot.width ~/ 2, top + 2)),
      isTrue,
      reason: 'середина верхнього краю не панель, вимір не про кути',
    );
  });

  testWidgets('лінія зверху йде і по заокругленню, не лише по прямій', (tester) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final key = GlobalKey();

    await tester.pumpWidget(
      AppScope(
        s: initialSettings(),
        set: (_) {},
        meds: const [],
        setMeds: (_) {},
        child: MaterialApp(
          theme: calviLightTheme,
          home: Scaffold(
            // Ink behind the panel, so a corner that is cut shows it through.
            backgroundColor: const Color(0xFF000000),
            // Full height, the way the day screen mounts it: the veil needs a
            // screen to cover, or the stack shrinks to the bar alone.
            body: RepaintBoundary(
              key: key,
              child: SizedBox.expand(
                child: BottomBar(
                  slot: 'Обід',
                  messages: const [],
                  open: false,
                  onOpen: (_) {},
                  onClose: () {},
                  onSend: (_) {},
                  onCamera: () {},
                  onVoice: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    late ui.Image shot;
    late ByteData bytes;
    await tester.runAsync(() async {
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      shot = await boundary.toImage();
      bytes = (await shot.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    });

    int at(int x, int y) {
      final i = (y * shot.width + x) * 4;
      return bytes.getUint8(i) << 16 | bytes.getUint8(i + 1) << 8 | bytes.getUint8(i + 2);
    }

    /* The line along the top edge, read where the corner curves. A border is a
       straight run across the box, so the clip cut it exactly where the curve
       began: white met the ground with nothing between, and the corner read as
       unfinished. Both readings are «the first pixel that is not the ground»,
       and on both the line has to sit dimmer than the panel behind it. */
    int firstInk(int x) {
      for (var y = 0; y < shot.height; y++) {
        final c = at(x, y);
        if ((c >> 16 & 0xFF) > 60) return c;
      }
      return 0;
    }

    final onStraight = firstInk(shot.width ~/ 2) >> 16 & 0xFF;
    final onCurve = firstInk(6) >> 16 & 0xFF;

    expect(onStraight, lessThan(250), reason: 'на прямій ділянці лінії немає: $onStraight');
    expect(onCurve, lessThan(250), reason: 'на заокругленні лінія обривається: $onCurve');
  });
}
