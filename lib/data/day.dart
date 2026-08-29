/// The day, and the week around it.
///
/// **A day is an offset from today, never a day of the month.** Zero is today,
/// negative is the past, and there is no future: a day that has not happened has
/// nothing to log and nothing to show. Numbering by the calendar meant every
/// fixture broke on the first of the month.
library;

import 'package:flutter/foundation.dart';

import 'meal.dart';
import 'settings.dart';
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

/// Наскільки можна промахнутись повз норму, і день усе одно вдалий.
///
/// Набрати рівно норму неможливо, тому це вікно, а не число. Ширина в кожної
/// цілі своя, і несиметрична навмисно: тому, хто набирає, перебір допомагає, а
/// тому, хто худне, недобір не шкодить настільки ж.
///
/// Вихід за вікно з будь-якого боку це невдалий день. Недоїсти на тисячу це не
/// успіх худнення, а голодування, і рахувати його як успіх означало б хвалити
/// за нього.
({int under, int over}) _window(Direction d) => switch (d) {
  Direction.lose => (under: 300, over: 0),
  Direction.keep => (under: 300, over: 300),
  Direction.gain => (under: 0, over: 500),
};

/// Чи день закінчився всередині вікна своєї цілі.
bool dayHit({required int kcal, required int norm, required Direction direction}) {
  final w = _window(direction);
  return kcal >= norm - w.under && kcal <= norm + w.over;
}

/// Чи день уже вийшов за верхню межу вікна.
///
/// Питання не те саме, що [dayHit], і різниця в часі. Перебір необоротний: те,
/// що зʼїдено, не роззʼїдається, і день, який перебрав об одинадцятій ранку,
/// уже не стане вдалим до вечора. Недобір оборотний: до півночі ще можна доїсти.
///
/// Саме тому сьогоднішній день уміє серію обірвати, але не вміє її подовжити.
bool dayOver({required int kcal, required int norm, required Direction direction}) =>
    kcal > norm + _window(direction).over;

/// Everything logged on one day, plus which cards it carries.
class DayModel {
  const DayModel({
    required this.slots,
    required this.meals,
    this.workouts = const [],
    this.waterMl = 0,
    this.medTakes = const {},
  });

  /// Cards, in the order they belong to the day. Not a fixed set of four: the
  /// assistant opens and renames them, so a day owns its own list.
  final List<SlotDef> slots;
  final List<Meal> meals;
  final List<Workout> workouts;
  final int waterMl;

  /* Прийняті дози цього дня, парами «препарат|година».
   *
   * Галочка належить дню, а не препарату. Доти вона бралася з самого препарату,
   * а той завантажувався один раз на сьогодні, тому будь-яка інша дата
   * показувала сьогоднішні галочки: людина закривала ранковий прийом і бачила
   * «прийнято» в кожному дні тижня, зокрема в майбутніх. */
  final Set<String> medTakes;

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

  /// Картки в порядку дня.
  ///
  /// Сніданок, обід і вечеря стоять на своїх місцях завжди, порожні вони чи ні.
  /// Тут довго сортувалось за часом першого запису, і від цього день
  /// перебудовувався під людиною: «додай в обід шашлик» на порожньому сніданку
  /// піднімало обід угору, і картка, яку щойно шукали очима внизу, опинялась
  /// зверху. Каркас дня має стояти нерухомо, інакше кожен запис доводиться
  /// шукати заново.
  ///
  /// Рухаються тільки картки поза цим каркасом: перекус, доданий о пів на
  /// десяту, лягає під вечерею, а зʼїдений об одинадцятій ранку між сніданком і
  /// обідом. У них немає своєї години, тому її дає перший запис.
  List<SlotDef> get ordered {
    double at(SlotDef s) {
      if (alwaysSlots.contains(s.id)) return s.order.toDouble();

      // Час запису це «21:30», рядком, як він і показується на картці.
      final clock = inSlot(s.id).firstOrNull?.time.split(':');
      if (clock == null) return s.order.toDouble();

      final h = int.tryParse(clock.first);
      if (h == null) return s.order.toDouble();

      final m = clock.length > 1 ? int.tryParse(clock[1]) ?? 0 : 0;
      return h + m / 60;
    }

    final out = [...slots];
    out.sort((a, b) {
      final byHour = at(a).compareTo(at(b));
      return byHour != 0 ? byHour : a.order.compareTo(b.order);
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

  /// Нижче за норму настільки, що це вже голод, а не дефіцит.
  under,

  /// День ще триває. Вироку немає і бути не може: о першій дня будь-хто
  /// «недоїв», і фарбувати це червоним означає лаяти людину за те, що вона ще
  /// не повечеряла.
  pending,

  /// Nothing logged. Dashed, and no verdict.
  empty,
}

/* Наскільки нижче норми ще можна опуститись і лишитись у зеленому.
 *
 * Дефіцит уже закладений у саму норму, тому ці чотириста це запас на живу
 * людину: пропущений перекус, менша порція, день без апетиту. Усе, що глибше,
 * це вже не план, а голодування, і кружечок не має його схвалювати. */
const kcalSlack = 400;

/// Як день читається в стрічці.
///
/// Правило залежить від того, куди людина йде, і це головне в ньому:
///
///   * **набір ваги**: норма або більше це зелений: з'їсти більше за ціль тут
///     не помилка, а власне ціль;
///   * **схуднення**: зелений лише від «норма мінус [kcalSlack]» до самої
///     норми. Вище означає, що дефіциту не вийшло, нижче означає голод, і обидва
///     випадки червоні;
///   * **утримання**: той самий запас, але в обидва боки.
///
/// День без записів не оцінюється взагалі: порожній кружечок це не вирок.
DayState verdictFor({
  required int eaten,
  required int norm,
  required Direction direction,
  bool logged = true,

  /// Минулий день оцінюють цілком; сьогоднішній ще ні.
  bool finished = true,
}) {
  if (!logged || eaten <= 0) return DayState.empty;

  final ceiling = direction == Direction.lose ? norm : norm + kcalSlack;
  // Перебрати можна й до вечора, і це вже факт, а не прогноз.
  if (direction != Direction.gain && eaten > ceiling) return DayState.over;
  if (!finished) return DayState.pending;

  return switch (direction) {
    Direction.gain => eaten >= norm ? DayState.ok : DayState.under,
    _ => eaten < norm - kcalSlack ? DayState.under : DayState.ok,
  };
}

/* --- Сьогодні ---
 *
 * Тут стояло `DateTime(2026, 8, 15)`, щоб числа під знімками екрана не пливли,
 * поки застосунок малювався. Ціна виявилась непомірною, і не тільки на вигляд.
 *
 * Стрічка днів завмерла на пʼятнадцятому серпні назавжди, а це ще півбіди.
 * Гірше те, що записи лягають у базу за справжнім годинником: страва, з'їдена
 * вісімнадцятого, отримувала день `2026-08-18`, а екран питав базу про
 * `2026-08-15` і не знаходив нічого. Людина записувала сніданок і бачила
 * порожній день. */

/// Звідки береться «сьогодні».
///
/// Підміняється тільки в тестах, і саме для того, щоб дата в них стояла на
/// місці: перевірка, яка падає опівночі, це перевірка, якій перестають вірити.
@visibleForTesting
DateTime Function() dayClock = DateTime.now;

/// Котра зараз година, за тим самим годинником, що й дати.
///
/// Окремо від [dayClock], бо той підміняють лише тести, а година потрібна і
/// застосунку: за нею він вирішує, який прийом їжі пропонувати наступним. Доти
/// екран питав системний час напряму і лишався єдиним місцем, яке закріплений
/// годинник не діставав.
int get nowHour => dayClock().hour;

/// Сьогодні, обрізане до дати.
///
/// Обчислюється щоразу, а не один раз при запуску: телефон, залишений
/// увімкненим через північ, має побачити новий день сам, без перезапуску.
DateTime get _anchor {
  final now = dayClock();
  return DateTime(now.year, now.month, now.day);
}

/* Мова, якою шар даних пише дати.
 *
 * Глобальна, як і [dayClock], і рівно з тієї ж причини: назви місяців потрібні
 * там, куди `BuildContext` не дістає, і тягнути його в сховище, у сповіщення і
 * в тести заради двох слів дорожче, ніж одне поле.
 *
 * Ставить її `main` при кожній зміні локалі. Стандартом лишається українська:
 * якщо ніхто нічого не поставив, дати виглядають так само, як виглядали. */
String dataLang = 'uk';

const _weekdaysUk = ['НД', 'ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ'];
const _weekdaysEn = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

/* Родовий відмінок: «15 серпня», а не «15 серпень». Місяць тут ніколи не
   стоїть сам, він завжди після числа. */
const _monthsUk = [
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

const _monthsEn = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

List<String> get _months => dataLang == 'uk' ? _monthsUk : _monthsEn;
List<String> get _weekdays => dataLang == 'uk' ? _weekdaysUk : _weekdaysEn;

/// Назва місяця так, як вона стоїть у даті: «серпня», «August».
String monthName(int month) => _months[month - 1];

/// Скорочення днів тижня від понеділка: «ПН…НД», «MON…SUN».
///
/// Смуга тижня бере їх за номером дня, тобто від неділі, а заставка запуску
/// малює тиждень таким, яким його читають, тобто від понеділка. Порядок тут
/// перекладається один раз, щоб не було двох різних уявлень про те, з чого
/// починається тиждень.
///
/// [lang] можна передати прямо, і заставка так і робить. Глобальний [dataLang]
/// виставляє `main` усередині `home`, тобто **нижче** в дереві, ніж стоїть
/// заставка: на найпершому кадрі його там ще може не бути, і англійський телефон
/// блимнув би українськими днями. Мова, взята з контексту, від порядку побудови
/// не залежить взагалі.
List<String> weekdaysFromMonday([String? lang]) {
  final week = (lang ?? dataLang) == 'uk' ? _weekdaysUk : _weekdaysEn;
  return [...week.skip(1), week.first];
}

const _shortUk = [
  'січ',
  'лют',
  'бер',
  'квіт',
  'трав',
  'черв',
  'лип',
  'серп',
  'вер',
  'жовт',
  'лист',
  'груд',
];

/// Скорочений місяць, для рядків, де на повний немає місця.
String monthShort(int month) =>
    dataLang == 'uk' ? _shortUk[month - 1] : _monthsEn[month - 1].substring(0, 3);

class DayInfo {
  const DayInfo({required this.day, required this.label, required this.full});

  /// Day of the month, for the strip.
  final int day;

  /// Two letters, as the strip prints them: «ПН», «ВТ».
  final String label;

  /// «15 серпня», for anywhere a date is spelled out.
  final String full;
}

/// Дата коротко, «31.05», для осей графіків.
///
/// На періодах довших за тиждень колонка це не один день, і назвати її двома
/// літерами дня тижня нема як. Стояло саме число дня («31», «13»), і сім таких
/// чисел під графіком не казали ні місяця, ні року: підпис був, а дати не було.
String shortDate(int offset) {
  final d = calendarDay(offset);
  return '${d.day}.${d.month.toString().padLeft(2, '0')}';
}

DayInfo dayInfo(int offset) {
  final d = calendarDay(offset);
  return DayInfo(
    day: d.day,
    label: _weekdays[d.weekday % 7],
    full: '${d.day} ${_months[d.month - 1]}',
  );
}

/// The calendar day an offset points at.
///
/// The screens count days as offsets from today, and the database files rows by
/// the local calendar. This is the one place the two meet, so a mistake here is
/// a mistake in one place.
///
/// Дні додаються конструктором, а не як [Duration]. Тривалість це абсолютні
/// години, а доба буває на годину довшою: в ніч переходу на зимовий час доба
/// плюс двадцять чотири години це двадцять третя того самого дня, і число
/// виходить на одиницю меншим. Раз на рік, зате в усій стрічці одразу.
DateTime calendarDay(int offset) => DateTime(_anchor.year, _anchor.month, _anchor.day + offset);

/// Today is the origin.
const todayDate = 0;

/// How far back the strip goes. Eighteen weeks is enough to scroll into and not
/// so much that the list becomes a year of empty circles.
const historyDays = 18 * 7;

/// The seven days ending today, which is the window analytics counts over.
List<int> get weekDates => List.generate(7, (i) => i - 6);

/// Offset of the Monday that opens the week [offset] falls in.
int mondayOf(int offset) => offset - ((calendarDay(offset).weekday + 6) % 7);

/// The run of days the strip shows, oldest first.
///
/// It ends on the Sunday that closes the current week rather than on today: a
/// week that stops mid-row reads as a week with days missing, and the days ahead
/// are simply empty, which is what they are.
List<int> get stripRun {
  final last = mondayOf(todayDate) + 6;
  return List.generate(historyDays + 1, (i) => last - historyDays + i);
}
