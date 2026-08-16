import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'theme.dart';
import 'tokens.dart';

/// Ring of progress. The arc starts at the top and runs clockwise.
///
/// A painter and not an SVG: this is the one mark in the set that moves. It
/// draws itself on when it appears and then slides to any later value, so the
/// geometry has to be a number the framework can animate, not a document.
///
/// **It fills, it never spins.** The motion here is of one kind, filling, and it
/// matches what is actually happening to the day. A ring that rotates says
/// "working" and this one is not working, it is reporting.
class CalviRing extends StatefulWidget {
  const CalviRing({
    super.key,
    required this.progress,
    this.size = 92,
    this.stroke = 9,
    this.color,
    this.track,
    this.fill = true,
    this.child,
  });

  /// 0 to 1. Anything above is clipped: past the line there is nothing left to
  /// measure, and the colour carries the overshoot instead.
  final double progress;
  final double size;
  final double stroke;
  final Color? color;
  final Color? track;

  /// Draw itself on when it first appears rather than being already there.
  final bool fill;
  final Widget? child;

  @override
  State<CalviRing> createState() => _CalviRingState();
}

class _CalviRingState extends State<CalviRing> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
  );
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _a = _curve(widget.fill ? 0 : widget.progress, widget.progress);
    _c.forward();
  }

  /* Expo out, the same curve the demo uses: quick off the mark, long settle. */
  Animation<double> _curve(double from, double to) => Tween<double>(
    begin: from,
    end: to,
  ).animate(CurvedAnimation(parent: _c, curve: CalviMotion.easeRise));

  @override
  void didUpdateWidget(CalviRing old) {
    super.didUpdateWidget(old);
    if (old.progress == widget.progress) return;
    /* A value that changes later slides to its new length from wherever the arc
       currently is, rather than being redrawn from zero. */
    _a = _curve(_a.value, widget.progress);
    _c
      ..duration = const Duration(milliseconds: 620)
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _a,
            builder: (context, _) => CustomPaint(
              size: Size.square(widget.size),
              painter: _RingPainter(
                progress: _a.value.clamp(0.0, 1.0),
                stroke: widget.stroke,
                color: widget.color ?? c.button,
                track: widget.track ?? c.track,
              ),
            ),
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.stroke,
    required this.color,
    required this.track,
  });

  final double progress;
  final double stroke;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final r = (size.width - stroke) / 2;
    final centre = Offset(size.width / 2, size.height / 2);
    final box = Rect.fromCircle(center: centre, radius: r);

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawCircle(centre, r, base);

    if (progress <= 0) return;

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      // Round ends, so a short arc still reads as a mark rather than a chip.
      ..strokeCap = StrokeCap.round
      ..color = color;
    // From the top, clockwise: -90 degrees is twelve o'clock in canvas terms.
    canvas.drawArc(box, -math.pi / 2, 2 * math.pi * progress, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}
