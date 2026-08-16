import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design/icons.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';

/// The shell every card of the day wears.
///
/// Meals, water, training and the tape are different things inside, but the day
/// reads as one list only if they open the same way and carry their figure in
/// the same corner. The shell owns that; each card owns only its contents.
class SlotCard extends StatelessWidget {
  const SlotCard({
    super.key,
    required this.icon,
    required this.title,
    required this.sub,
    required this.badge,
    required this.open,
    required this.onToggle,
    required this.child,
  });

  final String icon;
  final String title;

  /// The quiet line under the title: how much is in the card, in words.
  final String sub;

  /// The card's figure, in the pill on the right.
  final String badge;

  final bool open;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: c.cardBorder),
        borderRadius: BorderRadius.circular(CalviSize.rLarge),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: c.iconCircle),
                    child: CalviIcon(icon, size: 19),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: context.t.titleMedium),
                        const SizedBox(height: 2),
                        Text(sub, style: context.t.labelSmall),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: c.fillSecondary,
                      borderRadius: BorderRadius.circular(CalviSize.rPill),
                    ),
                    child: Text(
                      badge,
                      style: context.t.titleMedium?.copyWith(fontSize: CalviSize.fsMicro),
                    ),
                  ),
                  const SizedBox(width: 8),
                  /* Down when shut, up when open: the arrow says which way a
                     tap will move the fold, not where the content went. */
                  AnimatedRotation(
                    turns: open ? -0.25 : 0.25,
                    duration: CalviMotion.normal,
                    curve: CalviMotion.ease,
                    child: CalviIcon('chevron', size: 16, color: c.textSecondary),
                  ),
                ],
              ),
            ),
          ),

          /* Opening takes longer than closing: opening is an invitation, closing
             is a decision already made, and a slow one reads as stuck. */
          AnimatedSize(
            duration: open
                ? const Duration(milliseconds: 440)
                : const Duration(milliseconds: 220),
            curve: open ? CalviMotion.easeRise : CalviMotion.easeIn,
            alignment: Alignment.topCenter,
            child: open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    /* The contents lift into place a beat behind the height, so
                       the card unfolds instead of simply becoming taller. */
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: 1),
                      duration: const Duration(milliseconds: 420),
                      curve: const Interval(0.14, 1, curve: CalviMotion.easeRise),
                      builder: (context, t, inner) => Opacity(
                        opacity: t,
                        child: Transform.translate(
                          offset: Offset(0, -10 * (1 - t)),
                          child: inner,
                        ),
                      ),
                      child: child,
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// The row that adds something to a card: a plus, and what it adds.
class AddRow extends StatelessWidget {
  const AddRow({super.key, required this.label, required this.open, required this.onTap});

  final String label;

  /// Open rows offer to fold instead, so the mark says which way the tap goes.
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          border: Border.all(color: c.hairline),
          borderRadius: BorderRadius.circular(CalviSize.rCard),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.iconCircle),
              child: CalviIcon(open ? 'minus' : 'plus', size: 17),
            ),
            const SizedBox(width: 13),
            Text(label, style: context.t.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

/// The per-card way in.
///
/// The bar at the bottom of the screen is the main one and it already knows the
/// card; this field exists for the moment you are looking straight at the card
/// you mean, and it saves the step of saying which one.
class SlotInput extends StatefulWidget {
  const SlotInput({super.key, required this.onSend});

  final ValueChanged<String> onSend;

  @override
  State<SlotInput> createState() => _SlotInputState();
}

class _SlotInputState extends State<SlotInput> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _send() {
    final t = _text.text.trim();
    if (t.isEmpty) return;
    HapticFeedback.selectionClick();
    widget.onSend(t);
    _text.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final ready = _text.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: c.fillSecondary,
                border: Border.all(color: c.cardBorder),
                borderRadius: BorderRadius.circular(CalviSize.rCard),
              ),
              child: TextField(
                controller: _text,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _send(),
                textInputAction: TextInputAction.send,
                maxLength: 120,
                style: context.t.bodyLarge?.copyWith(fontSize: 15),
                decoration: InputDecoration(
                  isDense: true,
                  counterText: '',
                  border: InputBorder.none,
                  /* No card name and no verb: «на вечеря» needs the accusative
                     and «що ти їв» needs a gender. Both are traps in a field the
                     app fills in for itself, and the card above already says
                     which meal this is. */
                  hintText: 'Напиши, що було',
                  hintStyle: context.t.labelSmall?.copyWith(fontSize: 15),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: 'Записати',
            child: GestureDetector(
              onTap: ready ? _send : null,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: CalviMotion.fast,
                curve: CalviMotion.ease,
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(CalviSize.rCard),
                  color: ready ? c.button : c.buttonDisabled,
                ),
                child: CalviIcon(
                  'plus',
                  size: 17,
                  color: ready ? c.buttonText : c.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
