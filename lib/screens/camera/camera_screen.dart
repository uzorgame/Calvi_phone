import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/chat.dart';
import '../../design/icons.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';

enum CamMode { food, barcode }

class _ModeInfo {
  const _ModeInfo({
    required this.id,
    required this.icon,
    required this.title,
    required this.hint,
  });

  final CamMode id;
  final String icon;
  final String title;
  final String hint;
}

/* Two modes, two different jobs for the same lens. Food goes to the model and
   comes back as an estimate; a barcode is read on the device, hits the product
   base and costs nothing. */
const _modes = <_ModeInfo>[
  _ModeInfo(id: CamMode.food, icon: 'utensils', title: 'Страва', hint: 'наведи на тарілку'),
  _ModeInfo(id: CamMode.barcode, icon: 'barcode', title: 'Штрихкод', hint: 'код у рамку'),
];

/// How long the stand-in recognition holds before the answer lands.
const _readTime = Duration(milliseconds: 1400);

/// The one product the demo base knows.
const demoBarcode = '4820001234567';

/* The viewfinder is its own world and does not take the app's palette: a
   viewfinder that goes light in the light theme stops being a viewfinder. */
const _ink = Color(0xFFFFFFFF);
const _chrome = Color(0x6B141418);
const _chromeRound = Color(0x73141418);
const _dark = Color(0xFF101014);

/// Viewfinder, full screen.
///
/// Everything is chrome over the picture: the frame is the interface, and the
/// controls float on it rather than sit in a bar that eats the shot. The corner
/// brackets are not decoration, they say where to aim, and in barcode mode they
/// close in on a line, because a barcode needs a strip and a plate needs a
/// square.
///
/// The photo is not kept. It goes up, comes back as numbers, and is gone: an app
/// that quietly builds a gallery of what someone ate is a different app.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required this.slot, required this.onSend});

  /// Card the shot will be written into, so the shutter can say where it goes.
  final String slot;

  /// The shot leaves as a message. The viewfinder closes behind it and the chat
  /// opens with it already sent, because that is where the answer will arrive.
  final void Function(MsgKind kind, String? code) onSend;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CamMode _mode = CamMode.food;
  bool _busy = false;
  bool _done = false;
  bool _flash = false;

  /* A Timer and not a delayed future: it has to be cancellable. A shutter fired
     on the way out would otherwise open a sheet on a screen that is gone. */
  Timer? _read;

  @override
  void dispose() {
    _read?.cancel();
    super.dispose();
  }

  void _shoot() {
    if (_busy) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _busy = true;
      _done = false;
    });
    _read?.cancel();
    _read = Timer(_readTime, () {
      if (!mounted) return;
      HapticFeedback.selectionClick();
      setState(() {
        _busy = false;
        _done = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = _modes.firstWhere((m) => m.id == _mode);
    final slim = _mode == CamMode.barcode;

    return Scaffold(
      backgroundColor: _dark,
      body: Stack(
        children: [
          const Positioned.fill(child: _Feed()),

          /* The frame is placed against the screen, not centred in whatever the
             chrome left over: it has to sit where a plate sits when somebody
             holds a phone over a table. */
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, box) => Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 420),
                    curve: CalviMotion.easeRise,
                    left: box.maxWidth * (slim ? 0.08 : 0.12),
                    right: box.maxWidth * (slim ? 0.08 : 0.12),
                    top: box.maxHeight * (slim ? 0.40 : 0.26),
                    bottom: box.maxHeight * (slim ? 0.44 : 0.34),
                    child: _Frame(slim: slim),
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      _Round(
                        icon: 'chevron',
                        label: 'Назад',
                        turn: true,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Expanded(
                        child: Text(
                          'Сканер',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _ink,
                            fontSize: CalviSize.fsBody,
                            fontWeight: FontWeight.w600,
                            letterSpacing: CalviSize.fsBody * -0.02,
                            shadows: [
                              Shadow(
                                color: Color(0x66000000),
                                blurRadius: 8,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                      /* Nothing lives behind a menu here. The screen has two
                         modes, a shutter and a flash, and a button that opens
                         nothing teaches people to stop pressing buttons. */
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _busy ? 'Читаю…' : current.hint,
                  style: TextStyle(
                    color: _ink.withValues(alpha: 0.78),
                    fontSize: CalviSize.fsMicro,
                    shadows: const [
                      Shadow(color: Color(0x80000000), blurRadius: 8, offset: Offset(0, 1)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _Deck(
                  mode: _mode,
                  flash: _flash,
                  busy: _busy,
                  slot: widget.slot,
                  onMode: (m) => setState(() {
                    _mode = m;
                    _done = false;
                  }),
                  onFlash: () => setState(() => _flash = !_flash),
                  onShoot: _shoot,
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),

          if (_done)
            TweenAnimationBuilder<double>(
              // 16.37: it arrives from below rather than appearing in place.
              key: ValueKey(_mode),
              tween: Tween(end: 1),
              duration: const Duration(milliseconds: 380),
              curve: CalviMotion.easeRise,
              builder: (context, t, child) =>
                  Transform.translate(offset: Offset(0, 300 * (1 - t)), child: child),
              child: _Result(
                mode: _mode,
                slot: widget.slot,
                onAgain: () => setState(() => _done = false),
                onSend: widget.onSend,
              ),
            ),
        ],
      ),
    );
  }
}

/// Stand-in for the live feed: a table out of focus.
///
/// A flat rectangle would not show whether the chrome above it is readable,
/// which is the only thing this screen is here to prove. The plate is cool and
/// what is on it is warm, because that is how a table reads through a lens.
class _Feed extends StatelessWidget {
  const _Feed();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;
        return Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, 0.2),
                    radius: 1.1,
                    colors: [Color(0xFF4A3526), Color(0xFF2A1D15), Color(0xFF15100C)],
                    stops: [0, 0.55, 1],
                  ),
                ),
              ),
            ),

            _Blur(
              left: -w * 0.06,
              top: h * 0.04,
              w: w * 0.56,
              h: h * 0.26,
              colour: const Color(0xFF7A5C40),
              alpha: 0.4,
            ),
            _Blur(
              left: w * 0.62,
              top: 0,
              w: w * 0.42,
              h: h * 0.30,
              colour: const Color(0xFF3F4F46),
              alpha: 0.45,
            ),
            _Blur(
              left: w * 0.04,
              top: h * 0.76,
              w: w * 0.92,
              h: h * 0.30,
              colour: const Color(0xFF16100B),
              alpha: 0.75,
            ),

            // The plate.
            _Blur(
              left: w * 0.13,
              top: h * 0.39,
              w: w * 0.74,
              h: h * 0.26,
              blur: 18,
              alpha: 0.55,
              gradient: const RadialGradient(
                colors: [Color(0xFFB9D2CC), Color(0xFF86A8A1), Color(0xFF55726C)],
                stops: [0, 0.68, 1],
              ),
            ),
            // What is on it.
            _Blur(
              left: w * 0.27,
              top: h * 0.385,
              w: w * 0.46,
              h: h * 0.17,
              blur: 14,
              alpha: 0.7,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFD3A870), Color(0xFFB8834A), Color(0x33946630)],
                stops: [0, 0.6, 1],
              ),
            ),

            // The vignette, so the chrome always has something to sit on.
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.04),
                    radius: 0.9,
                    colors: [Color(0x00000000), Color(0x8C000000)],
                    stops: [0.3, 1],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Blur extends StatelessWidget {
  const _Blur({
    required this.left,
    required this.top,
    required this.w,
    required this.h,
    required this.alpha,
    this.colour,
    this.gradient,
    this.blur = 34,
  });

  final double left;
  final double top;
  final double w;
  final double h;
  final double alpha;
  final Color? colour;
  final Gradient? gradient;
  final double blur;

  @override
  Widget build(BuildContext context) => Positioned(
    left: left,
    top: top,
    width: w,
    height: h,
    child: ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Opacity(
        opacity: alpha,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.elliptical(w / 2, h / 2)),
            color: colour,
            gradient: gradient,
          ),
        ),
      ),
    ),
  );
}

/// Corner brackets, and a beam when a barcode is what is wanted.
class _Frame extends StatefulWidget {
  const _Frame({required this.slim});

  final bool slim;

  @override
  State<_Frame> createState() => _FrameState();
}

class _FrameState extends State<_Frame> with SingleTickerProviderStateMixin {
  /// 16.35: the reading line runs a 1.8 second cycle.
  late final AnimationController _beam = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  /// 16.33: the frame arrives once, over 620 ms, from a little too large.
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  )..forward();

  @override
  void dispose() {
    _beam.dispose();
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _in,
      builder: (context, child) {
        final t = CalviMotion.easeRise.transform(_in.value);
        return Opacity(
          opacity: t,
          child: Transform.scale(scale: 1.06 - 0.06 * t, child: child),
        );
      },
      child: Stack(
        children: [
          for (final a in const [
            Alignment.topLeft,
            Alignment.topRight,
            Alignment.bottomLeft,
            Alignment.bottomRight,
          ])
            Align(
              alignment: a,
              child: _Corner(align: a),
            ),

          if (widget.slim)
            Positioned(
              left: 6,
              right: 6,
              top: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _beam,
                builder: (context, _) {
                  final k = Curves.easeInOut.transform(_beam.value);
                  return Align(
                    alignment: Alignment.center,
                    child: Transform.translate(
                      offset: Offset(0, -16 + 32 * k),
                      child: Opacity(
                        opacity: 0.35 + 0.65 * k,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: const LinearGradient(
                              colors: [Color(0x00FFFFFF), _ink, Color(0x00FFFFFF)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// One bracket of the frame.
///
/// Painted rather than built from a Border: a BoxDecoration with different sides
/// and a corner radius is not something Flutter draws, and it came out as a
/// closed rectangle instead of an L.
class _Corner extends StatelessWidget {
  const _Corner({required this.align});

  final Alignment align;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 30,
    height: 30,
    child: CustomPaint(painter: _CornerPainter(align: align)),
  );
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({required this.align});

  final Alignment align;

  @override
  void paint(Canvas canvas, Size size) {
    const r = 12.0;
    final top = align.y < 0;
    final left = align.x < 0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xEBFFFFFF);

    /* Two arms and the arc that joins them, drawn from the outside corner in:
       the bracket is one continuous stroke, so the join never shows a seam. */
    final cx = left ? r : size.width - r;
    final cy = top ? r : size.height - r;
    final path = Path()
      ..moveTo(left ? 0 : size.width, top ? size.height : 0)
      ..lineTo(left ? 0 : size.width, cy)
      ..arcToPoint(
        Offset(cx, top ? 0 : size.height),
        radius: const Radius.circular(r),
        clockwise: left == top,
      )
      ..lineTo(left ? size.width : 0, top ? 0 : size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.align != align;
}

class _Deck extends StatelessWidget {
  const _Deck({
    required this.mode,
    required this.flash,
    required this.busy,
    required this.slot,
    required this.onMode,
    required this.onFlash,
    required this.onShoot,
  });

  final CamMode mode;
  final bool flash;
  final bool busy;
  final String slot;
  final ValueChanged<CamMode> onMode;
  final VoidCallback onFlash;
  final VoidCallback onShoot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          /* The modes sit in one smoked strip. The current one is the only one
             that gets a name; the rest are marks, which is what makes the row
             readable at a glance instead of three equal labels. */
          ClipRRect(
            borderRadius: BorderRadius.circular(CalviSize.rPill),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.all(6),
                color: _chrome,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final m in _modes)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: m.id == mode
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: _ink,
                                  borderRadius: BorderRadius.circular(CalviSize.rPill),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CalviIcon(m.icon, size: 15, color: _dark),
                                    const SizedBox(width: 7),
                                    Text(
                                      m.title,
                                      style: const TextStyle(
                                        color: _dark,
                                        fontSize: CalviSize.fsMicro,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _Mode(icon: m.icon, label: m.title, onTap: () => onMode(m.id)),
                      ),
                    const _Mode(icon: 'image', label: 'З галереї', onTap: null),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _Flash(on: flash, onTap: onFlash),
                ),
              ),
              _Shutter(busy: busy, onTap: onShoot),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'в $slot',
                    style: TextStyle(
                      color: _ink.withValues(alpha: 0.72),
                      fontSize: CalviSize.fsMicro,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One mode that is not the current one: a mark, no background of its own.
class _Mode extends StatefulWidget {
  const _Mode({required this.icon, required this.label, required this.onTap});

  final String icon;
  final String label;
  final VoidCallback? onTap;

  @override
  State<_Mode> createState() => _ModeState();
}

class _ModeState extends State<_Mode> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _down ? 0.9 : 1,
          duration: CalviMotion.fast,
          curve: CalviMotion.ease,
          child: AnimatedContainer(
            duration: CalviMotion.fast,
            curve: CalviMotion.ease,
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _down ? _ink.withValues(alpha: 0.12) : const Color(0x00000000),
            ),
            child: CalviIcon(widget.icon, size: 19, color: _ink.withValues(alpha: 0.86)),
          ),
        ),
      ),
    );
  }
}

class _Flash extends StatefulWidget {
  const _Flash({required this.on, required this.onTap});

  final bool on;
  final VoidCallback onTap;

  @override
  State<_Flash> createState() => _FlashState();
}

class _FlashState extends State<_Flash> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Спалах',
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _down ? 0.9 : 1,
          duration: CalviMotion.fast,
          curve: CalviMotion.ease,
          child: ClipOval(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                color: widget.on ? _ink : _chrome,
                child: CalviIcon('bolt', size: 18, color: widget.on ? _dark : _ink),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Shutter extends StatefulWidget {
  const _Shutter({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  State<_Shutter> createState() => _ShutterState();
}

class _ShutterState extends State<_Shutter> with SingleTickerProviderStateMixin {
  /* 16.36: a 900 ms cycle while the frame is being read. The control that
     started the wait is the one that shows it, so there is no spinner. */
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  bool _down = false;

  @override
  void didUpdateWidget(_Shutter old) {
    super.didUpdateWidget(old);
    if (widget.busy && !old.busy) {
      _pulse.repeat(reverse: true);
    } else if (!widget.busy && old.busy) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Зняти',
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 68,
          height: 68,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _ink.withValues(alpha: 0.9), width: 3),
          ),
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              final beat = Curves.easeInOut.transform(_pulse.value);
              final scale = widget.busy ? 1 - 0.2 * beat : (_down ? 0.86 : 1.0);
              return Opacity(
                opacity: widget.busy ? 1 - 0.4 * beat : 1.0,
                child: AnimatedScale(
                  scale: scale,
                  duration: widget.busy ? Duration.zero : CalviMotion.fast,
                  curve: CalviMotion.ease,
                  child: const SizedBox(
                    width: 54,
                    height: 54,
                    child: DecoratedBox(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: _ink),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Round extends StatefulWidget {
  const _Round({
    required this.icon,
    required this.label,
    required this.onTap,
    this.turn = false,
  });

  final String icon;
  final String label;
  final VoidCallback? onTap;

  /// The back arrow is the chevron turned around.
  final bool turn;

  @override
  State<_Round> createState() => _RoundState();
}

class _RoundState extends State<_Round> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final mark = CalviIcon(widget.icon, size: 18, color: _ink);
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _down ? 0.9 : 1,
          duration: CalviMotion.fast,
          curve: CalviMotion.ease,
          child: ClipOval(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                color: _chromeRound,
                child: widget.turn ? Transform.rotate(angle: 3.14159, child: mark) : mark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* What comes back differs by mode, and pretending otherwise would hide the one
   thing worth showing: a barcode hit costs nothing and is exact, a photo is an
   estimate and says so. */
class _Result extends StatelessWidget {
  const _Result({
    required this.mode,
    required this.slot,
    required this.onAgain,
    required this.onSend,
  });

  final CamMode mode;
  final String slot;
  final VoidCallback onAgain;
  final void Function(MsgKind, String?) onSend;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final found = mode == CamMode.barcode;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(CalviSize.rLarge),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.hairline,
                    borderRadius: BorderRadius.circular(CalviSize.rPill),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              if (found) ...[
                Text(demoBarcode, style: context.t.labelSmall?.copyWith(fontSize: 12)),
                const SizedBox(height: 4),
              ],
              Text(
                found ? 'Йогурт грецький 5%, 350 г' : 'Млинці з чорницею і медом',
                style: context.t.titleMedium?.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  text: found ? '231' : '~430',
                  children: [
                    TextSpan(
                      text: found ? ' ккал на 130 г' : ' ккал, оцінка',
                      style: context.t.labelSmall?.copyWith(fontSize: 14),
                    ),
                  ],
                ),
                style: context.t.headlineMedium,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final chip in found ? ['Б 12', 'Ж 8', 'В 14'] : ['Б 9', 'Ж 12', 'В 71'])
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: c.fillSecondary,
                          borderRadius: BorderRadius.circular(CalviSize.rPill),
                        ),
                        child: Text(chip, style: context.t.labelSmall?.copyWith(fontSize: 12)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                found
                    ? 'Склад із бази. Алергенів зі списку немає.'
                    : 'Порція на око. Скажи вагу або поправ словами, і я перерахую.',
                style: context.t.bodyMedium,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onAgain,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.fillSecondary,
                          borderRadius: BorderRadius.circular(CalviSize.rCard),
                        ),
                        child: Text(
                          'Ще раз',
                          style: context.t.titleMedium?.copyWith(fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: CalviButton(
                      label: 'Записати в $slot',
                      onTap: () => onSend(
                        found ? MsgKind.barcode : MsgKind.photo,
                        found ? demoBarcode : null,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
