import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/remote/api.dart';

/// Відповідь про пачку доходить до телефона цілою.
///
/// Етикетка нічого не пише в щоденник, тому її числа не можуть приїхати в
/// `logged`, як приїжджають числа записаної страви. Вони йдуть окремим полем, і
/// якщо телефон його не прочитає, людина побачить розповідь без жодної цифри.
void main() {
  NoraReply parse(Map<String, dynamic> body) =>
      NoraReply.fromWire(body, slot: 'lunch', day: '2026-08-28');

  test('числа пачки приходять окремо від записаного', () {
    final reply = parse({
      'text': 'Плавлений сир скибками.',
      'balance': 17,
      'logged': <dynamic>[],
      'label': {
        'name': 'American Cheese Slices, Haolam',
        'kcal': 333,
        'protein_g': 19,
        'fat_g': 23.8,
        'carbs_g': 4.8,
      },
    });

    expect(reply.logged, isEmpty, reason: 'етикетка щось записала в щоденник');
    expect(reply.label, isNotNull, reason: 'числа пачки загубились по дорозі');
    expect(reply.label!.kcal, 333);
    expect(reply.label!.fat, 23.8);
    expect(reply.label!.name, 'American Cheese Slices, Haolam');
  });

  test('звичайна відповідь лишається без пачки', () {
    final reply = parse({'text': 'Записала.', 'balance': 17, 'logged': <dynamic>[]});
    expect(reply.label, isNull);
  });

  test('покалічене поле не ламає відповідь', () {
    /* Сервер може змінитись, а старий телефон лишиться. Половина числа тут
       гірша за жодного: краще розповідь без смужки, ніж бульбашка, якої немає
       взагалі, бо розбір упав. */
    for (final broken in <Object?>[
      null,
      'label',
      <String, dynamic>{},
      {'name': 'Сир'},
      {'kcal': 333},
      {'name': 42, 'kcal': 333},
    ]) {
      final reply = parse({'text': 'Щось.', 'balance': 1, 'logged': <dynamic>[], 'label': broken});
      expect(reply.label, isNull, reason: 'на «$broken» зібралась половина числа');
      expect(reply.text, 'Щось.');
    }
  });

  test('відсутні макроси не стають нулями мовчки', () {
    final reply = parse({
      'text': 'Пачка.',
      'balance': 1,
      'logged': <dynamic>[],
      'label': {'name': 'Щось', 'kcal': 200, 'protein_g': null},
    });

    expect(reply.label!.protein, isNull, reason: 'невідомий білок виданий за нуль');
    expect(reply.label!.kcal, 200);
  });
}
