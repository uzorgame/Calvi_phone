import 'package:flutter/material.dart';

import '../../data/day.dart';
import '../../data/meds.dart';
import '../../design/icons.dart';
import '../../design/ring.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../l10n/app_localizations.dart';

/// Three macro cards, and a fourth for medications only when the person
/// actually has any.
///
/// Most people never open that feature, so it does not get a permanent slot; it
/// earns one by existing, and the three macros give up a little width for it
/// rather than the layout keeping an empty seat warm all year.
class MacroCards extends StatelessWidget {
  const MacroCards({
    super.key,
    required this.totals,
    required this.goal,
    required this.meds,
    required this.onMeds,
    this.takes = const {},
  });

  final DayTotals totals;
  final DayGoal goal;
  final List<Med> meds;
  final VoidCallback onMeds;

  /// Прийняті дози показаного дня, парами «препарат|година».
  final Set<String> takes;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final four = meds.isNotEmpty;
    final taken = medProgressOn(meds, takes);
    final ink = taken.ratio >= 1 ? c.success : c.accent;

    /* 16.16: the three macros give up width to the fourth over 420 ms, so the
       row is seen to make room instead of jumping to a new division.

       The widths are worked out here rather than handed to Expanded: a flex is a
       whole number and cannot sit halfway between thirds and quarters. An
       AnimatedSize around the row would be wrong for a different reason: it
       animates the row, and the row's own width never changes. */
    return LayoutBuilder(
      builder: (context, box) => TweenAnimationBuilder<double>(
        tween: Tween(end: four ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 420),
        curve: CalviMotion.easeRise,
        builder: (context, t, _) {
          const gap = CalviSize.gapCard;
          final third = (box.maxWidth - gap * 2) / 3;
          final quarter = (box.maxWidth - gap * 3) / 4;
          final macro = third + (quarter - third) * t;

          return Row(
            children: [
              _Card(
                width: macro,
                label: L.of(context).macroProteinCaps,
                icon: 'protein',
                value: '${totals.protein}',
                of: L.of(context).macroOfGrams(goal.protein),
                progress: goal.protein == 0 ? 0 : totals.protein / goal.protein,
                colour: c.protein,
                tight: four,
              ),
              const SizedBox(width: gap),
              _Card(
                width: macro,
                label: L.of(context).macroFatCaps,
                icon: 'fat',
                value: '${totals.fat}',
                of: L.of(context).macroOfGrams(goal.fat),
                progress: goal.fat == 0 ? 0 : totals.fat / goal.fat,
                colour: c.fats,
                tight: four,
              ),
              const SizedBox(width: gap),
              _Card(
                width: macro,
                label: L.of(context).macroCarbsCaps,
                icon: 'carbs',
                value: '${totals.carbs}',
                of: L.of(context).macroOfGrams(goal.carbs),
                progress: goal.carbs == 0 ? 0 : totals.carbs / goal.carbs,
                colour: c.carbs,
                tight: four,
              ),
              if (t > 0) ...[
                const SizedBox(width: gap),
                /* No entrance of its own: it is the fourth member of the row,
                   not a guest in it, so it appears exactly as the other three
                   do while the row makes room. */
                _Card(
                  // Whatever the three left behind, to the pixel.
                  width: box.maxWidth - macro * 3 - gap * 3,
                  label: L.of(context).macroMedsCaps,
                  // Green on a full set: finished, not merely on track.
                  icon: taken.ratio >= 1 ? 'check' : 'pill',
                  value: '${taken.done}',
                  of: ' / ${taken.total}',
                  progress: taken.ratio,
                  colour: ink,
                  tight: true,
                  onTap: onMeds,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.width,
    required this.label,
    required this.icon,
    required this.value,
    required this.of,
    required this.progress,
    required this.colour,
    required this.tight,
    this.onTap,
  });

  /// Worked out by the row, so the four widths add up exactly to its own.
  final double width;

  final String label;
  final String icon;
  final String value;
  final String of;
  final double progress;
  final Color colour;

  /* Four cards in the width of three need narrower type, otherwise «30 / 135г»
     wraps and the row grows a line taller the moment the fourth appears. */
  final bool tight;

  /// Only the fourth card leads anywhere; the three macros are figures.
  final VoidCallback? onTap;

  /// Рядок «число / ціль». Будується двічі: видимим і невидимим двійником.
  Widget _line(BuildContext context) => Text.rich(
    TextSpan(
      text: value,
      children: [
        TextSpan(
          text: of,
          style: context.t.labelSmall?.copyWith(
            fontSize: tight ? 10 : CalviSize.fsMicro,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    ),
    maxLines: 1,
    style: context.t.headlineMedium?.copyWith(
      fontSize: tight ? 16 : 19,
      fontWeight: FontWeight.w700,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    final card = GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: tight ? 5 : 14, vertical: tight ? 15 : 16),
        decoration: BoxDecoration(
          color: c.card,
          border: Border.all(color: c.cardBorder),
          borderRadius: BorderRadius.circular(CalviSize.rCard),
          boxShadow: context.shadowCard,
        ),
        child: Column(
          children: [
            /* Стискається, а не ріжеться, і не міняє висоти.
             *
             * `maxLines: 1` без явного overflow означає мовчазний clip, і на
             * екрані, вужчому на кілька пунктів (iPhone 16 це 393 проти 402 у
             * Pro), хвіст «/ 135г» просто зникав: людина бачила поточний білок
             * і не бачила цілі. FittedBox нічого не міняє там, де рядок влазить,
             * а в тісноті зменшує його на ті кілька відсотків, яких бракувало.
             *
             * Невидимий двійник повного розміру тримає висоту рядка. Без нього
             * стиснутий рядок ставав нижчим, і картка разом із ним: білок
             * стиснувся, жири ні, і три картки в ряду виходили різного зросту.
             * Двійник ріжеться по ширині, як різався оригінал, але його ніхто
             * не бачить: від нього потрібна лише висота. */
            Stack(
              alignment: Alignment.center,
              children: [
                Opacity(opacity: 0, child: _line(context)),
                FittedBox(fit: BoxFit.scaleDown, child: _line(context)),
              ],
            ),
            const SizedBox(height: 10),
            CalviRing(
              progress: progress,
              size: 46,
              stroke: 5,
              color: colour,
              child: CalviIcon(icon, size: 15, color: colour),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              maxLines: 1,
              // Clipped rather than wrapped: a second line under one card
              // makes the whole row taller than the other three.
              overflow: TextOverflow.clip,
              softWrap: false,
              /* Підпис як у приладів: маленький і розріджений. Саме трекінг
                 робить із нього підпис шкали, а не маленьке слово. */
              style: context.t.labelSmall?.copyWith(
                fontSize: tight ? 9 : 10,
                fontWeight: FontWeight.w500,
                letterSpacing: tight ? 0 : 10 * 0.09,
              ),
            ),
          ],
        ),
      ),
    );

    return SizedBox(width: width, child: card);
  }
}
