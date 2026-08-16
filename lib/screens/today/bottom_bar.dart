import 'package:flutter/material.dart';

import '../../data/chat.dart';
import '../../design/icons.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';

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
    required this.onVoice,
    required this.onSend,
    required this.messages,
    this.muteMic = false,
  });

  /// Card the next entry lands in.
  final String slot;
  final bool open;

  /// True only when the field itself was touched.
  final ValueChanged<bool> onOpen;
  final VoidCallback onClose;
  final VoidCallback onCamera;
  final VoidCallback onVoice;

  /// What was typed into the bar, in the person's own words.
  final ValueChanged<String> onSend;
  final List<Msg> messages;

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

class _BottomBarState extends State<BottomBar> {
  final _field = TextEditingController();
  final _focus = FocusNode();
  final _room = ScrollController();

  @override
  void dispose() {
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_room.hasClients) return;
        _room.animateTo(
          _room.position.maxScrollExtent,
          duration: CalviMotion.normal,
          curve: CalviMotion.ease,
        );
      });
    }
  }

  /// How many messages the room has already scrolled for.
  int _seen = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final open = widget.open;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /* Everything behind the raised field dims rather than disappears: the
           day is still the context for what is being written. */
        Expanded(
          child: IgnorePointer(
            ignoring: !open,
            child: GestureDetector(
              onTap: widget.onClose,
              child: AnimatedOpacity(
                opacity: open ? 1 : 0,
                duration: open ? const Duration(milliseconds: 460) : _closing,
                curve: CalviMotion.ease,
                child: ColoredBox(color: c.scrim, child: const SizedBox.expand()),
              ),
            ),
          ),
        ),

        GestureDetector(
          // The bar itself opens the room without asking for the keyboard.
          onTap: open ? null : () => widget.onOpen(false),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            /* Raised, the bar stops being a strip at the bottom and becomes the
               surface: it takes corners and throws a shadow over the day. */
            duration: const Duration(milliseconds: 420),
            curve: CalviMotion.easeRise,
            decoration: BoxDecoration(
              color: c.bg,
              border: Border(
                top: BorderSide(color: open ? const Color(0x00000000) : c.cardBorder),
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(open ? CalviSize.rLarge : 0),
              ),
              boxShadow: open
                  ? [BoxShadow(color: c.shade, blurRadius: 40, offset: const Offset(0, -18))]
                  : null,
            ),
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
                        child: AnimatedSlide(
                          duration: open ? _fillIn : _fillOut,
                          curve: open ? CalviMotion.easeRise : CalviMotion.easeOut,
                          offset: open ? Offset.zero : const Offset(0, 0.06),
                          child: AnimatedOpacity(
                            duration: open ? _fillIn : _fillOut,
                            curve: CalviMotion.ease,
                            opacity: open ? 1 : 0,
                            child: _Room(controller: _room, messages: widget.messages),
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
                      onVoice: widget.onVoice,
                      onSend: _send,
                      muteMic: widget.muteMic,
                    ),
                  ],
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
  const _Room({required this.controller, required this.messages});

  final ScrollController controller;
  final List<Msg> messages;

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
                Text('Нора', style: context.t.titleMedium),
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
                  ? const [
                      CalviNora(
                        text: 'Пиши як кажеш.',
                        hint:
                            '«два яйця і тост», «випив 300 води», «біг 40 хвилин» — розберу і '
                            'запишу в потрібну картку',
                      ),
                    ]
                  : [for (final m in messages) _Bubble(msg: m)],
            ),
          ),
        ],
      ),
    );
  }
}

/// One message, arriving from a little below.
class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg});

  final Msg msg;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                              CalviIcon(
                                'barcode',
                                size: 15,
                                color: mine ? c.buttonText : c.text,
                              ),
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
                    Text(
                      msg.text,
                      style: context.t.bodyMedium?.copyWith(
                        height: 1.45,
                        color: mine ? c.buttonText : c.text,
                      ),
                    ),
                  ],
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
            Text.rich(
              TextSpan(
                text: 'Записую в ',
                children: [
                  TextSpan(
                    text: slot,
                    style: TextStyle(color: c.text, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              style: context.t.labelSmall?.copyWith(fontSize: CalviSize.fsMicro),
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
    required this.onVoice,
    required this.onSend,
    required this.muteMic,
  });

  final TextEditingController field;
  final FocusNode focus;
  final VoidCallback onFocused;
  final VoidCallback onCamera;
  final VoidCallback onVoice;
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
                hintText: 'Нора',
                hintStyle: context.t.bodyLarge?.copyWith(
                  fontSize: CalviSize.fsBody,
                  color: c.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _Round(icon: 'camera', label: 'Камера', onTap: onCamera),
          const SizedBox(width: 8),
          // The small microphone steps aside while the big one is listening.
          AnimatedScale(
            scale: muteMic ? 0 : 1,
            duration: CalviMotion.fast,
            curve: CalviMotion.ease,
            child: _Round(icon: 'mic', label: 'Мікрофон', onTap: onVoice),
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
