/// One record in the day, and the card it belongs to.
library;

/// Which mark a row shows.
///
/// Not an emoji field. Emoji are drawn by the OS, so the same meal would look
/// one way on iOS and a noticeably worse way on most Android builds, and neither
/// would match the rest of the interface. These name marks in our own set.
enum FoodCategory {
  soup,
  bread,
  egg,
  drink,
  meat,
  vegetable,
  fruit,
  dairy,
  sweet,
  fish,
  grain,
  plate,
}

class Meal {
  const Meal({
    required this.id,
    required this.category,
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
  final FoodCategory category;
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
  const SlotDef({
    required this.id,
    required this.label,
    required this.order,
    required this.icon,
  });

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
