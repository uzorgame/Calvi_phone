part of 'shell.dart';

/* Дії набору: головна кнопка, тиха контурна, нижній аркуш і його живе
 * обличчя. Частина бібліотеки shell, див. примітку в shell_rows.dart. */

/// The wide button at the foot of a screen: the demo's .primary.
///
/// 56 tall, a pill, body-size semibold, and it gives 3% under the finger.
class CalviButton extends StatefulWidget {
  const CalviButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.danger = false,
    this.busy = false,
    this.second,
    this.onSecond,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool danger;

  /* Кнопку натиснули, і вона працює: кільце живе в ній самій, а колір
     лишається темним. Сіра «недоступність» брехала б, робота якраз іде. */
  final bool busy;

  /* The way out, under the action rather than beside it. Beside it, two filled
     buttons compete for the same glance; under it, plain text, the refusal is
     available without being offered. */
  final String? second;
  final VoidCallback? onSecond;

  @override
  State<CalviButton> createState() => _CalviButtonState();
}

class _CalviButtonState extends State<CalviButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final fill = !widget.enabled && !widget.busy
        ? c.buttonDisabled
        : widget.danger
        ? c.protein
        : c.button;

    final button = GestureDetector(
      onTap: widget.enabled && !widget.busy ? widget.onTap : null,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _down && widget.enabled && !widget.busy ? 0.97 : 1,
        duration: CalviMotion.fast,
        curve: CalviMotion.ease,
        child: Container(
          height: CalviSize.buttonH,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(CalviSize.rPill),
            /* Головна дія має вагу: тінь свого ж кольору. Вимкнена її не
               кидає, бо натиснути її зараз не можна. */
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: fill.withValues(alpha: 0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          /* Довгий напис стискається, а не ріжеться: у рядку з двох кнопок
             половина ширини дістається кожній, і «Так, видалити назавжди» має
             лишитись одним рядком, а не трикрапкою. */
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.busy) ...[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: c.buttonText,
                        backgroundColor: c.buttonText.withValues(alpha: 0.28),
                      ),
                    ),
                    const SizedBox(width: 9),
                  ],
                  Text(
                    widget.label,
                    style: context.t.titleMedium?.copyWith(
                      fontSize: CalviSize.fsBody,
                      color: c.buttonText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.second == null) return button;

    /* Дві дії стають рядком, а не стосом: відмова ліворуч, згода праворуч, як у
       нижніх аркушах. Одна над одною вони читались як список із двох пунктів, а
       не як вибір, і головна кнопка втрачала вагу. Тиха отримує заливку: текст
       без фону поруч із чорною таблеткою читається як підпис, а не як дія. */
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: widget.onSecond,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: CalviSize.buttonH,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.fillSecondary,
                borderRadius: BorderRadius.circular(CalviSize.rPill),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.second!,
                  style: context.t.titleMedium?.copyWith(
                    fontSize: CalviSize.fsBody,
                    color: c.text,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: button),
      ],
    );
  }
}

/// Modal sheet that rises from the bottom.
///
/// A sheet that only tells you something needs one way out, not two buttons
/// that do the same thing, so [info] drops the cancel.

/* Обличчя аркуша, що вміє мінятись, поки аркуш відкритий: заголовок, напис
   згоди, зайнятість і режим «тільки вихід». Аркуш дивиться на нього через
   ValueListenable, тож форма всередині міняє фазу одним присвоєнням. */
class CalviSheetFace {
  const CalviSheetFace({
    required this.title,
    required this.done,
    this.info = false,
    this.busy = false,
    this.onDone,
  });

  final String title;

  /// Напис на кнопці згоди.
  final String done;

  /// Одна кнопка на всю ширину: скасовувати нема чого.
  final bool info;

  /// Кільце в кнопці згоди; обидві кнопки не слухають дотиків.
  final bool busy;

  /// Що робить згода. Null означає «просто закрити аркуш».
  final VoidCallback? onDone;
}

Future<T?> calviSheet<T>(
  BuildContext context, {
  required String title,
  required Widget Function(BuildContext) builder,

  /// Напис на кнопці згоди. Порожньо означає «Готово» мовою застосунку.
  String? doneLabel,

  /// Аркуш нічого не питає, а розповідає: скасовувати тут нема чого, тому
  /// внизу лишається одна кнопка виходу замість двох.
  bool info = false,
  VoidCallback? onDone,

  /* Тиха кнопка ліворуч. За умовчанням це «Скасувати», яке просто закриває
     аркуш, але місце те саме і тоді, коли ліворуч стоїть друга дія: аркуш
     закінченого курсу пропонує звідти відновити його. Дія лишається тихою
     кнопкою навмисно: гучна тут одна, і це вихід. */
  String? cancelLabel,
  VoidCallback? onCancel,

  /// Згода руйнівна: нижня кнопка червона, щоб рука знала, що робить.
  bool danger = false,

  /* Живе обличчя аркуша: заголовок і кнопки, що міняються, поки він
     відкритий. Потрібно формам, які перетворюються на місці: «Що є на
     кухні?» після «Думаю…» стає вибором страви з іншим заголовком і однією
     кнопкою виходу. Передане обличчя головніше за title і doneLabel. */
  ValueListenable<CalviSheetFace>? face,
}) {
  /* 340 ms на кривій підйому, як у кожної іншої панелі, що приходить.
   *
   * Свій контролер це єдиний спосіб задати аркушу тривалість, але за нього
   * доводиться і прибирати: Flutter звільняє лише той, що зробив сам, а
   * принесений ззовні лишає жити. Кожне відкриття аркуша лишало по одному
   * тікеру на навігаторі, і за сеанс їх набиралися сотні.
   *
   * Звільняється тоді, коли аркуш опустився до кінця, а не коли його закрили:
   * закриття це початок зворотного шляху, і контролер потрібен ще всю його
   * довжину. Мікрозадача тому, що прибирати слухача зсередини нього самого
   * означає рвати список, яким Flutter саме йде. */
  final rise = AnimationController(
    vsync: Navigator.of(context),
    duration: const Duration(milliseconds: 340),
    reverseDuration: CalviMotion.normal,
  );
  rise.addStatusListener((state) {
    if (state == AnimationStatus.dismissed) scheduleMicrotask(rise.dispose);
  });

  return showModalBottomSheet<T>(
    context: context,
    transitionAnimationController: rise,
    backgroundColor: const Color(0x00000000),
    barrierColor: context.c.text.withValues(alpha: 0.34),
    isScrollControlled: true,
    builder: (sheetContext) {
      final c = sheetContext.c;
      /* Аркуш заходить у краї екрана, скруглений тільки згори.
       *
       * Тут був відступ у вісім пікселів з усіх боків, і аркуш висів карткою:
       * знизу й по боках проглядало затемнене тло. Аркуш, що приходить знизу,
       * має впиратись у край, інакше він читається як вікно поверх екрана, а не
       * як продовження екрана. */
      /* Стеля висоти живе тут, а не в кожній формі окремо.
       *
       * Аркуш це картка знизу, і три чверті екрана це вже його межа: вище він
       * читається як повноекранне вікно, і затемнений день за ним зникає.
       * Форма всередині прокручується, тому впиратись у стелю їй не боляче.
       * Доти правило трималось на тому, що вміст випадково влазив, і кнопка
       * згоди внизу його порушила. */
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.75),
        child: CalviOn(
          // Усе всередині лежить на аркуші, а не на сторінці. Див. [CalviOn].
          color: c.card,
          child: Container(
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(CalviSize.rLarge)),
            ),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: c.hairline,
                        borderRadius: BorderRadius.circular(CalviSize.rPill),
                      ),
                    ),
                  ),
                  /* У шапці тільки назва, по центру.
                   *
                   * Дрібні слова обабіч заголовка зливалися з ним в один рядок,
                   * і не було видно, що з трьох написів натискаються два; до
                   * того ж кожен аркуш розставляв їх по-своєму. Усі дії тепер
                   * унизу, однаково в кожному аркуші. */
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                    child: face == null
                        ? Text(title, textAlign: TextAlign.center, style: sheetContext.t.titleMedium)
                        : ValueListenableBuilder(
                            valueListenable: face,
                            builder: (_, f, _) => Text(
                              f.title,
                              textAlign: TextAlign.center,
                              style: sheetContext.t.titleMedium,
                            ),
                          ),
                  ),
                  Flexible(child: builder(sheetContext)),
                  if (face != null)
                    ValueListenableBuilder(
                      valueListenable: face,
                      builder: (_, f, _) => Padding(
                        padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 18, CalviSize.gutter, 12),
                        child: Row(
                          children: [
                            if (!f.info) ...[
                              Expanded(
                                child: GestureDetector(
                                  // Скасувати роботу, яку вже почали, не можна.
                                  onTap: f.busy
                                      ? null
                                      : () {
                                          onCancel?.call();
                                          Navigator.of(sheetContext).pop();
                                        },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    height: CalviSize.buttonH,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: c.fillSecondary,
                                      borderRadius: BorderRadius.circular(CalviSize.rPill),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        cancelLabel ?? L.of(sheetContext).actionCancel,
                                        style: sheetContext.t.titleMedium?.copyWith(
                                          fontSize: CalviSize.fsBody,
                                          color: c.text,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Expanded(
                              child: CalviButton(
                                label: f.done,
                                busy: f.busy,
                                onTap: () {
                                  // Згода без власної дії просто закриває аркуш.
                                  final act = f.onDone;
                                  if (act != null) {
                                    act();
                                  } else {
                                    Navigator.of(sheetContext).pop();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                  /* Дві кнопки в один рядок: скасування ліворуч, згода праворуч,
                     як у системних діалогах. Одна над одною вони читались як
                     список, а не як вибір із двох. Скасування тихою заливкою:
                     обидві відповіді виглядають як відповіді, але за погляд не
                     сперечаються. Інформаційний аркуш тримає одну кнопку на всю
                     ширину: скасовувати там нема чого. */
                  Padding(
                    padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 18, CalviSize.gutter, 12),
                    child: Row(
                      children: [
                        if (!info) ...[
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                onCancel?.call();
                                Navigator.of(sheetContext).pop();
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                height: CalviSize.buttonH,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: c.fillSecondary,
                                  borderRadius: BorderRadius.circular(CalviSize.rPill),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    cancelLabel ?? L.of(sheetContext).actionCancel,
                                    style: sheetContext.t.titleMedium?.copyWith(
                                      fontSize: CalviSize.fsBody,
                                      color: c.text,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: CalviButton(
                            label: doneLabel ?? L.of(sheetContext).actionDone,
                            danger: danger,
                            onTap: () {
                              onDone?.call();
                              Navigator.of(sheetContext).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// A row of states with the mark sliding between them.
///
/// One widget for two options and for four: the choice is one thing moving, not
/// several things toggling, and three hand-rolled copies of that idea drift into
/// three slightly different animations.
/// Тиха кнопка на зріст звичайної: контур замість заливки.
///
/// Другорядна дія поруч із головною. Дві залиті кнопки сперечаються за один
/// погляд; контурна стоїть поруч і не перебиває. Народилась на екрані
/// знайомства («Продовжити з Apple», «Поки без входу») і переїхала сюди, щойно
/// знадобилась удруге: дві приватні копії однієї кнопки розходяться з першою ж
/// правкою однієї з них.
class CalviGhost extends StatefulWidget {
  const CalviGhost({super.key, required this.label, required this.onTap, this.enabled = true});

  final String label;
  final VoidCallback onTap;

  /* Вимкнена кнопка мовчить і не втискається під пальцем.
   *
   * Доти зайняту кнопку «вимикали» порожнім обробником: вона й далі гралася
   * натиском, тобто відповідала на дотик, не роблячи нічого. Це читається як
   * поломка, а не як «зачекай». */
  final bool enabled;

  @override
  State<CalviGhost> createState() => _CalviGhostState();
}

class _CalviGhostState extends State<CalviGhost> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final on = widget.enabled;
    return GestureDetector(
      onTap: on ? widget.onTap : null,
      onTapDown: on ? (_) => setState(() => _down = true) : null,
      onTapUp: on ? (_) => setState(() => _down = false) : null,
      onTapCancel: on ? () => setState(() => _down = false) : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _down && on ? 0.98 : 1,
        duration: CalviMotion.fast,
        curve: CalviMotion.ease,
        child: Container(
          height: CalviSize.buttonH,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CalviSize.rPill),
            border: Border.all(color: c.hairline),
          ),
          child: Text(
            widget.label,
            style: context.t.titleMedium?.copyWith(
              fontSize: CalviSize.fsBody,
              color: on ? c.text : c.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
