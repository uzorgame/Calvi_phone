/// Заголовок, вердикт і картка під ними: три речі, з яких складається кожна
/// секція аналітики.
///
/// Жили в самому екрані аналітики, поки читав їх тільки він. Сторінка тижня
/// говорить тією ж мовою навмисно: людина вже вивчила її на сусідньому екрані,
/// і другий спосіб показати секцію був би другим інтерфейсом. Копія тут
/// розійшлася б із оригіналом на першій же правці, тому вони одні на двох.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';
import 'tokens.dart';

class CalviStat extends StatelessWidget {
  const CalviStat({
    super.key,
    required this.title,
    this.badge,
    this.aside,
    this.warn = false,
    required this.child,
  });

  final String title;
  final String? badge;
  final String? aside;
  final bool warn;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 12, CalviSize.gutter, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LayoutBuilder(
              builder: (context, box) {
                final titleStyle = context.t.titleMedium;

                /* Заголовок бере своє першим, плашка те, що лишилось.
                 *
                 * Доти було навпаки: межі не мала саме плашка, вона просила
                 * скільки хотіла, а заголовок у `Expanded` віддавав їй усе аж
                 * до нуля. Українською вона коротка («+1 205 від норми») і це
                 * нічим не виказувало себе; іспанською («+1 205 fuera del
                 * objetivo») слову «Calorías» лишалось сорок пʼять пікселів зі
                 * ста тридцяти шести, а на вузькому телефоні ряд ще й вилазив
                 * смугастою стрічкою.
                 *
                 * Нижня межа для зворотного випадку: заголовок теж буває
                 * довгим, і тоді вже він не має права роздавити плашку. */
                final forTitle = (TextPainter(
                  text: TextSpan(text: title, style: titleStyle),
                  textDirection: Directionality.of(context),
                  maxLines: 1,
                )..layout()).width;
                final forBadge = math.max(box.maxWidth - forTitle - 8, box.maxWidth * 0.4);

                return Row(
                  children: [
                    Expanded(child: Text(title, style: titleStyle)),
                    if (badge != null)
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: forBadge),
                        child: CalviBadge(text: badge!, warn: warn),
                      ),
                    /* Гнучкий з тієї ж причини: підпис праворуч довший за
                       заголовок, а системний шрифт уміє додати до нього ще
                       третину. Доти він брав скільки хотів, і на збільшеному
                       шрифті рядок вилазив за екран смугастим попереджувачем. */
                    if (aside != null) Flexible(child: Text(aside!, style: context.t.bodyMedium)),
                  ],
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: c.card,
              border: Border.all(color: c.cardBorder),
              borderRadius: BorderRadius.circular(CalviSize.rLarge),
              boxShadow: context.shadowCard,
            ),
            child: child,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

/// The verdict beside a section title: green on the way, amber off it.
///
/// The one-glance answer to whether the chart under it is worth reading, which
/// is why it is a colour and not another grey pill.
class CalviBadge extends StatelessWidget {
  const CalviBadge({super.key, required this.text, required this.warn});

  final String text;
  final bool warn;

  /// The figure leads, so it carries the weight and the words after it do not.
  static final _lead = RegExp(r'^(\S+)\s+(.*)$');

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = _lead.firstMatch(text);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (warn ? c.carbs : c.success).withValues(alpha: warn ? 0.16 : 0.13),
        borderRadius: BorderRadius.circular(CalviSize.rPill),
      ),
      child: Text.rich(
        TextSpan(
          text: m == null ? text : '${m.group(1)} ',
          style: const TextStyle(fontWeight: FontWeight.w700),
          children: [
            if (m != null)
              TextSpan(
                text: m.group(2),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
          ],
        ),
        style: context.t.labelSmall?.copyWith(
          color: chipInk(context, warn ? context.c.carbs : context.c.success),
        ),
      ),
    );
  }
}

class CalviFigure extends StatelessWidget {
  const CalviFigure({
    super.key,
    required this.value,
    required this.cap,
    this.suffix,
    this.dim = false,
    this.tight = false,
  });

  final String value;
  final String cap;
  final String? suffix;
  final bool dim;

  /// Sized by its own text instead of taking an equal share of the row.
  final bool tight;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: value,
            children: [
              if (suffix != null)
                TextSpan(
                  text: suffix,
                  style: context.t.headlineMedium?.copyWith(color: c.textSecondary),
                ),
            ],
          ),
          style: context.t.headlineLarge?.copyWith(
            fontSize: 30,
            height: 1,
            color: dim ? c.textSecondary : c.text,
          ),
        ),
        const SizedBox(height: 5),
        // One line, the way the demo sets it: a caption that wraps turns a pair
        // of figures into two columns of different heights.
        Text(
          cap,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
          style: context.t.labelSmall?.copyWith(fontWeight: FontWeight.w400),
        ),
      ],
    );
    return tight ? body : Expanded(child: body);
  }
}
