import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/profile_store.dart';
import 'package:calvi/data/repeat.dart';
import 'package:calvi/data/settings.dart';

/// Нагадування живуть у профілі, а не в памʼяті екрана.
///
/// Доти список зникав із перезапуском, як і препарати: одна й та сама діра, одне
/// й те саме джерело.
void main() {
  late CalviDb db;
  late ProfileStore store;

  setUp(() {
    db = CalviDb(NativeDatabase.memory());
    store = ProfileStore(db);
  });
  tearDown(() => db.close());

  test('нагадування переживає перезапуск', () async {
    await store.save(
      emptySettings().copyWith(
        reminders: const [
          Reminder(
            id: 'r1',
            kind: ReminderKind.water,
            label: 'Вода',
            times: ['09:00', '15:00'],
            repeat: WeekdayRepeat(days: [1, 3, 5]),
            on: true,
          ),
        ],
      ),
    );

    final back = (await store.load())!;
    expect(back.reminders, hasLength(1));

    final r = back.reminders.single;
    expect(r.label, 'Вода');
    expect(r.times, ['09:00', '15:00']);
    expect(r.on, true);
    expect((r.repeat as WeekdayRepeat).days, [1, 3, 5]);
  });

  test('через день читається назад тим самим', () async {
    await store.save(
      emptySettings().copyWith(
        reminders: const [
          Reminder(
            id: 'r1',
            kind: ReminderKind.weigh,
            label: 'Зважування',
            times: ['07:30'],
            repeat: IntervalRepeat(every: 2, from: '2026-08-18'),
            on: false,
          ),
        ],
      ),
    );

    final r = (await store.load())!.reminders.single;
    expect(r.on, false);
    expect((r.repeat as IntervalRepeat).every, 2);
    expect((r.repeat as IntervalRepeat).from, '2026-08-18');
  });

  test('на першому запуску нагадувань немає', () async {
    await store.save(emptySettings());
    expect((await store.load())!.reminders, isEmpty);
  });

  test('зіпсований рядок це порожній список, а не падіння', () async {
    await store.save(emptySettings());
    await db.customStatement("update profile set reminders = 'не json'");

    expect((await store.load())!.reminders, isEmpty);
  });

  test('розклад працює за днями тижня', () {
    const r = WeekdayRepeat(days: [1, 3]);
    expect(fallsOn(r, DateTime(2026, 8, 17)), true, reason: 'понеділок');
    expect(fallsOn(r, DateTime(2026, 8, 18)), false, reason: 'вівторок');
    expect(fallsOn(r, DateTime(2026, 8, 19)), true, reason: 'середа');
  });

  test('через день рахується від дня початку', () {
    const r = IntervalRepeat(every: 2, from: '2026-08-18');
    expect(fallsOn(r, DateTime(2026, 8, 18)), true);
    expect(fallsOn(r, DateTime(2026, 8, 19)), false);
    expect(fallsOn(r, DateTime(2026, 8, 20)), true);
    expect(fallsOn(r, DateTime(2026, 8, 17)), false, reason: 'до початку нічого не спрацьовує');
  });

  test('підпис розкладу читається людиною', () {
    expect(repeatLabel(const DailyRepeat()), 'щодня');
    expect(repeatLabel(const WeekdayRepeat(days: [1, 2, 3, 4, 5])), 'по буднях');
    expect(repeatLabel(const WeekdayRepeat(days: [6, 7])), 'на вихідних');
    expect(repeatLabel(const WeekdayRepeat(days: [1, 3, 5])), 'Пн, Ср, Пт');
    expect(repeatLabel(const IntervalRepeat(every: 2, from: '')), 'через день');
  });
}
