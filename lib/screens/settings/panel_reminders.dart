import 'package:flutter/material.dart';

import '../../data/repeat.dart';
import '../../data/settings.dart';
import '../../design/icons.dart';
import '../../design/repeat_picker.dart';
import '../../design/shell.dart';
import '../menu.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/wheel.dart';
import 'panels_account.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/labels.dart';

String _pad(int n) => n.toString().padLeft(2, '0');

/// Нагадування, які людина завела сама.
///
/// Тут був список із шести груп, увімкнених наперед: їжа, вода, препарати,
/// тренування, зважування, підсумок дня. Половина з них не стосувалась нікого
/// конкретного, і перше, що з ними робили, це вимикали. Наперед увімкнене
/// нагадування це не турбота, а припущення про чуже життя.
///
/// Тому екран порожній, поки людина не додасть перше, рівно як препарати. Кожне
/// нагадування знає, ПРО ЩО воно, о котрій і в які дні: без цих трьох воно або
/// дзвонить не тоді, або дзвонить щодня там, де треба двічі на тиждень.
class RemindersPanel extends StatefulWidget {
  const RemindersPanel({
    super.key,
    required this.s,
    required this.set,
    required this.medsRemind,
    required this.onMedsRemind,
    required this.onMeds,
    required this.now,
    this.onBack,
  });

  /// How the panel closes: settings puts its list back rather than a route
  /// popping, because the panel lives inside settings.
  final VoidCallback? onBack;

  final SettingsState s;
  final SetSettings set;

  /// The medication reminder state lives with the medications, not in this list.
  final bool medsRemind;
  final ValueChanged<bool> onMedsRemind;

  /// Medications are added where they live, not here.
  final VoidCallback onMeds;

  /// Passed in rather than read from the clock: a new reminder needs a unique
  /// id, and a widget that reaches for the current time cannot be tested.
  final int now;

  @override
  State<RemindersPanel> createState() => _RemindersPanelState();
}

class _RemindersPanelState extends State<RemindersPanel> {
  /* Форма живе в стані панелі, а не в аркуші: аркуш перемальовується від
     кожного дотику, і поле, оголошене всередині нього, скидалось би щоразу. */
  ReminderKind _kind = ReminderKind.water;
  String _label = '';
  List<String> _times = const ['09:00'];
  Repeat _repeat = const DailyRepeat();

  void _openNew() {
    _kind = ReminderKind.water;
    _label = '';
    _times = const ['09:00'];
    _repeat = const DailyRepeat();
    _openSheet(null);
  }

  void _openOne(Reminder r) {
    _kind = r.kind;
    _label = r.label;
    _times = r.times.isEmpty ? const ['09:00'] : r.times;
    _repeat = r.repeat;
    _openSheet(r.id);
  }

  void _save(String? id) {
    final title = reminderTitle(context, _kind);
    final clean = ({..._times}.toList()..sort());

    final made = Reminder(
      id: id ?? 'r-${widget.now}',
      kind: _kind,
      label: _label.trim().isEmpty ? title : _label.trim(),
      times: clean,
      repeat: _repeat,
      on: true,
    );

    widget.set(
      (v) => v.copyWith(
        reminders: id == null
            ? [...v.reminders, made]
            : [
                for (final r in v.reminders)
                  if (r.id == id) made.copyWith(on: r.on) else r,
              ],
      ),
    );
  }

  void _remove(String id) => widget.set(
    (v) => v.copyWith(
      reminders: [
        for (final r in v.reminders)
          if (r.id != id) r,
      ],
    ),
  );

  /// Годинник окремим аркушем поверх форми: інакше вибір години закривав би все,
  /// що людина щойно налаштувала, і повертатись довелось би наосліп.
  void _pickTime(BuildContext context, int index, void Function(void Function()) redraw) {
    final parts = _times[index].split(':');
    var h = int.tryParse(parts.first) ?? 9;
    var m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    calviSheet(
      context,
      title: L.of(context).remTime,
      onDone: () => redraw(() {
        _times = [
          for (final (i, t) in _times.indexed)
            if (i == index) '${_pad(h)}:${_pad(m)}' else t,
        ];
      }),
      builder: (_) =>
          CalviTimeWheel(hour: h, minute: m, onHour: (v) => h = v, onMinute: (v) => m = v),
    );
  }

  void _openSheet(String? id) {
    calviSheet(
      context,
      title: id == null ? L.of(context).remNew : L.of(context).remEdit,
      doneLabel: L.of(context).actionSave,
      onDone: () => _save(id),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, redraw) {
          final c = context.c;

          /* Висота за вмістом, а не на весь екран.
           *
           * Колонка без `mainAxisSize.min` усередині `Flexible` займає всю
           * доступну висоту, і аркуш, задуманий як картка знизу, розгортався в
           * повноекранне вікно. Прокрутка тут же: на маленькому телефоні з
           * відкритою клавіатурою форма не помістилась би, і без неї нижні поля
           * стали б недосяжними. */
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Cap(L.of(context).remAbout),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (final k in reminderKinds)
                      if (k.id != ReminderKind.meds)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => redraw(() => _kind = k.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _kind == k.id ? c.button : Colors.transparent,
                              borderRadius: BorderRadius.circular(CalviSize.rPill),
                              border: Border.all(color: _kind == k.id ? c.button : c.cardBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CalviIcon(
                                  k.icon,
                                  size: 15,
                                  color: _kind == k.id ? c.buttonText : c.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  reminderTitle(context, k.id),
                                  style: context.t.labelSmall?.copyWith(
                                    color: _kind == k.id ? c.buttonText : c.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),

                const SizedBox(height: 18),
                _Cap(L.of(context).remName),
                const SizedBox(height: 9),
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: c.fillSecondary,
                    borderRadius: BorderRadius.circular(CalviSize.rCard),
                    border: Border.all(color: c.cardBorder),
                  ),
                  child: TextField(
                    controller: TextEditingController(text: _label)
                      ..selection = TextSelection.collapsed(offset: _label.length),
                    maxLength: 40,
                    onChanged: (v) => _label = v,
                    style: context.t.bodyLarge?.copyWith(fontSize: 15),
                    decoration: InputDecoration(
                      isDense: true,
                      counterText: '',
                      border: InputBorder.none,
                      hintText: reminderTitle(context, _kind),
                      hintStyle: context.t.bodyLarge?.copyWith(fontSize: 15, color: c.faint),
                    ),
                  ),
                ),

                const SizedBox(height: 18),
                _Cap(L.of(context).remAt),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final (i, t) in _times.indexed)
                      _TimeChip(
                        at: t,
                        onTap: () => _pickTime(sheetContext, i, redraw),
                        onDrop: _times.length > 1
                            ? () => redraw(
                                () => _times = [
                                  for (final (j, x) in _times.indexed)
                                    if (j != i) x,
                                ],
                              )
                            : null,
                      ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => redraw(() => _times = [..._times, '21:00']),
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
                _Cap(L.of(context).remHowOften),
                const SizedBox(height: 9),
                RepeatPicker(value: _repeat, onChange: (r) => redraw(() => _repeat = r)),

                if (id != null) ...[
                  const SizedBox(height: 18),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _remove(id);
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
                        L.of(context).remDelete,
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

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);

    /* Без кнопки «Готово» внизу: тут нема чого підтверджувати, кожне
       нагадування зберігається своїм аркушем, а вихід це «назад» угорі. */
    return CalviScreen(
      trailing: const CalviMenuButton(),
      onBack: widget.onBack,
      title: l.remTitle,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CalviSize.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.s.reminders.isEmpty)
                CalviNora(text: l.remEmpty, hint: l.remEmptyHint)
              else
                for (final r in widget.s.reminders) ...[
                  _Row(
                    r: r,
                    onOpen: () => _openOne(r),
                    onToggle: (on) => widget.set(
                      (v) => v.copyWith(
                        reminders: [
                          for (final x in v.reminders)
                            if (x.id == r.id) x.copyWith(on: on) else x,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

              /* Повітря навколо: пунктирний рядок стояв упритул до сусідів і
                 читався як частина списку, а не як дія. */
              const SizedBox(height: 12),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _openNew,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(CalviSize.rCard),
                    border: Border.all(color: c.hairline),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: c.fillSecondary),
                        child: CalviIcon('plus', size: 15, color: c.textSecondary),
                      ),
                      const SizedBox(width: 10),
                      // Гнучкий: напис довгий, а на вузькому телефоні текст у
                      // ряду не переноситься, а вилазить за край.
                      Expanded(
                        child: Text(
                          l.remAdd,
                          style: context.t.bodyMedium?.copyWith(color: c.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              /* Препарати мають свій розклад там, де їх заводять: у них є назва,
                 доза і години прийому, і дублювати це сюди означало б два місця
                 для одного режиму. Тут лишається один перемикач і дорога туди. */
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(CalviSize.rCard),
                  border: Border.all(color: c.cardBorder),
                  boxShadow: context.shadowCard,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _Bubble(icon: 'pill'),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.setMeds, style: context.t.bodyMedium),
                              const SizedBox(height: 2),
                              Text(
                                l.reminderMedsHint,
                                style: context.t.labelSmall?.copyWith(color: c.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        CalviSwitch(on: widget.medsRemind, onChanged: widget.onMedsRemind),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onMeds,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(CalviSize.rPill),
                          border: Border.all(color: c.cardBorder),
                        ),
                        child: Text(
                          l.remOpenMeds,
                          style: context.t.labelSmall?.copyWith(color: c.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
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

class _Bubble extends StatelessWidget {
  const _Bubble({required this.icon});

  final String icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 34,
    height: 34,
    alignment: Alignment.center,
    decoration: BoxDecoration(shape: BoxShape.circle, color: context.c.fillSecondary),
    child: CalviIcon(icon, size: 19),
  );
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.at, required this.onTap, this.onDrop});

  final String at;
  final VoidCallback onTap;
  final VoidCallback? onDrop;

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
          if (onDrop != null)
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

class _Row extends StatelessWidget {
  const _Row({required this.r, required this.onOpen, required this.onToggle});

  final Reminder r;
  final VoidCallback onOpen;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final k = reminderKinds.firstWhere((x) => x.id == r.kind, orElse: () => reminderKinds.first);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(CalviSize.rCard),
        border: Border.all(color: c.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onOpen,
              child: Row(
                children: [
                  _Bubble(icon: k.icon),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.t.bodyMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${r.times.join(', ')} · ${repeatLabel(r.repeat)}',
                          style: context.t.labelSmall?.copyWith(color: c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          CalviSwitch(on: r.on, onChanged: onToggle),
        ],
      ),
    );
  }
}
