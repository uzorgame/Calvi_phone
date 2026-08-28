import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design/fold.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../l10n/app_localizations.dart';

/// Числа страви, вписані рукою.
class ManualEntry {
  const ManualEntry({
    required this.title,
    required this.grams,
    required this.kcal,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  final String title;
  final int grams;
  final int kcal;
  final int protein;
  final int fat;
  final int carbs;
}

/// Коефіцієнти Етвотера: скільки калорій дає грам кожного макроса.
const _atwater = (protein: 4, fat: 9, carbs: 4);

/// Пʼять чисел страви, вписаних рукою.
///
/// Вага і калорії стоять першим рядом, БЖВ другим: перші два це те, заради чого
/// запис узагалі роблять, а макроси уточнюють. Ряд із пʼяти однакових полів на
/// телефон не влазить і читався б як анкета.
///
/// **Калорії підказуються з БЖВ, поки їх не чіпали.** Порахувати їх за
/// Етвотером застосунок уміє, і змушувати людину множити в голові немає за чим.
/// Щойно вона вписала своє число, підказка мовчить: на упаковці буває інакше,
/// ніж дає формула, і сперечатися з тим, що людина бачить очима, не наша справа.
class ManualForm extends StatefulWidget {
  const ManualForm({super.key, required this.title, required this.onCancel, required this.onSave});

  final String title;
  final VoidCallback onCancel;
  final ValueChanged<ManualEntry> onSave;

  @override
  State<ManualForm> createState() => _ManualFormState();
}

class _ManualFormState extends State<ManualForm> {
  final _grams = TextEditingController();
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _fat = TextEditingController();
  final _carbs = TextEditingController();

  /// Чи людина вже вписала калорії сама. Далі підказка не втручається.
  bool _ownKcal = false;

  /// Відкладений доїзд у видиму зону. Скасовний, бо форму можуть закрити
  /// раніше, ніж складка розкриється.
  Timer? _ride;

  @override
  void initState() {
    super.initState();
    /* Форма доїжджає у видиму зону сама, коли складка розкрилась.
     *
     * Вона розгортається внизу картки, а картка часто стоїть біля низу екрана:
     * форма відкривалась за краєм, і виглядало це як «не відкривається».
     * Прокрутити просять після того, як складка набрала висоту, бо ціль, що
     * ще росте, довезе у вчорашнє місце. */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ride = Timer(CalviFold.openMs, () {
        if (!mounted) return;
        Scrollable.ensureVisible(
          context,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
          duration: const Duration(milliseconds: 300),
          curve: CalviMotion.easeRise,
        );
      });
    });
  }

  @override
  void dispose() {
    _ride?.cancel();
    for (final c in [_grams, _kcal, _protein, _fat, _carbs]) {
      c.dispose();
    }
    super.dispose();
  }

  int _num(TextEditingController c) {
    final v = double.tryParse(c.text.replaceAll(',', '.')) ?? 0;
    return v.isFinite && v > 0 ? v.round() : 0;
  }

  int get _fromMacros =>
      _num(_protein) * _atwater.protein + _num(_fat) * _atwater.fat + _num(_carbs) * _atwater.carbs;

  /// Скільки калорій піде в запис: своє число, якщо його вписали, інакше
  /// підказане з макросів.
  int get _kcalValue => _ownKcal || _fromMacros == 0 ? _num(_kcal) : _fromMacros;

  void _suggest() {
    // Підказка живе в самому полі, щоб її було видно і можна було виправити.
    if (!_ownKcal) _kcal.text = _fromMacros == 0 ? '' : '$_fromMacros';
    setState(() {});
  }

  void _save() {
    if (_kcalValue <= 0) return;
    HapticFeedback.selectionClick();
    widget.onSave(
      ManualEntry(
        title: widget.title,
        grams: _num(_grams),
        kcal: _kcalValue,
        protein: _num(_protein),
        fat: _num(_fat),
        carbs: _num(_carbs),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);
    final ready = _kcalValue > 0;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* Назва вже введена, і повторювати її полем немає за чим: вона стоїть
             тут заголовком, щоб було видно, до чого ці числа. */
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.t.titleMedium?.copyWith(fontSize: CalviSize.fsCaption),
            ),
          ),

          Row(
            children: [
              _Field(
                label: l.slotGrams,
                ctrl: _grams,
                onEdit: () => setState(() {}),
                onDone: _save,
              ),
              const SizedBox(width: 6),
              _Field(
                label: l.slotKcal,
                ctrl: _kcal,
                onEdit: () => setState(() => _ownKcal = true),
                onDone: _save,
              ),
            ],
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              _Field(
                label: l.macroProteinCaps,
                ctrl: _protein,
                colour: c.protein,
                onEdit: _suggest,
                onDone: _save,
              ),
              const SizedBox(width: 6),
              _Field(
                label: l.macroFatCaps,
                ctrl: _fat,
                colour: c.fats,
                onEdit: _suggest,
                onDone: _save,
              ),
              const SizedBox(width: 6),
              _Field(
                label: l.macroCarbsCaps,
                ctrl: _carbs,
                colour: c.carbs,
                onEdit: _suggest,
                onDone: _save,
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _Button(
                  label: l.slotCancel,
                  onTap: widget.onCancel,
                  ink: c.text,
                  ground: c.fillSecondary,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _Button(
                  label: l.slotLog,
                  // Запис без калорій це той самий нуль, від якого ми йдемо.
                  onTap: ready ? _save : null,
                  ink: c.buttonText,
                  ground: ready ? c.button : c.buttonDisabled,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.ctrl,
    required this.onEdit,
    required this.onDone,
    this.colour,
  });

  final String label;
  final TextEditingController ctrl;
  final VoidCallback onEdit;
  final VoidCallback onDone;

  /// Колір макроса. Вага і калорії його не мають, бо свого не мають ніде.
  final Color? colour;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (colour != null) ...[
                // Та сама крапка, що в рядах БЖВ: колір макроса, і більше нічого.
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: colour),
                ),
                const SizedBox(width: 5),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.t.labelSmall?.copyWith(fontSize: 10, letterSpacing: 10 * 0.04),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          SizedBox(
            height: 36,
            child: TextField(
              controller: ctrl,
              onChanged: (_) => onEdit(),
              onSubmitted: (_) => onDone(),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                LengthLimitingTextInputFormatter(6),
              ],
              style: context.t.bodyLarge?.copyWith(
                fontSize: CalviSize.fsCaption,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: '0',
                hintStyle: context.t.labelSmall?.copyWith(
                  fontSize: CalviSize.fsCaption,
                  color: c.faint,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                filled: true,
                fillColor: c.fillSecondary,
                border: _edge(c.cardBorder),
                enabledBorder: _edge(c.cardBorder),
                focusedBorder: _edge(c.button),
              ),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _edge(Color colour) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(CalviSize.rCard),
    borderSide: BorderSide(color: colour),
  );
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.onTap,
    required this.ink,
    required this.ground,
  });

  final String label;
  final VoidCallback? onTap;
  final Color ink;
  final Color ground;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: AnimatedContainer(
      duration: CalviMotion.fast,
      curve: CalviMotion.ease,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ground,
        borderRadius: BorderRadius.circular(CalviSize.rCard),
      ),
      child: Text(
        label,
        style: context.t.bodyMedium?.copyWith(color: ink, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
