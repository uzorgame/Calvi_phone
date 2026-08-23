import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/theme.dart';
import 'package:calvi/design/tokens.dart';

/// Ґрунт під сторінкою і те, що залежить від теми.
///
/// У темряві ґрунт це «Вугілля»: майже чорний, з одним відблиском угорі зліва,
/// від якого тон стікає донизу. Знизу він спиняється і далі йде рівним тоном, і
/// це правило, а не випадковість. У ґрунт згасає підкладка під головною
/// кнопкою, а вона згасає в один колір. Поки ґрунт під нею того самого кольору,
/// підкладки не видно взагалі. Варто ґрунту там поїхати, і під кнопкою лягає
/// смуга іншого тону, на кожному екрані налаштувань.
///
/// Решта тут про інше: усе, що залежить від теми, мусить пливти разом із нею.
/// Теми переходять за чверть секунди, а `brightness` перекидається одним кроком
/// посередині, і зроблене на ньому стрибає тоді, коли решта екрана ще
/// напівсвітла.
void main() {
  /// Ставить тему віджетом, а не полем MaterialApp: друге її анімує, і одразу
  /// після кадру там ще стоїть попередня.
  Future<T> under<T>(
    WidgetTester tester,
    CalviColors palette,
    T Function(BuildContext) read,
  ) async {
    late T out;
    await tester.pumpWidget(
      MaterialApp(
        home: Theme(
          data: ThemeData(extensions: [CalviTheme(palette)], scaffoldBackgroundColor: palette.bg),
          child: Builder(
            builder: (context) {
              out = read(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    return out;
  }

  for (final (name, palette) in [('темній', calviDark), ('світлій', calviLight)]) {
    testWidgets('у $name темі ґрунт унизу рівний і дорівнює кольору сторінки', (tester) async {
      final tones = await under(
        tester,
        palette,
        (context) => [
          for (final t in [0.78, 0.85, 0.92, 1.0]) CalviGround.toneAt(context, t).toARGB32(),
        ],
      );

      expect(
        tones,
        everyElement(palette.bg.toARGB32()),
        reason: 'ґрунт унизу не рівний, підкладка під кнопкою лягатиме смугою',
      );
    });

    testWidgets('у $name темі ґрунт непрозорий на всю висоту', (tester) async {
      final alphas = await under(
        tester,
        palette,
        (context) => [for (var i = 0; i <= 10; i++) CalviGround.toneAt(context, i / 10).a],
      );

      // Прозорий ґрунт означає, що сторінка, яка приїжджає, просвічує.
      expect(alphas, everyElement(1.0));
    });
  }

  testWidgets('у темряві ґрунт угорі світліший, тобто «Вугілля» на місці', (tester) async {
    final tones = await under(
      tester,
      calviDark,
      (context) => [CalviGround.toneAt(context, 0), CalviGround.toneAt(context, 1)],
    );
    final top = tones.first, bottom = tones.last;

    expect(top, isNot(bottom), reason: 'темний ґрунт рівний, від «Вугілля» лишився один тон');
    expect(
      top.computeLuminance(),
      greaterThan(bottom.computeLuminance()),
      reason: 'верх темного ґрунту темніший за низ',
    );
  });

  testWidgets('у світлі ґрунт рівний на всю висоту', (tester) async {
    // Світлому ґрунту градієнт не додає нічого, крім сірої плями вгорі.
    final tones = await under(
      tester,
      calviLight,
      (context) => [for (var i = 0; i <= 10; i++) CalviGround.toneAt(context, i / 10).toARGB32()],
    );

    expect(tones, everyElement(calviLight.bg.toARGB32()));
  });

  testWidgets('ґрунт малюється і без нашого розширення', (tester) async {
    // Ґрунт стоїть на кожній сторінці, і чужа тема там цілком можлива.
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: const CalviGround(child: SizedBox()),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('тіні, чорнило чіпів і ґрунт пливуть, а не стрибають', (tester) async {
    late double night;
    late Color ink;
    late Color shadow;
    late Color ground;

    Future<void> at(double t) async {
      final mixed = const CalviTheme(calviLight).lerp(const CalviTheme(calviDark), t);
      await tester.pumpWidget(
        MaterialApp(
          home: Theme(
            data: ThemeData(extensions: [mixed], scaffoldBackgroundColor: mixed.c.bg),
            child: Builder(
              builder: (context) {
                night = nightOf(context);
                ink = chipInk(context, context.c.success);
                shadow = CalviShadow.card(context).first.color;
                ground = CalviGround.toneAt(context, 0);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    }

    await at(0);
    final inkLight = ink, shadowLight = shadow, groundLight = ground;
    expect(night, 0);

    await at(1);
    final inkDark = ink, shadowDark = shadow, groundDark = ground;
    expect(night, 1);
    expect(inkDark, isNot(inkLight), reason: 'чорнило чіпа однакове в обох темах');

    await at(0.5);
    expect(night, greaterThan(0.05), reason: 'міра темряви ще не рушила');
    expect(night, lessThan(0.95), reason: 'міра темряви вже в кінці');
    expect(ink, isNot(inkLight), reason: 'чорнило чіпа не рушило з місця');
    expect(ink, isNot(inkDark), reason: 'чорнило чіпа вже стрибнуло в кінець');
    expect(shadow.a, greaterThan(shadowLight.a), reason: 'тінь не почала глибшати');
    expect(shadow.a, lessThan(shadowDark.a), reason: 'тінь уже стрибнула в темну');
    expect(ground, isNot(groundLight), reason: 'ґрунт не рушив з місця');
    expect(ground, isNot(groundDark), reason: 'ґрунт уже стрибнув у кінець');
  });
}
