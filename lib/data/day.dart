/// The day, and the week around it.
///
/// **A day is an offset from today, never a day of the month.** Zero is today,
/// negative is the past, and there is no future: a day that has not happened has
/// nothing to log and nothing to show. Numbering by the calendar meant every
/// fixture broke on the first of the month.
library;

import 'meal.dart';
import 'workout.dart';

/// What a day is measured against. One norm, not one per screen.
class DayGoal {
  const DayGoal({
    required this.kcal,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.waterMl,
  });

  final int kcal;
  final int protein;
  final int fat;
  final int carbs;
  final int waterMl;
}

/// Consecutive days finished inside the norm.
const streak = 12;

/// Everything logged on one day, plus which cards it carries.
class DayModel {
  const DayModel({
    required this.slots,
    required this.meals,
    this.workouts = const [],
    this.waterMl = 0,
  });

  /// Cards, in the order they belong to the day. Not a fixed set of four: the
  /// assistant opens and renames them, so a day owns its own list.
  final List<SlotDef> slots;
  final List<Meal> meals;
  final List<Workout> workouts;
  final int waterMl;

  /// Calories spent on training. They come back into the norm, so this is a
  /// figure derived from the sessions rather than stored beside them: two places
  /// to write the same number is one place to get it wrong.
  int get burned => workouts.fold<int>(0, (s, w) => s + w.kcal);

  DayTotals get totals {
    var kcal = 0, protein = 0, fat = 0, carbs = 0;
    for (final m in meals) {
      kcal += m.kcal;
      protein += m.protein;
      fat += m.fat;
      carbs += m.carbs;
    }
    return DayTotals(kcal: kcal, protein: protein, fat: fat, carbs: carbs);
  }

  /// Meals of one card, earliest first.
  List<Meal> inSlot(String slotId) {
    final out = meals.where((m) => m.slotId == slotId).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    return out;
  }

  /// Cards in the order the day was actually lived, not in the order a
  /// breakfast is supposed to happen: a snack logged at half nine belongs below
  /// a dinner logged at eight, whatever the card is called.
  List<SlotDef> get ordered {
    final out = [...slots];
    out.sort((a, b) {
      final ea = inSlot(a.id).firstOrNull?.time;
      final eb = inSlot(b.id).firstOrNull?.time;
      if (ea != null && eb != null) return ea.compareTo(eb);
      if (ea != null) return -1;
      if (eb != null) return 1;
      return a.order.compareTo(b.order);
    });
    return out;
  }
}

class DayTotals {
  const DayTotals({
    required this.kcal,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  final int kcal;
  final int protein;
  final int fat;
  final int carbs;
}

/// How a day reads in the strip.
enum DayState {
  /// Inside the norm.
  ok,

  /// Over it.
  over,

  /// Nothing logged. Dashed, and no verdict.
  empty,
}

/// Where the fixtures are anchored, so a forecast does not drift under a
/// screenshot taken a week later.
final _anchor = DateTime(2026, 8, 15);

const _weekdays = ['НД', 'ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ'];
const _months = [
  'січня',
  'лютого',
  'березня',
  'квітня',
  'травня',
  'червня',
  'липня',
  'серпня',
  'вересня',
  'жовтня',
  'листопада',
  'грудня',
];

class DayInfo {
  const DayInfo({required this.day, required this.label, required this.full});

  /// Day of the month, for the strip.
  final int day;

  /// Two letters, as the strip prints them: «ПН», «ВТ».
  final String label;

  /// «15 серпня», for anywhere a date is spelled out.
  final String full;
}

DayInfo dayInfo(int offset) {
  final d = _anchor.add(Duration(days: offset));
  return DayInfo(
    day: d.day,
    label: _weekdays[d.weekday % 7],
    full: '${d.day} ${_months[d.month - 1]}',
  );
}

/// Today is the origin.
const todayDate = 0;

/// How far back the strip goes. Eighteen weeks is enough to scroll into and not
/// so much that the list becomes a year of empty circles.
const historyDays = 18 * 7;

/// The seven days ending today, which is the window analytics counts over.
List<int> get weekDates => List.generate(7, (i) => i - 6);

/// Offset of the Monday that opens the week [offset] falls in.
int mondayOf(int offset) {
  final d = _anchor.add(Duration(days: offset));
  return offset - ((d.weekday + 6) % 7);
}

/// The run of days the strip shows, oldest first.
///
/// It ends on the Sunday that closes the current week rather than on today: a
/// week that stops mid-row reads as a week with days missing, and the days ahead
/// are simply empty, which is what they are.
List<int> get stripRun {
  final last = mondayOf(todayDate) + 6;
  return List.generate(historyDays + 1, (i) => last - historyDays + i);
}
