import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/meds.dart';
import 'package:calvi/data/notifications.dart';
import 'package:calvi/data/repeat.dart';
import 'package:calvi/data/settings.dart';

/// Що саме планується у шторку.
///
/// Перевіряється не показ (його дає система), а те, скільки сповіщень і з якими
/// словами кладеться в чергу: саме тут ховаються «нагадування не прийшло» і
/// «прийшло не те».
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Spy spy;
  late Notifications bell;

  setUp(() {
    spy = _Spy();
    bell = Notifications(sink: spy);
  });

  Reminder water({
    List<String> times = const ['09:00'],
    Repeat repeat = const DailyRepeat(),
    bool on = true,
  }) => Reminder(
    id: 'r1',
    kind: ReminderKind.water,
    label: 'Вода',
    times: times,
    repeat: repeat,
    on: on,
  );

  test('щоденне нагадування ставиться раз і повторюється щодня', () async {
    await bell.reschedule(reminders: [water()], meds: const [], medsRemind: false);

    expect(spy.planned, hasLength(1));
    expect(spy.planned.single.title, 'Вода');
    expect(spy.planned.single.body, 'Час попити');
    expect(spy.planned.single.repeats, Repeats.daily);
    expect(spy.planned.single.from, From.reminder, reason: 'нагадування веде не туди');
  });

  test('дві години це два сповіщення', () async {
    await bell.reschedule(
      reminders: [
        water(times: ['09:00', '21:00']),
      ],
      meds: const [],
      medsRemind: false,
    );

    expect(spy.planned, hasLength(2));
  });

  test('дні тижня це по одному на кожен день', () async {
    await bell.reschedule(
      reminders: [
        water(repeat: const WeekdayRepeat(days: [1, 3, 5])),
      ],
      meds: const [],
      medsRemind: false,
    );

    expect(spy.planned, hasLength(3));
    expect(spy.planned.every((p) => p.repeats == Repeats.weekly), true);
    expect({for (final p in spy.planned) p.at.weekday}, {1, 3, 5});
  });

  test('вимкнене нагадування не планується', () async {
    await bell.reschedule(reminders: [water(on: false)], meds: const [], medsRemind: false);
    expect(spy.planned, isEmpty);
  });

  test('через день ставиться поштучно на кілька тижнів', () async {
    /* Система вміє тільки «щодня» і «щотижня», тому інтервал розкладається на
       окремі дати. Без цього «через день» тихо не спрацьовувало б узагалі. */
    await bell.reschedule(
      reminders: [water(repeat: IntervalRepeat(every: 2, from: todayKey()))],
      meds: const [],
      medsRemind: false,
    );

    expect(spy.planned.length, greaterThan(5));
    expect(spy.planned.every((p) => p.repeats == Repeats.once), true);

    // Через день означає через день: сусідні дати не збігаються.
    final days = spy.planned.map((p) => p.at.day).toList();
    expect(days.toSet().length, days.length);
  });

  test('препарат називається своїм імʼям і своєю дозою', () async {
    await bell.reschedule(
      reminders: const [],
      medsRemind: true,
      meds: const [
        Med(
          id: 'm1',
          name: 'Магній B6',
          dose: 2,
          form: MedForm.tab,
          remind: true,
          times: [MedTime(at: '08:00', taken: false)],
        ),
      ],
    );

    expect(spy.planned, hasLength(1));
    expect(spy.planned.single.title, 'Магній B6');
    expect(spy.planned.single.body, '2 таблетки');

    /* Мітка їде разом зі сповіщенням: за нею дотик відкриває препарати, а не
       головний екран. Людина торкнулась «Магній B6» саме для того, щоб
       поставити галочку. */
    expect(spy.planned.single.from, From.meds);
  });

  test('вимкнені нагадування препаратів не планують нічого', () async {
    await bell.reschedule(
      reminders: const [],
      medsRemind: false,
      meds: const [
        Med(
          id: 'm1',
          name: 'Магній B6',
          dose: 1,
          form: MedForm.tab,
          remind: true,
          times: [MedTime(at: '08:00', taken: false)],
        ),
      ],
    );

    expect(spy.planned, isEmpty);
  });

  test('перепланування починається з чистого аркуша', () async {
    /* Інакше скасована година лишається в системі й дзвонить далі: людина
       перенесла нагадування, а старе прийшло о тій самій порі. */
    await bell.reschedule(reminders: [water()], meds: const [], medsRemind: false);
    await bell.reschedule(reminders: [water()], meds: const [], medsRemind: false);

    expect(spy.cancels, 2);
    expect(spy.planned, hasLength(1));
  });

  test('час у майбутньому, а не в минулому', () async {
    await bell.reschedule(
      reminders: [
        water(times: ['00:01']),
      ],
      meds: const [],
      medsRemind: false,
    );

    expect(spy.planned.single.at.isAfter(DateTime.now()), true);
  });

  test('два перепланування підряд не гасять одне одного', () async {
    /* Кожне починається з того, що витирає чергу цілком, а при запуску їх два:
       профіль і препарати читаються з диска паралельно. Якщо пустити їх
       навперейми, «витерти» другого може лягти після «поставити» першого. */
    final med = Med(
      id: 'm1',
      name: 'Магній B6',
      dose: 1,
      form: MedForm.tab,
      remind: true,
      repeat: const DailyRepeat(),
      startDay: dayKeyOf(DateTime.now()),
      times: const [MedTime(at: '08:00', taken: false)],
    );

    await Future.wait([
      bell.reschedule(reminders: [water()], meds: const [], medsRemind: false),
      bell.reschedule(reminders: [water()], meds: [med], medsRemind: true),
    ]);

    expect(spy.planned.map((p) => p.title).toList(), [
      'Вода',
      'Магній B6',
    ], reason: 'черга склалась не з останнього стану');
  });

  test('закінчений курс не потрапляє в чергу', () async {
    final over = Med(
      id: 'm2',
      name: 'Вітамін D3',
      dose: 1,
      form: MedForm.drop,
      remind: true,
      repeat: const DailyRepeat(),
      startDay: dayKeyOf(DateTime.now().subtract(const Duration(days: 30))),
      endDay: dayKeyOf(DateTime.now()),
      times: const [MedTime(at: '09:00', taken: false)],
    );

    await bell.reschedule(reminders: const [], meds: [over], medsRemind: true);
    expect(spy.planned, isEmpty, reason: 'закритий курс далі дзвонить');
  });
}

/// Двійник черги: нічого не показує, лише памʼятає, що в нього просили.
class _Spy implements NotificationSink {
  final planned =
      <({int id, String title, String body, DateTime at, Repeats repeats, String from})>[];
  var cancels = 0;

  @override
  set onTap(void Function(String from)? handler) {}

  @override
  Future<String?> launchedFrom() async => null;

  @override
  Future<void> ready() async {}

  @override
  Future<bool> ask() async => true;

  @override
  Future<bool> granted() async => true;

  @override
  Future<void> clearAll() async {
    cancels++;
    planned.clear();
  }

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
