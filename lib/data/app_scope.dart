import 'package:flutter/widgets.dart';

import 'meds.dart';
import 'settings.dart';

/// Everything the app keeps that more than one screen reads.
///
/// It sits **above** the navigator on purpose. A pushed screen is not a child of
/// the screen that pushed it, so a value handed over at push time would freeze:
/// change the theme inside settings and the list behind it would still be
/// drawing the old one.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.s,
    required this.set,
    required this.meds,
    required this.setMeds,
    required super.child,
  });

  final SettingsState s;
  final void Function(SettingsState Function(SettingsState)) set;

  /// Medications are read by the home screen's fourth card and edited on their
  /// own screen, so they cannot live inside either of them.
  final List<Med> meds;
  final void Function(List<Med> Function(List<Med>)) setMeds;

  static AppScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!;

  /// Identity is enough: every change makes a new object, and nothing is ever
  /// edited in place.
  @override
  bool updateShouldNotify(AppScope old) => !identical(old.s, s) || !identical(old.meds, meds);
}
