import 'package:flutter/material.dart';

import '../../data/settings.dart';
import '../../design/icons.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../today/slot_card.dart';
import 'panels_account.dart';

/// What the assistant remembers about you.
///
/// The memory is visible and editable: a person has to be able to see what has
/// been written down about them and to take it back out. An assistant's hidden
/// memory is something nobody asked for and nobody can check.
class AssistantPanel extends StatefulWidget {
  const AssistantPanel({super.key, required this.s, required this.set});

  final SettingsState s;
  final SetSettings set;

  @override
  State<AssistantPanel> createState() => _AssistantPanelState();
}

class _AssistantPanelState extends State<AssistantPanel> {
  final _text = TextEditingController();
  bool _adding = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _add() {
    final t = _text.text.trim();
    if (t.isEmpty) return;
    widget.set(
      (v) => v.copyWith(
        memory: [
          ...v.memory,
          Memo(id: 'm${v.memory.length + 1}-${t.length}', text: t, pinned: false),
        ],
      ),
    );
    _text.clear();
    setState(() => _adding = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final c = context.c;
    final pinned = s.memory.where((m) => m.pinned).length;

    return CalviScreen(
      title: 'Помічник',
      hint:
          '$assistantName веде щоденник разом із тобою і памʼятає те, що ти про себе розповів.',
      foot: CalviButton(label: 'Готово', onTap: () => Navigator.of(context).pop()),
      children: [
        CalviSection(
          title: 'Памʼять',
          children: [
            if (s.memory.isEmpty)
              const Padding(
                padding: EdgeInsets.all(14),
                child: CalviNora(
                  text: 'Поки нічого не запамʼятала.',
                  hint: 'Памʼять зʼявляється з розмов, або додай вручну',
                ),
              )
            else
              for (final (i, m) in s.memory.indexed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    border: i == 0 ? null : Border(top: BorderSide(color: c.hairline)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => widget.set(
                            (v) => v.copyWith(
                              memory: [
                                for (final x in v.memory)
                                  if (x.id == m.id) x.toggled() else x,
                              ],
                            ),
                          ),
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            children: [
                              CalviIcon(
                                m.pinned ? 'target' : 'note',
                                size: 16,
                                color: m.pinned ? c.accent : c.textSecondary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(m.text, style: context.t.bodyMedium)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Semantics(
                        button: true,
                        label: 'Забути',
                        child: GestureDetector(
                          onTap: () => widget.set(
                            (v) => v.copyWith(
                              memory: v.memory.where((x) => x.id != m.id).toList(),
                            ),
                          ),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: c.fillSecondary,
                            ),
                            child: CalviIcon('minus', size: 13, color: c.textSecondary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Text(
            '${s.memory.length} записів, закріплено $pinned',
            textAlign: TextAlign.center,
            style: context.t.labelSmall,
          ),
        ),
        const CalviNote(
          'Тап по запису закріплює його. Закріплене йде в кожну розмову, решта може витіснитись, '
          'коли контекст ущільнюється.',
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CalviSize.gutter),
          child: AddRow(
            label: _adding ? 'Згорнути' : 'Додати в памʼять',
            open: _adding,
            onTap: () => setState(() => _adding = !_adding),
          ),
        ),

        if (_adding)
          Padding(
            padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 6, CalviSize.gutter, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Що памʼятати', style: context.t.labelSmall),
                const SizedBox(height: 6),
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: c.fillSecondary,
                    borderRadius: BorderRadius.circular(CalviSize.rCard),
                  ),
                  child: TextField(
                    controller: _text,
                    maxLength: 90,
                    onChanged: (_) => setState(() {}),
                    style: context.t.bodyLarge?.copyWith(fontSize: 15),
                    decoration: InputDecoration(
                      isDense: true,
                      counterText: '',
                      border: InputBorder.none,
                      hintText: 'Наприклад, не їм гриби',
                      hintStyle: context.t.labelSmall?.copyWith(fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                CalviButton(
                  label: 'Зберегти',
                  enabled: _text.text.trim().isNotEmpty,
                  onTap: _add,
                ),
              ],
            ),
          ),

        const CalviNote(
          'Вибір іншого характеру помічника поки не робимо: спершу має бути добре зроблена одна.',
        ),
      ],
    );
  }
}
