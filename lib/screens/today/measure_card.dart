import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/measure.dart';
import '../../design/icons.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import 'slot_card.dart';
import '../../l10n/app_localizations.dart';

/// The tape, on the home screen and permanent.
///
/// It shows only what this person measures. Eight fields open at once assumes
/// everybody takes a full set, and almost nobody does: most track weight, some
/// add a waist, a few care about a bicep. The plus is how the rest arrive, one
/// at a time, when they are actually wanted.
///
/// **Поля порожні щодня, а не заповнені вчорашнім.**
///
/// Спершу тут стояло минуле значення, і виглядало це розумно: тіло не
/// починається з нуля щомісяця. Насправді виходила неправда. Картка казала
/// «останнє сьогодні» і показувала число, якого сьогодні ніхто не міряв, а
/// значок рахував не заміри, а поля, які людина вирішила відстежувати: два
/// увімкнені поля давали «2 заміри» на порожній картці.
///
/// Тому поле показує рівно те, що записано на цей день, а минуле число стоїть
/// підказкою всередині: видно, від чого відштовхуватись, і видно, що це ще не
/// сьогоднішнє. Записане в минулі дні лишається недоторканим: на ньому
/// тримається вся аналітика.
class MeasureCard extends StatefulWidget {
  const MeasureCard({
    super.key,
    required this.date,
    required this.list,
    required this.tracked,
    required this.onTrack,
    required this.onSave,
    required this.onStats,
    required this.open,
    required this.onToggle,
  });

  /// Який день зараз на екрані. Заміри належать дню, а не «взагалі».
  final int date;

  final List<Measure> list;
  final List<String> tracked;
  final ValueChanged<List<String>> onTrack;
  final ValueChanged<Measure> onSave;
  final VoidCallback onStats;
  final bool open;
  final VoidCallback onToggle;

  @override
  State<MeasureCard> createState() => _MeasureCardState();
}

class _MeasureCardState extends State<MeasureCard> {
  final _draft = <String, String>{};
  final _controllers = <String, TextEditingController>{};
  bool _picking = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /* Поле має показувати те, що в базі, а не те, що там було при першій побудові.
   *
   * Контролер створюється один раз, і число, яке прийшло пізніше, у нього вже не
   * потрапляло. Найпомітніше це було з Норою: людина каже «запиши вагу 77.5»,
   * запис лягає в базу, значок чесно пише «1 замір», а поле поруч порожнє. Той
   * самий контролер тягнувся і при перемиканні днів, показуючи вчорашнє число на
   * сьогоднішній картці.
   *
   * Недописане людиною не чіпаємо: чернетка живе, поки її не збережуть. */
  @override
  void didUpdateWidget(covariant MeasureCard old) {
    super.didUpdateWidget(old);
    if (old.list == widget.list && old.date == widget.date) return;

    // День змінився, значить чернетка була про інший день.
    if (old.date != widget.date) _draft.clear();

    for (final entry in _controllers.entries) {
      if (_draft.containsKey(entry.key)) continue;
      final fresh = _value(entry.key);
      if (entry.value.text != fresh) entry.value.text = fresh;
    }
  }

  /// Що записано на цей день. Порожньо, якщо сьогодні ще не міряли.
  String _value(String key) {
    if (_draft.containsKey(key)) return _draft[key]!;
    final v = _onThisDay(key);
    return v == null ? '' : _trim(v);
  }

  double? _onThisDay(String key) {
    for (final m in widget.list) {
      if (m.date == widget.date) {
        final v = m[key];
        if (v != null) return v;
      }
    }
    return null;
  }

  /// Останнє раніше за цей день: підказка в порожньому полі.
  String? _before(String key) {
    ({double v, int date})? best;
    for (final m in widget.list) {
      if (m.date >= widget.date) continue;
      final v = m[key];
      if (v == null) continue;
      if (best == null || m.date > best.date) best = (v: v, date: m.date);
    }
    return best == null ? null : _trim(best.v);
  }

  TextEditingController _controllerFor(String key) =>
      _controllers.putIfAbsent(key, () => TextEditingController(text: _value(key)));

  void _save() {
    if (_draft.isEmpty) return;
    final values = <String, double>{};
    for (final key in widget.tracked) {
      final f = fieldFor(key);
      final raw = _value(key).replaceAll(',', '.');
      final n = double.tryParse(raw);
      // Out of range is dropped rather than stored: a slipped digit in one field
      // would bend the chart for months.
      if (n != null && n >= f.min && n <= f.max) values[key] = n;
    }
    widget.onSave(Measure(date: widget.date, values: values));

    /* The fields are put back to what was actually stored. Clearing the draft
       alone left a rejected number sitting in its box: the chart had ignored it,
       the field still showed it, and nothing on screen said which one was real.
       A field that survived keeps its value; one that was dropped goes back to
       the last reading. */
    setState(() {
      for (final key in widget.tracked) {
        final kept = values[key];
        _controllers[key]?.text = kept == null ? '' : _trim(kept);
      }
      _draft.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final fields = measureFields.where((f) => widget.tracked.contains(f.key)).toList();
    final rest = measureFields.where((f) => !widget.tracked.contains(f.key)).toList();

    Measure? last;
    for (final m in widget.list) {
      if (last == null || m.date > last.date) last = m;
    }

    return SlotCard(
      icon: 'ruler',
      title: L.of(context).measureTitle,
      sub: last == null
          ? L.of(context).measureNever
          : L.of(context).measureLast(measureAgo(last.date)),
      /* Значок рахує заміри цього дня, а не ввімкнені поля. Порожня картка з
         написом «2 заміри» казала неправду двічі: замірів не було, а число
         означало щось геть інше. */
      badge: () {
        final done = fields.where((f) => _onThisDay(f.key) != null).length;
        if (done == 0) return L.of(context).measureNothing;
        return L.of(context).measureCount(done);
      }(),
      open: widget.open,
      onToggle: widget.onToggle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fields.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(L.of(context).measurePick, style: context.t.bodyMedium),
            )
          else
            LayoutBuilder(
              builder: (context, box) => Wrap(
                spacing: 10,
                runSpacing: 12,
                children: [
                  for (final f in fields)
                    _Field(
                      width: (box.maxWidth - 10) / 2,
                      field: f,
                      controller: _controllerFor(f.key),
                      // Минуле число підказкою: видно, від чого відштовхуватись,
                      // і видно, що це ще не сьогоднішнє.
                      was: _before(f.key),
                      onChanged: (v) => setState(() => _draft[f.key] = v),
                      onDrop: () {
                        _controllers.remove(f.key)?.dispose();
                        _draft.remove(f.key);
                        widget.onTrack(widget.tracked.where((k) => k != f.key).toList());
                      },
                    ),
                ],
              ),
            ),

          if (rest.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => _picking = !_picking),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: c.fillSecondary),
                      child: CalviIcon(_picking ? 'minus' : 'plus', size: 16, color: c.text),
                    ),
                    const SizedBox(width: 10),
                    // Гнучкий: напис довгий, а картка вузька, і текст у ряду
                    // без цього не переноситься, а вилазить за край.
                    Expanded(
                      child: Text(
                        _picking ? L.of(context).measureCollapse : L.of(context).measureAdd,
                        style: context.t.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_picking)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final f in rest)
                    GestureDetector(
                      onTap: () {
                        setState(() => _picking = false);
                        widget.onTrack([...widget.tracked, f.key]);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: c.fillSecondary,
                          borderRadius: BorderRadius.circular(CalviSize.rPill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CalviIcon('plus', size: 13, color: c.textSecondary),
                            const SizedBox(width: 6),
                            Text(f.label, style: context.t.labelSmall?.copyWith(fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

          if (fields.isNotEmpty && _draft.isNotEmpty) ...[
            const SizedBox(height: 16),
            CalviButton(label: L.of(context).measureSave, onTap: _save),
          ],

          const SizedBox(height: 4),
          GestureDetector(
            onTap: widget.onStats,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CalviIcon('chart', size: 15, color: c.textSecondary),
                  const SizedBox(width: 8),
                  // Гнучкий, бо ряд вирівняний по центру і місця має рівно
                  // стільки, скільки лишилось від картки.
                  Flexible(
                    child: Text(
                      L.of(context).measureStats,
                      style: context.t.labelSmall?.copyWith(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.width,
    required this.field,
    required this.controller,
    required this.onChanged,
    required this.onDrop,
    this.was,
  });

  /// Останнє записане раніше за цей день. Стоїть підказкою в порожньому полі.
  final String? was;

  final double width;
  final MeasureField field;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onDrop;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(field.label, style: context.t.labelSmall),
              const SizedBox(width: 6),
              // Dropping a field is a small mark beside its own label, not a
              // settings screen: what you stop measuring, you stop from here.
              GestureDetector(
                onTap: onDrop,
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c.fillSecondary),
                  child: CalviIcon('minus', size: 11, color: c.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 46,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: c.fillSecondary,
              borderRadius: BorderRadius.circular(CalviSize.rCard),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    textAlignVertical: TextAlignVertical.center,
                    controller: controller,
                    onChanged: onChanged,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                      LengthLimitingTextInputFormatter(5),
                    ],
                    style: context.t.headlineMedium?.copyWith(fontSize: 19),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: was ?? '',
                      hintStyle: context.t.headlineMedium?.copyWith(
                        fontSize: 19,
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                ),
                Text(field.unit, style: context.t.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// «78.6» rather than «78.60», and «81» rather than «81.0».
String _trim(double v) {
  final s = v.toStringAsFixed(1);
  return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
}
