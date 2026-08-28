import 'dart:math' as math;

import 'package:flutter/material.dart';

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
            builder: (context, box) => AnimatedBuilder(
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
                          highlight: widget.highlight,
                          progress: drawn,
                          ink: c.button,
                          grid: c.cardBorder,
                          success: c.success,
                          page: c.card,
                        ),
                      ),
                    ),

                    /* The goal reads as a number, not as a dashed line somebody
                       has to decode. It sits just above its own line so it never
                       lands on the month labels under the plot. */
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

                    /* The callout arrives after the line reaches it, never with
                       it: a label sitting on a point the line has not drawn yet
                       says the chart was finished before it was. */
                    if (widget.highlight != null)
                      _Callout(
                        at: _pointAt(widget.highlight!, box.biggest),
                        value:
                            '${widget.values[widget.highlight!]} '
                            '${widget.unit ?? L.of(context).unitKg}',
                        note: widget.highlightNote,
                        shown: drawn > 0.98,
                      ),
                  ],
                );
              },
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
    required this.progress,
    required this.ink,
    required this.grid,
    required this.success,
    required this.page,
  });

  final List<double> values;
  final double? goal;
  final int? highlight;
  final double progress;
  final Color ink;
  final Color grid;
  final Color success;
  final Color page;

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
class MacroBars extends StatefulWidget {
  const MacroBars({super.key, required this.rows});

  /// Kilocalories from each macro, per column, oldest first.
  final List<({String label, int protein, int fat, int carbs})> rows;

  @override
  State<MacroBars> createState() => _MacroBarsState();
}

class _MacroBarsState extends State<MacroBars> with SingleTickerProviderStateMixin {
  /* One controller for the whole row; each bar takes its own slice of it, so a
     column arrives a beat after the one to its left instead of the row snapping
     into place as a block. */
  late final AnimationController _grow;

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
    }
  }

  @override
  void dispose() {
    _grow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);
    final rows = widget.rows;
    final totals = [for (final r in rows) r.protein * 4 + r.carbs * 4 + r.fat * 9];
    final max = totals.fold<int>(1, math.max);

    return Column(
      children: [
        SizedBox(
          height: 118,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
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
                        parts: [
                          (r.fat * 9, c.fats),
                          (r.carbs * 4, c.carbs),
                          (r.protein * 4, c.protein),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
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
    );
  }
}

class _Stack extends StatelessWidget {
  const _Stack({
    required this.grow,
    required this.rank,
    required this.count,
    required this.fraction,
    required this.parts,
  });

  final Animation<double> grow;
  final int rank;
  final int count;
  final double fraction;
  final List<(int, Color)> parts;

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
    return FractionallySizedBox(
      heightFactor: (fraction * at).clamp(0.0, 1.0),
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Column(
          /* Stretch, not the default centre. A childless ColoredBox takes the
             smallest size its constraints allow, and a centring Column hands
             out loose width, so every segment collapsed to a zero-width sliver
             that laid out correctly and painted nothing. */
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (weight, colour) in parts)
              if (weight > 0)
                Expanded(
                  flex: weight,
                  child: ColoredBox(color: colour),
                ),
          ],
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
                    Text(
                      thousands(widget.goalMl),
                      style: context.t.labelSmall?.copyWith(fontSize: 10),
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
  const _Callout({required this.at, required this.value, required this.note, required this.shown});

  final Offset at;
  final String value;
  final String? note;
  final bool shown;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Positioned(
      // Above the point and centred on it, with a nudge off the top edge so the
      // pill never sits on the reading it is describing.
      left: at.dx - 46,
      top: at.dy - 52,
      width: 92,
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
