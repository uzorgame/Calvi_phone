import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/chat.dart';
import '../../data/day.dart';
import '../../data/fixtures.dart';
import '../../data/meal.dart';
import '../../data/app_scope.dart';
import '../../data/measure.dart';
import '../../data/settings.dart';
import '../../data/workout.dart';
import '../../design/icons.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/slide.dart';
import '../analytics/analytics_screen.dart';
import '../camera/camera_screen.dart';
import '../voice/voice_overlay.dart';
import 'bottom_bar.dart';
import 'hero_card.dart';
import 'macro_cards.dart';
import 'meal_card.dart';
import 'measure_card.dart';
import 'water_card.dart';
import 'week_strip.dart';
import 'workout_card.dart';

/// Today.
///
/// Top to bottom: the header, the run of days, the day's main card, the three
/// macros, and then the day itself. Navigation lives up here beside the figures
/// rather than in a tab bar, because the bottom belongs to the input field.
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key, required this.onSettings, required this.onMeds});

  final VoidCallback onSettings;

  /// The fourth macro card opens the medications.
  final VoidCallback onMeds;

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  int _date = todayDate;

  /// Which way the week was moved, so the day under the strip goes the same way.
  int _dayDir = 0;

  /* Everything logged during the session lives here rather than in the
     fixtures: the fixtures are const, and a day has to be able to change while
     it is being looked at. It goes when the local store lands. */
  final _water = <int, int>{};
  final _extraWorkouts = <int, List<Workout>>{};
  final _measures = <Measure>[...demoMeasures];
  var _tracked = <String>[...defaultTracked];

  String? _openCard;
  bool _chatOpen = false;
  bool _dictating = false;
  final _messages = <Msg>[];

  void _openAnalytics(BuildContext context) => Navigator.of(
    context,
  ).push(slideRoute(AnalyticsScreen(measures: _measures, onSettings: widget.onSettings)));

  void _toggle(String id) => setState(() => _openCard = _openCard == id ? null : id);

  /* One place where anything said to Nora arrives, whatever said it: the field,
     the camera or dictation. Three call sites that each append their own pair of
     messages is three chances for the chat to answer itself differently. */
  void _say(Msg mine, String reply) {
    setState(() {
      _messages.add(mine);
      _chatOpen = true;
    });

    /* The answer lands a beat later. Both at once would say the reply was
       already written, which is the one thing a conversation is not, and the
       list would jump by two rows instead of scrolling to one. */
    _reply?.cancel();
    _reply = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _messages.add(msg(from: MsgFrom.nora, text: reply)));
    });
  }

  /// Cancellable: a reply that outlives the screen is a screen still running.
  Timer? _reply;

  @override
  void dispose() {
    _reply?.cancel();
    super.dispose();
  }

  /* The shot leaves as a message. The viewfinder closes behind it and the chat
     opens with it already sent, because that is where the answer will arrive. */
  Future<void> _openCamera(BuildContext context) async {
    final slot = _nextSlot(dayFor(_date));
    await Navigator.of(context).push(
      slideRoute(
        CameraScreen(
          slot: slot,
          onSend: (kind, code) {
            Navigator.of(context).pop();
            _say(
              msg(
                from: MsgFrom.me,
                kind: kind,
                text: kind == MsgKind.barcode ? 'Штрихкод' : 'Фото страви',
                code: code,
              ),
              kind == MsgKind.barcode ? noraBarcode : noraPhoto,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final day = dayFor(_date);
    final totals = day.totals;
    final workouts = [...day.workouts, ...?_extraWorkouts[_date]];
    final waterMl = _water[_date] ?? day.waterMl;
    final scope = AppScope.of(context);
    final meds = scope.meds;
    final goal = goalOf(scope.s);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: ListView(
              // Room for the bar, which floats over the day rather than pushing it.
              padding: const EdgeInsets.only(bottom: 128),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 4, CalviSize.gutter, 18),
                  child: Row(
                    children: [
                      Text('Calvi', style: context.t.headlineLarge?.copyWith(fontSize: 23)),
                      const Spacer(),
                      // Square and dark: this one leaves the screen, while the round
                      // one beside it only opens a drawer of the same app.
                      _Square(icon: 'chart', onTap: () => _openAnalytics(context)),
                      const SizedBox(width: 8),
                      _Round(icon: 'settings', onTap: widget.onSettings),
                    ],
                  ),
                ),

                WeekStrip(
                  date: _date,
                  onPick: (d) => setState(() {
                    _dayDir = d > _date ? 1 : -1;
                    _date = d;
                  }),
                ),
                const SizedBox(height: 4),

                /* Everything below the strip belongs to the chosen day, so it
                   slides as one block in the direction the week was moved. */
                Slide(
                  value: _date,
                  dir: _dayDir,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: CalviSize.gutter),
                    child: Column(
                      children: [
                        // Burned is passed in rather than read off the day: a session
                        // logged just now has to move the hero's figure too.
                        HeroCard(
                          key: ValueKey(_date),
                          day: day,
                          burned: workouts.fold<int>(0, (s, w) => s + w.kcal),
                          goal: goal,
                        ),
                        const SizedBox(height: CalviSize.gapCard),
                        MacroCards(
                          totals: totals,
                          goal: goal,
                          meds: meds,
                          onMeds: widget.onMeds,
                        ),
                        const SizedBox(height: CalviSize.gapSection),

                        /* Meals, then water, then training, then the tape: the order
                     the day is lived in. Water sits above training because it is
                     filled all day, while training happened once. */
                        for (final slot in day.ordered)
                          Padding(
                            padding: const EdgeInsets.only(bottom: CalviSize.gapCard),
                            child: MealCard(
                              slot: slot,
                              meals: day.inSlot(slot.id),
                              open: _openCard == slot.id,
                              onToggle: () => _toggle(slot.id),
                              onAdd: (text) => _say(
                                msg(from: MsgFrom.me, text: text),
                                'Записав у ${slot.label.toLowerCase()}. Скажи вагу, якщо хочеш точніше.',
                              ),
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.only(bottom: CalviSize.gapCard),
                          child: WaterCard(
                            ml: waterMl,
                            goalMl: goal.waterMl,
                            onChange: (ml) => setState(() => _water[_date] = ml),
                            open: _openCard == 'water',
                            onToggle: () => _toggle('water'),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(bottom: CalviSize.gapCard),
                          child: WorkoutCard(
                            workouts: workouts,
                            onAdd: (w) => setState(
                              () => _extraWorkouts.putIfAbsent(_date, () => []).add(w),
                            ),
                            open: _openCard == 'workout',
                            onToggle: () => _toggle('workout'),
                          ),
                        ),

                        MeasureCard(
                          list: _measures,
                          tracked: _tracked,
                          onTrack: (keys) => setState(() => _tracked = keys),
                          onSave: (m) => setState(() => _measures.add(m)),
                          onStats: () => _openAnalytics(context),
                          open: _openCard == 'measure',
                          onToggle: () => _toggle('measure'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned.fill(
            child: BottomBar(
              slot: _nextSlot(day),
              open: _chatOpen,
              muteMic: _dictating,
              onOpen: (_) => setState(() => _chatOpen = true),
              onClose: () => setState(() => _chatOpen = false),
              onSend: (text) => _say(
                msg(from: MsgFrom.me, text: text),
                'Записав. Скажи вагу, якщо хочеш точніше.',
              ),
              onCamera: () => _openCamera(context),
              onVoice: () => setState(() => _dictating = true),
              messages: _messages,
            ),
          ),

          // Dictation covers everything, including the bar that started it.
          if (_dictating)
            VoiceOverlay(
              onDone: (text) {
                setState(() => _dictating = false);
                if (text.isEmpty) return;
                _say(msg(from: MsgFrom.me, kind: MsgKind.voice, text: text), noraVoice);
              },
            ),
        ],
      ),
    );
  }

  /// Which card the next sentence lands in.
  ///
  /// The hour decides, not the last card that was tapped: somebody writing at
  /// two in the afternoon means lunch whatever they were reading a moment ago.
  String _nextSlot(DayModel day) {
    final hour = TimeOfDay.now().hour;
    SlotDef? best;
    for (final s in day.slots) {
      if (best == null || (s.order - hour).abs() < (best.order - hour).abs()) best = s;
    }
    return best?.label ?? 'Перекус';
  }
}

class _Round extends StatelessWidget {
  const _Round({required this.icon, required this.onTap});

  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, color: c.fillSecondary),
        child: CalviIcon(icon, size: 20),
      ),
    );
  }
}

class _Square extends StatelessWidget {
  const _Square({required this.icon, required this.onTap});

  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: c.button, borderRadius: BorderRadius.circular(12)),
        child: CalviIcon(icon, size: 19, color: c.buttonText),
      ),
    );
  }
}
