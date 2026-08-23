/// One record in the day, and the card it belongs to.
library;

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
  });

  final String id;
  final FoodIcon icon;
  final String title;

  /// "08:20". A string because it is only ever displayed and compared.
  final String time;

  /// Points at a [SlotDef] on the day, not at a fixed enum: cards are opened and
  /// renamed while the day runs.
  final String slotId;

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
