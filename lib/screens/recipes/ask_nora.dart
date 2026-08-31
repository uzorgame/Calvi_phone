part of 'recipes_screen.dart';

/* Аркуш «Що є на кухні?»: питання, «Думаю…» і вибір із трьох страв.
 * Частина бібліотеки recipes_screen, див. примітку в recipe_view.dart. */

/// Відкриває аркуш «Що є на кухні?» і повертає збережений рецепт, коли людина
/// обрала страву. Після «Думаю…» аркуш не закривається, а перетворюється на
/// вибір із трьох: рецептом стає лише те, у що тицьнули.
Future<RecipeData?> askNoraForRecipe(BuildContext context) async {
  final scope = AppScope.of(context);
  final l = L.of(context);
  final draft = TextEditingController();

  /* Обличчя аркуша живе тут, а тіло міняє його фазами: «Що є на кухні?» зі
     штатними [Скасувати][Спитати], «Думаю…» кільцем у кнопці згоди, і «Обери
     страву» з однією кнопкою виходу. Один в один з аркушем демки: заголовок і
     кнопки стоять там, де в кожного іншого аркуша, і міняються на місці. */
  final face = ValueNotifier(CalviSheetFace(title: l.rcAskTitle, done: l.rcAskGo));

  RecipeData? saved;
  await calviSheet<void>(
    context,
    title: l.rcAskTitle,
    face: face,
    /* Той самий бічний відступ, що в низу аркуша: без нього поле і рядки
       страв лягали впритул до краю екрана. */
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: CalviSize.gutter),
      child: _AskBody(
        draft: draft,
        real: scope.real,
        face: face,
        onPicked: (r) => saved = r,
      ),
    ),
  );
  draft.dispose();
  face.dispose();
  return saved;
}

class _AskBody extends StatefulWidget {
  const _AskBody({
    required this.draft,
    required this.real,
    required this.face,
    required this.onPicked,
  });

  final TextEditingController draft;
  final bool real;
  final ValueNotifier<CalviSheetFace> face;
  final ValueChanged<RecipeData> onPicked;

  @override
  State<_AskBody> createState() => _AskBodyState();
}

enum _AskPhase { input, busy, pick }

class _AskBodyState extends State<_AskBody> {
  _AskPhase _phase = _AskPhase.input;
  List<RecipeData> _options = const [];
  String? _error;
  Timer? _timer;
  bool _armed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    /* Обличчя народилось без дії на «Спитати», бо _go живе тут: перша ж
       побудова вішає його. */
    if (_armed) return;
    _armed = true;
    widget.face.value = _faceOf(_AskPhase.input);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  CalviSheetFace _faceOf(_AskPhase phase) {
    final l = L.of(context);
    return switch (phase) {
      _AskPhase.input => CalviSheetFace(title: l.rcAskTitle, done: l.rcAskGo, onDone: _go),
      _AskPhase.busy => CalviSheetFace(title: l.rcAskTitle, done: l.rcAsking, busy: true),
      _AskPhase.pick => CalviSheetFace(title: l.rcPickTitle, done: l.rcAskCancel, info: true),
    };
  }

  void _turn(_AskPhase phase) {
    _phase = phase;
    widget.face.value = _faceOf(phase);
  }

  Future<void> _go() async {
    final what = widget.draft.text.trim();
    if (what.isEmpty || _phase == _AskPhase.busy) return;
    setState(() {
      _turn(_AskPhase.busy);
      _error = null;
    });

    if (!widget.real) {
      /* Демо тримає паузу і показує заготовлену трійку: моделі тут немає, а
         миттєвий «підбір» читався б як несправжній. */
      _timer = Timer(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        setState(() {
          _options = demoRecipeOptions();
          _turn(_AskPhase.pick);
        });
      });
      return;
    }

    final sync = AppScope.of(context).sync;
    if (sync == null) return;
    try {
      final options = await sync.suggestRecipes(what);
      if (!mounted) return;
      setState(() {
        _options = options;
        _turn(options.isEmpty ? _AskPhase.input : _AskPhase.pick);
        if (options.isEmpty) _error = L.of(context).rcSuggestFailed;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _turn(_AskPhase.input);
        _error = L.of(context).rcSuggestFailed;
      });
    }
  }

  Future<void> _pick(RecipeData r) async {
    final scope = AppScope.of(context);
    final nav = Navigator.of(context);
    if (!scope.real || scope.sync == null) {
      widget.onPicked(r);
      nav.pop();
      return;
    }
    try {
      final saved = await scope.sync!.saveRecipe(r);
      if (!mounted) return;
      widget.onPicked(saved);
      nav.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = L.of(context).rcSuggestFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);

    if (_phase == _AskPhase.pick) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          /* Назви страв, а не готові картки: людина обирає, що приготувати,
             а деталі чекають на сторінці рецепта, яка відкриється одразу.
             Рядки заходять сходинками, як у демці. */
          for (final (i, r) in _options.indexed) ...[
            if (i > 0) Container(height: 1, color: c.cardBorder),
            _Rise(
              delay: i * 70,
              child: GestureDetector(
              onTap: () => _pick(r),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
                child: Row(
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
                          Text(
                            r.title,
                            style: context.t.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${l.rcMinutes(r.minutes)} · ${r.kcal} ${l.unitKcal} ${l.rcPerServing}',
                            style: context.t.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ),
          ],
          /* Збереження обраного не вийшло: рядок про це стоїть під списком,
             а список лишається, щоб спробувати ще раз. */
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style: context.t.labelSmall?.copyWith(color: c.protein),
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: widget.draft,
          enabled: _phase != _AskPhase.busy,
          onSubmitted: (_) => _go(),
          textInputAction: TextInputAction.send,
          style: context.t.bodyMedium?.copyWith(color: c.text),
          decoration: InputDecoration(
            isDense: true,
            hintText: l.rcAskPlaceholder,
            hintStyle: context.t.bodyMedium?.copyWith(color: c.faint),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            filled: true,
            fillColor: c.fillSecondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CalviSize.rCard),
              borderSide: BorderSide(color: c.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CalviSize.rCard),
              borderSide: BorderSide(color: c.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CalviSize.rCard),
              borderSide: BorderSide(color: c.text),
            ),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              _error!,
              style: context.t.labelSmall?.copyWith(color: c.protein),
            ),
          ),
      ],
    );
  }
}


/* --- Розмова про рецепт --- */
