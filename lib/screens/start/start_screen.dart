import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';

import '../../data/allergens.dart';
import '../../data/app_scope.dart';
import '../../data/remote/login_service.dart';
import '../../data/legal.dart';
import '../../data/settings.dart';
import '../../design/icons.dart';
import '../../design/ring.dart';
import '../../design/ruler.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/wheel.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/labels.dart';
import '../settings/panel_legal.dart';
import '../../format.dart';

/* Скільки кроків у першому запуску.
 *
 * Тільки число: заповнення смуги вгорі це єдине, що з нього читають, а самі
 * назви ніде не показуються. Раніше тут лежав список їхніх імен, і це був
 * єдиний перелік у застосунку, який ніхто ніколи не бачив.
 *
 * Стать, вік і зріст стояли трьома екранами на дві секунди роботи кожен.
 * Питання одного роду і одного призначення: всі три йдуть у формулу норми і
 * жодне з них не потребує роздумів. Разом вони коротші, ніж три «Далі».
 *
 * Вітання «Стіл» звідси пішло і стало заставкою при кожному запуску, див.
 * `hello.dart`. Тут воно було екраном, який нічого не питав, і його доводилось
 * закривати кнопкою: єдиний дотик за весь «Старт», який нічого не означав. */
const startSteps = 7;

/* Allergies asked at the start are only the common ones. The full reference is
   in settings; a first run is not the place to scroll thirty seven entries. */
const _common = [
  'peanut',
  'hazelnut',
  'milk',
  'egg',
  'gluten',
  'fish',
  'crustacean',
  'soy',
  'sesame',
];

/// Три напрямки, словами тієї мови, якою зараз говорить застосунок.
List<({Direction id, String label, String hint})> _goals(L l) => [
  (id: Direction.lose, label: l.startGoalLose, hint: l.startGoalLoseHint),
  (id: Direction.keep, label: l.startGoalKeep, hint: l.startGoalKeepHint),
  (id: Direction.gain, label: l.startGoalGain, hint: l.startGoalGainHint),
];

/// First run, nine screens.
///
/// A competitor spends twenty eight of them, most on selling. We ask only what
/// the daily norm cannot be calculated without, one question to a screen, and
/// Nora picks up the rest in conversation over the first week.
///
/// **The account is the last screen.** The norm is already on the table by then,
/// so signing in is keeping something rather than paying for something not yet
/// seen. The cost is real and known: work done before the account exists is work
/// that can be lost if the app closes, and the sign-in has to earn its place by
/// arriving after the payoff rather than before it.
///
/// There is no social proof here and no testimonials. We have no users yet, and
/// a review invented for a demo is a lie that ships.
class StartScreen extends StatefulWidget {
  const StartScreen({super.key, required this.onFinish, this.step = 0});

  /// Where the finished profile goes.
  final void Function(StartDraft) onFinish;

  /// Which screen to open on. Only the demo entry point passes anything else.
  final int step;

  @override
  State<StartScreen> createState() => _StartScreenState();
}

/// Everything the first run collects, and nothing else.
///
/// A record of its own rather than a half-filled [SettingsState]: the caller
/// decides what to do with it, and a draft that pretends to be settings invites
/// somebody to hand it straight to a screen that expects every field.
class StartDraft {
  const StartDraft({
    required this.sex,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.direction,
    required this.targetKg,
    required this.pace,
    required this.activity,
    required this.allergies,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  final Sex sex;
  final int age;
  final int heightCm;
  final double weightKg;
  final Direction direction;
  final double targetKg;
  final double pace;
  final double activity;
  final List<String> allergies;
  final int protein;
  final int fat;
  final int carbs;

  /// Folded into the app's settings, with the goal anchored to today's weight.
  SettingsState applyTo(SettingsState s) => s.copyWith(
    sex: sex,
    age: age,
    heightCm: heightCm,
    weightKg: weightKg,
    goalStartKg: weightKg,
    targetKg: targetKg,
    direction: direction,
    pace: pace,
    activity: activity,
    allergies: [for (final id in allergies) Allergy(id: id, severe: false)],
    protein: protein,
    fat: fat,
    carbs: carbs,
  );
}

class _StartScreenState extends State<StartScreen> {
  /* Переклад геттером, а не полем: `L.of` тягне залежність від локалі, і
     збережене в `initState` значення пережило б зміну мови. */
  L get l => L.of(context);

  late int _step = widget.step;

  Sex _sex = Sex.m;
  int _age = 26;
  int _heightCm = 178;
  double _weightKg = 80;

  Direction _direction = Direction.lose;
  double _targetKg = 74;
  double _pace = 0.5;

  double _activity = 1.55;
  final _allergies = <String>[];

  /// The profile as it stands, so every screen can show what it adds up to.
  SettingsState get _draft => initialSettings().copyWith(
    sex: _sex,
    age: _age,
    heightCm: _heightCm,
    weightKg: _weightKg,
    goalStartKg: _weightKg,
    targetKg: _targetKg,
    direction: _direction,
    pace: _pace,
    activity: _activity,
  );

  /* The same split the norm screen uses: protein by weight, fat by share, the
     rest carbohydrates. Shown at the end so the number is a plan, not a
     verdict. */
  int get _protein => (_weightKg * 1.7).round();
  int get _fat => (calcKcal(_draft) * 0.28 / 9).round();
  int get _carbs => ((calcKcal(_draft) - _protein * 4 - _fat * 9) / 4).round();

  void _go(int n) => setState(() => _step = n);

  void _done() => widget.onFinish(
    StartDraft(
      sex: _sex,
      age: _age,
      heightCm: _heightCm,
      weightKg: _weightKg,
      direction: _direction,
      targetKg: _targetKg,
      pace: _pace,
      activity: _activity,
      allergies: [..._allergies],
      protein: _protein,
      fat: _fat,
      carbs: _carbs,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* Прозорий навмисно: під сторінкою лежить ґрунт, а суцільне тло
         Scaffold накрило б його рівним кольором і від «Вугілля» лишився б
         один тон. Непрозорість сторінки під час переходу дає CalviGround,
         а не це поле, тож нічого не просвічує. */
      backgroundColor: const Color(0x00000000),
      body: SafeArea(
        child: Column(
          children: [
            /* Смуга стоїть завжди, з першого ж питання.
             *
             * Раніше її на першому екрані не було, бо першим екраном було
             * вітання, яке кроком не рахувалось. Тепер перший екран це вже
             * питання, і сховати від нього смугу означало б сказати «ти ще не
             * почав» тому, хто вже відповідає.
             *
             * Безумовно, а не через `if`: шар, який то є, то немає, змінює
             * форму дерева під собою і перебудовує все, що нижче. Тут це
             * коштувало б втрати позиції барабанів на кожному переході. Тому
             * кнопка «назад» на першому кроці ховається, а місце своє тримає. */
            Padding(
              padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 6, CalviSize.gutter, 22),
              child: Row(
                children: [
                  Visibility(
                    visible: _step > 0,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: _Back(onTap: () => _go(_step - 1)),
                  ),
                  const SizedBox(width: 14),
                  /* Крок плюс один: людина на першому питанні пройшла одну
                     сьому, а не нічого. Порожня смуга на екрані, де вже щось
                     роблять, читається як зламана. */
                  Expanded(child: _Progress(at: (_step + 1) / startSteps)),
                ],
              ),
            ),
            /* No slide between steps. The demo keys its slide by screen, not by
               step, so the flow moves on one thing only: the bar filling. */
            Expanded(
              child: KeyedSubtree(key: ValueKey(_step), child: _body()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() => switch (_step) {
    0 => _aboutStep(),
    1 => _weightStep(),
    2 => _goalStep(),
    3 => _paceStep(),
    4 => _lifeStep(),
    5 => _normStep(),
    _ => _SignIn(onDone: _done),
  };

  /* Три відповіді одним екраном, і всі три без роздумів.
   *
   * Стать рядом, а не трьома картками: три слова без пояснень займають висоту
   * одного рядка і читаються так само. Барабани стиснуті до трьох рядів, щоб
   * екран уміщався цілком: прокрутка тут означала б, що людина не бачить
   * кнопку, поки не догортає до неї. */
  Widget _aboutStep() => _Step(
    title: l.startAbout,
    cta: l.actionNext,
    onNext: () => _go(1),
    children: [
      _Block(
        title: l.startSex,
        child: CalviSegments(
          labels: [l.startSexMale, l.startSexFemale, l.startSexOther],
          index: switch (_sex) {
            Sex.m => 0,
            Sex.f => 1,
            Sex.x => 2,
          },
          onPick: (i) => setState(
            () => _sex = switch (i) {
              0 => Sex.m,
              1 => Sex.f,
              _ => Sex.x,
            },
          ),
        ),
      ),
      _Block(
        title: l.startAge,
        aside: l.startAgeYears(_age),
        child: CalviWheel(
          values: ages,
          value: _age,
          suffix: l.startYearsShort,
          compact: true,
          onPick: (v) => setState(() => _age = v),
        ),
      ),
      _Block(
        title: l.startHeight,
        aside: '$_heightCm ${l.unitCm}',
        child: CalviWheel(
          values: heights,
          value: _heightCm,
          suffix: l.unitCm,
          compact: true,
          onPick: (v) => setState(() => _heightCm = v),
        ),
      ),
    ],
  );

  /* The weight has a screen to itself and stands in the middle of it: it is the
     one number here that will be asked again every week. */
  Widget _weightStep() => _Step(
    title: l.startWeightNow,
    cta: l.actionNext,
    onNext: () => _go(2),
    middle: true,
    children: [
      CalviRuler(
        value: _weightKg,
        min: 40,
        max: 180,
        suffix: l.unitKg,
        onChange: (v) => setState(() => _weightKg = v),
      ),
    ],
  );

  Widget _goalStep() => _Step(
    title: l.startGoal,
    cta: l.actionNext,
    // Holding weight needs no target and no pace, so the next step is skipped.
    onNext: () => _go(_direction == Direction.keep ? 4 : 3),
    children: [
      for (final g in _goals(l))
        CalviPick(
          label: g.label,
          hint: g.hint,
          on: _direction == g.id,
          onTap: () => setState(() => _direction = g.id),
        ),
      if (_direction != Direction.keep)
        _Field(
          label: l.startTargetWeight,
          value: _targetKg.toStringAsFixed(1),
          unit: l.unitKg,
          child: CalviRuler(
            showValue: false,
            value: _targetKg,
            min: 40,
            max: 180,
            suffix: l.unitKg,
            onChange: (v) => setState(() => _targetKg = v),
          ),
        ),
    ],
  );

  /* Pace on its own screen. It is the one answer here that decides how the next
     few months feel, and it deserves more than a slider under a drum. */
  Widget _paceStep() {
    final weeks = weeksToTarget(_draft);
    return _Step(
      title: l.startPace,
      cta: l.actionNext,
      onNext: () => _go(4),
      children: [
        Text.rich(
          TextSpan(
            text: _pace.toStringAsFixed(1),
            children: [
              TextSpan(
                text: '  ${l.startPaceUnit}',
                style: context.t.bodyMedium?.copyWith(fontSize: CalviSize.fsBody),
              ),
            ],
          ),
          style: context.t.displayLarge?.copyWith(height: 1),
        ),
        const SizedBox(height: 26),
        CalviSlider(
          value: _pace,
          min: 0.2,
          max: 1.2,
          step: 0.1,
          marks: [l.startPaceSlow, l.startPaceUsual, l.startPaceFast],
          onChange: (v) => setState(() => _pace = v),
        ),
        if (weeks > 0)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: context.c.fillSecondary,
                borderRadius: BorderRadius.circular(CalviSize.rCard),
              ),
              /* Речення трьома шматками, бо дата і строк у ньому жирні.
               *
               * Скільки тижнів це окремий рядок із множиною, а не число плюс
               * слово: українська має тут три форми, і склеєне в коді давало
               * «5 тижні». */
              child: Text.rich(
                TextSpan(
                  text: l.startPaceEtaHead,
                  children: [
                    TextSpan(
                      text: targetDate(weeks),
                      style: TextStyle(color: context.c.text, fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: l.startPaceEtaTail),
                    TextSpan(
                      text: l.startPaceWeeks(weeks),
                      style: TextStyle(color: context.c.text, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                style: context.t.bodyMedium,
              ),
            ),
          ),

        /* Only when there is something to say. A line that confirms nothing is
           wrong teaches people to stop reading the lines. */
        if (_pace > 0.8) _Note(l.startPaceWarning),
      ],
    );
  }

  Widget _lifeStep() => _Step(
    title: l.startLife,
    cta: l.actionNext,
    onNext: () => _go(5),
    children: [
      for (final a in activityLevels)
        CalviPick(
          label: activityTitle(context, a.v),
          hint: activityHint(context, a.v),
          on: _activity == a.v,
          onTap: () => setState(() => _activity = a.v),
        ),
      const SizedBox(height: 26),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          l.startAllergies,
          style: context.t.titleMedium?.copyWith(fontSize: CalviSize.fsCaption),
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 7,
        runSpacing: 7,
        children: [
          for (final id in _common)
            if (allergenById(id) case final a?)
              _Chip(
                label: a.name,
                on: _allergies.contains(id),
                onTap: () => setState(
                  () => _allergies.contains(id) ? _allergies.remove(id) : _allergies.add(id),
                ),
              ),
        ],
      ),
    ],
  );

  Widget _normStep() {
    final c = context.c;
    final kcal = calcKcal(_draft);
    final weeks = weeksToTarget(_draft);

    return _Step(
      title: l.startNorm,
      cta: l.actionNext,
      onNext: () => _go(6),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: c.card,
            border: Border.all(color: c.cardBorder),
            borderRadius: BorderRadius.circular(CalviSize.rLarge),
            boxShadow: context.shadowCard,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(thousands(kcal), style: context.t.displayLarge?.copyWith(height: 1)),
                    const SizedBox(height: 6),
                    Text(l.startNormPerDay, style: context.t.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              CalviRing(
                progress: 1,
                size: 92,
                stroke: 9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      weeks > 0 ? '$weeks' : '∞',
                      style: context.t.headlineLarge?.copyWith(
                        fontSize: 24,
                        letterSpacing: 24 * -0.02,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      weeks > 0 ? l.startNormWeeks : l.startNormHold,
                      style: context.t.labelSmall?.copyWith(fontSize: 9, height: 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: CalviSize.gapCard),
        Row(
          children: [
            _MacroDot(label: l.macroProtein, value: _protein, colour: c.protein),
            const SizedBox(width: CalviSize.gapCard),
            _MacroDot(label: l.macroFat, value: _fat, colour: c.fats),
            const SizedBox(width: CalviSize.gapCard),
            _MacroDot(label: l.macroCarbs, value: _carbs, colour: c.carbs),
          ],
        ),
        const SizedBox(height: CalviSize.gapCard),
        CalviNora(text: l.startNormNora, hint: l.startNormNoraHint),
        _Note(l.startNormNote),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.at});

  final double at;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 3,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: c.hairline)),
            // Grows rather than jumps: the bar is the same object getting longer.
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 460),
              curve: CalviMotion.easeRise,
              widthFactor: at.clamp(0.0, 1.0),
              heightFactor: 1,
              alignment: Alignment.centerLeft,
              child: ColoredBox(color: c.button),
            ),
          ],
        ),
      ),
    );
  }
}

/// The shell every step after the first shares.
/// The question at the top of a step.
class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Text(
      text,
      style: context.t.displayLarge?.copyWith(
        fontSize: 34,
        letterSpacing: 34 * -0.03,
        height: 1.12,
      ),
    ),
  );
}

class _Block extends StatelessWidget {
  const _Block({required this.title, this.aside, required this.child});

  final String title;

  /// Число, яке відповідає на заголовок, справа того ж рядка. Не в кожного
  /// блока воно є: у вибору статі відповідь стоїть у самому ряду кнопок.
  final String? aside;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: CalviSize.gapSection),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: Text(title, style: context.t.titleMedium)),
              if (aside != null) Text(aside!, style: context.t.bodyMedium),
            ],
          ),
        ),
        child,
      ],
    ),
  );
}

class _Step extends StatelessWidget {
  const _Step({
    required this.title,
    required this.cta,
    required this.onNext,
    required this.children,
    this.middle = false,
  });

  final String title;
  final String cta;
  final VoidCallback onNext;
  final List<Widget> children;

  /// Stands the content in the middle of the room it has, for a screen that
  /// holds one control: a lone tape at the top of an empty screen reads as
  /// something that failed to load below it.
  final bool middle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          // A screen with one control has nothing to scroll, so it is a column
          // that hands the leftover room to the control rather than a list.
          child: middle
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: CalviSize.gutter),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Title(title),
                      Expanded(
                        child: Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: children),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 16),
                  children: [_Title(title), ...children],
                ),
        ),
        /* A band under the action, so content scrolls behind it instead of
           through it: a button floating over a tape reads as a fault. The fade
           above the band is where the content goes out, not a hard cut. */
        SizedBox(
          height: 26,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [context.on.withValues(alpha: 0), context.on],
              ),
            ),
            child: const SizedBox.expand(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 26),
          child: CalviButton(label: cta, onTap: onNext),
        ),
      ],
    );
  }
}

/// The back mark of the flow. Plainer than [CalviBack] on purpose: the demo
/// draws no ring here, because the bar beside it is already the progress.
class _Back extends StatefulWidget {
  const _Back({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_Back> createState() => _BackState();
}

class _BackState extends State<_Back> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: L.of(context).actionBack,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _down ? 0.92 : 1,
          duration: CalviMotion.fast,
          curve: CalviMotion.ease,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: context.c.fillSecondary),
            child: Transform.rotate(angle: math.pi, child: const CalviIcon('chevron', size: 19)),
          ),
        ),
      ),
    );
  }
}

/// One option, as a card rather than a row: a first run has room for it, and a
/// choice that fills the thumb is easier than a list item.

/* A ruler with its own heading, so a screen carrying three of them does not read
   as three identical drums. */
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value, required this.unit, required this.child});

  final String label;
  final String value;
  final String unit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    /* No card. In the demo a field of the flow is a heading line and the naked
       tape under it, the full width of the content: the box my first version
       drew around each drum made three loud frames out of three quiet scales. */
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: Text(label, style: context.t.bodyMedium)),
              Text.rich(
                TextSpan(
                  text: value,
                  children: [
                    TextSpan(
                      text: ' $unit',
                      style: context.t.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.c.textSecondary,
                      ),
                    ),
                  ],
                ),
                style: context.t.headlineMedium?.copyWith(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 21 * -0.02,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          child,
        ],
      ),
    );
  }
}

class _MacroDot extends StatelessWidget {
  const _MacroDot({required this.label, required this.value, required this.colour});

  final String label;
  final int value;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          color: c.card,
          border: Border.all(color: c.cardBorder),
          borderRadius: BorderRadius.circular(CalviSize.rCard),
          boxShadow: context.shadowCard,
        ),
        child: Column(
          children: [
            CalviRing(progress: 1, size: 40, stroke: 5, color: colour),
            const SizedBox(height: 8),
            Text(
              L.of(context).gramsUnit(value),
              style: context.t.titleMedium?.copyWith(fontSize: CalviSize.fsBody),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: context.t.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.on, required this.onTap});

  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: CalviMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          /* Unpicked does not mean unavailable.
             These sat on `fillSecondary` over the page ground, one step of 255
             apart, so the chip had no shape at all, and `textSecondary` on it
             came to 2.99:1 where small text needs 4.5:1. Next to the activity
             options, which are white cards with dark titles, the one thing on
             the screen you have to tap looked like the one thing you could
             not. Ground it reads on, and ink you can read. */
          color: on ? c.button : c.track,
          borderRadius: BorderRadius.circular(CalviSize.rPill),
        ),
        child: Text(
          label,
          style: context.t.labelSmall?.copyWith(
            fontSize: CalviSize.fsMicro,
            fontWeight: on ? FontWeight.w600 : FontWeight.w400,
            color: on ? c.buttonText : c.text,
          ),
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: Text(
      text,
      style: context.t.bodyMedium?.copyWith(fontSize: CalviSize.fsMicro, height: 1.5),
    ),
  );
}

/* The last screen. The norm is already on the table, so signing in keeps
   something the person has seen rather than paying for something promised. The
   cost is real: everything before this exists only while the app is open. */
class _SignIn extends StatefulWidget {
  const _SignIn({required this.onDone});

  final VoidCallback onDone;

  @override
  State<_SignIn> createState() => _SignInState();
}

class _SignInState extends State<_SignIn> {
  bool _agree = true;

  /// Поки триває обмін із Google і нашим сервером. Другий тап тут дав би другий
  /// вхід, а не швидший перший.
  bool _busy = false;

  /* Вхід і його три кінці.
   *
   * Вийшло: йдемо далі, щоденник підписаний. Людина закрила вікно Google: теж
   * ідемо далі мовчки, бо це не помилка, а передумала. Не вийшло через мережу:
   * кажемо про це і лишаємось тут, бо повторити варто.
   *
   * Питання про два щоденники тут не ставиться навмисно: на першому запуску
   * місцевих записів ще немає, і сама ситуація неможлива. */
  Future<void> _google() async {
    final sync = AppScope.maybeOf(context)?.sync;
    if (sync == null) return widget.onDone();

    setState(() => _busy = true);
    final result = await sync.login.signIn(deviceName: L.of(context).startDeviceFirstRun);
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result) {
      case LoginResult.done:
      case LoginResult.canceled:
        widget.onDone();
      case LoginResult.failed:
        // Причина в тексті: без неї збій виглядає як мовчання, а до сервера він
        // не доходить, тому в логах його теж немає.
        final why = sync.login.error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              why == null
                  ? L.of(context).startSignInFailed
                  : L.of(context).startSignInFailedWhy(why),
            ),
            duration: const Duration(seconds: 10),
          ),
        );
    }
  }

  /* Документ відкривається аркушем, а не в браузері.
   *
   * Розходження з сайтом тут уже не загрожує: слова лежать в одному місці, і
   * `tools/legal.mjs` розвозить їх звідти і в сторінку сайту, і в застосунок.
   * А от браузер посеред знайомства коштував дорого: людина йшла читати умови й
   * поверталась у застосунок, який доводилось починати спочатку. Ще гірше без
   * мережі, де вона не поверталась узагалі. */

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);
    /* The buttons sit in the body, not pinned to the floor: the sentence above
       them is the reason to press one, and it has to be read first. */
    return ListView(
      padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 16),
      children: [
        Text(
          l.startSignInTitle,
          style: context.t.displayLarge?.copyWith(
            fontSize: 34,
            letterSpacing: 34 * -0.03,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l.startSignInText,
          style: context.t.bodyMedium?.copyWith(fontSize: CalviSize.fsBody, height: 1.5),
        ),
        const SizedBox(height: 24),
        // Nothing agreed to means nothing to press, and the row says so by going
        // pale rather than by turning grey.
        Opacity(
          opacity: _agree ? 1 : 0.4,
          child: IgnorePointer(
            ignoring: !_agree,
            child: Column(
              children: [
                /* Кнопка є тільки тоді, коли за нею щось стоїть.
                 *
                 * Порожній ідентифікатор означає, що вхід ще не налаштований у
                 * цій збірці. Показувати кнопку, яка нічого не зробить, гірше,
                 * ніж не показувати її: людина натискає, нічого не відбувається,
                 * і застосунок виглядає зламаним, а не незавершеним. */
                if (AppScope.maybeOf(context)?.sync?.login.available ?? false) ...[
                  CalviButton(
                    label: _busy ? l.startSignInBusy : l.startSignInGoogle,
                    onTap: _busy ? () {} : () => unawaited(_google()),
                  ),
                  const SizedBox(height: 10),
                ],

                /* Apple where Apple is. On Android the button leads nowhere, and
                   a way in that cannot be walked is worse than one less way in. */
                if (defaultTargetPlatform == TargetPlatform.iOS ||
                    defaultTargetPlatform == TargetPlatform.macOS) ...[
                  _Ghost(label: l.startSignInApple, onTap: widget.onDone),
                  const SizedBox(height: 10),
                ],

                /* Далі без входу. Раніше тут стояла кнопка «Продовжити з
                   поштою», за якою не було нічого: ні маршруту, ні планів. */
                _Ghost(label: l.startSignInSkip, onTap: widget.onDone),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: () => setState(() => _agree = !_agree),
          behavior: HitTestBehavior.opaque,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: CalviMotion.fast,
                curve: CalviMotion.ease,
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: _agree ? c.button : const Color(0x00000000),
                  border: Border.all(color: _agree ? c.button : c.hairline, width: 1.5),
                ),
                child: _agree ? CalviIcon('check', size: 13, color: c.buttonText) : null,
              ),
              const SizedBox(width: 10),
              /* Документи відкриваються, а не просто називаються.
               *
               * Тут стояв звичайний рядок тексту, і людина ставила галочку під
               * тим, чого не могла прочитати: слова «умови» і «політика» ні на
               * що не вели. Згода на непрочитане це не згода. */
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: l.startAgreeHead),
                      TextSpan(
                        text: l.startAgreeTerms,
                        style: TextStyle(color: c.text, decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => legalSheet(context, terms),
                      ),
                      TextSpan(text: l.startAgreeAnd),
                      TextSpan(
                        text: l.startAgreePrivacy,
                        style: TextStyle(color: c.text, decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => legalSheet(context, privacy),
                      ),
                    ],
                  ),
                  style: context.t.bodyMedium?.copyWith(fontSize: CalviSize.fsMicro, height: 1.45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Ghost extends StatefulWidget {
  const _Ghost({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_Ghost> createState() => _GhostState();
}

class _GhostState extends State<_Ghost> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _down ? 0.98 : 1,
        duration: CalviMotion.fast,
        curve: CalviMotion.ease,
        child: Container(
          height: CalviSize.buttonH,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CalviSize.rPill),
            border: Border.all(color: c.hairline),
          ),
          child: Text(
            widget.label,
            style: context.t.titleMedium?.copyWith(fontSize: CalviSize.fsBody, color: c.text),
          ),
        ),
      ),
    );
  }
}
