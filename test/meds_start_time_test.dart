import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/meds_store.dart';
import 'package:calvi/data/meds.dart';
import 'package:calvi/data/repeat.dart';

/// Курс починається о годині, а не о дні.
///
/// Людина заводить о 14:00 ліки на 09:00 і 21:00. Ранкова доза сьогодні вже
/// позаду, і курс не має відкриватись пропущеним прийомом, якого ніхто не
/// пропускав. Вечірню вона ще питиме, тож день початку не викидається цілком, а
/// рахується від години заведення.
void main() {
  final today = DateTime.now();
  final tomorrow = today.add(const Duration(days: 1));

  Med course({required List<String> at, String start = '14:00', String? end}) => Med(
    id: 'm1',
    name: 'Магній B6',
    dose: 2,
    form: MedForm.tab,
    remind: true,
    repeat: const DailyRepeat(),
    startDay: dayKeyOf(today),
    startTime: start,
    endDay: end,
    times: [for (final t in at) MedTime(at: t, taken: false)],
  );

  List<String> hoursOn(Med m, DateTime day) => [
    for (final t in dosesOn(m, day, marked: (_) => false)) t.at,
  ];

  group('день початку', () {
    test('година, яка вже минула, сьогодні не рахується', () {
      final m = course(at: ['09:00']);
      expect(hoursOn(m, today), isEmpty, reason: 'курс почався з боргу');
      expect(hoursOn(m, tomorrow), ['09:00'], reason: 'курс не почався взагалі');
    });

    test('година, яка ще попереду, рахується сьогодні', () {
      final m = course(at: ['18:00']);
      expect(hoursOn(m, today), ['18:00'], reason: 'вечірню дозу відкладено на завтра');
    });

    test('із двох годин лишається та, що попереду', () {
      /* Саме тут ламається правило «весь день у минулому»: воно відклало б курс
         на завтра разом із вечірньою дозою, яку людина сьогодні ще питиме. */
      final m = course(at: ['09:00', '21:00']);
      expect(hoursOn(m, today), ['21:00']);
      expect(hoursOn(m, tomorrow), ['09:00', '21:00']);
    });

    test('рівно та сама година рахується', () {
      // Заведено о 14:00 ліки на 14:00: це не минуле, це зараз.
      expect(hoursOn(course(at: ['14:00']), today), ['14:00']);
    });

    test('позначена доза належить дню навіть до години початку', () {
      /* Перший пункт правила сильніший за другий: галочка це запис про те, що
         сталось, і жодна межа курсу його не скасовує. */
      final m = course(at: ['09:00']);
      final taken = dosesOn(m, today, marked: (at) => at == '09:00');
      expect(taken, hasLength(1));
      expect(taken.single.taken, isTrue);
    });

    test('порожня година лишає день початку цілим', () {
      /* Так приїжджають курси зі старих збірок. Порожня година означає «не
         записана», і поводитись вони мають рівно так, як поводились. */
      expect(hoursOn(course(at: ['09:00'], start: ''), today), ['09:00']);
    });

    test('наступні дні беруть усі години', () {
      expect(hoursOn(course(at: ['09:00', '21:00']), tomorrow), ['09:00', '21:00']);
    });
  });

  group('перший прийом', () {
    test('мовчить, поки сьогодні щось лишилось', () {
      expect(firstDoseAhead(course(at: ['09:00', '21:00']), today), isNull);
    });

    test('називає завтрашню годину, коли сьогодні вже нічого', () {
      final ahead = firstDoseAhead(course(at: ['09:00']), today);
      expect(ahead, isNotNull);
      expect(ahead!.at, '09:00');
      expect(dayKeyOf(ahead.day), dayKeyOf(tomorrow));
    });

    test('називає найранішу годину того дня, а не першу за списком', () {
      final m = course(at: ['21:00', '09:00']);
      // Сьогодні лишається 21:00, тож казати нема чого.
      expect(firstDoseAhead(m, today), isNull);

      final later = m.copyWith(startTime: '23:00');
      expect(firstDoseAhead(later, today)?.at, '09:00');
    });

    test('розклад через день переносить на післязавтра', () {
      final m = Med(
        id: 'm2',
        name: 'Вітамін D3',
        dose: 1,
        form: MedForm.drop,
        remind: false,
        repeat: IntervalRepeat(every: 2, from: dayKeyOf(today)),
        startDay: dayKeyOf(today),
        startTime: '14:00',
        times: const [MedTime(at: '09:00', taken: false)],
      );
      final ahead = firstDoseAhead(m, today);
      expect(
        dayKeyOf(ahead!.day),
        dayKeyOf(today.add(const Duration(days: 2))),
        reason: 'названо день, у який курс не приймається',
      );
    });
  });

  group('сховище', () {
    late CalviDb db;
    late MedsStore store;

    setUp(() {
      db = CalviDb(NativeDatabase.memory());
      store = MedsStore(db);
    });
    tearDown(() => db.close());

    test('година початку переживає запис і читання', () async {
      await store.save(course(at: ['09:00']));
      expect((await store.load()).single.startTime, '14:00');
    });

    test('правка курсу не пересуває його початок', () async {
      /* Виправлена назва не має ставати новим початком курсу: інакше кожне
         редагування переносило б межу, від якої рахуються дози. */
      await store.save(course(at: ['09:00']));
      final was = (await store.load()).single;
      await store.save(was.copyWith(name: 'Магній'));
      expect((await store.load()).single.startTime, '14:00');
    });
  });
}
