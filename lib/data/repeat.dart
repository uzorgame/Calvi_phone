/// Як часто щось повторюється: нагадування або прийом препарату.
///
/// Одна модель на двох, бо питання одне й те саме. Ліки бувають «через день» і
/// «по понеділках і четвергах» так само, як нагадування про зважування, і два
/// різні описи однієї речі неминуче розійшлись би: у препаратах зʼявився б
/// інтервал, у нагадуваннях дні тижня, і людина мала б тримати в голові, де що
/// можна.
///
/// Три випадки покривають майже все, що люди кажуть уголос, і жоден не потребує
/// пояснень: щодня, по днях тижня, через N днів. Складніших схем («два тижні
/// пити, тиждень пауза») тут навмисно немає: вони трапляються рідко, а поле для
/// них ускладнює екран для всіх. Коли така потреба зʼявиться, це буде четвертий
/// випадок, а не підкручений третій.
library;

import '../l10n/data_lang.dart';

sealed class Repeat {
  const Repeat();
}

class DailyRepeat extends Repeat {
  const DailyRepeat();
}

/// Дні тижня: 1 понеділок … 7 неділя. Порожній список означає щодня.
class WeekdayRepeat extends Repeat {
  const WeekdayRepeat({required this.days});

  final List<int> days;
}

/// Кожен N-й день, рахуючи від [from]. [every] завжди більше одиниці.
class IntervalRepeat extends Repeat {
  const IntervalRepeat({required this.every, required this.from});

  final int every;

  /// День, з якого починається відлік, ключем «РРРР-ММ-ДД».
  final String from;
}

/// Підписи днів у тому порядку, у якому їх читають: з понеділка.
List<String> get weekdayShort => [
  dataL.wdMon,
  dataL.wdTue,
  dataL.wdWed,
  dataL.wdThu,
  dataL.wdFri,
  dataL.wdSat,
  dataL.wdSun,
];

/// Чи випадає це на конкретний день.
bool fallsOn(Repeat r, DateTime date) => switch (r) {
  DailyRepeat() => true,
  WeekdayRepeat(:final days) => days.isEmpty || days.contains(date.weekday),
  IntervalRepeat(:final every, :final from) => _hits(from, every, date),
};

bool _hits(String from, int every, DateTime date) {
  final parts = from.split('-');
  if (parts.length != 3) return true;

  final start = DateTime(
    int.tryParse(parts[0]) ?? date.year,
    int.tryParse(parts[1]) ?? date.month,
    int.tryParse(parts[2]) ?? date.day,
  );
  final gap = DateTime(date.year, date.month, date.day).difference(start).inDays;

  // До дня початку нічого не спрацьовує: розклад «через день» із завтрашнього
  // дня не має спрацювати вчора.
  return gap >= 0 && gap % (every < 2 ? 2 : every) == 0;
}

/// Як це називається одним рядком у списку.
///
/// Коротко, бо стоїть поруч із часом: «Пн, Ср, Пт» читається з одного погляду, а
/// «по понеділках, середах і пʼятницях» на картці не поміщається.
String repeatLabel(Repeat r) {
  switch (r) {
    case DailyRepeat():
      return dataL.repDaily;

    case WeekdayRepeat(:final days):
      if (days.isEmpty || days.length == 7) return dataL.repDaily;
      if (days.length == 5 && [1, 2, 3, 4, 5].every(days.contains)) return dataL.repWeekdays;
      if (days.length == 2 && days.contains(6) && days.contains(7)) return dataL.repWeekends;

      final order = [...days]..sort();
      final names = weekdayShort;
      return order.map((d) => names[d - 1]).join(', ');

    case IntervalRepeat(:final every):
      if (every <= 1) return dataL.repDaily;
      if (every == 2) return dataL.repEveryOther;
      if (every == 7) return dataL.repWeekly;
      return dataL.repEveryN(every);
  }
}

/// Сьогоднішня дата ключем, з якого починається відлік інтервалу.
String todayKey() {
  final d = DateTime.now();
  return '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
