import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../data/chat.dart';
import '../../data/day.dart' show dayMonth;
import '../../data/recipes_demo.dart';
import '../../data/allergens.dart';
import '../../data/settings.dart' show Allergy, goalOf;
import '../../data/local/chat_store.dart';
import '../../data/local/database.dart' show TokenStateData;
import '../../data/remote/api.dart';
import '../../data/units.dart';
import '../../design/icons.dart';
import '../../design/macro_row.dart';
import '../../design/shell.dart';
import '../../design/slide.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../menu.dart';
import '../today/bottom_bar.dart';
import '../voice/dictation.dart';
import '../voice/voice_overlay.dart';

part 'recipe_talk.dart';
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
 * кільцях і розмова з Норою тією самою смугою, що на дні.
 *
 * **Просять Нору внизу, а не кнопкою.** Тут стояла кнопка «Попросити рецепт у
 * Нори», яка відкривала аркуш з одним полем, тобто друге місце, куди пишуть
 * Норі, зі своїм виглядом і своїми правилами. Писати Норі в застосунку вміють в
 * одному місці, унизу екрана, і книга рецептів не має бути винятком: замість
 * кнопки лишився рядок, який каже, що там на неї чекають. */

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
  return dayMonth(d.day, d.month);
}

/* Алерген у рецепті шукається словами складників: назва і синоніми з
   реєстру, обома мовами одразу. Щедро, як і скрізь у нас: зайва мітка коштує
   один погляд, пропущена коштує здоровʼя. */
List<String> _allergenWords(Allergen a) => [...a.names.values, ...a.aka];

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
  /* Книга і розмова живуть в одному місці на весь розділ: сторінка страви
     працює з тими самими, а не зі своїми копіями. */
  final _desk = RecipeDesk();
  bool _asked = false;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _desk.addListener(_redraw);
  }

  void _redraw() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _desk.removeListener(_redraw);
    _desk.dispose();
    super.dispose();
  }

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
      _desk.shelve(demoRecipeBook());
      return;
    }

    final snap = await scope.sync!.recipesSnapshot();
    if (!mounted) return;
    if (snap != null) _desk.shelve(snap);

    /* Мережа чекає, поки сторінка доїде: перебудова списку посеред переходу
       і є той самий «лаг». Пів секунди свіжості книга рецептів переживе.
       Але тільки коли є що показувати: без знімка на екрані порожньо, і чекати
       посеред порожнечі нема заради чого. Саме так буває одразу після зміни
       мови, коли знімка цією мовою ще немає. */
    if (snap != null) await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    try {
      final rows = await scope.sync!.recipes();
      if (!mounted) return;
      _desk.shelve(rows);
    } catch (_) {
      if (!mounted) return;
      // Знімок є, значить є що показувати: збій дотягування не стирає книгу.
      if (_desk.book != null) return;
      _desk.shelve(const [], failed: true);
    }
  }

  Future<void> _openDish(RecipeData r) async {
    final gone = await Navigator.of(
      context,
    ).push(slideRoute(RecipeView(recipe: r, desk: _desk)));
    // Сторінка закрилась через видалення: список прибирає картку одразу,
    // знімок уже схуд усередині deleteRecipe.
    if (gone == true && mounted) _desk.drop(r.id);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final book = _desk.book ?? const <RecipeData>[];

    final shown = switch (_tab) {
      1 => [for (final r in book) if (r.origin == 'nora') r],
      2 => [for (final r in book) if (r.origin == 'mine') r],
      _ => book,
    };

    return CalviScreen(
      title: l.rcTitle,
      trailing: const CalviMenuButton(),
      /* Місце під смугу розмови: без нього остання картка книги ховалась би за
         полем. Смуга це 92 пікселі плюс безпечна зона телефона, яку вона
         тримає в собі, і сторінка мусить рахувати те саме, бо сама вона під
         ту зону заходить. */
      padding: EdgeInsets.only(bottom: 104 + MediaQuery.paddingOf(context).bottom),
      bar: RecipeBar(desk: _desk, onOpened: _openDish),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 4, CalviSize.gutter, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /* Сторінка вмикається поетапно, як аналітика: обкладинка,
                 перемикач, картки одна за одною. */
              _Rise(delay: 0, child: _Hero(count: book.length)),
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
              if (_desk.failed && book.isEmpty)
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
              else if (_desk.book == null)
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
   і рядок про те, хто тут допоможе.

   Кнопки більше немає: замість неї рядок, який відсилає до поля внизу. Тут не
   тиснуть, тут читають і йдуть просити. */
class _Hero extends StatelessWidget {
  const _Hero({required this.count});

  final int count;

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
          /* Той самий бейдж, що вітає в порожній розмові внизу: рядок і поле це
             одна Нора, і однаковий знак каже це швидше за будь-яке пояснення. */
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: c.fillSecondary,
              borderRadius: BorderRadius.circular(CalviSize.rCard),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c.button),
                  // Та сама літера, що на бейджі порожньої розмови: імʼя Нори
                  // однакове всіма мовами, і перекладати тут нема чого.
                  child: Text(
                    'N',
                    style: context.t.labelSmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: c.buttonText,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.rcHelps,
                    style: context.t.labelSmall?.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* Смуга розмови книги рецептів: та сама, що на дні.
 *
 * Та сама кімната, ті самі бульбашки, те саме кільце очікування, той самий
 * лічильник токенів. Інші тільки три речі, і кожна з них про те, що це інша
 * розмова: немає камери (страви ще не існує, знімати нічого), немає пігулки
 * «Записую в Обід» (звідси в щоденник не йде нічого) і свої приклади в полі.
 *
 * Один віджет на обидва маршрути: список показує його без страви, сторінка
 * рецепта зі стравою, і від цього міняються вітання, приклади й тема. */
class RecipeBar extends StatefulWidget {
  const RecipeBar({super.key, required this.desk, required this.onOpened, this.dish});

  final RecipeDesk desk;
  final RecipeData? dish;

  /// Куди йти з обраною стравою. Список її відкриває, сторінка підміняє себе.
  final ValueChanged<RecipeData> onOpened;

  @override
  State<RecipeBar> createState() => _RecipeBarState();
}

class _RecipeBarState extends State<RecipeBar> {
  /* Диктування, точно як на дні: той самий мікрофон, та сама накладка, та сама
     стрічка рівнів. Продиктоване стає тим самим проханням, що й набране, бо
     сказати «курка, броколі, рис» голосом швидше, ніж набрати. */
  final Dictation _ears = Dictation.shared;
  ({VoiceOrigin from, bool leaving})? _dictating;
  bool _listening = false;
  DateTime? _heldFrom;
  Timer? _showing;

  /// Накладка зʼявляється не з першим дотиком, а коли палець справді лежить.
  static const _holdBefore = Duration(milliseconds: 200);

  /// Коротший дотик це промах по кнопці, а не фраза.
  static const _minPhrase = Duration(milliseconds: 420);

  @override
  void dispose() {
    _showing?.cancel();
    if (_listening) unawaited(_ears.cancel());
    super.dispose();
  }

  Future<void> _hold(Offset at, double size) async {
    if (_dictating != null || _listening) return;
    _listening = true;

    _heldFrom = DateTime.now();
    _showing?.cancel();
    _showing = Timer(_holdBefore, () {
      if (!mounted || !_listening) return;
      setState(() => _dictating = (from: VoiceOrigin(at: at, size: size), leaving: false));
    });

    final ok = await _ears.start(onWords: (_) {});
    if (!mounted || ok) return;

    _showing?.cancel();
    _listening = false;
    _heldFrom = null;
    setState(() => _dictating = null);
    _trouble();
  }

  Future<void> _letGo() async {
    if (!_listening) return;

    _showing?.cancel();
    _showing = null;

    final held = _heldFrom == null ? Duration.zero : DateTime.now().difference(_heldFrom!);
    _heldFrom = null;

    final was = _dictating;
    if (was == null || held < _minPhrase) {
      _listening = false;
      if (was != null) setState(() => _dictating = null);
      unawaited(_ears.cancel());
      return;
    }

    setState(() => _dictating = (from: was.from, leaving: true));

    final text = (await _ears.stop()).trim();
    _listening = false;
    if (!mounted) return;

    if (text.isEmpty) {
      _trouble();
      return;
    }
    unawaited(askNoraInBook(context, widget.desk, text, dish: widget.dish));
  }

  void _trouble() {
    final why = _ears.failure;
    if (why == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(why)));
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final desk = widget.desk;
    final dish = widget.dish;

    /* Обидва шари на весь екран, і це не косметика.
     *
     * Стос за умовчанням дає дитині волю розміру і кладе її в лівий верхній
     * кут. Смуга сама по собі заввишки з поле, і без цього рядка вона ставала
     * саме туди, поверх кнопки «назад»: її власний перехоплювач непрозорий і
     * їв дотик, а замість повернення піднімався чат. */
    return Stack(
      fit: StackFit.expand,
      children: [
        StreamBuilder<TokenStateData?>(
          stream: AppScope.maybeOf(context)?.db?.syncDao.watchTokens(),
          builder: (context, snap) => BottomBar(
            tokensLeft: snap.data?.syncedAt == null || snap.data?.unlimited == true
                ? null
                : snap.data?.balance,
            pro: snap.data?.syncedAt != null && snap.data?.unlimited == true,
            open: desk.open,
            onOpen: (_) => desk.raise(),
            onClose: desk.lower,
            muteMic: _dictating != null,
            messages: desk.messages,
            greet: recipeGreet(l, dish),
            hints: recipeHints(l, dish: dish != null),
            onSend: (text) => askNoraInBook(context, desk, text, dish: dish),
            onPick: (at, pick) async {
              final saved = await takeDish(context, desk, at, pick);
              if (saved != null && context.mounted) widget.onOpened(saved);
            },
            onHold: _hold,
            onLetGo: _letGo,
          ),
        ),

        // Диктування накриває все, зокрема й смугу, яка його почала.
        if (_dictating case final d?)
          VoiceOverlay(
            origin: d.from,
            leaving: d.leaving,
            onClosed: () => setState(() => _dictating = null),
            source: _ears,
          ),
      ],
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
                      /* У списку числа на ВСЮ страву, у самому рецепті на
                         порцію.
                       *
                       * Список це вибір, що готувати, і там питання «скільки
                       * вийде з цієї каструлі». Порція стає важливою потім, на
                       * сторінці рецепта, коли страва вже обрана і треба
                       * покласти собі в тарілку. */
                      Text.rich(
                        TextSpan(
                          text: '${dataUnits.enNum(r.kcal * r.servings)} ',
                          children: [
                            TextSpan(
                              text: dataUnits.enLabel,
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
                      // БЖВ теж на всю страву: поруч із калоріями всієї страви
                      // числа на порцію читались би як її ж частина.
                      _Mac(
                        letter: l.macroProteinLetter,
                        value: r.protein * r.servings,
                        colour: c.protein,
                      ),
                      const SizedBox(width: 10),
                      _Mac(letter: l.macroFatLetter, value: r.fat * r.servings, colour: c.fats),
                      const SizedBox(width: 10),
                      _Mac(
                        letter: l.macroCarbsLetter,
                        value: r.carbs * r.servings,
                        colour: c.carbs,
                      ),
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
