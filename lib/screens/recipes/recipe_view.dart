part of 'recipes_screen.dart';

/* Сторінка одного рецепта і розмова про нього. Фізично окремий файл,
 * але та сама бібліотека: засічковий голос, дати і сходинки входу
 * спільні зі списком. */

class RecipeView extends StatelessWidget {
  const RecipeView({super.key, required this.recipe, required this.desk});

  final RecipeData recipe;

  /// Книга і розмова розділу: сторінка страви працює з тими самими, а не зі
  /// своїми копіями.
  final RecipeDesk desk;

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
      // Місце під смугу розмови, те саме, що в списку.
      padding: EdgeInsets.only(bottom: 104 + MediaQuery.paddingOf(context).bottom),
      /* Розмова про рецепт стоїть у смузі внизу, тій самій, що на кожній
         сторінці книги: коли рецепт відкритий, вона сама переходить на цю
         страву. Тут вона була карткою з власною кнопкою і власним полем, і
         виходило два поля одне над одним, обидва до Нори. */
      bar: _TalkHere(desk: desk, dish: r),
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
                          l.rcPortion(dataUnits.porText(r.gramsPerServing)),
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
                      /* Ціле поруч із порцією.
                       *
                       * Число на порцію саме по собі нічого не каже тому, хто
                       * ставить каструлю на сімʼю: він бачить 535 і не знає, чи
                       * це багато на всю каструлю. Обидва числа поруч знімають
                       * питання, і обидва вже є: ціле це порція на кількість
                       * порцій. */
                      Text.rich(
                        TextSpan(
                          text: '${dataUnits.enNum(r.kcal)} ',
                          children: [
                            TextSpan(
                              text: dataUnits.enLabel,
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
                      const SizedBox(height: 6),
                      Text(
                        l.rcWhole(
                          dataUnits.enText(r.kcal * r.servings),
                          dataUnits.porText(r.gramsPerServing * r.servings),
                        ),
                        style: context.t.labelSmall,
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
                  aside: l.rcItemsTotal(dataUnits.porText(total)),
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
                                l.gramsUnit(dataUnits.porText(item.grams)),
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
              /* «Записати в щоденник» тут прибрана свідомо: рецепт записують
                 тоді, коли його приготували і зʼїли, а не коли читають, і
                 дорога для цього вже є: сказати Норі в смугу внизу. */
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

/* Смуга розмови на сторінці страви.
 *
 * Своя обгортка, бо тут вона мусить слухати стрічку: сторінка сама по собі
 * нерухома, а розмова під нею живе. Без слухача нове повідомлення лягало б у
 * список і не перемальовувало нічого.
 *
 * Обрана з розмови страва підміняє сторінку, а не лягає поверх неї: вибирали
 * замість цієї, і стос із двох рецептів означав би, що «назад» веде до страви,
 * від якої людина щойно відмовилась. */
class _TalkHere extends StatefulWidget {
  const _TalkHere({required this.desk, required this.dish});

  final RecipeDesk desk;
  final RecipeData dish;

  @override
  State<_TalkHere> createState() => _TalkHereState();
}

class _TalkHereState extends State<_TalkHere> {
  @override
  void initState() {
    super.initState();
    widget.desk.addListener(_redraw);
  }

  void _redraw() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.desk.removeListener(_redraw);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RecipeBar(
    desk: widget.desk,
    dish: widget.dish,
    onOpened: (r) => Navigator.of(context).pushReplacement(
      slideRoute(RecipeView(recipe: r, desk: widget.desk)),
    ),
  );
}
