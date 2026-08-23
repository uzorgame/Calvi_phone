import 'package:flutter/material.dart';

import '../../format.dart';
import '../../design/icons.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import 'slot_card.dart';
import '../../l10n/app_localizations.dart';

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

    /* Скільки склянок у нормі. Обмежене згори, бо чотирнадцять поділок на
       ширину телефона це вже не поділки, а сірий пунктир. */
    final goalGlasses = (goalMl / 250).round().clamp(1, 12);

    return SlotCard(
      icon: 'drink',
      title: L.of(context).waterTitle,
      sub: glasses == 0 ? L.of(context).waterNone : L.of(context).waterGlasses(glasses),
      badge: '${thousands(ml)} ${L.of(context).unitMl}',
      open: open,
      onToggle: onToggle,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
        child: Row(
          children: [
            _Step(
              icon: 'minus',
              label: L.of(context).waterLess(waterStep),
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
                          text: L.of(context).waterOf(thousands(goalMl)),
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
                  /* Смуга поділена на склянки, а не суцільна.
                     Воду люди рахують склянками, і підпис картки так і каже.
                     Суцільна смуга просила рахувати відсотки, яких ніхто не
                     пʼє: тепер видно, скільки склянок є і скільки лишилось. */
                  SizedBox(
                    height: 6,
                    child: Row(
                      children: [
                        for (var i = 0; i < goalGlasses; i++) ...[
                          if (i > 0) const SizedBox(width: 4),
                          Expanded(
                            child: AnimatedContainer(
                              duration: CalviMotion.normal,
                              curve: CalviMotion.ease,
                              decoration: BoxDecoration(
                                color: i < glasses ? c.fats : c.fillSecondary,
                                borderRadius: BorderRadius.circular(CalviSize.rPill),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(L.of(context).waterShare(pct), style: context.t.labelSmall),
                ],
              ),
            ),
            const SizedBox(width: 14),
            _Step(
              icon: 'plus',
              label: L.of(context).waterMore(waterStep),
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
