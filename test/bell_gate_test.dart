import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/meds.dart';
import 'package:calvi/data/notifications.dart';
import 'package:calvi/data/settings.dart';

/// Перемикач не має брехати.
///
/// Дозвіл питався тільки при додаванні нагадування, а препарати йшли іншою
/// дорогою і не питали нічого. Людина заводила препарат, перемикач ставав
/// «увімкнено», системного дозволу не було, і сповіщення лягало в порожнечу.
void main() {
  test('без дозволу нічого не планується', () async {
    final spy = _Spy(allowed: false);
    final bell = Notifications(sink: spy);

    expect(await bell.granted(), false);
    expect(await bell.ask(), false);
  });

  test('дозвіл, який уже дали, не питається вдруге', () async {
    final spy = _Spy(allowed: true);
    final bell = Notifications(sink: spy);

    expect(await bell.granted(), true);
    expect(spy.asked, 0, reason: 'спитали, хоча дозвіл уже був');
  });

  test('препарат із нагадуванням доходить до черги', () async {
    final spy = _Spy(allowed: true);
    await Notifications(sink: spy).reschedule(
      reminders: const [],
      medsRemind: true,
      meds: const [
        Med(
          id: 'm1',
          name: 'Магній B6',
          dose: 2,
          form: MedForm.tab,
          remind: true,
          times: [MedTime(at: '11:10', taken: false)],
        ),
      ],
    );

    expect(spy.planned, hasLength(1));
    expect(spy.planned.single.title, 'Магній B6');
    expect(spy.planned.single.at.hour, 11);
    expect(spy.planned.single.at.minute, 10);
    expect(spy.planned.single.from, From.meds);
  });

  test('година в двадцятичотиригодинному форматі, а не в дванадцяти', () async {
    /* Барабан дає 0-23, і «21:00» має лишитись девʼятою вечора, а не девʼятою
       ранку. */
    final spy = _Spy(allowed: true);
    await Notifications(sink: spy).reschedule(
      reminders: [
        Reminder(
          id: 'r1',
          kind: ReminderKind.water,
          label: 'Вода',
          times: const ['21:00', '07:30'],
          on: true,
        ),
      ],
      meds: const [],
      medsRemind: false,
    );

    final hours = {for (final p in spy.planned) '${p.at.hour}:${p.at.minute}'};
    expect(hours, {'21:0', '7:30'});
  });
}

class _Spy implements NotificationSink {
  _Spy({required this.allowed});

  final bool allowed;
  var asked = 0;
  final planned =
      <({int id, String title, String body, DateTime at, Repeats repeats, String from})>[];

  @override
  Future<void> ready() async {}

  @override
  Future<bool> granted() async => allowed;

  @override
  Future<bool> ask() async {
    asked++;
    return allowed;
  }

  @override
  set onTap(void Function(String from)? handler) {}

  @override
  Future<String?> launchedFrom() async => null;

  @override
  Future<void> clearAll() async => planned.clear();

  @override
  Future<void> put({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    required Repeats repeats,
    required String from,
  }) async {
    planned.add((id: id, title: title, body: body, at: at, repeats: repeats, from: from));
  }
}
