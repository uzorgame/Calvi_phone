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
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => const ClampingScrollPhysics();
}
