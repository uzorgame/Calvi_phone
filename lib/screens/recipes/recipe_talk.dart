part of 'recipes_screen.dart';

/* Розмова книги рецептів і сама книга: одне на весь розділ.
 *
 * Список і сторінка страви це два маршрути, але книга одна і розмова одна.
 * Людина просить пораду в списку, відкриває страву й питає вже про неї, і
 * повертати її до порожнього чату на кожному кроці означало б забувати сказане
 * хвилину тому. Тому і те, і те живе тут, а сторінка страви отримує це
 * посиланням, а не копією.
 *
 * **Це не розмова щоденника.** «Курка, броколі, рис» на дні означає обід, який
 * людина зʼїла, а тут це прохання порадити страву. Одна стрічка на дві сторінки
 * змусила б памʼятати, де саме ти був, щоб зрозуміти власну ж репліку, і
 * жодного зиску натомість не дала б: у рецептах ніколи не знадобиться вчорашня
 * вечеря, а в щоденнику ніколи не знадобиться список продуктів для супу. */
class RecipeDesk extends ChangeNotifier {
  /// Книга. Порожньо означає «ще їде з сервера», а не «рецептів немає».
  List<RecipeData>? book;

  /// Книга не дійшла зовсім: сторінка каже про це рядком замість карток.
  bool failed = false;

  /// Стрічка розмови.
  final messages = <Msg>[];

  /// Чи піднята штора чату.
  bool open = false;

  /// Котра завчена відповідь про готування наступна. Демо говорить по колу.
  int replyAt = 0;

  /* Страви, які Нора щойно запропонувала, за своїм номером у розмові.
   *
   * Рецептом стає лише те, у що тицьнули: записувати в книгу все, що Нора
   * назвала, означало б засмічувати її чернетками. Тому повний рецепт чекає
   * тут, а в розмові стоїть тільки назва, час і калорії порції. */
  final offered = <String, RecipeData>{};

  void shelve(List<RecipeData>? rows, {bool failed = false}) {
    book = rows;
    this.failed = failed;
    notifyListeners();
  }

  void raise() {
    if (open) return;
    open = true;
    notifyListeners();
  }

  void lower() {
    if (!open) return;
    open = false;
    notifyListeners();
  }

  void add(Msg m) {
    messages.add(m);
    notifyListeners();
  }

  void replace(String id, Msg next) {
    final at = messages.indexWhere((m) => m.id == id);
    if (at < 0) return;
    messages[at] = next;
    notifyListeners();
  }

  /// Рецепт лягає в книгу зверху: щойно обране шукають не в кінці списку.
  void put(RecipeData r) {
    book = [r, ...?book];
    notifyListeners();
  }

  void drop(String id) {
    book = [
      for (final x in book ?? const <RecipeData>[])
        if (x.id != id) x,
    ];
    notifyListeners();
  }
}

/* --- Що Нора відповідає в книзі рецептів --- */

/// Приклади в полі: у списку питають, що приготувати, на сторінці страви про
/// саму страву. Поле те саме, а питання різні.
List<String> recipeHints(L l, {required bool dish}) => dish
    ? [l.rcDishHintSwap, l.rcDishHintDry, l.rcDishHintAhead, l.rcDishHintKeeps]
    : [l.rcAskPlaceholder, l.rcChatHintMince, l.rcChatHintDinner, l.rcChatHintEggs, l.rcChatHintOnly];

/// Чим вітається порожня розмова. На сторінці страви вона вітається нею.
({String hello, String hint}) recipeGreet(L l, RecipeData? dish) => dish == null
    ? (hello: l.rcChatHello, hint: l.rcChatHint)
    : (hello: l.rcChatGreet(dish.title), hint: l.rcDishHint);

/* Прохання до Нори з книги рецептів.
 *
 * Кільце очікування ставиться тієї ж миті і на тому самому місці, де буде
 * відповідь: бульбашка не зʼявляється потім із нічого, а доростає з нього.
 *
 * **Відкритий рецепт міняє тему сам собою.** Поле те саме, але питання вже інше:
 * не «що приготувати», а «чим замінити рис». Страву вже вибрано, і пропонувати
 * натомість інші означало б не почути питання.
 *
 * Фото тут немає навмисно, і це не економія: знімок відповідає на питання «що я
 * зʼїв», а тут питання протилежне, про страву, якої ще не існує. */
Future<void> askNoraInBook(
  BuildContext context,
  RecipeDesk desk,
  String said, {
  RecipeData? dish,
}) async {
  final scope = AppScope.of(context);
  final l = L.of(context);

  final waiting = msg(from: MsgFrom.nora, text: '', pending: true);
  desk
    ..add(msg(from: MsgFrom.me, text: said))
    ..add(waiting)
    ..raise();

  if (!scope.real || scope.sync == null) {
    /* Демо тримає паузу: моделі тут немає, а миттєва відповідь читалась би як
       несправжня. */
    await Future<void>.delayed(Duration(milliseconds: dish == null ? 1400 : 1100));
    if (!context.mounted) return;

    if (dish != null) {
      final canned = demoRecipeReplies[desk.replyAt % demoRecipeReplies.length];
      desk.replyAt++;
      desk.replace(waiting.id, waiting.answered(text: canned));
      return;
    }

    final options = demoRecipeOptions();
    for (final r in options) {
      desk.offered['${waiting.id}:${r.id}'] = r;
    }
    desk.replace(
      waiting.id,
      waiting.answered(text: l.rcChatPicks, picks: _picksOf(waiting.id, options)),
    );
    return;
  }

  final sync = scope.sync!;

  if (dish != null) {
    /* У режимі «мої» питання йде звичайним чатом Нори з рецептом першою
       реплікою історії: серверу не треба нового маршруту, а Нора бачить і
       назву, і складники, і кроки. */
    final db = scope.db;
    final talk = db == null ? null : ChatStore(db);
    unawaited(talk?.save(msg(from: MsgFrom.me, text: said)) ?? Future<void>.value());

    try {
      /* Історія це те, що було ДО цього питання: саме питання вже їде в `text`,
         і другим разом воно читалось би як повторене. Далі трьох реплік назад
         не заглядаємо: розмова про страву коротка, а кожен зайвий рядок це
         токени. */
      final earlier = desk.messages
          .where((m) => m.id != waiting.id && !m.pending && m.text.isNotEmpty)
          .toList();
      if (earlier.isNotEmpty) earlier.removeLast();
      final tail = earlier.length <= 3 ? earlier : earlier.sublist(earlier.length - 3);

      final answer = await sync.ask(
        text: said,
        slot: 'snack',
        history: [
          {'role': 'user', 'text': recipeChatContext(dish)},
          for (final m in tail)
            {'role': m.from == MsgFrom.me ? 'user' : 'model', 'text': m.text},
        ],
      );
      if (!context.mounted) return;
      final reply = answer.text.isEmpty ? l.todayDone : answer.text;
      unawaited(talk?.save(msg(from: MsgFrom.nora, text: reply)) ?? Future<void>.value());
      desk.replace(waiting.id, waiting.answered(text: reply));
    } on ApiFailure catch (e) {
      if (!context.mounted) return;
      desk.replace(waiting.id, waiting.answered(text: _failure(l, e.code)));
    } catch (_) {
      if (!context.mounted) return;
      desk.replace(waiting.id, waiting.answered(text: l.todayFailedRetry));
    }
    return;
  }

  try {
    final options = await sync.suggestRecipes(said);
    if (!context.mounted) return;
    if (options.isEmpty) {
      desk.replace(waiting.id, waiting.answered(text: l.rcSuggestFailed));
      return;
    }
    for (final r in options) {
      desk.offered['${waiting.id}:${r.id}'] = r;
    }
    desk.replace(
      waiting.id,
      waiting.answered(text: l.rcChatPicks, picks: _picksOf(waiting.id, options)),
    );
  } catch (_) {
    if (!context.mounted) return;
    desk.replace(waiting.id, waiting.answered(text: l.rcSuggestFailed));
  }
}

String _failure(L l, String code) => switch (code) {
  'offline' => l.todayOfflineSaved,
  'slow' => l.todayNoraSlow,
  'no_tokens' => l.todayOutOfTokens,
  _ => l.todayFailedRetry,
};

/// Той самий рецепт під іншим номером. `RecipeData` незмінний і `copyWith` не
/// має, а переписати тут треба рівно одне поле.
RecipeData _renamed(RecipeData r, String id) => RecipeData(
  id: id,
  title: r.title,
  icon: r.icon,
  origin: r.origin,
  minutes: r.minutes,
  servings: r.servings,
  gramsPerServing: r.gramsPerServing,
  kcal: r.kcal,
  protein: r.protein,
  fat: r.fat,
  carbs: r.carbs,
  tools: r.tools,
  items: r.items,
  steps: r.steps,
  why: r.why,
  createdAt: r.createdAt,
  allergen: r.allergen,
);

/* Номер повідомлення в ключі, а не сама назва страви.
 *
 * Нору просять двічі за одну розмову, і обидва рази вона може назвати ту саму
 * страву: без номера друге прохання затирало б перше, і дотик по верхньому
 * рядку відкривав би нижній рецепт. */
List<RecipePick> _picksOf(String at, List<RecipeData> options) => [
  for (final r in options)
    RecipePick(
      id: '$at:${r.id}',
      icon: r.icon,
      title: r.title,
      minutes: r.minutes,
      kcal: r.kcal,
    ),
];

/* Обрана страва лягає в книгу і повертається сюди готовим рецептом.
 *
 * Людина щойно сказала «оцю», і показати їй список замість рецепта означало б
 * змусити шукати те, що вона вже вибрала. Розмова при цьому згортається: те,
 * про що в ній говорили, стоїть тепер на весь екран.
 *
 * Порожньо означає, що зберегти не вийшло: рядок про це стає в розмову, а
 * страви лишаються на місці, щоб спробувати ще раз. */
Future<RecipeData?> takeDish(
  BuildContext context,
  RecipeDesk desk,
  String at,
  String pick,
) async {
  final draft = desk.offered[pick];
  if (draft == null) return null;

  final scope = AppScope.of(context);
  final l = L.of(context);

  var saved = draft;
  if (scope.real && scope.sync != null) {
    try {
      saved = await scope.sync!.saveRecipe(draft);
    } catch (_) {
      if (!context.mounted) return null;
      desk.add(msg(from: MsgFrom.nora, text: l.rcSuggestFailed));
      return null;
    }
  } else {
    /* У вітрині номер дає не сервер, а ця мить.
     *
     * Заготовлена трійка має сталі номери, і та сама страва, узята двічі,
     * лягала в книгу двома картками з одним номером. Список ключується саме
     * номером, і два однакові ключі в одному стосі це вже не косметика. */
    saved = _renamed(draft, 'r${DateTime.now().microsecondsSinceEpoch}');
  }
  if (!context.mounted) return null;

  // Рядки вибору поступаються місцем: на це питання відповідають один раз.
  final held = desk.messages.where((m) => m.id == at).firstOrNull;
  if (held != null) desk.replace(at, held.took(pick));

  desk
    ..put(saved)
    ..lower();
  return saved;
}
