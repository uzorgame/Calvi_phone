import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/meds_store.dart';
import 'package:calvi/data/meds.dart';
import 'package:calvi/data/repeat.dart';

/// Препарат живе в часі: у нього є початок, кінець і розклад.
///
/// Усе це раніше або губилось, або не діяло. Розклад стирався першим же
/// `copyWith`, діяв тільки на сповіщення, примітку затирала форма випуску, а
/// видалення переписувало історію заднім числом.
void main() {
  late CalviDb db;
  late MedsStore store;

  setUp(() {
    db = CalviDb(NativeDatabase.memory());
    store = MedsStore(db);
  });
  tearDown(() => db.close());

  String key(DateTime d) => dayKeyOf(d);
  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));
  final tomorrow = today.add(const Duration(days: 1));

  Med magnesium({Repeat repeat = const DailyRepeat(), String? start, String? end, String? note}) =>
      Med(
        id: 'm1',
        name: 'Магній B6',
        dose: 2,
        form: MedForm.tab,
        remind: true,
        repeat: repeat,
        startDay: start ?? key(today),
        endDay: end,
        note: note,
        times: const [MedTime(at: '08:00', taken: false)],
      );

  group('розклад більше не зникає', () {
    test('copyWith переносить розклад', () {
      final m = magnesium(repeat: const WeekdayRepeat(days: [1, 4]));
      final after = m.copyWith(remind: false);

      expect(after.repeat, isA<WeekdayRepeat>());
      expect((after.repeat as WeekdayRepeat).days, [1, 4]);
    });

    test('copyWith переносить межі курсу', () {
      final m = magnesium(start: '2026-08-01', end: '2026-08-30');
      final after = m.copyWith(remind: false);

      expect(after.startDay, '2026-08-01');
      expect(after.endDay, '2026-08-30');
    });

    test('галочка прийому не збиває розкладу', () {
      /* Саме цей шлях і стирав його щодня: людина відмічала випиту таблетку і
         разом із цим втрачала «по понеділках і четвергах». */
      final m = magnesium(repeat: const IntervalRepeat(every: 2, from: '2026-08-01'));
      final after = m.copyWith(times: [for (final t in m.times) t.copyWith(taken: true)]);

      expect(after.repeat, isA<IntervalRepeat>());
      expect(after.times.single.taken, true);
    });
  });

  group('розклад діє на день, а не тільки на сповіщення', () {
    test('через день: сьогодні так, завтра ні', () {
      final m = magnesium(repeat: IntervalRepeat(every: 2, from: key(today)));

      expect(m.activeOn(today), true);
      expect(m.activeOn(tomorrow), false);
      expect(medsOn([m], tomorrow), isEmpty);
      expect(medProgress(medsOn([m], tomorrow)).total, 0);
    });

    test('дні тижня рахуються тільки у свої дні', () {
      final m = magnesium(repeat: WeekdayRepeat(days: [today.weekday]));

      expect(m.activeOn(today), true);
      expect(m.activeOn(today.add(const Duration(days: 1))), false);
    });
  });

  group('курс має початок і кінець', () {
    test('заведений сьогодні не зʼявляється у вчорашньому дні', () {
      final m = magnesium();
      expect(m.activeOn(yesterday), false, reason: 'переписали минуле');
      expect(m.activeOn(today), true);
    });

    test('закінчений курс лишається в днях, коли його приймали', () {
      final m = magnesium(start: key(yesterday), end: key(yesterday));

      expect(m.activeOn(yesterday), true, reason: 'стерли історію');
      expect(m.activeOn(today), false);
    });

    test('припинення ставить останній день, а не ховає рядок', () async {
      await store.save(magnesium(start: key(yesterday)));
      await store.stop('m1', at: yesterday);

      final back = await store.load(on: yesterday);
      expect(back, hasLength(1), reason: 'препарат зник разом з історією');
      expect(back.single.endDay, key(yesterday));
      expect(back.single.activeOn(yesterday), true);
      expect(back.single.activeOn(today), false);
    });
  });

  group('примітка і форма живуть окремо', () {
    test('примітка переживає збереження', () async {
      await store.save(magnesium(note: 'Разом зі сніданком'));

      final back = (await store.load()).single;
      expect(back.note, 'Разом зі сніданком');
      expect(back.form, MedForm.tab);
    });

    test('форма читається зі свого поля', () async {
      await store.save(
        Med(
          id: 'm2',
          name: 'Вітамін D3',
          dose: 1,
          form: MedForm.drop,
          remind: true,
          startDay: key(today),
          times: const [MedTime(at: '08:00', taken: false)],
        ),
      );

      final back = (await store.load()).where((m) => m.id == 'm2').single;
      expect(back.form, MedForm.drop);
      expect(back.note, isNull);
    });
  });

  group('галочка належить дню', () {
    test('прийнято сьогодні не означає прийнято вчора', () async {
      await store.save(magnesium(start: key(yesterday)));
      await store.setTaken(medId: 'm1', at: '08:00', taken: true);

      final now = (await store.load(on: today)).single;
      final then = (await store.load(on: yesterday)).single;

      expect(now.times.single.taken, true);
      expect(then.times.single.taken, false, reason: 'галочка розповзлась по днях');
    });

    test('вчорашню галочку можна закрити вчорашнім днем', () async {
      await store.save(magnesium(start: key(yesterday)));
      await store.setTaken(medId: 'm1', at: '08:00', taken: true, on: yesterday);

      expect((await store.load(on: yesterday)).single.times.single.taken, true);
      expect((await store.load(on: today)).single.times.single.taken, false);
    });
  });

  test('усе разом їде на сервер', () async {
    await store.save(
      magnesium(
        repeat: const WeekdayRepeat(days: [1, 4]),
        note: 'після їжі',
      ),
    );

    final pending = await db.syncDao.pendingMeds();
    expect(pending, hasLength(1));
    expect(pending.single.form, 'tab');
    expect(pending.single.note, 'після їжі');
    expect(pending.single.startDay, key(today));
    expect(pending.single.dirty, true);
  });
}
