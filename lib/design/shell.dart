import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'icons.dart';
import 'theme.dart';
import 'tokens.dart';
import '../l10n/app_localizations.dart';

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

/// The sentence under a control that explains what the number means.
class CalviNote extends StatelessWidget {
  const CalviNote(this.text, {super.key, this.lead = 0}) : bold = null, rest = null;

  /// A note with one run standing out of the sentence, for the figure it is
  /// about: the demo's `<b>` inside a note.
  const CalviNote.rich(
    this.text, {
    super.key,
    required this.bold,
    required this.rest,
    this.lead = 0,
  });

  final String text;
  final String? bold;
  final String? rest;

  /// The gap above. Nothing after a block, which already leaves a section gap
  /// below it, and twelve when the note follows a card or a control inside one.
  final double lead;

  /// The note's own type, for the places that lay a note out themselves.
  static TextStyle? styleOf(BuildContext context) =>
      context.t.labelSmall?.copyWith(fontWeight: FontWeight.w400, height: 1.5);

  @override
  Widget build(BuildContext context) {
    final style = styleOf(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(CalviSize.gutter, lead, CalviSize.gutter, 0),
      child: bold == null
          ? Text(text, style: style)
          : Text.rich(
              TextSpan(
                text: text,
                children: [
                  TextSpan(
                    text: bold,
                    style: TextStyle(color: context.c.text, fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: rest),
                ],
              ),
              style: style,
            ),
    );
  }
}

/// A card of plain «label, value» lines.
class CalviFacts extends StatelessWidget {
  const CalviFacts({
    super.key,
    required this.rows,
    this.note,
    this.noteBold,
    this.noteRest,
    this.inset = true,
  });

  final List<(String, String)> rows;
  final String? note;

  /// A run of the note standing out of the sentence, and what follows it.
  final String? noteBold;
  final String? noteRest;

  /// Off inside a block, which already stands the card at the gutter.
  final bool inset;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      // No gap of its own below: what follows carries its own, the way the
      // demo's card does.
      padding: EdgeInsets.symmetric(horizontal: inset ? CalviSize.gutter : 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: c.card,
          border: Border.all(color: c.cardBorder),
          borderRadius: BorderRadius.circular(CalviSize.rLarge),
          boxShadow: context.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (label, value) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: LayoutBuilder(
                  builder: (context, box) => Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      /* Значення має стелю ширини, а не половину рядка.
                     *
                     * Рядок у Flex дає нерозтяжній дитині безмежну ширину, тому
                     * довге значення не переносилось, а вилазило за край: на
                     * вузькому телефоні з великим системним шрифтом замість
                     * картки був смугастий бар переповнення. Ділити рядок
                     * навпіл теж не можна: тоді «24 жовтня 2026» переносилось
                     * би там, де місця вистачало. Тому стеля, як у рядках
                     * налаштувань: значення бере скільки треба, але не більше
                     * двох третин. */
                      Expanded(child: Text(label, style: context.t.bodyMedium)),
                      const SizedBox(width: 10),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: box.maxWidth * 0.78),
                        child: Text(
                          value,
                          textAlign: TextAlign.right,
                          style: context.t.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (note != null)
              Container(
                // Nothing to be ruled off when the card is the sentence itself.
                margin: EdgeInsets.only(top: rows.isEmpty ? 0 : 14),
                padding: EdgeInsets.only(top: rows.isEmpty ? 0 : 13),
                decoration: rows.isEmpty
                    ? null
                    : BoxDecoration(
                        border: Border(top: BorderSide(color: c.cardBorder)),
                      ),
                child: Text.rich(
                  TextSpan(
                    text: note,
                    children: [
                      if (noteBold != null)
                        TextSpan(
                          text: noteBold,
                          style: TextStyle(color: c.text, fontWeight: FontWeight.w600),
                        ),
                      if (noteRest != null) TextSpan(text: noteRest),
                    ],
                  ),
                  style: context.t.bodyMedium?.copyWith(height: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The checkbox that gates a decision nobody should make by accident.
class CalviCheck extends StatelessWidget {
  const CalviCheck({super.key, required this.on, required this.onToggle, required this.text});

  final bool on;
  final VoidCallback onToggle;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CalviSize.gutter, vertical: 8),
      child: GestureDetector(
        onTap: onToggle,
        behavior: HitTestBehavior.opaque,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: CalviMotion.fast,
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: on ? c.button : const Color(0x00000000),
                border: Border.all(color: on ? c.button : c.hairline, width: 2),
              ),
              child: on ? CalviIcon('check', size: 12, color: c.buttonText) : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: context.t.bodyMedium)),
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

/// A titled group of rows.
class CalviSection extends StatelessWidget {
  const CalviSection({
    super.key,
    this.title,
    this.aside,
    this.bare = false,
    this.note,
    this.trail = 10,
    required this.children,
  });

  /// A group can go without a title: some hold one card and need no label.
  final String? title;

  /// The figure that answers the title, on the right of the same line.
  final String? aside;

  /// The children draw their own grounds, so the group must not draw one round
  /// them: options are separate cards, and a card of cards is a slab.
  final bool bare;

  /// A sentence under the card but inside the group, so the section gap stands
  /// under the note rather than between a card and its own explanation.
  final String? note;

  /// What the last bare child already leaves under itself. Options carry ten,
  /// a card carries nothing, and the demo's section gap swallows whichever it
  /// is rather than standing on top of it.
  final double trail;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* Body-sized and sentence case, the way the demo writes them: «Про
             тебе», not a shouted caps label. */
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(child: Text(title!, style: context.t.titleMedium)),
                  if (aside != null) Text(aside!, style: context.t.bodyMedium),
                ],
              ),
            ),
          // A title on its own is allowed: some groups are headings over a card
          // that draws itself, and an empty bordered box would be a hole.
          if (bare)
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children)
          else if (children.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: context.c.card,
                border: Border.all(color: context.c.cardBorder),
                borderRadius: BorderRadius.circular(CalviSize.rLarge),
                boxShadow: context.shadowCard,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(children: children),
            ),
          // Inside the group, so it takes the gutter the group already stands at.
          if (note != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(note!, style: CalviNote.styleOf(context)),
            ),
          SizedBox(
            height: bare && note == null
                ? CalviSize.gapSection - trail
                : children.isEmpty && !bare
                ? 0
                : CalviSize.gapSection,
          ),
        ],
      ),
    );
  }
}

/// One row of a section. Every row opens something: a row that leads nowhere
/// teaches people to stop tapping rows.
class CalviRow extends StatelessWidget {
  const CalviRow({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
    this.danger = false,
    this.trailing,
    this.first = false,
    this.hint,
  });

  final String icon;
  final String title;
  final String? value;

  /// A line under the title, for a row whose switch needs saying what it does.
  final String? hint;
  final VoidCallback? onTap;
  final bool danger;

  /// Replaces the chevron, for rows that carry a switch instead of a screen.
  final Widget? trailing;

  /// The top row of a group carries no hairline above it.
  final bool first;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final ink = danger ? c.protein : c.text;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          // Hairlines between rows are the card border, same as the demo.
          border: first ? null : Border(top: BorderSide(color: c.cardBorder)),
        ),
        child: LayoutBuilder(
          builder: (context, box) {
            /* The value takes what the title does not need, and the title gives
               way when there is not enough for both. Splitting the line equally
               left the value stranded mid-row with the right third empty; giving
               the value no ceiling pushed the title out of the row entirely on
               the one setting with a long answer. Measuring the title is what
               the browser does for `flex: 1 1 auto` beside `flex: 0 0 auto`. */
            final room = box.maxWidth - 34 - 12 - 12 - 16;
            final titleStyle = context.t.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: ink,
            );
            final measure = TextPainter(
              text: TextSpan(text: title, style: titleStyle),
              textDirection: TextDirection.ltr,
              maxLines: 1,
            )..layout();
            /* Its own width, capped at three fifths of the row: past that the
               value has nowhere left to go, and a title is easier to guess from
               half a word than a figure is. */
            final forTitle = math.min(measure.width, room * 0.6);

            return Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c.iconCircle),
                  child: CalviIcon(icon, size: 19, color: ink),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: hint == null
                      ? Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: titleStyle)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: titleStyle),
                            const SizedBox(height: 2),
                            Text(
                              hint!,
                              style: context.t.labelSmall?.copyWith(fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                ),
                if (value != null)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: room - forTitle),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        value!,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.t.labelSmall?.copyWith(fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                trailing ?? CalviIcon('chevron', size: 16, color: c.faint),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The switch, in this app's ink rather than the platform's.
class CalviSwitch extends StatelessWidget {
  const CalviSwitch({super.key, required this.on, required this.onChanged});

  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: () => onChanged(!on),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: CalviMotion.fast,
        curve: CalviMotion.ease,
        width: 46,
        height: 28,
        padding: const EdgeInsets.all(3),
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: on ? c.button : c.track,
          borderRadius: BorderRadius.circular(CalviSize.rPill),
        ),
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(shape: BoxShape.circle, color: on ? c.buttonText : c.card),
        ),
      ),
    );
  }
}

/// A choice in a list: title, hint, and a mark on the chosen one.
class CalviChoice extends StatelessWidget {
  const CalviChoice({
    super.key,
    required this.title,
    required this.hint,
    required this.chosen,
    required this.onTap,
    this.icon,
    this.first = false,
  });

  final String title;
  final String hint;
  final bool chosen;
  final VoidCallback onTap;
  final String? icon;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          border: first ? null : Border(top: BorderSide(color: c.hairline)),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: c.iconCircle),
                child: CalviIcon(icon!, size: 17),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.t.bodyLarge?.copyWith(fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(hint, style: context.t.labelSmall),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: CalviMotion.normal,
              curve: CalviMotion.ease,
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: chosen ? c.button : const Color(0x00000000),
                border: Border.all(color: chosen ? c.button : c.hairline, width: 1.5),
              ),
              child: AnimatedScale(
                scale: chosen ? 1 : 0,
                duration: CalviMotion.normal,
                curve: CalviMotion.ease,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c.card),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One option as a card of its own: the demo's .pick.
///
/// Chosen is white and outlined rather than filled: these are choices among
/// equals, and filling one black would make it read as the screen's action.
class CalviPick extends StatelessWidget {
  const CalviPick({
    super.key,
    required this.label,
    this.hint,
    this.icon,
    required this.on,
    required this.onTap,
  });

  final String label;
  final String? hint;
  final String? icon;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: CalviMotion.normal,
          curve: CalviMotion.ease,
          /* Chosen is white and outlined rather than filled: the row is a choice
             among equals, and filling it black would make it read as the
             screen's action. The padding gives back what the border takes. */
          padding: EdgeInsets.symmetric(horizontal: on ? 15 : 16, vertical: on ? 13 : 14),
          decoration: BoxDecoration(
            color: on ? c.bg : c.hover,
            border: Border.all(color: on ? c.button : c.cardBorder, width: on ? 2 : 1),
            borderRadius: BorderRadius.circular(CalviSize.rLarge),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c.iconCircle),
                  child: CalviIcon(icon!, size: 19),
                ),
                const SizedBox(width: 13),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: context.t.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        letterSpacing: CalviSize.fsBody * -0.02,
                      ),
                    ),
                    /* Порожній рядок це не підказка. Без цієї перевірки картка
                       без підказки малювала порожній текст із відступом, і
                       назва стояла не по центру, а трохи вище. */
                    if (hint != null && hint!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        hint!,
                        style: context.t.labelSmall?.copyWith(fontWeight: FontWeight.w400),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 13),
              _PickDot(on: on),
            ],
          ),
        ),
      ),
    );
  }
}

/// The radio of a [_Card]: a ring that fills, with a dot that grows inside it.
class _PickDot extends StatelessWidget {
  const _PickDot({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AnimatedContainer(
      duration: CalviMotion.normal,
      curve: CalviMotion.ease,
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: on ? c.button : const Color(0x00000000),
        border: Border.all(color: on ? c.button : c.hairline, width: 1.5),
      ),
      child: AnimatedScale(
        scale: on ? 1 : 0,
        duration: CalviMotion.normal,
        curve: CalviMotion.ease,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: c.bg),
        ),
      ),
    );
  }
}

/// The wide button at the foot of a screen: the demo's .primary.
///
/// 56 tall, a pill, body-size semibold, and it gives 3% under the finger.
class CalviButton extends StatefulWidget {
  const CalviButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.danger = false,
    this.second,
    this.onSecond,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool danger;

  /* The way out, under the action rather than beside it. Beside it, two filled
     buttons compete for the same glance; under it, plain text, the refusal is
     available without being offered. */
  final String? second;
  final VoidCallback? onSecond;

  @override
  State<CalviButton> createState() => _CalviButtonState();
}

class _CalviButtonState extends State<CalviButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final fill = !widget.enabled
        ? c.buttonDisabled
        : widget.danger
        ? c.protein
        : c.button;

    final button = GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _down && widget.enabled ? 0.97 : 1,
        duration: CalviMotion.fast,
        curve: CalviMotion.ease,
        child: Container(
          height: CalviSize.buttonH,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(CalviSize.rPill),
            /* Головна дія має вагу: тінь свого ж кольору. Вимкнена її не
               кидає, бо натиснути її зараз не можна. */
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: fill.withValues(alpha: 0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: context.t.titleMedium?.copyWith(fontSize: CalviSize.fsBody, color: c.buttonText),
          ),
        ),
      ),
    );

    if (widget.second == null) return button;
    return Column(
      children: [
        button,
        const SizedBox(height: 4),
        GestureDetector(
          onTap: widget.onSecond,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: Text(
              widget.second!,
              style: context.t.bodyLarge?.copyWith(color: c.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}

/// Modal sheet that rises from the bottom.
///
/// A sheet that only tells you something needs one way out, not two buttons
/// that do the same thing, so [info] drops the cancel.
Future<T?> calviSheet<T>(
  BuildContext context, {
  required String title,
  required Widget Function(BuildContext) builder,

  /// Напис на кнопці згоди. Порожньо означає «Готово» мовою застосунку.
  String? doneLabel,
  bool info = false,
  VoidCallback? onDone,

  /// Кнопка згоди стоїть унизу на всю ширину, а не словом у кутку.
  ///
  /// Для форм, які людина заповнює зверху вниз: рішення приймається в кінці
  /// шляху, і саме там на нього має чекати кнопка, під великим пальцем.
  /// Дрібним словом у кутку лишається те, що кутка й заслуговує: коліщатко
  /// годинника, з якого виходять одним дотиком.
  bool footDone = false,

  /* Згода руйнівна: нижня кнопка червона, а скасування другою повною кнопкою
     під нею, і кутове слово зникає. Два дрібні слова обабіч заголовка
     зливаються з ним у рядок, а дві повні кнопки читаються без вгадування. */
  bool danger = false,
}) {
  /* 340 ms на кривій підйому, як у кожної іншої панелі, що приходить.
   *
   * Свій контролер це єдиний спосіб задати аркушу тривалість, але за нього
   * доводиться і прибирати: Flutter звільняє лише той, що зробив сам, а
   * принесений ззовні лишає жити. Кожне відкриття аркуша лишало по одному
   * тікеру на навігаторі, і за сеанс їх набиралися сотні.
   *
   * Звільняється тоді, коли аркуш опустився до кінця, а не коли його закрили:
   * закриття це початок зворотного шляху, і контролер потрібен ще всю його
   * довжину. Мікрозадача тому, що прибирати слухача зсередини нього самого
   * означає рвати список, яким Flutter саме йде. */
  final rise = AnimationController(
    vsync: Navigator.of(context),
    duration: const Duration(milliseconds: 340),
    reverseDuration: CalviMotion.normal,
  );
  rise.addStatusListener((state) {
    if (state == AnimationStatus.dismissed) scheduleMicrotask(rise.dispose);
  });

  return showModalBottomSheet<T>(
    context: context,
    transitionAnimationController: rise,
    backgroundColor: const Color(0x00000000),
    barrierColor: context.c.text.withValues(alpha: 0.34),
    isScrollControlled: true,
    builder: (sheetContext) {
      final c = sheetContext.c;
      /* Аркуш заходить у краї екрана, скруглений тільки згори.
       *
       * Тут був відступ у вісім пікселів з усіх боків, і аркуш висів карткою:
       * знизу й по боках проглядало затемнене тло. Аркуш, що приходить знизу,
       * має впиратись у край, інакше він читається як вікно поверх екрана, а не
       * як продовження екрана. */
      /* Стеля висоти живе тут, а не в кожній формі окремо.
       *
       * Аркуш це картка знизу, і три чверті екрана це вже його межа: вище він
       * читається як повноекранне вікно, і затемнений день за ним зникає.
       * Форма всередині прокручується, тому впиратись у стелю їй не боляче.
       * Доти правило трималось на тому, що вміст випадково влазив, і кнопка
       * згоди внизу його порушила. */
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.75),
        child: CalviOn(
          // Усе всередині лежить на аркуші, а не на сторінці. Див. [CalviOn].
          color: c.card,
          child: Container(
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(CalviSize.rLarge)),
            ),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: c.hairline,
                        borderRadius: BorderRadius.circular(CalviSize.rPill),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 84,
                          child: info || (footDone && danger)
                              ? null
                              : GestureDetector(
                                  onTap: () => Navigator.of(sheetContext).pop(),
                                  behavior: HitTestBehavior.opaque,
                                  child: Text(
                                    L.of(context).actionCancel,
                                    style: sheetContext.t.labelSmall?.copyWith(fontSize: 14),
                                  ),
                                ),
                        ),
                        Expanded(
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: sheetContext.t.titleMedium,
                          ),
                        ),
                        SizedBox(
                          width: 84,
                          child: footDone
                              ? null
                              : GestureDetector(
                                  onTap: () {
                                    onDone?.call();
                                    Navigator.of(sheetContext).pop();
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Text(
                                    doneLabel ?? L.of(sheetContext).actionDone,
                                    textAlign: TextAlign.right,
                                    style: sheetContext.t.titleMedium?.copyWith(fontSize: 14),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(child: builder(sheetContext)),
                  if (footDone)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 18, CalviSize.gutter, 4),
                      child: CalviButton(
                        label: doneLabel ?? L.of(sheetContext).actionDone,
                        danger: danger,
                        second: danger ? L.of(sheetContext).actionCancel : null,
                        onSecond: danger ? () => Navigator.of(sheetContext).pop() : null,
                        onTap: () {
                          onDone?.call();
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// A row of states with the mark sliding between them.
///
/// One widget for two options and for four: the choice is one thing moving, not
/// several things toggling, and three hand-rolled copies of that idea drift into
/// three slightly different animations.
class CalviSegments extends StatelessWidget {
  const CalviSegments({
    super.key,
    required this.labels,
    required this.index,
    required this.onPick,
    /* Four of the demo's pills: 4 of padding, a 9/9 button around a 13px line.
       Anything shorter and the thumb reads as a chip sitting in a bar. */
    this.height = 43,
    this.cell,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onPick;
  final double height;

  /// Fixed width per segment, which makes the bar scroll instead of squeezing.
  ///
  /// Four periods share the width of the screen; eight measurements cannot, and
  /// a segment whose cells resize as the labels change is a segment whose thumb
  /// never lands where the eye expects it.
  final double? cell;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return LayoutBuilder(
      builder: (context, box) {
        final w = cell ?? (box.maxWidth - 8) / labels.length;
        final bar = SizedBox(
          height: height,
          width: cell == null ? null : w * labels.length + 8,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    /* The groove the thumb runs in, so the three options read as
                       one control. It was `fillSecondary` on the page ground,
                       one step of 255 apart, so only the thumb was ever visible
                       and the unchosen options sat on bare page. */
                    color: c.track,
                    borderRadius: BorderRadius.circular(CalviSize.rPill),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: CalviMotion.easeRise,
                left: 4 + w * index,
                top: 4,
                bottom: 4,
                width: w,
                child: DecoratedBox(
                  /* Картка, а не ґрунт: відколи сторінка тонована, бігунок на
                     `bg` зливався б із жолобом, у якому їздить. */
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(CalviSize.rPill),
                    boxShadow: context.shadowCard,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    for (final (i, l) in labels.indexed)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onPick(i),
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Text(
                              l,
                              maxLines: 1,
                              style: context.t.labelSmall?.copyWith(
                                fontWeight: i == index ? FontWeight.w600 : FontWeight.w400,
                                color: i == index ? c.text : c.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );

        // A bar wider than the screen is dragged rather than crushed.
        return cell == null
            ? bar
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: bar,
              );
      },
    );
  }
}

/// Nora saying something, in a card of her own.
///
/// Every empty state in this app is her speaking, never a grey «немає даних».
/// The border matters: without it the words read as a caption belonging to
/// whatever is above them, and with it they read as somebody talking.
class CalviNora extends StatelessWidget {
  const CalviNora({super.key, required this.text, this.hint});

  final String text;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(16),
      // Порожній стан це теж картка: біла поверхня на тонованому ґрунті.
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: c.cardBorder),
        borderRadius: BorderRadius.circular(CalviSize.rLarge),
        boxShadow: context.shadowCard,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c.button),
            child: Text(
              'N',
              style: context.t.titleMedium?.copyWith(
                fontSize: CalviSize.fsCaption,
                fontWeight: FontWeight.w700,
                color: c.buttonText,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: context.t.bodyMedium?.copyWith(
                    fontSize: CalviSize.fsCaption,
                    height: 1.45,
                    color: c.text,
                  ),
                ),
                if (hint != null) ...[
                  const SizedBox(height: 6),
                  Text(hint!, style: context.t.labelSmall?.copyWith(fontSize: CalviSize.fsMicro)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A press that answers the moment the finger lands.
///
/// Flutter's tap recognisers wait to win the gesture arena before they report a
/// press, and inside a scrolling list that wait is long enough that a quick tap
/// shows nothing at all. The demo's `:active` fires on pointer down with no
/// arena to win, so the visual state is taken straight from the raw pointer and
/// only the tap itself is left to the recogniser.
class CalviPress extends StatefulWidget {
  const CalviPress({super.key, required this.onTap, required this.builder, this.onLongPress});

  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  /// Called with true while a finger is on it.
  final Widget Function(BuildContext context, bool down) builder;

  @override
  State<CalviPress> createState() => _CalviPressState();
}

class _CalviPressState extends State<CalviPress> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => _set(true),
    onPointerUp: (_) => _set(false),
    onPointerCancel: (_) => _set(false),
    child: GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      behavior: HitTestBehavior.opaque,
      child: widget.builder(context, _down),
    ),
  );
}
