import 'package:flutter/material.dart';

import '../../data/settings.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';

typedef SetSettings = void Function(SettingsState Function(SettingsState));

/// How the app looks.
///
/// Three options rather than a switch. «Тема пристрою» is not a midpoint
/// between light and dark, it is a refusal to choose on the person's behalf, and
/// it has to stand in the row as its own decision instead of hiding in the
/// position of a toggle.
class ThemePanel extends StatelessWidget {
  const ThemePanel({super.key, required this.s, required this.set});

  final SettingsState s;
  final SetSettings set;

  @override
  Widget build(BuildContext context) {
    return CalviScreen(
      title: 'Тема',
      foot: CalviButton(label: 'Готово', onTap: () => Navigator.of(context).pop()),
      children: [
        CalviSection(
          title: 'Вигляд',
          children: [
            for (final (i, t) in themeOptions.indexed)
              CalviChoice(
                title: t.title,
                hint: t.hint,
                icon: t.icon,
                first: i == 0,
                chosen: s.theme == t.id,
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
  const LangPanel({super.key, required this.s, required this.set});

  final SettingsState s;
  final SetSettings set;

  @override
  Widget build(BuildContext context) {
    return CalviScreen(
      title: 'Мова',
      foot: CalviButton(label: 'Готово', onTap: () => Navigator.of(context).pop()),
      children: [
        CalviSection(
          title: 'Мова інтерфейсу',
          children: [
            for (final (i, l) in langOptions.indexed)
              CalviChoice(
                title: l.title,
                hint: l.hint,
                first: i == 0,
                chosen: s.lang == l.id,
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
  const PlanPanel({super.key});

  @override
  State<PlanPanel> createState() => _PlanPanelState();
}

class _PlanPanelState extends State<PlanPanel> {
  String _plan = 'year';

  @override
  Widget build(BuildContext context) {
    return CalviScreen(
      title: 'Підписка',
      foot: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.c.fillSecondary,
                  borderRadius: BorderRadius.circular(CalviSize.rCard),
                ),
                child: Text('Не зараз', style: context.t.titleMedium?.copyWith(fontSize: 15)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: CalviButton(label: 'Оформити', onTap: () => Navigator.of(context).pop()),
          ),
        ],
      ),
      children: [
        const CalviSection(title: 'Зараз', children: []),
        const CalviFacts(
          rows: [('План', 'Безкоштовний'), ('Токени', '2 на добу')],
          note: 'Безлімітні токени, історія без обмежень і звіти за будь-який період.',
        ),
        CalviSection(
          title: 'План',
          children: [
            CalviChoice(
              title: 'Рік',
              hint: '150 грн на місяць, списується раз на рік',
              first: true,
              chosen: _plan == 'year',
              onTap: () => setState(() => _plan = 'year'),
            ),
            CalviChoice(
              title: 'Місяць',
              hint: '180 грн',
              chosen: _plan == 'month',
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
  const PrivacyPanel({super.key, required this.s, required this.set});

  final SettingsState s;
  final SetSettings set;

  @override
  Widget build(BuildContext context) {
    return CalviScreen(
      title: 'Приватність',
      hint: 'Що саме залишає твій телефон, і що не залишає його ніколи.',
      foot: CalviButton(label: 'Готово', onTap: () => Navigator.of(context).pop()),
      children: [
        const CalviSection(title: 'Що ми не збираємо', children: []),
        const CalviFacts(
          rows: [],
          note:
              'Фото страв не зберігаються: знімок іде в обробку і зникає. В аналітику не '
              'потрапляють ні страви, ні вага, ні алергії, ні препарати. Це особлива категорія '
              'персональних даних, і віддавати її третій стороні не можна незалежно від '
              'зручності.',
        ),
        CalviSection(
          title: 'Що можна вимкнути',
          children: [
            CalviRow(
              icon: 'chart',
              title: 'Знеособлена статистика',
              first: true,
              trailing: CalviSwitch(
                on: s.analytics,
                onChanged: (v) => set((x) => x.copyWith(analytics: v)),
              ),
            ),
            CalviRow(
              icon: 'shield',
              title: 'Звіти про збої',
              trailing: CalviSwitch(
                on: s.crash,
                onChanged: (v) => set((x) => x.copyWith(crash: v)),
              ),
            ),
          ],
        ),
        const CalviNote(
          'Статистика каже, які екрани відкривають, і нічого про вміст записів. '
          'Звіт про збій це стек помилки, теж без щоденника.',
        ),
      ],
    );
  }
}

/// Deleting the account.
class DeletePanel extends StatefulWidget {
  const DeletePanel({super.key});

  @override
  State<DeletePanel> createState() => _DeletePanelState();
}

class _DeletePanelState extends State<DeletePanel> {
  bool _sure = false;

  @override
  Widget build(BuildContext context) {
    return CalviScreen(
      title: 'Видалити акаунт',
      hint:
          'Видаляється все: щоденник, вага, вимірювання, алергії, препарати, історія розмов. '
          'Відновити після цього неможливо.',
      foot: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.c.fillSecondary,
                  borderRadius: BorderRadius.circular(CalviSize.rCard),
                ),
                child: Text('Скасувати', style: context.t.titleMedium?.copyWith(fontSize: 15)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: CalviButton(
              label: 'Видалити назавжди',
              danger: true,
              enabled: _sure,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
      children: [
        const CalviFacts(
          rows: [
            ('Записів у щоденнику', '412'),
            ('Замірів ваги', '37'),
            ('Днів із Calvi', '94'),
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
        ),
      ],
    );
  }
}
