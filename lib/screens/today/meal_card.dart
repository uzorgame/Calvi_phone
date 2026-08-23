import 'package:flutter/material.dart';

import '../../data/meal.dart';
import '../../design/icons.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/labels.dart';
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
    final l = L.of(context);

    return SlotCard(
      icon: slot.icon,
      title: slotTitle(context, slot),
      /* Множина, а не склеєний рядок. Українська має тут три форми («1 запис,
         2 записи, 5 записів»), англійська дві, і саме на цьому ламається будь-яке
         саморобне рішення. */
      sub: l.entries(meals.length),
      badge: l.kcalUnit(kcal),
      open: open,
      onToggle: onToggle,
      child: Column(
        children: [
          // The empty state is Nora, not a grey «немає даних».
          /* Порожній стан зі знаком, а не голим рядком: мʼяке коло з виделкою
             каже «тут буде їжа» швидше, ніж речення встигне прочитатись. */
          if (meals.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 14, 6, 10),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.c.fillSecondary,
                    ),
                    child: CalviIcon('utensils', size: 14, color: context.c.faint),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      L.of(context).mealEmpty,
                      style: context.t.bodyMedium?.copyWith(height: 1.45),
                    ),
                  ),
                ],
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
            child: CalviIcon(meal.icon, size: 21),
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
                  Text(
                    L.of(context).mealThinking,
                    style: context.t.labelSmall?.copyWith(color: c.accent),
                  )
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
                meal.pending ? '···' : '${meal.kcal}',
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
                        text: L.of(context).mealAuto,
                        style: context.t.labelSmall?.copyWith(fontSize: 10, color: c.accent),
                        children: [TextSpan(text: '· ${meal.time}', style: context.t.labelSmall)],
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

/// Грами, а за ними білки, жири і вуглеводи, кожне за своїм кольором.
///
/// Крапки, а не літери: «Б 14 Ж 16 В 2» це чотири скорочення на кожен рядок, а
/// кольори тут ті самі, що в кільцях вище.
///
/// Порядок саме БЖВ, і це не дрібниця. Тут стояло Б, В, Ж: кольори збігались із
/// числами, тобто рядок був правдивим, але читався він як неправда. Людина
/// щойно подивилась на три картки вгорі в порядку БЖВ і читає рядок так само, не
/// звіряючи кольорів, бо в другому місці поспіль вони не мають розходитись.
/// Яєчня виглядала стравою на один грам жиру.
class _MacroChips extends StatelessWidget {
  const _MacroChips({required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final style = context.t.labelSmall;

    /* Переносяться, а не обрізаються. Рядок стоїть у колонці поруч із числом
       калорій, і місця йому лишається сто пʼятдесят пікселів. Чотирьох чисел
       туди вистачає рівно доти, доки вони двозначні: «980 г 145 116 232» вже не
       влазить, а `Row` такому не поступається взагалі й вивалює смугасту
       жовто-чорну стрічку поверх картки. Тепер зайве їде рядком нижче. */
    return Wrap(
      spacing: 9,
      runSpacing: 2,
      children: [
        Text(L.of(context).mealGrams(meal.grams), style: style),
        _Macro(colour: c.protein, value: meal.protein),
        _Macro(colour: c.fats, value: meal.fat),
        _Macro(colour: c.carbs, value: meal.carbs),
      ],
    );
  }
}

/// Крапка і число за нею, нерозлучно.
///
/// Однією парою, а не двома сусідами в ряду: перенос має рвати рядок між
/// макросами, а не між крапкою і її числом.
class _Macro extends StatelessWidget {
  const _Macro({required this.colour, required this.value});

  final Color colour;
  final int value;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _Dot(colour: colour),
      Text('$value', style: context.t.labelSmall),
    ],
  );
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
