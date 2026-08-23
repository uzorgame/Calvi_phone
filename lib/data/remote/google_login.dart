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
  GoogleLogin({required this.serverClientId});

  /// Веб-клієнт із Google Cloud. Порожньо означає, що вхід ще не налаштований.
  final String serverClientId;

  bool _ready = false;

  /// Чи можна взагалі показувати кнопку.
  bool get available => serverClientId.isNotEmpty;

  /* Ініціалізація одна на весь запуск: повторний виклик нічого не ламає, але й
     нічого не дає, а перший займає помітний час на холодному старті. */
  Future<void> _init() async {
    if (_ready) return;
    await GoogleSignIn.instance.initialize(serverClientId: serverClientId);
    _ready = true;
  }

  /// Чому не вийшло минулого разу, словами Google.
  ///
  /// Тримається тут, бо без нього збій виглядав як «нічого не сталося»: виняток
  /// вилітав нагору, ніхто його не ловив, і застосунок мовчки лишався на місці.
  /// Людина двічі тисне кнопку і йде геть, а ми навіть не знаємо, що вона
  /// приходила: запит до сервера в такому разі не доходить узагалі.
  String? lastError;

  /// Показує вікно Google і повертає `id_token`, або нічого, якщо передумали.
  ///
  /// Відмова людини це не помилка: вона натиснула «скасувати», і застосунок має
  /// повернутись туди, де був, без жодного повідомлення. Усе інше помилка, і про
  /// неї треба сказати.
  Future<String?> idToken() async {
    if (!available) {
      lastError = dataL.loginNotConfigured;
      return null;
    }

    lastError = null;

    try {
      await _init();
      final account = await GoogleSignIn.instance.authenticate();
      final token = account.authentication.idToken;
      if (token == null) lastError = dataL.loginNoToken;
      return token;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      lastError = '${e.code.name}: ${e.description ?? ''}'.trim();
      return null;
    } catch (e) {
      /* Ловимо все. Плагін уміє кидати не лише свій виняток, а на цьому шляху
         будь-який неспійманий виняток означає для людини порожню кнопку. */
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
