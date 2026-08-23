import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/meds_store.dart';
import 'package:calvi/data/meds.dart';
import 'package:calvi/data/repeat.dart';

/// Препарати живуть на диску, а не в памʼяті екрана.
///
/// Таблиця в базі була, відображення на дріт було, місце в черзі на сервер було.
/// Не було одного: коду між екраном і сховищем. Тому препарати зникали з
/// перезапуском і на сервер не потрапляли ніколи.
void main() {
  late CalviDb db;
  late MedsStore store;

  setUp(() {
    db = CalviDb(NativeDatabase.memory());
    store = MedsStore(db);
  });
  tearDown(() => db.close());

  Med magnesium({Repeat repeat = const DailyRepeat()}) => Med(
    id: 'm1',
    name: 'Магній B6',
    dose: 2,
    form: MedForm.tab,
    remind: true,
    repeat: repeat,
    times: const [
      MedTime(at: '08:00', taken: false),
      MedTime(at: '21:00', taken: false),
    ],
  );

  test('препарат переживає перезапуск', () async {
    await store.save(magnesium());

    final back = await store.load();
    expect(back, hasLength(1));
    expect(back.single.name, 'Магній B6');
    expect(back.single.dose, 2);
    expect(back.single.form, MedForm.tab);
    expect(back.single.times.map((t) => t.at), ['08:00', '21:00']);
  });

  test('розклад теж зберігається', () async {
    await store.save(magnesium(repeat: const WeekdayRepeat(days: [1, 4])));

    final back = await store.load();
    final r = back.single.repeat;
    expect(r, isA<WeekdayRepeat>());
    expect((r as WeekdayRepeat).days, [1, 4]);
  });

  test('через день читається назад тим самим', () async {
    await store.save(magnesium(repeat: const IntervalRepeat(every: 2, from: '2026-08-18')));

    final r = (await store.load()).single.repeat;
    expect(r, isA<IntervalRepeat>());
    expect((r as IntervalRepeat).every, 2);
  });

  test('препарат стає в чергу на сервер', () async {
    await store.save(magnesium());
    expect(await db.syncDao.pendingMeds(), hasLength(1));
  });

  test('помилково заведений препарат стирається разом з історією', () async {
    /* Мʼяке видалення лишилось, але тепер воно для того, чого не було взагалі.
       Закінчений курс прибирається інакше, через `stop`: див. meds_course_test. */
    await store.save(magnesium());
    await store.erase('m1');

    expect(await store.load(), isEmpty);

    final row = await db.select(db.medications).getSingle();
    expect(row.deletedAt, isNotNull);
    expect(row.dirty, true, reason: 'синхронізація не дізнається про видалення');
  });

  test('позначений прийом читається назад', () async {
    await store.save(magnesium());
    await store.setTaken(medId: 'm1', at: '08:00', taken: true);

    final back = await store.load();
    expect(back.single.times.firstWhere((t) => t.at == '08:00').taken, true);
    expect(back.single.times.firstWhere((t) => t.at == '21:00').taken, false);
  });

  test('знята галочка теж читається назад', () async {
    await store.save(magnesium());
    await store.setTaken(medId: 'm1', at: '08:00', taken: true);
    await store.setTaken(medId: 'm1', at: '08:00', taken: false);

    final back = await store.load();
    expect(back.single.times.every((t) => !t.taken), true);
  });

  test('зміна препарату не скидає сьогоднішніх галочок', () async {
    /* Виправлена опівдні назва не має скасовувати таблетку, випиту о восьмій. */
    await store.save(magnesium());
    await store.setTaken(medId: 'm1', at: '08:00', taken: true);

    await store.save(
      Med(
        id: 'm1',
        name: 'Магній B6 форте',
        dose: 2,
        form: MedForm.tab,
        remind: true,
        times: const [
          MedTime(at: '08:00', taken: true),
          MedTime(at: '21:00', taken: false),
        ],
      ),
    );

    final back = await store.load();
    expect(back.single.name, 'Магній B6 форте');
    expect(back.single.times.firstWhere((t) => t.at == '08:00').taken, true);
  });

  test('порожня база це порожній список, а не помилка', () async {
    expect(await store.load(), isEmpty);
  });
}
