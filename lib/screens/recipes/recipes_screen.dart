import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../data/chat.dart';
import '../../data/day.dart' show monthName;
import '../../data/recipes_demo.dart';
import '../../data/allergens.dart';
import '../../data/settings.dart' show Allergy, goalOf;
import '../../data/local/chat_store.dart';
import '../../data/remote/api.dart';
import '../../design/icons.dart';
import '../../design/macro_row.dart';
import '../../design/shell.dart';
import '../../design/slide.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../menu.dart';

part 'ask_nora.dart';
part 'recipe_view.dart';

/* Рецепти: те, що вже приготували або збираються приготувати.
 *
 * **Не бібліотека чужих страв.** Сюди потрапляє рівно те, що запропонувала
 * Нора, і те, що людина продиктувала сама. Тому кожна картка підписана
 * походженням, а сторінка починається не з пошуку, а з однієї дії: спитати
 * Нору, що приготувати з того, що є вдома.
 *
 * **Числа на порцію, а не на сто грамів.** Сто грамів це мова пачки; рецепт
 * міряють тарілками. Вага порції записана поруч, тож перерахунок можливий.
 *
 * Перенесено з демки 5300 один в один: обкладинка з засічковим заголовком,
 * перемикач джерела, картки на три рядки, сторінка рецепта з рядом БЖВ у
 * кільцях, вибір із трьох порад Нори і розмова про рецепт тією ж мовою, що
 * діалог під розбором тижня. */

/// Засічковий голос обкладинки. Системний: Georgia на iOS, Noto Serif на
/// Android, нуль завантаження. Єдине місце в застосунку з цим шрифтом.
const _serif = ['Georgia', 'Times New Roman'];

TextStyle _display(BuildContext context, double size) => TextStyle(
  fontFamily: 'serif',
  fontFamilyFallback: _serif,
  fontWeight: FontWeight.w400,
  fontSize: size,
  height: 1.12,
  letterSpacing: size * -0.01,
  color: context.c.text,
);

/// Акцент для слів: чистий акцент надто світлий на білому, тому підмішується
/// колір тексту. У темряві текст світлий, і акцент світлішає сам.
Color _accentInk(BuildContext context) =>
    Color.lerp(context.c.accent, context.c.text, 0.38) ?? context.c.text;

String _servingsLabel(L l, int n) => n == 1
    ? l.rcServingsOne
    : n >= 2 && n <= 4
    ? l.rcServingsFew(n)
    : l.rcServingsMany(n);

String _countLabel(L l, int n) => n == 1
    ? l.rcCountOne
    // Нуль і 5+ множиною («рецептів»), 2-4 few («рецепти»): українська лічба.
    : n >= 2 && n <= 4
    ? l.rcCountFew(n)
    : l.rcCount(n);

/// Коли рецепт зʼявився: «щойно» сьогодні, далі «29 серпня», як у демці.
String _when(L l, DateTime? at) {
  if (at == null) return l.rcJustNow;
  final d = at.toLocal();
  final now = DateTime.now();
  if (d.year == now.year && d.month == now.month && d.day == now.day) return l.rcJustNow;
  return '${d.day} ${monthName(d.month)}';
}

/* Алерген у рецепті шукається словами складників: назва і синоніми з
   реєстру, обома мовами одразу. Щедро, як і скрізь у нас: зайва мітка коштує
   один погляд, пропущена коштує здоровʼя. */
List<String> _allergenWords(Allergen a) => [a.nameUk, a.nameEn, ...a.aka];

bool _itemHasAllergen(String name, List<Allergen> warn) {
  final hay = name.toLowerCase();
  return warn.any((a) => _allergenWords(a).any((w) => hay.contains(w.toLowerCase())));
}

/// Алергії людини, які зустрілись у складниках рецепта.
List<Allergen> _recipeAllergens(RecipeData r, List<Allergy> mine) {
  final picked = {for (final m in mine) m.id};
  return [
    for (final a in allergens)
      if (picked.contains(a.id) && r.items.any((i) => _itemHasAllergen(i.name, [a]))) a,
  ];
}

String _toolLabel(L l, String key) => switch (key) {
  'oven' => l.rcToolOven,
  'pan' => l.rcToolPan,
  'pot' => l.rcToolPot,
  'blender' => l.rcToolBlender,
  'grill' => l.rcToolGrill,
  'mixer' => l.rcToolMixer,
  _ => key,
};

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  List<RecipeData>? _book;
  bool _failed = false;
  bool _asked = false;
  int _tab = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_asked) {
      _asked = true;
      _load();
    }
  }

  /* Книга приходить двома кроками. Спершу знімок із місцевої бази: остання
     відповідь сервера, миттєво і без мережі, тож сторінка відкривається одразу
     з картками навіть після перезапуску. Тоді тихе освіження: свіжа відповідь
     сервера підміняє і екран, і знімок. Правки в знімку не робляться ніколи,
     тож серверу й телефону нема за що битись. */
  Future<void> _load() async {
    final scope = AppScope.of(context);
    if (!scope.real || scope.sync == null) {
      setState(() => _book = demoRecipeBook());
      return;
    }

    final snap = await scope.sync!.recipesSnapshot();
    if (!mounted) return;
    if (snap != null) setState(() => _book = snap);

    /* Мережа чекає, поки сторінка доїде: перебудова списку посеред переходу
       і є той самий «лаг». Пів секунди свіжості книга рецептів переживе. */
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    try {
      final rows = await scope.sync!.recipes();
      if (!mounted) return;
      setState(() {
        _book = rows;
        _failed = false;
      });
    } catch (_) {
      if (!mounted) return;
      // Знімок є, значить є що показувати: збій дотягування не стирає книгу.
      if (_book != null) return;
      setState(() {
        _book = const [];
        _failed = true;
      });
    }
  }

  Future<void> _openDish(RecipeData r) async {
    final gone = await Navigator.of(context).push(slideRoute(RecipeView(recipe: r)));
    // Сторінка закрилась через видалення: список прибирає картку одразу,
    // знімок уже схуд усередині deleteRecipe.
    if (gone == true && mounted) {
      setState(() => _book = [
        for (final x in _book ?? const <RecipeData>[])
          if (x.id != r.id) x,
      ]);
    }
  }

  Future<void> _ask() async {
    final picked = await askNoraForRecipe(context);
    if (picked == null || !mounted) return;
    // Знімок уже оновив saveRecipe: тут лишається тільки екран.
    setState(() => _book = [picked, ..._book ?? const []]);
    _openDish(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final book = _book ?? const <RecipeData>[];

    final shown = switch (_tab) {
      1 => [for (final r in book) if (r.origin == 'nora') r],
      2 => [for (final r in book) if (r.origin == 'mine') r],
      _ => book,
    };

    return CalviScreen(
      title: l.rcTitle,
      trailing: const CalviMenuButton(),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 4, CalviSize.gutter, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /* Сторінка вмикається поетапно, як аналітика: обкладинка,
                 перемикач, картки одна за одною. */
              _Rise(delay: 0, child: _Hero(count: book.length, onAsk: _ask)),
              const SizedBox(height: 14),
              _Rise(
                delay: 110,
                child: CalviSegments(
                  labels: [l.rcTabAll, l.rcTabNora, l.rcTabMine],
                  index: _tab,
                  onPick: (i) => setState(() => _tab = i),
                ),
              ),
              const SizedBox(height: 14),
              if (_failed && book.isEmpty)
                _Rise(
                  delay: 180,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Text(
                      l.rcLoadFailed,
                      style: context.t.bodyMedium?.copyWith(color: context.c.textSecondary),
                    ),
                  ),
                )
              /* Книга ще їде з сервера: тиша чесніша за «Тут порожньо», яке
                 через пів секунди зміниться картками. */
              else if (_book == null)
                const SizedBox.shrink()
              else if (shown.isEmpty)
                _Rise(
                  delay: 180,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Text(
                      _tab == 2 ? l.rcEmptyMine : l.rcEmpty,
                      style: context.t.bodyMedium?.copyWith(color: context.c.textSecondary),
                    ),
                  ),
                )
              else
                for (final (i, r) in shown.indexed)
                  _Rise(
                    // Ключ включає вкладку: перемкнув «Мої», і список заходить
                    // наново тим самим рухом.
                    key: ValueKey('$_tab:${r.id}'),
                    delay: 170 + (i > 6 ? 6 : i) * 65,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _Card(r: r, onOpen: () => _openDish(r)),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

/* Обкладинка: звичайна картка, характер несуть слова. Капс-рядок «Кухня» і
   лічильник, засічковий заголовок із курсивним теплим словом, речення суті
   і головна дія. */
class _Hero extends StatelessWidget {
  const _Hero({required this.count, required this.onAsk});

  final int count;
  final VoidCallback onAsk;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: c.cardBorder),
        borderRadius: BorderRadius.circular(CalviSize.rLarge),
        boxShadow: context.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Eyebrow(left: l.rcEyebrow, right: _countLabel(l, count)),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              text: '${l.rcHeroA} ',
              children: [
                TextSpan(
                  text: l.rcHeroB,
                  style: TextStyle(fontStyle: FontStyle.italic, color: _accentInk(context)),
                ),
              ],
            ),
            style: _display(context, 30),
          ),
          const SizedBox(height: 8),
          Text(
            l.rcHeroLede,
            style: context.t.labelSmall?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onAsk,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.button,
                borderRadius: BorderRadius.circular(CalviSize.rPill),
              ),
              child: Text(
                l.rcAsk,
                style: context.t.bodyMedium?.copyWith(
                  color: c.buttonText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Дрібний рядок капсом урозрядку: назва розділу ліворуч, факт праворуч.
/// Замість факту праворуч може стояти дія: сторінка рецепта тримає там три
/// крапки видалення, бо дата вже сказана на картці списку.
class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.left, this.right = '', this.action});

  final String left;
  final String right;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final style = context.t.labelSmall?.copyWith(
      fontSize: 11,
      letterSpacing: 11 * 0.14,
      fontWeight: FontWeight.w500,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left.toUpperCase(), style: style),
        action ?? Text(right.toUpperCase(), style: style),
      ],
    );
  }
}

/* Картка списку на три рядки: назва з калоріями, капс-рядок фактів, БЖВ
   кольорами. Кільця чекають на сторінці рецепта: тут людина ще обирає. */
class _Card extends StatelessWidget {
  const _Card({required this.r, required this.onOpen});

  final RecipeData r;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);
    final warn = _recipeAllergens(r, AppScope.of(context).s.allergies);

    final facts = [
      l.rcMinutes(r.minutes),
      _servingsLabel(l, r.servings),
      _when(l, r.createdAt),
    ].join(' · ');

    return GestureDetector(
      onTap: onOpen,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: c.card,
          border: Border.all(color: c.cardBorder),
          borderRadius: BorderRadius.circular(CalviSize.rLarge),
          boxShadow: context.shadowCard,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.iconCircle),
              child: CalviIcon(r.icon, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          r.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.t.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text.rich(
                        TextSpan(
                          text: '${r.kcal} ',
                          children: [
                            TextSpan(
                              text: l.unitKcal,
                              style: context.t.labelSmall?.copyWith(fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                        style: context.t.headlineMedium?.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  /* Теплим у рядку стоїть лише «від Нори», решта фактів тихі:
                     так у демці, і так око одразу бачить, чий це рецепт. */
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: (r.origin == 'nora' ? l.rcFromNora : l.rcFromMine).toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: r.origin == 'nora' ? _accentInk(context) : c.textSecondary,
                          ),
                        ),
                        TextSpan(text: ' · ${facts.toUpperCase()}'),
                      ],
                    ),
                    style: context.t.labelSmall?.copyWith(
                      fontSize: 10,
                      letterSpacing: 1,
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Mac(letter: l.macroProteinLetter, value: r.protein, colour: c.protein),
                      const SizedBox(width: 10),
                      _Mac(letter: l.macroFatLetter, value: r.fat, colour: c.fats),
                      const SizedBox(width: 10),
                      _Mac(letter: l.macroCarbsLetter, value: r.carbs, colour: c.carbs),
                    ],
                  ),
                  /* Алерген видно ще зі списку: тихий рядок, а не плашка, але
                     кольором небезпеки і з іменем винуватця. */
                  if (warn.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        CalviIcon('allergy', size: 13, color: c.protein),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            warn.map((a) => a.name).join(', '),
                            style: context.t.labelSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: c.protein,
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _Mac extends StatelessWidget {
  const _Mac({required this.letter, required this.value, required this.colour});

  final String letter;
  final int value;
  final Color colour;

  @override
  Widget build(BuildContext context) => Text(
    '$letter $value',
    style: context.t.labelSmall?.copyWith(fontWeight: FontWeight.w600, color: colour),
  );
}

/* --- Сторінка одного рецепта --- */

/* Поява однієї ланки: коротке проступання знизу зі своєю затримкою, тим самим
   рухом, що вмикається аналітика. Затримка схована в криву, як у вітанні. */
class _Rise extends StatelessWidget {
  const _Rise({super.key, required this.delay, required this.child});

  final int delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const riseMs = 560;
    final total = delay + riseMs;
    final start = delay / total;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(start, 1, curve: CalviMotion.easeRise),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}

/* --- «Попросити рецепт у Нори»: питання, вибір, книга --- */
