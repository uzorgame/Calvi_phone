import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text_platform_interface/speech_to_text_platform_interface.dart';

import 'package:calvi/screens/voice/dictation.dart';

/// Стартовий сигнал грає ДО відкриття мікрофона, і диктування чекає, поки він
/// догра.
///
/// Порядок тут і є вся справа. Сигнал, пущений після [listen], на iOS не чує
/// ніхто й ніколи: плагін уже перевів аудіосесію в режим запису, а системні
/// звуки в ньому глушаться. Симптом виглядав загадково, «старт майже ніколи,
/// стоп завжди», а причина одна мить у черзі викликів.
class _Engine extends SpeechToTextPlatform {
  _Engine(this.timeline);

  final List<String> timeline;

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<bool> initialize({debugLogging = false, List<SpeechConfigOption>? options}) async => true;

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
    timeline.add('мікрофон');
    onStatus?.call('listening');
    return true;
  }

  @override
  Future<void> stop() async {
    onStatus?.call('done');
  }

  @override
  Future<void> cancel() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('calvi/earcon');

  testWidgets('на iOS сигнал стоїть у черзі перед мікрофоном', (tester) async {
    final timeline = <String>[];

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async => timeline.add('сигнал:${call.arguments}'),
    );
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    final engine = _Engine(timeline);
    SpeechToTextPlatform.instance = engine;
    final voice = Dictation(engine: SpeechToText.withMethodChannel());
    addTearDown(voice.dispose);

    final ok = await tester.runAsync(() => voice.start(onWords: (_) {}));

    /* Руками, а не через addTearDown: каркас перевіряє відлагоджувальні змінні
       раніше, ніж виконує зареєстровані прибирання, і тест падав на власному
       прибиранні. */
    debugDefaultTargetPlatformOverride = null;

    expect(ok, isTrue);
    expect(timeline, [
      'сигнал:duo-on',
      'мікрофон',
    ], reason: 'сигнал після мікрофона означає сигнал, який на iOS заглушено');
  });
}
