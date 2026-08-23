import '../local/database.dart';
import 'api.dart';
import 'google_login.dart';
import '../../l10n/data_lang.dart';

/// Вхід через Google, від кнопки до готового акаунта.
///
/// Обліковий запис у нас існує до входу: застосунок заводить його при першому
/// запуску, разом із щоденником, бо їсти й записувати людина починає раніше, ніж
/// думати про акаунт. Тому вхід робить одну з трьох речей, і найважливіше тут
/// не вони, а те, що відбувається з місцевим щоденником.
///
/// Найгірший випадок такий: людина три дні писала на новому телефоні, а тоді
/// увійшла і виявилось, що в неї є старий акаунт із трьома місяцями. Тепер два
/// щоденники, і жоден не можна викинути мовчки. Тому місцеві записи або
/// забираються без питань, коли їх немає, або питання ставиться людині.

/// Що вийшло зі спроби увійти.
enum LoginResult {
  /// Увійшли, і місцевий щоденник лишився при своєму власнику.
  done,

  /// Увійшли в інший акаунт, а на телефоні є чужі записи. Треба питати людину.
  needsChoice,

  /// Людина закрила вікно Google. Не помилка, і казати про це нічого не треба.
  canceled,

  /// Мережі немає або сервер відмовив.
  failed,
}

class LoginService {
  LoginService({required this.db, required this.api, required this.google});

  final CalviDb db;
  final CalviApi api;
  final GoogleLogin google;

  /// Акаунт, у який увійшли, поки триває питання про місцеві записи.
  GoogleAccount? pending;

  /// Чи взагалі показувати кнопку входу.
  bool get available => google.available;

  /// Що саме пішло не так, якщо результат `failed`. Порожньо, якщо все гаразд.
  String? get error => google.lastError ?? _apiError;
  String? _apiError;

  Future<LoginResult> signIn({String? deviceName}) async {
    _apiError = null;
    final idToken = await google.idToken();

    /* Порожній токен це або «передумав», або збій. Розрізняє їх саме
       `lastError`: відмова людини його не лишає. */
    if (idToken == null) {
      return google.lastError == null ? LoginResult.canceled : LoginResult.failed;
    }

    final GoogleAccount account;
    try {
      account = await api.signInWithGoogle(idToken: idToken, device: deviceName);
    } on ApiFailure catch (e) {
      _apiError = dataL.loginServer('$e');
      return LoginResult.failed;
    } catch (e) {
      _apiError = e.toString();
      return LoginResult.failed;
    }

    /* Акаунт той самий, у якому людина була: нічого не змінилось, крім того, що
       тепер його можна повернути. Це найчастіший випадок. */
    if (!account.switched) {
      await _apply(account);
      return LoginResult.done;
    }

    /* Акаунт інший. Якщо на телефоні порожньо, забираємо мовчки: питати про
       порожній щоденник означає лякати людину рівним місцем. */
    if (!await _hasLocalDiary()) {
      await db.syncDao.wipe();
      await _apply(account);
      return LoginResult.done;
    }

    pending = account;
    return LoginResult.needsChoice;
  }

  /// Людина обрала старий щоденник: місцеві записи стираються.
  Future<void> keepAccount() async {
    final account = pending;
    if (account == null) return;

    await db.syncDao.wipe();
    await _apply(account);
    pending = null;
  }

  /// Людина обрала те, що на телефоні: вхід скасовується разом із ним.
  ///
  /// Акаунт на сервері нікуди не дівається, вона просто лишається в тому, у
  /// якому була. Увійти можна буде наступного разу.
  Future<void> keepLocal() async {
    pending = null;
    await google.forget();
  }

  /// Вийти з акаунта, лишивши щоденник на телефоні.
  ///
  /// Записи не чіпаються навмисно: вихід це відмова від синхронізації, а не
  /// стирання. Google теж забуває вибір, інакше наступний вхід мовчки зайшов би
  /// тим самим акаунтом, і кнопка виглядала б зламаною.
  Future<void> signOut() async {
    pending = null;
    await google.forget();
    await db.syncDao.clearAccount();
    api.token = null;
  }

  Future<void> _apply(GoogleAccount account) async {
    await db.syncDao.setAccount(
      userId: account.userId,
      accessToken: account.accessToken,
      refreshToken: account.refreshToken,
      email: account.email,
      joinedAt: account.joinedAt,
    );
    await db.syncDao.putTokens(balance: account.balance);
    api.token = account.accessToken;
  }

  /* Чи є на телефоні хоч щось, чого шкода. Тільки їжа: вода й тренування без
     страв це майже завжди порожній день, у якому людина покрутила застосунок і
     нічого не записала. */
  Future<bool> _hasLocalDiary() async {
    final rows = await db.select(db.meals).get();
    return rows.isNotEmpty;
  }
}
