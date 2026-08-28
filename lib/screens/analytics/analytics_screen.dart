import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/day.dart';
import '../../data/fixtures.dart';
import '../../data/measure.dart';
import '../../data/settings.dart';
import '../../data/app_scope.dart';
import '../../design/icons.dart';
import '../../design/macro_row.dart';
import '../../design/section.dart';
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

        CalviStat(
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
                    child: CalviFigure(
                      value: s.weightKg.toStringAsFixed(1),
                      cap: l.anNowKg,
                      tight: true,
                    ),
                  ),
                  /* Знак каже напрямок, колір каже вердикт. Сірий означає, що
                     вердикту ще немає: ціль щойно поставлена, і руху не було. */
                  Builder(
                    builder: (context) {
                      final t = goalTrend(s);
                      return CalviIcon(
                        t.icon,
                        /* Більший за звичайні значки цього екрана, і навмисно:
                           це не оздоба між двома числами, а відповідь на
                           питання «воно працює?». На двадцяти пікселях між
                           двома тридцятками він читався як розділовий знак. */
                        size: 28,
                        color: switch (t.good) {
                          true => c.success,
                          false => c.protein,
                          null => c.textSecondary,
                        },
                      );
                    },
                  ),
                  Flexible(
                    child: CalviFigure(
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

        CalviStat(
          title: l.anKcal,
          badge: l.anShareOfNorm(share),
          warn: !ok,
          child: Column(
            children: [
              Row(
                children: [
                  CalviFigure(value: thousands(total), cap: l.anKcalTotal),
                  const SizedBox(width: 18),
                  Container(width: 1, height: 34, color: c.cardBorder),
                  const SizedBox(width: 18),
                  CalviFigure(value: thousands(avg), cap: l.anKcalAvg),
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

        CalviStat(
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
                      CalviFigure(value: '$hit', suffix: '/${dates.length}', cap: l.anDaysInNorm),
                      const SizedBox(width: 18),
                      Container(width: 1, height: 34, color: c.cardBorder),
                      const SizedBox(width: 18),
                      CalviFigure(value: thousands(avgMl), cap: l.anWaterAvg),
                    ],
                  ),
                  const SizedBox(height: 16),
                  HydrationBars(rows: water, goalMl: goal.waterMl),
                ],
              );
            },
          ),
        ),

        CalviStat(
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

        CalviStat(
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
              /* Та сама мова, що в карток БЖВ на дні і на сторінці тижня:
                 число з нормою через риску, кільце зі знаком, підпис капсом.
                 Тут стояли три колонки з крапками і чотирма рядками тексту під
                 кожною: своя розкладка на третьому екрані поспіль для тих
                 самих трьох величин. Кільце заразом показує те, чого чотири
                 рядки не показували жодним чином, а саме наскільки середнє
                 добирає до норми. */
              return MacroRow(
                cells: [
                  (
                    label: l.macroProteinCaps,
                    icon: 'protein',
                    value: sum.protein / over,
                    goal: goal.protein,
                    colour: c.protein,
                  ),
                  (
                    label: l.macroFatCaps,
                    icon: 'fat',
                    value: sum.fat / over,
                    goal: goal.fat,
                    colour: c.fats,
                  ),
                  (
                    label: l.macroCarbsCaps,
                    icon: 'carbs',
                    value: sum.carbs / over,
                    goal: goal.carbs,
                    colour: c.carbs,
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
