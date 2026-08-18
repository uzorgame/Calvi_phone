import 'package:flutter/material.dart';

import '../../format.dart';
import '../../design/icons.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import 'slot_card.dart';

/// One tap is one hundred millilitres.
const waterStep = 100;

/// Water.
///
/// The card counts in glasses in its subtitle and in millilitres everywhere a
/// number is set against the norm: nobody drinks 1400 millilitres, they drink
/// about six glasses, but a norm has to be a number.
class WaterCard extends StatelessWidget {
  const WaterCard({
    super.key,
    required this.ml,
    required this.goalMl,
    required this.onChange,
    required this.open,
    required this.onToggle,
  });

  final int ml;

  /// The daily target, which follows the weight and so is not a constant.
  final int goalMl;
  final ValueChanged<int> onChange;
  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final pct = (ml / goalMl * 100).round();
    final glasses = (ml / 250).round();

    return SlotCard(
      icon: 'drink',
      title: 'Вода',
      sub: glasses == 0 ? 'нічого не випито' : 'близько $glasses склянок',
      badge: '${thousands(ml)} мл',
      open: open,
      onToggle: onToggle,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
        child: Row(
          children: [
            _Step(
              icon: 'minus',
              label: 'Менше на $waterStep мл',
              onTap: () => onChange((ml - waterStep).clamp(0, 1 << 30)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                children: [
                  Text.rich(
                    TextSpan(
                      text: thousands(ml),
                      children: [
                        TextSpan(
                          text: ' / ${thousands(goalMl)} мл',
                          style: context.t.labelSmall?.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                    style: context.t.headlineMedium?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 24 * -0.02,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(CalviSize.rPill),
                    child: SizedBox(
                      height: 6,
                      /* Full width, said out loud. A stack sizes itself by its
                         unpositioned children, and the fill is one of those: at
                         forty per cent the whole bar came out forty per cent
                         wide and sat centred, with no track to either side. */
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Positioned.fill(child: ColoredBox(color: c.fillSecondary)),
                          // Grows on its own track rather than jumping: a bar that
                          // snaps reads as a redraw, not as water going in.
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (pct / 100).clamp(0.0, 1.0),
                            // Without this the fill has no height to take: a
                            // Stack hands out loose constraints and a coloured
                            // box with no child shrinks to nothing.
                            heightFactor: 1,
                            child: AnimatedContainer(
                              duration: CalviMotion.normal,
                              curve: CalviMotion.ease,
                              color: c.fats,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('$pct% денної цілі', style: context.t.labelSmall),
                ],
              ),
            ),
            const SizedBox(width: 14),
            _Step(
              icon: 'plus',
              label: 'Більше на $waterStep мл',
              onTap: () => onChange(ml + waterStep),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.label, required this.onTap});

  final String icon;

  /// A mark on its own says nothing out loud, so the step carries its own words.
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(shape: BoxShape.circle, color: c.fillSecondary),
          child: CalviIcon(icon, size: 19),
        ),
      ),
    );
  }
}
