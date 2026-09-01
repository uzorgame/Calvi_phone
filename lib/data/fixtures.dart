/// The demo week, carried over so the screens have something true to sit on.
///
/// Fixtures, not a database. They go when the local store lands, but until then
/// a screen built against empty state is a screen nobody can judge.
library;

import 'day.dart';
import 'settings.dart';
import 'meal.dart';
import 'workout.dart';

/// The norm the strip judges a fixture day against.
///
/// The screens read the person's own norm out of the settings; this one exists
/// so a day in the run can be green or red before anybody has opened settings,
/// and so the fixtures mean the same thing from one session to the next.
const fixtureGoal = DayGoal(kcal: 2380, protein: 135, fat: 66, carbs: 311, waterMl: 2200);

/* Назва показової страви двома мовами.
 *
 * Демо-день це вітрина, і дивиться на неї людина, яка ще не зробила жодного
 * свого запису. Українські назви в англійському інтерфейсі читаються там не як
 * чужа мова, а як поламаний застосунок.
 *
 * Тут, а не в ARB: це дані, а не напис. Назва їде далі в модель страви, у
 * підсумки і в аналітику, і жодне з тих місць про переклад не знає. */
String demoDish(String uk, String en) => dataLang == 'uk' ? uk : en;

SlotDef _s(String id) => baseSlots[id]!;

/// Every day the fixtures know, for anything that reads across the history.
final allDays = <int, DayModel>{
  -5: DayModel(
    slots: [_s('breakfast'), _s('lunch'), _s('dinner')],
    meals: [
      Meal(
        id: 'a1',
        icon: 'egg',
        title: demoDish('Омлет із двох яєць', 'Two-egg omelette'),
        time: '08:40',
        slotId: 'breakfast',
        grams: 180,
        kcal: 286,
        protein: 19,
        fat: 21,
        carbs: 3,
      ),
      Meal(
        id: 'a2',
        icon: 'soup',
        title: demoDish('Курячий суп', 'Chicken soup'),
        time: '13:10',
        slotId: 'lunch',
        grams: 350,
        kcal: 320,
        protein: 22,
        fat: 11,
        carbs: 30,
      ),
      Meal(
        id: 'a3',
        icon: 'meat',
        title: demoDish('Індичка з рисом', 'Turkey with rice'),
        time: '19:20',
        slotId: 'dinner',
        grams: 320,
        kcal: 540,
        protein: 44,
        fat: 12,
        carbs: 62,
      ),
      Meal(
        id: 'a4',
        icon: 'pancake',
        title: demoDish('Сирники', 'Cheese pancakes'),
        time: '16:20',
        slotId: 'snack',
        grams: 180,
        kcal: 396,
        protein: 21,
        fat: 18,
        carbs: 36,
      ),
      Meal(
        id: 'a5',
        icon: 'nuts',
        title: demoDish('Горіхи волоські', 'Walnuts'),
        time: '11:10',
        slotId: 'snack',
        grams: 45,
        kcal: 294,
        protein: 7,
        fat: 29,
        carbs: 4,
      ),
      Meal(
        id: 'a6',
        icon: 'pasta',
        title: demoDish('Паста з куркою', 'Pasta with chicken'),
        time: '20:10',
        slotId: 'dinner',
        grams: 320,
        kcal: 596,
        protein: 34,
        fat: 18,
        carbs: 72,
      ),
    ],
    workouts: [
      Workout(id: 'w1', activity: 'run', title: 'Біг', minutes: 34, kcal: 310, time: '07:20'),
    ],
    waterMl: 1800,
  ),
  -4: DayModel(
    slots: [_s('breakfast'), _s('lunch'), _s('dinner')],
    meals: [
      Meal(
        id: 'b1',
        icon: 'grain',
        title: demoDish('Вівсянка з бананом', 'Porridge with banana'),
        time: '08:15',
        slotId: 'breakfast',
        grams: 260,
        kcal: 340,
        protein: 11,
        fat: 7,
        carbs: 61,
      ),
      Meal(
        id: 'b2',
        icon: 'fish',
        title: demoDish('Лосось і салат', 'Salmon and salad'),
        time: '13:40',
        slotId: 'lunch',
        grams: 300,
        kcal: 470,
        protein: 38,
        fat: 26,
        carbs: 14,
      ),
      Meal(
        id: 'b3',
        icon: 'dairy',
        title: demoDish('Сир із медом', 'Cottage cheese with honey'),
        time: '20:05',
        slotId: 'dinner',
        grams: 200,
        kcal: 290,
        protein: 32,
        fat: 9,
        carbs: 20,
      ),
      Meal(
        id: 'b4',
        icon: 'chicken',
        title: demoDish('Куряча грудка', 'Chicken breast'),
        time: '19:00',
        slotId: 'dinner',
        grams: 220,
        kcal: 302,
        protein: 56,
        fat: 7,
        carbs: 0,
      ),
      Meal(
        id: 'b5',
        icon: 'dumpling',
        title: demoDish('Вареники з сиром', 'Dumplings with cheese'),
        time: '13:20',
        slotId: 'lunch',
        grams: 260,
        kcal: 533,
        protein: 22,
        fat: 17,
        carbs: 70,
      ),
      Meal(
        id: 'b6',
        icon: 'fruit',
        title: demoDish('Банан', 'Banana'),
        time: '16:30',
        slotId: 'snack',
        grams: 130,
        kcal: 125,
        protein: 1,
        fat: 0,
        carbs: 32,
      ),
    ],
    waterMl: 2400,
  ),
  // The day that went over: the strip shows this one red.
  -3: DayModel(
    slots: [_s('breakfast'), _s('lunch'), _s('dinner'), _s('snack')],
    meals: [
      Meal(
        id: 'c1',
        icon: 'bread',
        title: demoDish('Тост з авокадо', 'Avocado toast'),
        time: '09:00',
        slotId: 'breakfast',
        grams: 210,
        kcal: 420,
        protein: 12,
        fat: 24,
        carbs: 40,
      ),
      Meal(
        id: 'c2',
        icon: 'meat',
        title: demoDish('Бургер і картопля', 'Burger and chips'),
        time: '14:20',
        slotId: 'lunch',
        grams: 480,
        kcal: 980,
        protein: 41,
        fat: 48,
        carbs: 92,
      ),
      Meal(
        id: 'c3',
        icon: 'sweet',
        title: demoDish('Тістечко', 'A pastry'),
        time: '17:10',
        slotId: 'snack',
        grams: 120,
        kcal: 430,
        protein: 5,
        fat: 22,
        carbs: 54,
      ),
      Meal(
        id: 'c4',
        icon: 'plate',
        title: demoDish('Паста карбонара', 'Pasta carbonara'),
        time: '20:40',
        slotId: 'dinner',
        grams: 340,
        kcal: 690,
        protein: 26,
        fat: 31,
        carbs: 74,
      ),
    ],
    waterMl: 1200,
  ),
  -2: DayModel(
    slots: [_s('breakfast'), _s('lunch'), _s('dinner')],
    meals: [
      Meal(
        id: 'd1',
        icon: 'egg',
        title: demoDish('Яєчня і кава', 'Fried eggs and coffee'),
        time: '08:05',
        slotId: 'breakfast',
        grams: 190,
        kcal: 300,
        protein: 20,
        fat: 22,
        carbs: 4,
      ),
      Meal(
        id: 'd2',
        icon: 'grain',
        title: demoDish('Гречка з куркою', 'Buckwheat with chicken'),
        time: '13:25',
        slotId: 'lunch',
        grams: 380,
        kcal: 520,
        protein: 42,
        fat: 14,
        carbs: 58,
      ),
    ],
    workouts: [
      Workout(
        id: 'w2',
        activity: 'gym',
        title: demoDish('Зал', 'Gym'),
        minutes: 62,
        kcal: 445,
        time: '18:00',
      ),
    ],
    waterMl: 2600,
  ),
  -1: DayModel(
    slots: [_s('breakfast'), _s('lunch'), _s('dinner')],
    meals: [
      Meal(
        id: 'e1',
        icon: 'dairy',
        title: demoDish('Йогурт з ягодами', 'Yoghurt with berries'),
        time: '08:30',
        slotId: 'breakfast',
        grams: 220,
        kcal: 240,
        protein: 18,
        fat: 6,
        carbs: 28,
      ),
      Meal(
        id: 'e2',
        icon: 'vegetable',
        title: demoDish('Салат з тунцем', 'Tuna salad'),
        time: '13:50',
        slotId: 'lunch',
        grams: 320,
        kcal: 380,
        protein: 30,
        fat: 18,
        carbs: 22,
      ),
      Meal(
        id: 'e3',
        icon: 'meat',
        title: demoDish('Стейк і овочі', 'Steak and vegetables'),
        time: '19:35',
        slotId: 'dinner',
        grams: 360,
        kcal: 620,
        protein: 48,
        fat: 34,
        carbs: 18,
      ),
      Meal(
        id: 'e4',
        icon: 'fish',
        title: demoDish('Лосось запечений', 'Baked salmon'),
        time: '19:30',
        slotId: 'dinner',
        grams: 200,
        kcal: 412,
        protein: 40,
        fat: 26,
        carbs: 0,
      ),
      Meal(
        id: 'e5',
        icon: 'yogurt',
        title: demoDish('Йогурт грецький', 'Greek yoghurt'),
        time: '10:40',
        slotId: 'snack',
        grams: 200,
        kcal: 148,
        protein: 17,
        fat: 4,
        carbs: 11,
      ),
      Meal(
        id: 'e6',
        icon: 'bread',
        title: demoDish('Тост із авокадо', 'Avocado toast'),
        time: '08:50',
        slotId: 'breakfast',
        grams: 140,
        kcal: 268,
        protein: 6,
        fat: 16,
        carbs: 24,
      ),
    ],
    waterMl: 2200,
  ),
  // Today. Dinner is deliberately empty: the card stands anyway.
  0: DayModel(
    slots: [_s('breakfast'), _s('lunch'), _s('dinner')],
    meals: [
      Meal(
        id: 'f1',
        icon: 'egg',
        title: demoDish('Яєчня з двох яєць', 'Two fried eggs'),
        time: '08:20',
        slotId: 'breakfast',
        grams: 160,
        kcal: 214,
        protein: 14,
        fat: 16,
        carbs: 2,
      ),
      Meal(
        id: 'f2',
        icon: 'drink',
        title: demoDish('Кава з молоком', 'Coffee with milk'),
        time: '08:35',
        slotId: 'breakfast',
        grams: 200,
        kcal: 64,
        protein: 3,
        fat: 3,
        carbs: 6,
      ),
      Meal(
        id: 'f3',
        icon: 'soup',
        title: demoDish('Борщ з куркою', 'Borscht with chicken'),
        time: '13:05',
        slotId: 'lunch',
        grams: 300,
        kcal: 210,
        protein: 14,
        fat: 8,
        carbs: 20,
      ),
      Meal(
        id: 'f4',
        icon: 'bread',
        title: demoDish('Хліб житній', 'Rye bread'),
        time: '13:12',
        slotId: 'lunch',
        grams: 60,
        kcal: 136,
        protein: 5,
        fat: 1,
        carbs: 26,
      ),
    ],
    workouts: [
      Workout(
        id: 'w4',
        activity: 'bike',
        title: demoDish('Велосипед', 'Cycling'),
        minutes: 42,
        kcal: 310,
        time: '17:30',
      ),
    ],
    waterMl: 900,
  ),
};

/// A day with nothing in it still has its three cards.
DayModel dayFor(int date) =>
    allDays[date] ?? DayModel(slots: alwaysSlots.map(_s).toList(), meals: []);

/// Whether the fixtures know anything about this day at all.
bool hasDay(int date) => allDays.containsKey(date);

/// Демонстраційний день за тим самим правилом, що й справжній.
DayState stateFor(int date, {Direction direction = Direction.lose}) {
  final d = dayFor(date);
  return verdictFor(
    eaten: d.totals.kcal,
    burned: d.burned,
    norm: fixtureGoal.kcal,
    direction: direction,
    logged: hasDay(date),
    finished: date < 0,
  );
}

/// Weight, until the tape and the profile are wired up.
const profileWeightKg = 78.6;
const goalStartKg = 81.0;
const targetKg = 74.0;

/// The seven days the analytics screen counts over, oldest first.
List<({int date, String label})> get weekRows => [
  for (final d in weekDates) (date: d, label: dayInfo(d).label),
];

/// Totals of one day, zero for a day with nothing in it.
DayTotals totalsFor(int date) => dayFor(date).totals;

/// One column of a chart: the days it covers and what to write under it.
class DayBucket {
  const DayBucket({required this.label, required this.dates});

  final String label;
  final List<int> dates;
}

/// Splits a window of days into about seven columns.
///
/// A week gets a column a day and weekday letters under it. Anything longer is
/// grouped, because three hundred and sixty five bars is a texture, not a chart,
/// and the label then names the day the group opens on.
///
/// The grouping is arithmetic rather than calendar months on purpose: months are
/// unequal, and a bar twice as wide as its neighbour reads as twice as much.
List<DayBucket> bucketDays(int days) {
  const columns = 7;
  final size = (days / columns).ceil();
  final out = <DayBucket>[];

  for (var i = columns - 1; i >= 0; i--) {
    final last = -i * size;
    final dates = [for (var d = last - size + 1; d <= last; d++) d];
    final opens = dates.first;
    out.add(
      /* Колонка ширша за добу підписується датою свого початку, а не самим
         числом дня: «13» під стовпчиком не каже ні місяця, ні того, що колонка
         взагалі про кілька днів. */
      DayBucket(label: size == 1 ? dayInfo(opens).label : shortDate(opens), dates: dates),
    );
  }
  return out;
}

/// Totals of a whole bucket.
DayTotals totalsOf(Iterable<int> dates) {
  var kcal = 0, protein = 0, fat = 0, carbs = 0;
  for (final d in dates) {
    final t = totalsFor(d);
    kcal += t.kcal;
    protein += t.protein;
    fat += t.fat;
    carbs += t.carbs;
  }
  return DayTotals(kcal: kcal, protein: protein, fat: fat, carbs: carbs);
}
