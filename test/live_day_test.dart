import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/live_day.dart';

/// Живий запис: острівець на iPhone, стійке сповіщення на Android.
///
/// Перевіряється не малювання, його робить система, а рішення: коли запис
/// зʼявляється, коли оновлюється, коли зникає і які числа в ньому стоять.
class _Spy implements LiveSink {
  final shown = <LiveFacts>[];
  int hidden = 0;

  @override
  Future<void> show(LiveFacts facts) async => shown.add(facts);

  @override
  Future<void> hide() async => hidden++;
}

void main() {
  test('однакові числа не смикають систему двічі', () async {
    final spy = _Spy();
    final live = LiveDay(sink: spy, gap: Duration.zero);

    const same = LiveFacts(left: 800, goal: 2200, eaten: 1400);
    await live.put(same);
    await live.put(same);
    await live.put(const LiveFacts(left: 800, goal: 2200, eaten: 1400));

    expect(spy.shown.length, 1, reason: 'підсумки дня приходять потоком і часто повторюються');
  });

  test('нові числа оновлюють запис', () async {
    final spy = _Spy();
    final live = LiveDay(sink: spy, gap: Duration.zero);

    await live.put(const LiveFacts(left: 800, goal: 2200, eaten: 1400));
    await live.put(const LiveFacts(left: 400, goal: 2200, eaten: 1800));

    expect(spy.shown.length, 2);
    expect(spy.shown.last.left, 400);
  });

  test('зняти можна лише те, що висить', () async {
    final spy = _Spy();
    final live = LiveDay(sink: spy, gap: Duration.zero);

    await live.off();
    expect(spy.hidden, 0, reason: 'знімати нічого, а система отримала виклик');

    await live.put(const LiveFacts(left: 800, goal: 2200, eaten: 1400));
    await live.off();
    await live.off();
    expect(spy.hidden, 1);
  });

  test('після зняття ті самі числа показуються знову', () async {
    final spy = _Spy();
    final live = LiveDay(sink: spy, gap: Duration.zero);
    const same = LiveFacts(left: 800, goal: 2200, eaten: 1400);

    await live.put(same);
    await live.off();
    await live.put(same);

    expect(spy.shown.length, 2, reason: 'запис зняли, отже його треба завести наново');
  });

  test('пачка оновлень згортається в одне', () async {
    /* Числа приходять пачками: записали страву, перерахувалась норма, доїхала
       синхронізація. Кожне оновлення це анімація острівця, і пачка, яка
       наздогнала згортання застосунку, змушувала його програти появу вдруге.
       Перше йде одразу, решта згортається в останнє відоме. */
    final spy = _Spy();
    final live = LiveDay(sink: spy, gap: const Duration(milliseconds: 40));

    await live.put(const LiveFacts(left: 800, goal: 2200, eaten: 1400));
    await live.put(const LiveFacts(left: 700, goal: 2200, eaten: 1500));
    await live.put(const LiveFacts(left: 600, goal: 2200, eaten: 1600));

    expect(spy.shown.length, 1, reason: 'уся пачка пішла в систему поспіль');

    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(spy.shown.length, 2, reason: 'проміжні числа мали згорнутись в одне');
    expect(spy.shown.last.left, 600, reason: 'у системі має бути останнє число');
  });

  test('зняття скасовує те, що чекало у вікні', () async {
    final spy = _Spy();
    final live = LiveDay(sink: spy, gap: const Duration(milliseconds: 40));

    await live.put(const LiveFacts(left: 800, goal: 2200, eaten: 1400));
    await live.put(const LiveFacts(left: 700, goal: 2200, eaten: 1500));
    await live.off();

    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(spy.hidden, 1);
    expect(spy.shown.length, 1, reason: 'запис зняли, а число з черги його воскресило');
  });

  group('числа дня', () {
    test('перебір це не відʼємне число на екрані', () {
      const over = LiveFacts(left: -320, goal: 2200, eaten: 2520);
      expect(over.over, isTrue);
      expect(over.left.abs(), 320);
    });

    test('смуга не їде назад при переборі', () {
      const over = LiveFacts(left: -320, goal: 2200, eaten: 2520);
      expect(over.progress, greaterThan(1));
    });

    /* Тренування віднімається від зʼїденого, а не додається до норми: інакше
       число цілі пливло б щодня. Нетто буває відʼємним, і смуга тоді порожня, а
       не перевернута. */
    test('спалене більше за зʼїдене дає порожню смугу', () {
      const hard = LiveFacts(left: 2400, goal: 2200, eaten: -200);
      expect(hard.progress, 0);
    });

    test('без норми нічого не ділиться на нуль', () {
      const unset = LiveFacts(left: 0, goal: 0, eaten: 0);
      expect(unset.progress, 0);
    });
  });

  /* Останній запис це четверте число, і воно теж має рухати острівець.
   *
   * Без цього рядок «останній прийом їжі» застигав би на першій страві дня:
   * калорії дня однакові, коли одну страву замінили іншою такої ж ваги, а
   * запис при цьому інший. */
  test('новий останній запис оновлює острівець', () async {
    final spy = _Spy();
    final live = LiveDay(sink: spy, gap: Duration.zero);

    await live.put(const LiveFacts(left: 800, goal: 2200, eaten: 1400, last: 320));
    await live.put(const LiveFacts(left: 800, goal: 2200, eaten: 1400, last: 320));
    expect(spy.shown.length, 1);

    await live.put(const LiveFacts(left: 800, goal: 2200, eaten: 1400, last: 480));
    expect(spy.shown.length, 2);
    expect(spy.shown.last.last, 480);
  });

  /* Дозвіл дали посеред дня, і запис має зʼявитись одразу, а не з наступною
   * стравою.
   *
   * На Android 13 і новіших сповіщення без дозволу система викидає мовчки:
   * `put` уже сходив до неї і нічого не показав, а тут лишилось памʼятати, що
   * запис ніби стоїть. Ті самі числа далі не пішли б нікуди. */
  test('після дозволу ті самі числа показуються знову', () async {
    final spy = _Spy();
    final live = LiveDay(sink: spy, gap: Duration.zero);
    const same = LiveFacts(left: 800, goal: 2200, eaten: 1400);

    await live.put(same);
    live.forget();
    await live.put(same);

    expect(spy.shown.length, 2);
    expect(spy.hidden, 0, reason: 'знімати нема чого: нічого й не висіло');
  });

  test('порожній день не вигадує останнього запису', () {
    const empty = LiveFacts(left: 2200, goal: 2200, eaten: 0);
    expect(empty.last, isNull, reason: 'нуль калорій це запис, а порожньо це його відсутність');
  });
}
