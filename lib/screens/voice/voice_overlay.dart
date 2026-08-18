import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design/icons.dart';
import '../../design/theme.dart';
import 'dictation.dart';
import 'level_source.dart';

/// How many bars the meter draws. Enough to read as sound, few enough to stay
/// calm.
const _bars = 32;

/* Що показує демо, коли справжнього розпізнавання немає: на комп'ютері, у тесті
   і на телефоні без нього. Рядок навмисно один і той самий, щоб його ні з чим не
   сплутати. */
const _said = 'два яйця, тост і кава без цукру';
const _wordTime = Duration(milliseconds: 520);

/// Dictation, over the whole screen.
///
/// The screen behind blurs rather than disappears, because dictation is a layer
/// over the day and not a different place. In the middle a meter that answers to
/// the room, and under it the words as they land, so the person can see they
/// were heard before they stop talking.
class VoiceOverlay extends StatefulWidget {
  const VoiceOverlay({super.key, required this.onDone, this.source});

  /// Called with what was dictated, or with an empty string if nothing came.
  final ValueChanged<String> onDone;

  /* Джерело рівня. Порожньо означає «слухати телефон по-справжньому»; тест і
     демонстрація підставляють сюди своє і отримують той самий екран. */
  final LevelSource? source;

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

  /// Справжнє диктування, коли джерело не підставили ззовні.
  Dictation? _live;

  /// Чому мовчимо, якщо мовчимо. Показується замість почутого.
  String? _trouble;

  /* Створюється тут, а не лінивим полем.
   *
   * Лінива ініціалізація виглядала охайно і мовчки ламала все: поле обчислюється
   * при першому зверненні, а перевірка нижче зверталась не до нього, а до
   * `_live`, який на той момент ще був порожній. Диктування не вмикалось ніколи,
   * і замість голосу програвалась показова фраза. */
  late final LevelSource _source;

  @override
  void initState() {
    super.initState();
    _clock.addListener(_frame);

    final live = widget.source == null ? Dictation() : null;
    _live = live;
    _source = widget.source ?? live!;

    if (live == null) {
      _fake();
      return;
    }

    unawaited(
      live
          .start(onWords: (words) {
            if (mounted) setState(() => _heard = words);
          })
          .then((ok) {
            if (!mounted) return;
            // Не вийшло слухати, і про це треба сказати, а не вдавати диктування.
            if (!ok) setState(() => _trouble = live.failure);
          }),
    );
  }

  /* Показова розшифровка для екрана без мікрофона: комп'ютер, тест, телефон без
     розпізнавання. Слова лягають по одному, бо все разом означало б, що фразу
     знали наперед, а це саме те, чим диктування не є. */
  void _fake() {
    final words = _said.split(' ');
    var n = 0;
    _type = Timer.periodic(_wordTime, (t) {
      if (n >= words.length) return t.cancel();
      setState(() => _heard = words.take(++n).join(' '));
    });
  }

  void _frame() {
    _elapsed = _clock.lastElapsedDuration ?? Duration.zero;
    final level = _source.level(_elapsed);
    final t = _elapsed.inMilliseconds.toDouble();

    /* Біда може статись і посеред диктування, не лише на старті: мікрофон
       забирає дзвінок, вимикається мережа, двигун здається після кількох
       порожніх відрізків. Раніше причину читали один раз при вмиканні, і після
       неї смуги продовжували дихати над мертвим мікрофоном. */
    final live = _live;
    if (live != null && live.failure != _trouble) _trouble = live.failure;

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
    _source.dispose();
    super.dispose();
  }

  Future<void> _stop() async {
    HapticFeedback.selectionClick();
    final live = _live;
    // Дочекатись двигуна, бо останнє слово часто приходить саме на зупинці.
    final said = live == null ? _heard : await live.stop();
    if (!mounted) return;
    widget.onDone(said.trim());
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final level = _source.level(_elapsed);

    return Stack(
      children: [
        /* A real blur, not a wash of white over the page. Lowering the opacity
           of a veil leaves every edge behind it perfectly sharp, which reads as
           a dimmed screen rather than as attention moving off it.
         *
         * Дотик до нього не зупиняє запис, і це навмисне. Людина диктує з
         * телефоном у руці, а не перед собою на столі: випадковий дотик долонею
         * або великим пальцем обривав фразу посеред слова. Вимикає диктування
         * тільки той самий мікрофон, яким його ввімкнули. Але дотики шар усе
         * одно ловить: під ним живий екран, і натиснути кнопку крізь туман
         * означало б зробити щось, чого не видно. */
        Positioned.fill(
          child: GestureDetector(
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
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _MeterPainter(peaks: _peak, ink: c.text),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: 280,
                child: Text(
                  /* Причина замість почутого, коли слухати не вийшло: мовчазний
                     екран із бігунцями виглядав би як робота, якої немає. */
                  _trouble ?? _heard,
                  textAlign: TextAlign.center,
                  style: context.t.headlineMedium?.copyWith(
                    fontSize: 19,
                    color: _trouble == null ? null : c.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _trouble == null
                    ? 'Говори. Торкнись мікрофона, щоб зупинити'
                    : 'Торкнись мікрофона, щоб закрити',
                style: context.t.labelSmall,
              ),
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
                onTap: () => unawaited(_stop()),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 116,
                  height: 116,
                  child: RepaintBoundary(
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
