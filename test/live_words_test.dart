import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/live_day.dart';
import 'package:calvi/l10n/data_lang.dart';

/* Живий запис говорить мовою застосунку, а не мовою розробника.
 *
 * Слова туди їдуть готовими з Dart: ні андроїдне сповіщення, ні острівець
 * iPhone не мають ні контексту, ні перекладів. Острівець узагалі малює окремий
 * процес, і будь-який рядок, написаний у Swift, лишався б одномовним назавжди.
 *
 * Перевіряється саме вантаж: що летить у систему і якою мовою. Малювання нас
 * тут не обходить, його робить система.
 */
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Останнє, що пішло каналом, або порожньо.
  Map<Object?, Object?>? sent;

  void listen(String channel) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      MethodChannel(channel),
      (call) async {
        if (call.method == 'show') sent = call.arguments as Map<Object?, Object?>;
        return null;
      },
    );
  }

  setUp(() {
    sent = null;
    listen('calvi/live.android');
    listen('calvi/live');
  });

  tearDown(() => dataLang = 'uk');

  const facts = LiveFacts(left: 2547, goal: 2900, eaten: 353, last: 174);

  test('андроїдне сповіщення говорить мовою застосунку', () async {
    dataLang = 'uk';
    await const AndroidLive().show(facts);
    final uk = Map<Object?, Object?>.from(sent!);

    expect(uk['title'], contains('Лишилось'));
    expect(uk['body'], contains('зʼїдено'));
    expect(uk['channel'], 'Лічильник дня');
    expect(uk['progress'], 12, reason: '353 з 2900 це дванадцять відсотків');

    dataLang = 'de';
    await const AndroidLive().show(facts);
    final de = Map<Object?, Object?>.from(sent!);

    expect(de['title'], isNot(uk['title']), reason: 'мова змінилась, а слова ні');
    expect(de['title'], contains('kcal'));
    expect(de['channel'], 'Tageszähler');
  });

  test('острівець говорить мовою застосунку', () async {
    dataLang = 'uk';
    await const IosLive().show(facts);
    final uk = Map<Object?, Object?>.from(sent!);

    expect(uk['caption'], 'ккал лишилось');
    expect(uk['lock'], 'лишилось на сьогодні');
    expect(uk['lastLabel'], 'останній прийом їжі');
    expect(uk['lastValue'], contains('ккал'));
    /* Розряди відділені тонким пробілом, тим самим, що на картці дня. Тут
       перевіряється сам факт розділення, а не який саме пробіл. */
    expect((uk['shown']! as String).replaceAll(RegExp(r'\s'), ''), '2547');
    expect(uk['shown'], isNot('2547'), reason: 'тисячі мають бути відділені');

    dataLang = 'pl';
    await const IosLive().show(facts);
    final pl = Map<Object?, Object?>.from(sent!);

    expect(pl['caption'], 'kcal zostało');
    expect(pl['lock'], 'zostało na dziś');
    expect(pl['lastLabel'], 'ostatni posiłek');
    expect(pl['unit'], 'kcal');
  });

  test('порожній день не вигадує останнього запису в жодній мові', () async {
    dataLang = 'de';
    await const IosLive().show(const LiveFacts(left: 2900, goal: 2900, eaten: 0));
    final de = Map<Object?, Object?>.from(sent!);

    expect(de['lastValue'], '', reason: 'числа немає, отже й рядка з ним немає');
    expect(de['lastLabel'], 'heute noch nichts eingetragen');
  });

  /* Чеська окремим тестом, бо вона остання прийшла в застосунок, і саме на
     новій мові видно, чи справді слова їдуть із Dart. Забутий словник дав би
     тут англійську, і жодна інша перевірка цього не помітила б. */
  test('чеський застосунок дає чеський острівець і чеське сповіщення', () async {
    dataLang = 'cs';

    await const IosLive().show(facts);
    final island = Map<Object?, Object?>.from(sent!);

    expect(island['caption'], 'kcal zbývá');
    expect(island['lock'], 'zbývá na dnešek');
    expect(island['lastLabel'], 'poslední jídlo');
    expect(island['unit'], 'kcal');

    await const AndroidLive().show(facts);
    final notice = Map<Object?, Object?>.from(sent!);

    expect(notice['title'], contains('Zbývá'));
    expect(notice['body'], contains('snědeno'));
    expect(notice['channel'], 'Počítadlo dne');
  });

  test('перебір це інше слово, а не мінус', () async {
    dataLang = 'uk';
    await const IosLive().show(const LiveFacts(left: -320, goal: 2200, eaten: 2520));
    final over = Map<Object?, Object?>.from(sent!);

    expect(over['shown'], '320', reason: 'число завжди додатне');
    expect(over['caption'], 'ккал перебір');
    expect(over['lock'], 'перебір за сьогодні');
    expect(over['progress'], 1.0, reason: 'смуга повна, а не переповнена');
  });
}
