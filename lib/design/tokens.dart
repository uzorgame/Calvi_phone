// GENERATED FILE. Do not edit by hand.
//
// Source: Demo_Flutter_001/src/styles/tokens.css
// Regenerate: node tools/tokens.mjs
//
// A value is decided in the demo, where it can be seen on a screen, and lands
// here. Editing this file directly puts the app and the demo out of step, which
// is the one thing the generator exists to prevent.

import 'package:flutter/widgets.dart';

/// Every colour the interface is made of, in one theme's worth.
@immutable
class CalviColors {
  const CalviColors({
    required this.bg,
    required this.card,
    required this.cardBorder,
    required this.fillSecondary,
    required this.iconCircle,
    required this.track,
    required this.hover,
    required this.hairline,
    required this.faint,
    required this.stage,
    required this.bezel,
    required this.shade,
    required this.scrim,
    required this.text,
    required this.textSecondary,
    required this.button,
    required this.buttonText,
    required this.buttonPress,
    required this.buttonDisabled,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.success,
    required this.accent,
  });

  final Color bg;
  final Color card;
  final Color cardBorder;
  final Color fillSecondary;
  final Color iconCircle;
  final Color track;
  final Color hover;
  final Color hairline;
  final Color faint;
  final Color stage;
  final Color bezel;
  final Color shade;
  final Color scrim;
  final Color text;
  final Color textSecondary;
  final Color button;
  final Color buttonText;
  final Color buttonPress;
  final Color buttonDisabled;
  final Color protein;
  final Color carbs;
  final Color fats;
  final Color success;
  final Color accent;
}

/// Sizes do not change between themes, so they are plain constants.
class CalviSize {
  static const double fsHeadline = 42;
  static const double fsTitle = 28;
  static const double fsNumber = 48;
  static const double fsOption = 20;
  static const double fsBody = 17;
  static const double fsSubtitle = 18;
  static const double fsCaption = 15;
  static const double fsMicro = 13;
  static const double gutter = 24;
  static const double gapCard = 12;
  static const double gapSection = 28;
  static const double rCard = 16;
  static const double rLarge = 24;
  static const double rPill = 999;
  static const double buttonH = 56;
  static const double iconCircleSize = 44;
  static const double inputBarH = 64;
  static const double barRoom = 148;
  static const double navH = 52;
}

/// Motion. The same durations and the same curves the demo moves on, by the
/// same names, carried over from the stylesheet rather than retyped: a curve
/// matched by eye to whichever built-in looks closest is a curve that drifts.
class CalviMotion {
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration normal = Duration(milliseconds: 240);

  /// One screen giving way to another, and the day sliding inside one.
  static const Duration screen = Duration(milliseconds: 260);

  static const Curve ease = Cubic(0.32, 0.72, 0, 1);
  static const Curve easeRise = Cubic(0.16, 1, 0.3, 1);
  static const Curve easeOut = Cubic(0.4, 0, 0.2, 1);
  static const Curve easeIn = Cubic(0.4, 0, 1, 1);
}

const calviLight = CalviColors(
  bg: Color(0xFFF6F6F8),
  card: Color(0xFFFFFFFF),
  cardBorder: Color(0xFFEDEDF0),
  fillSecondary: Color(0xFFF5F5F7),
  iconCircle: Color(0xFFF4F4F7),
  track: Color(0xFFEFEFF2),
  hover: Color(0xFFFAFAFB),
  hairline: Color(0xFFE2E2E8),
  faint: Color(0xFFB4B4BB),
  stage: Color(0xFFECECED),
  bezel: Color(0xFF1A1A1C),
  shade: Color(0x17000000),
  scrim: Color(0x290A0A0C),
  text: Color(0xFF0A0A0A),
  textSecondary: Color(0xFF8E8E93),
  button: Color(0xFF1C1C1E),
  buttonText: Color(0xFFFFFFFF),
  buttonPress: Color(0xFF2A2A2E),
  buttonDisabled: Color(0xFFB0B0B5),
  protein: Color(0xFFC97F7C),
  carbs: Color(0xFFDCB471),
  fats: Color(0xFF8099B8),
  success: Color(0xFF8FAE87),
  accent: Color(0xFFCBA089),
);

const calviDark = CalviColors(
  bg: Color(0xFF121215),
  card: Color(0xFF171719),
  cardBorder: Color(0xFF252527),
  fillSecondary: Color(0xFF1D1D20),
  iconCircle: Color(0xFF232326),
  track: Color(0xFF26262A),
  hover: Color(0xFF1A1A1D),
  hairline: Color(0xFF313135),
  faint: Color(0xFF6B6B70),
  stage: Color(0xFF17171A),
  bezel: Color(0xFF050506),
  shade: Color(0x80000000),
  scrim: Color(0x6B000000),
  text: Color(0xFFF3F3F1),
  textSecondary: Color(0xFF9A9A9E),
  button: Color(0xFFF3F3F1),
  buttonText: Color(0xFF101012),
  buttonPress: Color(0xFFD9D9D6),
  buttonDisabled: Color(0xFF3A3A3F),
  protein: Color(0xFFC97F7C),
  carbs: Color(0xFFDCB471),
  fats: Color(0xFF8099B8),
  success: Color(0xFF8FAE87),
  accent: Color(0xFFCBA089),
);
