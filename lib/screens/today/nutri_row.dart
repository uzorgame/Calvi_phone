/// Другий рівень нутрієнтів під картками макросів.
library;

import 'package:flutter/material.dart';

import '../../data/meal.dart';
import '../../data/nutrients.dart';
import '../../design/icons.dart';
import '../../design/ring.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../l10n/app_localizations.dart';

/* Один нутрієнт, як його бачить екран: знак, підпис, тон і всі слова шторки.
 *
 * Зібрано в одному місці, бо інакше пʼять назв жили б у ряду, пʼять описів у
 * шторці, а пʼять тонів у таблиці кольорів, і додати шостий нутрієнт означало б
 * не забути про три різні файли. */
class _Fact {
  const _Fact({
    required this.key,
    required this.icon,
    required this.title,
    required this.short,
    required this.what,
    required this.norm,
    required this.source,
    required this.tint,
    this.note,
  });

  final NutrientKey key;
  final String icon;
  final String title;
  final String short;
  final String what;
  final String norm;
  final String source;
  final Color tint;
  final String? note;
}

/* Пʼять описів, зібраних із норми самої людини.
 *
 * Кольори не нові: усі пʼять уже є в темі, і три з них значать те саме, що й у
 * ряду макросів над цим. Цукор бере колір вуглеводів, бо він і є вуглевод;
 * насичені беруть колір жирів з тієї ж причини. Клітковина зелена, бо це єдине
 * число, якого добирають. Натрій сірий, бо він ні до чого з цього не належить.
 * Теракотовий у ряду не зайнятий нікому навмисно: він приходить тільки тоді,
 * коли стелю перебрано. */
List<_Fact> _facts(BuildContext context, NutrientGoal goal) {
  final l = L.of(context);
  final c = context.c;

  return [
    _Fact(
      key: NutrientKey.fiber,
      icon: 'leaf',
      title: l.nutriFiber,
      short: l.nutriFiberShort,
      what: l.nutriFiberWhat,
      norm: l.nutriFiberNorm(goal.fiber),
      source: l.nutriFiberSource,
      tint: c.success,
    ),
    _Fact(
      key: NutrientKey.sugar,
      icon: 'candy',
      title: l.nutriSugar,
      short: l.nutriSugarShort,
      what: l.nutriSugarWhat,
      norm: l.nutriSugarNorm,
      source: l.nutriSugarSource,
      note: l.nutriSugarNote,
      tint: c.carbs,
    ),
    _Fact(
      key: NutrientKey.added,
      icon: 'cubes',
      title: l.nutriAdded,
      short: l.nutriAddedShort,
      what: l.nutriAddedWhat,
      norm: l.nutriAddedNorm(goal.added, goal.addedBetter),
      source: l.nutriAddedSource,
      tint: c.protein,
    ),
    _Fact(
      key: NutrientKey.sodium,
      icon: 'salt',
      title: l.nutriSodium,
      short: l.nutriSodiumShort,
      what: l.nutriSodiumWhat,
      norm: l.nutriSodiumNorm,
      source: l.nutriSodiumSource,
      note: l.nutriSodiumNote,
      tint: c.textSecondary,
    ),
    _Fact(
      key: NutrientKey.sat,
      icon: 'butter',
      title: l.nutriSat,
      short: l.nutriSatShort,
      what: l.nutriSatWhat,
      norm: l.nutriSatNorm(goal.sat),
      source: l.nutriSatSource,
      tint: c.fats,
    ),
  ];
}

/// Число так, як його показують у ряду. Порожньо означає «не знаємо».
String? _shown(NutrientDay day, NutrientKey k) {
  final v = day.sum[k];
  if (v == null) return null;
  /* Натрій у грамах, а не в міліграмах, хоч на пачках друкують міліграми:
     «1316» удвічі довше за сусідів і ламає ряд. Скільки це солі, каже шторка. */
  return k == NutrientKey.sodium ? (v / 1000).toStringAsFixed(1) : '${v.round()}';
}

/// Яку частку норми набрано. Без норми і без числа це нуль: малювати нема чого.
double _part(NutrientDay day, NutrientGoal goal, NutrientKey k) {
  final v = day.sum[k];
  final of = goal.of(k);
  if (v == null || of == null || of == 0) return 0;
  return v / of;
}

/* Другий рівень нутрієнтів: одна смуга, пʼять стовпчиків, два розміри.
 *
 * **Малий за замовчуванням.** Це нагляд, а не план: на ці числа дивляться краєм
 * ока і реагують, коли щось вилізло за межу. Великий вигляд лишається, але як
 * особистий вибір у персоналізації, бо той, хто справді рахує клітковину, хоче
 * бачити її поруч із білком, а не дрібним рядком.
 *
 * **Увесь ряд навмисно тихий.** Над ним уже стоять чотири кольорові кільця
 * макросів; пʼять нових кольорів зробили б з екрана світлофор. Колір тут це не
 * оформлення, а подія: перебрали стелю, і знак теплішає разом із числом.
 * Клітковина навпаки зеленіє, коли набрана: вона єдина з пʼяти, якої добирають.
 *
 * **Порожнє лишається порожнім.** Страва, записана до появи цієї можливості,
 * не має цих чисел і вже не матиме. Показати за неї нуль означало б сказати, що
 * клітковини в ній не було. Тому день, у якому не пораховано нічого, каже це
 * словами замість пʼяти знаків питання, а день, у якому не пораховано частину,
 * лишає числа як є: наскільки їм вірити, написано в шторці, бо це речення, а не
 * значок.
 */
class NutriRow extends StatelessWidget {
  const NutriRow({
    super.key,
    required this.day,
    required this.goal,
    required this.meals,
    this.large = false,
  });

  final NutrientDay day;
  final NutrientGoal goal;

  /// Потрібні шторці: вона каже, які страви дали найбільше.
  final List<Meal> meals;

  final bool large;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);

    final box = BoxDecoration(
      color: c.card,
      border: Border.all(color: c.cardBorder),
      borderRadius: BorderRadius.circular(CalviSize.rCard),
      boxShadow: context.shadowCard,
    );

    /* Про день не відомо нічого з пʼяти: усі записи старші за саму можливість.
       Пʼять знаків питання в ряд це не чесність, а поламаний екран. */
    if (!day.sum.knownAny) {
      /* Записи в дні є, а порахованих серед них немає. Тут потрібні саме слова:
         мовчання читалось би як «застосунок не порахував», і пояснити це нічим,
         крім речення. */
      if (day.counted > 0) {
        return Container(
          width: double.infinity,
          decoration: box,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Text(
            l.nutriNone,
            textAlign: TextAlign.center,
            style: context.t.labelSmall?.copyWith(fontSize: CalviSize.fsMicro, height: 1.35),
          ),
        );
      }

      /* Порожній день: самі знаки, тихо, без чисел і без підписів.
       *
       * Тут стояв рядок «Нутрієнти зʼявляться з першим записом». Він повідомляв
       * те, що людина й так бачить: у дні немає жодного запису, отже й чисел
       * узятись нізвідки. Ряд знаків на тому самому місці каже це без слів і
       * заразом показує, що саме тут зʼявиться. */
      return Container(
        decoration: box,
        padding: large
            ? const EdgeInsets.fromLTRB(6, 14, 6, 12)
            : const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            for (final f in _facts(context, goal))
              Expanded(
                child: Padding(
                  padding: large
                      ? const EdgeInsets.symmetric(horizontal: 2, vertical: 4)
                      : const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                  child: Opacity(
                    opacity: 0.45,
                    child: large
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _Mark(
                                icon: f.icon,
                                tint: f.tint,
                                over: false,
                                full: false,
                                plain: false,
                              ),
                              const SizedBox(height: 7),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  f.short,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: context.t.labelSmall?.copyWith(
                                    fontSize: 8,
                                    letterSpacing: 0.08,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: _Mark(
                              icon: f.icon,
                              tint: f.tint,
                              over: false,
                              full: false,
                              plain: true,
                            ),
                          ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Container(
      decoration: box,
      padding: large
          ? const EdgeInsets.fromLTRB(6, 14, 6, 12)
          : const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          for (final f in _facts(context, goal))
            Expanded(
              child: _Cell(fact: f, day: day, goal: goal, meals: meals, large: large),
            ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.fact,
    required this.day,
    required this.goal,
    required this.meals,
    required this.large,
  });

  final _Fact fact;
  final NutrientDay day;
  final NutrientGoal goal;
  final List<Meal> meals;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    final now = _shown(day, fact.key);
    final part = _part(day, goal, fact.key);

    /* Перебір стелі лишається перебором і на неповному дні: якщо натрію вже
       більше за норму, решта страв цього не відмінить. А от «мало» на неповному
       дні сказати не можна, і ми його й не кажемо: тон під межею однаковий для
       всіх. */
    final aims = NutrientGoal.reached(fact.key);
    final over = !aims && goal.of(fact.key) != null && part > 1;
    final full = aims && part >= 1;
    final tone = over
        ? c.protein
        : full
        ? c.success
        : c.textSecondary;

    final mark = _Mark(icon: fact.icon, tint: fact.tint, over: over, full: full, plain: !large);

    /* Назва вголос: у малому ряду підпису немає взагалі, а «5 г» без слова це
       загадка і для ока, і для читача екрана. Число туди ж, бо воно і є
       відповідь. */
    return Semantics(
      button: true,
      label: '${fact.title}: ${now ?? '?'}${L.of(context).unitG}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _open(context),
        child: Padding(
          padding: large
              ? const EdgeInsets.symmetric(horizontal: 2, vertical: 4)
              : const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          child: large
              /* Стовпчик за змістом, а не за наявною висотою. У прокрутці різниці
               немає, бо там висота й так необмежена, але варто поставити цей ряд
               у коробку з висотою, і кожна клітинка розтягнеться на всю. */
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CalviRing(
                      progress: goal.of(fact.key) == null ? 0 : part.clamp(0, 1),
                      size: 36,
                      stroke: 2.5,
                      /* Кільце свого кольору, а не сірого: у великому вигляді
                         воно обводить знак, і сіра дуга навколо зеленого листка
                         читалась як чужа деталь. Стан кільце все одно каже:
                         перебрана стеля перефарбовує його в теракотовий, а
                         набрана клітковина в зелений, тобто рівно тоді, коли є
                         про що сказати. */
                      color: over
                          ? c.protein
                          : full
                          ? c.success
                          : fact.tint,
                      /* І доріжка теж своя, тільки блідіша: сіре кільце навколо
                         кольорового знака читалось як чужа деталь, а не як
                         власна шкала цього нутрієнта. У загального цукру її
                         немає взагалі, бо немає й норми. */
                      track: goal.of(fact.key) == null
                          ? const Color(0x00000000)
                          : fact.tint.withValues(alpha: 0.18),
                      child: mark,
                    ),
                    const SizedBox(height: 7),
                    _Value(now: now, tone: over || full ? tone : null),
                    const SizedBox(height: 5),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        fact.short,
                        maxLines: 1,
                        softWrap: false,
                        style: context.t.labelSmall?.copyWith(fontSize: 8, letterSpacing: 0.08),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    mark,
                    const SizedBox(width: 5),
                    Flexible(
                      child: _Value(now: now, tone: over || full ? tone : null, small: true),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    calviSheet<void>(
      context,
      title: fact.title,
      info: true,
      doneLabel: L.of(context).actionGotIt,
      builder: (sheet) => _Sheet(fact: fact, day: day, goal: goal, meals: meals),
    );
  }
}

/// Знак у мʼякому колі. Колір приходить тільки зі стану.
class _Mark extends StatelessWidget {
  const _Mark({
    required this.icon,
    required this.tint,
    required this.over,
    required this.full,
    required this.plain,
  });

  final String icon;
  final Color tint;
  final bool over;
  final bool full;

  /// Малий ряд: сам знак, без підкладки. Пʼять кіл у рядку під картками
  /// читались як другий ряд кнопок.
  final bool plain;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final ink = over ? c.protein : tint;

    if (plain) return CalviIcon(icon, size: 14, color: ink);

    /* Перебрали стелю: знак стає теракотовим, а підкладка густішою. Саме
       густіша підкладка тут головна: у доданого цукру теракотовий і так власний
       тон, і без неї стан «перебрали» був би невидимий рівно там, де він
       найважливіший. */
    final wash = over
        ? c.protein.withValues(alpha: 0.30)
        : full
        ? c.success.withValues(alpha: 0.26)
        : tint.withValues(alpha: 0.13);

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(color: wash, shape: BoxShape.circle),
      child: Center(child: CalviIcon(icon, size: 14, color: ink)),
    );
  }
}

/* Число з одиницею, і більше нічого.
 *
 * Тут стояв плюс: «щонайменше стільки», коли в дні є страви без цих чисел.
 * Читався він як загадка, а стояв би майже завжди, бо все, записане до появи
 * такого підрахунку, лишається без нього назавжди. Про межу точності каже
 * шторка, і каже словами. Знак питання лишається: він про інше, про те, що
 * числа немає взагалі, а нуль на його місці сказав би, що цього не було. */
class _Value extends StatelessWidget {
  const _Value({required this.now, required this.tone, this.small = false});

  final String? now;
  final Color? tone;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);

    final unit = context.t.labelSmall?.copyWith(
      fontSize: 9,
      fontWeight: FontWeight.w500,
      color: c.textSecondary,
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text.rich(
        TextSpan(
          text: now ?? '?',
          children: [
            /* Волосок між числом і одиницею.
             *
             * Доти вони стояли впритул, і «8г» читалось як одне слово: дрібна
             * сіра літера липла до великої чорної цифри. У демці цей відступ є
             * (`margin-left: 1px` на одиниці), і саме його тут бракувало.
             * Порожнеча коробкою, а не пробілом: пробіл залежить від шрифту, а
             * тут потрібен рівно волосок. */
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: SizedBox(width: 2),
            ),
            TextSpan(text: l.unitG, style: unit),
          ],
        ),
        maxLines: 1,
        softWrap: false,
        style: context.t.headlineMedium?.copyWith(
          fontSize: small ? 13 : 15,
          fontWeight: FontWeight.w700,
          /* Порожнє гасне, а не зникає: знак питання стоїть рівно там, де
             стояло б число, і тим самим кеглем. */
          color: now == null ? c.textSecondary.withValues(alpha: 0.65) : tone,
        ),
      ),
    );
  }
}

/// Що написано в шторці: скільки набралось, що це таке і яка норма саме тут.
class _Sheet extends StatelessWidget {
  const _Sheet({required this.fact, required this.day, required this.goal, required this.meals});

  final _Fact fact;
  final NutrientDay day;
  final NutrientGoal goal;
  final List<Meal> meals;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);

    final v = day.sum[fact.key];
    final now = _shown(day, fact.key);
    /* Ціла частка і підрізана. Смуга малюється підрізаною, бо далі краю немає
       куди рости, а тон береться з цілої: рівно на нормі стеля ще не перебрана,
       і смуга має казати те саме, що й число в ряду, з якого сюди прийшли. */
    final whole = _part(day, goal, fact.key);
    final part = whole.clamp(0.0, 1.0);
    final left = day.unknown[fact.key] ?? 0;

    /* Найважливіший рядок, тому він перший і великий. «Щонайменше» несе всю
       вагу: 12 г при трьох непорахованих стравах це не 12, і людина, яка цього
       не знає, добиратиме клітковину, якої вже досить. */
    final line = now == null
        ? l.nutriUnknown
        : switch (fact.key) {
            NutrientKey.sugar => l.nutriNowSugar(
              now,
              day.sum[NutrientKey.added] == null ? '?' : '${day.sum[NutrientKey.added]!.round()}',
            ),
            NutrientKey.sodium => l.nutriNowSodium(now, saltFrom(v!).toStringAsFixed(1)),
            _ => l.nutriNowGoal(now, goal.of(fact.key) ?? 0),
          };

    final head = now != null && left > 0 ? l.nutriAtLeast(line) : line;

    final sources = _sources();

    /* Поля аркуш не ставить, їх ставить те, що в ньому: у різних аркушів різний
       вміст, і однакове поле для картки і для списку було б не те саме поле.
       Прокрутка тут не про довгий текст, а про довгу мову: німецький опис із
       нотаткою внизу переростає стелю аркуша у три чверті екрана. */
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 2, CalviSize.gutter, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        /* За змістом, а не на всю висоту аркуша. Без цього шторка виростала до
           своєї стелі в три чверті екрана, і між останнім рядком і кнопкою
           лишалась долоня порожнечі. */
        mainAxisSize: MainAxisSize.min,
        children: [
          /* Знак той самий, що на картці, з якої сюди прийшли: шторка має
           показати, що вона про це число, до того як її почнуть читати. */
          Row(
            children: [
              _Mark(icon: fact.icon, tint: fact.tint, over: false, full: false, plain: false),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  head,
                  style: context.t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          // Смуга під числом: скільки це від норми, з одного погляду. У загального
          // цукру її немає, бо норми в нього немає.
          if (goal.of(fact.key) != null && now != null) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: part,
                minHeight: 5,
                backgroundColor: c.hairline,
                valueColor: AlwaysStoppedAnimation(
                  NutrientGoal.reached(fact.key)
                      ? (whole >= 1 ? c.success : fact.tint)
                      : (whole > 1 ? c.protein : fact.tint),
                ),
              ),
            ),
          ],

          /* Чого в цьому числі бракує. Стоїть одразу під смугою, а не в кінці:
           людина читає число, і наступне, що вона має знати, це наскільки
           йому можна вірити. */
          if (left > 0) ...[
            const SizedBox(height: 9),
            Text(
              left == day.counted ? l.nutriGapAll : l.nutriGap(left),
              style: context.t.labelSmall?.copyWith(fontSize: CalviSize.fsMicro, height: 1.45),
            ),
          ],

          const SizedBox(height: 15),
          Text(fact.what, style: context.t.bodySmall?.copyWith(height: 1.5)),

          // Норма окремим блоком, а не абзацом: її шукають очима, а не читають.
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 13),
            decoration: BoxDecoration(
              border: Border.all(color: c.cardBorder),
              borderRadius: BorderRadius.circular(CalviSize.rCard),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.nutriNorm, style: context.t.labelSmall),
                const SizedBox(height: 3),
                Text(
                  fact.norm,
                  style: context.t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  fact.source,
                  style: context.t.labelSmall?.copyWith(fontSize: CalviSize.fsMicro, height: 1.4),
                ),
              ],
            ),
          ),

          /* Звідки це число сьогодні. Єдина частина шторки, яка перетворює число
           на дію: «1.3 г натрію» не каже нічого, «сосиски дали 0.8 з них» каже
           все. Три страви і хвіст: довший список тут читали б як таблицю, а не
           як відповідь. */
          if (sources.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
              decoration: BoxDecoration(
                color: c.hover,
                borderRadius: BorderRadius.circular(CalviSize.rCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.nutriFrom, style: context.t.labelSmall),
                  const SizedBox(height: 7),
                  for (final r in sources.take(3))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              r.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.t.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            fact.key == NutrientKey.sodium
                                ? '${(r.value / 1000).toStringAsFixed(1)}${l.unitG}'
                                : '${r.value.round()}${l.unitG}',
                            style: context.t.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  if (sources.length > 3)
                    Text(
                      l.nutriRest(sources.length - 3),
                      style: context.t.labelSmall?.copyWith(fontSize: CalviSize.fsMicro),
                    ),
                ],
              ),
            ),
          ],

          if (fact.note != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(left: 14),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: c.hairline, width: 2)),
              ),
              child: Text(
                fact.note!,
                style: context.t.labelSmall?.copyWith(fontSize: CalviSize.fsMicro, height: 1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Страви, які дали найбільше. Нулі й непораховані сюди не потрапляють:
  /// страва без клітковини це не внесок, а шум у списку.
  List<({String title, double value})> _sources() {
    final rows = <({String title, double value})>[];
    for (final m in meals) {
      final v = m.nutrients[fact.key];
      if (v != null && v > 0.05) rows.add((title: m.title, value: v));
    }
    rows.sort((a, b) => b.value.compareTo(a.value));
    return rows;
  }
}
