import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'icons.dart';
import 'theme.dart';
import 'tokens.dart';

/// The frame every screen behind Today wears: a back arrow, a title, and the
/// same gutter as the day. The arrow sits on the left and nothing balances it on
/// the right except empty space, because a title that is not centred on a phone
/// reads as a mistake.
class CalviScreen extends StatelessWidget {
  const CalviScreen({
    super.key,
    required this.title,
    required this.children,
    this.onBack,
    this.trailing,
    this.hint,
    this.foot,
    this.padding = const EdgeInsets.only(bottom: 32),
  });

  final String title;
  final List<Widget> children;

  /// Null pops the navigator, which is what almost every screen wants.
  final VoidCallback? onBack;
  final Widget? trailing;

  /// One sentence under the title saying what this screen is for.
  final String? hint;

  /// The action, pinned to the bottom rather than scrolling away with the
  /// content: it is the point of the screen and has to be reachable by thumb.
  final Widget? foot;

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 4, CalviSize.gutter, 14),
              child: Row(
                children: [
                  CalviBack(onTap: onBack ?? () => Navigator.of(context).pop()),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: context.t.headlineLarge?.copyWith(fontSize: 19),
                    ),
                  ),
                  SizedBox(width: 40, child: trailing),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: padding,
                children: [
                  if (hint != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        CalviSize.gutter + 4,
                        0,
                        CalviSize.gutter + 4,
                        6,
                      ),
                      child: Text(hint!, style: context.t.bodyMedium),
                    ),
                  ...children,
                ],
              ),
            ),
            if (foot != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  CalviSize.gutter,
                  10,
                  CalviSize.gutter,
                  12 + MediaQuery.paddingOf(context).bottom,
                ),
                child: foot,
              ),
          ],
        ),
      ),
    );
  }
}

/// The sentence under a control that explains what the number means.
class CalviNote extends StatelessWidget {
  const CalviNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(CalviSize.gutter + 4, 2, CalviSize.gutter + 4, 16),
    child: Text(text, style: context.t.bodyMedium),
  );
}

/// A card of plain «label — value» lines.
class CalviFacts extends StatelessWidget {
  const CalviFacts({super.key, required this.rows, this.note});

  final List<(String, String)> rows;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.card,
          border: Border.all(color: c.cardBorder),
          borderRadius: BorderRadius.circular(CalviSize.rLarge),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (label, value) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Expanded(child: Text(label, style: context.t.bodyMedium)),
                    Text(value, style: context.t.titleMedium?.copyWith(fontSize: 15)),
                  ],
                ),
              ),
            if (note != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 10),
                child: Divider(height: 1, color: c.hairline),
              ),
              Text(note!, style: context.t.bodyMedium),
            ],
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
      padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 14),
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
      label: 'Назад',
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _down ? c.hover : c.fillSecondary,
            ),
            // The arrow leans under the finger, in the direction the CSS sends
            // it: the shift is written inside the flipped frame.
            child: AnimatedSlide(
              duration: CalviMotion.fast,
              curve: CalviMotion.ease,
              offset: Offset(_down ? 0.15 : 0, 0),
              child: Transform.rotate(
                angle: math.pi,
                child: const CalviIcon('chevron', size: 20),
              ),
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
  const CalviSection({super.key, required this.title, this.aside, required this.children});

  final String title;

  /// The figure that answers the title, on the right of the same line.
  final String? aside;
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
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(child: Text(title, style: context.t.titleMedium)),
                if (aside != null) Text(aside!, style: context.t.bodyMedium),
              ],
            ),
          ),
          // A title on its own is allowed: some groups are headings over a card
          // that draws itself, and an empty bordered box would be a hole.
          if (children.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: context.c.card,
                border: Border.all(color: context.c.cardBorder),
                borderRadius: BorderRadius.circular(CalviSize.rLarge),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(children: children),
            ),
          SizedBox(height: children.isEmpty ? 0 : CalviSize.gapSection),
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
  });

  final String icon;
  final String title;
  final String? value;
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
            /* The value is sized by its own text and sits against the chevron,
               taking whatever the title does not need. Splitting the line
               equally left it stranded mid-row with the right third empty;
               letting it size itself with no ceiling pushed the title out of
               the row entirely on the one setting with a long answer. */
            final room = box.maxWidth - 34 - 12 - 12 - 16;
            const forTitle = 96.0;

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
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.t.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: ink,
                    ),
                  ),
                ),
                if (value != null)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: math.max(room - forTitle, room * 0.4)),
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
              duration: CalviMotion.fast,
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: chosen ? c.button : const Color(0x00000000),
                border: Border.all(color: chosen ? c.button : c.hairline, width: 2),
              ),
              child: chosen ? CalviIcon('check', size: 12, color: c.buttonText) : null,
            ),
          ],
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
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool danger;

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

    return GestureDetector(
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
          ),
          child: Text(
            widget.label,
            style: context.t.titleMedium?.copyWith(
              fontSize: CalviSize.fsBody,
              color: c.buttonText,
            ),
          ),
        ),
      ),
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
  String doneLabel = 'Готово',
  bool info = false,
  VoidCallback? onDone,
}) {
  return showModalBottomSheet<T>(
    context: context,
    // 340 ms on the rise curve, the same as every other panel that arrives.
    transitionAnimationController: AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 340),
      reverseDuration: CalviMotion.normal,
    ),
    backgroundColor: const Color(0x00000000),
    barrierColor: context.c.text.withValues(alpha: 0.34),
    isScrollControlled: true,
    builder: (sheetContext) {
      final c = sheetContext.c;
      return Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(CalviSize.rLarge),
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
                      child: info
                          ? null
                          : GestureDetector(
                              onTap: () => Navigator.of(sheetContext).pop(),
                              behavior: HitTestBehavior.opaque,
                              child: Text(
                                'Скасувати',
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
                      child: GestureDetector(
                        onTap: () {
                          onDone?.call();
                          Navigator.of(sheetContext).pop();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          doneLabel,
                          textAlign: TextAlign.right,
                          style: sheetContext.t.titleMedium?.copyWith(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(child: builder(sheetContext)),
              const SizedBox(height: 8),
            ],
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
    this.height = 40,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onPick;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return LayoutBuilder(
      builder: (context, box) {
        final w = (box.maxWidth - 8) / labels.length;
        return SizedBox(
          height: height,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.fillSecondary,
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
                  decoration: BoxDecoration(
                    color: c.bg,
                    borderRadius: BorderRadius.circular(CalviSize.rPill),
                    boxShadow: const [
                      BoxShadow(color: Color(0x1F000000), blurRadius: 3, offset: Offset(0, 1)),
                    ],
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
      decoration: BoxDecoration(
        border: Border.all(color: c.cardBorder),
        borderRadius: BorderRadius.circular(CalviSize.rLarge),
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
                  Text(
                    hint!,
                    style: context.t.labelSmall?.copyWith(fontSize: CalviSize.fsMicro),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
