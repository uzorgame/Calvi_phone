import 'package:flutter/material.dart';

import '../../data/allergens.dart';
import '../../data/settings.dart';
import '../../design/icons.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import 'panels_account.dart';

/// Allergies, chosen from the reference rather than typed.
///
/// The warning has to fire on a code matched against an ingredient list. Free
/// text puts the model back in the loop exactly where being wrong is not a
/// cosmetic problem: «фундук» and «лісовий горіх» are the same nut, and a typo
/// is silently no allergy at all.
class AllergyPanel extends StatefulWidget {
  const AllergyPanel({super.key, required this.s, required this.set});

  final SettingsState s;
  final SetSettings set;

  @override
  State<AllergyPanel> createState() => _AllergyPanelState();
}

class _AllergyPanelState extends State<AllergyPanel> {
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  void _toggle(String id) {
    final picked = widget.s.allergies.any((a) => a.id == id);
    widget.set(
      (v) => v.copyWith(
        allergies: picked
            ? v.allergies.where((a) => a.id != id).toList()
            : [...v.allergies, Allergy(id: id, severe: false)],
      ),
    );
  }

  void _setSevere(String id, bool severe) {
    widget.set(
      (v) => v.copyWith(
        allergies: [
          for (final a in v.allergies)
            if (a.id == id) Allergy(id: a.id, severe: severe) else a,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final found = searchAllergens(_q.text);
    final picked = s.allergies.map((a) => a.id).toSet();
    final groups = <String>[];
    for (final a in found) {
      if (!groups.contains(a.group)) groups.add(a.group);
    }

    return CalviScreen(
      title: 'Алергії',
      hint:
          'Обирай зі списку, а не пиши текстом: попередження спрацьовує за кодом алергену в '
          'складі, і саме тому воно не залежить від того, як страву назвали.',
      foot: CalviButton(label: 'Готово', onTap: () => Navigator.of(context).pop()),
      children: [
        if (s.allergies.isNotEmpty)
          CalviSection(
            title: 'Мої алергії',
            children: [
              for (final (i, a) in s.allergies.indexed)
                if (allergenById(a.id) case final info?)
                  _Mine(
                    name: info.name,
                    severe: a.severe,
                    first: i == 0,
                    onDrop: () => _toggle(a.id),
                    onSevere: (v) => _setSevere(a.id, v),
                  ),
            ],
          )
        else
          const CalviNora(
            text: 'Поки нічого не вказано.',
            hint: 'Обери зі списку нижче, і я перевірятиму склад',
          ),

        _Search(
          controller: _q,
          onChanged: (_) => setState(() {}),
          hint: 'Пошук серед ${allergens.length} алергенів',
        ),

        if (found.isEmpty)
          const CalviNote(
            'Нічого не знайшлось. Якщо алергену немає в списку, напиши Норі: додамо його в '
            'довідник, щоб він працював у всіх, а не лишався текстом в одного.',
          ),

        for (final g in groups)
          CalviSection(
            title: g,
            children: [
              for (final (i, a) in found.where((x) => x.group == g).indexed)
                _AllergenRow(
                  allergen: a,
                  on: picked.contains(a.id),
                  first: i == 0,
                  onTap: () => _toggle(a.id),
                ),
            ],
          ),

        const CalviNote(
          'Якщо складу продукту немає в базі, я не мовчу і не вважаю це безпекою: скажу окремо, '
          'що склад невідомий.',
        ),
      ],
    );
  }
}

/// One allergy already on the list, with how hard it hits.
class _Mine extends StatelessWidget {
  const _Mine({
    required this.name,
    required this.severe,
    required this.first,
    required this.onDrop,
    required this.onSevere,
  });

  final String name;
  final bool severe;
  final bool first;
  final VoidCallback onDrop;
  final ValueChanged<bool> onSevere;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        border: first ? null : Border(top: BorderSide(color: c.hairline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(name, style: context.t.titleMedium)),
              GestureDetector(
                onTap: onDrop,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c.fillSecondary),
                  child: CalviIcon('minus', size: 13, color: c.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CalviSegments(
            labels: const ['Легка', 'Важка'],
            index: severe ? 1 : 0,
            height: 38,
            onPick: (i) => onSevere(i == 1),
          ),
          const SizedBox(height: 8),
          Text(
            severe ? 'Зупиню до запису і скажу прямо.' : 'Попереджу в тексті, запис не блокую.',
            style: context.t.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _Search extends StatelessWidget {
  const _Search({required this.controller, required this.onChanged, required this.hint});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 6, CalviSize.gutter, 4),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: c.fillSecondary,
          borderRadius: BorderRadius.circular(CalviSize.rPill),
        ),
        child: Row(
          children: [
            CalviIcon('allergy', size: 16, color: c.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: context.t.bodyLarge?.copyWith(fontSize: 15),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: context.t.labelSmall?.copyWith(fontSize: 14),
                ),
              ),
            ),
            if (controller.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  controller.clear();
                  onChanged('');
                },
                child: CalviIcon('minus', size: 15, color: c.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}

class _AllergenRow extends StatelessWidget {
  const _AllergenRow({
    required this.allergen,
    required this.on,
    required this.first,
    required this.onTap,
  });

  final Allergen allergen;
  final bool on;
  final bool first;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          border: first ? null : Border(top: BorderSide(color: c.hairline)),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: CalviMotion.fast,
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: on ? c.button : const Color(0x00000000),
                border: Border.all(color: on ? c.button : c.hairline, width: 2),
              ),
              child: on ? CalviIcon('check', size: 12, color: c.buttonText) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(allergen.name, style: context.t.bodyLarge?.copyWith(fontSize: 15)),
                  if (allergen.aka.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(allergen.aka.take(3).join(', '), style: context.t.labelSmall),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
