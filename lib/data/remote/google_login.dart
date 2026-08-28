import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../l10n/data_lang.dart';

/// Вхід через Google, з боку телефона.
///
/// Тут рівно один крок: показати вікно Google і взяти з нього `id_token`. Усе
/// інше вирішує сервер, бо тільки він може перевірити цей токен по-справжньому.
/// Телефон не має права вирішувати, хто перед ним: він показує те, що йому
/// віддали, а віддати можна що завгодно.
///
/// **Ідентифікатор сервера, а не застосунку.** `serverClientId` це веб-клієнт із
/// консолі Google, і саме його наш сервер перевіряє як адресата. Без нього
/// Google видає токен для самого застосунку, сервер бачить чужого адресата й
/// чесно відмовляє. Помилка з цим полем виглядає як «усе працює, але вхід не
/// проходить», і шукається довго.
class GoogleLogin {
  GoogleLogin({required this.serverClientId, this.iosClientId = ''});

  /// Веб-клієнт із Google Cloud. Порожньо означає, що вхід ще не налаштований.
  final String serverClientId;

  /* Клієнт типу iOS. На Android не потрібен і не передається: там застосунок
     впізнають за назвою пакета і відбитком ключа підпису. На пристроях Apple
     такої опори немає, і без цього ідентифікатора плагін не збирає
     конфігурацію взагалі. Мовчки: помилки не буде, впаде вже сама спроба. */
  final String iosClientId;

  bool _ready = false;

  /// Чи цей пристрій вимагає власного ідентифікатора застосунку.
  static bool get _apple =>
      defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS;

  /// Чи можна взагалі показувати кнопку.
  ///
  /// На Apple мало веб-клієнта: без свого ідентифікатора кнопка відкриє вікно і
  /// не зробить нічого. Кнопка, яка нічого не робить, гірша за її відсутність.
  bool get available => serverClientId.isNotEmpty && (!_apple || iosClientId.isNotEmpty);

  /* Ініціалізація одна на весь запуск: повторний виклик нічого не ламає, але й
     нічого не дає, а перший займає помітний час на холодному старті. */
  Future<void> _init() async {
    if (_ready) return;
    /* Обидва ідентифікатори разом, і на Apple це принципово. Плагін збирає
       конфігурацію лише тоді, коли знає клієнта застосунку, а разом із нею
       ставить і серверного. Передати самого серверного означає, що конфігурації
       не буде зовсім, і адресатом токена стане сам застосунок: вікно згоди
       відкриється, а сервер відмовить. */
    await GoogleSignIn.instance.initialize(
      clientId: _apple && iosClientId.isNotEmpty ? iosClientId : null,
      serverClientId: serverClientId,
    );
    _ready = true;
  }

  /// Чому не вийшло минулого разу, словами Google.
  ///
  /// Тримається тут, бо без нього збій виглядав як «нічого не сталося»: виняток
  /// вилітав нагору, ніхто його не ловив, і застосунок мовчки лишався на місці.
  /// Людина двічі тисне кнопку і йде геть, а ми навіть не знаємо, що вона
  /// приходила: запит до сервера в такому разі не доходить узагалі.
  String? lastError;

  /// Що сказати людині про цю відмову. `null` означає «мовчати».
  ///
  /// Скасуванням система називає і власну відмову теж, і це вже коштувало нам
  /// вечора: аркуш Google піднімався, сам опускався, а застосунок мовчав, бо
  /// вважав, що людина передумала. Насправді збірку підписали ключем, під який
  /// не заведено клієнта, і система сказала про це словами «[16] Account reauth
  /// failed», але сказала їх лише в журнал пристрою. Те саме рішення вже
  /// прийнято для входу через Apple, і з тієї ж причини.
  ///
  /// Тому мовчимо лише тоді, коли аркуш закрили без жодного пояснення: порожній
  /// опис і є тим, як виглядає людина, яка справді передумала. Ціна відома, хтось
  /// із них усе ж побачить короткий рядок, і вона дешевша за поломку, якої не
  /// видно.
  static String? refusal(GoogleSignInExceptionCode code, String? description) {
    final why = description?.trim() ?? '';
    if (code == GoogleSignInExceptionCode.canceled && why.isEmpty) return null;
    return why.isEmpty ? code.name : '${code.name}: $why';
  }

  /* Слід у logcat, і в release теж.
   *
   * Нативний аркуш Android уміє репортувати свої внутрішні провали як
   * «скасування»: у коді плагіна GetCredentialCancellationException чесно
   * перекладається в canceled, і збій виглядає точнісінько як людина, що
   * передумала. Єдиний спосіб їх розрізнити: записати все, що віддав плагін,
   * дослівно. Рядки збираються так:
   *
   *     adb logcat | grep CalviAuth
   */
  static void _note(String what) {
    // ignore: avoid_print
    print('CalviAuth: $what');
  }

  /// Показує вікно Google і повертає `id_token`, або нічого, якщо передумали.
  ///
  /// Відмова людини це не помилка: вона натиснула «скасувати», і застосунок має
  /// повернутись туди, де був, без жодного повідомлення. Усе інше помилка, і про
  /// неї треба сказати.
  Future<String?> idToken() async {
    if (!available) {
      lastError = dataL.loginNotConfigured;
      _note(
        'кнопка недоступна: serverClientId=${serverClientId.isNotEmpty}, '
        'iosClientId=${iosClientId.isNotEmpty}, apple=$_apple',
      );
      return null;
    }

    lastError = null;
    _note(
      'старт: platform=$defaultTargetPlatform, '
      'server=...${serverClientId.substring(serverClientId.length - 26)}',
    );

    try {
      await _init();
      _note('initialize пройшов');
      /* Хвилина, і не більше. Це єдине очікування в застосунку без межі:
         кожен запит до сервера має свої двадцять секунд, а вікно Google могло
         висіти вічно, і кнопка разом із ним. Вічний спінер це найгірша з
         відповідей: він не каже нічого, і людина не може навіть повторити.
         Хвилини вистачає і на вибір пошти, і на повільну мережу; хто справді
         відійшов і повернувся, побачить не колесо, а пораду спробувати ще. */
      final account = await GoogleSignIn.instance.authenticate().timeout(
        const Duration(seconds: 60),
      );
      final token = account.authentication.idToken;
      _note(
        'успіх: ${account.email}, токен=${token == null ? 'НЕМАЄ' : '${token.length} символів'}',
      );
      if (token == null) lastError = dataL.loginNoToken;
      return token;
    } on TimeoutException {
      _note('таймаут: 60 секунд без відповіді від аркуша');
      lastError = dataL.loginSlow;
      return null;
    } on GoogleSignInException catch (e) {
      /* Кожне поле окремо і дослівно: code, description, details. Саме тут
         живе відповідь, чому аркуш закрився. */
      _note(
        'GoogleSignInException: code=${e.code.name} | '
        'description=${e.description} | details=${e.details}',
      );

      lastError = refusal(e.code, e.description);
      return null;
    } catch (e, st) {
      /* Ловимо все. Плагін уміє кидати не лише свій виняток, а на цьому шляху
         будь-який неспійманий виняток означає для людини порожню кнопку. */
      _note('несподіване: ${e.runtimeType}: $e\n$st');
      lastError = e.toString();
      return null;
    }
  }

  /// Забути вхід на цьому телефоні. Акаунт на сервері лишається.
  Future<void> forget() async {
    if (!_ready) return;
    await GoogleSignIn.instance.signOut();
  }
}
