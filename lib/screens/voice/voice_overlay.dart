import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design/icons.dart';
import '../../design/theme.dart';
import 'level_source.dart';

/// How many bars the meter draws. Enough to read as sound, few enough to stay
/// calm.
const _bars = 32;

/* What the demo transcribes. Real speech recognition is a server away, and a
   canned line is honest about that: the meter really does answer to a level,
   the words do not pretend to. */
const _said = 'два яйця, тост і кава без цукру';
const _wordTime = Duration(milliseconds: 520);

/// Dictation, over the whole screen.
///
/// The screen behind blurs rather than disappears, because dictation is a layer
/// over the day and not a different place. In the middle a meter that answers to
/// the room, and under it the words as they land, so the person can see they
/// were heard before they stop talking.
class VoiceOverlay extends StatefulWidget {
  const VoiceOverlay({super.key, required this.onDone, this.source = const BreathingLevel()});

  /// Called with what was dictated, or with an empty string if nothing came.
  final ValueChanged<String> onDone;

  /// Swap in a real analyser and the screen does not change.
  final LevelSource source;

  @override
  State<VoiceOverlay> createState() => _VoiceOverlayState();
}

class _VoiceOverlayState extends State<VoiceOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(days: 1),
  )..forward();

  /* Each bar keeps its own falling ceiling, so the meter settles instead of
     flickering: sound rises instantly and decays over a few frames. */
  final _peak = List<double>.filled(_bars, 0);

  Duration _elapsed = Duration.zero;
  String _heard = '';
  Timer? _type;

  @override
  void initState() {
    super.initState();
    _clock.addListener(_frame);

    /* The words land one at a time. Everything at once would say the phrase was
       already known, which is exactly what dictation is not. */
    final words = _said.split(' ');
    var n = 0;
    _type = Timer.periodic(_wordTime, (t) {
      if (n >= words.length) return t.cancel();
      setState(() => _heard = words.take(++n).join(' '));
    });
  }

  void _frame() {
    _elapsed = _clock.lastElapsedDuration ?? Duration.zero;
    final level = widget.source.level(_elapsed);
    final t = _elapsed.inMilliseconds.toDouble();

    for (var i = 0; i < _bars; i++) {
      /* Middle bars carry more of the level than the ends, the way a voice meter
         is drawn, plus a little per-bar variation so it is not one hump. */
      final mid = 1 - (i / (_bars - 1) - 0.5).abs() * 2;
      final shape = 0.35 + 0.65 * mid;
      final jitter = 0.72 + 0.28 * math.sin(t / 90 + i * 1.7);
      final want = math.max(0.06, level * shape * jitter);
      _peak[i] = want > _peak[i] ? want : _peak[i] * 0.86 + want * 0.14;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _type?.cancel();
    _clock.removeListener(_frame);
    _clock.dispose();
    widget.source.dispose();
    super.dispose();
  }

  void _stop() {
    HapticFeedback.selectionClick();
    widget.onDone(_heard);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final level = widget.source.level(_elapsed);

    return Stack(
      children: [
        /* A real blur, not a wash of white over the page. Lowering the opacity
           of a veil leaves every edge behind it perfectly sharp, which reads as
           a dimmed screen rather than as attention moving off it. */
        Positioned.fill(
          child: GestureDetector(
            onTap: _stop,
            behavior: HitTestBehavior.opaque,
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 11, sigmaY: 11),
              child: ColoredBox(color: c.bg.withValues(alpha: 0.4)),
            ),
          ),
        ),

        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 96,
                width: 250,
                child: CustomPaint(
                  painter: _MeterPainter(peaks: _peak, ink: c.text),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: 280,
                child: Text(
                  _heard,
                  textAlign: TextAlign.center,
                  style: context.t.headlineMedium?.copyWith(fontSize: 19),
                ),
              ),
              const SizedBox(height: 10),
              Text('Говори, торкнись будь-де, щоб зупинити', style: context.t.labelSmall),
            ],
          ),
        ),

        /* The button that started this, grown and breathing. It stays sharp
           while everything else blurs, because it is the one thing still in
           use. */
        Positioned(
          left: 0,
          right: 0,
          bottom: 44,
          child: Center(
            child: Semantics(
              button: true,
              label: 'Зупинити запис',
              child: GestureDetector(
                onTap: _stop,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 116,
                  height: 116,
                  child: CustomPaint(
                    painter: _WobblePainter(
                      level: level,
                      phase: _elapsed.inMilliseconds / 1000,
                      fill: c.button,
                    ),
                    child: Center(child: CalviIcon('mic', size: 26, color: c.buttonText)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MeterPainter extends CustomPainter {
  _MeterPainter({required this.peaks, required this.ink});

  final List<double> peaks;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final gap = size.width / peaks.length;
    final paint = Paint()
      ..color = ink
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.min(4, gap * 0.55);

    for (var i = 0; i < peaks.length; i++) {
      final x = gap * (i + 0.5);
      final h = size.height * peaks[i] / 2;
      canvas.drawLine(Offset(x, size.height / 2 - h), Offset(x, size.height / 2 + h), paint);
    }
  }

  @override
  bool shouldRepaint(_MeterPainter old) => true;
}

/// The microphone disc, with an edge that answers to the room.
///
/// Three sine terms at different frequencies rather than one: a single wave
/// makes an egg that rotates, and what is wanted is a surface that ripples.
class _WobblePainter extends CustomPainter {
  _WobblePainter({required this.level, required this.phase, required this.fill});

  final double level;
  final double phase;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final base = size.shortestSide / 2 - 6;
    final amp = base * 0.06 * (0.35 + level);

    final path = Path();
    for (var a = 0.0; a <= 360; a += 3) {
      final rad = a * math.pi / 180;
      final r =
          base +
          amp * math.sin(3 * rad + phase * 2.1) +
          amp * 0.6 * math.sin(5 * rad - phase * 1.4) +
          amp * 0.4 * math.sin(7 * rad + phase * 0.9);
      final p = centre + Offset(math.cos(rad) * r, math.sin(rad) * r);
      if (a == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();

    canvas.drawPath(path, Paint()..color = fill.withValues(alpha: 0.18));
    canvas.drawCircle(centre, base * 0.74, Paint()..color = fill);
  }

  @override
  bool shouldRepaint(_WobblePainter old) => true;
}
