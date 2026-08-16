import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme.dart';
import 'tokens.dart';

/// A value picked off a drum.
///
/// Built on the framework's own wheel rather than a hand-rolled list: the
/// perspective, the physics and the detents are what a picker on this platform
/// already does, and rewriting them means shipping a wheel that feels almost
/// right, which is worse than one that feels familiar.
class CalviWheel extends StatefulWidget {
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
  State<CalviWheel> createState() => _CalviWheelState();
}

class _CalviWheelState extends State<CalviWheel> {
  late final FixedExtentScrollController _c = FixedExtentScrollController(
    initialItem: widget.values.indexOf(widget.value).clamp(0, widget.values.length - 1),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return SizedBox(
      height: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The band under the chosen value, so the wheel has a place to stop at
          // rather than a number that happens to be in the middle.
          IgnorePointer(
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: c.fillSecondary,
                borderRadius: BorderRadius.circular(CalviSize.rCard),
              ),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: _c,
            itemExtent: 40,
            // Shallow: a steep wheel turns the numbers on either side into
            // edges, and this one is read as much as it is turned.
            diameterRatio: 1.9,
            perspective: 0.004,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (i) {
              HapticFeedback.selectionClick();
              widget.onPick(widget.values[i]);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.values.length,
              builder: (context, i) => Center(
                child: Text(
                  '${widget.values[i]} ${widget.suffix}',
                  style: context.t.headlineMedium?.copyWith(
                    color: widget.values[i] == widget.value ? c.text : c.textSecondary,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _Key(
            label: 'Менше',
            sign: '−',
            onTap: () => onChange((value - step).clamp(min, 1 << 30)),
          ),
          Expanded(
            child: Center(
              child: Text.rich(
                TextSpan(
                  text: '$value',
                  children: [
                    TextSpan(
                      text: ' $suffix',
                      style: context.t.labelSmall?.copyWith(fontSize: 14),
                    ),
                  ],
                ),
                style: context.t.headlineMedium,
              ),
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
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: c.fillSecondary),
          child: Text(sign, style: context.t.headlineMedium?.copyWith(fontSize: 22)),
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
    HapticFeedback.selectionClick();
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
                  Text(
                    m,
                    style: context.t.labelSmall?.copyWith(
                      fontWeight: i == lit ? FontWeight.w600 : FontWeight.w400,
                      color: i == lit ? c.accent : c.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        LayoutBuilder(
          builder: (context, box) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (d) {
              setState(() => _settling = false);
              _drag(d.localPosition.dx, box.maxWidth);
            },
            onHorizontalDragUpdate: (d) => _drag(d.localPosition.dx, box.maxWidth),
            onHorizontalDragEnd: (_) => setState(() {
              _settling = true;
              _raw = _snap(_raw);
            }),
            onTapDown: (d) => setState(() => _settling = false),
            onTapUp: (d) {
              _drag(d.localPosition.dx, box.maxWidth);
              setState(() {
                _settling = true;
                _raw = _snap(_raw);
              });
            },
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
      ],
    );
  }
}
