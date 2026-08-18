import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/allergens.dart';
import '../../data/settings.dart';
import '../../data/app_scope.dart';
import '../meds/meds_route.dart';
import '../../design/icons.dart';
import '../../design/shell.dart';
import '../../design/slide.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../format.dart';
import 'panel_allergy.dart';
import 'panel_assistant.dart';
import 'panel_reminders.dart';
import 'panels_account.dart';
import 'panels_body.dart';

/* Handle the free tariff is arranged through. One constant, because it is the
   only address in the app and it will change with the developer, not with the
   screen. */
const devTelegram = 'calvi_dev';

const _freeLine =
    'Захисникам України, працівникам ЗСУ, ДСНС, ДТЕК, медикам, волонтерам, '
    'вчителям прифронтових зон тарифний план БЕЗКОШТОВНИЙ';

/// Settings, and the sub-screens behind each row. Every row opens something:
/// a row that leads nowhere teaches people to stop tapping rows.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /* Which sub-screen is showing, or null for the list itself. A panel is not a
     route: the demo swaps what is inside settings and slides the swap, so the
     panel arrives exactly the way settings itself arrived. Pushing a route put
     a second screen over the first, with the old list still under it sliding
     its own way, and that is the entrance that read as unfinished. */
  String? _panel;

  /// Whether anything has been opened yet, so the list does not slide on
  /// arrival: the screen is already being carried in by the route that opened
  /// it, and a second slide underneath fights the first.
  bool _moved = false;

  void _open(String id) => setState(() {
    _moved = true;
    _panel = id;
  });

  void _close() => setState(() {
    _moved = true;
    _panel = null;
  });

  /* Opens the app if it is installed and the web chat if it is not, which is
     what `externalApplication` means on every platform we ship to. Failure is
     silent on purpose: there is nothing useful to say to somebody whose phone
     has no Telegram, and an error dialog would be the app blaming them. */
  Future<void> _openTelegram() async {
    final url = Uri.parse('https://t.me/$devTelegram');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /* Medications keep a route of their own: they are reached from the day as
     well, so they are a place in the app rather than a page of settings. */
  void _openMeds(BuildContext context) =>
      Navigator.of(context).push(slideRoute(const MedsRoute()));

  /// The sub-screen behind a row, built when it is the one showing.
  Widget _panelFor(
    String id,
    SettingsState s,
    void Function(SettingsState Function(SettingsState)) set,
  ) {
    return switch (id) {
      'profile' => ProfilePanel(s: s, set: set, onBack: _close),
      'weight' => WeightPanel(s: s, set: set, onBack: _close),
      'goal' => GoalPanel(s: s, set: set, onBack: _close),
      'norm' => NormPanel(s: s, set: set, onBack: _close),
      'allergy' => AllergyPanel(s: s, set: set, onBack: _close),
      'assistant' => AssistantPanel(s: s, set: set, onBack: _close),
      'reminders' => RemindersPanel(
        s: s,
        set: set,
        onBack: _close,
        // One state, two sides: the medication screen owns it.
        medsRemind: AppScope.of(context).meds.any((m) => m.remind),
        onMedsRemind: (on) => AppScope.of(
          context,
        ).setMeds((list) => [for (final m in list) m.copyWith(remind: on)]),
        onMeds: () => _openMeds(context),
        now: DateTime.now().millisecondsSinceEpoch,
      ),
      'plan' => PlanPanel(onBack: _close),
      'theme' => ThemePanel(s: s, set: set, onBack: _close),
      'lang' => LangPanel(s: s, set: set, onBack: _close),
      'privacy' => PrivacyPanel(s: s, set: set, onBack: _close),
      'delete' => DeletePanel(onBack: _close),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final s = scope.s;
    final set = scope.set;
    final allergyValue = s.allergies.isEmpty
        ? 'не вказано'
        : s.allergies
              .map((a) => allergenById(a.id)?.name ?? '')
              .where((n) => n.isNotEmpty)
              .join(', ');

    final onKinds = s.reminders.where((r) => r.on).map((r) => r.kind).toSet();
    final remindValue = onKinds.isEmpty
        ? 'вимкнені'
        : reminderKinds
              .where((k) => onKinds.contains(k.id))
              .map((k) => k.title.toLowerCase())
              .join(', ');

    /* One screen, and what is inside it slides. Settings itself is already
       being carried in by the route that opened it, so on arrival the swap does
       not animate: dir is zero until something has actually been opened. */
    return Slide(
      value: _panel ?? 'root',
      dir: !_moved
          ? 0
          : _panel != null
          ? 1
          : -1,
      child: _panel != null
          ? _panelFor(_panel!, s, set)
          : CalviScreen(
              title: 'Налаштування',
              children: [
                CalviSection(
                  title: 'Про тебе',
                  children: [
                    CalviRow(
                      icon: 'user',
                      title: 'Профіль',
                      first: true,
                      value: '${sexLabel(s.sex)}, ${s.age}, ${s.heightCm} см',
                      onTap: () => _open('profile'),
                    ),
                    /* Weight is what you are today; where it should go is the goal's
               business. Holding both on one row made the two look like one
               decision. */
                    CalviRow(
                      icon: 'scale',
                      title: 'Вага',
                      value: '${s.weightKg.toStringAsFixed(1)} кг',
                      onTap: () => _open('weight'),
                    ),
                    CalviRow(
                      icon: 'target',
                      title: 'Ціль',
                      value: s.direction == Direction.keep
                          ? 'тримати вагу'
                          : '${s.targetKg.toStringAsFixed(1)} кг, ${s.pace.toStringAsFixed(1)}/тиждень',
                      onTap: () => _open('goal'),
                    ),
                  ],
                ),

                /* One row, not three. Macros are calculated from calories and water from
           weight; splitting numbers that move each other across separate screens
           hides from the person what they just changed. */
                CalviSection(
                  title: 'Норма',
                  children: [
                    CalviRow(
                      icon: 'flame',
                      title: 'Норма',
                      first: true,
                      value: '${thousands(dailyKcal(s))} ккал',
                      onTap: () => _open('norm'),
                    ),
                  ],
                ),

                CalviSection(
                  title: 'Здоровʼя',
                  children: [
                    CalviRow(
                      icon: 'allergy',
                      title: 'Алергії',
                      first: true,
                      value: allergyValue,
                      onTap: () => _open('allergy'),
                    ),
                    CalviRow(icon: 'pill', title: 'Препарати', onTap: () => _openMeds(context)),
                  ],
                ),

                CalviSection(
                  title: 'Помічник',
                  children: [
                    CalviRow(
                      icon: 'user',
                      title: 'Помічник',
                      first: true,
                      value: '$assistantName, памʼяті ${s.memory.length}',
                      onTap: () => _open('assistant'),
                    ),
                    CalviRow(
                      icon: 'bell',
                      title: 'Нагадування',
                      value: remindValue,
                      onTap: () => _open('reminders'),
                    ),
                  ],
                ),

                CalviSection(
                  title: 'Акаунт',
                  children: [
                    CalviRow(
                      icon: 'card',
                      title: 'Підписка',
                      first: true,
                      value: 'Безкоштовно',
                      onTap: () => _open('plan'),
                    ),
                    // Under the row it belongs to, and itself the way in: it
                    // names who pays nothing and says how to arrange that.
                    _FreeLine(onTap: () => _promo(context)),
                    CalviRow(
                      icon: 'sun',
                      title: 'Тема',
                      value: themeLabel(s.theme),
                      onTap: () => _open('theme'),
                    ),
                    CalviRow(
                      icon: 'note',
                      title: 'Мова',
                      value: langLabel(s.lang),
                      onTap: () => _open('lang'),
                    ),
                    CalviRow(
                      icon: 'shield',
                      title: 'Приватність',
                      onTap: () => _open('privacy'),
                    ),
                    CalviRow(
                      icon: 'user',
                      title: 'Видалити акаунт і дані',
                      danger: true,
                      onTap: () => _open('delete'),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Center(
                    child: Text('Calvi 0.1 · демо інтерфейсу', style: context.t.labelSmall),
                  ),
                ),
              ],
            ),
    );
  }

  void _promo(BuildContext context) {
    calviSheet(
      context,
      title: 'Безкоштовний тариф',
      doneLabel: 'Закрити',
      info: true,
      builder: (sheet) {
        final c = sheet.c;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  text:
                      'Захисникам України, працівникам ЗСУ, ДСНС, ДТЕК, медикам, волонтерам, '
                      'вчителям прифронтових зон тарифний план ',
                  children: [
                    TextSpan(
                      text: 'БЕЗКОШТОВНИЙ',
                      style: TextStyle(color: c.text, fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
                style: sheet.t.bodyMedium,
              ),
              const SizedBox(height: 16),

              /* The whole point is to land in the chat, so the link is the
                 control, not a line of text with an address to copy out, and it
                 opens Telegram rather than a browser page about Telegram. */
              GestureDetector(
                onTap: _openTelegram,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.fillSecondary,
                    borderRadius: BorderRadius.circular(CalviSize.rCard),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: c.button),
                        child: CalviIcon('send', size: 18, color: c.buttonText),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Написати в Telegram',
                              style: sheet.t.titleMedium?.copyWith(fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text('@$devTelegram', style: sheet.t.labelSmall),
                          ],
                        ),
                      ),
                      CalviIcon('chevron', size: 15, color: c.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Напишіть розробнику, і сьогодні вам активують платний тариф.',
                style: sheet.t.bodyMedium,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FreeLine extends StatelessWidget {
  const _FreeLine({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 13),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: c.cardBorder)),
        ),
        child: Text.rich(
          TextSpan(
            text: _freeLine,
            children: [
              // The way in is the last words of the sentence, not a button
              // beside it: the sentence is what makes anybody want to tap.
              TextSpan(
                text: ' Як отримати',
                style: TextStyle(color: c.text, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          style: context.t.bodyMedium?.copyWith(fontSize: CalviSize.fsMicro, height: 1.45),
        ),
      ),
    );
  }
}
