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

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<bool> initialize({
    debugLogging = false,
    List<SpeechConfigOption>? options,
  }) async => true;

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

  @override
  Future<void> stop() async {
    stops++;
    onStatus?.call('done');
  }

  @override
  Future<void> cancel() async {
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

  test('порожні відрізки поспіль не крутяться вічно', () async {
    await start();

    /* Мікрофон міг забрати дзвінок. Двигун падатиме одразу після кожного
       запуску, і крутити це без кінця означало б гріти телефон у кишені. */
    for (var i = 0; i < 12; i++) {
      engine.hearsNothing();
      await _settle();
    }

    expect(voice.running, isFalse);
    expect(engine.listens, lessThan(8), reason: 'перезапуск пішов у гарячу петлю');
    expect(voice.failure, isNotNull);
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
