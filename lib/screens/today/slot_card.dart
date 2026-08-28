import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../design/fold.dart';
import '../../design/icons.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../l10n/app_localizations.dart';
import 'manual_form.dart';

/// The shell every card of the day wears.
///
/// Meals, water, training and the tape are different things inside, but the day
/// reads as one list only if they open the same way and carry their figure in
/// the same corner. The shell owns that; each card owns only its contents.
class SlotCard extends StatefulWidget {
  const SlotCard({
    super.key,
    required this.icon,
    required this.title,
    required this.sub,
    required this.badge,
    required this.open,
    required this.onToggle,
    required this.child,
  });

  final String icon;
  final String title;

  /// The quiet line under the title: how much is in the card, in words.
  final String sub;

  /// The card's figure, in the pill on the right.
  final String badge;

  final bool open;
  final VoidCallback onToggle;
  final Widget child;

  @override
  State<SlotCard> createState() => _SlotCardState();
}

class _SlotCardState extends State<SlotCard> with SingleTickerProviderStateMixin {
  /// The contents, measured where they are laid out at their full size.
  final _inside = GlobalKey();

  /* Drives the page down while the card grows. Built here rather than lazily:
     a card nobody ever opened would otherwise create it for the first time
     inside dispose, where there is no ticker left to hang it on. */
  late final AnimationController _rideAt;

  @override
  void initState() {
    super.initState();
    _rideAt = AnimationController(vsync: this, duration: _openMs)..addListener(_ride);
  }

  @override
  void dispose() {
    _rideAt
      ..removeListener(_ride)
      ..dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SlotCard old) {
    super.didUpdateWidget(old);
    if (!old.open && widget.open) _follow();
  }

  /* The page comes down with the card. Opening a card near the foot of the day
     used to push what you just asked for below the screen, and the answer was
     to scroll by hand: the card had already told the page it needed room, and
     asking twice for the same thing is a thing an app should do for itself.

     The move is one animation, the same length and the same curve the card
     opens with, so the two read as one movement rather than as a scroll
     chasing a card. */
  /// Where the page stood when the card started opening.
  double _from = 0;

  void _follow() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final position = Scrollable.maybeOf(context)?.position;
      if (position == null) return;
      _from = position.pixels;
      _rideAt.forward(from: 0);
    });
  }

  /* Driven frame by frame rather than handed to animateTo, and the target is
     asked again on every one of those frames. The card is still growing while
     the run happens, so both the place it has to reach and the end of the list
     move underneath: an animation aimed once is clipped to the end as it stood
     when it started, and stops short by exactly the height the card added. */
  void _ride() {
    if (!mounted) return;
    final position = Scrollable.maybeOf(context)?.position;
    final box = context.findRenderObject() as RenderBox?;
    if (position == null || box == null || !box.attached) return;
    if (!position.hasContentDimensions) return;

    /* The assistant bar floats over the foot of the day, so what counts as
       visible ends above it rather than at the bottom edge of the screen.
       Stopping at the edge is what left the opened card sitting under the bar. */
    final under = CalviSize.barRoom + MediaQuery.paddingOf(context).bottom + _footRoom;
    final viewport = RenderAbstractViewport.of(box);

    // What it would take to put the card's head at the top of the screen, and
    // its foot clear of the bar. The card grows, so both move as it opens.
    final head = viewport.getOffsetToReveal(box, 0).offset - _footRoom;
    final foot = viewport.getOffsetToReveal(box, 1).offset + under;

    /* As little as the card needs, and nothing for the sake of tidiness. The
       page moves only when something is actually out of sight: up when the head
       has gone past the top edge, down when the foot is under the bar, and not
       at all when the whole card is already there. Pulling every opened card to
       the top instead was the version that yanked the day upward when a card in
       plain view was tapped. */
    final target = _from > head
        ? head
        : _from < foot
        ? foot
        : _from;

    final at = _from + (target - _from) * CalviMotion.easeRise.transform(_rideAt.value);
    position.jumpTo(at.clamp(position.minScrollExtent, position.maxScrollExtent));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final open = widget.open;

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: c.cardBorder),
        borderRadius: BorderRadius.circular(CalviSize.rLarge),
        boxShadow: context.shadowCard,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          GestureDetector(
            onTap: widget.onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: LayoutBuilder(
                builder: (context, box) {
                  final titleStyle = context.t.titleMedium;
                  final badgeStyle = context.t.titleMedium?.copyWith(fontSize: CalviSize.fsMicro);

                  /* Назва не переноситься і не обрізається.
                   *
                   * На вузькому телефоні «Вимірювання» ламалось посеред слова, а
                   * англійське «Measurements» лишало на другому рядку саму літеру
                   * «s». Назва картки це її імʼя, і зламане навпіл імʼя гірше за
                   * будь-який інший вихід.
                   *
                   * Тому місце ділиться міркою, а не порівну: назва бере рівно
                   * стільки, скільки їй треба, але не більше двох третин, щоб
                   * значку лишалась хоч третина. Далі обидва зменшуються замість
                   * того, щоб ламатись або ховати хвіст під трикрапку: слово, яке
                   * стало на пів пункту дрібнішим, читається, а «ще ніч…» ні. */
                  final room = box.maxWidth - 42 - 12 - 8 - 16;
                  double wide(String text, TextStyle? style) => (TextPainter(
                    text: TextSpan(text: text, style: style),
                    textDirection: TextDirection.ltr,
                    maxLines: 1,
                  )..layout()).width;

                  final forTitle = math.min(wide(widget.title, titleStyle), room * 0.62);

                  return Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: c.iconCircle),
                        child: CalviIcon(widget.icon, size: 19),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(widget.title, maxLines: 1, style: titleStyle),
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Найтихіший рядок здається першим: він єдиний тут,
                            // чий хвіст можна вгадати, не читаючи.
                            Text(
                              widget.sub,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.t.labelSmall,
                            ),
                          ],
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: math.max(room - forTitle, 0)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                          decoration: BoxDecoration(
                            color: c.fillSecondary,
                            borderRadius: BorderRadius.circular(CalviSize.rPill),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(widget.badge, maxLines: 1, style: badgeStyle),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      /* Down when shut, up when open: the arrow says which way a
                         tap will move the fold, not where the content went. */
                      AnimatedRotation(
                        turns: open ? -0.25 : 0.25,
                        duration: CalviMotion.normal,
                        curve: CalviMotion.ease,
                        child: CalviIcon('chevron', size: 16, color: c.textSecondary),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Сам рух спільний на застосунок, див. [CalviFold].
          CalviFold(
            open: open,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SizedBox(key: _inside, width: double.infinity, child: widget.child),
            ),
          ),
        ],
      ),
    );
  }
}

/// How long a card takes to open, and how much of the page is left under it.
const _openMs = Duration(milliseconds: 440);
const _footRoom = 16.0;

/// The row that adds something to a card: a plus, and what it adds.
class AddRow extends StatelessWidget {
  const AddRow({super.key, required this.label, required this.open, required this.onTap});

  final String label;

  /// Open rows offer to fold instead, so the mark says which way the tap goes.
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CustomPaint(
        painter: _DashedEdge(colour: c.hairline, radius: CalviSize.rCard),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: c.iconCircle),
                child: CalviIcon(open ? 'minus' : 'plus', size: 19, color: c.text),
              ),
              const SizedBox(width: 13),
              /* Гнучкий, бо напис буває довгим: «Додати до пізньої вечері» на
                 вузькому телефоні не влазить у ряд, а негнучкий текст у ряду не
                 переноситься, а вилазить за край смугастою стрічкою. */
              Expanded(
                child: Text(
                  label,
                  style: context.t.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The dashed outline of a row that offers to add something.
class _DashedEdge extends CustomPainter {
  _DashedEdge({required this.colour, required this.radius});

  final Color colour;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final shape = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = colour;

    /* Two on, two off, the length a browser gives a one pixel dashed border.
       Longer dashes read as a stitched seam rather than as an outline that is
       not quite there yet, which is what this row is saying. */
    for (final part in (Path()..addRRect(shape)).computeMetrics()) {
      for (var at = 0.0; at < part.length; at += 4) {
        canvas.drawPath(part.extractPath(at, math.min(at + 2, part.length)), line);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedEdge old) => old.colour != colour || old.radius != radius;
}

/// The per-card way in.
///
/// The bar at the bottom of the screen is the main one and it already knows the
/// card; this field exists for the moment you are looking straight at the card
/// you mean, and it saves the step of saying which one.
/// **Хто рахує числа, вирішується тут, і правило одне.** За замовчуванням рахує
/// Нора: більшість записів це «борщ 500 грам», і вони мають коштувати один
/// дотик. Форма з полями відкривається рівно там, де Норі нічим платити: токени
/// скінчились, підписки немає. Плюс, який то рахує сам, то просить порахувати
/// тебе, був би кнопкою з двома значеннями, а вгадувати, яке з них зараз,
/// людина не мусить.
///
/// Другий вхід у форму це «Ввести числа самому» під полем: для тих випадків,
/// коли упаковка в руці й точні числа відомі краще за будь-який довідник. Він
/// зʼявляється тільки коли в полі щось є, тому порожня картка лишається
/// порожньою.
class SlotInput extends StatefulWidget {
  const SlotInput({
    super.key,
    required this.onSend,
    required this.onManual,
    required this.noraCan,
    this.open = true,
    this.onWriting,
  });

  /// Нора рахує сама: швидкий шлях, один дотик.
  final ValueChanged<String> onSend;

  /// Числа вписала людина.
  final ValueChanged<ManualEntry> onManual;

  /// Чи Норі є чим платити. Рішення живе вище, бо залежить від балансу і
  /// підписки, про які поле вводу не знає.
  final bool noraCan;

  /* Чи картка розгорнута. Поле мусить це знати, бо згорнута картка не
     прибирає своїх дітей з дерева: форма, залишена відкритою, тримала б
     сигнал «пишу» вічно, і нижня панель не поверталась би ніколи. */
  final bool open;

  /* Людина пише сюди, а не в чат. Екран за цим сигналом опускає нижню панель:
     вона разом із клавіатурою накривала саме те, що людина в цю мить заповнює.
     `true` тримається, поки живе набирання: фокус у полі або відкрита форма. */
  final ValueChanged<bool>? onWriting;

  @override
  State<SlotInput> createState() => _SlotInputState();
}

class _SlotInputState extends State<SlotInput> with WidgetsBindingObserver {
  final _text = TextEditingController();
  final _focus = FocusNode();

  /// Чи форма розгорнута.
  bool _filling = false;

  /* Назва, яку форма зараз показує. Не гаситься на закритті: поки складка
     згортається, вміст усередині ще видно, і порожній заголовок мигнув би на
     самому початку руху. */
  String _naming = '';

  /* Лічильник відкриттів. Форма лишається в дереві, поки згортається, тому сама
     вона свої поля не чистить: без цього ключа наступна страва відкривалась би
     з чужими числами. */
  int _round = 0;

  /* Останнє, що сказали екрану. Сигнал шлеться на зміну, а не на кожен рух
     фокуса: слухач нагорі робить setState, і смикати його однаковими
     значеннями означало б перебудовувати екран на кожен блимок каретки. */
  bool _told = false;

  void _tell() {
    final writing = _focus.hasFocus || _filling;
    if (writing == _told) return;
    _told = writing;
    widget.onWriting?.call(writing);
  }

  @override
  void initState() {
    super.initState();
    _focus.addListener(_tell);
    _focus.addListener(_peek);
    // Щоб почути, як клавіатуру закрили повз нас: жестом «назад» або системою.
    WidgetsBinding.instance.addObserver(this);
    _kb = _insetNow;
  }

  @override
  void dispose() {
    /* Картка йде з екрана разом із днем, який гортнули. Панель, яку забули
       підняти, лишилась би внизу назавжди. */
    if (_told) widget.onWriting?.call(false);
    WidgetsBinding.instance.removeObserver(this);
    _reveal?.cancel();
    _focus
      ..removeListener(_peek)
      ..removeListener(_tell)
      ..dispose();
    _text.dispose();
    super.dispose();
  }

  /* Згорнута картка закриває і свою форму.
   *
   * Складка не прибирає вміст із дерева, тому форма, залишена відкритою в
   * згорнутій картці, жила далі невидимою: сигнал «пишу» тримався вічно, і
   * нижня панель не поверталась до перезапуску застосунку. */
  @override
  void didUpdateWidget(SlotInput old) {
    super.didUpdateWidget(old);
    if (old.open && !widget.open && _filling) {
      setState(() => _filling = false);
      _tell();
    }
  }

  /// Висота клавіатури минулого разу, коли ми дивились.
  double _kb = 0;

  double get _insetNow {
    final view = WidgetsBinding.instance.platformDispatcher.implicitView;
    if (view == null) return 0;
    return view.viewInsets.bottom / view.devicePixelRatio;
  }

  /* Клавіатуру закрили ззовні: жестом «назад», шторкою, самою системою.
   *
   * Android у такому разі ховає клавіатуру, але фокус лишається в полі, а
   * панель повертається саме за сигналом «фокус пішов». Сигнал не приходив
   * ніколи, і панель зникала до перезапуску. Тому за зникненням клавіатури
   * поле відпускає фокус саме: писати без клавіатури однаково не можна. */
  @override
  void didChangeMetrics() {
    final was = _kb;
    _kb = _insetNow;
    if (was > 0 && _kb <= 0 && _focus.hasFocus) _focus.unfocus();
  }

  /* Поле доїжджає у видиму зону, коли клавіатура встала.
   *
   * Прокрутка сама цього не робить: вікно не стискається під клавіатуру
   * (панель їздить над нею), тож для системи поле «видиме», хоч і лежить під
   * клавіатурою. Пауза дає клавіатурі виїхати, а запасу знизу вирости. */
  Timer? _reveal;

  void _peek() {
    _reveal?.cancel();
    if (!_focus.hasFocus) return;
    _reveal = Timer(const Duration(milliseconds: 380), _intoView);
  }

  void _intoView() {
    if (!mounted || !_focus.hasFocus) return;
    final box = context.findRenderObject() as RenderBox?;
    final scroll = Scrollable.maybeOf(context)?.position;
    if (box == null || !box.attached || scroll == null) return;

    final kb = MediaQuery.viewInsetsOf(context).bottom;
    if (kb <= 0) return;

    // Низ усього блока вводу проти верху клавіатури, з малим повітрям між ними.
    final bottom = box.localToGlobal(Offset(0, box.size.height)).dy;
    final over = bottom + 12 - (MediaQuery.sizeOf(context).height - kb);
    if (over <= 0) return;

    scroll.animateTo(
      (scroll.pixels + over).clamp(scroll.minScrollExtent, scroll.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: CalviMotion.easeRise,
    );
  }

  void _open(String name) {
    HapticFeedback.selectionClick();
    setState(() {
      _naming = name;
      _round++;
      _filling = true;
      _text.clear();
    });
    /* Клавіатура ховається вся, а не лише з нашого поля: далі людина спершу
       вибирає очима, куди вписувати, і клавіатура текстового поля їй у цьому
       тільки затуляла форму. Панель при цьому лишається внизу: форма це теж
       набирання, просто по пʼяти полях. */
    _focus.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    _tell();
  }

  /// Набирання скінчилось: каретка додолу, панель повертається.
  void _done() {
    _focus.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    _tell();
  }

  void _send() {
    final t = _text.text.trim();
    if (t.isEmpty) return;
    if (!widget.noraCan) return _open(t);

    HapticFeedback.selectionClick();
    widget.onSend(t);
    _text.clear();
    setState(() {});
    /* «Плюс» це кінець запису, а не кома в ньому: клавіатура ховається, панель
       піднімається назад. Наступну страву почнуть новим дотиком. */
    _done();
  }

  @override
  Widget build(BuildContext context) {
    /* Обидві половини згортаються тим самим рухом, що й картки дня: поле вводу
       складається, форма розкладається. Одна зникає рівно так, як зʼявляється
       друга, тому підміна читається як один рух, а не як дві незалежні появи. */
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CalviFold(open: !_filling, child: _writing(context)),

        /* Форма зʼявляється в дереві з першим відкриттям і лишається в ньому
           далі, щоб закриття було чим анімувати. До того її немає зовсім: пʼять
           полів вводу на кожній картці кожного дня це і зайва робота на кожен
           кадр, і три кольорові крапки БЖВ, яких на екрані ніхто не просив. */
        if (_round > 0)
          CalviFold(
            open: _filling,
            child: ManualForm(
              key: ValueKey(_round),
              title: _naming,
              onCancel: () {
                setState(() => _filling = false);
                _done();
              },
              onSave: (entry) {
                setState(() => _filling = false);
                widget.onManual(entry);
                _done();
              },
            ),
          ),
      ],
    );
  }

  Widget _writing(BuildContext context) {
    final c = context.c;
    final ready = _text.text.trim().isNotEmpty;

    final row = Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: c.fillSecondary,
                border: Border.all(color: c.cardBorder),
                borderRadius: BorderRadius.circular(CalviSize.rCard),
              ),
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                controller: _text,
                focusNode: _focus,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _send(),
                textInputAction: TextInputAction.send,
                maxLength: 120,
                style: context.t.bodyLarge?.copyWith(fontSize: 15),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  counterText: '',
                  border: InputBorder.none,
                  /* No card name and no verb: «на вечеря» needs the accusative
                     and «що ти їв» needs a gender. Both are traps in a field the
                     app fills in for itself, and the card above already says
                     which meal this is. */
                  hintText: L.of(context).slotWriteWhat,
                  hintStyle: context.t.labelSmall?.copyWith(fontSize: 15),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: L.of(context).slotLog,
            child: GestureDetector(
              onTap: ready ? _send : null,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: CalviMotion.fast,
                curve: CalviMotion.ease,
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(CalviSize.rCard),
                  color: ready ? c.button : c.buttonDisabled,
                ),
                /* The mark keeps the button's own ink whether or not there is
                   anything to send. Fading it to the page's grey put a grey
                   plus on a grey ground, which is a button you have to hunt
                   for; the demo dims the ground and leaves the mark alone. */
                child: CalviIcon('plus', size: 17, color: c.buttonText),
              ),
            ),
          ),
        ],
      ),
    );

    /* Другий вхід у форму. Зʼявляється тільки коли в полі щось є: порожня
       картка має лишатись порожньою, а не пропонувати дію, якій нема над чим
       працювати. */
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row,
        CalviFold(
          /* Притиснутий ліворуч рукою: складка центрує вузьких дітей, бо міряє
             висоту через Align. Лінк вужчий за картку, і без цього стояв
             посередині. */
          open: ready,
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => _open(_text.text.trim()),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 2),
                child: Text(
                  L.of(context).slotByHand,
                  style: context.t.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Картка, яка щойно народилась, виростає в список.
///
/// Нора відкриває перекус, коли в нього щось записали, і без цього він просто
/// зʼявляється між двома кадрами: усе, що під ним, стрибає вниз на висоту цілої
/// картки. Стрибок читається як збій верстки, а не як «зʼявилось нове», і людина
/// не встигає помітити, що саме змінилось.
///
/// Рухи ті самі, що й у демці: висота росте з нуля, картка приходить із восьми
/// пікселів угорі й трохи меншою, а прозорість добігає до повної раніше за
/// висоту, щоб картка не проявлялась уже дорісши.
class Arriving extends StatefulWidget {
  const Arriving({super.key, required this.play, required this.child});

  /// Грати появу. Хибно для карток, які вже стояли: щоденний сніданок не
  /// народжується щоразу, коли перемалювався екран.
  final bool play;

  final Widget child;

  @override
  State<Arriving> createState() => _ArrivingState();
}

class _ArrivingState extends State<Arriving> with SingleTickerProviderStateMixin {
  static const _ms = Duration(milliseconds: 460);

  /* Створюється в initState, а не лінивим полем: ліниве народжується при
     першому зверненні, а ним може виявитись сам dispose. */
  late final AnimationController _in;

  @override
  void initState() {
    super.initState();
    _in = AnimationController(vsync: this, duration: _ms, value: widget.play ? 0 : 1);
    if (widget.play) _in.forward();
  }

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /* Обгортки лишаються назавжди, і це не марнотратство, а єдиний спосіб не
       зламати картку під ними. Прибрати їх, коли поява добігла, означає інше
       дерево на тому самому місці: Flutter будує картку заново, а з нею заново
       народжується її стан. Неявні анімації всередині відлічують рух від того,
       що бачили минулого разу, тож новонароджена картка відкривається ривком.
       Найближче перемальовування після появи це і є дотик, яким її відкривають.

       Коштують вони при цьому нічого. Дійшовши до кінця, кожна стає собою
       тотожною, а такі шари Flutter не композитить: прозорість у одиницю
       малює дитину напряму, перетворення без зсуву й масштабу теж, а обрізання
       вимкнене прямо тут. */
    return AnimatedBuilder(
      animation: _in,
      child: widget.child,
      builder: (context, child) {
        final done = _in.isCompleted;
        final grown = CalviMotion.easeRise.transform(_in.value);

        return ClipRect(
          clipBehavior: done ? Clip.none : Clip.hardEdge,
          child: Align(
            alignment: Alignment.topCenter,
            // Висота з нуля: сусіди зʼїжджають, а не стрибають.
            heightFactor: grown,
            child: Opacity(
              // Повна прозорість добігає на сорока відсотках шляху, як у демці.
              opacity: (_in.value / 0.4).clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, -8 * (1 - grown)),
                child: Transform.scale(scale: 0.98 + 0.02 * grown, child: child),
              ),
            ),
          ),
        );
      },
    );
  }
}
