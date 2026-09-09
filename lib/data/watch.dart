import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Що телефон розповідає годиннику.
///
/// Годинник це окремий застосунок: він не бачить ні наших налаштувань, ні бази,
/// ні токена доступу. Усе, чим він живе, приходить сюди звідси, і список цей
/// навмисно короткий.
///
/// **Токен.** Без нього годинник не має чим підписати запит до Нори.
///
/// **Мова.** Не «системна», а та, якою застосунок зараз говорить. Годинник має
/// свою системну мову, і вона може не збігтися з телефонною: слово «системна»,
/// послане на годинник, він розвʼязав би по-своєму і слухав би не ту мову.
/// Рівно на цьому вже горіли на телефоні, коли польську слухали українською
/// моделлю і отримували кирилицю.
///
/// **Норма і залишок.** Заради них застосунок і ставлять на годинник: відповідь
/// «скільки ще можна» без жодного дотику.
class Watch {
  const Watch._();

  static const _channel = MethodChannel('calvi/watch');

  /* Останнє надіслане. Екран дня перебудовується десятки разів на хвилину, а
     годинник має дізнаватись про зміни, а не про перемальовки. */
  static String? _sent;

  /// Кладе свіжий стан у чергу до годинника. Мовчить, коли нічого не змінилось.
  static Future<void> tell({
    required String? token,
    required String lang,
    required int norm,
    required int left,
    // The two units the watch shows: portions and energy. Body mass and the
    // rest never appear on it.
    String portion = 'g',
    String energy = 'kcal',
  }) async {
    /* Тільки iPhone. На Android каналу немає взагалі, на вебі немає й самого
       поняття, і питати там нема кого. */
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;

    // Без токена годиннику нема з чим іти на сервер: чекаємо, поки акаунт буде.
    if (token == null || token.isEmpty) return;

    final now = '$token|$lang|$norm|$left|$portion|$energy';
    if (now == _sent) return;
    _sent = now;

    try {
      await _channel.invokeMethod<void>('tell', {
        'token': token,
        'lang': lang,
        'norm': norm,
        'left': left,
        'portion': portion,
        'energy': energy,
      });
    } on PlatformException {
      /* Годинника може не бути зовсім, і це не помилка застосунку. Наступна
         зміна дня спробує знову. */
      _sent = null;
    } on MissingPluginException {
      // Складання без нативного боку: у тестах і на інших платформах.
      _sent = null;
    }
  }

  /// Забути надіслане: вихід з акаунта, стирання даних, зміна людини.
  ///
  /// Без цього наступний вхід із тим самим станом не дійшов би до годинника: він
  /// збігся б із запамʼятованим, і ми вирішили б, що вже все розповіли.
  static void forget() => _sent = null;
}
