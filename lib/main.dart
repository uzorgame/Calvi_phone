import 'dart:async';
import 'package:flutter/material.dart';

import 'data/local/database.dart';
import 'data/remote/sync_service.dart';
import 'data/meds.dart';
import 'data/settings.dart';
import 'data/app_scope.dart';
import 'data/day_stats.dart';
import 'data/local/day_reader.dart';
import 'data/local/profile_store.dart';
import 'design/slide.dart';
import 'design/theme.dart';
import 'data/measure.dart';
import 'screens/analytics/analytics_screen.dart';
import 'screens/camera/camera_screen.dart';
import 'screens/voice/voice_overlay.dart';
import 'screens/meds/meds_route.dart';
import 'screens/settings/panel_allergy.dart';
import 'screens/settings/panel_assistant.dart';
import 'screens/settings/panel_reminders.dart';
import 'screens/settings/panels_account.dart';
import 'screens/settings/panels_body.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/start/start_screen.dart';
import 'screens/today/today_screen.dart';

void main() => runApp(const CalviApp());

class CalviApp extends StatefulWidget {
  const CalviApp({super.key, this.storage = true});

  /// Off in tests that are about a screen rather than about data: opening the
  /// database and starting a sync leaves timers running in a widget test, and a
  /// test of the theme has no business talking to a server.
  final bool storage;

  @override
  State<CalviApp> createState() => _CalviAppState();
}

class _CalviAppState extends State<CalviApp> {
  /* Settings and medications live above every screen, not inside the screens
     that edit them: the goal and the weight set in settings are read by the home
     card, and state that dies on the way out would leave that card showing
     figures nobody has any more. */
  /* Демонстраційна людина, доки не прочитано справжню. У демо-режимі вона ж і
     лишається: вітрина показує заповнений застосунок, а не порожній. */
  SettingsState _s = initialSettings();

  /// Профіль на диску. Зʼявляється разом із базою, тобто на першому справжньому
  /// запуску.
  ProfileStore? _profiles;
  /* Empty on purpose, same as the demo: the fourth card on the home row is
     earned by adding a regimen, not granted by a fixture. */
  List<Med> _meds = const [];

  /* The first run is a state of the app, not a route: it has no back door and
     nothing behind it to return to, so it replaces the home rather than sitting
     on top of it. It ends by folding what it collected into the settings, which
     is the whole point of asking.
   *
   * Порожньо означає «ще не знаємо»: сховище відповідає не тієї ж миті, а за
   * кілька кадрів. Показати за цей час «Старт» означало б блимнути онбордингом
   * в обличчя людині, яка проходила його місяць тому, тому доки відповіді
   * немає, на екрані не показується ніщо. */
  bool? _onboarding;

  /* The phone's own database, opened once and only when it is first needed. An
     app that never leaves the demo never touches the file, and a screen that
     mounts in a test never opens one at all. */
  CalviDb? _db;

  /* Which day the screens read: what is actually stored, or the demo. Real is
     the default now: the demo is a thing to look at, not a thing to start in.
     The switch stays on the home screen, because it is used while looking at
     the home screen. */
  bool _real = true;

  /// Carries local changes to the server and brings back what other devices
  /// wrote. Started with the database, which is to say on the first real use.
  SyncService? _sync;

  /* Підсумки днів для стрічки тижня і аналітики. У демо це фікстури, у режимі
     «мої» це те, що справді записано, і воно оновлюється саме, бо йде потоком. */
  DayStats _stats = DayStats.demo();
  StreamSubscription<DayStats>? _statsFeed;

  @override
  void dispose() {
    _statsFeed?.cancel();
    _saveLater?.cancel();
    _sync?.stop();
    _db?.close();
    super.dispose();
  }

  /// Switching to «мої» is what opens the database, and the first switch is the
  /// first time this phone writes anything of its own.
  void _setReal(bool real) => setState(() {
    if (real && widget.storage) _open();
    _real = real;
    // Назад у демо: підсумки теж мають бути демонстраційні, інакше на екрані
    // опиниться половина одного тижня і половина іншого.
    if (!real) {
      _statsFeed?.cancel();
      _statsFeed = null;
      _stats = DayStats.demo();
    } else {
      _follow(_db);
    }
  });

  /// Opens the database once, and starts the sync that follows it.
  void _open() {
    if (_db != null) return;
    final db = CalviDb();
    _db = db;
    _sync = SyncService(db)..start();
    _profiles = ProfileStore(db);
    _follow(db);
    unawaited(_loadProfile());
  }

  /// Читає збережений профіль і вирішує, чи це перший запуск.
  ///
  /// Саме тут закінчується онбординг, який раніше починався щоразу: питання
  /// «чи проходили ми це» має ставитись диску, а не полю в памʼяті, яке вмирає
  /// разом із застосунком.
  Future<void> _loadProfile() async {
    final saved = await _profiles?.load();
    if (!mounted) return;
    setState(() {
      if (saved != null) _s = saved;
      _onboarding = saved == null;
    });
  }

  /// Кінець «Старту»: те, що зібрали, стає профілем і одразу лягає на диск.
  void _finishStart(StartDraft draft) {
    final next = draft.applyTo(emptySettings());
    setState(() {
      _s = next;
      _onboarding = false;
    });
    unawaited(_profiles?.save(next));
  }

  /// Слухає підсумки днів зі сховища. Порожні, поки перша відповідь не прийшла.
  void _follow(CalviDb? db) {
    _statsFeed?.cancel();
    if (db == null) return;

    _stats = DayStats.empty;
    _statsFeed = DayReader(db).watchStats().listen((next) {
      if (mounted) setState(() => _stats = next);
    });
  }

  /* Пише не одразу, а трохи згодом.
   *
   * Налаштування міняються не по одному натисканню: лінійка ваги і колесо віку
   * шлють нове значення на кожен кадр перетягування. Запис на кожен із них це
   * сотні транзакцій за один жест і сотні брудних рядків у чергу на сервер.
   * Півсекунди тиші означає, що людина відпустила. */
  Timer? _saveLater;

  void _set(SettingsState Function(SettingsState) patch) {
    setState(() => _s = patch(_s));

    // У демо міняють вітрину, а не свій профіль: писати це на диск не можна.
    if (!_real || _onboarding != false) return;

    final snapshot = _s;
    _saveLater?.cancel();
    _saveLater = Timer(
      const Duration(milliseconds: 500),
      () => unawaited(_profiles?.save(snapshot)),
    );
  }

  void _setMeds(List<Med> Function(List<Med>) patch) => setState(() => _meds = patch(_meds));

  ThemeMode get _mode => switch (_s.theme) {
    AppTheme.light => ThemeMode.light,
    AppTheme.dark => ThemeMode.dark,
    AppTheme.system => ThemeMode.system,
  };

  @override
  void initState() {
    super.initState();
    // Real from the first frame, so nothing has to be switched on to be used.
    if (_real && widget.storage) {
      _open();
      return;
    }
    /* Без сховища питати нема кого, і відповідь тут одна: показати «Старт».
       Так поводиться тест про екран і збірка, яка навмисно не чіпає диску. */
    _onboarding = true;
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      s: _s,
      set: _set,
      meds: _meds,
      setMeds: _setMeds,
      db: _db,
      sync: _sync,
      real: _real,
      stats: _stats,
      setReal: _setReal,
      child: MaterialApp(
        title: 'Calvi',
        debugShowCheckedModeBanner: false,
        scrollBehavior: const CalviScroll(),
        theme: calviLightTheme,
        darkTheme: calviDarkTheme,
        themeMode: _mode,
        home: Builder(
          builder: (context) => _start(
            switch (_onboarding) {
              /* Диск ще не відповів. Порожній екран кольору застосунку триває
                 кадр або два і виглядає як продовження заставки; будь-що інше
                 тут блимнуло б і зникло. */
              null => const ColoredBox(color: Color(0xFFFFFFFF)),
              true => StartScreen(onFinish: _finishStart),
              false => TodayScreen(
                onSettings: () => Navigator.of(context).push(slideRoute(const SettingsScreen())),
                onMeds: () => Navigator.of(context).push(slideRoute(const MedsRoute())),
              ),
            },
          ),
        ),
      ),
    );
  }
}

/* Which screen the app opens on.
   `?screen=settings` in the address bar goes straight there. It exists for the
   same reason the demo has a control panel: a screen five taps deep cannot be
   looked at every time a colour moves, and «tap through to check» is how a
   detail stays broken for a week. Off in a normal build. */

/// Off unless the build asks for it: --dart-define=CALVI_DEV_SCREENS=true
const _devScreens = bool.fromEnvironment('CALVI_DEV_SCREENS');

Widget _start(Widget home) {
  if (!_devScreens) return home;
  final want = Uri.base.queryParameters['screen'];
  if (want == null) return home;
  return Builder(
    builder: (context) {
      final scope = AppScope.of(context);
      return switch (want) {
        'settings' => const SettingsScreen(),
        'profile' => ProfilePanel(s: scope.s, set: scope.set),
        'weight' => WeightPanel(s: scope.s, set: scope.set),
        'goal' => GoalPanel(s: scope.s, set: scope.set),
        'norm' => NormPanel(s: scope.s, set: scope.set),
        'theme' => ThemePanel(s: scope.s, set: scope.set),
        'lang' => LangPanel(s: scope.s, set: scope.set),
        'plan' => const PlanPanel(),
        'privacy' => PrivacyPanel(s: scope.s, set: scope.set),
        'delete' => const DeletePanel(),
        'allergy' => AllergyPanel(s: scope.s, set: scope.set),
        'assistant' => AssistantPanel(s: scope.s, set: scope.set),
        'reminders' => RemindersPanel(
          s: scope.s,
          set: scope.set,
          medsRemind: true,
          onMedsRemind: (_) {},
          onMeds: () {},
          now: 0,
        ),
        'meds' => Builder(
          builder: (context) {
            // The dev entry seeds the demo regimen so there is something to see.
            final scope = AppScope.of(context);
            if (scope.meds.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => scope.setMeds((_) => demoMeds),
              );
            }
            return const MedsRoute();
          },
        ),
        'analytics' => AnalyticsScreen(measures: demoMeasures, onSettings: () {}),
        'camera' => CameraScreen(slot: 'Обід', onSend: (_) {}),
        'voice' => Scaffold(body: VoiceOverlay(onDone: (_) {})),
        'start' => StartScreen(
          onFinish: (_) {},
          step: int.tryParse(Uri.base.queryParameters['step'] ?? '') ?? 0,
        ),
        'today' => Builder(
          builder: (context) {
            // ?meds=1 seeds the regimen, which is what puts a fourth card in the
            // macro row: it cannot be reached from a cold start otherwise.
            final scope = AppScope.of(context);
            if (Uri.base.queryParameters['meds'] == '1' && scope.meds.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => scope.setMeds((_) => demoMeds),
              );
            }
            return TodayScreen(
              chatOpen: Uri.base.queryParameters['chat'] == '1',
              openCard: Uri.base.queryParameters['card'],
              onSettings: () => Navigator.of(context).push(slideRoute(const SettingsScreen())),
              onMeds: () => Navigator.of(context).push(slideRoute(const MedsRoute())),
            );
          },
        ),
        _ => home,
      };
    },
  );
}
