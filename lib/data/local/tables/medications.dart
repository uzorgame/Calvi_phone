import 'package:drift/drift.dart';

import 'synced.dart';

/// The regimen: what is taken and at which hours.
///
/// Doses are recorded, never calculated. The product does not do arithmetic on
/// medicine, and that is a product decision, not a missing feature.
class Medications extends Table with Synced {
  TextColumn get name => text()();
  TextColumn get amount => text().nullable()();
  TextColumn get note => text().nullable()();

  /// Wall clock times as «HH:MM», comma separated. A reminder belongs to the
  /// clock on the wall: 08:00 stays 08:00 after a flight.
  TextColumn get times => text().withDefault(const Constant(''))();
  BoolColumn get remind => boolean().withDefault(const Constant(true))();

  /* Розклад рядком JSON: щодня, дні тижня або кожен N-й день.
   *
   * Годин самих по собі не досить: буває «через день», буває «по понеділках і
   * четвергах», і без цього поля такий курс доводилось вести в голові. */
  TextColumn get schedule => text().withDefault(const Constant(''))();

  /* Форма випуску власною колонкою: таблетка, капсула, крапля.
   *
   * Раніше вона їхала всередині `note` рядком «form=tab», бо своєї колонки не
   * мала. Через це збереження затирало примітку людини цим маркером, а читання
   * діставало з неї тільки форму: текст «разом зі сніданком» зникав назавжди і
   * мовчки. */
  TextColumn get form => text().withDefault(const Constant('tab'))();

  /* Межі курсу, календарними днями «РРРР-ММ-ДД».
   *
   * Препарат, заведений сьогодні, стосується сьогодні і майбутнього, а не всієї
   * історії: без `startDay` він зʼявлявся в кожному минулому дні, ніби людина
   * пила його завжди. `endDay` ставиться замість видалення, коли курс
   * закінчено: дні, коли препарат справді приймали, мають лишитись у щоденнику,
   * інакше історія переписується заднім числом. */
  TextColumn get startDay => text().withDefault(const Constant(''))();
  TextColumn get endDay => text().nullable()();
}
