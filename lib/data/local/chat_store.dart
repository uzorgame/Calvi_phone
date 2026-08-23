import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../chat.dart';
import 'database.dart';

const _uuid = Uuid();

/// Скільки останніх повідомлень піднімається при відкритті.
///
/// Не весь архів: розмова за півроку це тисячі рядків, які нікому не потрібні
/// одразу, а перший кадр екрана вони затримають помітно. Півсотні це кілька
/// днів звичайної переписки, тобто рівно те, куди людина справді гортає.
const chatWindow = 50;

/// Розмова з Норою між запусками.
///
/// Доти її не було зовсім: таблиця в базі стояла, а писав у неї ніхто. Кожен
/// запуск застосунку відкривав порожній чат, і те, що Нора казала вчора, разом
/// із тим, що людина їй писала, зникало без сліду. Для помічника, який
/// памʼятає звички, це особливо дивно виглядало.
///
/// Пишеться тут те саме, що видно на екрані, і рівно тоді, коли воно там
/// зʼявляється. Порожнє повідомлення очікування на диск не лягає: кільце це
/// стан екрана, а не рядок розмови.
class ChatStore {
  ChatStore(this.db);

  final CalviDb db;

  /// Останні повідомлення, найдавніші першими, як їх читає екран.
  Future<List<Msg>> load({int limit = chatWindow}) async {
    final rows =
        await (db.select(db.chatMessages)
              ..where((m) => m.deletedAt.isNull())
              ..orderBy([(m) => OrderingTerm(expression: m.at, mode: OrderingMode.desc)])
              ..limit(limit))
            .get();

    return [
      for (final row in rows.reversed)
        Msg(
          id: row.id,
          from: row.role == 'nora' ? MsgFrom.nora : MsgFrom.me,
          kind: _kindOf(row.role),
          text: row.body,
        ),
    ];
  }

  /// Кладе повідомлення на диск під тим самим ідентифікатором, що на екрані.
  ///
  /// Той самий, а не новий, і це важливо: відповідь Нори приходить у ту саму
  /// бульбашку, у якій щойно крутилось кільце, і знайти її на диску треба буде
  /// за тим самим ключем.
  Future<void> save(Msg m, {int spent = 0}) async {
    if (m.pending || m.text.trim().isEmpty) return;

    await db
        .into(db.chatMessages)
        .insertOnConflictUpdate(
          ChatMessagesCompanion.insert(
            /* Ідентифікатор з екрана короткий (`m12`), а рядок, який поїде на
           сервер, має бути uuid. Тому екранний перетворюється на сталий uuid:
           той самий вхід дає той самий ключ, і повторний запис оновлює рядок, а
           не додає другий. Саме на це спирається відповідь Нори, яка лягає в ту
           саму бульбашку, де щойно крутилось кільце. */
            id: _uuid.v5(Namespace.url.value, 'calvi:msg:${m.id}'),
            updatedAt: DateTime.now(),
            role: switch (m.from) {
              MsgFrom.nora => 'nora',
              MsgFrom.me => m.kind == MsgKind.photo ? 'user_photo' : 'user',
            },
            body: m.text,
            at: DateTime.now(),
            spent: Value(spent),
          ),
        );
  }

  /// Стирає розмову. Записи в щоденнику від цього не зникають: людина стирає
  /// переписку, а не те, що вона їла.
  Future<void> clear() async {
    final now = DateTime.now();
    await (db.update(db.chatMessages)..where((m) => m.deletedAt.isNull())).write(
      ChatMessagesCompanion(deletedAt: Value(now), updatedAt: Value(now), dirty: const Value(true)),
    );
  }

  static MsgKind _kindOf(String role) => switch (role) {
    'user_photo' => MsgKind.photo,
    _ => MsgKind.text,
  };
}
