import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// Colours reach widgets through the theme, not through imports.
///
/// A widget that reads `calviLight` directly is a widget that ignores the dark
/// theme, and the mistake is invisible until someone switches. Going through an
/// extension means the compiler cannot help, but `context.c` reads short enough
/// that there is no reason to reach past it.
@immutable
class CalviTheme extends ThemeExtension<CalviTheme> {
  const CalviTheme(this.c);

  final CalviColors c;

  @override
  CalviTheme copyWith({CalviColors? c}) => CalviTheme(c ?? this.c);

  /// Themes cross-fade on a switch, so the colours have to be able to meet in
  /// the middle rather than jump.
  @override
  CalviTheme lerp(ThemeExtension<CalviTheme>? other, double t) {
    if (other is! CalviTheme) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    final o = other.c;
    return CalviTheme(
      CalviColors(
        bg: mix(c.bg, o.bg),
        card: mix(c.card, o.card),
        cardBorder: mix(c.cardBorder, o.cardBorder),
        fillSecondary: mix(c.fillSecondary, o.fillSecondary),
        iconCircle: mix(c.iconCircle, o.iconCircle),
        track: mix(c.track, o.track),
        hover: mix(c.hover, o.hover),
        hairline: mix(c.hairline, o.hairline),
        faint: mix(c.faint, o.faint),
        stage: mix(c.stage, o.stage),
        bezel: mix(c.bezel, o.bezel),
        shade: mix(c.shade, o.shade),
        scrim: mix(c.scrim, o.scrim),
        text: mix(c.text, o.text),
        textSecondary: mix(c.textSecondary, o.textSecondary),
        button: mix(c.button, o.button),
        buttonText: mix(c.buttonText, o.buttonText),
        buttonPress: mix(c.buttonPress, o.buttonPress),
        buttonDisabled: mix(c.buttonDisabled, o.buttonDisabled),
        protein: mix(c.protein, o.protein),
        carbs: mix(c.carbs, o.carbs),
        fats: mix(c.fats, o.fats),
        success: mix(c.success, o.success),
        accent: mix(c.accent, o.accent),
      ),
    );
  }
}

extension CalviContext on BuildContext {
  /// The palette for whichever theme is on.
  CalviColors get c => Theme.of(this).extension<CalviTheme>()!.c;

  /// Type scale. Sizes come from the same tokens the demo uses.
  TextTheme get t => Theme.of(this).textTheme;

  /// Тінь під підійнятою поверхнею. Див. [CalviShadow].
  List<BoxShadow> get shadowCard => CalviShadow.card(this);
  List<BoxShadow> get shadowFloat => CalviShadow.float(this);
  List<BoxShadow> get shadowPop => CalviShadow.pop(this);

  /// Колір того, на чому цей віджет лежить. Див. [CalviOn].
  Color get on => CalviOn.of(this);
}

/// На чому лежить те, що всередині.
///
/// Потрібно тому, хто розчиняється у своєму тлі: краї барабана згасають не в
/// нікуди, а в поверхню під ними, і колір тієї поверхні знати обовʼязково.
/// Барабан брав колір сторінки завжди, а стоїть він переважно в аркуші, де тло
/// інше: у темряві сторінка це #111114, а аркуш #171719, і на кінцях барабана
/// лежала помітна темна пелена.
///
/// Позначку ставить той, хто малює поверхню. Не поставив нічого означає
/// сторінку, бо на ній лежить усе, під чим більше нічого немає.
class CalviOn extends InheritedWidget {
  const CalviOn({super.key, required this.color, required super.child});

  final Color color;

  static Color of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CalviOn>()?.color ?? context.c.bg;

  @override
  bool updateShouldNotify(CalviOn old) => old.color != color;
}

/// Наскільки зараз темно, від 0 у світлі до 1 у темряві.
///
/// Рахується з фону палітри, а не з `brightness`, і це не дрібниця. Теми не
/// перемикаються миттєво, вони пливуть: MaterialApp розводить кольори за чверть
/// секунди. А `brightness` перекидається одним кроком посеред цього шляху, і
/// все, що зроблене на ньому, стрибає тоді, коли решта екрана ще напівсвітла.
/// Світлість фону тече разом із рештою, тому міра, зроблена на ній, доїжджає
/// синхронно з усім екраном.
double nightOf(BuildContext context) {
  final theme = Theme.of(context);
  final bg = theme.extension<CalviTheme>()?.c.bg ?? theme.scaffoldBackgroundColor;
  return ((0.5 - bg.computeLuminance()) / 0.45).clamp(0.0, 1.0);
}

/// Глибина, трьома висотами на весь застосунок.
///
/// Дві тіні на кожен шар, і це не надмір: близька дає контур, далека дає
/// повітря. Однією тінню так не буває, близька сама по собі це обведення, а
/// далека сама по собі пляма.
///
/// Висоти рівно три, і поза ними тіней немає: картка лежить на сторінці, щось
/// підняте над нею плаває, а темна картка препаратів і аркуші стоять найвище.
/// У темряві тінь глибша, інакше її не видно взагалі.
class CalviShadow {
  const CalviShadow._();

  /// Одна тінь, розведена між світлою і темною за мірою темряви.
  static BoxShadow _lerp(BoxShadow light, BoxShadow dark, double night) =>
      BoxShadow.lerp(light, dark, night)!;

  /* Одна тінь, а не дві, і це про швидкість.
   *
   * Двошарова тінь малюється красивіше, але кожен шар це окреме розмиття, а на
   * екрані дня карток десяток: двадцять розмиттів на кожен кадр прокрутки. На
   * телефоні це видно рукою, і застосунок почав відчуватись важким. Контур
   * картці дає рамка, тож ближній шар був розкішшю, за яку платив кожен кадр.
   * Далекий лишається: саме він дає повітря під карткою. */
  static List<BoxShadow> card(BuildContext context) => [
    _lerp(
      const BoxShadow(color: Color(0x12101014), blurRadius: 14, offset: Offset(0, 4)),
      const BoxShadow(color: Color(0x66000000), blurRadius: 14, offset: Offset(0, 4)),
      nightOf(context),
    ),
  ];

  static List<BoxShadow> float(BuildContext context) {
    final night = nightOf(context);
    return [
      _lerp(
        const BoxShadow(color: Color(0x0D101014), blurRadius: 6, offset: Offset(0, 2)),
        const BoxShadow(color: Color(0x59000000), blurRadius: 6, offset: Offset(0, 2)),
        night,
      ),
      _lerp(
        const BoxShadow(color: Color(0x17101014), blurRadius: 34, offset: Offset(0, 14)),
        const BoxShadow(color: Color(0x73000000), blurRadius: 34, offset: Offset(0, 14)),
        night,
      ),
    ];
  }

  static List<BoxShadow> pop(BuildContext context) {
    final night = nightOf(context);
    return [
      _lerp(
        const BoxShadow(color: Color(0x14101014), blurRadius: 8, offset: Offset(0, 3)),
        const BoxShadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 3)),
        night,
      ),
      _lerp(
        const BoxShadow(color: Color(0x24101014), blurRadius: 48, offset: Offset(0, 22)),
        const BoxShadow(color: Color(0x8C000000), blurRadius: 48, offset: Offset(0, 22)),
        night,
      ),
    ];
  }
}

/// Which face the interface is set in.
///
/// [CalviFace.system] is the one entry that is not a family at all: it leaves
/// `fontFamily` unset, so iOS draws in SF Pro and Android in Roboto. That is the
/// only honest way to have Apple's face, because its licence allows it on Apple
/// platforms and nowhere else, so shipping it inside an Android build is not an
/// option. The trade is real: the app then looks slightly different on the two
/// systems instead of being one thing everywhere.
enum CalviFace { system, interTight, inter, manrope, onest }

/// The face in use. One place to change it; the gallery in the demo exists to
/// make that change cheap.
const calviFace = CalviFace.onest;

/// The face. One line to change it, because the choice is still open and the
/// whole point of the gallery in the demo was to make swapping cheap.
TextTheme _type(Color text, Color secondary) {
  TextStyle base(double size, FontWeight w, {double spacing = -0.02, Color? colour}) {
    final style = TextStyle(
      fontSize: size,
      fontWeight: w,
      letterSpacing: size * spacing,
      /* What Onest gives a browser when nothing asks for a line height, measured
         off the demo: a 17px line comes out 22px, a 13px one 17px. Anything that
         needs a tighter line asks for it. */
      height: 1.3,
      color: colour ?? text,
    );
    return switch (calviFace) {
      // No family: the platform answers, which is what puts SF Pro on iPhone.
      CalviFace.system => style,
      /* Onest ships in the binary. google_fonts pulled it from the network at
         runtime, and a phone that had not fetched it yet showed Roboto. */
      CalviFace.onest => style.copyWith(fontFamily: 'Onest'),
      CalviFace.interTight => GoogleFonts.interTight(textStyle: style),
      CalviFace.inter => GoogleFonts.inter(textStyle: style),
      CalviFace.manrope => GoogleFonts.manrope(textStyle: style),
    };
  }

  return TextTheme(
    // The day's main figure, and nothing else at this size.
    displayLarge: base(CalviSize.fsNumber, FontWeight.w700),
    headlineLarge: base(CalviSize.fsTitle, FontWeight.w700),
    headlineMedium: base(CalviSize.fsOption, FontWeight.w600),
    titleMedium: base(CalviSize.fsBody, FontWeight.w600, spacing: 0),
    bodyLarge: base(CalviSize.fsBody, FontWeight.w400, spacing: 0),
    bodyMedium: base(CalviSize.fsCaption, FontWeight.w400, spacing: 0, colour: secondary),
    labelSmall: base(CalviSize.fsMicro, FontWeight.w500, spacing: 0, colour: secondary),
  );
}

ThemeData _theme(CalviColors c, Brightness b) {
  final type = _type(c.text, c.textSecondary);
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    scaffoldBackgroundColor: c.bg,
    canvasColor: c.bg,
    // Material's own palette still shows through in ripples and cursors, so it
    // is pointed at ours rather than left to guess.
    colorScheme: ColorScheme.fromSeed(
      seedColor: c.button,
      brightness: b,
    ).copyWith(surface: c.bg, onSurface: c.text, primary: c.button, onPrimary: c.buttonText),
    textTheme: type,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    extensions: [CalviTheme(c)],
  );
}

ThemeData get calviLightTheme => _theme(calviLight, Brightness.light);
ThemeData get calviDarkTheme => _theme(calviDark, Brightness.dark);

/// How every list in this app behaves at its ends.
///
/// Android stretches the whole screen when a list is pulled past its end, and
/// iOS lets it rubber-band. Neither belongs here: the demo's lists stop at the
/// end because `overscroll-behavior` says so, and a screen that visibly bends
/// under a thumb reads as a rendering fault in an app this flat. The list simply
/// stops, and nothing paints over the edge to explain it.
class CalviScroll extends MaterialScrollBehavior {
  const CalviScroll();

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) =>
      child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => const ClampingScrollPhysics();
}

/// Де ґрунт перестає мінятись і далі йде рівним тоном.
///
/// Знизу до цієї межі темний ґрунт рівний, і це правило, а не випадковість.
/// Підкладка під головною кнопкою згасає в один колір, [CalviColors.bg]. Поки
/// ґрунт під нею того самого кольору, підкладки не видно взагалі. Варто ґрунту
/// там поїхати, і під кнопкою лягає смуга іншого тону, на кожному екрані
/// налаштувань. Ця межа стоїть вище за найвищу можливу кнопку: вісімдесят
/// відсотків висоти з запасом покривають і маленький телефон, і збільшений
/// системний шрифт.
const _groundFlatAt = 0.78;

/// Ґрунт під сторінкою.
///
/// У темряві це «Вугілля»: майже чорний, з одним відблиском угорі зліва, від
/// якого тон стікає донизу. У світлі рівний тон, бо світлому ґрунту градієнт
/// не додає нічого, крім сірої плями.
///
/// Знизу ґрунт вирівнюється, див. [_groundFlatAt]. Відблиск туди не дістає:
/// він гасне на двох третинах екрана згори.
///
/// Лишається він окремим віджетом заради ще однієї гарантії: сторінка, що
/// приїжджає, непрозора. Попередня лежить під нею весь час переходу, і
/// напівпрозора нова пропускає її крізь себе.
class CalviGround extends StatelessWidget {
  const CalviGround({super.key, required this.child});

  final Widget child;

  /// Колір ґрунту на висоті [t], від 0 угорі до 1 унизу.
  ///
  /// Рахує лише нижній шар, і цього досить: відблиск гасне на двох третинах
  /// екрана згори, а питання «якого кольору ґрунт» ставлять про низ, там де в
  /// нього згасає підкладка під головною кнопкою.
  static Color toneAt(BuildContext context, double t) {
    final theme = Theme.of(context);
    final bg = theme.extension<CalviTheme>()?.c.bg ?? theme.scaffoldBackgroundColor;
    final top = Color.lerp(bg, const Color(0xFF1E1E22), nightOf(context))!;
    return t >= _groundFlatAt ? bg : Color.lerp(top, bg, t / _groundFlatAt)!;
  }

  /// Тло сторінки в цій темі. Непрозоре завжди, обома шарами.
  static Decoration of(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.extension<CalviTheme>()?.c;
    final bg = c?.bg ?? theme.scaffoldBackgroundColor;
    final night = nightOf(context);

    /* Верх ґрунту світлішає разом із темрявою, низ лишається кольором сторінки.
       Через `night`, а не через `brightness`: теми пливуть чверть секунди, а
       `brightness` перекидається одним кроком посередині. */
    final top = Color.lerp(bg, const Color(0xFF1E1E22), night)!;

    return BoxDecoration(
      gradient: LinearGradient(
        // 170 градусів у демці: майже прямо вниз, з ледь помітним нахилом.
        begin: const Alignment(0.17, -1),
        end: const Alignment(-0.17, 1),
        colors: [top, bg, bg],
        stops: const [0, _groundFlatAt, 1],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final night = nightOf(context);

    return DecoratedBox(
      decoration: of(context),
      child: night < 0.01
          ? child
          /* Відблиск окремим шаром, бо коробка вміє тільки один градієнт.
             Коштує це другої заливки прямокутника і жодного шару: обидва
             градієнти малюються прямо на полотно. */
          : DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.48, -0.72),
                  radius: 1.4,
                  colors: [
                    Color.lerp(const Color(0x0033333A), const Color(0xFF33333A), night)!,
                    const Color(0x0033333A),
                  ],
                  stops: const [0, 0.68],
                ),
              ),
              child: child,
            ),
    );
  }
}

/// Чорнило для чіпа, який стоїть на тонованій плашці свого ж кольору.
///
/// У світлі це потемнілий відтінок: пастельний зелений на світло-зеленій
/// подушці не читається, бо між ними майже немає різниці. У темряві навпаки,
/// потемнілий зникає на темному, і читається сам пастельний.
///
/// Одне місце на весь застосунок: доти в трьох файлах стояли зашиті
/// `0xFF1F8A3D` і `0xFF9A6300`, які в темряві перетворювали чіп на пляму.
Color chipInk(BuildContext context, Color tone) =>
    Color.lerp(Color.lerp(tone, const Color(0xFF1A1A1C), 0.45)!, tone, nightOf(context))!;
