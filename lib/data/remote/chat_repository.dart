import 'package:uuid/uuid.dart';

import '../local/daos/diary_dao.dart';
import '../local/database.dart';
import 'api.dart';

/// Talking to Nora, from the phone's side.
///
/// The request goes to our server and nowhere else: the model key lives there,
/// the token is spent there, and the diary row is written there. What comes back
/// is a sentence, a new balance, and whatever was recorded, which the next sync
/// brings down as an ordinary row.
class ChatRepository {
  ChatRepository(this.db, this.api);

  final CalviDb db;
  final CalviApi api;

  static const _uuid = Uuid();

  /// Sends one message and returns what Nora said.
  ///
  /// Throws [ApiFailure]; the screen decides what to show. «Немає токенів» and
  /// «немає мережі» are different sentences and must not be merged into one.
  Future<NoraReply> send({
    required String text,
    required String slot,
    DateTime? at,
    Shot? image,
  }) async {
    final when = at ?? DateTime.now();

    final answer = await api.chat(
      text: text,
      slot: slot,
      day: DiaryDao.dayKey(when),
      // The same key for a retry of the same message, so a lost connection
      // cannot charge twice for one sentence.
      idempotencyKey: _uuid.v4(),
      image: image,
    );

    // The balance is the server's word, mirrored so the screen can draw it.
    await db.syncDao.putTokens(balance: answer.balance);

    return answer;
  }

  /// Розбір знімка: числа назад, у щоденник нічого.
  Future<Analysis> look(Shot shot) async {
    final answer = await api.analyze(shot: shot, idempotencyKey: _uuid.v4());
    await db.syncDao.putTokens(balance: answer.balance);
    return answer;
  }
}
