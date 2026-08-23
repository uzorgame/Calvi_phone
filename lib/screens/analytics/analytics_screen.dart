import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/day.dart';
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
import '../../l10n/app_localizations.dart';

class Period {
  const Period({required this.days, required this.label});

  final int days;
  final String label;
}

List<Period> _periods(L l) => [
  Period(days: 7, label: l.anWeek),
  Period(days: 30, label: l.anMonth),
  Period(days: 90, label: l.anQuarter),
  Period(days: 365, label: l.anYear),
];

/// Показова крива ваги. Тільки для демо, і більше ніде.
const _demoWeights = [81.0, 80.6, 80.9, 79.8, 79.4, 78.9, 78.6];

/// Підписи показової кривої: сім місяців підряд, скороченнями мови застосунку.
List<String> get _demoLabels => [for (var m = 6; m <= 12; m++) monthShort(m)];

/// Крива ваги за записами, розкладена на сім точок вибраного періоду.
///
/// Не кожен день, а середнє по відрізку, бо графік заввишки сто тридцять
/// пікселів не покаже двісті точок нічим, крім шуму. Порожні відрізки просто
/// пропускаються, і лінія йде від запису до запису.
///
/// Раніше тут стояв сталий ряд із семи чисел, той самий у будь-якому режимі: на
/// екрані аналітики вага людини не мінялась ніколи, хай би скільки вона
/// зважувалась.
({List<double> values, List<String> labels}) weightCurve(Map<int, double> byDay, int days) {
  if (byDay.isEmpty) return (values: const [], labels: const []);

  const buckets = 7;

  /* Відрізок рахується з вибраного періоду, а не з півроку назавжди.
   *
   * Тут стояло сталих двадцять шість тижнів, і крива ваги показувала одне й те
   * саме, хоч тиждень вибери, хоч рік: перемикач угорі рухав усе на сторінці,
   * крім найпершої картки. Людина натискала «Тиждень» і бачила місяці. */
  final span = math.max(1, (days / buckets).ceil());

  final values = <double>[];
  final labels = <String>[];

  for (var i = buckets - 1; i >= 0; i--) {
    final to = -i * span;
    final from = to - span + 1;

    final inside = [
      for (final e in byDay.entries)
        if (e.key >= from && e.key <= to) e.value,
    ];
    if (inside.isEmpty) continue;

    values.add(inside.reduce((a, b) => a + b) / inside.length);
    labels.add(dayInfo(to).full.split(' ').last.substring(0, 3));
  }

  return (values: values, labels: labels);
}

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
    final l = L.of(context);
    final s = AppScope.of(context).s;
    final goal = goalOf(s);
    final periods = _periods(l);
    final days = periods[_period].days;

    /* Стрічка вимірювань іде за тим самим перемикачем, що й решта сторінки.
     *
     * Виняток один, і він названий уголос: тиждень. Сантиметром міряються раз на
     * місяць, і тиждень дав би одну точку або жодної, тобто картку, яка нічого
     * не каже. Для тижня береться три місяці, для всього іншого рівно те, що
     * вибрали. Раніше підлога стояла на трьох місяцях завжди, і «Місяць» нічого
     * не міняв. */
    final tapeDays = days < 30 ? 90 : days;
    final tapeLabel = switch (tapeDays) {
      >= 365 => l.anForYear,
      >= 90 => l.anForQuarter,
      _ => l.anForMonth,
    };

    /* Числа беруться з підсумків застосунку, а не з фікстур. У режимі «мої» це
       те, що людина справді записала; у демо це демонстраційний тиждень. Екран
       про різницю не знає і знати не має. */
    final stats = AppScope.of(context).stats;

    /* Columns and figures come from the same window: a headline counted over a
       month above a chart drawn over a week is two answers to one question. */
    final buckets = bucketDays(days);
    final dates = [for (final b in buckets) ...b.dates];
    /* Підсумки за відрізок беруться з тих самих даних, що й числа над ними.
     *
     * Тут стояв `totalsOf` із фікстур, і графік макросів малював демонстраційний
     * тиждень завжди: зверху чесні нулі, знизу різнокольорові стовпчики з чужого
     * життя. Найгірший різновид помилки, бо виглядає як робочий екран. */
    DayTotals totalsOver(Iterable<int> days) {
      var kcal = 0, protein = 0, fat = 0, carbs = 0;
      for (final d in days) {
        final t = stats.totalsOn(d);
        kcal += t.kcal;
        protein += t.protein;
        fat += t.fat;
        carbs += t.carbs;
      }
      return DayTotals(kcal: kcal, protein: protein, fat: fat, carbs: carbs);
    }

    final logged = dates.where((d) => stats.totalsOn(d).kcal > 0).length;
    final total = dates.fold<int>(0, (a, d) => a + stats.totalsOn(d).kcal);
    // Averaged over the days actually logged, not over the calendar: a week
    // opened on Friday is not a week of two hundred calories a day.
    final avg = (total / (logged == 0 ? 1 : logged)).round();
    final share = (avg / goal.kcal * 100).round();
    final ok = share >= 90 && share <= 110;

    // Те саме число, що на головному екрані, і тією ж формулою: два підрахунки
    // одного прогресу розійшлись би на першому ж кілограмі.
    final done = (goalProgress(s) * 100).round();

    final tracked = measureFields
        .where((f) => latestMeasure(widget.measures, f.key) != null)
        .toList();
    final field = tracked.isEmpty
        ? null
        : tracked.firstWhere((f) => f.key == _tape, orElse: () => tracked.first);

    return CalviScreen(
      title: l.anTitle,
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
            labels: [for (final p in periods) p.label],
            index: _period,
            onPick: (i) => setState(() => _period = i),
          ),
        ),

        _Block(
          title: l.anGoalProgress,
          badge: l.anDonePercent(done),
          child: Column(
            children: [
              // Гнучкі обидва числа: підписи під ними це слова, а слова довші
              // на вузькому телефоні й зі збільшеним шрифтом системи.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: _Figure(
                      value: s.weightKg.toStringAsFixed(1),
                      cap: l.anNowKg,
                      tight: true,
                    ),
                  ),
                  CalviIcon('trend', size: 20, color: c.textSecondary),
                  Flexible(
                    child: _Figure(
                      value: s.targetKg.toStringAsFixed(1),
                      cap: l.anTargetKg,
                      dim: true,
                      tight: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Builder(
                builder: (context) {
                  /* Демо малює показову криву, «мої» малюють свої зважування.
                     Той самий перемикач, що й на головній: він відповідає за
                     всю сторінку, а не за половину. */
                  final curve = stats.demo
                      ? (values: _demoWeights, labels: _demoLabels)
                      : weightCurve(stats.weights, days);

                  if (curve.values.length < 2) {
                    return _Note(l.anWeightEmpty);
                  }

                  return LineChart(
                    values: curve.values,
                    labels: curve.labels,
                    goal: s.targetKg,
                    highlight: curve.values.length - 1,
                    height: 132,
                  );
                },
              ),
              const SizedBox(height: 12),
              // The most valuable number on the page: it turns an abstract goal
              // into a date the person can picture.
              _Note(l.anEtaHead(targetDay(weeksToTarget(s)))),
            ],
          ),
        ),

        _Block(
          title: l.anKcal,
          badge: l.anShareOfNorm(share),
          warn: !ok,
          child: Column(
            children: [
              Row(
                children: [
                  _Figure(value: thousands(total), cap: l.anKcalTotal),
                  const SizedBox(width: 18),
                  Container(width: 1, height: 34, color: c.cardBorder),
                  const SizedBox(width: 18),
                  _Figure(value: thousands(avg), cap: l.anKcalAvg),
                ],
              ),
              const SizedBox(height: 16),
              if (total == 0)
                _Note(l.anKcalEmpty)
              else
                MacroBars(
                  rows: [
                    for (final b in buckets)
                      if (totalsOver(b.dates) case final t)
                        (label: b.label, protein: t.protein, fat: t.fat, carbs: t.carbs),
                  ],
                ),
            ],
          ),
        ),

        _Block(
          title: l.anWater,
          aside: l.anWaterGoal(thousands(goal.waterMl)),
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
                      _Figure(value: '$hit', suffix: '/${dates.length}', cap: l.anDaysInNorm),
                      const SizedBox(width: 18),
                      Container(width: 1, height: 34, color: c.cardBorder),
                      const SizedBox(width: 18),
                      _Figure(value: thousands(avgMl), cap: l.anWaterAvg),
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
          title: l.anMeasures,
          aside: l.anMeasuresChange(tapeLabel),
          child: field == null
              ? CalviNora(text: l.anMeasuresEmpty, hint: l.anMeasuresEmptyHint)
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
                          /* Дві дати, перша й остання, а не підпис під кожною
                             точкою.
                           *
                           * Тут не було жодної, і крива висіла в повітрі: видно,
                           * що щось змінилось, і незрозуміло, за який час. Але
                           * чотири заміри за рік це чотири дати, які не стають
                           * поруч, тому named саме кінці відрізка: між ними все
                           * інше читається само. */
                          labels: points.length < 2
                              ? const []
                              : [dayInfo(points.first.date).full, dayInfo(points.last.date).full],
                          unit: field.unit,
                        );
                      },
                    ),
                  ],
                ),
        ),

        _Block(
          title: l.anMacrosAvg,
          /* Підпис називає вибраний період, а не кількість записаних днів.
           *
           * «За 6 днів» стояло однаково при будь-якому виборі згори і читалось
           * як «цей блок живе своїм життям». Період тут той самий, що й у решти
           * сторінки; скільки з нього днів справді записано, сказано нижче. */
          aside: periods[_period].label.toLowerCase(),
          child: Builder(
            builder: (context) {
              /* Тут стояли числа 96, 71 і 268, вписані в код.
               *
               * Вони малювались завжди: на порожньому щоденнику теж, і поруч із
               * чесними нулями вище. Людина бачила заповнені смуги і вирішувала
               * по них, скільки їй ще їсти сьогодні. Тепер це середнє за ті дні,
               * коли справді щось записано, бо ділити на календар означало б
               * ділити тиждень, відкритий у пʼятницю, на сім. */
              final sum = totalsOver(dates);
              final over = logged == 0 ? 1 : logged;

              if (logged == 0) {
                return _Note(l.anMacrosEmpty);
              }

              /* І малювалось це шкалою до норми, що для середнього неправильно
                 по суті: смуга відповідає на питання «скільки лишилось», а воно
                 про сьогодні. Середнє за тиждень нікуди не лишається, воно
                 просто число, і стоїть тут як число. */
              final rows = [
                (
                  label: l.macroProtein,
                  avg: sum.protein / over,
                  goal: goal.protein,
                  colour: c.protein,
                ),
                (label: l.macroFat, avg: sum.fat / over, goal: goal.fat, colour: c.fats),
                (label: l.macroCarbs, avg: sum.carbs / over, goal: goal.carbs, colour: c.carbs),
              ];

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final r in rows)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(color: r.colour, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  r.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.t.labelSmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              text: '${r.avg.round()}',
                              children: [
                                TextSpan(
                                  text: ' ${l.unitG}',
                                  style: context.t.labelSmall?.copyWith(color: c.textSecondary),
                                ),
                              ],
                            ),
                            style: context.t.titleLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l.anPerDay,
                            style: context.t.labelSmall?.copyWith(color: c.textSecondary),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            l.anMacroGoal(r.goal),
                            style: context.t.labelSmall?.copyWith(
                              color: c.textSecondary.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
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
              boxShadow: context.shadowCard,
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
          color: chipInk(context, warn ? context.c.carbs : context.c.success),
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
              Text(L.of(context).anNow, style: context.t.labelSmall),
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
            d == null ? L.of(context).anOneReading : '${d > 0 ? '+' : ''}${_trim(d)} ${field.unit}',
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

  /* Висновок це не примітка під рискою, а тихий блок: сіра подушка каже «це
     сказав застосунок», і око знаходить його одразу після графіка. */
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 14),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: context.c.fillSecondary,
      borderRadius: BorderRadius.circular(CalviSize.rCard),
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
            style: i.isOdd ? TextStyle(color: context.c.text, fontWeight: FontWeight.w600) : null,
          ),
      ],
    );
  }
}

String _trim(double v) {
  final s = v.toStringAsFixed(1);
  return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
}
