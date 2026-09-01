import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/day.dart';
import '../../format.dart';
import '../../data/app_scope.dart';
import '../../data/settings.dart';
import '../../data/week.dart';
import '../../design/ring.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../l10n/app_localizations.dart';

/// The day's main card, one side at a time.
///
/// **It is a physical object that turns.** Calories do not fade into weight:
/// the side in front leaves upward and the other rises to take its place. A
/// cross-fade would say the two figures are alternatives; a turn says they are
/// two sides of one card.
///
/// **Every step goes the same way.** On the first the front leaves and the back
/// rises; on the second the roles swap, so the back leaves and the front rises
/// from below. Without that the deck reverses on every other step: pull up twice
/// and the card comes back down. The two sides trade directions at the halfway
/// mark, where both are invisible, so the swap is never seen.
///
/// The motion is driven frame by frame from one continuous position, so a card
/// thrown by hand and a card that turned by itself move identically.
class HeroCard extends StatefulWidget {
  const HeroCard({
    super.key,
    required this.day,
    required this.burned,
    required this.goal,
    required this.week,
    required this.onWeek,
  });

  final DayModel day;

  /// What this day is measured against, as the settings currently have it.
  final DayGoal goal;

  /// Calories the day gave back. Passed in because a session logged during the
  /// session is not in the fixture the day was built from.
  final int burned;

  /// Зведений тиждень для третьої сторони. Приходить готовим, бо його ж читає
  /// сторінка тижня: два підрахунки одного тижня розійшлись би.
  final WeekSummary week;

  /// Дотик по стороні тижня. Відкриває сторінку тижневої аналітики.
  final VoidCallback onWeek;

  @override
  State<HeroCard> createState() => _HeroCardState();
}

/// Calories hold the card; weight and the week take it for a moment now and
/// then. Long enough that the card is never mid-turn when the eye arrives: a
/// figure that swaps while it is being read is a figure that has to be read
/// twice.
const _holds = [Duration(seconds: 16), Duration(seconds: 7), Duration(seconds: 7)];

/// How far a side travels while it leaves or arrives.
const _lift = 26.0;

/// A drag has to cross this much of a step before the release finishes it.
const _throw = 0.18;

/// Нижче цього палець не крутив, а натиснув.
const _tap = 0.03;

/* Скільки сторін у колоди: калорії, вага, тиждень. Уся арифметика повороту
   рахується від цього числа, а не від двійки в десятку місць. */
const _sides = 3;

class _HeroCardState extends State<HeroCard>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  /* Built here rather than lazily: the deck no longer reads the controller while
     it paints, so a card that was never turned would have created it for the
     first time inside dispose, where there is no ticker to hang it on. */
  late final AnimationController _c;

  /// Where the deck stands, continuously, for the two faces to read.
  final _turn = ValueNotifier<double>(0);

  /* Пише завжди, і останній кадр теж.
   *
   * Тут стояла охорона «якщо не анімується, вийти», і вона мовчки з'їдала
   * останній кадр повороту: контролер зупиняє себе до того, як розсилає
   * повідомлення. Потреби в ній немає відтоді, як `_origin` і `_target`
   * ставляться до обнулення контролера: поштовх від обнулення тепер пише те
   * саме місце, де колода й стоїть. */
  void _paint() {
    _turn.value = _origin + (_target - _origin) * Curves.easeOutQuart.transform(_c.value);
  }

  /// Continuous position. Whole numbers are the resting states.
  double _pos = 0;
  double _held = 0;
  double? _from;

  /// Звідки палець почав крутити: місце колоди на початку жесту, а не остання
  /// сторона спокою. Після перерваного дольоту це різні числа.
  double _base = 0;

  int get _side => _pos.round() % _sides;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this)..addListener(_paint);
    // Щоб дізнатись, що застосунок згортають: поворот має скінчитись до того.
    WidgetsBinding.instance.addObserver(this);
    _wait();
  }

  /* Застосунок згортають, і колода має стояти на цілій стороні.
   *
   * Поки застосунок попереду, поворот триває пів секунди й закінчується сам.
   * Щойно він іде у фон, кадри припиняються, і поворот, який саме йшов,
   * застигає посередині: обидві сторони видно одночасно, число калорій крізь
   * число ваги. Саме таким застосунок і потрапляє в перелік недавніх, бо
   * система знімає його в цю мить. Тому колода сідає негайно, без анімації.
   *
   * А годинник заводиться в кінці в будь-якому разі, і це головне.
   *
   * Спершу він тут гасився, а заводився назад тільки на `resumed`. Виглядало
   * симетрично, а насправді ні: `inactive` Android надсилає в геть буденних
   * ситуаціях, від шторки сповіщень до системного вікна поверх застосунку, і
   * `resumed` після нього приходить не завжди. Один такий випадок, і колода
   * більше не поверталась ніколи до перезапуску. Годинник, який не може
   * згаснути, коштує одного таймера і знімає цілий клас таких випадків. */
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _c.stop();
      _from = null;
      _held = 0;

      final side = (_turn.value.round() % _sides).toDouble();
      if (side != _pos) setState(() => _pos = side);
      _turn.value = side;
    }

    _wait();
  }

  /* The clock stops while the card is in hand: a turn that started by itself
     would snatch the card out from under the finger.
     A Timer and not a delayed future, because this one has to be cancellable:
     a sixteen second wait that outlives the screen is a screen still running
     after it is gone. */
  Timer? _clock;
  void _wait() {
    _clock?.cancel();
    _clock = Timer(_holds[_side], () {
      if (!mounted) return;
      /* Палець на картці: поворот чекає, але годинник заводиться на нове коло.
         Доти цей вихід нічого не заводив, і якщо шторку сповіщень смикнули
         посеред перетягування, колода лишалась стояти назавжди. */
      if (_from != null) {
        _wait();
        return;
      }
      /* Гасити годинник у фоні не потрібно, і навіть шкідливо. Поворот, який
         почався без кадрів, стоїть на самому своєму початку, тобто на цілій
         стороні, і доїде тоді, коли кадри повернуться. А ось вимикач, який
         вмикається назад тільки на `resumed`, це той самий спосіб загубити
         годинник назавжди, від якого ми щойно пішли. */
      _glide(_pos.roundToDouble() + 1);
    });
  }

  void _glide(double to) {
    final from = _pos;
    final span = to - from;
    if (span == 0) {
      /* Їхати нікуди, але годинник має цокати далі. Без цього рядка колода,
         яку легенько зачепили пальцем і відпустили на тому самому місці,
         більше не поверталась ніколи: годинник гасився на початку дотику, а
         завести його назад мав кінець повороту, якого не було. */
      _wait();
      return;
    }

    _c
      ..stop()
      ..duration = const Duration(milliseconds: 520)
      ..removeStatusListener(_landed)
      ..addStatusListener(_landed);

    /* Спершу куди і звідки, а вже потім обнулення. Обнулення розсилає
       повідомлення слухачам, і при зворотному порядку воно писало місце з
       попереднього повороту: колода смикалась на першому ж кадрі. */
    _target = to;
    _origin = from;
    _c.value = 0;
    _c.forward();
  }

  double _target = 0;
  double _origin = 0;

  void _landed(AnimationStatus s) {
    if (s != AnimationStatus.completed) return;
    // Folded back so the counter cannot grow without bound.
    setState(() => _pos = (_target % _sides + _sides) % _sides);
    _turn.value = _pos;
    _wait();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clock?.cancel();
    _c.dispose();
    _turn.dispose();
    super.dispose();
  }

  /// Where a given side sits at any point of the turn.
  ///
  /// Обраний з галереї демки «Стос», перенесений формулою один в один:
  /// прогорнута сторона йде вгору і тане, наступна піднімається знизу їй услід.
  ///
  /// Рахується відстань від місця колоди до цієї сторони, по колу і в
  /// найкоротший бік. Знак виходить із неї сам: сторона, яку вже пройшли,
  /// поїхала вгору, а та, до якої йдемо, чекає знизу. Стара версія тримала
  /// по окремому виразу на кожну сторону, і вони домовлялись міняти напрямок
  /// посередині кроку; третю сторону в таку домовленість не вставиш, а сюди
  /// вона додасться самою константою [_sides].
  ({Offset shift, double scale, double opacity}) _face(int index, double pos) {
    var rel = (pos - index) % _sides;
    if (rel > _sides / 2) rel -= _sides;

    final off = rel.abs().clamp(0.0, 1.0);
    return (
      shift: Offset(0, -_lift * rel),
      scale: 1 - 0.14 * off,
      opacity: (1 - off).clamp(0.0, 1.0),
    );
  }

  /// Puts the deck back on a whole side, whether the finger let go or the page
  /// pulled the gesture out from under it.
  ///
  /// Приземлення рахується від того місця, де колода реально є, а не від
  /// останньої сторони спокою: після перерваного дольоту вони розходяться.
  /// Кидок у межах кроку доводить розпочатий крок до кінця; рух через кілька
  /// сторін сідає на найближчу попереду.
  void _settle() {
    if (_from == null) return;
    final over = _held;
    final p = _turn.value;
    _from = null;
    _held = 0;
    _pos = p;

    /* Дотик без руху це не поворот, а натискання.
     *
     * Сторона береться з місця колоди, а не зі стану спокою: після перерваного
     * дольоту вони можуть розходитись, і тоді відкривався б тиждень із
     * картки, на якій стоять калорії. */
    if (over.abs() < _tap) {
      final showing = (p.round() % _sides + _sides) % _sides;
      _glide(p.roundToDouble());
      if (showing == 2) widget.onWeek();
      return;
    }

    _glide(
      over > _throw
          ? (p - 0.000001).ceilToDouble()
          : over < -_throw
          ? (p + 0.000001).floorToDouble()
          : p.roundToDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    /* Built once per real change and handed to the builder below as a child, so
       the faces are the same widgets from frame to frame and the framework skips
       their subtrees entirely while the deck turns. */
    final faces = <Widget>[
      _Kcal(day: widget.day, burned: widget.burned, goal: widget.goal),
      const _Weight(),
      _Week(summary: widget.week, onOpen: widget.onWeek),
    ];

    /* The faces share one box, and a system font scale the phone sets can
       push the taller of them past it: what spills is clipped, and a clipped
       card reads as a card that vanished. The figures here are already large,
       so the scale is allowed a little room and no more. */
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.15,
      child: GestureDetector(
        /* Чистий тап це окремий жест, і двері тижня відчиняє саме він.
         *
         * Розпізнавач перетягування відпускає палець, який нікуди не рушив, і
         * не шле жодного зворотного виклику. Гілка «майже не посунув» у
         * _settle ловить лише палець, що зрушив колоду і повернув, тож тап по
         * пілюлі «Тижнева аналітика» не робив нічого. */
        onTap: () {
          if ((_turn.value.round() % _sides + _sides) % _sides == 2) widget.onWeek();
        },
        // The card takes the vertical drag itself. It is a small target on a long
        // page, so the scroll it costs is cheap.
        onVerticalDragStart: (d) {
          _c.stop();
          _clock?.cancel();
          _from = d.localPosition.dy;
          /* Жест підхоплює колоду там, де вона є, як рука підхоплює барабан,
             що ще крутиться.

             Тут ховалась причина «кручу і викидає назад». Малювалось від
             `_pos`, останньої сторони спокою, а `_c.stop()` заморожував колоду
             посеред дольоту: доліт стояв десь на 1.7, а палець продовжував від
             одиниці, і картка стрибала назад на цілий крок. Кожен швидкий рух
             з'їдав попередній. */
          _base = _turn.value;
          _held = 0;
        },
        onVerticalDragUpdate: (d) {
          if (_from == null) return;
          /* Up carries the far side away, the way a deck shuffles under a thumb.

             Без обмеження дальності: тут стояв затиск на пів кроку, і далі
             однієї сторони за один рух прокрутити було не можна, колода
             впиралась у невидиму стіну. Один довгий рух тепер веде через
             скільки завгодно сторін. */
          _held = (_from! - d.localPosition.dy) * 1.1 / 180;
          _turn.value = _base + _held;
        },
        onVerticalDragEnd: (_) => _settle(),
        /* The page can take the gesture away mid-drag, and when it does there is
         no end event. Without this the deck stayed wherever the finger left it,
         which on a half turn is a card standing edge on: invisible. */
        onVerticalDragCancel: _settle,
        child: ValueListenableBuilder<double>(
          valueListenable: _turn,
          /* Калорії в потоці, решта розтягнуті по них: висоту колоди задає
             найвища сторона, і поки вона на місці, картка не може схлопнутись
             до нуля посеред повороту.

             Найвища саме вона, і не випадково: у неї найдовший рядок під
             числом і чіп тренування на додачу. Тиждень зумисне нижчий, бо його
             головне це шкала, а не цифра. Якщо колись інша сторона переросте
             калорії, її обріже, і смугастий попереджувач скаже про це першим
             же прогоном тестів: мовчки це не станеться. */
          builder: (context, pos, _) => Stack(
            children: [
              _Side(face: _face(0, pos), child: faces[0]),
              for (var i = 1; i < _sides; i++)
                Positioned.fill(
                  child: _Side(face: _face(i, pos), child: faces[i]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({required this.face, required this.child});

  final ({Offset shift, double scale, double opacity}) face;
  final Widget child;

  Offset get shift => face.shift;
  double get scale => face.scale;
  double get opacity => face.opacity;

  @override
  Widget build(BuildContext context) {
    /* An invisible side still holds the card open. The front one is what the
       stack measures itself by, so returning nothing for it once it faded out
       collapsed the card to no height at all, and the weight side, stretched to
       fill that, went with it: the card vanished the moment it finished turning
       to kilograms. Opacity zero already skips the painting; the layout is the
       part that has to stay. */
    return IgnorePointer(
      ignoring: opacity <= 0.01,
      child: Transform.translate(
        offset: shift,
        child: Transform.scale(
          scale: scale,
          child: Opacity(opacity: opacity, child: child),
        ),
      ),
    );
  }
}

/// The card itself. Both sides are whole cards, border and all: turning only the
/// contents inside a frame that stays put reads as a panel flipping in a window.
class _Shell extends StatelessWidget {
  const _Shell({required this.left, required this.ring, required this.dot});

  final Widget left;
  final Widget ring;

  /// Which of the dots in the corner is lit.
  final int dot;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(22),
      constraints: const BoxConstraints(minHeight: 132),
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: c.cardBorder),
        borderRadius: BorderRadius.circular(CalviSize.rLarge),
        boxShadow: context.shadowCard,
      ),
      child: Stack(
        /* The dots sit in the card's own padding, which is outside this stack:
           the stack clips by default, and clipping is what has been eating them.
           A card that turns by itself and never said it had another side reads
           as a glitch the first time it happens. */
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              Expanded(child: left),
              const SizedBox(width: 14),
              ring,
            ],
          ),
          // Dots, so the card says it has other sides before anyone pulls it:
          // one that turns by itself and never said so reads as a glitch.
          Positioned(
            right: -8,
            bottom: -12,
            child: Row(
              children: [
                for (var i = 0; i < _sides; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  _Dot(on: dot == i),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 5,
    height: 5,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.c.text.withValues(alpha: on ? 0.5 : 0.14),
      ),
    ),
  );
}

/// Overshoot at which the ring is fully red: a third past the norm.
const _heat = 0.33;

class _Kcal extends StatelessWidget {
  const _Kcal({required this.day, required this.burned, required this.goal});

  final DayModel day;
  final int burned;
  final DayGoal goal;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    /* Нетто: зʼїдене мінус спалене. Норма стоїть на місці, а тренування
       зменшує зараховане, а не піднімає ціль. Доти було навпаки, і підпис казав
       «з 2 628» при нормі 2 220: число цілі пливло щодня. */
    final eaten = day.totals.kcal - burned;
    final left = goal.kcal - eaten;
    final progress = (eaten < 0 ? 0 : eaten) / goal.kcal;

    /* Серія рахується з тих самих підсумків, що малюють тиждень і аналітику, а
       не тримається окремим числом. Без області це нуль: показати вигадану
       серію гірше, ніж не показати жодної. */
    final scope = AppScope.maybeOf(context);
    final streak = scope == null ? 0 : scope.stats.streakOn(scope.s);

    /* Up to the norm the arc measures how much of the day is spent. Past it
       there is nothing left to measure, so it fills and starts to heat: full red
       a third over, and the saturation builds, so eighty extra calories look
       like eighty rather than like a catastrophe. */
    final heat = ((progress - 1) / _heat).clamp(0.0, 1.0);
    final ink = Color.lerp(c.button, c.protein, heat)!;

    return _Shell(
      dot: 0,
      /* Числа набігають до нових значень, а не стрибають на них.
       *
       * Записана страва це подія, і картка дня має показати її рухом. Кільце
       * поруч уже їде до нової довжини само, тож без цього число і дуга
       * рухались урізнобій: одне вже на місці, друга ще в дорозі. Тривалість і
       * крива тут ті самі, що в кільця, тому вони приходять разом.
       *
       * Перше значення показується як є: тween без початку не рухається на
       * першій побудові, і лічильник не крутиться на кожному вході в день. */
      left: TweenAnimationBuilder<double>(
        tween: Tween(end: eaten.toDouble()),
        duration: const Duration(milliseconds: 620),
        curve: CalviMotion.easeRise,
        builder: (context, value, _) {
          final shownEaten = value.round();
          final shownLeft = goal.kcal - shownEaten;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              /* Великим числом стоїть зʼїдене, а не залишок.
           *
           * Людина відкриває застосунок, щоб побачити, скільки вона вже зʼїла, і
           * саме це число шукає очима першим. Залишок це висновок із нього, і
           * він доречний рядком нижче. До того ж залишок буває відʼємним, і
           * найбільша цифра на екрані переставала означати те, що означала
           * вранці. */
              Text.rich(
                TextSpan(
                  text: thousands(shownEaten),
                  children: [
                    TextSpan(
                      text: L.of(context).heroKcal,
                      style: context.t.bodyMedium?.copyWith(fontSize: 17),
                    ),
                  ],
                ),
                style: context.t.displayLarge?.copyWith(height: 1),
              ),
              const SizedBox(height: 7),
              Text.rich(
                TextSpan(
                  children: [
                    if (left >= 0) ...[
                      TextSpan(text: L.of(context).heroLeft),
                      TextSpan(
                        text: thousands(shownLeft),
                        style: TextStyle(color: c.text, fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: L.of(context).heroOf(thousands(goal.kcal))),
                    ] else ...[
                      TextSpan(text: L.of(context).heroOver),
                      TextSpan(
                        text: thousands(shownLeft.abs()),
                        style: TextStyle(color: c.protein, fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: L.of(context).heroFrom(thousands(goal.kcal))),
                    ],
                  ],
                ),
                style: context.t.bodyMedium?.copyWith(height: 1.5),
              ),
              /* Спалене чіпом, а не словами в рядку.
           *
           * Мінус, бо тренування спалило калорії. Число пояснює себе саме:
           * «-310 спалено» лишало питання, звідки воно взялось, а «за
           * тренування» відповідає на нього і показує, чому велике число
           * менше за суму страв у картках. */
              if (burned > 0) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: c.success.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(CalviSize.rPill),
                  ),
                  child: Text(
                    L.of(context).heroBurned(burned),
                    style: context.t.labelSmall?.copyWith(
                      color: c.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      ring: CalviRing(
        progress: progress,
        color: ink,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$streak',
              style: context.t.headlineMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 24 * -0.02,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              L.of(context).heroDays,
              style: context.t.labelSmall?.copyWith(
                fontSize: 9,
                letterSpacing: 9 * 0.04,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Третя сторона: тиждень.
///
/// **Шкала, а не смужка прогресу.** Зелене посередині, червоне по обох краях:
/// погано в обидва боки, і триматися треба середини. Ліворуч з'їжджає той, хто
/// недоїдає, праворуч той, хто переїдає. Смужка прогресу сказала б «більше
/// краще», а це неправда про калорії.
///
/// **Кільце тут не про норму, а про час.** Це тижневий годинник: наповнюється
/// потроху від понеділка до неділі, о 23:59 неділі повний, а з понеділка
/// починається наново. Усередині стоїть день тижня, і це єдине, що там
/// доречно: скільки зафарбовано, той і день, тож кільце читає себе вголос.
///
/// Дотик відкриває сторінку тижня. Про це каже пілюля під шкалою: сторона з
/// дверима, яка про них мовчить, це двері, яких ніхто не знайде.
class _Week extends StatelessWidget {
  const _Week({required this.summary, required this.onOpen});

  final WeekSummary summary;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    /* Позначка стоїть за тим самим вікном, що фарбує кружечки: середня третина
       шкали це вікно цілі, червоне тільки поза ним. Шкала зі своєю мірою
       казала «недобір» тижню із самих зелених днів. */
    final direction = AppScope.maybeOf(context)?.s.direction ?? Direction.lose;
    final k = summary.meterOn(direction);

    return _Shell(
      dot: 2,
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          /* Число тут менше, ніж на сусідніх сторонах, і навмисно.
           *
           * Головне на цій стороні не цифра, а шкала: середнє за тиждень саме
           * по собі мало що каже, а от де воно стоїть між недобором і
           * перебором, каже все. Тому число віддає зріст тому, що його
           * пояснює, і сторона перестає бути на ряд вищою за решту колоди. */
          Text.rich(
            TextSpan(
              text: thousands(summary.avgKcal),
              children: [
                TextSpan(
                  text: L.of(context).heroKcal,
                  style: context.t.bodyMedium?.copyWith(fontSize: 15),
                ),
              ],
            ),
            style: context.t.headlineLarge?.copyWith(fontSize: 30, height: 1),
          ),
          const SizedBox(height: 12),
          _Meter(at: k),
          const SizedBox(height: 10),
          /* Пілюля, а не сірий рядок зі стрілкою: рядок читався як підпис, і
             те, що картка кудись веде, лишалось таємницею крапок у кутку. */
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: c.fillSecondary,
              borderRadius: BorderRadius.circular(CalviSize.rPill),
            ),
            child: Text(
              L.of(context).heroWeekOpen,
              style: context.t.labelSmall?.copyWith(color: c.text, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      ring: CalviRing(
        progress: weekRun(),
        child: Text(
          // Той самий підпис дня, що під стовпчиками тижня і в стрічці дат:
          // одна назва понеділка на застосунок, а не дві.
          dayInfo(todayDate).label,
          style: context.t.headlineMedium?.copyWith(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            letterSpacing: 19 * 0.02,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// Шкала недобору і перебору: зелене посередині, червоне по краях.
class _Meter extends StatelessWidget {
  const _Meter({required this.at});

  /// Де стоїть позначка, від -1 (глибокий недобір) до 1 (глибокий перебір).
  final double at;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    // Одна смуга з двома полюсами, а не три кольорові зони.
    final edge = Color.lerp(c.track, c.protein, 0.34)!;
    final mid = Color.lerp(c.track, c.success, 0.38)!;

    return SizedBox(
      width: 190,
      height: 13,
      child: Stack(
        alignment: Alignment.centerLeft,
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(CalviSize.rPill),
              gradient: LinearGradient(
                colors: [edge, mid, mid, edge],
                stops: const [0, 0.42, 0.58, 1],
              ),
            ),
          ),
          // Риска норми: без неї середина шкали лише малась на увазі.
          Positioned(
            left: 190 / 2,
            top: -2,
            bottom: -2,
            child: SizedBox(width: 1, child: ColoredBox(color: c.hairline)),
          ),
          Positioned(
            left: 190 * (0.5 + at * 0.5) - 6.5,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.button,
                border: Border.all(color: c.card, width: 2.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Weight extends StatelessWidget {
  const _Weight();

  @override
  Widget build(BuildContext context) {
    /* The person's own figures, not the fixtures. A weight set in settings and a
       card still showing the one the fixtures were written with are two answers
       to the same question. */
    final s = AppScope.of(context).s;

    /* Measured from where the goal started, not from the oldest reading: the
       ring shows progress on this goal, and a weight from before it was set has
       nothing to do with it. */
    // Працює в обидва боки: схуднення і набір це та сама відстань, пройдена в
    // різні сторони.
    final done = goalProgress(s);

    return _Shell(
      dot: 1,
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              text: s.weightKg.toStringAsFixed(1),
              children: [TextSpan(text: L.of(context).heroKg, style: context.t.headlineLarge)],
            ),
            style: context.t.displayLarge?.copyWith(height: 1),
          ),
          const SizedBox(height: 6),
          Text(
            L.of(context).heroWeightFrom(s.goalStartKg.toStringAsFixed(1)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.t.bodyMedium?.copyWith(height: 1.25),
          ),
        ],
      ),
      ring: CalviRing(
        progress: done,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              s.targetKg.toStringAsFixed(0),
              style: context.t.headlineMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 24 * -0.02,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              L.of(context).heroGoalKg,
              style: context.t.labelSmall?.copyWith(
                fontSize: 9,
                letterSpacing: 9 * 0.04,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
