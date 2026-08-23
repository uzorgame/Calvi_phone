import 'package:flutter/material.dart';

import '../data/repeat.dart';
import 'theme.dart';
import 'tokens.dart';
import '../l10n/app_localizations.dart';

/// Як часто це повторюється.
///
/// Три способи сказати одне й те саме питання, і перемикач між ними стоїть
/// зверху, бо спершу людина обирає СПОСІБ («по днях тижня»), а вже потім
/// подробиці. Зворотний порядок, коли дні тижня й інтервал лежать поруч як два
/// рівноправні поля, змушує здогадуватись, яке з них зараз діє.
///
/// «Щодня» стоїть першим і вибране за замовчуванням: більшість режимів саме
/// такі, і людині, якій нічого складного не треба, не доводиться нічого чіпати.
class RepeatPicker extends StatelessWidget {
  const RepeatPicker({super.key, required this.value, required this.onChange});

  final Repeat value;
  final ValueChanged<Repeat> onChange;

  /// Інтервали, які люди справді називають. Решта це вже календар, а не режим.
  /// Три звичні інтервали. Підпис береться з того самого місця, що й у списку
  /// нагадувань: два описи одного розкладу неминуче розійшлись би.
  static List<(int, String)> _every() => [
    for (final n in [2, 3, 7]) (n, repeatLabel(IntervalRepeat(every: n, from: todayKey()))),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final days = value is WeekdayRepeat ? (value as WeekdayRepeat).days : const <int>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: c.fillSecondary,
            borderRadius: BorderRadius.circular(CalviSize.rPill),
          ),
          child: Row(
            children: [
              for (final (kind, label) in [
                ('daily', L.of(context).repPickDaily),
                ('weekdays', L.of(context).repPickWeekdays),
                ('interval', L.of(context).repPickInterval),
              ])
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChange(switch (kind) {
                      'weekdays' => const WeekdayRepeat(days: [1, 3, 5]),
                      'interval' => IntervalRepeat(every: 2, from: todayKey()),
                      _ => const DailyRepeat(),
                    }),
                    child: AnimatedContainer(
                      duration: CalviMotion.fast,
                      curve: CalviMotion.ease,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _is(kind) ? c.card : Colors.transparent,
                        borderRadius: BorderRadius.circular(CalviSize.rPill),
                      ),
                      child: Text(
                        label,
                        style: context.t.labelSmall?.copyWith(
                          color: _is(kind) ? c.text : c.textSecondary,
                          fontWeight: _is(kind) ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        if (value is WeekdayRepeat) ...[
          const SizedBox(height: 14),
          // Сім кружечків у ряд: тиждень видно цілим, і вибір читається як
          // візерунок, а не як список галочок.
          Row(
            children: [
              for (var d = 1; d <= 7; d++) ...[
                if (d > 1) const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChange(
                      WeekdayRepeat(
                        days: days.contains(d)
                            ? [
                                for (final x in days)
                                  if (x != d) x,
                              ]
                            : [...days, d],
                      ),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: days.contains(d) ? c.button : Colors.transparent,
                          border: Border.all(color: days.contains(d) ? c.button : c.cardBorder),
                        ),
                        child: Center(
                          child: Text(
                            weekdayShort[d - 1],
                            style: context.t.labelSmall?.copyWith(
                              color: days.contains(d) ? c.buttonText : c.textSecondary,
                              fontWeight: days.contains(d) ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (days.isEmpty) ...[
            const SizedBox(height: 10),
            Text(
              L.of(context).repPickNoDays,
              style: context.t.labelSmall?.copyWith(color: c.textSecondary),
            ),
          ],
        ],

        if (value is IntervalRepeat) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (n, label) in _every())
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () =>
                      onChange(IntervalRepeat(every: n, from: (value as IntervalRepeat).from)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: (value as IntervalRepeat).every == n ? c.button : Colors.transparent,
                      borderRadius: BorderRadius.circular(CalviSize.rPill),
                      border: Border.all(
                        color: (value as IntervalRepeat).every == n ? c.button : c.cardBorder,
                      ),
                    ),
                    child: Text(
                      label,
                      style: context.t.labelSmall?.copyWith(
                        color: (value as IntervalRepeat).every == n
                            ? c.buttonText
                            : c.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Відлік має від чого починатись, інакше «через день» не означає
          // нічого: важливо не тільки раз на скільки, а й від якого дня.
          Text(
            L.of(context).repPickFromToday,
            style: context.t.labelSmall?.copyWith(color: c.textSecondary),
          ),
        ],
      ],
    );
  }

  bool _is(String kind) => switch (kind) {
    'weekdays' => value is WeekdayRepeat,
    'interval' => value is IntervalRepeat,
    _ => value is DailyRepeat,
  };
}
