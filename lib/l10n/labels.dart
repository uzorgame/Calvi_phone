import 'package:flutter/widgets.dart';

import '../data/meal.dart';
import '../data/settings.dart';
import 'app_localizations.dart';

/// Назви для того, що приходить із даних, а не з екрана.
///
/// Шар даних не має знати про мову: він оперує кодами (`breakfast`, `lunch`), а
/// слово під ними живе тут. Інакше довелось би тягнути `BuildContext` у сховище,
/// у синхронізацію і в тести, які про переклад нічого не знають.

/// Назва картки прийому їжі.
///
/// Помічниця вміє перейменувати картку за фактичним часом: «снідав об 11» стає
/// «Пізній сніданок». Такий напис приходить з сервера її словами, і перекладати
/// його нема чим, тому він показується як є. Перекладаються тільки чотири
/// стандартні, і впізнаються вони за тим, що напис не мінявся.
String slotTitle(BuildContext context, SlotDef slot) {
  final base = baseSlots[slot.id];
  if (base == null || base.label != slot.label) return slot.label;

  final l = L.of(context);
  return switch (slot.id) {
    'breakfast' => l.slotBreakfast,
    'lunch' => l.slotLunch,
    'dinner' => l.slotDinner,
    'snack' => l.slotSnack,
    _ => slot.label,
  };
}

/// «Записала **в обід**»: назва картки разом із прийменником.
///
/// Цілою фразою, а не склеюванням, і це не примха. Українська відмінює іменник
/// після прийменника, а сам прийменник чергується для звучання: «в обід», але
/// «у вечерю». Складене в коді з «в» плюс назва, воно давало «Записала в
/// вечеря», і саме так це й виглядало на екрані.
///
/// Перейменовану помічницею картку відмінювати нема чим: її назва приходить її
/// словами. Тоді назву беруть у лапки, і речення обходиться без відмінка.
String slotInto(BuildContext context, SlotDef slot) {
  final l = L.of(context);
  final base = baseSlots[slot.id];
  if (base == null || base.label != slot.label) return l.slotIntoOther(slot.label);

  return switch (slot.id) {
    'breakfast' => l.slotIntoBreakfast,
    'lunch' => l.slotIntoLunch,
    'dinner' => l.slotIntoDinner,
    'snack' => l.slotIntoSnack,
    _ => l.slotIntoOther(slot.label),
  };
}

/// Те саме, коли на руках лише підпис картки, а не вона сама.
///
/// Половина шляхів через камеру носить із собою рядок, а не [SlotDef]. Підпис
/// стандартної картки це стала з `baseSlots`, і мовою інтерфейсу вона не
/// міняється: у шарі даних мови немає взагалі. Тому пошук за ним однаково
/// працює і в українському застосунку, і в англійському.
String slotIntoLabel(BuildContext context, String label) {
  for (final slot in baseSlots.values) {
    if (slot.label == label) return slotInto(context, slot);
  }
  return L.of(context).slotIntoOther(label);
}

/// Стать, однією літерою в рядку профілю.
String sexShort(BuildContext context, Sex s) {
  final l = L.of(context);
  return switch (s) {
    Sex.m => l.sexShortMale,
    Sex.f => l.sexShortFemale,
    Sex.x => l.sexOther,
  };
}

/// Рівень активності. Впізнається за множником, бо саме він і є рівнем.
String activityTitle(BuildContext context, double v) {
  final l = L.of(context);
  return switch (v) {
    < 1.3 => l.activitySedentary,
    < 1.45 => l.activityLight,
    < 1.65 => l.activityModerate,
    < 1.8 => l.activityHigh,
    _ => l.activityVeryHigh,
  };
}

String activityHint(BuildContext context, double v) {
  final l = L.of(context);
  return switch (v) {
    < 1.3 => l.activitySedentaryHint,
    < 1.45 => l.activityLightHint,
    < 1.65 => l.activityModerateHint,
    < 1.8 => l.activityHighHint,
    _ => l.activityVeryHighHint,
  };
}

String themeTitle(BuildContext context, AppTheme t) {
  final l = L.of(context);
  return switch (t) {
    AppTheme.light => l.themeLight,
    AppTheme.dark => l.themeDark,
    AppTheme.system => l.themeSystem,
  };
}

String themeHint(BuildContext context, AppTheme t) {
  final l = L.of(context);
  return switch (t) {
    AppTheme.light => l.themeLightHint,
    AppTheme.dark => l.themeDarkHint,
    AppTheme.system => l.themeSystemHint,
  };
}

/* Назви мов не перекладаються.
 *
 * «Українська» лишається «Українська» і в англійському застосунку, бо цей рядок
 * читає той, хто саме шукає свою мову в чужому інтерфейсі. Перекладена назва
 * ховає її від єдиної людини, якій вона потрібна. */
String langTitle(BuildContext context, Lang lang) => switch (lang) {
  Lang.system => L.of(context).langSystem,
  Lang.uk => 'Українська',
  Lang.en => 'English',
};

/// Про що нагадування. Назву самій людині вирішувати, це лише рід.
String reminderTitle(BuildContext context, ReminderKind kind) {
  final l = L.of(context);
  return switch (kind) {
    ReminderKind.meal => l.reminderMeal,
    ReminderKind.water => l.reminderWater,
    ReminderKind.meds => l.reminderMeds,
    ReminderKind.workout => l.reminderWorkout,
    ReminderKind.weigh => l.reminderWeigh,
    ReminderKind.summary => l.reminderSummary,
  };
}

String reminderHint(BuildContext context, ReminderKind kind) {
  final l = L.of(context);
  return switch (kind) {
    ReminderKind.meal => l.reminderMealHint,
    ReminderKind.water => l.reminderWaterHint,
    ReminderKind.meds => l.reminderMedsHint,
    ReminderKind.workout => l.reminderWorkoutHint,
    ReminderKind.weigh => l.reminderWeighHint,
    ReminderKind.summary => l.reminderSummaryHint,
  };
}
