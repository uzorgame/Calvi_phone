import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../design/icons.dart';
import '../../design/theme.dart';
import 'level_source.dart';

/// Звідки збирається рідина і куди вона повертається.
class VoiceOrigin {
  const VoiceOrigin({required this.at, required this.size});

  /// Центр кнопки мікрофона, у координатах екрана.
  final Offset at;

  /// Її справжній діаметр: у нього збільшена кнопка повертається наприкінці.
  final double size;
}

/* Скільки смуг малює метр, і скільки крапель летить: це одне число.
 *
 * Одинадцять товстих, а не тридцять дві тонких. Тонкі під фільтром просто
 * зникають: розмиття розмазує їх нижче порога прозорості. Товщі смуги при
 * ширшому полі лишають між собою проміжок, удвічі більший за розмиття, тому
 * вони тягнуться одна до одної перетяжками, але не склеюються в суцільну масу. */
const _bars = 11;

/// Скільки крапель збирається довкола кнопки, перш ніж маса рушить.
const _beads = 7;

/// Ширина смуги і поле, у якому вона росте.
const _barW = 16.0;
const _barH = 140.0;

/// Ширина метра і його місце по висоті екрана.
const _meterW = 320.0;
const _meterAt = 0.47;

/// Діаметр збільшеної кнопки і крапель довкола неї.
const _micD = 74.0;
const _beadD = 18.0;

/* Висота смуги в спокої, часткою від її поля. Робить із неї коло: рівно таку
   краплю смуга і має, поки летить, і з неї ж вона росте. */
const _seed = _barW / _barH;

/// Коли рушає найперша крапля і наскільки пізніше за неї найкрайніша.
const _flyAt = 70.0;
const _flySpread = 130.0;
const _flyMs = 620.0;

/// Скільки збираються краплі довкола кнопки і скільки набрякає сама кнопка.
const _gatherMs = 520.0;

/// Наскільки раніше за посадку смуга починає рости, і скільки вона росте.
const _riseLead = 90.0;
const _riseMs = 280.0;

/// За скільки метр складається назад, коли палець прибрали.
const _foldMs = 200.0;

/// Коли і за скільки збільшена кнопка сідає у свій звичайний розмір.
const _homeAt = 400.0;
const _homeMs = 240.0;

/// Скільки триває зворотний шлях. Стільки, щоб кнопка встигла сісти.
const backMs = 660;

/// Розмиття і поріг, які роблять із крапель воду.
const _goo = 5.5;
const _sharpen = 17.0;
const _cut = 6.5;

/// Мʼякий початок і кінець: рідина не рушає і не спиняється ривком.
double _ease(double v) => v * v * (3 - 2 * v);

double _clamp(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

/// Наскільки смуга далеко від середини, від нуля до одиниці.
double _offMid(int i) => (i - (_bars - 1) / 2).abs() / ((_bars - 1) / 2);

/// Коли рушає крапля цієї смуги. Середні летять першими, крайні наздоганяють.
///
/// Дрібний доважок за парністю розводить сусідів, симетричних відносно
/// середини: без нього вони рушали б хвилина в хвилину і йшли б однією точкою,
/// тобто цівка була б удвічі коротшою, ніж могла б.
double _flyOf(int i) => _flyAt + _offMid(i) * _flySpread + (i.isOdd ? 18 : 0);

/// Крива польоту, та сама, що в демці.
const _flyCurve = Cubic(0.46, 0, 0.28, 1);
const _homeCurve = Cubic(0.42, 0, 0.4, 1);

/// Диктування, поки палець на кнопці.
///
/// Тримаєш і говориш, відпустив і сказане пішло. Тексту тут немає навмисне:
/// показувати слова, поки їх ніхто не розбирає, означало б показувати вигадку,
/// а розбір починається рівно тоді, коли палець прибрали.
///
/// **Рідина склеюється фільтром, а не намальована.** Кульки, що летять поруч,
/// лишаються кульками, скільки їх не додавай. Тут вони проходять крізь розмиття
/// і різкий поріг по прозорості, і те, що близько, зливається в одну масу з
/// перетяжкою між краплями, а те, що відірвалось, знову стає краплею. Це та сама
/// механіка, якою малюють ртуть.
///
/// **Метр і є ця рідина.** Не окрема анімація, яка починається після неї: кожна
/// смуга сама вилітає з кнопки краплею, летить своєю дорогою, сідає на своє
/// місце і звідти живе голосом. Передавати нема чого і нема кому, тому й мить
/// передачі не видно.
class VoiceOverlay extends StatefulWidget {
  const VoiceOverlay({
    super.key,
    required this.origin,
    required this.leaving,
    required this.onClosed,
    required this.source,
  });

  /// Звідки збирається рідина і куди вона повертається.
  final VoiceOrigin origin;

  /// Палець уже відпущено: рідина пливе назад, і після неї накладка гасне.
  final bool leaving;

  /// Зворотний шлях доїхав. Тільки після цього накладку можна знімати.
  final VoidCallback onClosed;

  /// Звідки метр бере гучність.
  final LevelSource source;

  @override
  State<VoiceOverlay> createState() => _VoiceOverlayState();
}

class _VoiceOverlayState extends State<VoiceOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(days: 1),
  )..forward();

  /* Кожна смуга тримає власну спадаючу стелю: звук підіймає її миттєво, а
     осідає вона за кілька кадрів. Інакше метр мерехтить. */
  final _peak = List<double>.filled(_bars, _seed);

  Duration _age = Duration.zero;

  /// Коли палець прибрали. Нуль означає «ще тримають».
  double _away = 0;

  /* Таймер знімається разом із накладкою.
   *
   * Відкладений виклик без нього переживає віджет: після зникнення екрана він
   * усе одно спрацьовує, і хай навіть його ловить перевірка на `mounted`, це
   * лишається таймером, який ніхто не зупиняв. */
  Timer? _closing;

  @override
  void initState() {
    super.initState();
    _clock.addListener(() {
      final now = _clock.lastElapsedDuration ?? Duration.zero;
      setState(() => _age = now);
    });
  }

  @override
  void didUpdateWidget(VoiceOverlay old) {
    super.didUpdateWidget(old);
    if (widget.leaving && !old.leaving) {
      _away = _age.inMilliseconds.toDouble();
      _closing = Timer(const Duration(milliseconds: backMs), () {
        if (mounted) widget.onClosed();
      });
    }
  }

  @override
  void dispose() {
    _closing?.cancel();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final age = _age.inMilliseconds.toDouble();
    final away = _away == 0 ? 0.0 : age - _away;

    _breathe(age, away);

    /* Кнопка живе своїм життям: набрякає при появі, тримається весь час, поки
       рідина в дорозі, і аж наприкінці сідає у свій звичайний розмір. Вона не
       зникає ні на мить, бо на ній лежить палець. */
    final micScale = away == 0
        ? _swell(age)
        : ui.lerpDouble(
            _swell(_away),
            widget.origin.size / _micD,
            _ease(_clamp((away - _homeAt) / _homeMs)),
          )!;

    /* Дотики поглинаються, а не пропускаються наскрізь.
     *
     * Тут стояв `IgnorePointer`, і крізь відкритий екран запису натискалось геть
     * усе, що під ним: розмита картка дня ловила дотик і відкривалась. Палець,
     * яким запис почали, це не зачіпає: він уже належить своїй кнопці, і
     * відпускання дійде до неї попри цей шар. */
    return AbsorbPointer(
      child: Stack(
        children: [
          /* День лишається позаду, поза фокусом: диктування це шар над ним, а не
             інше місце. Туман сходить швидше, ніж рідина встигає доїхати. */
          Positioned.fill(
            child: Opacity(
              opacity: away == 0 ? _clamp(age / 300) : 1 - _clamp((away - 40) / 280),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: ColoredBox(color: c.bg.withValues(alpha: 0.45)),
              ),
            ),
          ),

          /* Уся маса разом, і саме в цьому вся справа. Розмиття з різким порогом
             по прозорості склеює те, що поруч, в одну масу з перетяжкою між
             краплями, і рве її назад на краплі, щойно вони розійшлись. */
          Positioned.fill(
            child: _goo_(
              CustomPaint(
                size: Size.infinite,
                painter: _Liquid(
                  age: age,
                  away: away,
                  origin: widget.origin,
                  heights: _peak,
                  ink: c.button,
                ),
              ),
            ),
          ),

          /* Знак мікрофона поза фільтром: під ним він розплився б у пляму. */
          Positioned(
            left: widget.origin.at.dx - _micD / 2,
            top: widget.origin.at.dy - _micD / 2,
            width: _micD,
            height: _micD,
            child: Transform.scale(
              scale: micScale,
              child: Center(child: CalviIcon('mic', size: 26, color: c.buttonText)),
            ),
          ),
        ],
      ),
    );
  }

  /* Розмиття плюс різкий поріг по прозорості: те саме, що робив фільтр у демці.
     Те, що поруч, зливається в одну масу з перетяжкою між краплями, а те, що
     відірвалось, знову стає краплею. */
  Widget _goo_(Widget child) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        1, 0, 0, 0, 0, //
        0, 1, 0, 0, 0,
        0, 0, 1, 0, 0,
        0, 0, 0, _sharpen, -_cut * 255,
      ]),
      child: ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: _goo, sigmaY: _goo),
        child: child,
      ),
    );
  }

  /// Розмір кнопки при появі: набрякає вище, ніж осяде.
  double _swell(double age) {
    final t = _clamp(age / _gatherMs);
    return t < 0.4
        ? ui.lerpDouble(0.34, 1.06, _ease(t / 0.4))!
        : ui.lerpDouble(1.06, 0.92, _ease((t - 0.4) / 0.6))!;
  }

  /* Висота кожної смуги на цей кадр.
   *
   * Росте з краплі, а не з нуля, і в неї ж повертається: смуга вилітає з кнопки
   * вже краплею, і якби висота повзла від нуля, її просто не було б видно. */
  void _breathe(double age, double away) {
    final loud = widget.source.level(_age);

    for (var i = 0; i < _bars; i++) {
      final mid = 1 - _offMid(i);
      final shape = 0.62 + 0.38 * mid;
      final jitter = 0.7 + 0.3 * math.sin(age / 90 + i * 1.7);

      /* Метр дихає і в тиші. Хвиля, що біжить уздовж ряду, а не спільний
         рівень: спільний підіймав би всі смуги разом, і ряд лишався б рівним.
         Голос лягає поверх неї. */
      final calm =
          0.17 + 0.06 * math.sin(age / 620 + i * 0.62) + 0.03 * math.sin(age / 210 - i * 0.9);

      final rise = _clamp((age - (_flyOf(i) + _flyMs - _riseLead)) / _riseMs);
      final fold = away == 0 ? 0.0 : _clamp((away - (1 - _offMid(i)) * 90) / _foldMs);

      final voice = math.max(calm, loud * shape * jitter);
      final want = _seed + (voice - _seed) * _ease(rise) * (1 - _ease(fold));
      _peak[i] = want > _peak[i] ? want : _peak[i] * 0.82 + want * 0.18;
    }
  }
}

/// Малює всю масу: краплі довкола кнопки, саму кнопку і смуги в дорозі.
class _Liquid extends CustomPainter {
  const _Liquid({
    required this.age,
    required this.away,
    required this.origin,
    required this.heights,
    required this.ink,
  });

  final double age;
  final double away;
  final VoiceOrigin origin;
  final List<double> heights;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = ink;

    final meterW = math.min(_meterW, size.width - 40);
    final gap = (meterW - _bars * _barW) / (_bars - 1);
    final left = (size.width - meterW) / 2;
    final hub = Offset(size.width / 2, size.height * _meterAt);

    _beadsAround(canvas, paint);
    _theSeed(canvas, paint);

    for (var i = 0; i < _bars; i++) {
      final seat = Offset(left + i * (_barW + gap) + _barW / 2, hub.dy);
      _oneBar(canvas, paint, i, seat, hub);
    }
  }

  /* Вода збирається довкола кнопки, перш ніж рушити. Без цього маса зʼявлялась
     нізвідки, а так вона звідкись береться. */
  void _beadsAround(Canvas canvas, Paint paint) {
    for (var i = 0; i < _beads; i++) {
      final a = 2 * math.pi * i / _beads;
      final span = _gatherMs + (i % 3) * 40;

      double reach, scale;
      if (away == 0) {
        final t = _clamp(age / span);
        if (t < 0.38) {
          reach = ui.lerpDouble(6, 40, _ease(t / 0.38))!;
          scale = ui.lerpDouble(0.3, 1, _ease(t / 0.38))!;
        } else {
          reach = ui.lerpDouble(40, 12, _ease((t - 0.38) / 0.62))!;
          scale = ui.lerpDouble(1, 0.42, _ease((t - 0.38) / 0.62))!;
        }
      } else {
        // Осідають у кнопку разом з усім іншим.
        final t = _ease(_clamp(away / 240));
        reach = ui.lerpDouble(12, 0, t)!;
        scale = ui.lerpDouble(0.42, 0, t)!;
      }

      if (scale <= 0.01) continue;
      final at = origin.at + Offset(math.cos(a), math.sin(a)) * reach;
      _blob(canvas, paint, at, _beadD * scale, _beadD * scale, i * 1.7);
    }
  }

  /* Маса під кнопкою. Не зникає, поки рідина в дорозі: саме в неї вона й
     повертається, і аж потім кнопка сідає у свій розмір. */
  void _theSeed(Canvas canvas, Paint paint) {
    final double scale;
    if (away == 0) {
      final t = _clamp(age / _gatherMs);
      scale = t < 0.4
          ? ui.lerpDouble(0.34, 1.06, _ease(t / 0.4))!
          : ui.lerpDouble(1.06, 0.92, _ease((t - 0.4) / 0.6))!;
    } else {
      scale = ui.lerpDouble(0.92, origin.size / _micD, _ease(_clamp((away - _homeAt) / _homeMs)))!;
    }
    _blob(canvas, paint, origin.at, _micD * scale, _micD * scale, 0);
  }

  /* Смуга сама вилітає з кнопки краплею, летить своєю дорогою і сідає на своє
     місце. Окремих крапель немає навмисне: доти між ними була мить передачі, і
     на ній було видно, що це дві різні анімації. */
  void _oneBar(Canvas canvas, Paint paint, int i, Offset seat, Offset hub) {
    /* Перша опора виводить краплю з кнопки вгору, друга збирає всі дороги над
       серединою метра, і вже звідти кожна розходиться у своє місце. Тому рідина
       злітає одним тілом і розпливається вздовж метра, замість збиратись у
       точку. */
    final c1 = Offset(
      origin.at.dx + (hub.dx - origin.at.dx) * 0.12,
      origin.at.dy + (hub.dy - origin.at.dy) * 0.34,
    );
    final c2 = Offset(hub.dx + (seat.dx - hub.dx) * 0.1, hub.dy - 20);

    final double t;
    final double wide, tall;
    if (away == 0) {
      t = _flyCurve.transform(_clamp((age - _flyOf(i)) / _flyMs));
      // У дорозі крапля більша за себе саму і витягнута вздовж підйому: саме це
      // робить цівку товстою і суцільною.
      (wide, tall) = _stretch(t);
    } else {
      final back = _homeCurve.transform(_clamp((away - (_bars - 1 - i) * 8) / 320));
      t = 1 - back;
      (wide, tall) = _stretch(1 - back * 0.86);
    }

    final at = _onRoad(origin.at, c1, c2, seat, t);
    final h = _barH * heights[i] * tall;
    _blob(canvas, paint, at, _barW * wide, math.max(_barW * wide, h), i * 0.9);
  }

  /// Кадри розтягу в дорозі, ті самі числа, що в демці.
  (double, double) _stretch(double t) {
    if (t < 0.22) return (ui.lerpDouble(0.7, 1.5, t / 0.22)!, ui.lerpDouble(0.7, 2.4, t / 0.22)!);
    if (t < 0.6) {
      final k = (t - 0.22) / 0.38;
      return (ui.lerpDouble(1.5, 1.3, k)!, ui.lerpDouble(2.4, 1.9, k)!);
    }
    if (t < 0.84) {
      final k = (t - 0.6) / 0.24;
      return (ui.lerpDouble(1.3, 1.14, k)!, ui.lerpDouble(1.9, 1.3, k)!);
    }
    final k = (t - 0.84) / 0.16;
    return (ui.lerpDouble(1.14, 1, k)!, ui.lerpDouble(1.3, 1, k)!);
  }

  /// Точка на кубічній кривій.
  Offset _onRoad(Offset a, Offset b, Offset c, Offset d, double t) {
    final u = 1 - t;
    return a * (u * u * u) + b * (3 * u * u * t) + c * (3 * u * t * t) + d * (t * t * t);
  }

  /* Одне тіло з трохи неправильними краями.
   *
   * Радіуси кутів повільно перетікають, і кожне тіло має свою фазу: рівний овал
   * читається як намальована фігура, а жива вода не буває симетричною. Рух
   * рівномірний навмисне: мʼякий вхід і вихід спиняли б форму на кожному кадрі,
   * і це читалось би як сіпання. */
  void _blob(Canvas canvas, Paint paint, Offset at, double w, double h, double phase) {
    if (w <= 0.5 || h <= 0.5) return;

    final s = age / 1000;
    double r(double k) => 0.5 + 0.045 * math.sin(s / 1.6 + phase + k);

    final box = Rect.fromCenter(center: at, width: w, height: h);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        box,
        topLeft: Radius.elliptical(w * r(0), h * r(1.9)),
        topRight: Radius.elliptical(w * r(3.1), h * r(0.7)),
        bottomRight: Radius.elliptical(w * r(4.4), h * r(2.6)),
        bottomLeft: Radius.elliptical(w * r(1.2), h * r(5.0)),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_Liquid old) => true;
}
