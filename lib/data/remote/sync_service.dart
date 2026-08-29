import 'dart:async';

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
    return review;
  }

  /// Минулі розбори для сторінки «Минулі», найновіший перший.
  Future<List<WeekReviewData>> weekReviews() async {
    if (!await SyncRepository(db, _api).ensureAccount()) return const [];
    return _api.weekReviews();
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
