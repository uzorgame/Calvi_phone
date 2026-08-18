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

/// Числа страви, які Нора розібрала.
///
/// Живуть окремим полем, а не всередині тексту, і це не дрібниця. Число, вплетене
/// в речення, читається як частина розмови, і його доводиться вишукувати очима
/// серед слів. Те саме число смужкою під повідомленням видно з одного погляду, і
/// одразу зрозуміло, де закінчується мова помічника і починаються дані.
class MealPlate {
  const MealPlate({
    required this.name,
    required this.kcal,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.grams,
  });

  final String name;
  final double? grams;
  final int kcal;
  final int protein;
  final int fat;
  final int carbs;
}

class Msg {
  const Msg({
    required this.id,
    required this.from,
    required this.kind,
    required this.text,
    this.code,
    this.plate,
    this.pending = false,
  });

  final String id;
  final MsgFrom from;
  final MsgKind kind;

  /// What is read out in the bubble.
  final String text;

  /// The code, for a barcode. Unused otherwise.
  final String? code;

  /// Розібрана страва: малюється смужкою під текстом.
  final MealPlate? plate;

  /* Нора ще думає над цим повідомленням.
   *
   * Саме повідомлення, а не значок збоку. Різниця не косметична: очікування
   * стоїть рівно там, де зʼявиться відповідь, і коли вона приходить, бульбашка
   * не виникає з нічого, а доростає з кільця. Значок в іншому місці означав би
   * стрибок, а стрибок читається як збій. */
  final bool pending;

  Msg answered({required String text, MealPlate? plate}) => Msg(
    id: id,
    from: from,
    kind: kind,
    text: text,
    code: code,
    plate: plate ?? this.plate,
  );
}

var _seq = 0;

Msg msg({
  required MsgFrom from,
  MsgKind kind = MsgKind.text,
  required String text,
  MealPlate? plate,
  bool pending = false,
  String? code,
}) => Msg(
  id: 'm${++_seq}',
  from: from,
  kind: kind,
  text: text,
  code: code,
  plate: plate,
  pending: pending,
);

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
