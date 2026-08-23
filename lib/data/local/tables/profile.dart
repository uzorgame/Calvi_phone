import 'package:drift/drift.dart';

import 'synced.dart';

/// One row, the person's own settings and goal.
///
/// Columns rather than a settings blob: the daily norm is calculated from these
/// fields on both sides, and a blob cannot be checked by either.
class Profile extends Table with Synced {
  TextColumn get sex => text().withDefault(const Constant('m'))();
  IntColumn get birthYear => integer().nullable()();
  IntColumn get heightCm => integer().nullable()();

  RealColumn get goalStartKg => real().nullable()();
  RealColumn get targetKg => real().nullable()();
  TextColumn get direction => text().withDefault(const Constant('lose'))();
  RealColumn get pace => real().withDefault(const Constant(0.5))();
  RealColumn get activity => real().withDefault(const Constant(1.55))();

  /// Null means «count it», a number means the person overrode it.
  IntColumn get kcalManual => integer().nullable()();
  IntColumn get proteinG => integer().nullable()();
  IntColumn get fatG => integer().nullable()();
  IntColumn get carbsG => integer().nullable()();
  IntColumn get waterMl => integer().withDefault(const Constant(2000))();

  TextColumn get theme => text().withDefault(const Constant('system'))();

  /* Мова інтерфейсу. `system` означає «як на телефоні, а якщо тієї мови в нас
     немає, то англійська». Зберігається поруч із темою, бо це та сама річ: вибір
     вигляду, який людина зробила один раз і більше про нього не думає. */
  TextColumn get lang => text().withDefault(const Constant('system'))();

  /// Як звертатись до людини. Порожньо, поки вона не сказала.
  TextColumn get addressAs => text().nullable()();

  /* Памʼять Нори, рядком JSON.
   *
   * Тут вона живе поруч із рештою профілю, бо це короткий список на кілька
   * записів, один на людину, і він їздить тим самим маршрутом. Окрема таблиця
   * коштувала б повної синхронізації рядків заради десятка нотаток. */
  TextColumn get memory => text().withDefault(const Constant('[]'))();

  /* Нагадування рядком JSON, поруч із памʼяттю.
   *
   * Вони належать людині, а не дню, і живуть стільки ж, скільки профіль. Доти
   * список жив у памʼяті екрана і зникав із перезапуском, як і препарати. */
  TextColumn get reminders => text().withDefault(const Constant('[]'))();

  /* Які поля вимірювань людина веде: «weightKg,waist».
   *
   * Жило тільки в памʼяті екрана. Людина додавала груди й біцепс, місяць їх
   * записувала, а після перезапуску картка показувала знову вагу й талію: самі
   * заміри в базі лишались, але побачити їх було ніде. */
  TextColumn get tracked => text().withDefault(const Constant(''))();
}
