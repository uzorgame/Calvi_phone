import 'package:flutter/material.dart';

import '../../data/meds.dart';
import '../../data/repeat.dart';
import '../../design/icons.dart';
import '../../design/repeat_picker.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/wheel.dart';
import '../../l10n/app_localizations.dart';

String _pad(int n) => n.toString().padLeft(2, '0');

/// Препарат: як зветься, скільки, коли і як часто. Більше нічого.
///
/// Аркушем, а не розгорнутим блоком у списку. Розгорнута форма займала цілий
/// екран, штовхала список униз і лишала людину гортати те, що вона щойно
/// відкрила; до того ж додавання препарату і додавання нагадування виглядали як
/// дві різні механіки, хоч це одна й та сама дія в одному застосунку.
///
/// Та сама форма і додає, і редагує, бо це той самий акт. Редагування зберігає
/// галочки, уже поставлені сьогодні для годин, які пережили зміну: виправлена
/// опівдні назва не має скасовувати таблетку, випиту о восьмій.
void openMedSheet(
  BuildContext context, {
  Med? med,
  required int now,
  required ValueChanged<Med> onSave,
  /* Закінчити курс, не видалити препарат.
   *
   * Кнопка колись звалась «Видалити препарат» і стирала його разом з історією:
   * дні, коли людина його справді пила, ставали такими, ніби вона не пила його
   * ніколи. Тепер препарат переїжджає в «Минулі», а щоденник лишається
   * щоденником. Порожнє означає «цей аркуш відкритий на створення». */
  ValueChanged<String>? onFinish,
}) {
  final name = TextEditingController(text: med?.name ?? '');
  var dose = med?.dose ?? 1;
  var form = med?.form ?? MedForm.tab;
  var remind = med?.remind ?? true;
  var repeat = med?.repeat ?? const DailyRepeat();
  var times = med?.times.map((t) => t.at).toList() ?? <String>[];

  void save() {
    if (name.text.trim().isEmpty || times.isEmpty) return;
    onSave(
      Med(
        id: med?.id ?? 'med-$now',
        name: name.text.trim(),
        dose: dose,
        form: form,
        remind: remind,
        repeat: repeat,
        /* Початок курсу проставляється тут, а не тільки в сховищі.
         *
         * Сховище й так підставляло сьогодні, але об'єкт, який лишався в памʼяті
         * застосунку, мав порожній `startDay`, а порожній означає «приймався
         * завжди». Тому щойно заведений препарат до першого перезапуску світився
         * в минулих днях: людина ставила «по понеділках» і бачила його в
         * позаминулий понеділок. */
        startDay: med?.startDay.isNotEmpty == true ? med!.startDay : dayKeyOf(DateTime.now()),
        /* Година заведення разом із днем. Дня самого по собі не досить: людина
           заводить о 14:00 ліки на 09:00 і 21:00, ранкова доза сьогодні вже
           позаду, а вечірню вона ще питиме. Правлений курс своєї години не
           міняє, інакше кожне виправлення назви пересувало б початок. */
        startTime: med?.startDay.isNotEmpty == true ? med!.startTime : hhmm(DateTime.now()),
        endDay: med?.endDay,
        note: med?.note,
        times: [
          for (final at in times)
            MedTime(
              at: at,
              // Виправлена опівдні назва не має скасовувати таблетку, випиту о
              // восьмій, тому години, що пережили зміну, лишають свою галочку.
              taken:
                  med?.times
                      .firstWhere(
                        (t) => t.at == at,
                        orElse: () => const MedTime(at: '', taken: false),
                      )
                      .taken ??
                  false,
            ),
        ],
      ),
    );
  }

  calviSheet(
    context,
    title: med == null ? L.of(context).medsNew : L.of(context).medsOne,
    doneLabel: L.of(context).actionSave,
    onDone: save,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, redraw) {
        final c = context.c;
        final l = L.of(context);
        final unit = formInfo(form);

        void pickTime(int? index) {
          final at = index == null ? '08:00' : times[index];
          final parts = at.split(':');
          var h = int.tryParse(parts.first) ?? 8;
          var m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

          calviSheet(
            sheetContext,
            title: L.of(context).medsTime,
            onDone: () => redraw(() {
              final picked = '${_pad(h)}:${_pad(m)}';
              times = index == null
                  ? [...times, picked]
                  : [
                      for (final (i, t) in times.indexed)
                        if (i == index) picked else t,
                    ];
              times = ({...times}.toList()..sort());
            }),
            builder: (_) =>
                CalviTimeWheel(hour: h, minute: m, onHour: (v) => h = v, onMinute: (v) => m = v),
          );
        }

        /* Висота за вмістом, а не на весь екран: колонка без `mainAxisSize.min`
           усередині `Flexible` займає всю доступну висоту, і аркуш, задуманий як
           картка знизу, розгортається в повноекранне вікно. */
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Cap(l.medsName),
              const SizedBox(height: 9),
              Container(
                height: 44,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: c.fillSecondary,
                  borderRadius: BorderRadius.circular(CalviSize.rCard),
                  border: Border.all(color: c.cardBorder),
                ),
                child: TextField(
                  controller: name,
                  maxLength: 60,
                  onChanged: (_) => redraw(() {}),
                  style: context.t.bodyLarge?.copyWith(fontSize: 15),
                  decoration: InputDecoration(
                    isDense: true,
                    counterText: '',
                    border: InputBorder.none,
                    hintText: l.medsNameExample,
                    hintStyle: context.t.bodyLarge?.copyWith(fontSize: 15, color: c.faint),
                  ),
                ),
              ),

              const SizedBox(height: 18),
              /* Форма і кількість одним полем: питання одне, скільки і чого.
                 Двома окремими блоками з підписами воно займало вдвічі більше
                 місця і читалось як два різні рішення. */
              _Cap(l.medsPerTake),
              const SizedBox(height: 9),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final f in medForms)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => redraw(() {
                        form = f.id;
                        dose = 1;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: form == f.id ? c.button : Colors.transparent,
                          borderRadius: BorderRadius.circular(CalviSize.rPill),
                          border: Border.all(color: form == f.id ? c.button : c.cardBorder),
                        ),
                        child: Text(
                          f.many,
                          style: context.t.labelSmall?.copyWith(
                            color: form == f.id ? c.buttonText : c.textSecondary,
                            fontWeight: form == f.id ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: c.fillSecondary,
                  borderRadius: BorderRadius.circular(CalviSize.rPill),
                ),
                child: Row(
                  children: [
                    _Round(
                      icon: 'minus',
                      onTap: () => redraw(() {
                        dose = ((dose - unit.step) * 10).round() / 10;
                        if (dose < unit.step) dose = unit.step;
                      }),
                    ),
                    Expanded(
                      child: Text(
                        doseLabel(dose, form),
                        textAlign: TextAlign.center,
                        style: context.t.titleMedium?.copyWith(fontSize: 15),
                      ),
                    ),
                    _Round(
                      icon: 'plus',
                      onTap: () => redraw(() {
                        dose = ((dose + unit.step) * 10).round() / 10;
                        if (dose > unit.max) dose = unit.max;
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              _Cap(l.medsAt),
              const SizedBox(height: 9),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final (i, t) in times.indexed)
                    _TimeChip(
                      at: t,
                      onTap: () => pickTime(i),
                      onDrop: () => redraw(() {
                        times = [
                          for (final (j, x) in times.indexed)
                            if (j != i) x,
                        ];
                      }),
                    ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => pickTime(null),
                    child: Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: c.cardBorder),
                      ),
                      child: CalviIcon('plus', size: 14, color: c.textSecondary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              _Cap(l.medsHowOften),
              const SizedBox(height: 9),
              RepeatPicker(value: repeat, onChange: (r) => redraw(() => repeat = r)),

              const SizedBox(height: 18),
              /* Той самий перемикач стоїть в екрані нагадувань. Хоч котрий
                 чіпають, обидва показують один стан: два перемикачі однієї речі,
                 що розходяться, гірші за жоден. */
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => redraw(() => remind = !remind),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: c.fillSecondary,
                    borderRadius: BorderRadius.circular(CalviSize.rCard),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: c.card),
                        child: const CalviIcon('bell', size: 17),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.medsRemind, style: context.t.bodyMedium),
                            const SizedBox(height: 2),
                            Text(
                              l.medsRemindHint,
                              style: context.t.labelSmall?.copyWith(color: c.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      CalviSwitch(on: remind, onChanged: (v) => redraw(() => remind = v)),
                    ],
                  ),
                ),
              ),

              if (med != null && onFinish != null) ...[
                const SizedBox(height: 18),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    onFinish(med.id);
                    Navigator.of(sheetContext).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.fillSecondary,
                      borderRadius: BorderRadius.circular(CalviSize.rPill),
                    ),
                    child: Text(
                      l.medsFinish,
                      style: context.t.labelSmall?.copyWith(color: c.protein),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    ),
  );
}

class _Cap extends StatelessWidget {
  const _Cap(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: context.t.labelSmall?.copyWith(color: context.c.textSecondary)),
  );
}

class _Round extends StatelessWidget {
  const _Round({required this.icon, required this.onTap});

  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: context.c.card),
      child: CalviIcon(icon, size: 15),
    ),
  );
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.at, required this.onTap, required this.onDrop});

  final String at;
  final VoidCallback onTap;
  final VoidCallback onDrop;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CalviSize.rPill),
        border: Border.all(color: c.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Text(at, style: context.t.bodyMedium),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDrop,
            child: Container(
              width: 28,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: c.cardBorder)),
              ),
              child: CalviIcon('minus', size: 12, color: c.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
