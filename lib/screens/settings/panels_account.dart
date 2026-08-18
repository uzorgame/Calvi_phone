import 'package:flutter/material.dart';

import '../../data/settings.dart';
import '../../design/shell.dart';

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
    return CalviScreen(
      onBack: onBack,
      title: 'Тема',
      foot: CalviButton(label: 'Готово', onTap: () => (onBack ?? Navigator.of(context).pop)()),
      children: [
        CalviSection(
          title: 'Вигляд',
          bare: true,
          children: [
            for (final t in themeOptions)
              CalviPick(
                label: t.title,
                hint: t.hint,
                icon: t.icon,
                on: s.theme == t.id,
                onTap: () => set((v) => v.copyWith(theme: t.id)),
              ),
          ],
        ),
        const CalviNote(
          'Темна тема тут нейтральна, без синього відтінку: чорнило застосунку в ній '
          'перевертається у світле, а не міняє колір.',
        ),
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
    return CalviScreen(
      onBack: onBack,
      title: 'Мова',
      foot: CalviButton(label: 'Готово', onTap: () => (onBack ?? Navigator.of(context).pop)()),
      children: [
        CalviSection(
          title: 'Мова інтерфейсу',
          bare: true,
          children: [
            for (final l in langOptions)
              CalviPick(
                label: l.title,
                hint: l.hint,
                on: s.lang == l.id,
                onTap: () => set((v) => v.copyWith(lang: l.id)),
              ),
          ],
        ),
        const CalviNote(
          'Переклад англійською ще не зроблено: поки вибір лише запамʼятовується.',
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
    return CalviScreen(
      onBack: widget.onBack,
      title: 'Підписка',
      foot: CalviButton(
        label: 'Оформити',
        onTap: () => (widget.onBack ?? Navigator.of(context).pop)(),
        second: 'Не зараз',
        onSecond: () => (widget.onBack ?? Navigator.of(context).pop)(),
      ),
      children: [
        const CalviSection(
          title: 'Зараз',
          bare: true,
          trail: 0,
          children: [
            CalviFacts(
              inset: false,
              rows: [('План', 'Безкоштовний'), ('Токени', '2 на добу')],
              note: 'Безлімітні токени, історія без обмежень і звіти за будь-який період.',
            ),
          ],
        ),
        CalviSection(
          title: 'План',
          bare: true,
          children: [
            CalviPick(
              label: 'Рік',
              hint: '150 грн на місяць, списується раз на рік',
              on: _plan == 'year',
              onTap: () => setState(() => _plan = 'year'),
            ),
            CalviPick(
              label: 'Місяць',
              hint: '180 грн',
              on: _plan == 'month',
              onTap: () => setState(() => _plan = 'month'),
            ),
          ],
        ),
        const CalviNote(
          'Оплата проходить через App Store або Google Play. Скасувати можна там само, '
          'у налаштуваннях передплат, і Calvi на це не впливає.',
        ),
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
    return CalviScreen(
      onBack: onBack,
      title: 'Приватність',
      hint: 'Що саме залишає твій телефон, і що не залишає його ніколи.',
      foot: CalviButton(label: 'Готово', onTap: () => (onBack ?? Navigator.of(context).pop)()),
      children: [
        const CalviSection(
          title: 'Що ми не збираємо',
          bare: true,
          trail: 0,
          children: [
            CalviFacts(
              inset: false,
              rows: [],
              note: 'Фото страв ',
              noteBold: 'не зберігаються',
              noteRest:
                  ': знімок іде в обробку і зникає. В аналітику не потрапляють ні страви, ні '
                  'вага, ні алергії, ні препарати. Це особлива категорія персональних даних, і '
                  'віддавати її третій стороні не можна незалежно від зручності.',
            ),
          ],
        ),
        CalviSection(
          title: 'Що можна вимкнути',
          children: [
            CalviRow(
              icon: 'chart',
              first: true,
              title: 'Знеособлена статистика',
              hint: 'які екрани відкривають, без вмісту записів',
              trailing: CalviSwitch(
                on: s.analytics,
                onChanged: (v) => set((x) => x.copyWith(analytics: v)),
              ),
            ),
            CalviRow(
              icon: 'shield',
              title: 'Звіти про збої',
              hint: 'стек помилки, без даних щоденника',
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
    return CalviScreen(
      onBack: widget.onBack,
      title: 'Видалити акаунт',
      hint:
          'Видаляється все: щоденник, вага, вимірювання, алергії, препарати, історія розмов. '
          'Відновити після цього неможливо.',
      foot: CalviButton(
        label: 'Видалити назавжди',
        enabled: _sure,
        danger: true,
        onTap: () => (widget.onBack ?? Navigator.of(context).pop)(),
        second: 'Скасувати',
        onSecond: () => (widget.onBack ?? Navigator.of(context).pop)(),
      ),
      children: [
        const CalviSection(
          bare: true,
          trail: 0,
          children: [
            CalviFacts(
              inset: false,
              rows: [
                ('Записів у щоденнику', '412'),
                ('Замірів ваги', '37'),
                ('Днів із Calvi', '94'),
              ],
            ),
          ],
        ),
        CalviCheck(
          on: _sure,
          onToggle: () => setState(() => _sure = !_sure),
          text: 'Я розумію, що дані буде видалено назавжди і відновити їх не вийде.',
        ),
        const CalviNote(
          'Якщо річ у підписці, її можна скасувати окремо в App Store або Google Play, '
          'не видаляючи акаунт.',
          lead: 12,
        ),
      ],
    );
  }
}
