part of 'recipes_screen.dart';

/* Сторінка одного рецепта і розмова про нього. Фізично окремий файл,
 * але та сама бібліотека: засічковий голос, дати і сходинки входу
 * спільні зі списком. */

class RecipeView extends StatelessWidget {
  const RecipeView({super.key, required this.recipe});

  final RecipeData recipe;

  /* Видалення питається аркушем із червоною згодою: одне натискання не має
     вміти стерти рецепт. Сервер гасить мʼяко, тож Нора його забуває, а
     записи щоденника, зроблені за ним, живуть.
   *
   * Дія йде ПІСЛЯ того, як аркуш закрився, а не зсередини onDone: pop із
   * onDone знімав верхній маршрут, яким у ту мить був сам аркуш, і замість
   * сторінки закривався він, а картка лишалась у списку. Тому тут лише
   * прапорець згоди, а вся робота чекає на кінець аркуша. Знімок книги худне
   * всередині deleteRecipe лише після згоди сервера; сторінка закривається з
   * true, і список прибирає картку. Збій каже про себе рядком і лишає все
   * як було. */
  Future<void> _askDelete(BuildContext context) async {
    final l = L.of(context);
    final scope = AppScope.of(context);
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    var agreed = false;
    await calviSheet<void>(
      context,
      title: l.rcDeleteTitle,
      doneLabel: l.rcDeleteCta,
      danger: true,
      onDone: () => agreed = true,
      builder: (sheet) => Padding(
        padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 4, CalviSize.gutter, 0),
        child: Text(
          l.rcDeleteBody(recipe.title),
          style: sheet.t.bodyMedium?.copyWith(color: sheet.c.textSecondary, height: 1.4),
        ),
      ),
    );
    if (!agreed) return;

    try {
      if (scope.real && scope.sync != null) {
        await scope.sync!.deleteRecipe(recipe.id);
      }
      nav.pop(true);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.rcDeleteFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);
    final r = recipe;
    final scope = AppScope.of(context);
    final goalKcal = goalOf(scope.s).kcal;
    final share = goalKcal <= 0 ? 0 : ((r.kcal / goalKcal) * 100).round();
    final total = r.items.fold(0, (s, i) => s + i.grams);
    final warn = _recipeAllergens(r, scope.s.allergies);

    return CalviScreen(
      title: l.rcTitle,
      trailing: const CalviMenuButton(),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 4, CalviSize.gutter, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Rise(
                delay: 0,
                child: Container(
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
                      /* Праворуч не дата, а дії рецепта: дата вже сказана на
                         картці списку, а тут людині потрібніша можливість
                         його прибрати. Три крапки лише питають: стирає
                         червона згода в аркуші. */
                      _Eyebrow(
                        left: r.origin == 'nora' ? l.rcFromNora : l.rcFromMine,
                        action: GestureDetector(
                          onTap: () => _askDelete(context),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: c.fillSecondary,
                            ),
                            child: CalviIcon('dots', size: 15, color: c.textSecondary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: c.iconCircle,
                            ),
                            child: CalviIcon(r.icon, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(r.title, style: _display(context, 28))),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        [
                          l.rcMinutes(r.minutes),
                          _servingsLabel(l, r.servings),
                          l.rcPortion(r.gramsPerServing),
                        ].join(' · ').toUpperCase(),
                        style: context.t.labelSmall?.copyWith(
                          fontSize: 11,
                          letterSpacing: 11 * 0.12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (r.why != null && r.why!.isNotEmpty) ...[
                const SizedBox(height: 14),
                _Rise(
                  delay: 100,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
                    decoration: BoxDecoration(
                      color: c.fillSecondary,
                      borderRadius: BorderRadius.circular(CalviSize.rCard),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: CalviIcon('note', size: 16, color: c.textSecondary),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            r.why!,
                            style: context.t.bodyMedium?.copyWith(
                              color: c.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              /* Попередження про алерген над числами: людина мусить
                 наткнутись на нього раніше, ніж вирішить готувати. Мова
                 кольору небезпеки, але подушкою, а не сиреною: рецепт
                 лишається її рецептом. */
              if (warn.isNotEmpty) ...[
                const SizedBox(height: 14),
                _Rise(
                  delay: 130,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
                    decoration: BoxDecoration(
                      color: c.protein.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(CalviSize.rCard),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: CalviIcon('allergy', size: 16, color: c.protein),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            l.rcAllergyWarn(
                              warn.map((a) => a.name.toLowerCase()).join(', '),
                            ),
                            style: context.t.bodyMedium?.copyWith(
                              color: c.protein,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              _Rise(
                delay: 160,
                child: _Section(
                  title: l.rcPerServingHead,
                  aside: l.rcOfDay(share),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: '${r.kcal} ',
                          children: [
                            TextSpan(
                              text: l.unitKcal,
                              style: context.t.bodyMedium?.copyWith(
                                color: c.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        style: context.t.headlineLarge?.copyWith(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      MacroRow(
                        cells: [
                          (
                            label: l.macroProtein,
                            icon: 'protein',
                            value: r.protein.toDouble(),
                            goal: goalOf(scope.s).protein,
                            colour: c.protein,
                          ),
                          (
                            label: l.macroFat,
                            icon: 'fat',
                            value: r.fat.toDouble(),
                            goal: goalOf(scope.s).fat,
                            colour: c.fats,
                          ),
                          (
                            label: l.macroCarbs,
                            icon: 'carbs',
                            value: r.carbs.toDouble(),
                            goal: goalOf(scope.s).carbs,
                            colour: c.carbs,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _Rise(
                delay: 230,
                child: _Section(
                  title: l.rcItemsHead,
                  aside: l.rcItemsTotal(total),
                  child: Column(
                    children: [
                      /* Винний складник підсвічений просто в списку:
                         попередження вгорі каже «тут є», а рядок показує,
                         де саме. */
                      for (final (i, item) in r.items.indexed) ...[
                        if (i > 0) Container(height: 1, color: c.cardBorder),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              if (_itemHasAllergen(item.name, warn)) ...[
                                CalviIcon('allergy', size: 13, color: c.protein),
                                const SizedBox(width: 5),
                              ],
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: _itemHasAllergen(item.name, warn)
                                      ? context.t.bodyMedium?.copyWith(
                                          color: c.protein,
                                          fontWeight: FontWeight.w500,
                                        )
                                      : context.t.bodyMedium,
                                ),
                              ),
                              Text(
                                l.gramsUnit(item.grams),
                                style: context.t.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // Техніка в хвості картки продуктів, а не окремою секцією.
                      Container(height: 1, color: c.cardBorder),
                      Padding(
                        padding: const EdgeInsets.only(top: 13, bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              l.rcToolsHead.toUpperCase(),
                              style: context.t.labelSmall?.copyWith(
                                fontSize: 10,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: r.tools.isEmpty
                                  ? Text(
                                      l.rcNoTools,
                                      style: context.t.labelSmall?.copyWith(height: 1.3),
                                    )
                                  : Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        for (final t in r.tools)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 13,
                                              vertical: 7,
                                            ),
                                            decoration: BoxDecoration(
                                              color: c.fillSecondary,
                                              borderRadius: BorderRadius.circular(
                                                CalviSize.rPill,
                                              ),
                                            ),
                                            child: Text(
                                              _toolLabel(l, t).toUpperCase(),
                                              style: context.t.labelSmall?.copyWith(
                                                fontSize: 10,
                                                letterSpacing: 1,
                                                fontWeight: FontWeight.w600,
                                                color: c.text,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _Rise(
                delay: 300,
                child: _Section(
                  title: l.rcStepsHead,
                  child: Column(
                    children: [
                      for (final (i, s) in r.steps.indexed) ...[
                        if (i > 0) Container(height: 1, color: c.cardBorder),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 30,
                                child: Text(
                                  '${i + 1}'.padLeft(2, '0'),
                                  style: context.t.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: c.faint,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  s,
                                  style: context.t.bodyMedium?.copyWith(height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _Rise(delay: 370, child: _RecipeChat(recipe: r)),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}

/// Секція: заголовок із фактом праворуч і біла картка під ним.
class _Section extends StatelessWidget {
  const _Section({required this.title, this.aside, required this.child});

  final String title;
  final String? aside;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 2, right: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: context.t.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (aside != null)
                Text(aside!, style: context.t.labelSmall),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          decoration: BoxDecoration(
            color: c.card,
            border: Border.all(color: c.cardBorder),
            borderRadius: BorderRadius.circular(CalviSize.rLarge),
            boxShadow: context.shadowCard,
          ),
          child: child,
        ),
      ],
    );
  }
}

/* Той самий діалог, що під розбором тижня: тиха кнопка, ті самі бульбашки,
   те саме кільце «думаю» і поле зі стрілкою. Людина вивчила цю розмову на
   тижні, і другий вид чату був би другим інтерфейсом.
 *
 * У режимі «мої» питання йде звичайним чатом Нори з рецептом першою реплікою
 * історії: серверу не треба нового маршруту, а Нора бачить і назву, і
 * складники, і кроки. */
class _RecipeChat extends StatefulWidget {
  const _RecipeChat({required this.recipe});

  final RecipeData recipe;

  @override
  State<_RecipeChat> createState() => _RecipeChatState();
}

class _RecipeChatState extends State<_RecipeChat> {
  bool _chat = false;
  bool _thinking = false;
  int _replyAt = 0;
  final _draft = TextEditingController();
  final _msgs = <({bool me, String text})>[];
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _draft.dispose();
    super.dispose();
  }


  Future<void> _send() async {
    final text = _draft.text.trim();
    if (text.isEmpty || _thinking) return;
    setState(() {
      _draft.clear();
      _msgs.add((me: true, text: text));
      _thinking = true;
    });

    final scope = AppScope.of(context);
    final l = L.of(context);

    if (!scope.real || scope.sync == null) {
      _timer = Timer(const Duration(milliseconds: 1100), () {
        if (!mounted) return;
        final canned = demoRecipeReplies[_replyAt % demoRecipeReplies.length];
        setState(() {
          _replyAt++;
          _thinking = false;
          _msgs.add((me: false, text: canned));
        });
      });
      return;
    }

    final sync = scope.sync!;
    final db = scope.db;
    final talk = db == null ? null : ChatStore(db);
    unawaited(talk?.save(msg(from: MsgFrom.me, text: text)) ?? Future<void>.value());

    try {
      final answer = await sync.ask(
        text: text,
        slot: 'snack',
        history: [
          /* Рецепт першою реплікою: Нора бачить складники і кроки, і питання
             «чим замінити рис» має ґрунт без нового маршруту на сервері. */
          {'role': 'user', 'text': recipeChatContext(widget.recipe)},
          for (final m in _msgs.take(_msgs.length - 1).toList().reversed.take(3).toList().reversed)
            {'role': m.me ? 'user' : 'model', 'text': m.text},
        ],
      );
      if (!mounted) return;
      final said = answer.text.isEmpty ? l.todayDone : answer.text;
      unawaited(talk?.save(msg(from: MsgFrom.nora, text: said)) ?? Future<void>.value());
      setState(() {
        _thinking = false;
        _msgs.add((me: false, text: said));
      });
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _thinking = false;
        _msgs.add((
          me: false,
          text: switch (e.code) {
            'offline' => l.todayOfflineSaved,
            'slow' => l.todayNoraSlow,
            'no_tokens' => l.todayOutOfTokens,
            _ => l.todayFailedRetry,
          },
        ));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _thinking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: c.cardBorder),
        borderRadius: BorderRadius.circular(CalviSize.rLarge),
        boxShadow: context.shadowCard,
      ),
      child: !_chat
          ? GestureDetector(
              onTap: () => setState(() {
                _chat = true;
                _msgs.add((me: false, text: l.rcChatGreet(widget.recipe.title)));
              }),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.fillSecondary,
                  borderRadius: BorderRadius.circular(CalviSize.rCard),
                ),
                child: Text(
                  l.rcAskAbout,
                  style: context.t.bodyMedium?.copyWith(
                    color: c.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final m in _msgs)
                  Align(
                    alignment: m.me ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.62,
                      ),
                      decoration: BoxDecoration(
                        color: m.me ? c.button : c.fillSecondary,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(CalviSize.rCard),
                          topRight: const Radius.circular(CalviSize.rCard),
                          bottomLeft: Radius.circular(m.me ? CalviSize.rCard : 6),
                          bottomRight: Radius.circular(m.me ? 6 : CalviSize.rCard),
                        ),
                      ),
                      child: Text(
                        m.text,
                        style: context.t.bodyMedium?.copyWith(
                          color: m.me ? c.buttonText : c.text,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ),
                if (_thinking)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: c.fillSecondary,
                        borderRadius: BorderRadius.circular(CalviSize.rCard),
                      ),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: c.text,
                          backgroundColor: c.text.withValues(alpha: 0.16),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: TextField(
                            controller: _draft,
                            onSubmitted: (_) => _send(),
                            textInputAction: TextInputAction.send,
                            style: context.t.bodyMedium?.copyWith(color: c.text),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: l.rcChatPlaceholder,
                              hintStyle: context.t.bodyMedium?.copyWith(color: c.faint),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              filled: true,
                              fillColor: c.card,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(CalviSize.rPill),
                                borderSide: BorderSide(color: c.cardBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(CalviSize.rPill),
                                borderSide: BorderSide(color: c.cardBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(CalviSize.rPill),
                                borderSide: BorderSide(color: c.text),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _send,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: c.button),
                          child: CalviIcon('send', size: 18, color: c.buttonText),
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
