import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../format.dart';
import '../../l10n/app_localizations.dart';

/// A run of readings drawn as one smooth line.
///
/// Catmull-Rom through the points rather than a polyline: a straight run of
/// segments reads as a stock ticker, and a body does not move like that.
///
/// The scale comes from the data, not from the goal. Pulling a far target into
/// range would squash months of real movement into the top third of the box, so
/// the goal keeps its own dashed line pinned to the floor of the plot.
class LineChart extends StatefulWidget {
  const LineChart({
    super.key,
    required this.values,
    required this.labels,
    this.goal,
    this.highlight,
    this.highlightNote,
    this.dates,
    this.unit,
    this.height = 150,
    this.draw = const Duration(milliseconds: 900),
  });

  final List<double> values;
  final List<String> labels;

  /// Drawn as a dashed line along the floor, if there is one.
  final double? goal;

  /// Which point carries the callout.
  final int? highlight;

  /// The line under the figure in that callout, usually a date.
  final String? highlightNote;

  /// Дата кожної точки, для числа під пальцем.
  ///
  /// Крива каже «щось рухається», але не каже, скільки саме було у вівторок.
  /// Підпис під кожною точкою перетворив би графік на таблицю, тому число
  /// приходить на дотик, і разом із ним день, до якого воно належить. Порожньо
  /// означає, що графік не знає своїх дат: тоді під пальцем буде саме число.
  final List<String>? dates;

  /// Одиниця під виділеною точкою. Порожньо означає кілограми: так стоїть
  /// майже скрізь, а слово для них знає лише екран.
  final String? unit;
  final double height;

  /// How long the line takes to draw itself. The tape redraws faster than the
  /// weight chart because it redraws on every chip, not once on arrival.
  final Duration draw;

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> with SingleTickerProviderStateMixin {
  /* Створюється в initState, а не лінивим полем: ліниве народжується при
     першому зверненні, а ним може виявитись сам dispose. Віджет, який створили
     і прибрали, не намалювавши, тоді заводить тікер на вже відчепленому
     елементі і падає на пошуку предка. Довгий список, який ховає нижні картки,
     робить це буденною ситуацією, а не крайнім випадком. */
  late final AnimationController _c;

  /// Точка під пальцем. Порожньо означає, що криву ще не питали.
  int? _at;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      // The line draws itself once. Long enough to follow, short enough that a
      // second look at the screen never catches it mid-stroke.
      duration: widget.draw,
    )..forward();
  }

  @override
  void didUpdateWidget(LineChart old) {
    super.didUpdateWidget(old);
    // Інші дані означають іншу криву: тримати на ній стару точку нема сенсу.
    if (old.values.length != widget.values.length) _at = null;
  }

  /// Яка точка стоїть під цим дотиком.
  void _pick(double dx, double width) {
    const padX = 5.0;
    final span = width - padX * 2;
    if (span <= 0) return;
    final share = (dx - padX) / span;
    final i = (share * (widget.values.length - 1)).round().clamp(0, widget.values.length - 1);
    if (i == _at) return;
    // Відгук на кожну нову точку, а не на кожен піксель руху.
    HapticFeedback.selectionClick();
    setState(() => _at = i);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Where a point sits, in the same arithmetic the painter uses.
  Offset _pointAt(int i, Size size) {
    const padT = 14.0;
    const padB = 8.0;
    const padX = 5.0;
    final lo = widget.values.reduce(math.min);
    final hi = widget.values.reduce(math.max);
    final pad = math.max((hi - lo) * 0.35, hi == lo ? 1.0 : 0.4);
    final min = lo - pad;
    final max = hi + pad;
    return Offset(
      padX + i / (widget.values.length - 1) * (size.width - padX * 2),
      padT + (1 - (widget.values[i] - min) / (max - min)) * (size.height - padT - padB),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    if (widget.values.length < 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 22),
        child: Text(
          L.of(context).anOneWeighing,
          textAlign: TextAlign.center,
          style: context.t.bodyMedium,
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, box) => TapRegion(
              /* Вибір гасне від дотику будь-де поза графіком, як і вибрана
                 колонка калорій: одна мова на весь екран. */
              onTapOutside: _at == null ? null : (_) => setState(() => _at = null),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                /* Дотик і ковзання по горизонталі беруться графіком, усе
                   інше лишається сторінці: вертикальний рух мусить гортати
                   екран, а не водити по кривій. */
                onTapDown: (d) => _pick(d.localPosition.dx, box.maxWidth),
                onHorizontalDragStart: (d) => _pick(d.localPosition.dx, box.maxWidth),
                onHorizontalDragUpdate: (d) => _pick(d.localPosition.dx, box.maxWidth),
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) {
                    final drawn = CalviMotion.ease.transform(_c.value);
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _LinePainter(
                              values: widget.values,
                              goal: widget.goal,
                              highlight: _at ?? widget.highlight,
                              scrub: _at,
                              progress: drawn,
                              ink: c.button,
                              grid: c.cardBorder,
                              success: c.success,
                              page: c.card,
                              hairline: c.hairline,
                            ),
                          ),
                        ),

                        /* The goal reads as a number, not as a dashed line
                           somebody has to decode. It sits just above its own
                           line so it never lands on the month labels under the
                           plot. */
                        if (widget.goal != null)
                          Positioned(
                            right: 0,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: Color.alphaBlend(c.success.withValues(alpha: 0.15), c.card),
                                borderRadius: BorderRadius.circular(CalviSize.rPill),
                              ),
                              child: Text(
                                L.of(context).anChartGoal(_trimGoal(widget.goal!)),
                                style: context.t.labelSmall?.copyWith(
                                  fontSize: 10,
                                  color: chipInk(context, c.success),
                                ),
                              ),
                            ),
                          ),

                        /* Число точки: під пальцем, коли криву питають, або на
                           заздалегідь названій точці. Приходить після того, як
                           лінія до неї дійшла: підпис на ще не намальованій
                           точці каже, що графік закінчився раніше, ніж почався. */
                        if ((_at ?? widget.highlight) case final i?)
                          _Callout(
                            at: _pointAt(i, box.biggest),
                            width: box.maxWidth,
                            /* Один знак після коми, і це не косметика: точка
                               кривої часто є середнім кількох зважувань, а
                               середнє двох чесних чисел дає 78.97500000000001.
                               Людина бачила цей хвіст замість своєї ваги. */
                            value:
                                '${widget.values[i].toStringAsFixed(1)} '
                                '${widget.unit ?? L.of(context).unitKg}',
                            note: _at != null && widget.dates != null && i < widget.dates!.length
                                ? widget.dates![i]
                                : widget.highlightNote,
                            shown: drawn > 0.98,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        if (widget.labels.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              // Every label takes an equal share and clips: a long one used to
              // push the row past the card and paint a stripe over the chart.
              for (final (i, l) in widget.labels.indexed)
                Expanded(
                  child: Text(
                    l,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    textAlign: i == 0
                        ? TextAlign.left
                        : i == widget.labels.length - 1
                        ? TextAlign.right
                        : TextAlign.center,
                    style: context.t.labelSmall?.copyWith(fontSize: 11),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// «74» rather than «74.0»: the goal is a round number in every sentence but this.
String _trimGoal(double v) {
  final s = v.toStringAsFixed(1);
  return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.values,
    required this.goal,
    required this.highlight,
    required this.scrub,
    required this.progress,
    required this.ink,
    required this.grid,
    required this.success,
    required this.page,
    required this.hairline,
  });

  final List<double> values;
  final double? goal;
  final int? highlight;

  /// Точка під пальцем: до неї малюється волосінь через увесь графік.
  final int? scrub;

  final double progress;
  final Color ink;
  final Color grid;
  final Color success;
  final Color page;
  final Color hairline;

  @override
  void paint(Canvas canvas, Size size) {
    const padT = 14.0;
    const padB = 8.0;
    const padX = 5.0;

    final lo = values.reduce(math.min);
    final hi = values.reduce(math.max);
    /* Padded so a flat run does not draw a line glued to the frame, and so a
       single loud reading does not squash the rest into the baseline. */
    final pad = math.max((hi - lo) * 0.35, hi == lo ? 1.0 : 0.4);
    final min = lo - pad;
    final max = hi + pad;

    double x(int i) => padX + i / (values.length - 1) * (size.width - padX * 2);
    double y(double v) => padT + (1 - (v - min) / (max - min)) * (size.height - padT - padB);

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (final v in [max, (max + min) / 2, min]) {
      canvas.drawLine(Offset(0, y(v)), Offset(size.width, y(v)), gridPaint);
    }

    if (goal != null) {
      // Dashed, along the floor: it is a destination, not a reading.
      final floor = size.height - padB;
      final dash = Paint()
        ..color = success
        ..strokeWidth = 1;
      for (var dx = 0.0; dx < size.width; dx += 8) {
        canvas.drawLine(Offset(dx, floor), Offset(math.min(dx + 4, size.width), floor), dash);
      }
    }

    final pts = [for (var i = 0; i < values.length; i++) Offset(x(i), y(values[i]))];
    final path = _smooth(pts);

    // The area under the line, so the plot has weight without a second colour.
    final area = Path.from(path)
      ..lineTo(size.width, size.height - padB)
      ..lineTo(0, size.height - padB)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ink.withValues(alpha: 0.14), ink.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );

    // Drawn as a fraction of its own length, so any series animates the same.
    final metrics = path.computeMetrics().toList();
    final drawn = Path();
    for (final m in metrics) {
      drawn.addPath(m.extractPath(0, m.length * progress), Offset.zero);
    }
    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..color = ink,
    );

    /* Волосінь від верху до низу: вона каже, яку саме точку тримає палець, поки
       сама точка під ним і її не видно. */
    if (scrub != null) {
      final at = pts[scrub!.clamp(0, pts.length - 1)].dx;
      canvas.drawLine(
        Offset(at, 0),
        Offset(at, size.height - padB),
        Paint()
          ..color = hairline
          ..strokeWidth = 1,
      );
    }

    if (highlight != null && progress > 0.98) {
      final p = pts[highlight!.clamp(0, pts.length - 1)];
      canvas.drawCircle(p, 4, Paint()..color = page);
      canvas.drawCircle(
        p,
        4,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = ink,
      );
    }
  }

  Path _smooth(List<Offset> pts) {
    final p = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = i == 0 ? pts[i] : pts[i - 1];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i + 2 < pts.length ? pts[i + 2] : p2;
      p.cubicTo(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
        p2.dx,
        p2.dy,
      );
    }
    return p;
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.progress != progress || old.values != values;
}

/// Stacked bars: each day split by where its calories actually came from.
///
/// A single grey bar answers «how much»; this answers «of what», which is the
/// question a plateau usually turns out to be about.
///
/// **Один банер на дві сторінки.** Той самий графік стоїть на аналітиці і на
/// сторінці тижня: питання там одне, і два різні малюнки для нього були б двома
/// мовами.
///
/// Числа зʼявляються на дотик, а не стоять завжди: сім колонок по чотири цифри
/// це таблиця, а не графік. Перший дотик вибирає колонку і каже її калорії,
/// другий дотик по складнику каже калорії складника, той самий складник ще раз
/// повертає день, а дотик будь-де поза колонками знімає вибір.
class MacroBars extends StatefulWidget {
  const MacroBars({super.key, required this.rows, required this.norm, this.span = 1});

  /// Grams of each macro, per column, oldest first.
  final List<({String label, int protein, int fat, int carbs})> rows;

  /// Денна норма калорій.
  final int norm;

  /// Скільки днів стоїть в одній колонці.
  ///
  /// На тижні це один день, у місяці й році колонка збирає кілька, і тоді разом
  /// із нею множиться все: і норма, і повітря над нею. Інакше на річному
  /// графіку лінія норми виїжджає під саму стелю і зникає з очей.
  final int span;

  @override
  State<MacroBars> createState() => _MacroBarsState();
}

/// Котрий складник питають: білок, жири чи вуглеводи.
enum _Macro { protein, fat, carbs }

class _MacroBarsState extends State<MacroBars> with SingleTickerProviderStateMixin {
  /* Висота графіка і те, як вона тримається на різних даних.
   *
   * Над нормою завжди стоїть повітря на пʼятсот калорій: лінія норми має жити
   * всередині графіка, а не на його стелі, інакше день, який ледь перебрав,
   * малюється врівень із нормою і перебору не видно.
   *
   * День, який вийшов і за це повітря, не стискає графік, а розтягує його:
   * висота росте разом зі стелею, тому ціна пікселя в калоріях лишається та
   * сама, і лінія норми стоїть там само, де стояла. Так стовпчики не
   * перетворюються на смужки в тиждень, коли одна вечеря вибилась із ряду.
   *
   * Зростання не безмежне: після [_tallest] графік перестає рости і стовпчики
   * починають меншати. Інакше один день на десять тисяч калорій виштовхнув би
   * решту сторінки за екран. */
  static const _height = 130.0;
  static const _tallest = 200.0;
  static const _air = 500;

  /* One controller for the whole row; each bar takes its own slice of it, so a
     column arrives a beat after the one to its left instead of the row snapping
     into place as a block. */
  late final AnimationController _grow;

  /// Вибрана колонка і вибраний у ній складник. Порожньо означає, що не питали.
  int? _pick;
  _Macro? _part;

  @override
  void initState() {
    super.initState();
    _grow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520 + 55 * 6),
    )..forward();
  }

  @override
  void didUpdateWidget(MacroBars old) {
    super.didUpdateWidget(old);
    // A new period is a new chart, and it earns the growth again.
    if (old.rows.length != widget.rows.length || old.rows.first.label != widget.rows.first.label) {
      _grow.forward(from: 0);
      _clear();
    }
  }

  @override
  void dispose() {
    _grow.dispose();
    super.dispose();
  }

  void _clear() {
    _pick = null;
    _part = null;
  }

  void _tap(int column, _Macro part) {
    setState(() {
      /* Дотик завжди влучає в якийсь складник, тому «вибрати колонку» означає
         «перший дотик по невибраній»: складник питається лише другим. */
      if (_pick != column) {
        _pick = column;
        _part = null;
        return;
      }
      _part = _part == part ? null : part;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);
    final rows = widget.rows;
    final totals = [for (final r in rows) r.protein * 4 + r.carbs * 4 + r.fat * 9];

    /* Стеля графіка це норма плюс повітря, а коли день вибився і за нього, то
       сам той день із дещицею запасу над ним. Обидва числа рахуються на цілу
       колонку: пʼять днів в одній колонці означають і пʼятикратну норму, і
       пʼятикратне повітря. */
    final span = math.max(widget.span, 1);
    final norm = math.max(widget.norm * span, 1);
    final air = norm + _air * span;
    final tallest = totals.fold<int>(0, math.max);
    final max = tallest <= air ? air.toDouble() : tallest * 1.06;

    /* Висота росте рівно настільки, наскільки стеля вийшла за повітря над
       нормою: доти ціна пікселя в калоріях стала, і лінія норми не рухається
       з місця, хай яким видався тиждень. */
    final height = (_height * (max / air)).clamp(_height, _tallest);

    /* Число, яке спитали дотиком: калорії дня або одного складника. Малюється
       не в колонці, а тут, поверх усього графіка, і саме тому не ріжеться: у
       колонці йому дозволена була б лише її ширина, і «2 510» ставало «2 51».
       На довгих періодах числа ще довші, і в тонку смугу не влізли б ніяк. */
    final r = _pick == null ? null : rows[_pick!];
    final tip = r == null
        ? null
        : switch (_part) {
            _Macro.protein => r.protein * 4,
            _Macro.fat => r.fat * 9,
            _Macro.carbs => r.carbs * 4,
            null => totals[_pick!],
          };

    return TapRegion(
      /* Вибір гасне від дотику будь-де поза колонками: в цій картці, під нею,
         на іншому кінці екрана. Дотики по самих колонках сюди не долітають. */
      onTapOutside: _pick == null ? null : (_) => setState(_clear),
      child: Column(
        children: [
          /* Повітря над графіком: там стає число, яке спитали дотиком, і без
             цього відступу воно налазило б на підпис картки. */
          const SizedBox(height: 14),
          SizedBox(
            height: height,
            child: LayoutBuilder(
              builder: (context, box) {
                // Ширина однієї колонки: за нею стає число над вибраною.
                final cell = box.maxWidth / rows.length;

                return Stack(
                  // Пігулка числа виходить за межі колонки і має право на це.
                  clipBehavior: Clip.none,
                  children: [
                /* На всю висоту, а не самим рядом стовпчиків.
                 *
                 * Ряд, покладений у стопку звичайною дитиною, отримує вільні
                 * обмеження, і FractionallySizedBox у вільних обмеженнях
                 * стискається до самої смуги. Ряд ставав заввишки з найвищий
                 * стовпчик, спливав до верху стопки, а під ним лишалась
                 * порожнеча в піврядка: дні тижня від'їжджали вниз, і лінія
                 * норми, відлічена від низу стопки, опинялась усередині
                 * стовпчиків. Тому висота тут задається силою. */
                Positioned.fill(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (i, r) in rows.indexed)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: AnimatedBuilder(
                              animation: _grow,
                              builder: (context, _) => _Stack(
                                grow: _grow,
                                rank: i,
                                count: rows.length,
                                fraction: totals[i] / max,
                                total: totals[i],
                                parts: [
                                  (_Macro.carbs, r.carbs * 4, c.carbs),
                                  (_Macro.fat, r.fat * 9, c.fats),
                                  (_Macro.protein, r.protein * 4, c.protein),
                                ],
                                picked: _pick == i,
                                dimmed: _pick != null && _pick != i,
                                part: _pick == i ? _part : null,
                                onTap: (part) => _tap(i, part),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                /* Лінія норми поперек стовпчиків, із самим числом норми при ній:
                   скільки саме, а не лише де. Норма живе в налаштуваннях і
                   міняється разом із ціллю, тому і висота, і число рахуються з
                   неї щоразу. */
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: height * (norm / max),
                  /* Наскрізна для дотиків. Заливка кольором ловить дотики, і
                     риска в один піксель забирала собі цілу смугу впоперек
                     графіка: дотик по стовпчику саме там мовчав, і причини
                     цього не видно нікому. */
                  child: IgnorePointer(
                    child: Row(
                      children: [
                        Expanded(child: Container(height: 1, color: c.hairline)),
                        const SizedBox(width: 6),
                        /* Підкладка кольору картки: риска йде поверх стовпчиків,
                           і без неї число лягало просто на останній із них. */
                        ColoredBox(
                          color: c.card,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Text(
                              // Норма цілої колонки, та сама, за якою стоїть риска.
                              thousands(norm),
                              style: context.t.labelSmall?.copyWith(fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /* Число над колонкою, поверх усього іншого. Три ширини колонки
                   під нього, вирівняне серединою: довге число виходить за свою
                   колонку в обидва боки, і саме тому воно живе тут, а не в
                   ній. */
                if (tip != null && totals[_pick!] > 0)
                  Positioned(
                    bottom: height * (totals[_pick!] / max) * 1.1 + 9,
                    left: cell * (_pick! - 1),
                    width: cell * 3,
                    child: IgnorePointer(child: Center(child: _Tip(kcal: tip))),
                  ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final r in rows)
                Expanded(
                  child: Text(
                    r.label,
                    textAlign: TextAlign.center,
                    style: context.t.labelSmall?.copyWith(fontSize: 11),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          /* Переноситься, а не вилазить. Три підписи стояли рядом, який не вмів
             стати вужчим: на збільшеному системному шрифті «Вуглеводи» виїжджало
             за картку смугастим попереджувачем. Тепер третій просто переходить на
             наступний рядок, і легенда лишається легендою. */
          Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 6,
            children: [
              _Key(label: l.macroProtein, colour: c.protein),
              _Key(label: l.macroFat, colour: c.fats),
              _Key(label: l.macroCarbs, colour: c.carbs),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stack extends StatelessWidget {
  const _Stack({
    required this.grow,
    required this.rank,
    required this.count,
    required this.fraction,
    required this.total,
    required this.parts,
    required this.picked,
    required this.dimmed,
    required this.part,
    required this.onTap,
  });

  final Animation<double> grow;
  final int rank;
  final int count;
  final double fraction;

  /// Калорії всієї колонки, для підказки.
  final int total;

  final List<(_Macro, int, Color)> parts;

  /// Ця колонка вибрана.
  final bool picked;

  /// Вибрана інша: ця відходить на задній план.
  final bool dimmed;

  /// Вибраний складник цієї колонки, якщо питали саме його.
  final _Macro? part;

  final ValueChanged<_Macro> onTap;

  @override
  Widget build(BuildContext context) {
    if (fraction <= 0) return const SizedBox.expand();
    // Half the run is the stagger, half is one bar's own growth.
    final step = 0.5 / count;
    final at = Interval(
      step * rank,
      step * rank + 0.5,
      curve: CalviMotion.ease,
    ).transform(grow.value);

    final shown = [
      for (final (macro, kcal, colour) in parts)
        if (kcal > 0) (macro, kcal, colour),
    ];

    /* Найменша смужка, яку ще видно і в яку ще можна поцілити пальцем: день на
       двісті калорій це запис, а не порожнє місце. */
    final grown = math.max((fraction * at).clamp(0.0, 1.0), 0.03 * at);

    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        widthFactor: 1,
        heightFactor: grown,
        alignment: Alignment.bottomCenter,
        child: AnimatedOpacity(
          opacity: dimmed ? 0.55 : 1,
          duration: CalviMotion.normal,
          curve: CalviMotion.ease,
          /* Колонка росте цілою і лишається суцільною: силует і заокруглення ті
             самі, що в спокої. Вибраний складник кажуть не висуванням, яке
             ламало б силует, а тим, що решта всередині пригасає. */
          child: AnimatedScale(
            scale: picked ? 1.1 : 1,
            alignment: Alignment.bottomCenter,
            duration: CalviMotion.normal,
            curve: CalviMotion.ease,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Column(
                /* Stretch, not the default centre. A childless ColoredBox takes
                   the smallest size its constraints allow, and a centring Column
                   hands out loose width, so every segment collapsed to a
                   zero-width sliver that laid out correctly and painted
                   nothing. */
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (macro, kcal, colour) in shown)
                    Expanded(
                      flex: kcal,
                      child: GestureDetector(
                        onTap: () => onTap(macro),
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedOpacity(
                          opacity: part == null || part == macro ? 1 : 0.45,
                          duration: CalviMotion.normal,
                          curve: CalviMotion.ease,
                          child: ColoredBox(color: colour),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Число калорій на дотик: чорнильна пігулка поверх стовпчика.
class _Tip extends StatelessWidget {
  const _Tip({required this.kcal});

  final int kcal;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.button,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          thousands(kcal),
          maxLines: 1,
          style: context.t.labelSmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: c.buttonText,
          ),
        ),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.colour});

  final String label;
  final Color colour;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: colour),
        ),
        const SizedBox(width: 5),
        Text(label, style: context.t.labelSmall?.copyWith(fontSize: 11)),
      ],
    ),
  );
}

/// Water over the week.
///
/// Bars against the target line, because the only question worth asking of water
/// is how often you got there, not what the average came to. An average of 2200
/// made of one 4000 day and six dry ones is not hydration.
/// Скільки випито за кожен відрізок, стовпчиками знизу догори.
///
/// Тут стояли сірі прямокутники, які фарбувались у колір тільки в день, коли
/// норму перекрито. День на півтора літра виглядав так само, як день, коли не
/// пито взагалі: обидва сірі, різні лише висотою. Тепер вода завжди синя, а її
/// висота і є відповідь; за нею стоїть доріжка на всю висоту, щоб порожній день
/// читався як порожній слот, а не як відсутній стовпчик.
class HydrationBars extends StatefulWidget {
  const HydrationBars({super.key, required this.rows, required this.goalMl});

  final List<({String label, int ml})> rows;
  final int goalMl;

  @override
  State<HydrationBars> createState() => _HydrationBarsState();
}

class _HydrationBarsState extends State<HydrationBars> with SingleTickerProviderStateMixin {
  static const _height = 112.0;

  /* Створюється в initState, а не лінивим полем.
   *
   * Ліниве поле народжується при першому зверненні, а першим зверненням може
   * виявитись сам dispose: якщо віджет побудували і прибрали, не намалювавши,
   * контролер створює тікер уже на відчепленому елементі, і застосунок падає на
   * пошуку предка. */
  late final AnimationController _rise;

  @override
  void initState() {
    super.initState();
    _rise = AnimationController(vsync: this, duration: const Duration(milliseconds: 620))
      ..forward();
  }

  @override
  void dispose() {
    _rise.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    /* Headroom above whichever is taller, the target or the best day. Without it
       a week where nobody cleared the target pins the line to the ceiling and
       its label climbs out of the chart. */
    final top = widget.rows.fold<int>(widget.goalMl, (a, r) => math.max(a, r.ml));
    final max = top * 1.18;

    return Column(
      children: [
        SizedBox(
          height: _height,
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final r in widget.rows)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        /* Тільки вода, без сірої доріжки під нею.
                         *
                         * Доріжка тут була, щоб порожній день лишав місце в
                         * ряду, і вона мала сенс, поки стовпчики були сірі й
                         * ледь помітні. Тепер вода синя і видна сама, а сім
                         * сірих прямокутників поруч із нею читаються як
                         * заповнені стовпчики, тобто як дані, яких немає.
                         * Порожньо має виглядати порожньо. */
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            // Тримає ширину стовпчика, поки води ще немає.
                            const SizedBox.expand(),
                            AnimatedBuilder(
                              animation: _rise,
                              builder: (context, _) {
                                /* Стовпчик росте знизу вгору, як наливається
                                   склянка. Курва сповільнення на кінці: вода
                                   не зупиняється різко. */
                                final grown = Curves.easeOutCubic.transform(_rise.value);
                                final full = (r.ml / max).clamp(0.0, 1.0);

                                // Наскільки день дотягнув до норми: від цього
                                // насиченість кольору.
                                final full01 = widget.goalMl == 0
                                    ? 1.0
                                    : (r.ml / widget.goalMl).clamp(0.0, 1.0);

                                /* Ширина задається явно, і це не косметика.
                                 *
                                 * Стовпчик без вмісту бере найменший розмір,
                                 * який дозволяють обмеження, а всередині стопки
                                 * ширина приходить вільною. Виходила смуга з
                                 * правильною висотою і нульовою шириною: на
                                 * екрані лишались самі доріжки, однакові й
                                 * порожні, і день на тисячу триста мілілітрів
                                 * виглядав так само, як день без жодної
                                 * склянки. Той самий дефект колись ховав
                                 * стовпчики БЖВ. */
                                return FractionallySizedBox(
                                  widthFactor: 1,
                                  heightFactor: full * grown,
                                  alignment: Alignment.bottomCenter,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      /* Один колір на всю воду, а насиченість
                                         росте разом із нею: що більше випито,
                                         то контрастніший стовпчик. Норма
                                         перекрита це повна сила кольору. Сірого,
                                         який читався як «немає даних», тут
                                         більше немає взагалі. */
                                      color: c.fats.withValues(alpha: 0.35 + 0.65 * full01),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              /* Target line across the bars: the point of the chart is which
                 days cleared it, and a legend cannot say that as fast. */
              Positioned(
                left: 0,
                right: 0,
                bottom: _height * (widget.goalMl / max),
                child: Row(
                  children: [
                    Expanded(child: Container(height: 1, color: c.hairline)),
                    const SizedBox(width: 6),
                    // Підкладка кольору картки: інакше число лягає на стовпчик.
                    ColoredBox(
                      color: c.card,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Text(
                          thousands(widget.goalMl),
                          style: context.t.labelSmall?.copyWith(fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final r in widget.rows)
              Expanded(
                child: Text(
                  r.label,
                  textAlign: TextAlign.center,
                  style: context.t.labelSmall?.copyWith(fontSize: 11),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// One macro against its norm, as a bar with the figures beside it.
class MacroLine extends StatelessWidget {
  const MacroLine({
    super.key,
    required this.label,
    required this.value,
    required this.goal,
    required this.colour,
  });

  final String label;
  final int value;
  final int goal;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(width: 78, child: Text(label, style: context.t.bodyMedium)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(CalviSize.rPill),
              child: SizedBox(
                height: 8,
                child: Stack(
                  children: [
                    Positioned.fill(child: ColoredBox(color: c.track)),
                    FractionallySizedBox(
                      widthFactor: goal > 0 ? (value / goal).clamp(0.0, 1.0) : 0,
                      heightFactor: 1,
                      child: ColoredBox(color: colour),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text.rich(
            TextSpan(
              text: '$value',
              children: [
                TextSpan(text: ' / $goal', style: context.t.labelSmall?.copyWith(fontSize: 12)),
              ],
            ),
            style: context.t.titleMedium?.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// The pill that names one reading on the line.
class _Callout extends StatelessWidget {
  const _Callout({
    required this.at,
    required this.width,
    required this.value,
    required this.note,
    required this.shown,
  });

  final Offset at;

  /// Ширина графіка: пігулка не має права виїхати за неї.
  final double width;

  final String value;
  final String? note;
  final bool shown;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    /* Пігулка вирівняна серединою по точці, тож на першій і останній половина
       її ширини лишалась би за межами картки. Число, обрізане краєм, гірше за
       число, зсунуте на сантиметр. */
    const half = 46.0;
    final left = (at.dx - half).clamp(0.0, math.max(0.0, width - half * 2)).toDouble();

    return Positioned(
      // Above the point and centred on it, with a nudge off the top edge so the
      // pill never sits on the reading it is describing.
      left: left,
      top: at.dy - 52,
      width: half * 2,
      child: AnimatedOpacity(
        opacity: shown ? 1 : 0,
        duration: const Duration(milliseconds: 340),
        curve: CalviMotion.ease,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(color: c.button, borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: context.t.titleMedium?.copyWith(
                      fontSize: CalviSize.fsMicro,
                      height: 1.2,
                      color: c.buttonText,
                    ),
                  ),
                  if (note != null)
                    Text(
                      note!,
                      style: context.t.labelSmall?.copyWith(
                        fontSize: 10,
                        height: 1.2,
                        fontWeight: FontWeight.w400,
                        color: c.buttonText.withValues(alpha: 0.62),
                      ),
                    ),
                ],
              ),
            ),
            // A little tail, so the pill reads as attached to its point.
            Transform.translate(
              offset: const Offset(0, -3),
              child: Transform.rotate(
                angle: math.pi / 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: c.button,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
