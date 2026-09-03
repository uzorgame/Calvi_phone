import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import '../local/database.dart';
import 'api.dart';
import 'config.dart';
import 'google_login.dart';
import 'login_service.dart';
import 'chat_repository.dart';
import 'food_repository.dart';
import 'sync_repository.dart';

/// Keeps the phone and the server in step, quietly.
///
/// **Nothing waits for it.** It runs when the app opens, when it comes back to
/// the foreground, and on a slow timer while it is open. A screen never asks it
/// for anything and never shows its progress: the local database is what the
/// screens read, and this only makes sure the same rows exist on the server.
class SyncService with WidgetsBindingObserver {
  SyncService(this.db, {CalviApi? api}) : _api = api ?? CalviApi(base: Uri.parse(apiBase));

  final CalviDb db;
  final CalviApi _api;

  Timer? _tick;

  /* Замок, спільний із входом: гонка курсора жила саме між ними двома. */
  final SyncGate _gate = SyncGate();

  /// Often enough that a phone left open catches another device's writes, rare
  /// enough to be invisible on a battery.
  static const _every = Duration(seconds: 45);

  void start() {
    WidgetsBinding.instance.addObserver(this);
    unawaited(now());
    _tick = Timer.periodic(_every, (_) => unawaited(now()));
  }

  void stop() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    _api.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back is the moment another device's changes matter most.
    if (state == AppLifecycleState.resumed) unawaited(now());
  }

  /// Asks Nora, over the same client and the same account as the sync.
  Future<NoraReply> ask({
    required String text,
    required String slot,
    Shot? image,
    List<Map<String, String>> history = const [],
    String place = 'today',
    /// Написане в поле картки, а не в чат: запис лягає рівно в цю картку.
    bool card = false,
  }) => ChatRepository(
    db,
    _api,
  ).send(text: text, slot: slot, image: image, history: history, place: place, card: card);

  /* Тижневий розбір. Живе тут, а не в екрані, бо тут той самий клієнт, той
     самий акаунт і те саме дзеркало токенів: розбір коштує два, і число в
     застосунку має змінитись тією ж миттю, а не наступним обміном. */
  Future<WeekReviewData> weekReview() async {
    if (!await SyncRepository(db, _api).ensureAccount()) throw const ApiFailure.offline();

    final review = await _api.weekReview(idempotencyKey: const Uuid().v4());
    if (review.balance != null) {
      await db.syncDao.putTokens(balance: review.balance!, unlimited: review.unlimited);
    }

    /* Свіжий розбір одразу в чоло знімка: перезапуск застосунку має зустріти
       його на місці, а не чекати наступної відповіді сервера. Той самий
       тиждень, збудований наново, витісняє свою стару версію. */
    final had = await weekReviewsSnapshot() ?? const <WeekReviewData>[];
    await _putReviewsSnapshot([review, ...had.where((w) => w.week != review.week)]);

    return review;
  }

  /* Підтвердити покупку сервером.
   *
   * Доступ дає сервер, і після вікна магазину телефон питає його одразу, а не
   * чекає чергового обміну: півхвилини з лічильником після оплати читаються
   * як «не спрацювало». Повертає, чи сервер уже зняв лічильник. Порожньо,
   * коли спитати не вдалось: тоді правда приїде обміном. */
  Future<bool?> confirmPurchase() async {
    if (!await SyncRepository(db, _api).ensureAccount()) return null;
    try {
      final now = await _api.refreshSubscription();
      await db.syncDao.putTokens(balance: now.balance, unlimited: now.unlimited);
      if (now.state != null) await _keepSubscription(now.state!);
      return now.unlimited;
    } on ApiFailure {
      return null;
    }
  }

  /* Форма підписки для сторінки тарифу: знімок для першого кадру і свіжа
     відповідь за ним. Тільки сервер знає все разом: який тариф діє, який
     заплановано наступним, доки і чи поновиться. */
  Future<SubscriptionState?> subscriptionSnapshot() async {
    final raw = await db.syncDao.snapshot(subscriptionSnapshotKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return SubscriptionState.fromWire(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<SubscriptionState?> subscription() async {
    if (!await SyncRepository(db, _api).ensureAccount()) return null;
    try {
      final state = await _api.subscriptionState();
      await _keepSubscription(state);
      return state;
    } on ApiFailure {
      return null;
    }
  }

  Future<void> _keepSubscription(SubscriptionState s) =>
      db.syncDao.putSnapshot(subscriptionSnapshotKey, jsonEncode(s.toWire()));

  /// Минулі розбори, як їх востаннє віддав сервер. Null до першої відповіді.
  Future<List<WeekReviewData>?> weekReviewsSnapshot() async {
    final raw = await db.syncDao.snapshot(_reviewsKey);
    if (raw == null) return null;
    try {
      return [
        for (final b in jsonDecode(raw) as List<dynamic>)
          WeekReviewData.fromWire(b as Map<String, dynamic>),
      ];
    } catch (_) {
      return null;
    }
  }

  Future<void> _putReviewsSnapshot(List<WeekReviewData> rows) => db.syncDao.putSnapshot(
    _reviewsKey,
    // fresh і баланс у знімок не йдуть: збережений розбір уже нічого не коштує.
    jsonEncode([
      for (final r in rows) {'week': r.week, 'body': r.body},
    ]),
  );

  /// Минулі розбори для сторінки «Минулі», найновіший перший. Успіх осідає
  /// в знімок.
  Future<List<WeekReviewData>> weekReviews() async {
    if (!await SyncRepository(db, _api).ensureAccount()) return const [];
    final rows = await _api.weekReviews();
    await _putReviewsSnapshot(rows);
    return rows;
  }

  /* --- Знімки серверних списків ---
   *
   * Книга рецептів і минулі розбори належать серверу: телефон їх не творить,
   * лише показує. Щоб сторінки відкривались миттєво і без мережі, останнє
   * слово сервера лежить у місцевій базі, і правила прості: знімок читається
   * при відкритті, пишеться кожною вдалою відповіддю, місцевих правок у ньому
   * не буває. Через це серверу й телефону нема за що битись: у знімка немає
   * власної думки, він завжди програє свіжій відповіді. */

  static const _recipesKey = 'recipes';
  static const _reviewsKey = 'week_reviews';

  /* toWire шле чернетку на сервер і тому не знає id та дати; знімок мусить
     памʼятати обидва, інакше після перезапуску картки втратять «щойно». */
  Map<String, dynamic> _recipeJson(RecipeData r) => {
    ...r.toWire(),
    'id': r.id,
    if (r.createdAt != null) 'created_at': r.createdAt!.toIso8601String(),
  };

  Future<void> _putRecipesSnapshot(List<RecipeData> rows) => db.syncDao.putSnapshot(
    _recipesKey,
    jsonEncode([for (final r in rows) _recipeJson(r)]),
  );

  /// Книга, як її востаннє віддав сервер. Null, коли знімка ще не було.
  Future<List<RecipeData>?> recipesSnapshot() async {
    final raw = await db.syncDao.snapshot(_recipesKey);
    if (raw == null) return null;
    try {
      return [
        for (final b in jsonDecode(raw) as List<dynamic>)
          RecipeData.fromWire(b as Map<String, dynamic>),
      ];
    } catch (_) {
      // Зіпсований знімок означає «знімка немає», а не поламану сторінку.
      return null;
    }
  }

  /// Книга рецептів людини, найновіший перший. Успіх осідає в знімок.
  Future<List<RecipeData>> recipes() async {
    if (!await SyncRepository(db, _api).ensureAccount()) return const [];
    final rows = await _api.recipes();
    await _putRecipesSnapshot(rows);
    return rows;
  }

  /// Покласти рецепт у книгу. Відповідь сервера стає в чоло знімка.
  Future<RecipeData> saveRecipe(RecipeData draft) async {
    if (!await SyncRepository(db, _api).ensureAccount()) throw const ApiFailure.offline();
    final saved = await _api.createRecipe(draft);
    final had = await recipesSnapshot();
    if (had != null) await _putRecipesSnapshot([saved, ...had]);
    return saved;
  }

  /// Прибрати рецепт із книги. Знімок худне лише після згоди сервера: якщо
  /// видалення не дійшло, рецепт чесно лишається на екрані.
  Future<void> deleteRecipe(String id) async {
    if (!await SyncRepository(db, _api).ensureAccount()) throw const ApiFailure.offline();
    await _api.deleteRecipe(id);
    final had = await recipesSnapshot();
    if (had != null) {
      await _putRecipesSnapshot([for (final r in had) if (r.id != id) r]);
    }
  }

  /* Підбір страв. Живе тут із тієї ж причини, що тижневий розбір: той самий
     клієнт і те саме дзеркало токенів, число в застосунку міняється тією ж
     миттю, а не наступним обміном. */
  Future<List<RecipeData>> suggestRecipes(String what) async {
    if (!await SyncRepository(db, _api).ensureAccount()) throw const ApiFailure.offline();

    final got = await _api.suggestRecipes(what: what, idempotencyKey: const Uuid().v4());
    if (got.balance != null) {
      await db.syncDao.putTokens(balance: got.balance!, unlimited: got.unlimited);
    }
    return got.options;
  }

  /* Вхід через Google. Живе тут, бо саме тут лежить той самий клієнт і та сама
     база: вхід міняє обліковий запис, і робити це повз синхронізацію означало б
     мати два уявлення про те, хто зараз у застосунку. */
  late final LoginService login = LoginService(
    db: db,
    api: _api,
    google: GoogleLogin(serverClientId: googleClientId, iosClientId: googleIosClientId),
    gate: _gate,
  );

  /// Вага, обрана дотиком. Без токена: страву вже розібрано.
  Future<NoraReply> weigh({required int grams, required String slot, String? askId}) =>
      ChatRepository(db, _api).weigh(grams: grams, slot: slot, askId: askId);

  /// Що на знімку. Числа для картки сканера, без запису в день.
  Future<Analysis> look(Shot shot) => ChatRepository(db, _api).look(shot);

  /// The food reference, over the same client. Kept as one instance because it
  /// remembers what it has already asked, and a new one each time would ask the
  /// server the same two words again.
  late final FoodRepository foods = FoodRepository(api: _api, db: db);

  /// Puts real numbers on an entry someone typed by hand.
  ///
  /// The account has to exist first, or the lookup comes back 401 and the entry
  /// stays at zero. On a phone with no signal this quietly does nothing, and the
  /// entry keeps the name it was given.
  Future<bool> enrich(String mealId, String text) async {
    if (!await SyncRepository(db, _api).ensureAccount()) return false;
    return foods.enrich(mealId, text);
  }

  /* «Видалити дані» з налаштувань, від сервера до місцевої бази.
   *
   * Під тим самим замком, що обмін і вхід, і це не обережність про запас:
   * обмін, що вилетів до стирання, довозив би свої рядки на сервер уже після
   * нього, і вони воскресали б живими. Порядок усередині теж не довільний:
   * спершу дотиснути своє нагору, щоб серверне гасіння накрило все, тоді
   * погасити, тоді прибрати місцеве і зʼїхати надгробки. */
  Future<void> eraseDiary() => _gate.run(() async {
    await SyncRepository(db, _api).run();
    await _api.eraseDiary();
    await db.syncDao.clearDiary();
    await SyncRepository(db, _api).run();
  });

  /* «Видалити акаунт і дані»: від запиту на сервер до порожнього телефона.
   *
   * Порядок важливий. Спершу запит, поки токен ще живий: без відповіді сервера
   * нічого не стирається, бо інакше акаунт лишився б живим у базі, а людина
   * була б певна, що його немає. Потім вихід: він забуває Google і Apple,
   * акаунт, токени, підписку і всю місцеву базу разом із курсором. Після цього
   * застосунок не знає нічого і починає з вітання, як після встановлення.
   *
   * Незіслане тут навмисно не дотискається, на відміну від виходу: акаунт іде
   * в чергу на видалення, і везти на нього останню страву нема сенсу.
   *
   * Під тим самим замком, що обмін: обмін, який вилетів під час стирання,
   * довіз би рядки на акаунт, що вже в черзі на видалення. */
  Future<void> deleteAccount() => _gate.run(() async {
    await _api.requestDeletion();
    await login.signOut();
  });

  /* Вийти з акаунта: спершу дотиснути незіслане, потім забути все місцеве.
   *
   * Порядок тут і є суттю. `signOut` стирає щоденник з телефона, і рядок, який
   * сервер ще не бачив, зник би назавжди. Тому перед виходом іде звичайний
   * обмін, і тільки після нього стирання.
   *
   * Невдача обміну виходу не скасовує: людина попросила вийти, і тримати її в
   * акаунті через відсутню мережу неправильно. Ціна відома і сказана в аркуші
   * перед кнопкою: записи, зроблені офлайн, лишаться тільки в цьому телефоні,
   * тобто зникнуть. */
  Future<void> signOut() async {
    try {
      await now();
    } on ApiFailure {
      // Немає мережі. Вихід усе одно робиться, див. коментар вище.
    }
    await _gate.run(login.signOut);
  }

  /// One round, and never two at once: a second run while the first is in the
  /// air would push the same rows twice and fight over the cursor.
  Future<SyncOutcome> now() async {
    /* Зайнято входом або іншим обміном: такт пропускається, а не стає в чергу.
       Обмін, який і так іде, довезе те саме, а черга з тактів таймера була б
       чергою однакової роботи. */
    if (_gate.held) return const SyncOutcome(pushed: 0, pulled: 0);
    return _gate.run(() => SyncRepository(db, _api).run());
  }
}
