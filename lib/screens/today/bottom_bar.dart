import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../data/chat.dart';
import '../../design/icons.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import 'plate_strip.dart';
import '../../l10n/app_localizations.dart';

/// Bottom of the screen: the input field, nothing else.
///
/// No plus button, because the field itself is the primary action, and no tab
/// bar, because navigation moved up beside the day figures.
///
/// **Touching the field raises it into the chat.** It does not jump to another
/// screen: the same field grows upward and the room above it fills in, so what
/// you were about to type is still under the thumb the whole way. A tap that
/// replaces the screen loses the sentence the person had already started.
///
/// Touching the **field itself** also puts the caret in it, which on a phone is
/// what raises the keyboard. Touching anywhere else on the bar opens the room
/// and leaves the keyboard down, because opening the chat to read what Nora said
/// is not the same act as opening it to write.
class BottomBar extends StatefulWidget {
  const BottomBar({
    super.key,
    required this.slot,
    required this.open,
    required this.onOpen,
    required this.onClose,
    required this.onCamera,
    required this.onHold,
    required this.onLetGo,
    required this.onSend,
    required this.messages,
    /* Обрана вага у відповідь на питання Нори. Один дотик замість набирання. */
    this.onWeigh,
    this.muteMic = false,
  });

  /// Card the next entry lands in.
  final String slot;
  final bool open;

  /// True only when the field itself was touched.
  final ValueChanged<bool> onOpen;
  final VoidCallback onClose;
  final VoidCallback onCamera;

  /// Палець ліг на мікрофон: запис починається цієї ж миті.
  final void Function(Offset at, double size) onHold;

  /// Палець прибрали: запис спиняється, і сказане йде на розбір.
  final VoidCallback onLetGo;

  /// What was typed into the bar, in the person's own words.
  final ValueChanged<String> onSend;
  final List<Msg> messages;
  final void Function(String id, int grams)? onWeigh;

  /// While dictation is on, the small microphone steps aside for the big one.
  final bool muteMic;

  @override
  State<BottomBar> createState() => _BottomBarState();
}

/// Opening is slower than closing and lands softer: the room arriving is worth
/// watching, the room leaving is not.
const _opening = Duration(milliseconds: 560);
const _closing = Duration(milliseconds: 380);

/* The contents come a beat behind the height, so the room opens and then fills
   instead of sliding what is in it through a gap that is still growing. On the
   way out they go first and fast, so the room is empty by the time it folds. */
const _fillIn = Duration(milliseconds: 340);
const _fillOut = Duration(milliseconds: 160);

/// How long the contents wait before following the height up.
const _fillDelay = Duration(milliseconds: 220);

/// And how far they sit below their place while they wait.
const _fillLift = 12.0;

class _BottomBarState extends State<BottomBar> {
  final _field = TextEditingController();
  final _focus = FocusNode();
  final _room = ScrollController();

  @override
  void initState() {
    super.initState();
    /* The caret landing in the field is what raises the chat, not a tap on it.
       A tap can be lost to the bar's own recogniser or to the platform's text
       handling, and the demo listens for focus for exactly that reason: however
       the caret got there, the room is what should be under it. */
    _focus.addListener(_raise);
  }

  void _raise() {
    if (!_focus.hasFocus || widget.open) return;
    /* Next frame, not this one. Focus can land while the tree is being built,
       and telling the screen above to rebuild in the middle of its own build is
       the kind of thing that works until it does not. */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _focus.hasFocus && !widget.open) widget.onOpen(true);
    });
  }

  @override
  void dispose() {
    _later?.cancel();
    _focus.removeListener(_raise);
    _field.dispose();
    _focus.dispose();
    _room.dispose();
    super.dispose();
  }

  void _send() {
    final t = _field.text.trim();
    if (t.isEmpty) return;
    /* The field empties before the answer comes back, so the next sentence can
       start while Nora is still reading the last one. */
    _field.clear();
    widget.onSend(t);
  }

  @override
  void didUpdateWidget(BottomBar old) {
    super.didUpdateWidget(old);

    /* Closing puts the caret down as well. On a phone a field that keeps focus
       keeps the keyboard up, and the chat would fold away behind it. */
    if (old.open && !widget.open) _focus.unfocus();

    /* A new message is only useful if it is the one in view.

       The count is kept here rather than compared against `old.messages`: the
       list arrives by reference and is appended to in place, so the old widget
       and the new one hold the same object and their lengths are always equal.
       That comparison was always false and the room never followed a reply. */
    if (widget.open && widget.messages.length != _seen) {
      _seen = widget.messages.length;
      _toBottom();
    }

    /* І ще раз, коли панель доїхала.
     *
     * Сказане голосом приходить разом із відкриттям панелі, і домотування
     * рахувалось по кімнаті, яка ще не має повної висоти: кінець списку тоді
     * ще не там, де він буде за пів секунди. Тому нове повідомлення лишалось
     * унизу за краєм, і людина бачила середину розмови замість своєї останньої
     * фрази. */
    if (!old.open && widget.open) {
      _toBottom(after: _opening + const Duration(milliseconds: 60));
    }
  }

  /// Домотує кімнату до останнього рядка. З відступом, коли панель ще їде.
  void _toBottom({Duration? after}) {
    void go() {
      if (!mounted || !_room.hasClients) return;
      _room.animateTo(
        _room.position.maxScrollExtent,
        duration: CalviMotion.normal,
        curve: CalviMotion.ease,
      );
    }

    if (after == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => go());
    } else {
      _later?.cancel();
      _later = Timer(after, go);
    }
  }

  /// How many messages the room has already scrolled for.
  int _seen = 0;

  /* Відкладене домотування знімається разом із рядком: відкладений виклик без
     цього переживає віджет і спрацьовує вже над мертвим екраном. */
  Timer? _later;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final open = widget.open;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        /* Everything behind the raised field dims rather than disappears: the
           day is still the context for what is being written.

           The veil runs the whole screen, panel included, not just the space
           above it. The panel's corners are cut, and what shows through a cut
           is whatever is underneath: with the veil stopping at the panel's top
           edge, the notches showed the bright page and the corners read as a
           rendering fault. This is the demo's z-order, veil under bar. */
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !open,
            child: GestureDetector(
              onTap: widget.onClose,
              /* The alpha is animated, not an opacity layer over it: a layer
                 the size of the screen is saved and blended on every frame of
                 the run, and that cost lands as a stutter exactly while the
                 panel is trying to move smoothly. */
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: open ? 1.0 : 0.0),
                duration: open ? const Duration(milliseconds: 460) : _closing,
                curve: CalviMotion.ease,
                builder: (context, t, _) => ColoredBox(
                  color: c.scrim.withValues(alpha: c.scrim.a * t),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ),

        GestureDetector(
          // The bar itself opens the room without asking for the keyboard.
          onTap: open ? null : () => widget.onOpen(false),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            /* Riding the keyboard rather than being pushed by it. The platform
               reports the inset frame by frame as its own animation runs, so the
               padding follows it directly: an AnimatedPadding on top of that was
               a second curve chasing the first, and the chase is what the finger
               read as the panel stuttering on its way up. */
            padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
            child: TweenAnimationBuilder<double>(
              /* The corners are the bar's own, raised or not: it is a surface
                 laid over the day, and a surface that squares off at the bottom
                 of the screen reads as the screen ending, not as a panel. What
                 raising changes is the shadow it throws and the hairline it no
                 longer needs. */
              tween: Tween(end: open ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 420),
              curve: CalviMotion.easeRise,
              builder: (context, lift, child) {
                const shape = BorderRadius.vertical(top: Radius.circular(CalviSize.rLarge));
                return DecoratedBox(
                  // Under the clip, so the shadow keeps the shape it is cast by.
                  decoration: BoxDecoration(
                    borderRadius: shape,
                    /* Тінь угору замість риски: панель це окремий шар над
                       тонованим ґрунтом дня, а не місце, де закінчується
                       екран. Опущена вона кидає тиху тінь, піднята глибшу. */
                    boxShadow: [
                      BoxShadow(
                        color: c.shade.withValues(alpha: c.shade.a * (0.55 + 0.45 * lift)),
                        blurRadius: 34 + 6 * lift,
                        offset: Offset(0, -10 - 8 * lift),
                      ),
                    ],
                  ),
                  /* The hairline is painted over the panel rather than set as its
                     top border. A border is a straight run across the box, so the
                     clip cut it off exactly where the corners begin and the curve
                     was left bare: a line that stops short of the corner reads as
                     a rendering fault, which is what it was. Raised, the shadow
                     says the same thing better, so the line fades out. */
                  child: CustomPaint(
                    foregroundPainter: _TopEdge(
                      color: c.cardBorder.withValues(alpha: c.cardBorder.a * (1 - lift)),
                    ),
                    child: ClipRRect(
                      borderRadius: shape,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: c.card),
                        child: child,
                      ),
                    ),
                  ),
                );
              },
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 12, CalviSize.gutter, 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // The room grows from nothing rather than sliding in over the
                      // day: the bar is one object that gets taller.
                      ClipRect(
                        // Named so a test can measure the room rather than guess at it.
                        key: const Key('chat-room'),
                        child: AnimatedAlign(
                          duration: open ? _opening : _closing,
                          curve: open ? CalviMotion.easeRise : CalviMotion.easeOut,
                          alignment: Alignment.bottomCenter,
                          heightFactor: open ? 1 : 0,
                          child: RepaintBoundary(
                            child: TweenAnimationBuilder<double>(
                              /* One value drives both the lift and the fade, and it
                               starts a beat late on the way up so the room opens
                               before it fills. Two separate animations of the
                               same thing drifted apart under load, and that
                               drift is what read as a stutter. */
                              tween: Tween(end: open ? 1.0 : 0.0),
                              duration: open ? _fillIn + _fillDelay : _fillOut,
                              curve: open
                                  ? Interval(
                                      _fillDelay.inMilliseconds /
                                          (_fillIn + _fillDelay).inMilliseconds,
                                      1,
                                      curve: CalviMotion.easeRise,
                                    )
                                  : CalviMotion.easeOut,
                              builder: (context, t, child) => Opacity(
                                opacity: t,
                                child: Transform.translate(
                                  offset: Offset(0, _fillLift * (1 - t)),
                                  child: child,
                                ),
                              ),
                              child: _Room(
                                controller: _room,
                                messages: widget.messages,
                                onWeigh: widget.onWeigh,
                              ),
                            ),
                          ),
                        ),
                      ),
                      _SlotChip(slot: widget.slot),
                      _Input(
                        field: _field,
                        focus: _focus,
                        onFocused: () {
                          if (!open) widget.onOpen(true);
                        },
                        onCamera: widget.onCamera,
                        onHold: widget.onHold,
                        onLetGo: widget.onLetGo,
                        onSend: _send,
                        muteMic: widget.muteMic,
                      ),
                    ],
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

/// Where the messages live once the bar is raised.
class _Room extends StatelessWidget {
  const _Room({required this.controller, required this.messages, this.onWeigh});

  final ScrollController controller;
  final List<Msg> messages;
  final void Function(String id, int grams)? onWeigh;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ConstrainedBox(
      /* Tall enough to hold a conversation and never shorter than a greeting, so
         the room does not open onto a sliver the first time it is asked. */
      constraints: const BoxConstraints(minHeight: 148, maxHeight: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 2, 2, 14),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 4,
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    color: c.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(L.of(context).noraName, style: context.t.titleMedium),
                const Spacer(),
                /* The count is a fact, not a warning: it sits quiet in a pill
                   until the number starts to matter. */
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.fillSecondary,
                    borderRadius: BorderRadius.circular(CalviSize.rPill),
                  ),
                  child: Text(
                    '$tokensUsed/$tokensCap',
                    style: context.t.labelSmall?.copyWith(fontSize: CalviSize.fsMicro),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.only(bottom: 14),
              shrinkWrap: true,
              children: messages.isEmpty
                  // What Nora says before anything has been said to her.
                  ? [CalviNora(text: L.of(context).barHint, hint: L.of(context).barHintMore)]
                  : [for (final m in messages) _Bubble(msg: m, onWeigh: onWeigh)],
            ),
          ),
        ],
      ),
    );
  }
}

/// One message, arriving from a little below.
class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg, this.onWeigh});

  final Msg msg;
  final void Function(String id, int grams)? onWeigh;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final mine = msg.from == MsgFrom.me;

    return TweenAnimationBuilder<double>(
      key: ValueKey(msg.id),
      tween: Tween(end: 1),
      duration: const Duration(milliseconds: 420),
      curve: CalviMotion.easeRise,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 10 * (1 - t)), child: child),
      ),
      child: Row(
        /* Ours sits right and dark, hers left and quiet: the side says who spoke
           before the text is read. */
        mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.82 - CalviSize.gutter * 2,
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: mine ? c.button : c.fillSecondary,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(CalviSize.rCard),
                    topRight: const Radius.circular(CalviSize.rCard),
                    bottomLeft: Radius.circular(mine ? CalviSize.rCard : 6),
                    bottomRight: Radius.circular(mine ? 6 : CalviSize.rCard),
                  ),
                ),
                /* Бульбашка доростає до свого нового вмісту, а не стрибає в
                   нього. Кільце очікування і відповідь Нори це одна й та сама
                   бульбашка у двох станах, і без цього рівня висота мінялась би
                   за один кадр. Око читає такий стрибок як перемальовку, а не як
                   появу відповіді. */
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 320),
                  curve: CalviMotion.easeRise,
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Кільце стоїть рівно там, де зʼявиться відповідь.
                      if (msg.pending) const Thinking(),

                      /* The shot itself, not a paperclip: what was sent is the
                       picture, and a filename would say nothing. */
                      if (msg.kind == MsgKind.photo)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            width: 132,
                            height: 96,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [Color(0xFF6B503A), Color(0xFF2A1D15)],
                              ),
                            ),
                          ),
                        ),
                      if (msg.kind == MsgKind.barcode)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              // Reads on either bubble: its own ink, kept quiet.
                              color: (mine ? c.buttonText : c.text).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(CalviSize.rPill),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CalviIcon('barcode', size: 15, color: mine ? c.buttonText : c.text),
                                const SizedBox(width: 7),
                                Text(
                                  msg.code ?? '',
                                  style: context.t.labelSmall?.copyWith(
                                    fontSize: CalviSize.fsMicro,
                                    color: mine ? c.buttonText : c.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (msg.text.isNotEmpty)
                        Text(
                          msg.text,
                          style: context.t.bodyMedium?.copyWith(
                            height: 1.45,
                            color: mine ? c.buttonText : c.text,
                          ),
                        ),

                      // Числа не в тексті, а смужкою під ним: помічник говорить,
                      // дані показуються, і одне з одним не плутається.
                      if (msg.plate != null) ...[
                        const SizedBox(height: 10),
                        PlateStrip(plate: msg.plate!),
                      ],

                      /* Питання про вагу має відповідь в один дотик.
                       *
                       * Посередині найімовірніша порція, з боків крок униз і
                       * вгору. Набирати «400 г» руками тут не було за чим, а тап
                       * ще й не коштує токена: страву вже розібрано, і лишилось
                       * помножити її числа на вагу. */
                      if (msg.weights.isNotEmpty && msg.weighed == null) ...[
                        const SizedBox(height: 10),
                        _WeightPicks(weights: msg.weights, onPick: (g) => onWeigh?.call(msg.id, g)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Where the next entry lands, as a chip that hugs its own words.
///
/// It says so before anything is typed, so nobody has to guess which card a
/// sentence will end up in.
class _SlotChip extends StatelessWidget {
  const _SlotChip({required this.slot});

  final String slot;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: c.fillSecondary,
          borderRadius: BorderRadius.circular(CalviSize.rPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CalviIcon('utensils', size: 13, color: c.textSecondary),
            const SizedBox(width: 7),
            /* Гнучкий, бо назви карток різної довжини, а екрани різної ширини.
               «Пізня вечеря» на найменшому телефоні не влазила рівно на шість
               пікселів, і замість напису людина бачила жовто-чорну стрічку
               переповнення. Саме вночі, коли ця назва й зʼявляється.

               Перенос, а не трикрапка: рядок каже, у яку картку піде запис, і
               обрізати його з кінця означає обрізати саме те, заради чого він
               написаний. Хай краще пігулка стане на рядок вища. */
            Flexible(
              child: Text.rich(
                TextSpan(
                  text: L.of(context).barLogsInto,
                  children: [
                    TextSpan(
                      text: slot,
                      style: TextStyle(color: c.text, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                style: context.t.labelSmall?.copyWith(fontSize: CalviSize.fsMicro),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The field and its two buttons, in one pill.
///
/// One shape, not three: the camera and the microphone are ways of saying the
/// same thing as typing, and standing them outside the field would make them
/// read as separate features.
class _Input extends StatelessWidget {
  const _Input({
    required this.field,
    required this.focus,
    required this.onFocused,
    required this.onCamera,
    required this.onHold,
    required this.onLetGo,
    required this.onSend,
    required this.muteMic,
  });

  final TextEditingController field;
  final FocusNode focus;
  final VoidCallback onFocused;
  final VoidCallback onCamera;

  /// Палець ліг на мікрофон: запис починається цієї ж миті.
  final void Function(Offset at, double size) onHold;

  /// Палець прибрали: запис спиняється, і сказане йде на розбір.
  final VoidCallback onLetGo;
  final VoidCallback onSend;
  final bool muteMic;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 8, 8, 8),
      decoration: BoxDecoration(
        color: c.fillSecondary,
        borderRadius: BorderRadius.circular(CalviSize.rPill),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              textAlignVertical: TextAlignVertical.center,
              controller: field,
              focusNode: focus,
              onTap: onFocused,
              onSubmitted: (_) => onSend(),
              textInputAction: TextInputAction.send,
              style: context.t.bodyLarge?.copyWith(fontSize: CalviSize.fsBody),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: L.of(context).noraName,
                hintStyle: context.t.bodyLarge?.copyWith(
                  fontSize: CalviSize.fsBody,
                  color: c.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _Round(icon: 'camera', label: L.of(context).barCamera, onTap: onCamera),
          const SizedBox(width: 8),
          /* Один круг на дві дії, а не дві кнопки поруч.
           *
           * Поки поле порожнє, сказати можна тільки голосом, і круг це мікрофон.
           * З першою ж літерою наміром стає «надіслати», і мікрофон поступається
           * місцем: тримати обидві кнопки означало б питати людину, якою з них
           * вона хоче зробити те саме. */
          AnimatedScale(
            scale: muteMic ? 0 : 1,
            duration: CalviMotion.fast,
            curve: CalviMotion.ease,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: field,
              builder: (context, value, _) {
                final typed = value.text.trim().isNotEmpty;
                return _MicSend(send: typed, onSend: onSend, onHold: onHold, onLetGo: onLetGo);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Round extends StatefulWidget {
  const _Round({required this.icon, required this.label, required this.onTap});

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_Round> createState() => _RoundState();
}

class _RoundState extends State<_Round> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _down ? 0.92 : 1,
          duration: CalviMotion.fast,
          curve: CalviMotion.ease,
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c.button),
            child: CalviIcon(widget.icon, size: 19, color: c.buttonText),
          ),
        ),
      ),
    );
  }
}

/// Мікрофон і літак: одна кнопка у двох станах.
///
/// Поки поле порожнє, сказати можна тільки голосом. З першою ж літерою наміром
/// стає «надіслати», і круг стає ним: дві кнопки поруч питали б людину, якою з
/// них вона хоче зробити те саме.
///
/// **Свій годинник, а не `AnimatedSwitcher`.** Той викликає будівника переходу
/// рівно один раз, коли зʼявляється новий знак, і зберігає готовий віджет.
/// `FadeTransition` усередині виживає, бо слухає анімацію сам, а от
/// `Transform.rotate(angle: ...)` отримує число один раз і застигає з ним
/// назавжди. Тому знак не обертався взагалі: він народжувався під кутом і під
/// ним же лишався. Мікрофон стояв боком із першого кадру застосунку, а те, що
/// виглядало як смикана анімація, було випадковим перерахунком на тих кадрах,
/// коли поле перебудовувало кнопку з іншої причини.
class _MicSend extends StatefulWidget {
  const _MicSend({
    required this.send,
    required this.onSend,
    required this.onHold,
    required this.onLetGo,
  });

  /// True, коли в полі щось написано: тоді круг означає «надіслати».
  final bool send;
  final VoidCallback onSend;

  /* Мікрофон утримують, а не тицяють.
   *
   * Запис іде рівно стільки, скільки палець на кнопці. Початок віддає її місце
   * і розмір: рідина має вилетіти саме звідти і туди ж повернутись, а кнопка
   * стоїть у різних місцях, залежно від того, відкрита панель чи ні. */
  final void Function(Offset at, double size) onHold;
  final VoidCallback onLetGo;

  @override
  State<_MicSend> createState() => _MicSendState();
}

class _MicSendState extends State<_MicSend> with SingleTickerProviderStateMixin {
  /* Прихід нового знака, від нуля до одиниці.
   *
   * Рухається тільки той, що приходить: старий зникає тієї ж миті, коли настає
   * його черга піти. Так це зроблено в демці, і так воно ніколи не лишає на
   * екрані знак під кутом: кінець руху це завжди нуль градусів, хай навіть
   * людина передумала посеред нього. */
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: CalviMotion.normal,
    value: 1,
  );

  bool _down = false;

  /// Щоб дізнатись, де стоїть кнопка тієї миті, коли на неї натиснули.
  final _spot = GlobalKey();

  void _hold() {
    setState(() => _down = true);
    if (widget.send) return;

    final box = _spot.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    widget.onHold(box.localToGlobal(box.size.center(Offset.zero)), box.size.width);
  }

  void _letGo() {
    setState(() => _down = false);
    if (!widget.send) widget.onLetGo();
  }

  @override
  void didUpdateWidget(_MicSend old) {
    super.didUpdateWidget(old);
    if (widget.send != old.send) _in.forward(from: 0);
  }

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Semantics(
      button: true,
      label: widget.send ? L.of(context).barSend : L.of(context).barMic,
      /* Запис тримається, поки палець на екрані, а не поки він на кнопці.
       *
       * Тут стояв `GestureDetector`, і його `onTapCancel` спрацьовував, щойно
       * палець зсувався далі за кілька пікселів: рука ледь поїхала, і запис
       * обірвався посеред фрази. `Listener` дає сирі події вказівника, а їх
       * система віддає тому, хто прийняв натискання, куди б палець потім не
       * поїхав. Так само це зроблено в месенджерах, і саме тому там зручно.
       *
       * Дотик лишається дотиком тільки для «надіслати»: там подія одна і
       * приходить уже після всього. */
      child: Listener(
        onPointerDown: widget.send ? null : (_) => _hold(),
        onPointerUp: widget.send ? null : (_) => _letGo(),
        onPointerCancel: widget.send ? null : (_) => _letGo(),
        child: GestureDetector(
          onTap: widget.send ? widget.onSend : null,
          behavior: HitTestBehavior.opaque,
          child: AnimatedScale(
            scale: _down ? 0.92 : 1,
            duration: CalviMotion.fast,
            curve: CalviMotion.ease,
            child: Container(
              key: _spot,
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.button),
              child: AnimatedBuilder(
                animation: _in,
                /* Числа тут не з голови, а зняті з демки: `swap-in`, 240 мс,
                 `--ease-rise`, від `rotate(-180deg) scale(0.55)` і прозорості
                 нуль до звичайного стану. Знак на кнопці завжди рівно один, бо
                 другого просто немає в дереві. */
                builder: (context, child) {
                  final t = CalviMotion.easeRise.transform(_in.value);
                  return Opacity(
                    opacity: t.clamp(0, 1),
                    child: Transform.rotate(
                      angle: -math.pi * (1 - t),
                      child: Transform.scale(scale: 0.55 + 0.45 * t, child: child),
                    ),
                  );
                },
                child: CalviIcon(widget.send ? 'send' : 'mic', size: 19, color: c.buttonText),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The line along the top of the bar, corners included.
///
/// Drawn as a path rather than as a border so it follows the curve instead of
/// stopping where the curve starts.
class _TopEdge extends CustomPainter {
  const _TopEdge({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (color.a == 0) return;
    const r = CalviSize.rLarge;
    // Half a pixel in, so the stroke lands inside the panel rather than astride
    // its edge, where the top half of it would be drawn over the day.
    const o = 0.5;
    final path = Path()
      ..moveTo(o, r)
      ..arcToPoint(const Offset(r, o), radius: const Radius.circular(r - o))
      ..lineTo(size.width - r, o)
      ..arcToPoint(Offset(size.width - o, r), radius: const Radius.circular(r - o));

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_TopEdge old) => old.color != color;
}

/* Три ваги на вибір під питанням Нори.
 *
 * Посередині найімовірніша порція, і саме вона зафарбована: око йде до неї
 * першою, а решта лишається поруч на випадок, коли порція вийшла більшою або
 * меншою за звичну. Ширина в усіх однакова, а не за числом: «100 г» поруч із
 * «1000 г» інакше стрибало б, і ряд читався б як випадковий. */
class _WeightPicks extends StatelessWidget {
  const _WeightPicks({required this.weights, required this.onPick});

  final List<int> weights;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Row(
      children: [
        for (final (i, g) in weights.indexed) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Material(
              color: i == 1 ? c.button : c.card,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onPick(g),
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: i == 1 ? null : Border.all(color: c.cardBorder),
                  ),
                  child: Text(
                    L.of(context).barGrams(g),
                    style: context.t.labelLarge?.copyWith(
                      color: i == 1 ? c.buttonText : c.text,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
