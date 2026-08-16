/// What the chat with Nora carries.
///
/// A message is never invented on the client. Text is what the person typed or
/// dictated, a photo message says a photo was sent and nothing about what is in
/// it, and a barcode carries the code. The numbers only ever come back in Nora's
/// reply, because they come from the model or from the product base, and putting
/// a guess in the outgoing message would be the app answering itself.
library;

enum MsgKind { text, voice, photo, barcode }

enum MsgFrom { me, nora }

class Msg {
  const Msg({
    required this.id,
    required this.from,
    required this.kind,
    required this.text,
    this.code,
  });

  final String id;
  final MsgFrom from;
  final MsgKind kind;

  /// What is read out in the bubble.
  final String text;

  /// The code, for a barcode. Unused otherwise.
  final String? code;
}

var _seq = 0;

Msg msg({
  required MsgFrom from,
  MsgKind kind = MsgKind.text,
  required String text,
  String? code,
}) => Msg(id: 'm${++_seq}', from: from, kind: kind, text: text, code: code);

/* Fixed answers for the demo. The same figures the camera sheet showed, because
   two different numbers for one shot would be the demo contradicting itself. */
const noraPhoto =
    'Млинці з чорницею і медом, приблизно 430 ккал. Записав у Обід, скажи вагу, якщо хочеш точніше.';
const noraBarcode =
    'Йогурт грецький 5%, 231 ккал на 130 г. Склад із бази, алергенів зі списку немає. Записав у Обід.';
const noraVoice = 'Записав: два яйця, тост і кава без цукру. Разом 384 ккал у Обід.';

/// Tokens left today, the same figure the chat header carries in the spec.
const tokensUsed = 19;
const tokensCap = 30;
