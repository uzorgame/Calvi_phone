import 'package:flutter/material.dart';

import 'data/meds.dart';
import 'data/settings.dart';
import 'data/app_scope.dart';
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
  const CalviApp({super.key});

  @override
  State<CalviApp> createState() => _CalviAppState();
}

class _CalviAppState extends State<CalviApp> {
  /* Settings and medications live above every screen, not inside the screens
     that edit them: the goal and the weight set in settings are read by the home
     card, and state that dies on the way out would leave that card showing
     figures nobody has any more. */
  SettingsState _s = initialSettings();
  /* Empty on purpose, same as the demo: the fourth card on the home row is
     earned by adding a regimen, not granted by a fixture. */
  List<Med> _meds = const [];

  /* The first run is a state of the app, not a route: it has no back door and
     nothing behind it to return to, so it replaces the home rather than sitting
     on top of it. It ends by folding what it collected into the settings, which
     is the whole point of asking. */
  bool _onboarding = true;

  void _set(SettingsState Function(SettingsState) patch) => setState(() => _s = patch(_s));
  void _setMeds(List<Med> Function(List<Med>) patch) => setState(() => _meds = patch(_meds));

  ThemeMode get _mode => switch (_s.theme) {
    AppTheme.light => ThemeMode.light,
    AppTheme.dark => ThemeMode.dark,
    AppTheme.system => ThemeMode.system,
  };

  @override
  Widget build(BuildContext context) {
    return AppScope(
      s: _s,
      set: _set,
      meds: _meds,
      setMeds: _setMeds,
      child: MaterialApp(
        title: 'Calvi',
        debugShowCheckedModeBanner: false,
        theme: calviLightTheme,
        darkTheme: calviDarkTheme,
        themeMode: _mode,
        home: Builder(
          builder: (context) => _start(
            _onboarding
                ? StartScreen(
                    onFinish: (draft) => setState(() {
                      _s = draft.applyTo(_s);
                      _onboarding = false;
                    }),
                  )
                : TodayScreen(
                    onSettings: () =>
                        Navigator.of(context).push(slideRoute(const SettingsScreen())),
                    onMeds: () => Navigator.of(context).push(slideRoute(const MedsRoute())),
                  ),
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
        'camera' => CameraScreen(slot: 'Обід', onSend: (_, _) {}),
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
