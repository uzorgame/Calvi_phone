import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/day_reader.dart';
import 'package:calvi/data/local/meds_store.dart';
import 'package:calvi/data/meds.dart';
import 'package:calvi/data/repeat.dart';

/// Галочка прийому належить дню, а не препарату.
///
/// Людина закривала ранковий прийом і бачила «прийнято» в кожному дні, зокрема
/// в майбутніх. Причина була в тому, що картка дня брала галочку з самого
/// препарату, а той завантажувався один раз на сьогодні.
void main() {
  late CalviDb db;
  late MedsStore meds;
  late DayReader days;

  setUp(() {
    db = CalviDb(NativeDatabase.memory());
    meds = MedsStore(db);
    days = DayReader(db);
  });
  tearDown(() => db.close());

  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));
  final tomorrow = today.add(const Duration(days: 1));

  Med magnesium({Repeat repeat = const DailyRepeat(), String? start}) => Med(
    id: 'm1',
    name: 'Магній B6',
    dose: 2,
    form: MedForm.tab,
    remind: true,
    repeat: repeat,
    startDay: start ?? dayKeyOf(today),
    times: const [MedTime(at: '08:00', taken: false)],
  );

  test('прийнято сьогодні не світиться вчора і завтра', () async {
    await meds.save(magnesium(start: dayKeyOf(yesterday)));
    await meds.setTaken(medId: 'm1', at: '08:00', taken: true);

    final list = await meds.load();

    for (final (label, date, want) in [
      ('вчора', yesterday, 0),
      ('сьогодні', today, 1),
      ('завтра', tomorrow, 0),
    ]) {
      final day = await days.read(date);
      final got = medProgressOn(medsOn(list, date), day.medTakes).done;
      expect(got, want, reason: '$label: прийнято $got замість $want');
    }
  });

  test('день знає свої галочки', () async {
    await meds.save(magnesium(start: dayKeyOf(yesterday)));
    await meds.setTaken(medId: 'm1', at: '08:00', taken: true, on: yesterday);

    expect((await days.read(yesterday)).medTakes, {'m1|08:00'});
    expect((await days.read(today)).medTakes, isEmpty);
  });

  test('по днях тижня препарат не зʼявляється до свого початку', () async {
    /* Той самий випадок, що й на телефоні: людина ставить «по понеділках»
       сьогодні, а препарат світиться в минулий понеділок. */
    final monday = today.subtract(Duration(days: (today.weekday - 1) % 7));
    final lastMonday = monday.subtract(const Duration(days: 7));

    final m = magnesium(
      repeat: const WeekdayRepeat(days: [1]),
      start: dayKeyOf(today),
    );

    expect(m.activeOn(lastMonday), false, reason: 'зʼявився в минулому понеділку');
    expect(m.activeOn(monday.add(const Duration(days: 7))), true, reason: 'зник у майбутньому');
  });

  test('день перебудовується від самої галочки', () async {
    /* Інакше картка показує зміну лише після виходу з екрана і повернення. */
    await meds.save(magnesium());

    final seen = <int>[];
    final sub = days.watch(today).listen((d) => seen.add(d.medTakes.length));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await meds.setTaken(medId: 'm1', at: '08:00', taken: true);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sub.cancel();

    expect(seen.first, 0);
    expect(seen.last, 1, reason: 'потік не помітив галочку: $seen');
  });

  test('курс без початку отримує сьогодні, а не «завжди»', () async {
    /* Аркуш створював препарат із порожнім початком, і порожній означав
       «приймався завжди»: до першого перезапуску він світився в минулих днях. */
    await meds.save(
      const Med(
        id: 'm2',
        name: 'Вітамін D3',
        dose: 1,
        form: MedForm.drop,
        remind: true,
        times: [MedTime(at: '08:00', taken: false)],
      ),
    );

    final back = (await meds.load()).where((m) => m.id == 'm2').single;
    expect(back.startDay, dayKeyOf(today));
    expect(back.activeOn(yesterday), false);
  });
}
