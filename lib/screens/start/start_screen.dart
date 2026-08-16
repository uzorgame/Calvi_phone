import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/allergens.dart';
import '../../data/settings.dart';
import '../../design/icons.dart';
import '../../design/ring.dart';
import '../../design/ruler.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/wheel.dart';
import '../../format.dart';

/// Names of the eight screens, in order. The demo panel jumps by index.
const startSteps = [
  'Вітання',
  'Стать',
  'Тіло',
  'Ціль',
  'Темп',
  'Спосіб життя',
  'Твоя норма',
  'Вхід',
];

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

const _sexes = [
  (id: Sex.m, label: 'Чоловіча'),
  (id: Sex.f, label: 'Жіноча'),
  (id: Sex.x, label: 'Інше'),
];

const _goals = [
  (id: Direction.lose, label: 'Схуднути', hint: 'дефіцит під обраний темп'),
  (id: Direction.keep, label: 'Тримати вагу', hint: 'скільки витрачаєш, стільки й повертаєш'),
  (id: Direction.gain, label: 'Набрати', hint: 'профіцит під обраний темп'),
];

/// First run, eight screens.
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
      body: SafeArea(
        child: Column(
          children: [
            // Screen one has nothing to be a step of, so it carries no progress.
            if (_step > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 6, CalviSize.gutter, 22),
                child: Row(
                  children: [
                    _Back(onTap: () => _go(_step - 1)),
                    const SizedBox(width: 14),
                    Expanded(child: _Progress(at: _step / (startSteps.length - 1))),
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
    0 => _Hello(onNext: () => _go(1)),
    1 => _sexStep(),
    2 => _bodyStep(),
    3 => _goalStep(),
    4 => _paceStep(),
    5 => _lifeStep(),
    6 => _normStep(),
    _ => _SignIn(onDone: _done),
  };

  Widget _sexStep() => _Step(
    title: 'Стать',
    hint:
        'Формула норми рахує чоловіків і жінок по-різному, тому питання тут про арифметику, '
        'а не про щось інше.',
    cta: 'Далі',
    onNext: () => _go(2),
    children: [
      for (final (i, x) in _sexes.indexed)
        _Card(
          label: x.label,
          icon: 'user',
          first: i == 0,
          on: _sex == x.id,
          onTap: () => setState(() => _sex = x.id),
        ),
    ],
  );

  /* Three drums on their own screen. Sharing one with the option cards made a
     page you had to scroll to see the question you were answering. */
  Widget _bodyStep() => _Step(
    title: 'Вік, зріст і вага',
    cta: 'Далі',
    onNext: () => _go(3),
    children: [
      _Field(
        label: 'Вік',
        value: '$_age',
        unit: 'років',
        child: CalviRuler(
          showValue: false,
          value: _age.toDouble(),
          min: 14,
          max: 90,
          step: 1,
          suffix: 'років',
          onChange: (v) => setState(() => _age = v.round()),
        ),
      ),
      _Field(
        label: 'Зріст',
        value: '$_heightCm',
        unit: 'см',
        child: CalviRuler(
          showValue: false,
          value: _heightCm.toDouble(),
          min: 120,
          max: 220,
          step: 1,
          suffix: 'см',
          onChange: (v) => setState(() => _heightCm = v.round()),
        ),
      ),
      _Field(
        label: 'Вага зараз',
        value: _weightKg.toStringAsFixed(1),
        unit: 'кг',
        child: CalviRuler(
          showValue: false,
          value: _weightKg,
          min: 40,
          max: 180,
          suffix: 'кг',
          onChange: (v) => setState(() => _weightKg = v),
        ),
      ),
    ],
  );

  Widget _goalStep() => _Step(
    title: 'Куди рухаємось',
    cta: 'Далі',
    // Holding weight needs no target and no pace, so the next step is skipped.
    onNext: () => _go(_direction == Direction.keep ? 5 : 4),
    children: [
      for (final (i, g) in _goals.indexed)
        _Card(
          label: g.label,
          hint: g.hint,
          first: i == 0,
          on: _direction == g.id,
          onTap: () => setState(() => _direction = g.id),
        ),
      if (_direction == Direction.keep)
        const _Note(
          'Тримати вагу означає їсти рівно стільки, скільки витрачаєш. Ціль і темп тут не '
          'потрібні, тому наступний крок пропускаємо.',
        )
      else
        _Field(
          label: 'Цільова вага',
          value: _targetKg.toStringAsFixed(1),
          unit: 'кг',
          child: CalviRuler(
            showValue: false,
            value: _targetKg,
            min: 40,
            max: 180,
            suffix: 'кг',
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
      title: 'Як швидко',
      cta: 'Далі',
      onNext: () => _go(5),
      children: [
        Text.rich(
          TextSpan(
            text: _pace.toStringAsFixed(1),
            children: [
              TextSpan(
                text: '  кг на тиждень',
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
          marks: const ['повільно', 'звично', 'швидко'],
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
              child: Text.rich(
                TextSpan(
                  text: 'Ціль приблизно ',
                  children: [
                    TextSpan(
                      text: targetDate(weeks),
                      style: TextStyle(color: context.c.text, fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(text: ', це '),
                    TextSpan(
                      text: '$weeks',
                      style: TextStyle(color: context.c.text, fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text:
                          ' ${weeks == 1
                              ? 'тиждень'
                              : weeks < 5
                              ? 'тижні'
                              : 'тижнів'}',
                    ),
                  ],
                ),
                style: context.t.bodyMedium,
              ),
            ),
          ),

        /* Only when there is something to say. A line that confirms nothing is
           wrong teaches people to stop reading the lines. */
        if (_pace > 0.8)
          const _Note(
            'Такий темп тримається важко і зазвичай зривається. Нижче за 0.8 кг на тиждень '
            'результат виходить повільніший, але лишається.',
          ),
      ],
    );
  }

  Widget _lifeStep() => _Step(
    title: 'Спосіб життя',
    hint:
        'Активність змінює норму сильніше, ніж здається: різниця між сидячим і помірним це '
        'майже чотириста калорій.',
    cta: 'Далі',
    onNext: () => _go(6),
    children: [
      for (final (i, a) in activityLevels.indexed)
        _Card(
          label: a.label,
          hint: a.hint,
          first: i == 0,
          on: _activity == a.v,
          onTap: () => setState(() => _activity = a.v),
        ),
      const SizedBox(height: 26),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Алергії',
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
      title: 'Твоя норма',
      cta: 'Далі',
      onNext: () => _go(7),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: c.card,
            border: Border.all(color: c.cardBorder),
            borderRadius: BorderRadius.circular(CalviSize.rLarge),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(thousands(kcal), style: context.t.displayLarge?.copyWith(height: 1)),
                    const SizedBox(height: 6),
                    Text('ккал на день', style: context.t.bodyMedium),
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
                      weeks > 0 ? 'тижнів' : 'тримаємо',
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
            _MacroDot(label: 'Білок', value: _protein, colour: c.protein),
            const SizedBox(width: CalviSize.gapCard),
            _MacroDot(label: 'Жири', value: _fat, colour: c.fats),
            const SizedBox(width: CalviSize.gapCard),
            _MacroDot(label: 'Вуглеводи', value: _carbs, colour: c.carbs),
          ],
        ),
        const SizedBox(height: CalviSize.gapCard),
        const CalviNora(
          text: 'Порахувала. Далі простіше.',
          hint:
              'Пиши або кажи як зручно: «два яйця і тост», «випив 300 води». Решту, що '
              'знадобиться, спитаю в розмові.',
        ),
        const _Note(
          'Це розрахунок за формулою Міффліна-Сан Жеора, а не медична рекомендація. Якщо є '
          'захворювання, вагітність або призначена дієта, звіряйся з лікарем.',
        ),
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
class _Step extends StatelessWidget {
  const _Step({
    required this.title,
    this.hint,
    required this.cta,
    required this.onNext,
    required this.children,
  });

  final String title;
  final String? hint;
  final String cta;
  final VoidCallback onNext;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 16),
            children: [
              Text(
                title,
                style: context.t.displayLarge?.copyWith(
                  fontSize: 34,
                  letterSpacing: 34 * -0.03,
                  height: 1.12,
                ),
              ),
              if (hint != null) ...[
                const SizedBox(height: 12),
                Text(
                  hint!,
                  style: context.t.bodyMedium?.copyWith(
                    fontSize: CalviSize.fsBody,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ...children,
            ],
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
                colors: [context.c.bg.withValues(alpha: 0), context.c.bg],
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
      label: 'Назад',
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
            child: Transform.rotate(
              angle: math.pi,
              child: const CalviIcon('chevron', size: 19),
            ),
          ),
        ),
      ),
    );
  }
}

/// One option, as a card rather than a row: a first run has room for it, and a
/// choice that fills the thumb is easier than a list item.
class _Card extends StatelessWidget {
  const _Card({
    required this.label,
    this.hint,
    this.icon,
    required this.on,
    required this.onTap,
    this.first = false,
  });

  final String label;
  final String? hint;
  final String? icon;
  final bool on;
  final VoidCallback onTap;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: EdgeInsets.only(top: first ? 0 : 10),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: CalviMotion.normal,
          curve: CalviMotion.ease,
          /* Chosen is white and outlined rather than filled: the row is a choice
             among equals, and filling it black would make it read as the
             screen's action. The padding gives back what the border takes. */
          padding: EdgeInsets.symmetric(horizontal: on ? 15 : 16, vertical: on ? 13 : 14),
          decoration: BoxDecoration(
            color: on ? c.bg : c.hover,
            border: Border.all(color: on ? c.button : c.cardBorder, width: on ? 2 : 1),
            borderRadius: BorderRadius.circular(CalviSize.rLarge),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c.iconCircle),
                  child: CalviIcon(icon!, size: 19),
                ),
                const SizedBox(width: 13),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: context.t.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        letterSpacing: CalviSize.fsBody * -0.02,
                      ),
                    ),
                    if (hint != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        hint!,
                        style: context.t.labelSmall?.copyWith(fontWeight: FontWeight.w400),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 13),
              _Dot(on: on),
            ],
          ),
        ),
      ),
    );
  }
}

/// The radio of a [_Card]: a ring that fills, with a dot that grows inside it.
class _Dot extends StatelessWidget {
  const _Dot({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AnimatedContainer(
      duration: CalviMotion.normal,
      curve: CalviMotion.ease,
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: on ? c.button : const Color(0x00000000),
        border: Border.all(color: on ? c.button : c.hairline, width: 1.5),
      ),
      child: AnimatedScale(
        scale: on ? 1 : 0,
        duration: CalviMotion.normal,
        curve: CalviMotion.ease,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: c.bg),
        ),
      ),
    );
  }
}

/* A ruler with its own heading, so a screen carrying three of them does not read
   as three identical drums. */
class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    required this.unit,
    required this.child,
  });

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
        ),
        child: Column(
          children: [
            CalviRing(progress: 1, size: 40, stroke: 5, color: colour),
            const SizedBox(height: 8),
            Text('$valueг', style: context.t.titleMedium?.copyWith(fontSize: CalviSize.fsBody)),
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
          color: on ? c.button : c.fillSecondary,
          borderRadius: BorderRadius.circular(CalviSize.rPill),
        ),
        child: Text(
          label,
          style: context.t.labelSmall?.copyWith(
            fontSize: CalviSize.fsMicro,
            fontWeight: on ? FontWeight.w600 : FontWeight.w400,
            color: on ? c.buttonText : c.textSecondary,
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

/* Screen one. No account here: it asks nothing and promises the short version of
   what the app is, because the first tap should cost nothing. */
class _Hello extends StatelessWidget {
  const _Hello({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: CalviSize.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: box.maxHeight * 0.12),
            Text(
              'Calvi',
              style: context.t.displayLarge?.copyWith(fontSize: 40, letterSpacing: 40 * -0.04),
            ),
            const SizedBox(height: 12),
            Text(
              'Тут нічого не треба вести. Скажи Норі «два яйця і тост», і день порахований: '
              'ні пошуку в довідниках, ні грамів, ні таблиць. Далі вона сама.',
              style: context.t.bodyMedium?.copyWith(fontSize: CalviSize.fsBody, height: 1.45),
            ),
            const Spacer(),
            CalviButton(label: 'Почати', onTap: onNext),
            // A CSS percentage margin measures the width, not the height.
            SizedBox(height: box.maxWidth * 0.18),
          ],
        ),
      ),
    );
  }
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

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    /* The buttons sit in the body, not pinned to the floor: the sentence above
       them is the reason to press one, and it has to be read first. */
    return ListView(
      padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 16),
      children: [
        Text(
          'Збережімо це',
          style: context.t.displayLarge?.copyWith(
            fontSize: 34,
            letterSpacing: 34 * -0.03,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Норма порахована. Увійди, щоб вона лишилась при собі: історія, заміри й записи '
          'будуть на всіх пристроях, а не тільки тут.',
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
                CalviButton(label: 'Продовжити з Google', onTap: widget.onDone),
                const SizedBox(height: 10),
                _Ghost(label: 'Продовжити з Apple', onTap: widget.onDone),
                const SizedBox(height: 10),
                _Ghost(label: 'Продовжити з поштою', onTap: widget.onDone),
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
              Expanded(
                child: Text(
                  'Погоджуюсь з умовами користування і політикою приватності',
                  style: context.t.bodyMedium?.copyWith(
                    fontSize: CalviSize.fsMicro,
                    height: 1.45,
                  ),
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
