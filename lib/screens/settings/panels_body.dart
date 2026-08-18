import 'package:flutter/material.dart';

import '../../data/settings.dart';
import '../../design/ruler.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/wheel.dart';
import '../../format.dart';
import 'panels_account.dart';


/// The body the norm is calculated from: sex, age, height, activity.
class ProfilePanel extends StatelessWidget {
  const ProfilePanel({super.key, required this.s, required this.set, this.onBack});

  final SettingsState s;
  final SetSettings set;

  /// How the panel closes. It lives inside settings, not on top of it, so the
  /// way out is settings putting its list back rather than a route popping.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return CalviScreen(
      onBack: onBack,
      title: 'Профіль',
      hint: 'Ці числа стоять у формулі денної норми, тому їх варто тримати точними.',
      foot: CalviButton(label: 'Готово', onTap: () => (onBack ?? Navigator.of(context).pop)()),
      children: [
        CalviSection(
          title: 'Стать',
          bare: true,
          children: [
            /* Only the third option needs saying: the two formulas are what
               everybody expects, and a note under each of them would be two
               lines of arithmetic nobody asked to read. */
            CalviPick(
              label: 'Чоловіча',
              icon: 'user',
              on: s.sex == Sex.m,
              onTap: () => set((v) => v.copyWith(sex: Sex.m)),
            ),
            CalviPick(
              label: 'Жіноча',
              icon: 'user',
              on: s.sex == Sex.f,
              onTap: () => set((v) => v.copyWith(sex: Sex.f)),
            ),
            CalviPick(
              label: 'Інше',
              hint: 'норма береться як середнє двох формул',
              icon: 'user',
              on: s.sex == Sex.x,
              onTap: () => set((v) => v.copyWith(sex: Sex.x)),
            ),
          ],
        ),

        _Titled(
          title: 'Вік',
          aside: '${s.age} років',
          bare: true,
          child: CalviWheel(
            values: ages,
            value: s.age,
            suffix: 'років',
            onPick: (age) => set((v) => v.copyWith(age: age)),
          ),
        ),

        _Titled(
          title: 'Зріст',
          aside: '${s.heightCm} см',
          bare: true,
          child: CalviWheel(
            values: heights,
            value: s.heightCm,
            suffix: 'см',
            onPick: (h) => set((v) => v.copyWith(heightCm: h)),
          ),
        ),

        CalviSection(
          title: 'Активність',
          bare: true,
          children: [
            for (final a in activityLevels)
              CalviPick(
                label: a.label,
                hint: a.hint,
                on: s.activity == a.v,
                onTap: () => set((v) => v.copyWith(activity: a.v)),
              ),
          ],
        ),
      ],
    );
  }
}

/// Weight, and only today's. Where it should end up is the goal's business.
class WeightPanel extends StatelessWidget {
  const WeightPanel({super.key, required this.s, required this.set, this.onBack});

  final SettingsState s;
  final SetSettings set;

  /// How the panel closes. It lives inside settings, not on top of it, so the
  /// way out is settings putting its list back rather than a route popping.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return CalviScreen(
      onBack: onBack,
      title: 'Вага',
      hint: 'Скільки ти важиш сьогодні. Ціль і темп до неї живуть окремо.',
      foot: CalviButton(label: 'Готово', onTap: () => (onBack ?? Navigator.of(context).pop)()),
      children: [
        _Titled(
          bare: true,
          child: CalviRuler(
            value: s.weightKg,
            min: 40,
            max: 180,
            suffix: 'кг',
            onChange: (w) => set((v) => v.copyWith(weightKg: w)),
          ),
        ),
        const CalviNote(
          'Записуй вагу вранці, до їжі: так добові коливання не перетворюють графік на шум. '
          'Один замір на тиждень уже дає тренд.',
        ),
      ],
    );
  }
}

/// The goal: which way, to what weight, and how fast.
class GoalPanel extends StatefulWidget {
  const GoalPanel({super.key, required this.s, required this.set, this.onBack});

  final SettingsState s;
  final SetSettings set;

  /// How the panel closes. It lives inside settings, not on top of it, so the
  /// way out is settings putting its list back rather than a route popping.
  final VoidCallback? onBack;

  @override
  State<GoalPanel> createState() => _GoalPanelState();
}

class _GoalPanelState extends State<GoalPanel> {
  /* A goal is never edited in place. Changing the target rewrites what every
     progress figure is measured against, and silently moving that line makes
     the ring on the home screen jump for no reason the person can see. So a new
     target is a new goal: confirmed once, and anchored to the weight on the day
     it was set. */
  double? _draft;

  bool get _changed => _draft != null && _draft != widget.s.targetKg;

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final set = widget.set;
    final pending = _draft ?? s.targetKg;
    final weeks = weeksToTarget(s);
    final kcal = calcKcal(s);
    final brisk = s.pace > 0.8;
    final diff = (s.weightKg - s.targetKg).abs();

    return CalviScreen(
      onBack: widget.onBack,
      title: 'Ціль',
      hint:
          'Куди рухаємось і як швидко. Швидше означає більший дефіцит, а не кращий результат.',
      foot: CalviButton(
        label: _changed ? 'Поставити нову ціль' : 'Готово',
        onTap: () => _changed ? _confirm(context, pending) : Navigator.of(context).pop(),
      ),
      children: [
        CalviSection(
          title: 'Напрямок',
          bare: true,
          children: [
            CalviPick(
              label: 'Схуднути',
              icon: 'down',
              on: s.direction == Direction.lose,
              onTap: () => set((v) => v.copyWith(direction: Direction.lose)),
            ),
            CalviPick(
              label: 'Тримати вагу',
              icon: 'minus',
              on: s.direction == Direction.keep,
              onTap: () => set((v) => v.copyWith(direction: Direction.keep)),
            ),
            CalviPick(
              label: 'Набрати',
              icon: 'up',
              on: s.direction == Direction.gain,
              onTap: () => set((v) => v.copyWith(direction: Direction.gain)),
            ),
          ],
        ),

        if (s.direction != Direction.keep) ...[
          _Titled(
            title: 'Цільова вага',
            aside: 'різниця ${diff.toStringAsFixed(1)} кг',
            bare: true,
            child: Column(
              children: [
                CalviRuler(
                  value: pending,
                  min: 40,
                  max: 180,
                  suffix: 'кг',
                  onChange: (v) => setState(() => _draft = v),
                ),
                if (_changed)
                  CalviNote.rich(
                    'Поточна ціль ',
                    bold: '${s.targetKg.toStringAsFixed(1)} кг',
                    rest:
                        ' від ${s.goalStartKg.toStringAsFixed(1)} кг на старті. '
                        'Нова ціль почнеться від сьогоднішньої ваги.',
                    lead: 12,
                  ),
              ],
            ),
          ),

          _Titled(
            title: 'Темп',
            bare: true,
            child: Column(
              children: [
                // The figure and what it counts, one over the other and centred.
                Padding(
                  padding: const EdgeInsets.only(bottom: 26),
                  child: Column(
                    children: [
                      Text(
                        s.pace.toStringAsFixed(1),
                        style: context.t.displayLarge?.copyWith(
                          fontSize: 40,
                          height: 1.26,
                          letterSpacing: 40 * -0.02,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text('кг на тиждень', style: context.t.bodyMedium),
                      ),
                    ],
                  ),
                ),
                CalviSlider(
                  value: s.pace,
                  min: 0.1,
                  max: 1.2,
                  step: 0.1,
                  marks: const ['Повільно', 'Рекомендовано', 'Швидко'],
                  onChange: (p) => set((v) => v.copyWith(pace: p)),
                ),
              ],
            ),
          ),
        ],

        CalviFacts(
          rows: [
            ('Денна норма', '${thousands(kcal)} ккал'),
            if (weeks > 0) ('Ціль приблизно', targetDate(weeks)),
          ],
          note: s.direction == Direction.keep
              ? 'Норма тримає поточну вагу: скільки витрачаєш, стільки й повертаєш.'
              : brisk
              ? 'Такий темп тримається важко і зазвичай зривається. Нижче за 0.8 кг на тиждень '
                    'результат виходить повільніший, але лишається.'
              : 'Це темп, який більшість витримує без зривів.',
        ),
      ],
    );
  }

  void _confirm(BuildContext context, double pending) {
    final s = widget.s;
    calviSheet(
      context,
      title: 'Нова ціль',
      doneLabel: 'Поставити',
      onDone: () {
        /* The new goal is anchored to today's weight, not to the old anchor:
           progress on a goal set this morning cannot start from a figure that
           belongs to the goal it replaced. */
        widget.set((v) => v.copyWith(targetKg: pending, goalStartKg: s.weightKg));
        setState(() => _draft = null);
      },
      builder: (sheet) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Was(
              label: 'Було',
              text: '${s.goalStartKg.toStringAsFixed(1)} → ${s.targetKg.toStringAsFixed(1)} кг',
              strong: false,
            ),
            _Was(
              label: 'Стане',
              text: '${s.weightKg.toStringAsFixed(1)} → ${pending.toStringAsFixed(1)} кг',
              strong: true,
            ),
            const SizedBox(height: 12),
            Text(
              'Ціль не редагується, вона замінюється. Прогрес почне рахуватись від сьогоднішньої '
              'ваги, а стара ціль лишиться в історії. Підтверджуєш заміну?',
              style: sheet.t.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _Was extends StatelessWidget {
  const _Was({required this.label, required this.text, required this.strong});

  final String label;
  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: context.t.bodyMedium)),
          Text(
            text,
            style: context.t.titleMedium?.copyWith(
              fontSize: 15,
              color: strong ? c.accent : c.text,
            ),
          ),
        ],
      ),
    );
  }
}

/// The whole norm on one screen: calories, macros and water.
///
/// These were three separate rows once, and that was wrong: macros are
/// calculated from calories and water from weight. Splitting numbers that move
/// each other across separate screens hides from the person what they just
/// changed.
class NormPanel extends StatelessWidget {
  const NormPanel({super.key, required this.s, required this.set, this.onBack});

  final SettingsState s;
  final SetSettings set;

  /// How the panel closes. It lives inside settings, not on top of it, so the
  /// way out is settings putting its list back rather than a route popping.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final auto = calcKcal(s);
    final manual = s.kcalManual != null;
    final kcal = dailyKcal(s);
    final sum = s.protein * 4 + s.fat * 9 + s.carbs * 4;
    final off = sum - kcal;
    final ok = off.abs() <= 60;
    final perKg = (s.waterMl / s.weightKg * 10).round() / 10;

    return CalviScreen(
      onBack: onBack,
      title: 'Норма',
      foot: CalviButton(label: 'Готово', onTap: () => (onBack ?? Navigator.of(context).pop)()),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
          child: Column(
            children: [
              Text(
                thousands(kcal),
                style: context.t.displayLarge?.copyWith(
                  fontSize: 54,
                  height: 1,
                  letterSpacing: 54 * -0.02,
                ),
              ),
              const SizedBox(height: 8),
              Text('ккал на день', style: context.t.bodyMedium),
              if (manual)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                    decoration: BoxDecoration(
                      // The colour of carbohydrates, thinned: a number somebody
                      // typed is worth marking, not worth alarming about.
                      color: c.carbs.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(CalviSize.rPill),
                    ),
                    child: Text(
                      'перевизначено вручну',
                      style: context.t.labelSmall?.copyWith(color: const Color(0xFF9A6300)),
                    ),
                  ),
                ),
            ],
          ),
        ),

        CalviSection(
          title: 'Звідки це число',
          bare: true,
          children: [
            CalviPick(
              label: 'Рахувати автоматично',
              hint: 'з ваги, зросту, віку, активності й цілі: ${thousands(auto)} ккал',
              on: !manual,
              onTap: () => set((v) => v.copyWith(clearKcalManual: true)),
            ),
            CalviPick(
              label: 'Задати вручну',
              hint: 'аналітика рахуватиме проти цього числа',
              on: manual,
              onTap: () => set((v) => v.copyWith(kcalManual: s.kcalManual ?? auto)),
            ),
            if (manual) ...[
              CalviStepper(
                value: s.kcalManual ?? auto,
                step: 50,
                min: 1200,
                suffix: 'ккал',
                onChange: (v) => set((x) => x.copyWith(kcalManual: v < 1200 ? 1200 : v)),
              ),
              CalviNote.rich(
                'Розрахункове значення ',
                bold: '${thousands(auto)} ккал',
                rest: '. Повернутись до нього можна вибором «Рахувати автоматично».',
                lead: 12,
              ),
            ],
          ],
        ),

        _Titled(
          title: 'БЖВ',
          aside: '${s.protein} / ${s.fat} / ${s.carbs} г',
          bare: true,
          child: Column(
            children: [
              /* Green while the three add up to the norm, pink when they do not:
                 the sum is the one number on this screen that can be wrong, and
                 it says so by its ground rather than by a warning. */
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: (ok ? c.success : c.protein).withValues(alpha: ok ? 0.10 : 0.08),
                  borderRadius: BorderRadius.circular(CalviSize.rLarge),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      thousands(sum),
                      style: context.t.headlineMedium?.copyWith(
                        fontSize: 24,
                        height: 1.26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 24 * -0.02,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('з ${thousands(kcal)} ккал', style: context.t.bodyMedium),
                    ),
                    if (!ok)
                      Text(
                        '${off > 0 ? '+' : ''}$off',
                        style: context.t.titleMedium?.copyWith(
                          fontSize: CalviSize.fsCaption,
                          color: c.protein,
                        ),
                      ),
                  ],
                ),
              ),

              /* Never block the exit on arithmetic the person did not create.
                 Offer the fix instead: keep protein and fats, solve carbs. */
              if (!ok)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: GestureDetector(
                    onTap: () => set(
                      (v) => v.copyWith(
                        carbs: (((kcal - s.protein * 4 - s.fat * 9) / 4 / 5).round() * 5).clamp(
                          0,
                          1000,
                        ),
                      ),
                    ),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: c.fillSecondary,
                        borderRadius: BorderRadius.circular(CalviSize.rPill),
                      ),
                      child: Text(
                        'Підігнати вуглеводи під норму',
                        style: context.t.titleMedium?.copyWith(
                          fontSize: CalviSize.fsCaption,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

              // The sum stands a section clear of the sliders under it.
              const SizedBox(height: CalviSize.gapSection - 18),
              _MacroRow(label: 'Білок', value: '${s.protein} г'),
              CalviSlider(
                value: s.protein.toDouble(),
                min: 40,
                max: 260,
                step: 5,
                onChange: (v) => set((x) => x.copyWith(protein: v.round())),
              ),
              _MacroRow(label: 'Жири', value: '${s.fat} г'),
              CalviSlider(
                value: s.fat.toDouble(),
                min: 20,
                max: 160,
                step: 2,
                onChange: (v) => set((x) => x.copyWith(fat: v.round())),
              ),
              _MacroRow(label: 'Вуглеводи', value: '${s.carbs} г'),
              CalviSlider(
                value: s.carbs.toDouble(),
                min: 40,
                max: 500,
                step: 5,
                onChange: (v) => set((x) => x.copyWith(carbs: v.round())),
              ),
            ],
          ),
        ),

        _Titled(
          title: 'Вода',
          bare: true,
          child: Column(
            children: [
              CalviStepper(
                value: s.waterMl,
                step: 100,
                suffix: 'мл',
                onChange: (v) => set((x) => x.copyWith(waterMl: v)),
              ),
              CalviNote.rich(
                'Це ',
                bold: '$perKg мл',
                rest:
                    ' на кілограм ваги. Звична орієнтовна вилка це 30-40 мл, але вона залежить '
                    'від спеки й тренувань, тому число тут не жорстке.',
                lead: 12,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 18, 0, 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(child: Text(label, style: context.t.bodyMedium)),
        Text(
          value,
          style: context.t.titleMedium?.copyWith(letterSpacing: CalviSize.fsBody * -0.02),
        ),
      ],
    ),
  );
}

/// A card with an optional title above it and a figure on the right of that
/// title: what the control below is currently set to, without reading it off
/// the control itself.
class _Titled extends StatelessWidget {
  const _Titled({this.title, this.aside, this.bare = false, required this.child});

  final String? title;
  final String? aside;

  /// The tape stands on its own; boxing it makes a loud frame of a quiet scale.
  final bool bare;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CalviSize.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(child: Text(title!, style: context.t.titleMedium)),
                  if (aside != null) Text(aside!, style: context.t.bodyMedium),
                ],
              ),
            ),
          if (bare)
            child
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: c.card,
                border: Border.all(color: c.cardBorder),
                borderRadius: BorderRadius.circular(CalviSize.rLarge),
              ),
              clipBehavior: Clip.antiAlias,
              child: child,
            ),
          const SizedBox(height: CalviSize.gapSection),
        ],
      ),
    );
  }
}
