import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../data/meds.dart';
import '../../design/icons.dart';
import '../../design/ring.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../today/slot_card.dart';
import 'meds_form.dart';

/// Demo clock, same value the status bar shows.
const _now = '12:39';

/// Medication journal, laid out as the day itself.
///
/// A flat list answers «what do I take»; the question people actually open this
/// screen with is «what do I take next». So the doses sit on a rail running from
/// morning to night, the taken part of the rail is solid behind them, the rest
/// is dashed ahead, and the current hour cuts across it. Everything is the same
/// information a list would carry, arranged so the answer is the shape.
///
/// It records and reminds. It does not calculate doses, propose regimens or
/// comment on one: we are not doctors, and here a wrong number is not a wrong
/// number, it is harm.
class MedsScreen extends StatefulWidget {
  const MedsScreen({
    super.key,
    required this.meds,
    required this.onToggle,
    required this.onSave,
    required this.onDelete,
  });

  final List<Med> meds;
  final void Function(String medId, int index) onToggle;
  final ValueChanged<Med> onSave;
  final ValueChanged<String> onDelete;

  @override
  State<MedsScreen> createState() => _MedsScreenState();
}

class _MedsScreenState extends State<MedsScreen> {
  /// null: closed. 'new': adding. Otherwise the id being edited.
  String? _form;

  List<({String at, List<({Med med, int index})> items})> get _groups {
    final map = <String, List<({Med med, int index})>>{};
    for (final m in widget.meds) {
      for (final (i, t) in m.times.indexed) {
        map.putIfAbsent(t.at, () => []).add((med: m, index: i));
      }
    }
    final keys = map.keys.toList()..sort();
    return [for (final k in keys) (at: k, items: map[k]!)];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final meds = widget.meds;
    final total = medProgress(meds);
    final due = nextDue(meds);
    final groups = _groups;
    final nowAt = groups.indexWhere((g) => g.at.compareTo(_now) > 0);

    return CalviScreen(
      title: 'Препарати',
      children: [
        if (meds.isEmpty)
          const Padding(
            padding: EdgeInsets.fromLTRB(CalviSize.gutter, 4, CalviSize.gutter, 12),
            child: CalviNora(
              text: 'Тут порожньо. Додай препарат, і я нагадаю в потрібний час.',
              hint: 'Веду журнал прийомів, дозування не рахую',
            ),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 22),
            child: TweenAnimationBuilder<double>(
              // 17.2: it arrives once, from a little above, over 520 ms.
              tween: Tween(end: 1),
              duration: const Duration(milliseconds: 520),
              curve: CalviMotion.ease,
              builder: (context, t, child) => Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, -10 * (1 - t)),
                  child: Transform.scale(scale: 0.985 + 0.015 * t, child: child),
                ),
              ),
              child: Container(
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                decoration: BoxDecoration(
                  /* The one dark card of the day, in button ink on both themes:
                     the regimen summary is the headline, not another tile. */
                  color: c.button,
                  borderRadius: BorderRadius.circular(CalviSize.rLarge),
                ),
                child: Stack(
                  children: [
                    // Warm light off the corner the ring sits in.
                    /* Painted with a shader rather than boxed in a decoration:
                       the web renderer showed the box of a decorated gradient,
                       and a canvas circle has no box to show. */
                    Positioned.fill(
                      child: CustomPaint(painter: _Glow(colour: c.accent)),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  text: '${total.done}',
                                  children: [
                                    TextSpan(
                                      text: ' / ${total.total}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                        color: c.buttonText.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                                style: context.t.displayLarge?.copyWith(
                                  fontSize: 38,
                                  height: 1,
                                  color: c.buttonText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                due == null
                                    ? 'На сьогодні все прийнято'
                                    : 'Далі о ${due.at}, ${due.name}',
                                style: context.t.bodyMedium?.copyWith(
                                  color: c.buttonText.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        CalviRing(
                          progress: total.ratio,
                          size: 68,
                          stroke: 7,
                          color: total.ratio >= 1 ? c.success : c.accent,
                          // The track has to read on the dark card, so it is the
                          // card's own ink at low strength, not the page grey.
                          track: c.buttonText.withValues(alpha: 0.18),
                          child: CalviIcon(
                            total.ratio >= 1 ? 'check' : 'pill',
                            size: 22,
                            color: total.ratio >= 1 ? c.success : c.accent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          for (final (gi, g) in groups.indexed) ...[
            if (gi == nowAt) const _NowLine(),
            _Arrive(
              rank: gi,
              child: _RailRow(
                at: g.at,
                items: g.items,
                last: gi == groups.length - 1,
                passed: g.at.compareTo(_now) <= 0,
                onToggle: widget.onToggle,
              ),
            ),
          ],

          /* The rail answers what is next; this answers what is in the list at
             all, and it is the only place a name can be corrected or an entry
             dropped. */
          CalviSection(
            title: 'Мої препарати',
            children: [
              for (final (i, m) in meds.indexed)
                CalviRow(
                  icon: 'pill',
                  title: m.name,
                  first: i == 0,
                  value:
                      '${doseLabel(m.dose, m.form)} · ${m.times.map((t) => t.at).join(', ')}',
                  onTap: () => setState(() => _form = _form == m.id ? null : m.id),
                ),
            ],
          ),

          if (_form != null && _form != 'new')
            if (meds.where((m) => m.id == _form).firstOrNull case final med?) ...[
              MedsForm(
                key: ValueKey(med.id),
                med: med,
                now: DateTime.now().millisecondsSinceEpoch,
                onSave: widget.onSave,
                onDone: () => setState(() => _form = null),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _form = null);
                    widget.onDelete(med.id);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Видалити препарат',
                        style: context.t.titleMedium?.copyWith(fontSize: 14, color: c.protein),
                      ),
                    ),
                  ),
                ),
              ),
            ],
        ],

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CalviSize.gutter),
          child: AddRow(
            label: _form == 'new' ? 'Згорнути' : 'Додати препарат',
            open: _form == 'new',
            onTap: () => setState(() => _form = _form == 'new' ? null : 'new'),
          ),
        ),

        if (_form == 'new')
          MedsForm(
            now: DateTime.now().millisecondsSinceEpoch,
            onSave: widget.onSave,
            onDone: () => setState(() => _form = null),
          ),
      ],
    );
  }
}

/// Where the current hour cuts across the rail.
class _NowLine extends StatefulWidget {
  const _NowLine();

  @override
  State<_NowLine> createState() => _NowLineState();
}

class _NowLineState extends State<_NowLine> with SingleTickerProviderStateMixin {
  /* 16.25: a 2.4 second cycle. The marker is the only thing on the screen that
     moves on its own, which is what makes it read as the current hour rather
     than as another line. */
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) => Opacity(
        opacity: 0.65 + 0.35 * Curves.easeInOut.transform(_pulse.value),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 4, CalviSize.gutter, 4),
          child: Row(
            children: [
              Text(
                'зараз',
                style: context.t.labelSmall?.copyWith(fontSize: 11, color: c.accent),
              ),
              const SizedBox(width: 8),
              Expanded(child: Container(height: 1, color: c.accent.withValues(alpha: 0.4))),
              const SizedBox(width: 8),
              Text(_now, style: context.t.titleMedium?.copyWith(fontSize: 13, color: c.accent)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RailRow extends StatelessWidget {
  const _RailRow({
    required this.at,
    required this.items,
    required this.last,
    required this.passed,
    required this.onToggle,
  });

  final String at;
  final List<({Med med, int index})> items;
  final bool last;

  /// The hour is behind the clock: anything untaken here is late, not upcoming.
  final bool passed;
  final void Function(String, int) onToggle;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final done = items.every((it) => it.med.times[it.index].taken);
    final late = !done && passed;

    return Padding(
      padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 46,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  at,
                  style: context.t.titleMedium?.copyWith(
                    fontSize: 14,
                    color: late ? c.protein : c.text,
                  ),
                ),
              ),
            ),

            // The rail: solid behind, hairline ahead.
            SizedBox(
              width: 26,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? c.success : c.card,
                      border: Border.all(color: done ? c.success : c.hairline, width: 2),
                    ),
                    child: done ? CalviIcon('check', size: 10, color: c.card) : null,
                  ),
                  /* Solid behind, dashed ahead. The rail is the day: what has
                     happened is a line, what has not is a plan. */
                  if (!last)
                    Expanded(
                      child: CustomPaint(
                        size: const Size(2, double.infinity),
                        painter: _RailLine(
                          colour: done ? c.success : c.hairline,
                          dashed: !done,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    for (final it in items)
                      _Dose(
                        med: it.med,
                        taken: it.med.times[it.index].taken,
                        onTap: () => onToggle(it.med.id, it.index),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dose extends StatelessWidget {
  const _Dose({required this.med, required this.taken, required this.onTap});

  final Med med;
  final bool taken;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: CalviMotion.fast,
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: taken ? c.fillSecondary : c.card,
          border: Border.all(color: taken ? c.fillSecondary : c.cardBorder),
          borderRadius: BorderRadius.circular(CalviSize.rCard),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med.name,
                    style: context.t.titleMedium?.copyWith(
                      fontSize: 15,
                      color: taken ? c.textSecondary : c.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(doseLabel(med.dose, med.form), style: context.t.labelSmall),
                  if (med.note != null) ...[
                    const SizedBox(height: 2),
                    Text(med.note!, style: context.t.labelSmall?.copyWith(fontSize: 11)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            _Tick(taken: taken),
          ],
        ),
      ),
    );
  }
}

/// The rail between two hours.
class _RailLine extends CustomPainter {
  _RailLine({required this.colour, required this.dashed});

  final Color colour;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colour
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final x = size.width / 2;

    if (!dashed) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      return;
    }
    for (var y = 0.0; y < size.height; y += 8) {
      canvas.drawLine(Offset(x, y), Offset(x, (y + 4).clamp(0, size.height)), paint);
    }
  }

  @override
  bool shouldRepaint(_RailLine old) => old.colour != colour || old.dashed != dashed;
}

/// The mark on a dose that has been taken.
///
/// It overshoots to 1.14 on the way in and settles back: a tick that simply
/// appears reads as the state having always been that way, and the one thing
/// worth feeling here is that you just did it.
class _Tick extends StatefulWidget {
  const _Tick({required this.taken});

  final bool taken;

  @override
  State<_Tick> createState() => _TickState();
}

class _TickState extends State<_Tick> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
    value: widget.taken ? 1 : 0,
  );

  @override
  void didUpdateWidget(_Tick old) {
    super.didUpdateWidget(old);
    // Only the arrival is worth an overshoot; untaking is a correction.
    if (widget.taken && !old.taken) {
      _c.forward(from: 0);
    } else if (!widget.taken && old.taken) {
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final at = CalviMotion.ease.transform(_c.value);
        // Up to 1.14 by two thirds of the way, back to 1 by the end.
        final scale = at < 0.66 ? 1 + 0.14 * (at / 0.66) : 1.14 - 0.14 * ((at - 0.66) / 0.34);
        return Transform.scale(
          scale: widget.taken ? scale : 1,
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.taken ? c.success : c.fillSecondary,
            ),
            child: CalviIcon(
              widget.taken ? 'check' : 'plus',
              size: 14,
              color: widget.taken ? c.card : c.textSecondary,
            ),
          ),
        );
      },
    );
  }
}

/// 16.24: a row of the rail arriving, 420 ms and 70 ms after the one above it.
///
/// The rail is read top to bottom, so it assembles top to bottom: all at once
/// would be a list appearing, and what is wanted is a day being laid out.
class _Arrive extends StatelessWidget {
  const _Arrive({required this.rank, required this.child});

  final int rank;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const step = 70;
    const run = 420;
    final total = run + step * rank;

    return TweenAnimationBuilder<double>(
      tween: Tween(end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(step * rank / total, 1, curve: CalviMotion.ease),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}

/// Warm light off the corner the ring sits in.
class _Glow extends CustomPainter {
  _Glow({required this.colour});

  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width + 40 - 90, -60 + 90);
    canvas.drawCircle(
      centre,
      90,
      Paint()
        ..shader = ui.Gradient.radial(centre, 90, [
          colour.withValues(alpha: 0.34),
          colour.withValues(alpha: 0),
        ]),
    );
  }

  @override
  bool shouldRepaint(_Glow old) => old.colour != colour;
}
