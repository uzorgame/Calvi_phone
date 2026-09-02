import '../billing/billing.dart';
import '../local/database.dart';
import 'api.dart';
import 'apple_login.dart';
import 'google_login.dart';
import 'sync_repository.dart';
import '../../l10n/data_lang.dart';

/// Вхід через Google, від кнопки до готового акаунта.
///
/// Обліковий запис у нас існує до входу: застосунок заводить його при першому
/// запуску, разом із щоденником, бо їсти й записувати людина починає раніше, ніж
/// думати про акаунт.
///
/// Найдорожчий випадок такий: людина три дні писала на новому телефоні, а тоді
/// увійшла і виявилось, що в неї є старий акаунт із трьома місяцями. Раніше це
/// було питання з двома відповідями, і обидві погані: «взяти хмарний» стирало
/// три дні, «лишити телефонний» скасовувало вхід. Тепер питання немає: сервер
/// зливає безіменний акаунт пристрою у справжній прямо під час входу, і жоден
/// із двох щоденників не втрачається.
///
/// Клієнту лишаються три кроки, і всі три під одним замком із фоновим обміном:
/// дотиснути своє нагору, перемкнутись, зʼїхати обʼєднане вниз.

/// Що вийшло зі спроби увійти.
enum LoginResult {
  /// Увійшли. Обʼєднаний щоденник уже на телефоні.
  done,

  /// Людина закрила вікно провайдера. Не помилка, і казати про це нічого не треба.
  canceled,

  /// Увійшли, але щоденник цього разу не доїхав повністю.
  ///
  /// Акаунт на телефоні вже є, і повторювати вхід не треба: записи забере
  /// наступний обмін. Окремо від [failed] саме тому, що людині тут не можна
  /// казати «не вдалось»: вдалось, і кнопка більше не потрібна.
  partial,

  /// Мережі немає або сервер відмовив.
  failed,
}

class LoginService {
  LoginService({
    required this.db,
    required this.api,
    required this.google,
    AppleLogin? apple,
    SyncGate? gate,
  }) : apple = apple ?? AppleLogin(),
       gate = gate ?? SyncGate();

  final CalviDb db;
  final CalviApi api;
  final GoogleLogin google;
  final AppleLogin apple;

  /* Черга, спільна з фоновим обміном. Своя за замовчуванням, щоб тести і
     розʼєднані виклики працювали, але в застосунку сюди приходить замок самого
     SyncService: гонка, від якої він захищає, живе саме між ними двома. */
  final SyncGate gate;

  /// Чи взагалі показувати кнопку входу.
  bool get available => google.available;

  /// Чи показувати кнопку Apple. Окремо від Google: вона живе лише на iOS.
  bool get appleAvailable => apple.available;

  /// Що саме пішло не так, якщо результат `failed`. Порожньо, якщо все гаразд.
  ///
  /// Одне поле на обидва входи, і кладе його той, ким щойно заходили. Раніше
  /// тут стояло `google.lastError ?? apple.lastError`, і помилка одного
  /// провайдера переживала спробу входу іншим: людина тиснула Apple, а бачила
  /// стару причину від Google. Діагностика йшла хибним слідом.
  String? get error => _lastError;
  String? _lastError;

  /* Останній вхід зняв акаунт із черги на видалення. Екран, що кликав вхід,
     дивиться сюди одразу після `done` і показує аркуш «дані відновлено»:
     людина має знати, що записи повернулись і що видалення доведеться просити
     знову. Скидається на кожній новій спробі входу. */
  bool get restored => _restored;
  bool _restored = false;

  Future<LoginResult> signIn({String? deviceName}) => _signIn(
    window: google.idToken,
    windowError: () => google.lastError,
    exchange: (idToken) => api.signInWithGoogle(idToken: idToken, device: deviceName),
  );

  /// Вхід через Apple: інше вікно, той самий конвеєр.
  ///
  /// Спільний шлях не з економії, а з обережності: усі гарантії про «спершу
  /// дотиснути все нагору» і «стирати лише порожню чергу» живуть в одному
  /// місці, і другий вхід зі своєю копією цих правил розійшовся б із першим
  /// на першій же правці.
  Future<LoginResult> signInApple({String? deviceName}) => _signIn(
    window: apple.identityToken,
    windowError: () => apple.lastError,
    exchange: (idToken) => api.signInWithApple(idToken: idToken, device: deviceName),
  );

  Future<LoginResult> _signIn({
    required Future<String?> Function() window,
    required String? Function() windowError,
    required Future<GoogleAccount> Function(String idToken) exchange,
  }) async {
    _lastError = null;
    _restored = false;

    /* Вікно провайдера поза замком навмисно: людина може дивитись на нього
       хвилину, і морозити на цей час фонову синхронізацію нема за що. */
    final idToken = await window();

    /* Порожній токен це або «передумав», або збій. Розрізняє їх саме
       `lastError`: відмова людини його не лишає. */
    if (idToken == null) {
      _lastError = windowError();
      return _lastError == null ? LoginResult.canceled : LoginResult.failed;
    }

    return gate.run(() async {
      try {
        /* Крок перший: дотиснути нагору ВСЕ місцеве, поки акаунт ще старий.
           Сервер зливає те, що в нього доїхало, і рядок, який жив тільки в
           телефоні, злиття б не пережив. Тому без мережі вхід чесно падає тут,
           а не стирає недовезене.

           Циклом, а не одним обміном. Обмін відвозить до сотні рядків на
           таблицю і зупиняється, розраховуючи на наступний такт таймера. Для
           фонової синхронізації це правильно, а тут «майже все доїхало» не
           відрізняється від «нічого»: тиждень життя без входу може важити
           більше за одну порцію, і стирати можна лише порожню чергу. */
        for (var round = 0; round < 30; round++) {
          final up = await SyncRepository(db, api).run();
          if (up.failure != null) {
            _lastError = dataL.loginServer('${up.failure}');
            return LoginResult.failed;
          }
          if (!await db.syncDao.hasDirty()) break;
        }
        if (await db.syncDao.hasDirty()) {
          /* Сервер живий, але якийсь рядок не приймає. Входити далі означало б
             стерти його при перемиканні; чесніше зупинитись і сказати. */
          _lastError = dataL.loginNotSynced;
          return LoginResult.failed;
        }

        final account = await exchange(idToken);
        _restored = account.restored;

        /* Акаунт інший: сервер уже перевіз туди записи безіменного. Місцева
           копія тепер чужа за номерами черги, тому чистий аркуш і повний
           зʼїзд з нуля. */
        if (account.switched) await db.syncDao.wipe();
        await _apply(account);

        /* Крок останній: зʼїхати все одразу, а не чекати таймера. Людина після
           входу дивиться на екран, і хвилина порожнечі читалась як «дані
           зникли», хоча вони просто ще не приїхали.

           Але вхід уже відбувся, і невдача ТУТ його не скасовує. Один зіпсований
           рядок у відповіді валив увесь вхід: акаунт уже лежав на телефоні, а
           людина бачила «Не вдалось увійти» і тиснула кнопку знову, отримуючи
           те саме. Записи доїдуть наступним обміном, а сказати про це можна
           тихо. */
        try {
          await SyncRepository(db, api).run();
        } catch (e) {
          _lastError = dataL.loginServer('$e');
          return LoginResult.partial;
        }
        return LoginResult.done;
      } on ApiFailure catch (e) {
        _lastError = dataL.loginServer('$e');
        return LoginResult.failed;
      } catch (e) {
        _lastError = e.toString();
        return LoginResult.failed;
      }
    });
  }

  /// Вийти з акаунта, лишивши щоденник на телефоні.
  ///
  /// Записи не чіпаються навмисно: вихід це відмова від синхронізації, а не
  /// стирання. Google теж забуває вибір, інакше наступний вхід мовчки зайшов би
  /// тим самим акаунтом, і кнопка виглядала б зламаною.
  Future<void> signOut() async {
    await google.forget();
    await apple.forget();
    await db.syncDao.clearAccount();
    /* Разом з акаунтом іде і його баланс: інакше сторінка підписки ще хвилину
       показувала б «Pro» тому, хто щойно вийшов. */
    await db.syncDao.clearTokens();
    // І форма підписки: вона теж належала акаунту, з якого вийшли.
    await db.syncDao.putSnapshot(subscriptionSnapshotKey, '');
    api.token = null;
    // Далі покупки цього пристрою рахуються анонімними, поки хтось не увійде.
    await Billing.identify(null);
  }

  Future<void> _apply(GoogleAccount account) async {
    await db.syncDao.setAccount(
      userId: account.userId,
      accessToken: account.accessToken,
      refreshToken: account.refreshToken,
      email: account.email,
      joinedAt: account.joinedAt,
      provider: account.provider,
    );
    await db.syncDao.putTokens(balance: account.balance, unlimited: account.unlimited);
    api.token = account.accessToken;
    /* Магазин має знати, чия це покупка. Наш `userId` їде в RevenueCat як
       `app_user_id`, і саме за ним вебхук знайде людину на сервері. */
    await Billing.identify(account.userId);
  }
}
