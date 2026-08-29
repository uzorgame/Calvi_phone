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

  /// Вага, обрана дотиком у відповідь на питання Нори.
  ///
  /// Токен не списується: страву вже розібрано попереднім повідомленням, і
  /// лишилось помножити її числа на вагу. Далі дорога та сама, що й у звичайної
  /// відповіді, тому і застосовується вона тим самим кодом.
  Future<NoraReply> weigh({
    required int grams,
    required String slot,
    String? askId,
    DateTime? at,
  }) async {
    final when = at ?? DateTime.now();
    final answer = await api.weigh(
      grams: grams,
      slot: slot,
      askId: askId,
      day: DiaryDao.dayKey(when),
    );
    await _apply(answer, slot: slot, when: when);
    return answer;
  }

  /// Sends one message and returns what Nora said.
  ///
  /// Throws [ApiFailure]; the screen decides what to show. «Немає токенів» and
  /// «немає мережі» are different sentences and must not be merged into one.
  Future<NoraReply> send({
    required String text,
    required String slot,
    DateTime? at,
    Shot? image,
    List<Map<String, String>> history = const [],
    String place = 'today',
    bool card = false,
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
      history: history,
      place: place,
      card: card,
    );

    await _apply(answer, slot: slot, when: when);
    return answer;
  }

  /* Усе, що Нора зробила з щоденником, лягає на телефон тут же, а не
   * наступною синхронізацією.
   *
   * Дорога була така: телефон питає сервер, сервер пише в свою базу, телефон
   * забирає це назад окремим запитом. Три кроки і дві мережі між словами
   * «записала яєчню» і появою яєчні в сніданку. Кожен збій на другій мережі
   * давав те саме: відповідь є, запису немає, і застосунок виглядає так, ніби
   * бреше.
   *
   * Один метод на обидві дороги, звичайну відповідь і вагу з кнопки: вони
   * повертають ту саму форму, і два списки полів рано чи пізно розійшлись би. */
  Future<void> _apply(NoraReply answer, {required String slot, required DateTime when}) async {
    // The balance is the server's word, mirrored so the screen can draw it.
    await db.syncDao.putTokens(balance: answer.balance, unlimited: answer.unlimited);

    /* Усе, що Нора зробила з щоденником, лягає на телефон тут же, а не
     * наступною синхронізацією.
     *
     * Дорога була така: телефон питає сервер, сервер пише в свою базу, телефон
     * забирає це назад окремим запитом. Три кроки і дві мережі між словами
     * «записала яєчню» і появою яєчні в сніданку. Кожен збій на другій мережі
     * давав те саме: відповідь є, запису немає, і застосунок виглядає так, ніби
     * бреше.
     *
     * Тепер рядки кладуться з відповіді, якою вона прийшла, і з тими самими
     * ідентифікаторами. Синхронізація лишається: вона зшиває пристрої між
     * собою. Але картка дня вже не чекає на неї. */

    /* Прибране гасне тут же, тим самим ідентифікатором. Людина сказала «видали
       сніданок», Нора відповіла «прибрала», і картка має спорожніти в ту саму
       мить, а не за сорок пʼять секунд, коли доїде синхронізація. */
    for (final id in answer.deleted) {
      await db.diaryDao.forgetServerMeal(id);
    }

    /* Виправлене переписується тут же, тим самим ідентифікатором. Людина
       сказала «ні, двісті грамів», Нора відповіла «виправила», і число в картці
       має змінитись у ту саму мить, а не за сорок пʼять секунд. */
    for (final m in answer.fixed) {
      await db.diaryDao.patchServerMeal(
        id: m.id,
        name: m.name,
        kcal: m.kcal,
        grams: m.grams,
        protein: m.protein,
        fat: m.fat,
        carbs: m.carbs,
      );
    }

    /* Перенесене переїжджає тут же, тим самим ідентифікатором.
     *
     * Не видалити й записати наново: числа лишаються ті самі, разом із усіма
     * виправленнями, які людина колись зробила. Міняється місце. */
    for (final m in answer.moved) {
      await db.diaryDao.moveServerMeal(
        id: m.id,
        day: m.day,
        slot: m.slot,
        at: m.at == null ? null : DateTime.tryParse(m.at!)?.toLocal(),
      );
    }

    /* Вода лягає в свою картку, а не стравою в обід. */
    final poured = answer.water;
    if (poured != null) {
      if (poured.id.isNotEmpty) {
        await db.diaryDao.putServerWater(
          id: poured.id,
          day: DiaryDao.dayKey(when),
          ml: poured.ml,
          at: when,
        );
      } else if (poured.ml < 0) {
        /* Мінус не має свого рядка: сервер зменшив уже записане. Телефон
           приводить день до того ж підсумку тим самим правилом, що й кнопка
           «менше», інакше два способи зменшити одне число розійшлись би. */
        await db.diaryDao.setWaterTotal(poured.totalMl, at: when);
      }
    }

    /* Заміри теж. Доти Нора казала «записала вагу 77.5», а на екрані не
       мінялось нічого: ні картка, ні крива, ні прогрес до цілі. */
    for (final m in answer.measures) {
      if (m.id.isEmpty) continue;
      final at = DateTime.tryParse(m.at ?? '')?.toLocal() ?? when;

      if (m.part == 'weight') {
        await db.diaryDao.putServerWeight(id: m.id, day: m.day, kg: m.value, at: at);
      } else {
        await db.diaryDao.putServerMeasure(id: m.id, day: m.day, part: m.part, cm: m.value, at: at);
      }
    }

    /* Тренування теж лягає одразу, з ідентифікатором сервера. */
    for (final w in answer.workouts) {
      if (w.id.isEmpty) continue;
      await db.diaryDao.putServerWorkout(
        id: w.id,
        day: DiaryDao.dayKey(when),
        kind: w.kind,
        minutes: w.minutes,
        kcal: w.kcal,
        at: when,
      );
    }

    for (final m in answer.logged) {
      if (m.id.isEmpty) continue;
      /* Слот, день і час беруться з відповіді, а не з екрана. Саме тут страва
         їхала не в ту картку. */
      await db.diaryDao.putServerMeal(
        id: m.id,
        day: m.day,
        slot: m.slot,
        name: m.name,
        kcal: m.kcal,
        at: DateTime.tryParse(m.at ?? '')?.toLocal() ?? when,
        grams: m.grams,
        protein: m.protein,
        fat: m.fat,
        carbs: m.carbs,
        icon: m.icon,
      );
    }
  }

  /// Розбір знімка: числа назад, у щоденник нічого.
  Future<Analysis> look(Shot shot) async {
    final answer = await api.analyze(shot: shot, idempotencyKey: _uuid.v4());
    await db.syncDao.putTokens(balance: answer.balance, unlimited: answer.unlimited);
    return answer;
  }
}
