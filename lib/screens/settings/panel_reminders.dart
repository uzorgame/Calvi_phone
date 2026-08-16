import 'package:flutter/material.dart';

import '../../data/settings.dart';
import '../../design/icons.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/wheel.dart';
import 'panels_account.dart';

String _pad(int n) => n.toString().padLeft(2, '0');

/// Reminders, grouped by what they are FOR.
///
/// «Нагадування» on its own says nothing, and a bell with no address is the
/// first thing switched off. Every row names its purpose, and every group
/// answers «a reminder of what» before the question is asked.
class RemindersPanel extends StatelessWidget {
  const RemindersPanel({
    super.key,
    required this.s,
    required this.set,
    required this.medsRemind,
    required this.onMedsRemind,
    required this.onMeds,
    required this.now,
  });

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

  void _toggleKind(ReminderKind kind, bool on) => set(
    (v) => v.copyWith(
      reminders: [
        for (final r in v.reminders)
          if (r.kind == kind) r.copyWith(on: on) else r,
      ],
    ),
  );

  /* A new reminder starts empty and at the hour the group already keeps, so it
     lands somewhere sensible and can be moved with one tap. */
  void _addTo(BuildContext context, ReminderKind kind) {
    final kin = s.reminders.where((r) => r.kind == kind);
    final at = kin
        .firstWhere(
          (r) => r.at != '--:--',
          orElse: () =>
              const Reminder(id: '', kind: ReminderKind.meal, label: '', at: '09:00', on: true),
        )
        .at;
    final id = '${kind.name}-$now';
    set(
      (v) => v.copyWith(
        reminders: [
          ...v.reminders,
          Reminder(id: id, kind: kind, label: 'Своє нагадування', at: at, on: true),
        ],
      ),
    );
    _editTime(context, id, at, 'Своє нагадування');
  }

  void _editTime(BuildContext context, String id, String at, String label) {
    final parts = (at == '--:--' ? '08:00' : at).split(':');
    var h = int.parse(parts[0]);
    var m = int.parse(parts[1]);

    calviSheet(
      context,
      title: label,
      doneLabel: 'Зберегти',
      onDone: () => set(
        (v) => v.copyWith(
          reminders: [
            for (final r in v.reminders)
              if (r.id == id) r.copyWith(at: '${_pad(h)}:${_pad(m)}') else r,
          ],
        ),
      ),
      builder: (sheet) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          children: [
            Expanded(
              child: CalviWheel(
                values: List.generate(24, (i) => i),
                value: h,
                suffix: '',
                onPick: (v) => h = v,
              ),
            ),
            Text(':', style: sheet.t.headlineMedium),
            Expanded(
              child: CalviWheel(
                // Five-minute steps: a reminder at 13:47 is a reminder nobody
                // meant to set.
                values: List.generate(12, (i) => i * 5),
                value: (m / 5).round() * 5,
                suffix: '',
                onPick: (v) => m = v,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CalviScreen(
      title: 'Нагадування',
      hint:
          'Час береться з твоїх записів, а не вигаданий: годину прийому я знаю з того, коли ти '
          'зазвичай їси. Спрацьовують локально, тому працюють і без мережі.',
      foot: CalviButton(label: 'Готово', onTap: () => Navigator.of(context).pop()),
      children: [
        for (final k in reminderKinds)
          if (s.reminders.where((r) => r.kind == k.id).toList() case final items
              when items.isNotEmpty)
            _Group(
              kind: k,
              items: items,
              medsRemind: medsRemind,
              onKind: (on) =>
                  k.id == ReminderKind.meds ? onMedsRemind(on) : _toggleKind(k.id, on),
              onAdd: () => k.id == ReminderKind.meds ? onMeds() : _addTo(context, k.id),
              onTime: (r) => _editTime(context, r.id, r.at, r.label),
              onOne: (r, on) => set(
                (v) => v.copyWith(
                  reminders: [
                    for (final x in v.reminders)
                      if (x.id == r.id) x.copyWith(on: on) else x,
                  ],
                ),
              ),
            ),

        const CalviNote(
          'Тап по часу змінює його. Верхній перемикач вимикає цілу групу, нижній окреме '
          'нагадування. Прочерк означає, що годину ще нема звідки взяти: препарати беруть її з '
          'журналу препаратів, а тренування з розкладу, якого поки немає.',
        ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.kind,
    required this.items,
    required this.medsRemind,
    required this.onKind,
    required this.onAdd,
    required this.onTime,
    required this.onOne,
  });

  final ReminderKindInfo kind;
  final List<Reminder> items;
  final bool medsRemind;
  final ValueChanged<bool> onKind;
  final VoidCallback onAdd;
  final ValueChanged<Reminder> onTime;
  final void Function(Reminder, bool) onOne;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final on = items.where((r) => r.on).length;
    final groupOn = kind.id == ReminderKind.meds ? medsRemind : on > 0;

    return CalviSection(
      title: kind.title,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: c.iconCircle),
                child: CalviIcon(kind.icon, size: 17),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(kind.hint, style: context.t.bodyMedium)),
              const SizedBox(width: 8),
              /* One state, two sides. The medications hold it, so this switch
                 keeps no count of its own and flips theirs instead: two switches
                 for one thing that drift apart are worse than one. */
              CalviSwitch(on: groupOn, onChanged: (v) => onKind(v)),
            ],
          ),
        ),

        /* Every group can add a reminder of its own. Medications are the
           exception: those need a name as well as an hour, so the plus leads to
           where both are entered instead of inventing an empty row. */
        GestureDetector(
          onTap: onAdd,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.hairline)),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c.fillSecondary),
                  child: CalviIcon('plus', size: 13, color: c.textSecondary),
                ),
                const SizedBox(width: 10),
                Text(
                  kind.id == ReminderKind.meds
                      ? 'Додати препарат і години'
                      : 'Своє нагадування',
                  style: context.t.bodyMedium,
                ),
              ],
            ),
          ),
        ),

        for (final r in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.hairline)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onTime(r),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 58,
                          child: Text(
                            r.at,
                            style: context.t.titleMedium?.copyWith(
                              fontSize: 15,
                              // A dash is not a time, and it should not read as
                              // one: the hour is simply not known yet.
                              color: r.at == '--:--' ? c.textSecondary : c.text,
                            ),
                          ),
                        ),
                        Expanded(child: Text(r.label, style: context.t.bodyMedium)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CalviSwitch(on: r.on, onChanged: (v) => onOne(r, v)),
              ],
            ),
          ),
      ],
    );
  }
}
