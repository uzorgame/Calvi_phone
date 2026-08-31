import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../data/week.dart';
import '../design/icons.dart';
import '../design/slide.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../l10n/app_localizations.dart';
import 'analytics/analytics_screen.dart';
import 'recipes/recipes_screen.dart';
import 'settings/settings_screen.dart';
import 'week/week_screen.dart';

/* Меню застосунку: картка, що випадає з кнопки в шапці.
 *
 * Доти праворуч угорі скрізь стояли налаштування, і сторінкам без власного
 * входу (рецепти, тижневий аналіз, тарифи) не було де жити. Меню дає їм дім,
 * а налаштування чесно опускає на глибину, де їм місце: їх відкривають рідко.
 *
 * Не нижній аркуш: аркуш це мова рішень, і меню в ньому виглядало як питання
 * з кнопкою «Закрити». Картка розкривається з кута, звідки її покликали, тап
 * повз неї просто закриває. Один в один із демкою 5300. */

Future<void> showCalviMenu(BuildContext context) {
  final scope = AppScope.of(context);
  final l = L.of(context);
  final c = context.c;
  final nav = Navigator.of(context);

  void go(Widget page) {
    nav.pop(); // спершу закривається меню, тоді їде сторінка
    nav.push(slideRoute(page));
  }

  final rows = <({String icon, String title, bool soon, VoidCallback? open})>[
    /* Щоденник перший: це дім застосунку, і з будь-якої глибини меню веде
       туди одним рухом. З самого дому рядок просто закриває меню. */
    (
      icon: 'book',
      title: l.menuDiary,
      soon: false,
      open: () {
        nav.pop();
        nav.popUntil((r) => r.isFirst);
      },
    ),
    (
      icon: 'chart',
      title: l.menuAnalytics,
      soon: false,
      open: () => go(AnalyticsScreen(measures: scope.stats.measures, onSettings: () {})),
    ),
    (
      icon: 'calendar',
      title: l.menuWeek,
      soon: false,
      open: () => go(WeekScreen(summary: weekSummary(scope.stats, scope.s), onSettings: () {})),
    ),
    (icon: 'utensils', title: l.menuRecipes, soon: false, open: () => go(const RecipesScreen())),
    /* Сторінки ще немає, і рядок чесно каже «скоро» замість вести в нікуди:
       мертвий пункт, який кудись веде, гірший за живий, який чекає. */
    (icon: 'user', title: l.menuNora, soon: true, open: null),
    (
      icon: 'card',
      title: l.menuPlan,
      soon: false,
      open: () => go(const SettingsScreen(panel: 'plan')),
    ),
    (
      icon: 'settings',
      title: l.menuSettings,
      soon: false,
      open: () => go(const SettingsScreen()),
    ),
    (
      icon: 'note',
      title: l.menuAbout,
      soon: false,
      open: () => go(const SettingsScreen(panel: 'about')),
    ),
  ];

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: l.menuTitle,
    // Ледь помітна тінь: сторінка під меню зараз не слухає, але нікуди не
    // зникла.
    barrierColor: c.text.withValues(alpha: 0.06),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (dialogContext, _, _) {
      final top = MediaQuery.paddingOf(dialogContext).top;
      return Stack(
        children: [
          Positioned(
            top: top + 52,
            right: 14,
            width: 236,
            child: Material(
              color: const Color(0x00000000),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: c.card,
                  border: Border.all(color: c.cardBorder),
                  borderRadius: BorderRadius.circular(CalviSize.rLarge),
                  boxShadow: context.shadowPop,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, r) in rows.indexed) ...[
                      /* Тонка риска тільки перед службовим хвостом: меню
                         читається як дві групи, а не сім однакових рядків. */
                      if (i == rows.length - 2)
                        Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          color: c.cardBorder,
                        ),
                      _Row(row: r),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
    transitionBuilder: (dialogContext, anim, _, child) {
      // Розкривається з кута, звідки її покликали.
      final t = CurvedAnimation(parent: anim, curve: CalviMotion.easeRise);
      return Opacity(
        opacity: t.value,
        child: Transform.scale(
          scale: 0.92 + 0.08 * t.value,
          alignment: Alignment.topRight,
          child: Transform.translate(offset: Offset(0, -6 * (1 - t.value)), child: child),
        ),
      );
    },
  );
}

/* Кнопка меню для шапки сторінки: коло з трьома рисками, скрізь однакова.
   Тиждень і аналітика тримали власні приватні копії, і третя на рецептах
   стала б четвертою причиною їм розійтись.

   Поки меню відкрите, риски складаються в хрестик і розкладаються назад,
   коли воно закрилось: кнопка сама показує, що зараз активна саме вона. */
class CalviMenuButton extends StatefulWidget {
  const CalviMenuButton({super.key});

  @override
  State<CalviMenuButton> createState() => _CalviMenuButtonState();
}

class _CalviMenuButtonState extends State<CalviMenuButton> {
  bool _open = false;
  bool _down = false;

  Future<void> _tap() async {
    setState(() => _open = true);
    await showCalviMenu(context);
    if (mounted) setState(() => _open = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: _tap,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: CalviMotion.fast,
        curve: CalviMotion.ease,
        width: 38,
        height: 38,
        alignment: Alignment.center,
        /* Біла таблетка з тінню, як кнопка «Назад» і кнопки шапки демки:
           сіре коло на тонованому ґрунті зливалося з ним і читалось темнішим
           за сусідів. */
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _down ? c.hover : c.card,
          border: Border.all(color: c.cardBorder),
          boxShadow: context.shadowCard,
        ),
        child: MenuGlyph(open: _open),
      ),
    );
  }
}

/// Три риски, намальовані контейнерами, а не SVG: іконку з файлу не
/// анімувати між двома формами, а рискам досить трансформацій.
class MenuGlyph extends StatelessWidget {
  const MenuGlyph({super.key, required this.open});

  final bool open;

  @override
  Widget build(BuildContext context) {
    final bar = Container(
      width: 13,
      height: 1.6,
      decoration: BoxDecoration(
        color: context.c.text,
        borderRadius: BorderRadius.circular(CalviSize.rPill),
      ),
    );

    // Крайні риски їдуть у центр і повертаються на 45 градусів, середня гасне.
    Widget slat({required double rest, required double turn}) => AnimatedContainer(
      duration: CalviMotion.normal,
      curve: CalviMotion.easeRise,
      transformAlignment: Alignment.center,
      transform: open ? Matrix4.rotationZ(turn) : Matrix4.translationValues(0, rest, 0),
      child: bar,
    );

    return SizedBox(
      width: 16,
      height: 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          slat(rest: -4.2, turn: math.pi / 4),
          AnimatedOpacity(
            duration: CalviMotion.normal,
            curve: CalviMotion.ease,
            opacity: open ? 0 : 1,
            child: bar,
          ),
          slat(rest: 4.2, turn: -math.pi / 4),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.row});

  final ({String icon, String title, bool soon, VoidCallback? open}) row;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);

    return GestureDetector(
      onTap: row.soon ? null : row.open,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Opacity(
              opacity: row.soon ? 0.45 : 1,
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: c.iconCircle),
                child: CalviIcon(row.icon, size: 17),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Opacity(
                opacity: row.soon ? 0.45 : 1,
                child: Text(
                  row.title,
                  style: context.t.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ),
            if (row.soon)
              Text(l.menuSoon, style: context.t.labelSmall?.copyWith(color: c.faint)),
          ],
        ),
      ),
    );
  }
}
