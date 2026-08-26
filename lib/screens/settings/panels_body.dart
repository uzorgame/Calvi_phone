import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../data/settings.dart';
import '../../design/ruler.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/wheel.dart';
import '../../format.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/labels.dart';
import 'account_block.dart';
import 'panels_account.dart';

/// The body the norm is calculated from: sex, age, height, activity.
class ProfilePanel extends StatelessWidget {
  const ProfilePanel({super.key, required this.s, required this.set, this.onBack});

  final SettingsState s;
  final SetSettings set;

  /// How the panel closes. It lives inside settings, not on top of it, so the
  /// way out is settings putting its list back rather than a route popping.
  final VoidCallback? onBack;

  /* Значення застосовується на «Готово», а не на кожному оберті барабана.
   *
   * Крутячи його, людина проходить повз двадцять чисел, і кожне з них
   * перерахувало б норму й усі підписи на екрані під аркушем. */
  void _pickAge(BuildContext context) {
    var picked = s.age;
    calviSheet<void>(
      context,
      title: L.of(context).profileAge,
      onDone: () => set((v) => v.copyWith(age: picked)),
      builder: (sheet) => CalviWheel(
        values: ages,
        value: s.age,
        suffix: L.of(sheet).startYearsShort,
        onPick: (age) => picked = age,
      ),
    );
  }

  void _pickHeight(BuildContext context) {
    var picked = s.heightCm;
    calviSheet<void>(
      context,
      title: L.of(context).profileHeight,
      onDone: () => set((v) => v.copyWith(heightCm: picked)),
      builder: (sheet) => CalviWheel(
        values: heights,
        value: s.heightCm,
        suffix: L.of(sheet).unitCm,
        onPick: (h) => picked = h,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return CalviScreen(
      onBack: onBack,
      title: l.setProfile,
      foot: CalviButton(label: l.actionDone, onTap: () => (onBack ?? Navigator.of(context).pop)()),
      children: [
        const AccountBlock(),

        /* Три слова без пояснень не варті трьох рядків із іконками: у ряд вони
           займають висоту одного і читаються так само. */
        CalviSection(
          title: l.profileSex,
          bare: true,
          trail: 0,
          children: [
            CalviSegments(
              labels: [l.startSexMale, l.startSexFemale, l.startSexOther],
              index: switch (s.sex) {
                Sex.m => 0,
                Sex.f => 1,
                Sex.x => 2,
              },
              onPick: (i) => set(
                (v) => v.copyWith(
                  sex: switch (i) {
                    0 => Sex.m,
                    1 => Sex.f,
                    _ => Sex.x,
                  },
                ),
              ),
            ),
          ],
        ),

        /* Барабани переїхали в аркуш, і це не про красу.
         *
         * Барабан це теж прокрутка. Палець, який починав рух на ньому, крутив
         * барабан, а сторінка стояла: людина тягла вгору, екран сіпався і не
         * піднімався. Двоє прокруток на одній осі не діляться, вибирає котрась
         * одна, і всередині завжди виграє внутрішня.
         *
         * Той самий вихід уже стоїть у нагадуваннях: барабан живе в аркуші
         * поверх сторінки, де конкурувати нема з чим. */
        CalviSection(
          children: [
            CalviRow(
              icon: 'clock',
              first: true,
              title: l.profileAge,
              value: l.startAgeYears(s.age),
              onTap: () => _pickAge(context),
            ),
            CalviRow(
              icon: 'ruler',
              title: l.profileHeight,
              value: '${s.heightCm} ${l.unitCm}',
              onTap: () => _pickHeight(context),
            ),
          ],
        ),

        CalviSection(
          title: l.profileActivity,
          bare: true,
          children: [
            for (final a in activityLevels)
              CalviPick(
                label: activityTitle(context, a.v),
                hint: activityHint(context, a.v),
                on: s.activity == a.v,
                onTap: () => set((v) => v.copyWith(activity: a.v)),
              ),
          ],
        ),

        /* Найнижче і в тому ж вбранні, що решта рядків: небезпеку каже колір
           назви, а не крик плашки. Сюди мають доходити свідомо. */
        CalviSection(
          children: [
            CalviRow(
              icon: 'note',
              first: true,
              danger: true,
              title: l.eraseDataTitle,
              onTap: () => _askErase(context),
            ),
          ],
        ),
      ],
    );
  }

  /* Стирання питається двічі, і це два окремі аркуші.
   *
   * Перший пояснює, що зникне і що лишиться: його читають. Другий існує рівно
   * для одного речення про незворотність: його підтверджують. Одне натискання
   * не має вміти стерти все, скільки б тексту над ним не стояло, бо текст
   * читають не завжди, а палець промахується. */
  void _askErase(BuildContext context) {
    final l = L.of(context);
    calviSheet<void>(
      context,
      title: l.eraseAskTitle,
      doneLabel: l.eraseAskCta,
      danger: true,
      onDone: () => _askSure(context),
      builder: (sheet) => Padding(
        padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 4, CalviSize.gutter, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.eraseAskBody1, style: sheet.t.bodyMedium),
            const SizedBox(height: 10),
            Text(l.eraseAskBody2, style: sheet.t.bodyMedium),
          ],
        ),
      ),
    );
  }

  void _askSure(BuildContext context) {
    final l = L.of(context);
    calviSheet<void>(
      context,
      title: l.eraseSureTitle,
      doneLabel: l.eraseSureCta,
      danger: true,
      onDone: () => _erase(context),
      builder: (sheet) => Padding(
        padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 4, CalviSize.gutter, 0),
        child: Text(l.eraseSureBody, style: sheet.t.bodyMedium),
      ),
    );
  }

  Future<void> _erase(BuildContext context) async {
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final sync = AppScope.maybeOf(context)?.sync;

    // Без синхронізації (демо-запуск без бази) стирати нема звідки.
    if (sync == null) return;

    try {
      await sync.eraseDiary();
      messenger.showSnackBar(SnackBar(content: Text(l.eraseDone)));
    } catch (e) {
      /* Причина в тексті: «спробуй ще раз» без неї це порада нічого не робити.
         Найчастіша причина тут одна, немає мережі, і сервер без неї не погасить
         щоденник на інших пристроях. */
      messenger.showSnackBar(
        SnackBar(content: Text(l.eraseFailed('$e')), duration: const Duration(seconds: 8)),
      );
    }
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
    final l = L.of(context);
    return CalviScreen(
      onBack: onBack,
      title: l.weightTitle,
      hint: l.weightHint,
      foot: CalviButton(label: l.actionDone, onTap: () => (onBack ?? Navigator.of(context).pop)()),
      children: [
        _Titled(
          bare: true,
          child: CalviRuler(
            value: s.weightKg,
            min: 40,
            max: 180,
            suffix: l.unitKg,
            onChange: (w) => set((v) => v.copyWith(weightKg: w)),
          ),
        ),
        CalviNote(l.weightNote),
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
    final l = L.of(context);
    final pending = _draft ?? s.targetKg;
    final weeks = weeksToTarget(s);
    final kcal = calcKcal(s);
    final brisk = s.pace > 0.8;
    final diff = (s.weightKg - s.targetKg).abs();

    return CalviScreen(
      onBack: widget.onBack,
      title: l.setGoal,
      foot: CalviButton(
        label: _changed ? l.goalNew : l.actionDone,
        onTap: () => _changed ? _confirm(context, pending) : Navigator.of(context).pop(),
      ),
      children: [
        /* Той самий сегмент, що й стать: три рівні варіанти в один рядок.
           Три високі картки з радіо важили більше, ніж рішення, яке несуть.
           В онбордингу вони лишаються картками навмисно: там людина обирає
           вперше і читає пояснення під кожним. */
        CalviSection(
          title: l.goalDirection,
          bare: true,
          children: [
            CalviSegments(
              labels: [l.startGoalLose, l.goalKeepShort, l.startGoalGain],
              index: switch (s.direction) {
                Direction.lose => 0,
                Direction.keep => 1,
                Direction.gain => 2,
              },
              onPick: (i) => set(
                (v) => v.copyWith(
                  direction: switch (i) {
                    0 => Direction.lose,
                    1 => Direction.keep,
                    _ => Direction.gain,
                  },
                ),
              ),
            ),
          ],
        ),

        if (s.direction != Direction.keep) ...[
          _Titled(
            title: l.goalTarget,
            aside: l.goalDiff(diff.toStringAsFixed(1)),
            bare: true,
            child: Column(
              children: [
                CalviRuler(
                  value: pending,
                  min: 40,
                  max: 180,
                  suffix: l.unitKg,
                  onChange: (v) => setState(() => _draft = v),
                ),
                if (_changed)
                  CalviNote.rich(
                    l.goalCurrent,
                    bold: '${s.targetKg.toStringAsFixed(1)} ${l.unitKg}',
                    rest: l.goalFromStart(s.goalStartKg.toStringAsFixed(1)) + l.goalFromToday,
                    lead: 12,
                  ),
              ],
            ),
          ),

          _Titled(
            title: l.goalPace,
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
                        child: Text(l.goalPaceUnit, style: context.t.bodyMedium),
                      ),
                    ],
                  ),
                ),
                CalviSlider(
                  value: s.pace,
                  min: 0.1,
                  max: 1.2,
                  step: 0.1,
                  marks: [l.goalPaceSlow, l.goalPaceUsual, l.goalPaceFast],
                  onChange: (p) => set((v) => v.copyWith(pace: p)),
                ),
              ],
            ),
          ),
        ],

        CalviFacts(
          rows: [
            (l.goalDailyNorm, l.normKcalOf(thousands(kcal))),
            if (weeks > 0) (l.goalEta, targetDate(weeks)),
          ],
          note: s.direction == Direction.keep
              ? l.goalKeepNote
              : brisk
              ? l.startPaceWarning
              : l.goalPaceOk,
        ),
      ],
    );
  }

  void _confirm(BuildContext context, double pending) {
    final s = widget.s;
    final l = L.of(context);
    calviSheet(
      context,
      title: l.goalNewTitle,
      doneLabel: l.goalSet,
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
              label: l.goalWas,
              text: l.goalRange(s.goalStartKg.toStringAsFixed(1), s.targetKg.toStringAsFixed(1)),
              strong: false,
            ),
            _Was(
              label: l.goalBecomes,
              text: l.goalRange(s.weightKg.toStringAsFixed(1), pending.toStringAsFixed(1)),
              strong: true,
            ),
            const SizedBox(height: 12),
            Text(l.goalReplaceNote, style: sheet.t.bodyMedium),
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
            style: context.t.titleMedium?.copyWith(fontSize: 15, color: strong ? c.accent : c.text),
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
    final l = L.of(context);
    final auto = calcKcal(s);
    final manual = s.kcalManual != null;
    final kcal = dailyKcal(s);
    final sum = s.protein * 4 + s.fat * 9 + s.carbs * 4;
    final off = sum - kcal;
    final ok = off.abs() <= 60;
    final perKg = (s.waterMl / s.weightKg * 10).round() / 10;

    return CalviScreen(
      onBack: onBack,
      title: l.normTitle,
      foot: CalviButton(label: l.actionDone, onTap: () => (onBack ?? Navigator.of(context).pop)()),
      children: [
        /* Норма і склад однією тихою карткою.
         *
         * Доти тут стояли три великі блоки, і два з них казали одне: число
         * норми вгорі, а нижче окрема кольорова смуга «2 378 з 2 250 ккал».
         * Тепер це один предмет: число, під ним склад тією ж мовою кольору,
         * що в кільцях дня, і рядок стану звичайним текстом. Кричати тут нема
         * про що, сюди заходять раз на місяць. */
        Padding(
          padding: const EdgeInsets.fromLTRB(
            CalviSize.gutter,
            0,
            CalviSize.gutter,
            CalviSize.gapSection,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: c.card,
              border: Border.all(color: c.cardBorder),
              borderRadius: BorderRadius.circular(CalviSize.rLarge),
              boxShadow: context.shadowCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      thousands(kcal),
                      style: context.t.displayLarge?.copyWith(
                        fontSize: 34,
                        height: 1,
                        letterSpacing: 34 * -0.03,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l.normPerDay, style: context.t.bodyMedium)),
                    if (manual)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          // The colour of carbohydrates, thinned: a number
                          // somebody typed is worth marking, not alarming about.
                          color: c.carbs.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(CalviSize.rPill),
                        ),
                        child: Text(
                          l.normManual,
                          style: context.t.labelSmall?.copyWith(color: chipInk(context, c.carbs)),
                        ),
                      ),
                  ],
                ),

                /* Склад як частки одного цілого: смуга сама показує, чого
                   багато, а чого мало, і три числа під нею перестають бути
                   трьома окремими фактами. */
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
                  child: SizedBox(
                    height: 6,
                    child: Row(
                      children: [
                        for (final (i, part) in [
                          (s.protein * 4, c.protein),
                          (s.fat * 9, c.fats),
                          (s.carbs * 4, c.carbs),
                        ].indexed) ...[
                          if (i > 0) const SizedBox(width: 3),
                          Expanded(
                            flex: part.$1 < 1 ? 1 : part.$1,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: part.$2,
                                borderRadius: BorderRadius.circular(CalviSize.rPill),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                /* Стан рядком, а не кольоровою плашкою: коли все сходиться, це
                   не подія, і зелений прямокутник святкував би арифметику. */
                Text(
                  ok ? l.normFits : l.normOffBy(thousands(sum), off.abs()),
                  style: context.t.labelSmall?.copyWith(color: ok ? null : c.protein),
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
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.fillSecondary,
                          borderRadius: BorderRadius.circular(CalviSize.rPill),
                        ),
                        child: Text(
                          l.normFitCarbs,
                          style: context.t.labelSmall?.copyWith(
                            color: c.text,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        /* Два слова замість двох карток із поясненнями: вибір тут двійковий, і
           рядок сегмента важить рівно стільки, скільки важить це рішення. */
        CalviSection(
          title: l.normWhere,
          bare: true,
          children: [
            CalviSegments(
              labels: [l.normAutoShort, l.normByHandShort],
              index: manual ? 1 : 0,
              onPick: (i) => set(
                (v) => i == 0
                    ? v.copyWith(clearKcalManual: true)
                    : v.copyWith(kcalManual: s.kcalManual ?? auto),
              ),
            ),
            if (!manual)
              CalviNote.rich(
                l.normAutoFrom,
                bold: l.normKcalOf(thousands(auto)),
                rest: '.',
                lead: 12,
              ),
            if (manual) ...[
              /* Проміжок, бо інакше перемикач і поле з числом злипаються в одну
                 фігуру: «Автоматично / Вручну» перестає читатись як вибір, а
                 число під ним як його наслідок. Водяний степер стоїть у своєму
                 блоці першим і відступу не має, як і в демці. */
              const SizedBox(height: CalviSize.gapCard),
              CalviStepper(
                value: s.kcalManual ?? auto,
                step: 50,
                min: 1200,
                suffix: l.unitKcal,
                onChange: (v) => set((x) => x.copyWith(kcalManual: v < 1200 ? 1200 : v)),
              ),
              CalviNote.rich(
                l.normCalculatedHead,
                bold: l.normKcalOf(thousands(auto)),
                rest: l.normCalculatedTail,
                lead: 12,
              ),
            ],
          ],
        ),

        _Titled(
          title: l.normMacros,
          aside: l.normMacroSplit(s.protein, s.fat, s.carbs),
          bare: true,
          child: Column(
            children: [
              /* Сума і кнопка підгонки переїхали в картку норми вгорі: там
                 вони стоять поруч із числом, проти якого рахуються, а тут
                 повторювали б його вдруге. */
              _MacroRow(label: l.macroProtein, value: l.normGrams(s.protein)),
              CalviSlider(
                value: s.protein.toDouble(),
                min: 40,
                max: 260,
                step: 5,
                onChange: (v) => set((x) => x.copyWith(protein: v.round())),
              ),
              _MacroRow(label: l.macroFat, value: l.normGrams(s.fat)),
              CalviSlider(
                value: s.fat.toDouble(),
                min: 20,
                max: 160,
                step: 2,
                onChange: (v) => set((x) => x.copyWith(fat: v.round())),
              ),
              _MacroRow(label: l.macroCarbs, value: l.normGrams(s.carbs)),
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
          title: l.normWater,
          bare: true,
          child: Column(
            children: [
              CalviStepper(
                value: s.waterMl,
                step: 100,
                suffix: l.unitMl,
                onChange: (v) => set((x) => x.copyWith(waterMl: v)),
              ),
              CalviNote.rich(
                l.normWaterHead,
                bold: '$perKg ${l.unitMl}',
                rest: l.normWaterTail,
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
                boxShadow: context.shadowCard,
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
