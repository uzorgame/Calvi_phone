import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/app_scope.dart';
import '../../data/workout.dart';
import '../../design/icons.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../l10n/app_localizations.dart';

/// Durations offered as chips. What a person actually says after training is a
/// round number, so the form offers those and keeps the odd ones out of the way.
const _durations = [15, 20, 30, 45, 60, 90];

/// Adding a workout.
///
/// Minutes are the default path because that is what a person actually knows
/// after training; calories are derived and shown as an estimate, never
/// presented as a measurement.
///
/// The manual path exists for the case the estimate cannot serve: a watch or a
/// machine already gave a number. There duration and note are optional, because
/// requiring them would make people invent values to get past the form.
class WorkoutForm extends StatefulWidget {
  const WorkoutForm({
    super.key,
    required this.activity,
    required this.onCancel,
    required this.onSave,
  });

  final Activity activity;
  final VoidCallback onCancel;
  final void Function({required int minutes, required int kcal, String? note}) onSave;

  @override
  State<WorkoutForm> createState() => _WorkoutFormState();
}

class _WorkoutFormState extends State<WorkoutForm> {
  bool _manual = false;
  int _minutes = 30;
  final _kcal = TextEditingController();
  final _manualMinutes = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _kcal.dispose();
    _manualMinutes.dispose();
    _note.dispose();
    super.dispose();
  }

  /// Оцінка за вагою саме цієї людини, а не за вагою з демонстрації.
  int get _estimate =>
      burnEstimate(widget.activity.met, _minutes, weightKg: AppScope.of(context).s.weightKg);
  int get _typedKcal => int.tryParse(_kcal.text) ?? 0;

  bool get _valid => _manual ? _typedKcal > 0 && _typedKcal < 5000 : _minutes > 0;

  void _submit() {
    if (!_valid) return;
    HapticFeedback.selectionClick();
    final note = _note.text.trim();
    widget.onSave(
      minutes: _manual ? (int.tryParse(_manualMinutes.text) ?? 0) : _minutes,
      kcal: _manual ? _typedKcal : _estimate,
      note: note.isEmpty ? null : note,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.iconCircle),
              child: CalviIcon(widget.activity.key, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(widget.activity.label, style: context.t.titleMedium)),
            Semantics(
              button: true,
              label: L.of(context).actionCancel,
              child: GestureDetector(
                onTap: widget.onCancel,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c.fillSecondary),
                  child: CalviIcon('minus', size: 13, color: c.textSecondary),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        CalviSegments(
          labels: [L.of(context).wfMinutes, L.of(context).wfManualKcal],
          index: _manual ? 1 : 0,
          onPick: (i) => setState(() => _manual = i == 1),
        ),
        const SizedBox(height: 14),

        if (_manual) ...[
          _Label(L.of(context).wfBurned),
          _Input(
            controller: _kcal,
            hint: L.of(context).wfFromWatch,
            digits: 4,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _Label(L.of(context).wfDurationCap, optional: true),
          _Input(controller: _manualMinutes, hint: '', digits: 3, onChanged: (_) {}),
        ] else ...[
          _Label(L.of(context).wfDuration),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in _durations)
                GestureDetector(
                  onTap: () => setState(() => _minutes = m),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: m == _minutes ? c.button : c.fillSecondary,
                      borderRadius: BorderRadius.circular(CalviSize.rPill),
                    ),
                    child: Text(
                      L.of(context).wfMin(m),
                      style: context.t.titleMedium?.copyWith(
                        fontSize: 14,
                        color: m == _minutes ? c.buttonText : c.text,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.fillSecondary,
              borderRadius: BorderRadius.circular(CalviSize.rCard),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: '≈ $_estimate',
                    children: [
                      TextSpan(
                        text: L.of(context).wfKcal,
                        style: context.t.labelSmall?.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                  style: context.t.headlineMedium,
                ),
                const SizedBox(height: 4),
                // Named as an estimate on the screen, not only in the docs.
                Text(L.of(context).wfEstimate, style: context.t.labelSmall),
              ],
            ),
          ),
        ],

        const SizedBox(height: 12),
        _Label(L.of(context).wfNote, optional: true),
        _Input(controller: _note, hint: L.of(context).wfNoteExample, onChanged: (_) {}),
        const SizedBox(height: 14),

        CalviButton(label: L.of(context).wfLog, enabled: _valid, onTap: _submit),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {this.optional = false});

  final String text;
  final bool optional;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text.rich(
      TextSpan(
        text: text,
        children: [
          // Said in the label, not enforced by the button: a required field
          // nobody can fill is a field people invent a value for.
          if (optional)
            TextSpan(
              text: L.of(context).wfOptional,
              style: context.t.labelSmall?.copyWith(fontSize: 11),
            ),
        ],
      ),
      style: context.t.labelSmall,
    ),
  );
}

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.digits,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  /// Set for numeric fields: the keyboard and the filter follow it.
  final int? digits;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      height: 48,
      // Centred, or the line sits at the top of a box that is taller than it.
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: c.fillSecondary,
        borderRadius: BorderRadius.circular(CalviSize.rCard),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: digits == null ? TextInputType.text : TextInputType.number,
        inputFormatters: digits == null
            ? [LengthLimitingTextInputFormatter(90)]
            : [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(digits)],
        style: context.t.bodyLarge?.copyWith(fontSize: 15),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: context.t.labelSmall?.copyWith(fontSize: 15),
        ),
      ),
    );
  }
}
