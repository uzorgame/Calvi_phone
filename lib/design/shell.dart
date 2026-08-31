import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import 'icons.dart';
import 'theme.dart';
import 'tokens.dart';
import '../l10n/app_localizations.dart';

part 'shell_actions.dart';
part 'shell_rows.dart';

/// The frame every screen behind Today wears: a back arrow, a title, and the
/// same gutter as the day. The arrow sits on the left and nothing balances it on
/// the right except empty space, because a title that is not centred on a phone
/// reads as a mistake.
class CalviScreen extends StatefulWidget {
  const CalviScreen({
    super.key,
    required this.title,
    required this.children,
    this.onBack,
    this.trailing,
    this.hint,
    this.foot,
    this.padding = const EdgeInsets.only(bottom: 16),
    this.storageKey,
  });

  final String title;
  final List<Widget> children;

  /* Памʼять про те, де цей список був прогорнутий.
   *
   * Потрібна там, де екран зникає з дерева і повертається: налаштування
   * підміняють список панеллю, і список при цьому знищується разом зі своїм
   * контролером прокрутки. Без ключа Flutter не зберігає положення взагалі,
   * бо `PageStorage` пише тільки за `PageStorageKey`, і повернення щоразу
   * приземляло на початок.
   *
   * Не всім екранам це потрібно і не всім корисно: сторінка, відкрита наново,
   * має починатись згори, інакше документ відкривається посеред третього
   * абзацу. Тому за умовчанням памʼяті немає, і її просять окремо. */
  final PageStorageKey<String>? storageKey;

  /// Null pops the navigator, which is what almost every screen wants.
  final VoidCallback? onBack;
  final Widget? trailing;

  /// One sentence under the title saying what this screen is for.
  final String? hint;

  /// The action. It follows the content when the screen has room for it and
  /// holds the bottom when it does not, which is the demo's sticky footer: an
  /// action nailed to the bottom of a short screen floats away from the thing it
  /// acts on, and one that only scrolls is out of reach on a long one.
  final Widget? foot;

  final EdgeInsets padding;

  @override
  State<CalviScreen> createState() => _CalviScreenState();
}

class _CalviScreenState extends State<CalviScreen> {
  @override
  Widget build(BuildContext context) {
    final foot = widget.foot == null
        ? null
        : Container(
            padding: EdgeInsets.fromLTRB(
              CalviSize.gutter,
              18,
              CalviSize.gutter,
              6 + MediaQuery.paddingOf(context).bottom,
            ),
            /* The content scrolls under it, so it needs ground of its own, and
               the ground arrives as a fade rather than an edge. */
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [context.on.withValues(alpha: 0), context.on],
                stops: const [0, 0.26],
              ),
            ),
            child: widget.foot,
          );

    return Scaffold(
      /* Прозорий навмисно: під сторінкою лежить ґрунт, а суцільне тло
         Scaffold накрило б його рівним кольором і від «Вугілля» лишився б
         один тон. Непрозорість сторінки під час переходу дає CalviGround,
         а не це поле, тож нічого не просвічує. */
      backgroundColor: const Color(0x00000000),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              key: widget.storageKey,
              padding: widget.padding,
              children: [
                // The header scrolls with the page, the way the day's does.
                Padding(
                  padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 4, CalviSize.gutter, 18),
                  child: Row(
                    children: [
                      CalviBack(onTap: widget.onBack ?? () => Navigator.of(context).pop()),
                      Expanded(
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: context.t.headlineLarge?.copyWith(fontSize: 23),
                        ),
                      ),
                      SizedBox(width: 40, child: widget.trailing),
                    ],
                  ),
                ),
                if (widget.hint != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      CalviSize.gutter,
                      0,
                      CalviSize.gutter,
                      CalviSize.gapSection,
                    ),
                    child: Text(
                      widget.hint!,
                      // Looser than body text: this is a sentence to read, not
                      // a label to glance at.
                      style: context.t.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ),
                ...widget.children,
                /* The action's space stays in the flow so a long page can
                   scroll its last row clear of the button; the action itself
                   is drawn once, below. */
                if (foot != null)
                  Visibility(
                    visible: false,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: foot,
                  ),
              ],
            ),
            /* The action holds the bottom ALWAYS, short page or long.
             *
             * It used to follow the content when the screen had room, and that
             * quietly broke the oldest promise in this design. The veil under
             * the button dissolves into the flat page colour, and the whole
             * "theme reaches the bottom" fix rests on the ground being flat
             * where that veil lands. Pinned to the bottom, it lands in the
             * flat zone on every theme; following a short page's content, it
             * landed mid-screen, where coal is still a gradient and the new
             * grounds have their clouds, and cut a flat band straight across
             * both. On tall phones every short settings page showed it. */
            if (foot != null) Positioned(left: 0, right: 0, bottom: 0, child: foot),
          ],
        ),
      ),
    );
  }
}

/// Back, with a ring drawn once around it on arrival.
///
/// The ring is drawn rather than filled: it reads as the screen being outlined,
/// which is what a screen arriving on top of another is. It runs once and goes,
/// because a mark that stays is a mark somebody has to learn to ignore.
class CalviBack extends StatefulWidget {
  const CalviBack({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<CalviBack> createState() => _CalviBackState();
}

class _CalviBackState extends State<CalviBack> with SingleTickerProviderStateMixin {
  /* One controller for both the button arriving and the ring being drawn: the
     ring starts 120 ms in, so its slice is an interval of the same run. */
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _ringDelay + _ringMs),
  )..forward();

  bool _down = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    const total = _ringDelay + _ringMs;

    return Semantics(
      button: true,
      label: L.of(context).actionBack,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            final t = _c.value * total;
            // The two runs are separate in the demo, not one split in two.
            final arrive = CalviMotion.ease.transform((t / _inMs).clamp(0.0, 1.0));
            final ring = ((t - _ringDelay) / _ringMs).clamp(0.0, 1.0);

            return Opacity(
              opacity: arrive,
              child: Transform.translate(
                offset: Offset(-10 * (1 - arrive), 0),
                child: Transform.scale(
                  scale: 0.86 + 0.14 * arrive,
                  child: CustomPaint(
                    foregroundPainter: ring >= 1 ? null : _Ring(at: ring, colour: c.button),
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: AnimatedContainer(
            duration: CalviMotion.fast,
            curve: CalviMotion.ease,
            width: 40,
            height: 40,
            alignment: Alignment.center,
            /* Біла таблетка з тінню, як усі поверхні: на тонованому ґрунті
               сіре коло зливалося з ним. */
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _down ? c.hover : c.card,
              border: Border.all(color: c.cardBorder),
              boxShadow: context.shadowCard,
            ),
            // The arrow leans under the finger, in the direction the CSS sends
            // it: the shift is written inside the flipped frame.
            child: AnimatedSlide(
              duration: CalviMotion.fast,
              curve: CalviMotion.ease,
              offset: Offset(_down ? 0.15 : 0, 0),
              child: Transform.rotate(angle: math.pi, child: const CalviIcon('chevron', size: 20)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Додати, у шапці навпроти «Назад».
///
/// Та сама біла таблетка сорока пікселів, тільки приходить зі свого боку: ліва
/// кнопка виїжджає зліва, ця справа, і дві однакові кнопки не читаються як одна,
/// що роздвоїлась. Кільця тут немає навмисно: воно обводить екран, у який щойно
/// зайшли, а ця кнопка нікуди не веде, вона щось відкриває.
///
/// Напис читається вголос і на екрані його немає: у шапці стоїть плюс, і поруч
/// із назвою екрана слово було б зайвим.
class CalviAdd extends StatefulWidget {
  const CalviAdd({super.key, required this.onTap, required this.label});

  final VoidCallback onTap;
  final String label;

  @override
  State<CalviAdd> createState() => _CalviAddState();
}

class _CalviAddState extends State<CalviAdd> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _inMs),
  )..forward();

  bool _down = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            final arrive = CalviMotion.ease.transform(_c.value);
            return Opacity(
              opacity: arrive,
              child: Transform.translate(
                offset: Offset(10 * (1 - arrive), 0),
                child: Transform.scale(scale: 0.86 + 0.14 * arrive, child: child),
              ),
            );
          },
          child: AnimatedScale(
            duration: CalviMotion.fast,
            curve: CalviMotion.ease,
            scale: _down ? 0.92 : 1,
            child: AnimatedContainer(
              duration: CalviMotion.fast,
              curve: CalviMotion.ease,
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _down ? c.hover : c.card,
                border: Border.all(color: c.cardBorder),
                boxShadow: context.shadowCard,
              ),
              child: const CalviIcon('plus', size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

/// 16.13: the ring closes over 720 ms after a 120 ms wait, then fades.
const _ringMs = 720;

const _ringDelay = 120;

const _inMs = 420;

class _Ring extends CustomPainter {
  _Ring({required this.at, required this.colour});

  /// Zero to one across the ring's own run, before any easing.
  final double at;
  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    /* Two keyframe legs, each eased on its own the way CSS runs them: closed
       and half faded by seven tenths, gone by the end. */
    final double drawn;
    final double alpha;
    if (at < 0.7) {
      final k = CalviMotion.ease.transform(at / 0.7);
      drawn = k;
      alpha = 0.9 - 0.4 * k;
    } else {
      drawn = 1;
      alpha = 0.5 * (1 - CalviMotion.ease.transform((at - 0.7) / 0.3));
    }
    if (alpha <= 0) return;

    canvas.drawArc(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      -math.pi / 2,
      2 * math.pi * drawn,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = colour.withValues(alpha: alpha),
    );
  }

  @override
  bool shouldRepaint(_Ring old) => old.at != at || old.colour != colour;
}
