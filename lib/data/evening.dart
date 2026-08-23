/// Вечірнє питання: що сьогодні лишилось незаписаним.
///
/// Записує людина, а забуває теж людина, і найчастіше ввечері: вечеря з'їдена,
/// день закритий, а в застосунку його половина. Наступного ранку цю діру вже не
/// закрити, бо ніхто не памʼятає, скільки було води в четвер.
///
/// Тому питання не завчене, а порахованe з самого дня: питати «як минув день» у
/// того, хто все записав, означає навчити людину змахувати сповіщення не
/// читаючи. Питання ставиться тільки тоді, коли в дні справді чогось бракує, і
/// каже рівно, чого саме.
library;

import '../l10n/data_lang.dart';
import 'day.dart';
import 'meal.dart';

/// Скільки води від норми вважається «майже все». Нижче за це варто спитати.
const _enoughWater = 0.75;

/* Назва картки в тому відмінку, який потрібен питанню.
 *
 * Без цього питання звучить як машинний переклад: «записала вечеря» замість
 * «записала вечерю». Підпис картки тут не годиться, він називний. В англійській
 * відмінка немає, і той самий рядок працює в обох місцях. */
String _slotName(String id) => switch (id) {
  'breakfast' => dataL.eveningBreakfastAcc,
  'lunch' => dataL.eveningLunchAcc,
  'dinner' => dataL.eveningDinnerAcc,
  _ => id,
};

/// Що спитати ввечері. Порожньо означає, що питати нема про що.
String? eveningAsk({required DayModel day, required DayGoal goal}) {
  final missing = <String>[];

  /* Порожній день не розбирають по частинах: питати про вечерю в того, хто не
     записав нічого, означає підказати найменшу з його турбот. */
  if (day.meals.isEmpty) {
    return dataL.eveningEmptyDay;
  }

  for (final id in alwaysSlots) {
    if (day.inSlot(id).isEmpty) missing.add(id);
  }

  final thirsty = goal.waterMl > 0 && day.waterMl < goal.waterMl * _enoughWater;

  if (missing.isEmpty && !thirsty) return null;

  /* Одне питання, а не список. Три питання поспіль на ніч це анкета, і людина
     відповість на перше, а решту закриє. */
  if (missing.isEmpty) {
    return dataL.eveningWater;
  }

  if (missing.length == 1) return dataL.eveningLogged(_slotName(missing.single));

  final names = [for (final id in missing) _slotName(id)];
  final what = names.take(names.length - 1).join(', ') + dataL.eveningAnd + names.last;
  return dataL.eveningMissing(what);
}
