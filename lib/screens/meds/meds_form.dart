import 'package:flutter/material.dart';

import '../../data/meds.dart';
import '../../design/icons.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/wheel.dart';

String _pad(int n) => n.toString().padLeft(2, '0');

/// A medication: what it is called, how much, and when. Nothing else.
///
/// The same form adds and edits, because they are the same act. Editing keeps
/// the doses already ticked off today for the hours that survived the change: a
/// name corrected at noon must not undo a pill taken at eight.
class MedsForm extends StatefulWidget {
  const MedsForm({
    super.key,
    this.med,
    required this.onSave,
    required this.onDone,
    required this.now,
  });

  /// Present when an existing entry is being changed rather than a new one added.
  final Med? med;
  final ValueChanged<Med> onSave;
  final VoidCallback onDone;

  /// A new entry needs a unique id; the clock is passed in rather than read.
  final int now;

  @override
  State<MedsForm> createState() => _MedsFormState();
}

class _MedsFormState extends State<MedsForm> {
  late final _name = TextEditingController(text: widget.med?.name ?? '');

  /// One line in the person's own words: «разом зі сніданком», «через день».
  late final _note = TextEditingController(text: widget.med?.note ?? '');
  late double _dose = widget.med?.dose ?? 1;
  /* Kept, but no longer asked about: the day card counts doses, and a count
     needs a unit to step by. What the thing actually is goes in the note, in the
     person's own words. */
  late final MedForm _form = widget.med?.form ?? MedForm.tab;
  late bool _remind = widget.med?.remind ?? true;
  late List<String> _times = widget.med?.times.map((t) => t.at).toList() ?? [];

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  void _pickTime() {
    var h = 8, m = 0;
    calviSheet(
      context,
      title: 'Час прийому',
      doneLabel: 'Додати',
      onDone: () {
        final at = '${_pad(h)}:${_pad(m)}';
        setState(() {
          if (!_times.contains(at)) _times = [..._times, at]..sort();
        });
      },
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
    final c = context.c;
    final unit = formInfo(_form);
    final ready = _name.text.trim().isNotEmpty && _times.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 4, CalviSize.gutter, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label('Назва'),
          Container(
            height: 48,
            // Centred, or the line sits at the top of a box that is taller than it.
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: c.fillSecondary,
              borderRadius: BorderRadius.circular(CalviSize.rCard),
            ),
            child: TextField(
              controller: _name,
              maxLength: 60,
              onChanged: (_) => setState(() {}),
              style: context.t.bodyLarge?.copyWith(fontSize: 15),
              decoration: InputDecoration(
                isDense: true,
                counterText: '',
                border: InputBorder.none,
                hintText: 'Наприклад, Магній B6',
                hintStyle: context.t.labelSmall?.copyWith(fontSize: 15),
              ),
            ),
          ),

          _Label('Скільки за раз'),
          Container(
            decoration: BoxDecoration(
              color: c.fillSecondary,
              borderRadius: BorderRadius.circular(CalviSize.rCard),
            ),
            child: Row(
              children: [
                _Key(
                  label: 'Менше',
                  sign: '−',
                  onTap: () => setState(() {
                    _dose = ((_dose - unit.step) * 10).round() / 10;
                    if (_dose < unit.step) _dose = unit.step;
                  }),
                ),
                Expanded(
                  child: Center(
                    child: Text(doseLabel(_dose, _form), style: context.t.titleMedium),
                  ),
                ),
                _Key(
                  label: 'Більше',
                  sign: '+',
                  onTap: () => setState(() {
                    _dose = ((_dose + unit.step) * 10).round() / 10;
                    if (_dose > unit.max) _dose = unit.max;
                  }),
                ),
              ],
            ),
          ),

          _Label('Коли приймати'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in _times)
                GestureDetector(
                  onTap: () => setState(() => _times = _times.where((x) => x != t).toList()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: c.fillSecondary,
                      borderRadius: BorderRadius.circular(CalviSize.rPill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(t, style: context.t.titleMedium?.copyWith(fontSize: 14)),
                        const SizedBox(width: 6),
                        CalviIcon('minus', size: 12, color: c.textSecondary),
                      ],
                    ),
                  ),
                ),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(CalviSize.rPill),
                    border: Border.all(color: c.hairline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CalviIcon('clock', size: 14, color: c.textSecondary),
                      const SizedBox(width: 7),
                      Text(
                        'Вибрати годину',
                        style: context.t.labelSmall?.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /* The same switch lives in the reminders screen. Whichever is touched,
             both show the same state: two switches for one thing that disagree
             are worse than no switch at all. */
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: c.card,
              border: Border.all(color: c.cardBorder),
              borderRadius: BorderRadius.circular(CalviSize.rCard),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c.iconCircle),
                  child: const CalviIcon('bell', size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Нагадувати', style: context.t.titleMedium?.copyWith(fontSize: 15)),
                      const SizedBox(height: 2),
                      Text('у вибрані години', style: context.t.labelSmall),
                    ],
                  ),
                ),
                CalviSwitch(on: _remind, onChanged: (v) => setState(() => _remind = v)),
              ],
            ),
          ),

          _Label('Нотатка'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: c.fillSecondary,
              borderRadius: BorderRadius.circular(CalviSize.rCard),
            ),
            child: TextField(
              controller: _note,
              maxLength: 80,
              maxLines: 2,
              minLines: 1,
              style: context.t.bodyLarge?.copyWith(fontSize: 15),
              decoration: InputDecoration(
                isDense: true,
                counterText: '',
                border: InputBorder.none,
                hintText: 'Наприклад, разом зі сніданком',
                hintStyle: context.t.labelSmall?.copyWith(fontSize: 15),
              ),
            ),
          ),

          const SizedBox(height: 20),

          CalviButton(
            label: widget.med != null ? 'Зберегти зміни' : 'Зберегти',
            enabled: ready,
            onTap: () {
              widget.onSave(
                Med(
                  id: widget.med?.id ?? 'med-${widget.now}',
                  name: _name.text.trim(),
                  dose: _dose,
                  form: _form,
                  note: _note.text.trim().isEmpty ? null : _note.text.trim(),
                  remind: _remind,
                  times: [
                    for (final at in _times)
                      MedTime(
                        at: at,
                        // A name corrected at noon must not undo a pill taken
                        // at eight, so surviving hours keep their tick.
                        taken:
                            widget.med?.times.where((t) => t.at == at).firstOrNull?.taken ??
                            false,
                      ),
                  ],
                ),
              );
              widget.onDone();
            },
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 14, 2, 7),
    child: Text(text, style: context.t.labelSmall),
  );
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.sign, required this.onTap});

  final String label;
  final String sign;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 52,
        height: 48,
        child: Center(
          child: Text(sign, style: context.t.headlineMedium?.copyWith(fontSize: 21)),
        ),
      ),
    ),
  );
}
