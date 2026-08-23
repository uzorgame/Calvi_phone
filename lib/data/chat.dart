/// What the chat with Nora carries.
///
/// A message is never invented on the client. Text is what the person typed or
/// dictated, a photo message says a photo was sent and nothing about what is in
/// it, and a barcode carries the code. The numbers only ever come back in Nora's
/// reply, because they come from the model or from the product base, and putting
/// a guess in the outgoing message would be the app answering itself.
library;

import 'fixtures.dart';

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
    this.weights = const [],
    this.weighed,
    this.askId,
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

  /* Три ваги на вибір, коли Нора спитала про порцію.
   *
   * Відповідь на це питання це майже завжди одне число з трьох очевидних, і
   * набирати його руками не було за чим. Посередині найімовірніша вага, з боків
   * крок униз і вгору. Тап не коштує токена: страву вже розібрано, і лишилось
   * помножити її числа на вагу. */
  final List<int> weights;

  /// Яку вагу обрали. Кнопки після цього зникають.
  final int? weighed;

  /* Яке питання черги стоїть за цими вагами.
   *
   * Одне повідомлення лишає стільки питань, скільки в ньому страв без ваги, і
   * відповідь має закрити рівно своє. Без цього номера друга відповідь лягла б
   * на першу страву, а порядок відповідей людина обирає сама.
   *
   * Порожньо в усіх повідомленнях, крім самих питань. */
  final String? askId;

  Msg picked(int grams) => Msg(
    id: id,
    from: from,
    kind: kind,
    text: text,
    code: code,
    plate: plate,
    weights: weights,
    weighed: grams,
    askId: askId,
  );

  Msg answered({required String text, MealPlate? plate}) => Msg(
    id: id,
    from: from,
    kind: kind,
    text: text,
    code: code,
    plate: plate ?? this.plate,
    weights: weights,
    weighed: weighed,
    askId: askId,
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
  List<int> weights = const [],
  String? askId,
}) => Msg(
  id: 'm${++_seq}',
  from: from,
  kind: kind,
  text: text,
  code: code,
  plate: plate,
  pending: pending,
  weights: weights,
  askId: askId,
);

/* Fixed answers for the demo. The same figures the camera sheet showed, because
   two different numbers for one shot would be the demo contradicting itself. */
String get noraPhoto => demoDish(
  'Млинці з чорницею і медом, приблизно 430 ккал. Записала в обід, скажи вагу, якщо хочеш точніше.',
  'Pancakes with blueberries and honey, about 430 kcal. Logged into lunch, tell me the weight if you want it exact.',
);
String get noraBarcode => demoDish(
  'Записала в обід: Йогурт грецький 5%, 231 ккал за 130 г.\nСклад: молоко знежирене, закваска, білок молочний.',
  'Logged into lunch: Greek yoghurt 5%, 231 kcal per 130 g.\nIngredients: skimmed milk, cultures, milk protein.',
);
String get noraCodeTalk => demoDish(
  'Цього коду немає в базах, тож нічого не записую. Розкажи, що це за продукт, або сфотографуй етикетку зі складом, і я порахую.',
  'No base knows this code, so nothing is logged. Tell me what the product is, or photograph the label with its composition, and I will count it.',
);
String get noraVoice => demoDish(
  'Записала: два яйця, тост і кава без цукру. Разом 384 ккал в обід.',
  'Logged: two eggs, toast and coffee without sugar. 384 kcal into lunch.',
);

/// Tokens left today, the same figure the chat header carries in the spec.
const tokensUsed = 19;
const tokensCap = 30;
