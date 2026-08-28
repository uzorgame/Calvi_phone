import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/day_reader.dart';
import 'package:calvi/data/remote/api.dart';

/// Закриті питання про вагу доходять до телефона і прибирають чернетки.
///
/// Вага, названа в чат словами замість кнопок, записує страву новим рядком, а
/// питання в черзі закриває сервер. Якщо телефон не прочитає номери закритих,
/// чернетка «Нора рахує…» у картці чекатиме на відповідь, яка вже прозвучала.
void main() {
  NoraReply parse(Map<String, dynamic> body) =>
      NoraReply.fromWire(body, slot: 'lunch', day: '2026-08-28');

  test('номери закритих питань приходять списком', () {
    final reply = parse({
      'text': 'Записала.',
      'balance': 9,
      'logged': <dynamic>[],
      'closed_asks': ['ask-1', 'ask-2'],
    });

    expect(reply.closedAsks, ['ask-1', 'ask-2']);
  });

  test('відповідь без поля і покалічене поле не ламають розбір', () {
    /* Старий сервер поля не шле, а новий може прислати що завгодно: краще
       незакрите питання, ніж бульбашка, якої немає взагалі, бо розбір упав. */
    for (final broken in <Object?>[
      null,
      'ask-1',
      42,
      <Object?>[null, 42, ''],
    ]) {
      final reply = parse({
        'text': 'Щось.',
        'balance': 1,
        'logged': <dynamic>[],
        if (broken != null) 'closed_asks': broken,
      });
      expect(reply.closedAsks, isEmpty, reason: 'на «$broken» розбір дав не порожнє');
      expect(reply.text, 'Щось.');
    }
  });

  /* Той самий ланцюжок, яким живе екран: чернетка привʼязана до питання в
     базі, номер приїхав у closed_asks, і рядок прибирається. Памʼять екрана
     тут ні до чого навмисно: саме так це працює і після перезапуску. */
  test('закладка в базі веде від закритого питання до чернетки', () async {
    final db = CalviDb(NativeDatabase.memory());
    addTearDown(db.close);

    final id = await DayReader(db).addTyped(slotId: 'lunch', text: 'три бутерброди із шинкою');
    await db.diaryDao.bindAsk(id, 'ask-7');

    final reply = parse({
      'text': 'Бутерброди: 660 ккал за 300 г. Записала в обід.',
      'balance': 8,
      'logged': <dynamic>[
        {'id': 'srv-1', 'name': 'бутерброд із шинкою', 'kcal': 660},
      ],
      'closed_asks': ['ask-7'],
    });

    // Рівно те, що робить екран: за кожним закритим питанням іде його чернетка.
    for (final closed in reply.closedAsks) {
      final row = await db.diaryDao.draftForAsk(closed);
      if (row != null) await db.diaryDao.removeMeal(row);
    }

    final day = await DayReader(db).read(DateTime.now());
    expect(
      day.meals.where((m) => m.id == id),
      isEmpty,
      reason: 'чернетка пережила відповідь на своє питання',
    );
  });
}
