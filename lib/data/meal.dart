/// One record in the day, and the card it belongs to.
library;

import 'nutrients.dart';

/// Which mark a row shows: a key from our own set, as a string.
///
/// Not an emoji, because emoji are drawn by the OS and the same meal would look
/// one way on iOS and a noticeably worse way on most Android builds, and neither
/// would match the rest of the interface.
///
/// Not an enum either, and this was once one. The set is shared with the server,
/// where it is the closed list the model is handed, and an enum here meant every
/// new mark had to be added in three places and mapped between them. Now a key
/// that does not exist simply draws the plate, and that is the only rule.
typedef FoodIcon = String;

/// Назва запису з великої літери, решта рядка недоторкана.
///
/// Рядок у картці дня це підпис, а не уламок речення, і «яйце» поруч із
/// «Тост з маслом» читається як недогляд. Саме перша літера, а не кожне слово:
/// «Тост З Маслом» це вже вивіска.
///
/// Записам від Нори це не потрібно, вони приходять із сервера вже такими. Тут
/// це для того, що людина вписала руками.
String titled(String name) {
  final clean = name.trim();
  if (clean.isEmpty) return clean;

  /* По рунах, а не по кодових одиницях: половина символу з пари сурогатів це
     зіпсована назва. */
  final runes = clean.runes.toList();
  final first = String.fromCharCode(runes.first).toUpperCase();
  return first + String.fromCharCodes(runes.skip(1));
}

class Meal {
  const Meal({
    required this.id,
    required this.icon,
    required this.title,
    required this.time,
    required this.slotId,
    this.grams = 0,
    this.kcal = 0,
    this.protein = 0,
    this.fat = 0,
    this.carbs = 0,
    this.auto = false,
    this.pending = false,
    this.nutrients = Nutrients.none,
  });

  final String id;
  final FoodIcon icon;
  final String title;

  /// "08:20". A string because it is only ever displayed and compared.
  final String time;

  /// Points at a [SlotDef] on the day, not at a fixed enum: cards are opened and
  /// renamed while the day runs.
  final String slotId;

  /* Другий рівень нутрієнтів цієї страви, і кожне з пʼяти може бути невідомим.
     Порожньо означає «ще не рахували», а не «немає»: усе, записане до появи
     цієї можливості, лишиться порожнім назавжди, і малювати там нулі означало б
     вигадати числа за минулий рік. */
  final Nutrients nutrients;

  final int grams;
  final int kcal;
  final int protein;
  final int fat;
  final int carbs;

  /// Logged from the widget or the watch without a confirmation step.
  final bool auto;

  /// Written down but not parsed yet: the numbers are unknown until Nora
  /// answers, and filling them with a guess would be the app inventing data.
  final bool pending;
}

/// A card on the day.
class SlotDef {
  const SlotDef({required this.id, required this.label, required this.order, required this.icon});

  final String id;
  final String label;

  /// Roughly the hour the card belongs to. Only a fallback: a day with records
  /// in it sorts by the time they actually happened.
  final int order;

  /// Name in the icon set.
  final String icon;

  SlotDef renamed(String label) => SlotDef(id: id, label: label, order: order, icon: icon);
}

/// The four the assistant works from. A day may carry others.
const baseSlots = <String, SlotDef>{
  'breakfast': SlotDef(id: 'breakfast', label: 'Сніданок', order: 8, icon: 'sunrise'),
  'lunch': SlotDef(id: 'lunch', label: 'Обід', order: 13, icon: 'sun'),
  'dinner': SlotDef(id: 'dinner', label: 'Вечеря', order: 19, icon: 'moon'),
  'snack': SlotDef(id: 'snack', label: 'Перекус', order: 16, icon: 'utensils'),
};

/// Breakfast, lunch and dinner stand whether or not anything went into them.
/// A card that only appears once it has content cannot be tapped to add the
/// first thing, which is exactly when it is needed.
const alwaysSlots = ['breakfast', 'lunch', 'dinner'];

/* Ніч закінчується о пів на пʼяту.
 *
 * До того наступний запис іде в перекус, а не в сніданок. За самою годиною
 * найближчою карткою о другій ночі виходив сніданок (його година восьма, до
 * решти ще далі), і те, що їдять уночі, лягало в ранок. Пів на пʼяту це межа,
 * з якої ранній підйом уже рахується ранком, і сніданок о пʼятій лишається
 * сніданком. */
const nightEndsMinute = 4 * 60 + 30;

/// Картка, у яку піде наступний запис о цій порі.
///
/// Уночі перекус, коли він у дня є; далі найближча за своєю годиною картка.
/// Порівнюється з годиною картки, а не з останнім дотиком: людина відкриває
/// застосунок, щоб записати те, що їсть зараз.
SlotDef? nearestSlot(Iterable<SlotDef> slots, DateTime now) {
  if (now.hour * 60 + now.minute < nightEndsMinute) {
    for (final s in slots) {
      if (s.id == 'snack') return s;
    }
  }

  SlotDef? best;
  for (final s in slots) {
    if (best == null || (s.order - now.hour).abs() < (best.order - now.hour).abs()) best = s;
  }
  return best;
}
