import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/allergens.dart';
import '../data/app_scope.dart';
import '../data/day.dart' show todayDate;
import '../data/meds.dart';
import '../data/week.dart';
import '../design/icons.dart';
import '../design/slide.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import 'analytics/analytics_screen.dart';
import 'meds/meds_route.dart';
import 'recipes/recipes_screen.dart';
import 'settings/settings_screen.dart';
import 'week/week_screen.dart';

/* Меню застосунку: картка, що випадає з кнопки в шапці.
 *
 * Доти праворуч угорі скрізь стояли налаштування, і сторінкам без власного
 * входу (рецепти, тижневий аналіз, алергії) не було де жити. Меню дає їм дім,
 * а налаштування чесно опускає на глибину, де їм місце: їх відкривають рідко.
 *
 * Не нижній аркуш: аркуш це мова рішень, і меню в ньому виглядало як питання
 * з кнопкою «Закрити». Картка розкривається з кута, звідки її покликали, тап
 * повз неї просто закриває. Один в один із демкою 5300.
 *
 * Під кожним пунктом живий рядок з екрана, куди він веде: скільки записано,
 * чи відкритий розбір, які курси, який тариф. Меню відповідає ще до того, як
 * у нього зайшли, і половина заходів стає непотрібною. */

Future<void> showCalviMenu(BuildContext context) {
  final scope = AppScope.of(context);
  final l = L.of(context);
  final c = context.c;
  final nav = Navigator.of(context);

  void go(Widget page) {
    nav.pop(); // спершу закривається меню, тоді їде сторінка
    nav.push(slideRoute(page));
  }

  /* Підказки. Числа беруться з того, що вже є в памʼяті: меню має відкритись
     миттєво, і жоден рядок не чекає на базу. Виняток один: тариф, який живе
     в потоці токенів, і той рядок оновлюється сам, щойно потік відповість. */
  final kcal = scope.stats.totalsOn(todayDate).kcal;
  final week = weekSummary(scope.stats, scope.s);
  final running = [for (final m in medsAhead(scope.meds)) m.name];
  final allergies = [
    for (final a in scope.s.allergies) allergenById(a.id)?.name,
  ].whereType<String>().toList();
  final reviewIsOpen = reviewOpen();
  final plan = scope.db?.syncDao.watchTokens().map(
    (t) => t?.syncedAt != null && t?.unlimited == true ? l.planOn : l.menuHintFree,
  );

  /* Три групи, розділені тонкою рискою: день і його числа, потім те, що людина
     про себе веде, потім службовий хвіст. Девʼять однакових рядків підряд
     читались як список, у якому треба шукати; три купки по три читаються з
     одного погляду.

     `gap` означає «тут починається наступна група». Доти риску малював
     порядковий номер рядка, тобто вона трималась на тому, скільки їх у меню,
     і при кожній зміні переїжджала не туди.  */
  final rows = <_MenuRow>[
    /* Щоденник перший: це дім застосунку, і з будь-якої глибини меню веде
       туди одним рухом. З самого дому рядок просто закриває меню. */
    _MenuRow(
      icon: 'book',
      title: l.menuDiary,
      hint: kcal > 0 ? l.menuHintKcal(kcal) : l.menuHintNothing,
      open: () {
        nav.pop();
        nav.popUntil((r) => r.isFirst);
      },
    ),
    _MenuRow(
      icon: 'chart',
      title: l.menuAnalytics,
      hint: week.daysFinished > 0
          ? l.menuHintOnGoal(week.daysOnGoal, week.daysFinished)
          : l.menuHintWeekYoung,
      open: () => go(AnalyticsScreen(measures: scope.stats.measures, onSettings: () {})),
    ),
    // Вікно розбору відкрите: крапка каже, що зайти варто саме зараз.
    _MenuRow(
      icon: 'calendar',
      title: l.menuWeek,
      hint: reviewIsOpen ? l.menuHintWeekOpen : l.menuHintWeekFriday,
      live: reviewIsOpen,
      open: () => go(WeekScreen(summary: weekSummary(scope.stats, scope.s), onSettings: () {})),
    ),

    /* Своє: книга рецептів, курси препаратів, алергії. Усе троє впливає на те,
       що радить Нора, і доти лежало по різних кутах застосунку: препарати
       відкривались лише з картки дня, алергії ховались за двома дотиками в
       налаштуваннях. */
    _MenuRow(
      icon: 'utensils',
      title: l.menuRecipes,
      hint: l.menuHintRecipes,
      gap: true,
      open: () => go(const RecipesScreen()),
    ),
    _MenuRow(
      icon: 'pill',
      title: l.menuMeds,
      hint: l.menuHintNoMeds,
      hintItems: running,
      open: () => go(const MedsRoute()),
    ),
    _MenuRow(
      icon: 'allergy',
      title: l.menuAllergy,
      hint: l.menuHintNoAllergy,
      hintItems: allergies,
      open: () => go(const SettingsScreen(panel: 'allergy')),
    ),

    _MenuRow(
      icon: 'card',
      title: l.menuPlan,
      hint: l.menuHintFree,
      hintStream: plan,
      gap: true,
      open: () => go(const SettingsScreen(panel: 'plan')),
    ),
    /* «Про застосунок» тут немає навмисно, як і тарифів.
     *
     * Версію і пошту розробника відкривають раз за весь час, і рядок, який
     * щодня стоїть у меню поряд із щоденником, обіцяє більше, ніж за ним є.
     * Дорога до нього лишилась там, де їй місце: рядком у налаштуваннях. */
    _MenuRow(
      icon: 'settings',
      title: l.menuSettings,
      hint: '${langTitle(context, scope.s.lang)}, ${themeTitle(context, scope.s.theme)}',
      open: () => go(const SettingsScreen()),
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
            /* Ширше за колишні 236: під назвою тепер рядок, і «горіхи,
               лактоза» має вміститись без крапок у звичайному випадку. */
            width: 268,
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
                    for (final r in rows) ...[
                      // Риска перед першим рядком групи, див. примітку в rows.
                      if (r.gap)
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

class _MenuRow {
  const _MenuRow({
    required this.icon,
    required this.title,
    required this.hint,
    required this.open,
    this.hintItems = const [],
    this.hintStream,
    this.live = false,
    this.gap = false,
  });

  final String icon;
  final String title;

  /// Живий рядок з екрана, куди веде пункт. Для списку це слова на випадок,
  /// коли він порожній.
  final String hint;

  /// Список назв: скільки вміщається, стільки й стоїть, решта хвостом «ще 2».
  final List<String> hintItems;

  /// Підказка, яка приїжджає пізніше за меню; [hint] стоїть, доки її немає.
  final Stream<String>? hintStream;

  /// Зелена крапка перед підказкою: це чекає саме сьогодні.
  final bool live;

  /// «Тут починається наступна група»: риска перед рядком.
  final bool gap;

  final VoidCallback open;
}

/* Рядок на два поверхи: назва і під нею підказка. 54 замість 42, бо два
   рядки тексту в 42 стискаються до нечитаного. */
class _Row extends StatelessWidget {
  const _Row({required this.row});

  final _MenuRow row;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final stream = row.hintStream;
    final hint = row.hintItems.isNotEmpty
        ? _FitList(items: row.hintItems)
        : stream == null
            ? _Hint(text: row.hint, live: row.live)
            : StreamBuilder<String>(
                stream: stream,
                initialData: row.hint,
                builder: (_, snap) => _Hint(text: snap.data ?? row.hint, live: row.live),
              );

    return GestureDetector(
      onTap: row.open,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.iconCircle),
              child: CalviIcon(row.icon, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    row.title,
                    style: context.t.bodyMedium?.copyWith(fontWeight: FontWeight.w500, height: 1.15),
                  ),
                  const SizedBox(height: 3),
                  hint,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Стиль підказки, один на текст і на список, щоб хвіст «ще 2» не відрізнявся
/// від назв перед ним.
TextStyle? _hintStyle(BuildContext context) =>
    context.t.bodySmall?.copyWith(fontSize: 12, height: 1.2, color: context.c.textSecondary);

/// Підказка одним рядком.
class _Hint extends StatelessWidget {
  const _Hint({required this.text, required this.live});

  final String text;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(
      children: [
        if (live) ...[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c.success),
          ),
          const SizedBox(width: 5),
        ],
        Expanded(
          child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: _hintStyle(context)),
        ),
      ],
    );
  }
}

/* Список одним рядком: скільки назв уміщається, стільки й стоїть, замість
   решти «ще 2». Міряється до малювання, тим самим стилем і масштабом
   шрифту, що й сам рядок. Крапки ховали б, скільки саме курсів за ними, а
   число каже. */
class _FitList extends StatelessWidget {
  const _FitList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final style = _hintStyle(context);
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);

    return LayoutBuilder(
      builder: (context, box) {
        var text = items.join(', ');
        for (var n = items.length; n >= 1; n--) {
          final rest = items.length - n;
          text = rest == 0 ? items.join(', ') : '${items.take(n).join(', ')}, ${l.menuHintMore(rest)}';
          final painter = TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: direction,
            textScaler: scaler,
            maxLines: 1,
          )..layout();
          final fits = painter.width <= box.maxWidth;
          painter.dispose();
          if (fits) break;
        }
        return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: style);
      },
    );
  }
}
