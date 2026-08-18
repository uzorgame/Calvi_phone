import 'dart:async';

import 'package:flutter/widgets.dart';

import '../local/database.dart';
import 'api.dart';
import 'chat_repository.dart';
import 'config.dart';
import 'food_repository.dart';
import 'sync_repository.dart';

/// Keeps the phone and the server in step, quietly.
///
/// **Nothing waits for it.** It runs when the app opens, when it comes back to
/// the foreground, and on a slow timer while it is open. A screen never asks it
/// for anything and never shows its progress: the local database is what the
/// screens read, and this only makes sure the same rows exist on the server.
class SyncService with WidgetsBindingObserver {
  SyncService(this.db, {CalviApi? api})
    : _api = api ?? CalviApi(base: Uri.parse(apiBase));

  final CalviDb db;
  final CalviApi _api;

  Timer? _tick;
  bool _busy = false;

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
  Future<NoraReply> ask({required String text, required String slot, Shot? image}) =>
      ChatRepository(db, _api).send(text: text, slot: slot, image: image);

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

  /// One round, and never two at once: a second run while the first is in the
  /// air would push the same rows twice and fight over the cursor.
  Future<SyncOutcome> now() async {
    if (_busy) return const SyncOutcome(pushed: 0, pulled: 0);
    _busy = true;
    try {
      return await SyncRepository(db, _api).run();
    } finally {
      _busy = false;
    }
  }
}
