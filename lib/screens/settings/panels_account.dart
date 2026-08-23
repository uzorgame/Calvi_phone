import 'package:flutter/material.dart';

import '../../data/settings.dart';
import '../../design/icons.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/labels.dart';

typedef SetSettings = void Function(SettingsState Function(SettingsState));

/// How the app looks.
///
/// Three options rather than a switch. «Тема пристрою» is not a midpoint
/// between light and dark, it is a refusal to choose on the person's behalf, and
/// it has to stand in the row as its own decision instead of hiding in the
/// position of a toggle.
class ThemePanel extends StatelessWidget {
  const ThemePanel({super.key, required this.s, required this.set, this.onBack});

  final SettingsState s;
  final SetSettings set;

  /// How the panel closes. It lives inside settings, not on top of it, so the
  /// way out is settings putting its list back rather than a route popping.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return CalviScreen(
      onBack: onBack,
      title: l.setTheme,
      foot: CalviButton(label: l.actionDone, onTap: () => (onBack ?? Navigator.of(context).pop)()),
      children: [
        CalviSection(
          title: l.themeSectionLook,
          bare: true,
          children: [
            for (final t in themeOptions)
              CalviPick(
                label: themeTitle(context, t.id),
                hint: themeHint(context, t.id),
                icon: t.icon,
                on: s.theme == t.id,
                onTap: () => set((v) => v.copyWith(theme: t.id)),
              ),
          ],
        ),
        CalviNote(l.themeNote),
      ],
    );
  }
}

/// Interface language.
///
/// The choice exists, the translation does not, and the screen says so plainly
/// instead of switching silently and leaving everything in Ukrainian. A promise
/// the interface does not keep costs more than a missing button.
class LangPanel extends StatelessWidget {
  const LangPanel({super.key, required this.s, required this.set, this.onBack});

  final SettingsState s;
  final SetSettings set;

  /// How the panel closes. It lives inside settings, not on top of it, so the
  /// way out is settings putting its list back rather than a route popping.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return CalviScreen(
      onBack: onBack,
      title: l.setLang,
      foot: CalviButton(label: l.actionDone, onTap: () => (onBack ?? Navigator.of(context).pop)()),
      children: [
        CalviSection(
          title: l.langSection,
          bare: true,
          children: [
            for (final option in langOptions)
              CalviPick(
                label: langTitle(context, option),
                on: s.lang == option,
                onTap: () => set((v) => v.copyWith(lang: option)),
              ),
          ],
        ),
      ],
    );
  }
}

/// Subscription. Paid through the stores and nowhere else.
class PlanPanel extends StatefulWidget {
  const PlanPanel({super.key, this.onBack});

  /// How the panel closes: settings puts its list back rather than a route
  /// popping, because the panel lives inside settings.
  final VoidCallback? onBack;

  @override
  State<PlanPanel> createState() => _PlanPanelState();
}

class _PlanPanelState extends State<PlanPanel> {
  String _plan = 'year';

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return CalviScreen(
      onBack: widget.onBack,
      title: l.planTitle,
      foot: CalviButton(
        label: l.planBuy,
        onTap: () => (widget.onBack ?? Navigator.of(context).pop)(),
        second: l.planLater,
        onSecond: () => (widget.onBack ?? Navigator.of(context).pop)(),
      ),
      children: [
        CalviSection(
          title: l.planNow,
          bare: true,
          trail: 0,
          children: [
            CalviFacts(
              inset: false,
              rows: [(l.planPlan, l.planFree), (l.planTokens, l.planTokensFree)],
            ),
          ],
        ),

        /* Переваги списком із галочками, а не реченням у примітці: екран
           продає, і кожен рядок має читатись окремим «так». */
        CalviSection(
          title: l.planPerks,
          bare: true,
          trail: 0,
          children: [
            _Perks(rows: [l.planPerkChat, l.planPerkHistory, l.planPerkReports]),
          ],
        ),

        /* Два плани двома картками, і вигода річного названа числом на чіпі, а
           не захована в підказці, де про неї треба здогадатись. */
        CalviSection(
          title: l.planPlan,
          bare: true,
          children: [
            Row(
              children: [
                Expanded(
                  child: _PlanCard(
                    name: l.planYear,
                    save: l.planSave,
                    price: l.planYearPrice,
                    note: l.planYearBilled,
                    on: _plan == 'year',
                    onTap: () => setState(() => _plan = 'year'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PlanCard(
                    name: l.planMonth,
                    price: l.planMonthPrice,
                    note: l.planMonthBilled,
                    on: _plan == 'month',
                    onTap: () => setState(() => _plan = 'month'),
                  ),
                ),
              ],
            ),
          ],
        ),
        CalviNote(l.planStoreNote),
      ],
    );
  }
}

/// Privacy.
class PrivacyPanel extends StatelessWidget {
  const PrivacyPanel({super.key, required this.s, required this.set, this.onBack});

  final SettingsState s;
  final SetSettings set;

  /// How the panel closes. It lives inside settings, not on top of it, so the
  /// way out is settings putting its list back rather than a route popping.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return CalviScreen(
      onBack: onBack,
      title: l.privacyTitle,
      foot: CalviButton(label: l.actionDone, onTap: () => (onBack ?? Navigator.of(context).pop)()),
      children: [
        /* Три обіцянки трьома рядками, а не абзацом.
           Це головне, що людина хоче тут прочитати, і суцільний сірий текст
           вона пробігає очима, не читаючи жодної з них. */
        CalviSection(
          title: l.privacyNotCollected,
          bare: true,
          trail: 0,
          children: [
            _Guarantees(
              rows: [
                (l.privacyNoPhotosHead, l.privacyNoPhotosSub),
                (l.privacyDiaryHead, l.privacyDiarySub),
                (l.privacyHealthHead, l.privacyHealthSub),
              ],
            ),
          ],
        ),
        CalviSection(
          title: l.privacyOptional,
          children: [
            CalviRow(
              icon: 'chart',
              first: true,
              title: l.privacyStats,
              hint: l.privacyStatsHint,
              trailing: CalviSwitch(
                on: s.analytics,
                onChanged: (v) => set((x) => x.copyWith(analytics: v)),
              ),
            ),
            CalviRow(
              icon: 'shield',
              title: l.privacyCrash,
              hint: l.privacyCrashHint,
              trailing: CalviSwitch(
                on: s.crash,
                onChanged: (v) => set((x) => x.copyWith(crash: v)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Deleting the account.
class DeletePanel extends StatefulWidget {
  const DeletePanel({super.key, this.onBack});

  /// How the panel closes: settings puts its list back rather than a route
  /// popping, because the panel lives inside settings.
  final VoidCallback? onBack;

  @override
  State<DeletePanel> createState() => _DeletePanelState();
}

class _DeletePanelState extends State<DeletePanel> {
  bool _sure = false;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return CalviScreen(
      onBack: widget.onBack,
      title: l.deleteTitle,
      hint: l.deleteNote,
      foot: CalviButton(
        label: l.deleteForever,
        enabled: _sure,
        danger: true,
        onTap: () => (widget.onBack ?? Navigator.of(context).pop)(),
        second: l.actionCancel,
        onSecond: () => (widget.onBack ?? Navigator.of(context).pop)(),
      ),
      children: [
        CalviSection(
          bare: true,
          trail: 0,
          children: [
            CalviFacts(
              inset: false,
              rows: [(l.deleteEntries, '412'), (l.deleteWeighings, '37'), (l.deleteDays, '94')],
            ),
          ],
        ),
        CalviCheck(
          on: _sure,
          onToggle: () => setState(() => _sure = !_sure),
          text: l.deleteConfirm,
        ),
        CalviNote(l.deleteSubNote, lead: 12),
      ],
    );
  }
}

/// Гарантії списком, зі значком щита перед кожною.
///
/// Щит, а не галочка: тут перелік не переваг, а того, чого ми не робимо, і
/// значок має говорити про захист, а не про виконаний пункт.
class _Guarantees extends StatelessWidget {
  const _Guarantees({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: c.cardBorder),
        borderRadius: BorderRadius.circular(CalviSize.rLarge),
        boxShadow: context.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, row) in rows.indexed) ...[
            if (i > 0) const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.fats.withValues(alpha: 0.16),
                  ),
                  child: CalviIcon('shield', size: 12, color: c.fats),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.$1,
                        style: context.t.bodyLarge?.copyWith(
                          fontSize: CalviSize.fsCaption,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(row.$2, style: context.t.labelSmall),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Переваги списком, кожна окремим «так».
class _Perks extends StatelessWidget {
  const _Perks({required this.rows});

  final List<String> rows;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: c.cardBorder),
        borderRadius: BorderRadius.circular(CalviSize.rLarge),
        boxShadow: context.shadowCard,
      ),
      child: Column(
        children: [
          for (final (i, row) in rows.indexed) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.success.withValues(alpha: 0.16),
                  ),
                  child: CalviIcon('check', size: 12, color: c.success),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    row,
                    style: context.t.bodyLarge?.copyWith(fontSize: CalviSize.fsCaption),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Один план карткою: назва, ціна великим числом, умова списання дрібним.
///
/// Обраний обведений чорнилом, як обрана мова: це вибір серед рівних, а не
/// кнопка дії, і фарбувати його чорним означало б зробити з нього кнопку.
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.name,
    required this.price,
    required this.note,
    required this.on,
    required this.onTap,
    this.save,
  });

  final String name;
  final String price;
  final String note;
  final bool on;
  final VoidCallback onTap;

  /// Скільки економить річний, числом на чіпі. Порожньо в місячного.
  final String? save;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return CalviPress(
      onTap: onTap,
      builder: (context, down) => AnimatedScale(
        scale: down ? 0.98 : 1,
        duration: CalviMotion.fast,
        curve: CalviMotion.ease,
        child: AnimatedContainer(
          duration: CalviMotion.fast,
          curve: CalviMotion.ease,
          padding: EdgeInsets.all(on ? 13 : 14),
          decoration: BoxDecoration(
            color: c.card,
            border: Border.all(color: on ? c.button : c.cardBorder, width: on ? 2 : 1),
            borderRadius: BorderRadius.circular(CalviSize.rCard),
            boxShadow: context.shadowCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* Назва і чіп знижки в один рядок, і саме тому обидва мусять
                 уміти стискатись: на вузькому телефоні з великим системним
                 шрифтом «Рік» і «-17%» разом не влазили в половину ширини, і
                 екран показував смугастий бар замість карток. */
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.t.bodyLarge?.copyWith(
                        fontSize: CalviSize.fsCaption,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (save != null) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                        decoration: BoxDecoration(
                          color: c.success.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(CalviSize.rPill),
                        ),
                        child: Text(
                          save!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.t.labelSmall?.copyWith(
                            fontSize: 11,
                            color: c.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                price,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.t.headlineMedium?.copyWith(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(note, style: context.t.labelSmall?.copyWith(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
