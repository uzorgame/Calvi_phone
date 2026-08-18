import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'shell.dart';
import 'theme.dart';
import 'tokens.dart';

/// Row height and how many rows the drum shows.
const _row = 40.0;
const _visible = 5;

/// How tall the drum stands. Five rows, so two values are readable either side
/// of the one under the band.
const _drum = 200.0;

/* The framework's wheel is flattened almost to a list and the tilt is written
   here instead. Its cylinder moves rows along the drum as well as turning them,
   so a curve steep enough to match the demo's 58 degrees pulled the outer values
   in towards the middle: five evenly spaced rows became three and two smears.
   Flat, the rows stand where the demo stands them, and the turn is the demo's
   own transform applied about each row's own centre. */
const _cylinder = 6.0;

/// How far a row turns away at the edge of the drum, and how far off it is
/// before the turn is complete: the demo's rotateX(-d * 58deg).
const _tilt = 58 * math.pi / 180;

/// One drum: values scroll under a fixed band, tilting away from it as they go.
///
/// It replaces a row of preset buttons, which only ever cover the values we
/// happened to guess. Someone 178 cm tall should not have to pick 180 because
/// that is what the interface offered.
class CalviWheelColumn extends StatefulWidget {
  const CalviWheelColumn({
    super.key,
    required this.values,
    required this.value,
    required this.onPick,
    this.suffix = '',
    this.format,
    this.width = 120,
  });

  final List<int> values;
  final int value;
  final ValueChanged<int> onPick;

  /// Set small beside the number: «см», «кг», «років».
  final String suffix;

  /// How the number reads, when it is not just its digits: «07» for an hour.
  final String Function(int)? format;
  final double width;

  @override
  State<CalviWheelColumn> createState() => _CalviWheelColumnState();
}

class _CalviWheelColumnState extends State<CalviWheelColumn> {
  late final int _start = widget.values.indexOf(widget.value).clamp(
    0,
    widget.values.length - 1,
  );
  late final FixedExtentScrollController _c = FixedExtentScrollController(initialItem: _start);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    /* Built once and handed back unchanged while the ink stays the same.
       Everything above a drum rebuilds on every detent it reports, and a rebuilt
       drum lays out again; a drum that lays out mid-fling has its fling started
       over, aimed one row further along each time. That chain is what made the
       drums in settings feel worse than the same drums at the first run, where
       less stands above them. */
    if (_tree != null && identical(_ink, c)) return _tree!;
    _ink = c;
    return _tree = _wheel(c);
  }

  CalviColors? _ink;
  Widget? _tree;

  Widget _wheel(CalviColors c) {
    return SizedBox(
      width: widget.width,
      child: ListWheelScrollView.useDelegate(
        controller: _c,
        itemExtent: _row,
        diameterRatio: _cylinder,
        perspective: 0.00001,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (i) {
          HapticFeedback.lightImpact();
          widget.onPick(widget.values[i]);
        },
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: widget.values.length,
          builder: (context, i) => AnimatedBuilder(
            /* The framework tilts the rows; the fade and the shrink on top of
               the tilt are the demo's, and they are written per row against the
               live scroll offset rather than through state: a drum routed
               through setState would rebuild the sheet on every pixel. */
            animation: _c,
            builder: (context, _) {
              final at = _c.hasClients ? _c.offset : _start * _row;
              final d = (i * _row - at) / (_row * _visible / 2);
              final k = d.abs().clamp(0.0, 1.0);
              return Opacity(
                opacity: 1 - k * 0.72,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, -1 / 620)
                    ..rotateX(-d * _tilt)
                    ..scaleByDouble(1 - k * 0.22, 1 - k * 0.22, 1, 1),
                  child: _face(context, c, i),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _face(BuildContext context, CalviColors c, int i) {
    final v = widget.values[i];
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            widget.format?.call(v) ?? '$v',
            style: context.t.headlineMedium?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 22 * -0.02,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: c.text,
            ),
          ),
          if (widget.suffix.isNotEmpty) ...[
            const SizedBox(width: 3),
            Text(
              widget.suffix,
              style: context.t.labelSmall?.copyWith(fontWeight: FontWeight.w400),
            ),
          ],
        ],
      ),
    );
  }
}

/// The band and the fading ends that every drum stands in.
class _Drum extends StatelessWidget {
  const _Drum({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      height: _drum,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The band stays put and the values move under it, so the drum has a
          // place to stop at rather than a number that happens to be halfway up.
          IgnorePointer(
            child: Container(
              height: _row,
              decoration: BoxDecoration(
                color: c.fillSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
          // Values dissolve at the ends of the drum rather than being cut off by
          // it. Two veils of the page rather than a mask: a mask means a layer
          // saved and blended on every frame of a scroll.
          for (final top in const [true, false])
            IgnorePointer(
              child: Align(
                alignment: top ? Alignment.topCenter : Alignment.bottomCenter,
                child: Container(
                  height: _drum * 0.34,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: top ? Alignment.topCenter : Alignment.bottomCenter,
                      end: top ? Alignment.bottomCenter : Alignment.topCenter,
                      colors: [c.bg, c.bg.withValues(alpha: 0)],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A single drum with the band behind it, for one-value pickers.
class CalviWheel extends StatelessWidget {
  const CalviWheel({
    super.key,
    required this.values,
    required this.value,
    required this.onPick,
    required this.suffix,
  });

  final List<int> values;
  final int value;
  final ValueChanged<int> onPick;
  final String suffix;

  @override
  Widget build(BuildContext context) => _Drum(
    children: [
      CalviWheelColumn(values: values, value: value, onPick: onPick, suffix: suffix),
    ],
  );
}

/// Hours and minutes on two drums under one band.
class CalviTimeWheel extends StatelessWidget {
  const CalviTimeWheel({
    super.key,
    required this.hour,
    required this.minute,
    required this.onHour,
    required this.onMinute,
  });

  final int hour;
  final int minute;

  /* One callback per drum. A single onChange(hour, minute) looked tidier, but
     each column would have to pass the other column's value, and a column owns
     its scroll from the moment it mounts: setting the hour quietly reset the
     minutes to whatever they were when the sheet opened. */
  final ValueChanged<int> onHour;
  final ValueChanged<int> onMinute;

  static String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) => _Drum(
    children: [
      CalviWheelColumn(
        values: List.generate(24, (i) => i),
        value: hour,
        onPick: onHour,
        format: _pad,
        width: 86,
      ),
      const SizedBox(width: 6),
      Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          ':',
          style: context.t.headlineMedium?.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
      const SizedBox(width: 6),
      CalviWheelColumn(
        // Five-minute steps: a reminder at 13:47 is a reminder nobody meant to set.
        values: List.generate(12, (i) => i * 5),
        value: minute,
        onPick: onMinute,
        format: _pad,
        width: 86,
      ),
    ],
  );
}

/// A number nudged in fixed steps: minus, the figure, plus.
///
/// For values people adjust rather than choose. A wheel of every hundred
/// millilitres from zero to four thousand is a wheel nobody wants to turn.
class CalviStepper extends StatelessWidget {
  const CalviStepper({
    super.key,
    required this.value,
    required this.step,
    required this.suffix,
    required this.onChange,
    this.min = 0,
  });

  final int value;
  final int step;
  final String suffix;
  final ValueChanged<int> onChange;
  final int min;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: context.c.cardBorder),
        borderRadius: BorderRadius.circular(CalviSize.rLarge),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Key(
            label: 'Менше',
            sign: '−',
            onTap: () => onChange((value - step).clamp(min, 1 << 30)),
          ),
          Text.rich(
            TextSpan(
              text: '$value',
              children: [
                TextSpan(
                  text: ' $suffix',
                  style: context.t.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
                ),
              ],
            ),
            style: context.t.headlineMedium?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 24 * -0.02,
            ),
          ),
          _Key(label: 'Більше', sign: '+', onTap: () => onChange(value + step)),
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.sign, required this.onTap});

  final String label;
  final String sign;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      button: true,
      label: label,
      child: CalviPress(
        onTap: onTap,
        builder: (context, down) => AnimatedScale(
          scale: down ? 0.9 : 1,
          duration: CalviMotion.fast,
          curve: CalviMotion.ease,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c.fillSecondary),
            child: Text(sign, style: context.t.headlineMedium?.copyWith(fontSize: 22)),
          ),
        ),
      ),
    );
  }
}

/// The slider, in this app's ink.
///
/// The words above the track say what the ends mean, and the one the handle is
/// nearest lights up: a bare track of numbers makes a person work out what
/// «0.8» is supposed to feel like. Steps are real steps, but the track runs
/// continuously so the handle never stutters under the finger; the value it
/// reports is snapped. On release the handle eases onto the notch it landed on,
/// and during the drag it does not, because a handle that lags the finger reads
/// as a dropped frame.
class CalviSlider extends StatefulWidget {
  const CalviSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChange,
    this.marks = const [],
  });

  final double value;
  final double min;
  final double max;
  final double step;
  final ValueChanged<double> onChange;

  /// Words over the track: what the low, middle and high ends mean.
  final List<String> marks;

  @override
  State<CalviSlider> createState() => _CalviSliderState();
}

class _CalviSliderState extends State<CalviSlider> {
  /// Where the handle actually is, before the value is snapped to a step.
  late double _raw = widget.value;
  bool _settling = false;

  @override
  void didUpdateWidget(CalviSlider old) {
    super.didUpdateWidget(old);
    // A value changed from outside wins: the handle shows it, it does not drive it.
    if (old.value != widget.value && widget.value != _snap(_raw)) _raw = widget.value;
  }

  double _snap(double v) {
    final n = ((v - widget.min) / widget.step).round() * widget.step + widget.min;
    return double.parse(n.toStringAsFixed(widget.step < 1 ? 2 : 0));
  }

  void _drag(double x, double width) {
    final t = (x / width).clamp(0.0, 1.0);
    final next = widget.min + t * (widget.max - widget.min);
    setState(() => _raw = next);
    final snapped = _snap(next);
    if (snapped == _snap(widget.value)) return;
    // One click per real step, not one per pixel of travel.
    HapticFeedback.lightImpact();
    widget.onChange(snapped);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final at = ((_raw - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);
    final lit = widget.marks.isEmpty ? -1 : (at * (widget.marks.length - 1)).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.marks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final (i, m) in widget.marks.indexed)
                  // Flexible, so a wider font shortens the words rather than
                  // running them off the end of the track.
                  Flexible(
                    child: Text(
                      m,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.t.labelSmall?.copyWith(
                        fontWeight: i == lit ? FontWeight.w600 : FontWeight.w400,
                        color: i == lit ? c.accent : c.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        LayoutBuilder(
          /* Raw pointer events rather than a drag gesture. A drag has to win an
             arena and travel a slop distance before it starts, and both of those
             land as a handle that sticks and then jumps; the demo's range input
             has neither, and the difference is the whole feel of the control.

             The empty vertical drag under it is what keeps the page still: raw
             pointers claim nothing in the arena, so the list behind the slider
             was taking the same finger and scrolling the screen while the handle
             moved. Claimed here and dropped, the page stays where it was. */
          builder: (context, box) => GestureDetector(
            onVerticalDragStart: (_) {},
            onVerticalDragUpdate: (_) {},
            onVerticalDragEnd: (_) {},
            child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (e) {
              setState(() => _settling = false);
              _drag(e.localPosition.dx, box.maxWidth);
            },
            onPointerMove: (e) => _drag(e.localPosition.dx, box.maxWidth),
            onPointerUp: (_) => setState(() {
              _settling = true;
              _raw = _snap(_raw);
            }),
            onPointerCancel: (_) => setState(() {
              _settling = true;
              _raw = _snap(_raw);
            }),
            child: SizedBox(
              // Room for the handle to stand proud of the track, and for a thumb
              // to land anywhere near it.
              height: 30,
              child: Stack(
                alignment: Alignment.centerLeft,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: c.fillSecondary,
                      borderRadius: BorderRadius.circular(CalviSize.rPill),
                    ),
                  ),
                  AnimatedContainer(
                    duration: _settling ? const Duration(milliseconds: 200) : Duration.zero,
                    curve: CalviMotion.easeRise,
                    height: 8,
                    width: box.maxWidth * at,
                    decoration: BoxDecoration(
                      color: c.button,
                      borderRadius: BorderRadius.circular(CalviSize.rPill),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: _settling ? const Duration(milliseconds: 200) : Duration.zero,
                    curve: CalviMotion.easeRise,
                    left: box.maxWidth * at - 15,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        /* The handle sits on the filled part of the track, so it
                           is made of the ink's opposite: white on dark in the
                           light theme, dark on light in the dark one. */
                        color: c.buttonText,
                        border: Border.all(color: c.button, width: 2),
                        boxShadow: [
                          BoxShadow(color: c.shade, blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
        ),
      ],
    );
  }
}
