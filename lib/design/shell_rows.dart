part of 'shell.dart';

/* Рядки і вибори набору: нотатки, секції, ряди, перемикачі, сегменти.
 *
 * Фізично окремий файл, але та сама бібліотека shell: приватні помічники
 * спільні, а екрани як імпортували shell.dart, так і імпортують. У самому
 * shell.dart лишився каркас сторінки, тут живе все, з чого складаються
 * списки. */

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
