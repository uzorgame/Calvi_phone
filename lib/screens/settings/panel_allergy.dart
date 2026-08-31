import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/allergens.dart';
import '../../data/settings.dart';
import '../../design/icons.dart';
import '../../design/shell.dart';
import '../menu.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import 'panels_account.dart';
import '../../l10n/app_localizations.dart';

/// Allergies, chosen from the reference rather than typed.
///
/// The warning has to fire on a code matched against an ingredient list. Free
/// text puts the model back in the loop exactly where being wrong is not a
/// cosmetic problem: «фундук» and «лісовий горіх» are the same nut, and a typo
/// is silently no allergy at all.
class AllergyPanel extends StatefulWidget {
  const AllergyPanel({super.key, required this.s, required this.set, this.onBack});

  final SettingsState s;
  final SetSettings set;

  /// How the panel closes. It lives inside settings, not on top of it, so the
  /// way out is settings putting its list back rather than a route popping.
  final VoidCallback? onBack;

  @override
  State<AllergyPanel> createState() => _AllergyPanelState();
}

class _AllergyPanelState extends State<AllergyPanel> {
  final _q = TextEditingController();

  /// Which row has its banner open, and what that banner is set to.
  ///
  /// The draft lives here rather than in settings: opening a row to look at it
  /// must change nothing, and nothing is written until it is confirmed.
  String? _open;
  bool _severe = false;

  /// The row whose banner is folding away, kept only until it has folded.
  String? _closing;
  Timer? _shut;

  @override
  void dispose() {
    _shut?.cancel();
    _q.dispose();
    super.dispose();
  }

  void _shutting(String id) {
    _closing = id;
    _shut?.cancel();
    _shut = Timer(const Duration(milliseconds: 340), () {
      if (mounted) setState(() => _closing = null);
    });
  }

  void _openRow(String id) {
    setState(() {
      if (_open == id) {
        _open = null;
        return _shutting(id);
      }
      _severe = widget.s.allergies.where((a) => a.id == id).firstOrNull?.severe ?? false;
      _open = id;
      _closing = null;
    });
  }

  void _confirm(String id) {
    final had = widget.s.allergies.any((a) => a.id == id);
    widget.set(
      (v) => v.copyWith(
        allergies: had
            ? [
                for (final a in v.allergies)
                  if (a.id == id) Allergy(id: a.id, severe: _severe) else a,
              ]
            : [...v.allergies, Allergy(id: id, severe: _severe)],
      ),
    );
    setState(() {
      _open = null;
      _shutting(id);
    });
  }

  void _drop(String id) {
    widget.set((v) => v.copyWith(allergies: v.allergies.where((a) => a.id != id).toList()));
    setState(() {
      _open = null;
      _shutting(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final found = searchAllergens(_q.text);
    final groups = <String>[];
    for (final a in found) {
      if (!groups.contains(a.group)) groups.add(a.group);
    }

    final l = L.of(context);
    /* Без кнопки «Готово» внизу: тут нема чого підтверджувати, кожна алергія
       зберігається своєю кнопкою в банері, а вихід це «назад» зверху зліва. */
    return CalviScreen(
      trailing: const CalviMenuButton(),
      onBack: widget.onBack,
      title: l.allergyTitle,
      children: [
        _Search(
          controller: _q,
          onChanged: (_) => setState(() {}),
          hint: l.allergySearch(allergens.length),
        ),

        if (found.isEmpty) CalviNote(l.allergyNothing),

        for (final g in groups)
          CalviSection(
            title: g,
            children: [
              for (final a in found.where((x) => x.group == g))
                _AllergenRow(
                  allergen: a,
                  mine: s.allergies.where((x) => x.id == a.id).firstOrNull,
                  open: _open == a.id,
                  alive: _open == a.id || _closing == a.id,
                  severe: _severe,
                  onTap: () => _openRow(a.id),
                  onSeverity: (v) => setState(() => _severe = v),
                  onConfirm: () => _confirm(a.id),
                  onDrop: () => _drop(a.id),
                ),
            ],
          ),

        CalviNote(l.allergyNote),
      ],
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

/// One allergen in the reference, with the banner that sets it.
///
/// The banner belongs under the row it is about: a choice made at the top of the
/// screen is a choice about nothing in particular. Once set, the row itself
/// carries the answer as its colour, so the list can be read by scanning: the
/// pink of protein for an allergy that stops a record, the amber of
/// carbohydrates for one that only warns.
class _AllergenRow extends StatelessWidget {
  const _AllergenRow({
    required this.allergen,
    required this.mine,
    required this.open,
    required this.alive,
    required this.severe,
    required this.onTap,
    required this.onSeverity,
    required this.onConfirm,
    required this.onDrop,
  });

  final Allergen allergen;

  /// The allergy as it is already set, or null while it is not.
  final Allergy? mine;

  /// Whether this row's banner is the open one, and what it is set to.
  final bool open;

  /// Whether the banner is built at all: the open row, and the one folding away.
  final bool alive;
  final bool severe;

  final VoidCallback onTap;
  final ValueChanged<bool> onSeverity;
  final VoidCallback onConfirm;
  final VoidCallback onDrop;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final set = mine != null;
    final tone = mine == null
        ? const Color(0x00000000)
        : mine!.severe
        ? c.protein.withValues(alpha: 0.10)
        : c.carbs.withValues(alpha: 0.14);
    final mark = mine == null
        ? c.button
        : mine!.severe
        ? c.protein
        : c.carbs;

    return AnimatedContainer(
      duration: CalviMotion.normal,
      curve: CalviMotion.ease,
      /* Розгорнутий рядок підіймається над списком: тло картки і тінь кажуть,
         що вибір важкості стосується саме нього, а не сторінки загалом. Доти
         банер просто виростав знизу, і око не бачило межі.
       *
       * Позначений алерген це вкладена плашка з повітрям по краях, а не
       * заливка на всю ширину: у білій картці повнорозмірна заливка читалась
       * як зламана секція, а плашка читається як позначка. */
      margin: const EdgeInsets.fromLTRB(8, 3, 8, 3),
      decoration: BoxDecoration(
        color: open ? c.card : tone,
        borderRadius: BorderRadius.circular(14),
        border: open ? Border.all(color: c.cardBorder) : null,
        boxShadow: open ? context.shadowFloat : const [],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: CalviMotion.normal,
                    curve: CalviMotion.ease,
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: set ? mark : const Color(0x00000000),
                      border: Border.all(color: set ? mark : c.hairline, width: 1.5),
                    ),
                    child: CalviIcon(
                      'check',
                      size: 13,
                      color: set ? c.buttonText : const Color(0x00000000),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          allergen.name,
                          style: context.t.bodyMedium?.copyWith(
                            color: c.text,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (allergen.aka.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            allergen.aka.take(3).join(', '),
                            style: context.t.labelSmall?.copyWith(
                              fontWeight: FontWeight.w400,
                              color: c.faint,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (mine case final a?) ...[
                    const SizedBox(width: 10),
                    // Важкість підписана своїм кольором: слово і плашка кажуть
                    // одне, і рядок читається без вчитування.
                    Text(
                      a.severe ? L.of(context).allergySevereShort : L.of(context).allergyMildShort,
                      style: context.t.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: a.severe ? c.protein : Color.lerp(c.carbs, c.text, 0.4),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          /* The banner opens by giving the row height rather than by sliding
             over it, so nothing underneath jumps. Its contents follow a beat
             later, the way every other room in the app opens: first the space,
             then what is in it. */
          ClipRect(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 320),
              curve: open ? CalviMotion.easeRise : CalviMotion.easeOut,
              alignment: Alignment.topCenter,
              heightFactor: open ? 1 : 0,
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: open ? 1.0 : 0.0),
                duration: Duration(milliseconds: open ? 380 : 140),
                curve: open
                    ? const Interval(0.32, 1, curve: CalviMotion.easeRise)
                    : CalviMotion.easeOut,
                builder: (context, t, child) => Opacity(
                  opacity: t,
                  child: Transform.translate(offset: Offset(0, -6 * (1 - t)), child: child),
                ),
                child: !alive
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CalviSegments(
                              labels: [L.of(context).allergyMild, L.of(context).allergySevere],
                              index: severe ? 1 : 0,
                              height: 38,
                              onPick: (i) => onSeverity(i == 1),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: CalviPress(
                                    onTap: onConfirm,
                                    builder: (context, down) => AnimatedScale(
                                      scale: down ? 0.98 : 1,
                                      duration: CalviMotion.fast,
                                      curve: CalviMotion.ease,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: c.button,
                                          borderRadius: BorderRadius.circular(CalviSize.rPill),
                                        ),
                                        child: Text(
                                          L.of(context).allergyConfirm,
                                          style: context.t.titleMedium?.copyWith(
                                            fontSize: CalviSize.fsCaption,
                                            fontWeight: FontWeight.w600,
                                            color: c.buttonText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Only where there is something to take away.
                                if (set)
                                  GestureDetector(
                                    onTap: onDrop,
                                    behavior: HitTestBehavior.opaque,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
                                      child: Text(
                                        L.of(context).allergyRemove,
                                        style: context.t.bodyMedium,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
