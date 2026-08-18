import 'package:flutter/material.dart';

import '../../data/settings.dart';
import '../../design/icons.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
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
      builder: (sheet) => CalviTimeWheel(
        hour: h,
        minute: m,
        onHour: (v) => h = v,
        onMinute: (v) => m = v,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CalviScreen(
      onBack: onBack,
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
      aside: on == 0 ? 'вимкнено' : '$on з ${items.length}',
      /* The switch and the way in stand on the page; only the reminders
         themselves are a card. Boxing all three made the group's own switch look
         like one more reminder. */
      bare: true,
      trail: 0,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 0, 2, 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: c.iconCircle),
                child: CalviIcon(kind.icon, size: 19),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  kind.hint,
                  style: context.t.labelSmall?.copyWith(fontWeight: FontWeight.w400),
                ),
              ),
              const SizedBox(width: 11),
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
        CalviPress(
          onTap: onAdd,
          builder: (context, down) => Padding(
            padding: const EdgeInsets.fromLTRB(4, 10, 4, 12),
            child: Row(
              children: [
                AnimatedScale(
                  scale: down ? 0.9 : 1,
                  duration: CalviMotion.fast,
                  curve: CalviMotion.ease,
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: c.fillSecondary),
                    child: CalviIcon('plus', size: 15),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  kind.id == ReminderKind.meds
                      ? 'Додати препарат і години'
                      : 'Своє нагадування',
                  style: context.t.labelSmall?.copyWith(fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ),

        Container(
          decoration: BoxDecoration(
            border: Border.all(color: c.cardBorder),
            borderRadius: BorderRadius.circular(CalviSize.rLarge),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // A rule between reminders, none under the last: the card's own
              // border closes the list.
              for (final (i, r) in items.indexed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    border: i == 0 ? null : Border(top: BorderSide(color: c.cardBorder)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onTime(r),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.at,
                                style: context.t.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: r.at == '--:--'
                                      ? CalviSize.fsBody * 0.08
                                      : CalviSize.fsBody * -0.02,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                  // A dash is not a time, and it should not read
                                  // as one: the hour is simply not known yet.
                                  color: r.at == '--:--' ? c.faint : c.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                r.label,
                                style: context.t.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      CalviSwitch(on: r.on, onChanged: (v) => onOne(r, v)),
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
