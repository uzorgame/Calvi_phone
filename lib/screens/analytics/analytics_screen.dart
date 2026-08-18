import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/fixtures.dart';
import '../../data/measure.dart';
import '../../data/settings.dart';
import '../../data/app_scope.dart';
import '../../design/icons.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../format.dart';
import 'charts.dart';

class Period {
  const Period({required this.days, required this.label});

  final int days;
  final String label;
}

const _periods = [
  Period(days: 7, label: 'Тиждень'),
  Period(days: 30, label: 'Місяць'),
  Period(days: 90, label: '3 місяці'),
  Period(days: 365, label: 'Рік'),
];

/// Six months of weight, for the goal card.
const _weightSeries = [81.0, 80.6, 80.9, 79.8, 79.4, 78.9, 78.6];
const _weightLabels = ['Чер', 'Лип', 'Сер', 'Вер', 'Жов', 'Лис', 'Гру'];

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key, required this.measures, required this.onSettings});

  final List<Measure> measures;
  final VoidCallback onSettings;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _period = 0;
  String _tape = 'weightKg';

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final s = AppScope.of(context).s;
    final goal = goalOf(s);
    final days = _periods[_period].days;

    /* The tape moves once a month, so a week-long window shows a row of dots and
       says nothing. It gets its own floor and names the window it actually
       used. */
    final tapeDays = days < 90 ? 90 : days;
    final tapeLabel = tapeDays >= 365 ? 'за рік' : 'за 3 місяці';

    /* Числа беруться з підсумків застосунку, а не з фікстур. У режимі «мої» це
       те, що людина справді записала; у демо це демонстраційний тиждень. Екран
       про різницю не знає і знати не має. */
    final stats = AppScope.of(context).stats;

    /* Columns and figures come from the same window: a headline counted over a
       month above a chart drawn over a week is two answers to one question. */
    final buckets = bucketDays(days);
    final dates = [for (final b in buckets) ...b.dates];
    final logged = dates.where((d) => stats.totalsOn(d).kcal > 0).length;
    final total = dates.fold<int>(0, (a, d) => a + stats.totalsOn(d).kcal);
    // Averaged over the days actually logged, not over the calendar: a week
    // opened on Friday is not a week of two hundred calories a day.
    final avg = (total / (logged == 0 ? 1 : logged)).round();
    final share = (avg / goal.kcal * 100).round();
    final ok = share >= 90 && share <= 110;

    final span = s.goalStartKg - s.targetKg;
    final done = span > 0
        ? ((s.goalStartKg - s.weightKg) / span * 100).round().clamp(0, 100)
        : 0;

    final tracked = measureFields
        .where((f) => latestMeasure(widget.measures, f.key) != null)
        .toList();
    final field = tracked.isEmpty
        ? null
        : tracked.firstWhere((f) => f.key == _tape, orElse: () => tracked.first);

    return CalviScreen(
      title: 'Аналітика',
      trailing: GestureDetector(
        onTap: widget.onSettings,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: c.fillSecondary),
          child: const CalviIcon('settings', size: 18),
        ),
      ),
      children: [
        /* A row of four equal pills read as tabs and behaved as nothing: nothing
           moved when one was pressed, and there was no way to tell which was
           current except by colour. A sliding segment answers both. */
        Padding(
          padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 6),
          child: CalviSegments(
            labels: [for (final p in _periods) p.label],
            index: _period,
            onPick: (i) => setState(() => _period = i),
          ),
        ),

        _Block(
          title: 'Прогрес до цілі',
          badge: '$done% пройдено',
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Figure(
                    value: s.weightKg.toStringAsFixed(1),
                    cap: 'поточна, кг',
                    tight: true,
                  ),
                  CalviIcon('trend', size: 20, color: c.textSecondary),
                  _Figure(
                    value: s.targetKg.toStringAsFixed(1),
                    cap: 'ціль, кг',
                    dim: true,
                    tight: true,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              LineChart(
                values: _weightSeries,
                labels: _weightLabels,
                goal: s.targetKg,
                highlight: 4,
                highlightNote: '12 жовтня',
                height: 132,
              ),
              const SizedBox(height: 12),
              // The most valuable number on the page: it turns an abstract goal
              // into a date the person can picture.
              _Note('За поточним темпом ціль близько *${targetDay(weeksToTarget(s))}*'),
            ],
          ),
        ),

        _Block(
          title: 'Калорії',
          badge: '$share% від норми',
          warn: !ok,
          child: Column(
            children: [
              Row(
                children: [
                  _Figure(value: thousands(total), cap: 'за період, ккал'),
                  const SizedBox(width: 18),
                  Container(width: 1, height: 34, color: c.cardBorder),
                  const SizedBox(width: 18),
                  _Figure(value: thousands(avg), cap: 'у середньому за день'),
                ],
              ),
              const SizedBox(height: 16),
              MacroBars(
                rows: [
                  for (final b in buckets)
                    if (totalsOf(b.dates) case final t)
                      (label: b.label, protein: t.protein, fat: t.fat, carbs: t.carbs),
                ],
              ),
            ],
          ),
        ),

        _Block(
          title: 'Гідратація',
          aside: 'норма ${thousands(goal.waterMl)} мл',
          child: Builder(
            builder: (context) {
              /* Water is asked of every day in the window, then drawn per
                 column: the question is how often the target was cleared, and
                 that is a count of days, not of columns. */
              final wetDays = dates.where((d) => stats.waterOn(d) > 0).length;
              final hit = dates.where((d) => stats.waterOn(d) >= goal.waterMl).length;
              final avgMl = wetDays == 0
                  ? 0
                  : (dates.fold<int>(0, (a, d) => a + stats.waterOn(d)) / wetDays).round();
              final water = [
                for (final b in buckets)
                  (
                    label: b.label,
                    // A column of several days shows the best of them: a sum
                    // would tower over the daily target line and mean nothing.
                    ml: b.dates.fold<int>(0, (a, d) => math.max(a, stats.waterOn(d))),
                  ),
              ];

              return Column(
                children: [
                  Row(
                    children: [
                      _Figure(value: '$hit', suffix: '/${dates.length}', cap: 'днів у нормі'),
                      const SizedBox(width: 18),
                      Container(width: 1, height: 34, color: c.cardBorder),
                      const SizedBox(width: 18),
                      _Figure(value: thousands(avgMl), cap: 'у середньому, мл'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  HydrationBars(rows: water, goalMl: goal.waterMl),
                ],
              );
            },
          ),
        ),

        _Block(
          title: 'Заміри',
          aside: 'зміна $tapeLabel',
          child: field == null
              ? const CalviNora(
                  text: 'Замірів ще немає.',
                  hint: 'Заміряйся раз на місяць, і я покажу, що рухається',
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /* One chart, switched on the same segment the period picker
                       uses. Eight sparklines side by side made eight tiny
                       pictures and no reading, and a row of chips said "filter"
                       when exactly one of these is ever on screen. */
                    CalviSegments(
                      labels: [for (final f in tracked) f.label],
                      index: tracked.indexWhere((f) => f.key == field.key),
                      cell: 84,
                      onPick: (i) => setState(() => _tape = tracked[i].key),
                    ),
                    const SizedBox(height: 18),
                    _TapeHead(list: widget.measures, field: field, days: tapeDays),
                    const SizedBox(height: 10),
                    Builder(
                      builder: (context) {
                        final points =
                            widget.measures
                                .where((m) => m[field.key] != null && m.date >= -tapeDays)
                                .toList()
                              ..sort((a, b) => a.date.compareTo(b.date));
                        return LineChart(
                          // Keyed by measurement so the line redraws when the
                          // chip changes: the same painter kept its finished
                          // animation.
                          key: ValueKey(field.key),
                          values: [for (final m in points) m[field.key]!],
                          // No axis under the tape: four readings a year would
                          // need four dates, and they do not fit side by side.
                          labels: const [],
                          unit: field.unit,
                        );
                      },
                    ),
                  ],
                ),
        ),

        _Block(
          title: 'БЖВ у середньому',
          child: Column(
            children: [
              MacroLine(label: 'Білок', value: 96, goal: goal.protein, colour: c.protein),
              MacroLine(label: 'Жири', value: 71, goal: goal.fat, colour: c.fats),
              MacroLine(label: 'Вуглеводи', value: 268, goal: goal.carbs, colour: c.carbs),
            ],
          ),
        ),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.title,
    this.badge,
    this.aside,
    this.warn = false,
    required this.child,
  });

  final String title;
  final String? badge;
  final String? aside;
  final bool warn;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 12, CalviSize.gutter, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(child: Text(title, style: context.t.titleMedium)),
                if (badge != null) _Badge(text: badge!, warn: warn),
                if (aside != null) Text(aside!, style: context.t.bodyMedium),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: c.card,
              border: Border.all(color: c.cardBorder),
              borderRadius: BorderRadius.circular(CalviSize.rLarge),
            ),
            child: child,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

/// The verdict beside a section title: green on the way, amber off it.
///
/// The one-glance answer to whether the chart under it is worth reading, which
/// is why it is a colour and not another grey pill.
class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.warn});

  final String text;
  final bool warn;

  /// The figure leads, so it carries the weight and the words after it do not.
  static final _lead = RegExp(r'^(\S+)\s+(.*)$');

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = _lead.firstMatch(text);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (warn ? c.carbs : c.success).withValues(alpha: warn ? 0.16 : 0.13),
        borderRadius: BorderRadius.circular(CalviSize.rPill),
      ),
      child: Text.rich(
        TextSpan(
          text: m == null ? text : '${m.group(1)} ',
          style: const TextStyle(fontWeight: FontWeight.w700),
          children: [
            if (m != null)
              TextSpan(
                text: m.group(2),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
          ],
        ),
        style: context.t.labelSmall?.copyWith(
          color: warn ? const Color(0xFF9A6300) : const Color(0xFF1F8A3D),
        ),
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.value,
    required this.cap,
    this.suffix,
    this.dim = false,
    this.tight = false,
  });

  final String value;
  final String cap;
  final String? suffix;
  final bool dim;

  /// Sized by its own text instead of taking an equal share of the row.
  final bool tight;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: value,
            children: [
              if (suffix != null)
                TextSpan(
                  text: suffix,
                  style: context.t.headlineMedium?.copyWith(color: c.textSecondary),
                ),
            ],
          ),
          style: context.t.headlineLarge?.copyWith(
            fontSize: 30,
            height: 1,
            color: dim ? c.textSecondary : c.text,
          ),
        ),
        const SizedBox(height: 5),
        // One line, the way the demo sets it: a caption that wraps turns a pair
        // of figures into two columns of different heights.
        Text(
          cap,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
          style: context.t.labelSmall?.copyWith(fontWeight: FontWeight.w400),
        ),
      ],
    );
    return tight ? body : Expanded(child: body);
  }
}

/* Only two measurements have a direction the app can defend. Weight moves
   toward the stated goal, and a waist is a health marker on its own. A chest or
   a thigh that shrank could be fat or muscle, and the tape cannot tell which, so
   painting it red would be the app asserting something it does not know.
   Everything else gets the number and no verdict. */
const _judged = ['weightKg', 'waist'];

class _TapeHead extends StatelessWidget {
  const _TapeHead({required this.list, required this.field, required this.days});

  final List<Measure> list;
  final MeasureField field;
  final int days;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final d = measureDelta(list, field.key, days);
    final now = latestMeasure(list, field.key)!;
    final good = d != null && d != 0 && _judged.contains(field.key) ? d < 0 : null;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  text: _trim(now.v),
                  children: [
                    TextSpan(
                      text: ' ${field.unit}',
                      style: context.t.headlineMedium?.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
                style: context.t.headlineLarge?.copyWith(fontSize: 27),
              ),
              const SizedBox(height: 3),
              Text('зараз', style: context.t.labelSmall),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: c.fillSecondary,
            borderRadius: BorderRadius.circular(CalviSize.rPill),
          ),
          child: Text(
            d == null ? 'один замір' : '${d > 0 ? '+' : ''}${_trim(d)} ${field.unit}',
            style: context.t.titleMedium?.copyWith(
              fontSize: 13,
              color: good == null
                  ? c.text
                  : good
                  ? c.success
                  : c.protein,
            ),
          ),
        ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 14),
    padding: const EdgeInsets.only(top: 13),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: context.c.cardBorder)),
    ),
    child: Text.rich(_spans(context, text), style: context.t.bodyMedium?.copyWith(height: 1.5)),
  );

  /* Anything between asterisks is the answer the sentence was written for, so it
     is the one part in the ink of the page. */
  TextSpan _spans(BuildContext context, String raw) {
    final parts = raw.split('*');
    return TextSpan(
      children: [
        for (final (i, p) in parts.indexed)
          TextSpan(
            text: p,
            style: i.isOdd
                ? TextStyle(color: context.c.text, fontWeight: FontWeight.w600)
                : null,
          ),
      ],
    );
  }
}

String _trim(double v) {
  final s = v.toStringAsFixed(1);
  return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
}
