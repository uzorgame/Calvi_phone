import 'package:flutter/material.dart';

import '../../data/meal.dart';
import '../../design/icons.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import 'slot_card.dart';

/// A day's meals under one card.
///
/// Breakfast, lunch and dinner stand whether or not anything went into them: a
/// card that only appears once it has content cannot be tapped to add the first
/// thing, which is exactly when it is needed.
class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.slot,
    required this.meals,
    required this.open,
    required this.onToggle,
    required this.onAdd,
  });

  final SlotDef slot;
  final List<Meal> meals;
  final bool open;
  final VoidCallback onToggle;

  /// What was written straight into this card, in the person's own words.
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    final kcal = meals.fold<int>(0, (s, m) => s + m.kcal);

    return SlotCard(
      icon: slot.icon,
      title: slot.label,
      sub: meals.isEmpty
          ? '0 записів'
          : '${meals.length} ${meals.length == 1 ? 'запис' : 'записи'}',
      badge: '$kcal ккал',
      open: open,
      onToggle: onToggle,
      child: Column(
        children: [
          // The empty state is Nora, not a grey «немає даних».
          if (meals.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 14, 6, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Тут поки порожньо. Напиши, що було, і я запишу.',
                  style: context.t.bodyMedium?.copyWith(height: 1.45),
                ),
              ),
            ),
          for (final m in meals) MealRow(meal: m),
          SlotInput(onSend: onAdd),
        ],
      ),
    );
  }
}

class MealRow extends StatelessWidget {
  const MealRow({super.key, required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        border: Border.all(color: c.cardBorder),
        borderRadius: BorderRadius.circular(CalviSize.rCard),
      ),
      child: Row(
        children: [
          /* Category mark instead of a photo: we never store food photos, and a
             text-only row would collapse into a dull table. */
          Container(
            width: CalviSize.iconCircleSize,
            height: CalviSize.iconCircleSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c.iconCircle),
            child: CalviIcon(meal.category.name, size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.t.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: meal.pending ? c.textSecondary : c.text,
                  ),
                ),
                const SizedBox(height: 4),
                /* Written down but not parsed yet: the numbers are unknown until
                   Nora answers, and filling them with a guess would be the app
                   inventing data. */
                if (meal.pending)
                  Text('Нора рахує…', style: context.t.labelSmall?.copyWith(color: c.accent))
                else
                  _MacroChips(meal: meal),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                meal.pending ? '—' : '${meal.kcal}',
                style: context.t.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: CalviSize.fsBody * -0.02,
                ),
              ),
              const SizedBox(height: 3),
              /* Logged from the widget or the watch, without anybody at the
                 screen. The row says so rather than pretending it was typed. */
              meal.auto
                  ? Text.rich(
                      TextSpan(
                        text: 'авто ',
                        style: context.t.labelSmall?.copyWith(fontSize: 10, color: c.accent),
                        children: [
                          TextSpan(text: '· ${meal.time}', style: context.t.labelSmall),
                        ],
                      ),
                    )
                  : Text(meal.time, style: context.t.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

/// Grams, then protein, carbohydrates and fat, each behind its own colour.
///
/// Dots rather than letters: «Б 14 В 2 Ж 16» is four abbreviations to decode on
/// every row, and the colours are already the ones the rings above use.
class _MacroChips extends StatelessWidget {
  const _MacroChips({required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final style = context.t.labelSmall;

    return Row(
      children: [
        Text('${meal.grams} г', style: style),
        const SizedBox(width: 9),
        _Dot(colour: c.protein),
        Text('${meal.protein}', style: style),
        const SizedBox(width: 9),
        _Dot(colour: c.carbs),
        Text('${meal.carbs}', style: style),
        const SizedBox(width: 9),
        _Dot(colour: c.fats),
        Text('${meal.fat}', style: style),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.colour});

  final Color colour;

  @override
  Widget build(BuildContext context) => Container(
    width: 5,
    height: 5,
    margin: const EdgeInsets.only(right: 4),
    decoration: BoxDecoration(shape: BoxShape.circle, color: colour),
  );
}
