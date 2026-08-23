import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text_platform_interface/speech_to_text_platform_interface.dart';

import 'package:calvi/screens/voice/dictation.dart';

/// Диктування слухає, доки не скажуть перестати.
///
/// Двигун розпізнавання так не вміє: і Android, і iOS закривають відрізок після
/// паузи в голосі, а про Android бібліотека каже прямо, що системну паузу в
/// одну-три секунди не перебити нічим. Людина ж мовчить по кілька секунд просто
/// тому, що згадує, що вона ще їла. Тому диктування зшивається з відрізків, і
/// саме це тут перевіряється.
///
/// Замість справжнього мікрофона підставлений двигун, який робить, що скажуть:
/// віддає слова, обриває відрізок, повертає помилку. Іншого способу перевірити
/// поведінку на паузі немає, бо паузу в тесті не помовчиш.
class _FakeEngine extends SpeechToTextPlatform {
  int listens = 0;
  int stops = 0;
  int cancels = 0;

  /* Скільки двигун піднімається. На справжньому телефоні це не миттєво, і саме
     в цю щілину встигає піднятись палець. */
  Duration? slowStart;

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<bool> initialize({debugLogging = false, List<SpeechConfigOption>? options}) async {
    final wait = slowStart;
    if (wait != null) await Future<void>.delayed(wait);
    return true;
  }

  @override
  Future<List<dynamic>> locales() async => ['uk_UA:Українська'];

  @override
  Future<bool> listen({
    String? localeId,
    partialResults = true,
    onDevice = false,
    int listenMode = 0,
    sampleRate = 0,
    SpeechListenOptions? options,
  }) async {
    listens++;
    onStatus?.call('listening');
    return true;
  }

  /* Скільки двигун домовляє фразу після того, як його спинили. Нуль означає, що
     він мовчить: так поводиться пристрій, який підсумку не віддає взагалі. */
  Duration? tail;
  String tailWords = '';

  @override
  Future<void> stop() async {
    stops++;
    /* Справжній двигун домовляє фразу окремим викликом уже після зупинки, а не
       в ту саму мить. Саме на цьому й обрізало кінець кожної фрази. */
    final wait = tail;
    if (wait != null) {
      Future<void>.delayed(wait, () {
        hears(tailWords, finished: true);
        onStatus?.call('done');
      });
    } else {
      onStatus?.call('done');
    }
  }

  @override
  Future<void> cancel() async {
    cancels++;
    onStatus?.call('done');
  }

  /// Двигун почув слова. Проміжний результат чи закритий відрізок.
  ///
  /// Форма відповіді така сама, як у справжнього. Двійка в `resultType` означає
  /// закритий відрізок, нуль означає, що людина ще говорить. Одиниця це щось
  /// проміжне між ними, і саме на ній цей тест колись і збився.
  void hears(String words, {bool finished = false}) {
    onTextRecognition?.call(
      jsonEncode({
        'resultType': finished ? 2 : 0,
        'alternates': [
          {'recognizedWords': words, 'confidence': 0.9},
        ],
      }),
    );
  }

  /// Двигун закінчив відрізок сам, як він і робить після паузи в голосі.
  void givesUp() => onStatus?.call('done');

  /// Мовчазний відрізок, як його закінчує справжній двигун.
  ///
  /// Саме так, і це не дрібниця: статус «done» після відрізка без жодного слова
  /// бібліотека ковтає, і єдиним свідченням того, що двигун згас, лишається ця
  /// помилка.
  void hearsNothing() {
    breaks('error_no_match');
    givesUp();
  }

  void breaks(String code) {
    onError?.call(jsonEncode({'errorMsg': code, 'permanent': true}));
  }
}

/// Пауза, довша за ту, що диктування чекає перед новим відрізком.
Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 400));

void main() {
  late _FakeEngine engine;
  late Dictation voice;
  late List<String> said;

  setUp(() {
    engine = _FakeEngine();
    SpeechToTextPlatform.instance = engine;
    voice = Dictation(engine: SpeechToText.withMethodChannel());
    said = [];
  });

  tearDown(() => voice.dispose());

  Future<bool> start() => voice.start(onWords: said.add);

  test('кінець фрази не губиться, хай навіть двигун домовляє його після зупинки', () async {
    /* Найдорожчий баг цього екрана: у чат летіла фраза без останніх слів, і
       щоразу приблизно однаково обрізана. Причина не в записі звуку, а в тому,
       що почуте забирали в ту саму мить, коли просили двигун спинитись, а він
       домовляє окремим викликом уже після. */
    await start();

    engine.hears('два яйця і тост');
    engine.tail = const Duration(milliseconds: 120);
    engine.tailWords = 'два яйця і тост і кава без цукру';

    expect(await voice.stop(), 'два яйця і тост і кава без цукру');
  });

  test('зупинка не висить, коли двигун підсумку так і не віддав', () async {
    /* Буває і так. Чекати вічно означало б тримати людину з прибраним пальцем
       перед екраном, де нічого не відбувається. */
    await start();
    engine.hears('два яйця');
    engine.tail = null;

    final began = DateTime.now();
    final heard = await voice.stop();
    final took = DateTime.now().difference(began);

    expect(heard, 'два яйця', reason: 'втратили навіть те, що вже почули');
    expect(took, lessThan(const Duration(seconds: 2)), reason: 'зупинка думала задовго');
  });

  test('пауза в голосі не закінчує диктування', () async {
    expect(await start(), isTrue);
    expect(engine.listens, 1);

    engine.hears('два яйця', finished: true);
    engine.givesUp();
    await _settle();

    expect(engine.listens, 2, reason: 'після паузи двигун не перезапустили');
    expect(voice.running, isTrue, reason: 'диктування здалось раніше за людину');
  });

  test('почуте до паузи і після неї зшивається в одну фразу', () async {
    await start();

    engine.hears('два яйця', finished: true);
    engine.givesUp();
    await _settle();

    engine.hears('і кава без цукру', finished: true);
    engine.givesUp();
    await _settle();

    expect(voice.heard, 'два яйця і кава без цукру');
  });

  test('проміжне слово не губить того, що вже почули', () async {
    await start();

    engine.hears('тарілка борщу', finished: true);
    engine.givesUp();
    await _settle();

    // Наступний відрізок починає розпізнавання з чистого аркуша.
    engine.hears('і', finished: false);
    expect(voice.heard, 'тарілка борщу і');

    engine.hears('і компот', finished: false);
    expect(voice.heard, 'тарілка борщу і компот', reason: 'проміжне не має накопичуватись двічі');
  });

  test('тиша це не помилка, а просто тиша', () async {
    await start();
    engine.hears('салат', finished: true);

    // Саме так Android повідомляє про паузу.
    engine.hearsNothing();
    await _settle();

    expect(voice.running, isTrue);
    expect(voice.failure, isNull, reason: 'пауза показалась людині як поломка');
    expect(engine.listens, 2);
  });

  test('відібраний мікрофон зупиняє диктування і каже чому', () async {
    await start();
    engine.breaks('error_permission');
    engine.givesUp();
    await _settle();

    expect(voice.running, isFalse);
    expect(voice.failure, 'Немає дозволу на мікрофон');
  });

  test('мовчазний відрізок теж перезапускається', () async {
    await start();
    engine.hears('гречка', finished: true);
    await _settle();

    final listens = engine.listens;
    engine.hearsNothing();
    await _settle();

    expect(engine.listens, listens + 1, reason: 'після тихого відрізка диктування згасло');
    expect(voice.running, isTrue);
    expect(voice.heard, 'гречка', reason: 'тиша стерла те, що вже почули');
  });

  test('довга пауза не вимикає диктування', () async {
    /* Людина сказала «запиши» і задумалась. Двигун на кожній паузі закриває
       відрізок і падає одразу після запуску, бо чути нічого. Доти шість таких
       падінь поспіль вимикали диктування, і людина, яка ще тримала палець на
       кнопці, договорювала в нікуди. */
    await start();
    engine.hears('запиши', finished: true);

    for (var i = 0; i < 12; i++) {
      engine.hearsNothing();
      await _settle();
    }

    expect(voice.running, isTrue, reason: 'диктування здалось раніше за людину');
    expect(voice.failure, isNull, reason: 'пауза записалась як поломка');
  });

  test('порожні відрізки поспіль не крутяться вічно', () async {
    /* Терпіння тут коротке навмисно: справжнє це двадцять пʼять секунд, і
       чекати їх у тесті означало б чекати їх по-справжньому. */
    voice.dispose();
    voice = Dictation(
      engine: SpeechToText.withMethodChannel(),
      patience: const Duration(milliseconds: 1200),
    );
    await start();

    /* Мікрофон міг забрати дзвінок. Двигун падатиме одразу після кожного
       запуску, і крутити це без кінця означало б гріти телефон у кишені. */
    for (var i = 0; i < 16; i++) {
      engine.hearsNothing();
      await _settle();
    }

    expect(voice.running, isFalse);
    expect(engine.listens, lessThan(12), reason: 'перезапуск пішов у гарячу петлю');
    expect(voice.failure, isNotNull);
  });

  test('палець прибрали посеред старту, і мікрофон не лишився ввімкненим', () async {
    /* Найпідліший із збоїв цієї кнопки, бо він лишав по собі увімкнений
       мікрофон і жодного сліду на екрані.
     *
     * Старт довгий: підняти двигун, спитати в нього перелік мов, аж тоді почати
     * слухати. Тап по кнопці коротший за це. Скасування, яке виконувалось
     * усередині старту, не скасовувало нічого: старт дограв після нього і
     * вмикав мікрофон уже після того, як кнопку відпустили. Спинити його після
     * цього не було чим, бо для екрана сеанс уже закінчився. */
    engine.slowStart = const Duration(milliseconds: 120);

    final starting = start();
    final letGo = voice.cancel();

    await starting;
    await letGo;
    await _settle();

    expect(voice.running, isFalse, reason: 'мікрофон лишився ввімкненим після відпускання');
    expect(engine.cancels, 1, reason: 'до двигуна скасування так і не дійшло');
  });

  test('другий обʼєкт над тим самим двигуном лишається глухим', () async {
    /* Причина, з якої обʼєкт диктування рівно один на застосунок, і головна
       підозра в тому, що мікрофон «часто ламається».
     *
     * `SpeechToText()` віддає спільний екземпляр, а його `initialize` при
     * повторному виклику виходить одразу і **не перереєстровує** обробники
     * подій. Перший, хто підняв двигун, забирає його події назавжди.
     *
     * Доти обʼєкт створювався наново на кожне натискання мікрофона, і з другого
     * разу безперервне слухання просто не працювало: двигун закривав відрізок
     * на першій же паузі, а перезапустити його не було кому. Людина тримала
     * палець, бачила смуги, які дихають, і говорила в мікрофон, якого вже
     * ніхто не слухав.
     *
     * Цей тест не про наш код, а про двигун під ним: він тримає причину, з якої
     * [Dictation.shared] існує, щоб її не «спростили» назад. */
    final one = SpeechToText.withMethodChannel();

    final first = Dictation(engine: one);
    await first.start(onWords: (_) {});
    await first.stop();

    final second = Dictation(engine: one);
    await second.start(onWords: (_) {});
    final listens = engine.listens;

    // Двигун згас на паузі. Про це дізнається перший обʼєкт, а не той, що слухає.
    engine.hearsNothing();
    await _settle();

    expect(engine.listens, listens, reason: 'другого обʼєкта двигун таки почув');
    expect(second.running, isTrue, reason: 'і він навіть не знає, що мікрофон під ним уже мовчить');

    first.dispose();
    second.dispose();
  });

  test('скасований сеанс не лишає почутого наступному', () async {
    /* Скасування це не зупинка: сказане викидають, а не забирають. Лишити його
       означало б, що наступна фраза почнеться з чужих слів. */
    await start();
    engine.hears('борщ');

    await voice.cancel();
    expect(voice.heard, isEmpty);
    expect(voice.running, isFalse);

    await start();
    expect(voice.heard, isEmpty, reason: 'новий сеанс почався з викинутої фрази');
  });

  test('зупинка людиною остаточна', () async {
    await start();
    engine.hears('вівсянка', finished: true);

    expect(await voice.stop(), 'вівсянка');

    final listens = engine.listens;
    await _settle();
    expect(engine.listens, listens, reason: 'зупинене диктування ожило саме');
    expect(voice.running, isFalse);
  });
}
