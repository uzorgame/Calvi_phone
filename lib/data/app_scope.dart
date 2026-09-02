import 'package:flutter/widgets.dart';

import 'local/database.dart';
import 'remote/sync_service.dart';
import 'meds.dart';
import 'day_stats.dart';
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
    this.db,
    this.sync,
    this.real = false,
    this.setReal = _keepDemo,
    this.stats = DayStats.empty,
    this.eraseAll,
    this.deleteAccount,
    required super.child,
  });

  final SettingsState s;
  final void Function(SettingsState Function(SettingsState)) set;

  /// Medications are read by the home screen's fourth card and edited on their
  /// own screen, so they cannot live inside either of them.
  final List<Med> meds;
  final void Function(List<Med> Function(List<Med>)) setMeds;

  /// The phone's own database, or null where there is none: a widget test, or
  /// the app before the first frame.
  final CalviDb? db;

  /// Підсумки днів для стрічки тижня і аналітики: демонстраційні в режимі
  /// «демо», зі сховища в режимі «мої». Порожні, поки база не відповіла, і саме
  /// порожні: підставити чужий тиждень замість свого гірше, ніж почекати кадр.
  final DayStats stats;

  /// Carries local changes to the server and Nora's answers back. Null in a
  /// widget test and while the app has no database yet.
  final SyncService? sync;

  /* «Видалити дані» з налаштувань, цілком: сервер, місцева база і памʼять
     екранів. Живе тут, а не в самих налаштуваннях, бо половина роботи належить
     кореню застосунку: перечитати препарати, зняти їхні нагадування і
     перезібрати екран дня, який тримає розмову з Норою в памʼяті. Стирання, від
     якого на екрані лишаються старі бульбашки і таблетки, виглядає як таке, що
     не спрацювало. Порожньо в демо і в тестах: там стирати нема звідки. */
  final Future<void> Function()? eraseAll;

  /* «Видалити акаунт і дані»: запит на сервер, порожній телефон і повернення на
     вітання. Теж у корені, бо після стирання треба забути профіль, препарати й
     нагадування і перезібрати екрани з нуля. Порожньо в демо і в тестах. */
  final Future<void> Function()? deleteAccount;

  /// Whether the screens are showing the demo day or what is actually stored.
  ///
  /// The demo is not a debug toy: it is the only way to look at a full day of
  /// screens without inventing a week of food first, and it is what the design
  /// work has been done against. So the two live side by side and the switch is
  /// on the home screen, not buried in settings.
  final bool real;
  final ValueChanged<bool> setReal;

  static void _keepDemo(bool _) {}

  static AppScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!;

  /// Те саме, але без обіцянки, що обгортка є.
  ///
  /// Потрібно віджетам, які вміють показувати себе і без застосунку навколо:
  /// стрічка тижня в тесті геометрії живе сама, і падати там через відсутній
  /// стан вона не повинна. Обов'язковим [of] лишається для тих, кому без стану
  /// нема чого показувати.
  static AppScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>();

  /// Identity is enough: every change makes a new object, and nothing is ever
  /// edited in place.
  @override
  bool updateShouldNotify(AppScope old) =>
      !identical(old.s, s) ||
      !identical(old.meds, meds) ||
      old.real != real ||
      !identical(old.stats, stats);
}
