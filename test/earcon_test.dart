import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/screens/voice/earcon.dart';

/// Службовий звук запису лунає тільки там, де його немає в системи.
///
/// На Android розпізнаванням займається окремий системний сервіс, і він грає
/// власні звуки початку і кінця. Свій поверх системного дав би два звуки на одне
/// натискання, а це помітно гірше за жоден. На iOS не грає ніхто, і саме там наш
/// потрібен.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('calvi/earcon');
  late List<String> played;

  setUp(() {
    played = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async {
        played.add('${call.method}:${call.arguments}');
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      null,
    );
    debugDefaultTargetPlatformOverride = null;
  });

  test('на iOS звучать обидва боки, і вони різні', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    await Earcon.start();
    await Earcon.stop();

    expect(played, ['play:duo-on', 'play:duo-off']);
  });

  /* Найважливіша перевірка у файлі. На Android звук грає система, і наш поверх
     нього означав би подвійний сигнал. */
  test('на Android не лунає нічого', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    await Earcon.start();
    await Earcon.stop();

    expect(played, isEmpty, reason: 'свій звук поверх системного це два звуки на одне натискання');
  });

  test('на решті систем теж тиша', () async {
    for (final p in [TargetPlatform.macOS, TargetPlatform.windows, TargetPlatform.linux]) {
      debugDefaultTargetPlatformOverride = p;
      await Earcon.start();
    }
    expect(played, isEmpty);
  });

  /* Телефон у беззвучному режимі, зайнята аудіосистема, відсутній файл: усе це
     має лишитись між нами. Диктування важливіше за приємність, і людина не
     просила звуку, щоб отримувати через нього помилки. */
  test('відмова нативної сторони не піднімається нагору', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async => throw PlatformException(code: 'busy'),
    );

    await expectLater(Earcon.start(), completes);
  });
}
