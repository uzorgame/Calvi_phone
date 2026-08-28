// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class LUk extends L {
  LUk([String locale = 'uk']) : super(locale);

  @override
  String get aboutContact => 'Звʼязок';

  @override
  String get aboutDeveloper => 'Розробник';

  @override
  String get aboutText =>
      'Щоденник харчування, який розуміє звичайні речення. Числа рахує помічниця Нора, рішення лишаються за тобою.';

  @override
  String get aboutTitle => 'Про застосунок';

  @override
  String get aboutVersion => 'Версія';

  @override
  String get aboutWrite => 'Написати нам';

  @override
  String get accountBusy => 'Заходимо…';

  @override
  String get accountGoogle => 'Продовжити з Google';

  @override
  String get accountKeepCloud => 'Той, що в акаунті';

  @override
  String get accountNoAccountNote =>
      'Щоденник живе тільки на цьому телефоні. Зміниш телефон або зітреш застосунок, і повернути записи не буде чим: ми не знаємо, чиї вони.';

  @override
  String get accountScopeNote =>
      'Ми просимо тільки пошту. Імені, фото профілю і контактів Google нам не передає.';

  @override
  String get accountSettingsDevice => 'налаштування';

  @override
  String get accountSignInFailed => 'Не вдалось увійти.';

  @override
  String accountSignInFailedWhy(String why) {
    return 'Не вдалось увійти. $why';
  }

  @override
  String get accountSignOut => 'Вийти';

  @override
  String get accountSignOutAction => 'Вийти з акаунта';

  @override
  String get accountSignOutAsk => 'Вийти з акаунта?';

  @override
  String get accountSignOutBack => 'Увійти тим самим акаунтом можна будь-коли, тут же.';

  @override
  String get accountSignOutNote =>
      'Записи лишаться на цьому телефоні: вихід не стирає щоденник. Зупиниться інше, синхронізація з іншими пристроями і можливість повернути дані, якщо телефон загубиться.';

  @override
  String get accountSince => 'З Calvi з';

  @override
  String get accountTitle => 'Обліковий запис';

  @override
  String get accountVia => 'Вхід через Google';

  @override
  String get accountViaApple => 'Вхід через Apple';

  @override
  String get accountWhichDiary => 'Який щоденник лишаємо?';

  @override
  String get accountWhichDiaryNote =>
      'У цьому акаунті вже є записи, і на телефоні теж. Лишити можна тільки один: той, що в акаунті, або той, що на телефоні. Другий зникне.';

  @override
  String get actBasketball => 'Баскетбол';

  @override
  String get actBike => 'Велосипед';

  @override
  String get actDance => 'Танці';

  @override
  String get actFootball => 'Футбол';

  @override
  String get actGym => 'Зал';

  @override
  String get actHiit => 'HIIT';

  @override
  String get actJumprope => 'Скакалка';

  @override
  String get actRun => 'Біг';

  @override
  String get actSki => 'Лижі';

  @override
  String get actStretch => 'Розтяжка';

  @override
  String get actSwim => 'Плавання';

  @override
  String get actTennis => 'Теніс';

  @override
  String get actWalk => 'Ходьба';

  @override
  String get actYoga => 'Йога';

  @override
  String get actionAdd => 'Додати';

  @override
  String get actionBack => 'Назад';

  @override
  String get actionCancel => 'Скасувати';

  @override
  String get actionClose => 'Закрити';

  @override
  String get actionDelete => 'Видалити';

  @override
  String get actionDone => 'Готово';

  @override
  String get actionNext => 'Далі';

  @override
  String get actionSave => 'Зберегти';

  @override
  String get activityHigh => 'Висока';

  @override
  String get activityHighHint => '5-6 тренувань';

  @override
  String get activityLight => 'Легка активність';

  @override
  String get activityLightHint => '1-2 тренування на тиждень';

  @override
  String get activityModerate => 'Помірна';

  @override
  String get activityModerateHint => '3-4 тренування';

  @override
  String get activitySedentary => 'Сидячий';

  @override
  String get activitySedentaryHint => 'майже без руху';

  @override
  String get activityVeryHigh => 'Дуже висока';

  @override
  String get activityVeryHighHint => 'фізична робота або спорт щодня';

  @override
  String agoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня тому',
      many: '$count днів тому',
      few: '$count дні тому',
      one: '$count день тому',
    );
    return '$_temp0';
  }

  @override
  String get agoToday => 'сьогодні';

  @override
  String get agoWeek => 'тиждень тому';

  @override
  String agoWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count тижня тому',
      many: '$count тижнів тому',
      few: '$count тижні тому',
      one: '$count тиждень тому',
    );
    return '$_temp0';
  }

  @override
  String get agoYesterday => 'учора';

  @override
  String get allergyConfirm => 'Підтвердити';

  @override
  String get allergyMild => 'Легка';

  @override
  String get allergyMildHint => 'Попереджу в тексті, запис не блокую.';

  @override
  String get allergyMildShort => 'легка';

  @override
  String get allergyNote =>
      'Якщо складу продукту немає в базі, я не мовчу і не вважаю це безпекою: скажу окремо, що склад невідомий.';

  @override
  String get allergyNothing =>
      'Нічого не знайшлось. Якщо алергену немає в списку, напиши Норі: додамо його в довідник, щоб він працював у всіх, а не лишався текстом в одного.';

  @override
  String get allergyRemove => 'Прибрати';

  @override
  String allergySearch(int count) {
    return 'Пошук серед $count алергенів';
  }

  @override
  String get allergySevere => 'Важка';

  @override
  String get allergySevereHint => 'Зупиню до запису і скажу прямо.';

  @override
  String get allergySevereShort => 'важка';

  @override
  String get allergyTitle => 'Алергії';

  @override
  String anChartGoal(String value) {
    return 'ціль $value';
  }

  @override
  String get anDaysInNorm => 'днів у нормі';

  @override
  String anDonePercent(int percent) {
    return '$percent% пройдено';
  }

  @override
  String anEtaHead(String date) {
    return 'За поточним темпом ціль близько *$date*';
  }

  @override
  String get anForMonth => 'за місяць';

  @override
  String get anForQuarter => 'за 3 місяці';

  @override
  String get anForYear => 'за рік';

  @override
  String get anGoalProgress => 'Прогрес до цілі';

  @override
  String get anKcal => 'Калорії';

  @override
  String get anKcalAvg => 'у середньому за день';

  @override
  String get anKcalEmpty =>
      'За цей період ще нічого не записано. Скажи Норі, що зʼїв, і графік почне збиратись сам.';

  @override
  String get anKcalTotal => 'за період, ккал';

  @override
  String anMacroGoal(int grams) {
    return 'норма $grams г';
  }

  @override
  String get anMacrosAvg => 'БЖВ у середньому';

  @override
  String get anMacrosEmpty =>
      'Середнє зʼявиться, щойно буде що усереднювати: запиши хоча б один день.';

  @override
  String get anMeasures => 'Заміри';

  @override
  String anMeasuresChange(String period) {
    return 'зміна $period';
  }

  @override
  String get anMeasuresEmpty => 'Замірів ще немає.';

  @override
  String get anMeasuresEmptyHint => 'Заміряйся раз на місяць, і я покажу, що рухається';

  @override
  String get anMonth => 'Місяць';

  @override
  String get anNow => 'зараз';

  @override
  String get anNowKg => 'поточна, кг';

  @override
  String get anOneReading => 'один замір';

  @override
  String get anOneWeighing => 'Поки один замір. Другий покаже напрямок, і з нього почнеться лінія.';

  @override
  String get anPerDay => 'за день';

  @override
  String get anQuarter => '3 місяці';

  @override
  String anShareOfNorm(int share) {
    return '$share% від норми';
  }

  @override
  String get anTargetKg => 'ціль, кг';

  @override
  String get anTitle => 'Аналітика';

  @override
  String get anWater => 'Гідратація';

  @override
  String get anWaterAvg => 'у середньому, мл';

  @override
  String anWaterGoal(String ml) {
    return 'норма $ml мл';
  }

  @override
  String get anWeek => 'Тиждень';

  @override
  String get anWeightEmpty =>
      'Крива зʼявиться після другого зважування. Скажи Норі вагу, і вона сама її запише.';

  @override
  String get anYear => 'Рік';

  @override
  String get assistantAddMemory => 'Додати в памʼять';

  @override
  String get assistantCollapse => 'Згорнути';

  @override
  String get assistantExample => 'Наприклад, не їм гриби';

  @override
  String get assistantForget => 'Забути';

  @override
  String assistantHint(String name) {
    return '$name веде щоденник разом із тобою і памʼятає те, що ти про себе розповів.';
  }

  @override
  String get assistantMemory => 'Памʼять';

  @override
  String get assistantMemoryEmpty => 'Поки нічого не запамʼятала.';

  @override
  String get assistantMemoryEmptyHint => 'Памʼять зʼявляється з розмов, або додай вручну';

  @override
  String assistantPinned(int count, int pinned) {
    return '$count, закріплено $pinned';
  }

  @override
  String get assistantTitle => 'Помічник';

  @override
  String get assistantWhatToRemember => 'Що памʼятати';

  @override
  String get barCamera => 'Камера';

  @override
  String barGrams(int grams) {
    return '$grams г';
  }

  @override
  String get barHint => 'Пиши як кажеш.';

  @override
  String get barHintMore =>
      '«два яйця і тост», «випив 300 води», «біг 40 хвилин»: розберу і запишу в потрібну картку';

  @override
  String get barLogsInto => 'Записую в ';

  @override
  String get barMic => 'Мікрофон';

  @override
  String get barSend => 'Надіслати';

  @override
  String get camAgain => 'Ще раз';

  @override
  String get camAllergen => 'Алерген!';

  @override
  String camAllergyContains(String list) {
    return 'Містить твій алерген: $list';
  }

  @override
  String camAllergyTraces(String list) {
    return 'Може містити сліди: $list';
  }

  @override
  String get camAskNoraInstead => 'Етикетки немає, спитати Нору';

  @override
  String get camBarcode => 'Штрихкод';

  @override
  String get camBusy => 'Камера не відкрилась. Найчастіше вона зайнята іншим застосунком.';

  @override
  String get camCouldNotRead => 'Не вийшло розібрати знімок';

  @override
  String get camDish => 'Фото';

  @override
  String get camEstimate => ' ккал, оцінка';

  @override
  String get camFlash => 'Спалах';

  @override
  String get camFromPack => 'Числа з упаковки. Запис не коштує токенів.';

  @override
  String get camGallery => 'З галереї';

  @override
  String get camGapNote => 'Цього числа не знає жодна база. Зніми етикетку, і я його дочитаю.';

  @override
  String get camHintBarcode => 'код у рамку';

  @override
  String get camHintDish => 'наведи на тарілку або пачку';

  @override
  String camIngredients(String text) {
    return 'Склад: $text';
  }

  @override
  String camIntoSlot(String slot) {
    return 'в $slot';
  }

  @override
  String camKcalFor(int grams) {
    return ' ккал за $grams г';
  }

  @override
  String camKcalPer(int grams) {
    return ' ккал на $grams г';
  }

  @override
  String get camLabelAim => 'наведи на таблицю поживності';

  @override
  String get camLabelNoShot => 'Кадр не вийшов. Спробуй зняти етикетку ще раз.';

  @override
  String get camLabelReading => 'Переписую числа з пачки…';

  @override
  String camLogInto(String slotInto) {
    return 'Записати $slotInto';
  }

  @override
  String get camNoPermission =>
      'Немає дозволу на камеру. Його можна дати в налаштуваннях телефона.';

  @override
  String get camNoScanner => 'Цей телефон не вміє читати коди камерою.';

  @override
  String get camNoTokens => 'Токени скінчились';

  @override
  String get camNotAProduct => 'Це не штрихкод товару';

  @override
  String get camNotAProductNote =>
      'Прочиталось посилання або службовий код. Наведи на смужку з цифрами під нею.';

  @override
  String get camNotRead => 'Не розібрала';

  @override
  String get camOffline =>
      'Код прочитано, але спитати про нього нема кого. Спробуй, коли зʼявиться звʼязок.';

  @override
  String get camOfflineShot => 'Не дістаю мережі. Знімок можна надіслати Норі пізніше';

  @override
  String get camOfflineTitle => 'Немає мережі';

  @override
  String get camPer100 => 'Точної ваги на упаковці немає: числа за 100 г.';

  @override
  String camPortionPack(int g) {
    return 'Порція з упаковки: $g г. Числа за порцію.';
  }

  @override
  String get camReading => 'Читаю…';

  @override
  String get camSendToNora => 'Надіслати Норі';

  @override
  String get camServerDown => 'Це не через код і не через камеру. Спробуй за хвилину.';

  @override
  String get camServerDownTitle => 'Наш сервер не відповів';

  @override
  String get camShoot => 'Зняти';

  @override
  String get camShootLabel => 'Зняти етикетку';

  @override
  String get camShotFailed => 'Кадр не вийшов';

  @override
  String get camShotReady => 'Знімок готовий';

  @override
  String get camShotReadyNote =>
      'Нора розбере його і відповість у чаті: назве страву, оцінить порцію і покаже, звідки взялося число. Коштує два токени.';

  @override
  String get camSignedOut =>
      'Сесія недійсна, тому довідник нас не впізнає. Зайди в застосунок наново, і сканер запрацює.';

  @override
  String get camSignedOutTitle => 'Треба зайти наново';

  @override
  String get camSlow => 'Код прочитано, а довідник забарився. Спробуй ще раз.';

  @override
  String get camSlowTitle => 'Відповідь не встигла';

  @override
  String get camStillWorks => 'Знімок страви і галерея працюють як завжди.';

  @override
  String get camTitle => 'Сканер';

  @override
  String get camTookTooLong => 'Розбір затягнувся. Спробуй ще раз';

  @override
  String get camUnknownCode => 'Немає цього товару в базі';

  @override
  String get camUnknownCodeNote =>
      'Ні в нашій, ні у відкритій. Зніми таблицю поживності з упаковки, і я перепишу числа з неї. Це безкоштовно.';

  @override
  String get deleteConfirm => 'Я розумію, що дані буде видалено назавжди і відновити їх не вийде.';

  @override
  String get deleteDays => 'Днів із Calvi';

  @override
  String get deleteEntries => 'Записів у щоденнику';

  @override
  String get deleteForever => 'Видалити назавжди';

  @override
  String get deleteNote =>
      'Видаляється все: щоденник, вага, вимірювання, алергії, препарати, історія розмов. Відновити після цього неможливо.';

  @override
  String get deleteSubNote =>
      'Якщо річ у підписці, її можна скасувати окремо в App Store або Google Play, не видаляючи акаунт.';

  @override
  String get deleteTitle => 'Видалити акаунт';

  @override
  String get deleteWeighings => 'Замірів ваги';

  @override
  String get dictationBusy => 'Мікрофон зайнятий. Спробуй ще раз';

  @override
  String get dictationFailed => 'Диктування не вийшло';

  @override
  String get dictationNoMatch => 'Не почула нічого зрозумілого';

  @override
  String get dictationNoNetwork => 'Розпізнаванню потрібна мережа';

  @override
  String get dictationNoPermission => 'Немає дозволу на мікрофон';

  @override
  String get dictationSilence => 'Тиша. Спробуй ще раз ближче до мікрофона';

  @override
  String get dictationUnavailable => 'Диктування недоступне на цьому телефоні';

  @override
  String get doseCapFew => 'капсули';

  @override
  String get doseCapMany => 'капсул';

  @override
  String get doseCapOne => 'капсула';

  @override
  String get doseDropFew => 'краплі';

  @override
  String get doseDropMany => 'крапель';

  @override
  String get doseDropOne => 'крапля';

  @override
  String get doseMlFew => 'мл';

  @override
  String get doseMlMany => 'мл';

  @override
  String get doseMlOne => 'мл';

  @override
  String get doseShotFew => 'уколи';

  @override
  String get doseShotMany => 'уколів';

  @override
  String get doseShotOne => 'укол';

  @override
  String get doseTabFew => 'таблетки';

  @override
  String get doseTabMany => 'таблеток';

  @override
  String get doseTabOne => 'таблетка';

  @override
  String entries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count запису',
      many: '$count записів',
      few: '$count записи',
      one: '$count запис',
      zero: '0 записів',
    );
    return '$_temp0';
  }

  @override
  String get eraseAskBody1 =>
      'Зникне весь щоденник за весь час: страви, вода, вага, заміри, тренування, препарати і розмова з Норою. На всіх пристроях, бо стирається і копія на сервері.';

  @override
  String get eraseAskBody2 =>
      'Лишаться: обліковий запис, вхід, токени з балансом і налаштування профілю. Це не вихід з акаунта, це чистий аркуш у ньому.';

  @override
  String get eraseAskCta => 'Видалити все';

  @override
  String get eraseAskTitle => 'Видалити всі записи?';

  @override
  String get eraseDataTitle => 'Видалити дані';

  @override
  String get eraseDone => 'Щоденник стерто. Чистий аркуш.';

  @override
  String eraseFailed(String why) {
    return 'Не вдалось стерти: $why';
  }

  @override
  String get eraseNoNet => 'немає мережі. Увімкни інтернет і спробуй ще раз';

  @override
  String get eraseSlow => 'сервер довго відповідає. Спробуй ще раз за хвилину';

  @override
  String get eraseSureBody =>
      'Це незворотньо. Щоденник зникне назавжди, і повернути його не зможемо ні ти, ні ми.';

  @override
  String get eraseSureCta => 'Так, видалити назавжди';

  @override
  String get eraseSureTitle => 'Точно видалити?';

  @override
  String get eveningAnd => ' і ';

  @override
  String get eveningBreakfastAcc => 'сніданок';

  @override
  String get eveningDinnerAcc => 'вечерю';

  @override
  String get eveningEmptyDay => 'День порожній. Що сьогодні їв?';

  @override
  String eveningLogged(String slot) {
    return 'Записала $slot?';
  }

  @override
  String get eveningLunchAcc => 'обід';

  @override
  String eveningMissing(String list) {
    return 'Ще не записані $list. Що з цього було?';
  }

  @override
  String get eveningWater => 'Скільки води вийшло за день?';

  @override
  String get fieldBiceps => 'Біцепс';

  @override
  String get fieldChest => 'Груди';

  @override
  String get fieldHips => 'Стегна';

  @override
  String get fieldNeck => 'Шия';

  @override
  String get fieldThigh => 'Стегно';

  @override
  String get fieldWaist => 'Талія';

  @override
  String get fieldWeight => 'Вага';

  @override
  String get fieldWrist => 'Запʼясток';

  @override
  String get goalBecomes => 'Стане';

  @override
  String get goalCurrent => 'Поточна ціль ';

  @override
  String get goalDailyNorm => 'Денна норма';

  @override
  String goalDiff(String kg) {
    return 'різниця $kg кг';
  }

  @override
  String get goalDirection => 'Напрямок';

  @override
  String get goalEta => 'Ціль приблизно';

  @override
  String goalFromStart(String kg) {
    return ' від $kg кг на старті. ';
  }

  @override
  String get goalFromToday => 'Нова ціль почнеться від сьогоднішньої ваги.';

  @override
  String get goalKeepNote => 'Норма тримає поточну вагу: скільки витрачаєш, стільки й повертаєш.';

  @override
  String get goalKeepShort => 'Тримати';

  @override
  String get goalNew => 'Поставити нову ціль';

  @override
  String get goalNewTitle => 'Нова ціль';

  @override
  String get goalPace => 'Темп';

  @override
  String get goalPaceFast => 'Швидко';

  @override
  String get goalPaceOk => 'Це темп, який більшість витримує без зривів.';

  @override
  String get goalPaceSlow => 'Повільно';

  @override
  String get goalPaceUnit => 'кг на тиждень';

  @override
  String get goalPaceUsual => 'Рекомендовано';

  @override
  String goalRange(String from, String to) {
    return '$from → $to кг';
  }

  @override
  String get goalReplaceNote =>
      'Ціль не редагується, вона замінюється. Прогрес почне рахуватись від сьогоднішньої ваги, а стара ціль лишиться в історії. Підтверджуєш заміну?';

  @override
  String get goalSet => 'Поставити';

  @override
  String get goalTarget => 'Цільова вага';

  @override
  String get goalWas => 'Було';

  @override
  String gramsUnit(int grams) {
    return '$grams г';
  }

  @override
  String get helloDishBread => 'Хліб житній';

  @override
  String get helloDishEggs => 'Яєчня з двох яєць';

  @override
  String get helloSaid => 'два яйця і тост';

  @override
  String get helloSlotSub => 'дві страви';

  @override
  String get helloStepCount => 'Порахую калорії';

  @override
  String get helloStepLog => 'Запишу в день';

  @override
  String get helloStepSay => 'Скажи, що їв';

  @override
  String heroBurned(int kcal) {
    return '-$kcal ккал за тренування';
  }

  @override
  String get heroDays => 'днів';

  @override
  String heroFrom(String kcal) {
    return ' від $kcal';
  }

  @override
  String get heroGoalKg => 'ціль, кг';

  @override
  String get heroKcal => ' ккал';

  @override
  String get heroKg => ' кг';

  @override
  String get heroLeft => 'лишилось ';

  @override
  String heroOf(String kcal) {
    return ' з $kcal';
  }

  @override
  String get heroOver => 'перебір на ';

  @override
  String get heroWeekOpen => 'Розбір тижня';

  @override
  String heroWeightFrom(String kg) {
    return 'зараз, від $kg кг на старті цілі';
  }

  @override
  String kcalUnit(int kcal) {
    return '$kcal ккал';
  }

  @override
  String get langSection => 'Мова інтерфейсу';

  @override
  String get langSystem => 'Мова пристрою';

  @override
  String legalUpdated(String date) {
    return 'Оновлено $date';
  }

  @override
  String get loginNoToken => 'Google не віддав токен';

  @override
  String get loginNotConfigured => 'вхід не налаштований у цій збірці';

  @override
  String get loginNotSynced =>
      'Не всі записи доїхали на сервер. Спробуй ще раз за хвилину: вхід не стирає нічого, поки все не збережено';

  @override
  String loginServer(String why) {
    return 'сервер: $why';
  }

  @override
  String get loginSlow => 'Google не відповів за хвилину. Спробуй ще раз';

  @override
  String get macroCNone => 'В ?';

  @override
  String macroCShort(int value) {
    return 'В $value';
  }

  @override
  String get macroCarbs => 'Вуглеводи';

  @override
  String get macroCarbsCaps => 'ВУГЛЕВОДИ';

  @override
  String get macroCarbsLetter => 'В';

  @override
  String get macroFNone => 'Ж ?';

  @override
  String macroFShort(int value) {
    return 'Ж $value';
  }

  @override
  String get macroFat => 'Жири';

  @override
  String get macroFatCaps => 'ЖИРИ';

  @override
  String get macroFatLetter => 'Ж';

  @override
  String get macroMedsCaps => 'ПРЕПАРАТИ';

  @override
  String macroOfGrams(int goal) {
    return ' / $goalг';
  }

  @override
  String get macroPNone => 'Б ?';

  @override
  String macroPShort(int value) {
    return 'Б $value';
  }

  @override
  String get macroProtein => 'Білок';

  @override
  String get macroProteinCaps => 'БІЛОК';

  @override
  String get macroProteinLetter => 'Б';

  @override
  String get mealAuto => 'авто ';

  @override
  String get mealEmpty => 'Тут поки порожньо. Напиши, що було, і я запишу.';

  @override
  String mealGrams(int grams) {
    return '$grams г';
  }

  @override
  String get mealThinking => 'Нора рахує…';

  @override
  String get measureAdd => 'Додати вимірювання';

  @override
  String get measureCollapse => 'Згорнути';

  @override
  String measureCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заміру',
      many: '$count замірів',
      few: '$count заміри',
      one: '$count замір',
    );
    return '$_temp0';
  }

  @override
  String measureLast(String ago) {
    return 'останнє $ago';
  }

  @override
  String get measureNever => 'ще не робив';

  @override
  String get measureNothing => 'ще нічого';

  @override
  String get measurePick => 'Обери, що будеш міряти. Досить одного, якщо решта не цікавить.';

  @override
  String get measureSave => 'Зберегти заміри';

  @override
  String get measureStats => 'Статистика замірів';

  @override
  String get measureTitle => 'Вимірювання';

  @override
  String get medsAdd => 'Додати препарат';

  @override
  String get medsAllTaken => 'На сьогодні все прийнято';

  @override
  String get medsAt => 'О котрій';

  @override
  String get medsCourse => 'Курс';

  @override
  String get medsDose => 'Доза';

  @override
  String get medsEmpty => 'Тут порожньо. Додай препарат, і я нагадаю в потрібний час.';

  @override
  String get medsEmptyHint => 'Веду журнал прийомів, дозування не рахую';

  @override
  String get medsFinish => 'Закінчити курс';

  @override
  String medsFirstDose(String name, String day, String at) {
    return '$name, перший прийом $day о $at';
  }

  @override
  String get medsHours => 'Години';

  @override
  String get medsHowOften => 'Як часто';

  @override
  String get medsMine => 'Мої препарати';

  @override
  String get medsName => 'Назва';

  @override
  String get medsNameExample => 'Наприклад, Магній B6';

  @override
  String get medsNew => 'Новий препарат';

  @override
  String get medsNextAt => 'Далі о ';

  @override
  String get medsNoneToday => 'Сьогодні прийомів немає';

  @override
  String get medsNote => 'Примітка';

  @override
  String get medsNow => 'ЗАРАЗ';

  @override
  String get medsOne => 'Препарат';

  @override
  String get medsPast => 'Минулі';

  @override
  String get medsPastEmpty =>
      'Тут будуть курси, які ти вже не приймаєш. Препарат, прибраний зі списку, лишається в днях, коли ти його пив.';

  @override
  String get medsPerTake => 'Скільки за раз';

  @override
  String get medsRemind => 'Нагадувати';

  @override
  String get medsRemindHint => 'у вибрані години';

  @override
  String get medsResume => 'Відновити курс';

  @override
  String get medsSchedule => 'Розклад';

  @override
  String medsSince(String date) {
    return 'з $date';
  }

  @override
  String get medsTime => 'Час';

  @override
  String get medsTitle => 'Препарати';

  @override
  String get medsTomorrow => 'завтра';

  @override
  String get medsUnmarked => 'Ще не позначено: ';

  @override
  String medsUntil(String date) {
    return 'до $date';
  }

  @override
  String get noraName => 'Нора';

  @override
  String get normAuto => 'Рахувати автоматично';

  @override
  String get normAutoFrom => 'З ваги, зросту, віку, активності й цілі: ';

  @override
  String normAutoHint(String kcal) {
    return 'з ваги, зросту, віку, активності й цілі: $kcal ккал';
  }

  @override
  String get normAutoShort => 'Автоматично';

  @override
  String get normByHand => 'Задати вручну';

  @override
  String get normByHandHint => 'аналітика рахуватиме проти цього числа';

  @override
  String get normByHandShort => 'Вручну';

  @override
  String get normCalculatedHead => 'Розрахункове значення ';

  @override
  String get normCalculatedTail => '. Повернутись до нього можна вибором «Автоматично».';

  @override
  String get normFitCarbs => 'Підігнати вуглеводи під норму';

  @override
  String get normFits => 'Склад сходиться з нормою';

  @override
  String normGrams(int grams) {
    return '$grams г';
  }

  @override
  String normKcalOf(String kcal) {
    return '$kcal ккал';
  }

  @override
  String normMacroSplit(int protein, int fat, int carbs) {
    return '$protein / $fat / $carbs г';
  }

  @override
  String get normMacros => 'БЖВ';

  @override
  String get normManual => 'перевизначено вручну';

  @override
  String normOf(String kcal) {
    return 'з $kcal ккал';
  }

  @override
  String normOffBy(String sum, int off) {
    return 'Склад дає $sum ккал, це на $off осторонь';
  }

  @override
  String get normPerDay => 'ккал на день';

  @override
  String get normTitle => 'Норма';

  @override
  String get normWater => 'Вода';

  @override
  String get normWaterHead => 'Це ';

  @override
  String normWaterPerKg(int ml) {
    return '$ml мл';
  }

  @override
  String get normWaterTail =>
      ' на кілограм ваги. Звична орієнтовна вилка це 30-40 мл, але вона залежить від спеки й тренувань, тому число тут не жорстке.';

  @override
  String get normWhere => 'Звідки це число';

  @override
  String get notifyChannel => 'Нагадування';

  @override
  String get notifyChannelHint => 'Нагадування про їжу, воду, препарати і зважування';

  @override
  String get notifyDenied =>
      'Телефон не дозволив сповіщення. Увімкни їх у налаштуваннях системи, і нагадування запрацюють.';

  @override
  String get photoDish => 'Страва';

  @override
  String get photoNotRecognized => 'Не впізнала страву на цьому знімку';

  @override
  String get planBuy => 'Оформити';

  @override
  String get planFree => 'Безкоштовний';

  @override
  String get planLater => 'Не зараз';

  @override
  String get planMonth => 'Місяць';

  @override
  String get planMonthBilled => 'щомісячне списання';

  @override
  String get planMonthPrice => '180 грн';

  @override
  String get planNow => 'Зараз';

  @override
  String get planPerkChat => 'Безлімітні розмови з Норою';

  @override
  String get planPerkHistory => 'Історія і аналітика без обмежень';

  @override
  String get planPerkReports => 'Звіти за будь-який період';

  @override
  String get planPerks => 'Що дає Premium';

  @override
  String get planPitch => 'Безлімітні токени, історія без обмежень і звіти за будь-який період.';

  @override
  String get planPlan => 'План';

  @override
  String get planSave => '-17%';

  @override
  String get planStoreNote =>
      'Оплата проходить через App Store або Google Play. Скасувати можна там само, у налаштуваннях передплат, і Calvi на це не впливає.';

  @override
  String get planTitle => 'Підписка';

  @override
  String get planTokens => 'Токени';

  @override
  String get planTokensFree => '40 на місяць';

  @override
  String get planYear => 'Рік';

  @override
  String get planYearBilled => '1 800 грн раз на рік';

  @override
  String get planYearHint => '150 грн на місяць, списується раз на рік';

  @override
  String get planYearPrice => '150 грн';

  @override
  String plateFor(int grams) {
    return 'за $grams г';
  }

  @override
  String get plateGrams => ' г';

  @override
  String get plateKcal => 'ккал';

  @override
  String get plateThinking => 'думаю';

  @override
  String get privacyCrash => 'Звіти про збої';

  @override
  String get privacyCrashHint => 'стек помилки, без даних щоденника';

  @override
  String get privacyDiaryHead => 'Щоденник лишається у тебе';

  @override
  String get privacyDiarySub => 'ні страви, ні вага не йдуть в аналітику';

  @override
  String get privacyHealthHead => 'Здоровʼя не передається нікому';

  @override
  String get privacyHealthSub => 'алергії та препарати не покидають застосунок';

  @override
  String get privacyNoPhotosHead => 'Фото страв не зберігаються';

  @override
  String get privacyNoPhotosSub => 'знімок іде в обробку і зникає';

  @override
  String get privacyNotCollected => 'Що ми не збираємо';

  @override
  String get privacyOptional => 'Що можна вимкнути';

  @override
  String get privacyPhotosBold => 'не зберігаються';

  @override
  String get privacyPhotosHead => 'Фото страв ';

  @override
  String get privacyPhotosTail =>
      ': знімок іде в обробку і зникає. В аналітику не потрапляють ні страви, ні вага, ні алергії, ні препарати. Це особлива категорія персональних даних, і віддавати її третій стороні не можна незалежно від зручності.';

  @override
  String get privacyStats => 'Знеособлена статистика';

  @override
  String get privacyStatsHint => 'які екрани відкривають, без вмісту записів';

  @override
  String get privacyTitle => 'Приватність';

  @override
  String get profileActivity => 'Активність';

  @override
  String get profileAge => 'Вік';

  @override
  String get profileHeight => 'Зріст';

  @override
  String get profileSex => 'Стать';

  @override
  String get remAbout => 'Про що';

  @override
  String get remAdd => 'Додати нагадування';

  @override
  String get remAt => 'О котрій';

  @override
  String get remDelete => 'Видалити нагадування';

  @override
  String get remEdit => 'Нагадування';

  @override
  String get remEmpty => 'Поки жодного нагадування.';

  @override
  String get remEmptyHint => 'Додай те, про що справді забуваєш, а не все підряд';

  @override
  String get remHowOften => 'Як часто';

  @override
  String get remName => 'Назва';

  @override
  String get remNew => 'Нове нагадування';

  @override
  String get remOpenMeds => 'Відкрити препарати';

  @override
  String get remTime => 'Час';

  @override
  String get remTitle => 'Нагадування';

  @override
  String get reminderBodyMeal => 'Запиши, що було';

  @override
  String get reminderBodyMeds => 'За розкладом';

  @override
  String get reminderBodySummary => 'Що сьогодні не записав?';

  @override
  String get reminderBodyWater => 'Час попити';

  @override
  String get reminderBodyWeigh => 'Вранці, до їжі';

  @override
  String get reminderBodyWorkout => 'Запиши, якщо було';

  @override
  String get reminderMeal => 'Їжа';

  @override
  String get reminderMealHint => 'нагадаю записати прийом';

  @override
  String get reminderMeds => 'Препарати';

  @override
  String get reminderMedsHint => 'за розкладом із журналу';

  @override
  String get reminderSummary => 'Підсумок дня';

  @override
  String get reminderSummaryHint => 'коротко про день перед сном';

  @override
  String get reminderWater => 'Вода';

  @override
  String get reminderWaterHint => 'нагадаю попити';

  @override
  String get reminderWeigh => 'Зважування';

  @override
  String get reminderWeighHint => 'щоб графік ваги не рвався';

  @override
  String get reminderWorkout => 'Тренування';

  @override
  String get reminderWorkoutHint => 'нагадаю про заплановане';

  @override
  String get repDaily => 'щодня';

  @override
  String repEveryN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'кожні $count дня',
      many: 'кожні $count днів',
      few: 'кожні $count дні',
      one: 'кожні $count день',
    );
    return '$_temp0';
  }

  @override
  String get repEveryOther => 'через день';

  @override
  String get repPickDaily => 'Щодня';

  @override
  String get repPickFromToday => 'Відлік від сьогодні.';

  @override
  String get repPickInterval => 'Через день';

  @override
  String get repPickNoDays => 'Жодного дня не вибрано, тому нагадування не спрацює.';

  @override
  String get repPickWeekdays => 'Дні тижня';

  @override
  String get repWeekdays => 'по буднях';

  @override
  String get repWeekends => 'на вихідних';

  @override
  String get repWeekly => 'раз на тиждень';

  @override
  String get setAbout => 'Про застосунок';

  @override
  String get setAllergies => 'Алергії';

  @override
  String setAssistantLine(String name, int count) {
    return '$name, памʼяті $count';
  }

  @override
  String get setDeleteAccount => 'Видалити акаунт і дані';

  @override
  String get setFreeTierHead =>
      'Захисникам України, працівникам ЗСУ, ДСНС, ДТЕК, медикам, волонтерам, вчителям прифронтових зон тарифний план ';

  @override
  String get setFreeTierHow => ' Як отримати';

  @override
  String get setFreeTierShort =>
      'Захисникам України, працівникам ЗСУ, ДСНС, ДТЕК, медикам, волонтерам, вчителям прифронтових зон тарифний план БЕЗКОШТОВНИЙ';

  @override
  String get setFreeTierTelegram => 'Написати в Telegram';

  @override
  String get setFreeTierTitle => 'Безкоштовний тариф';

  @override
  String get setFreeTierWord => 'БЕЗКОШТОВНИЙ';

  @override
  String get setFreeTierWrite => 'Напишіть розробнику, і сьогодні вам активують платний тариф.';

  @override
  String get setGoal => 'Ціль';

  @override
  String get setGoalKeep => 'тримати вагу';

  @override
  String setGoalLine(String kg, String pace) {
    return '$kg кг, $pace/тиждень';
  }

  @override
  String get setGroupAbout => 'Про тебе';

  @override
  String get setGroupAccount => 'Акаунт';

  @override
  String get setGroupAssistant => 'Помічник';

  @override
  String get setGroupDocs => 'Документи';

  @override
  String get setGroupHealth => 'Здоровʼя';

  @override
  String get setLang => 'Мова';

  @override
  String get setMeds => 'Препарати';

  @override
  String get setNorm => 'Норма';

  @override
  String setNormLine(String kcal) {
    return '$kcal ккал';
  }

  @override
  String get setPlan => 'Підписка';

  @override
  String get setPlanFree => 'Безкоштовно';

  @override
  String get setPolicy => 'Політика приватності';

  @override
  String get setPrivacy => 'Дані і аналітика';

  @override
  String get setProfile => 'Профіль';

  @override
  String setProfileLine(String sex, int age, int height) {
    return '$sex, $age, $height см';
  }

  @override
  String get setReminders => 'Нагадування';

  @override
  String get setRemindersOff => 'вимкнені';

  @override
  String get setTerms => 'Умови користування';

  @override
  String get setTheme => 'Тема';

  @override
  String get setTitle => 'Налаштування';

  @override
  String get setUnset => 'не вказано';

  @override
  String get sexOther => 'Інше';

  @override
  String get sexShortFemale => 'Ж';

  @override
  String get sexShortMale => 'Ч';

  @override
  String get slotBreakfast => 'Сніданок';

  @override
  String get slotByHand => 'Ввести числа самому';

  @override
  String get slotCancel => 'Скасувати';

  @override
  String get slotDinner => 'Вечеря';

  @override
  String slotEraseBody(String name) {
    return '«$name» стоїть без чисел. Рядок зникне з дня.';
  }

  @override
  String get slotEraseDo => 'Прибрати';

  @override
  String get slotEraseTitle => 'Прибрати чернетку?';

  @override
  String get slotGrams => 'ВАГА, Г';

  @override
  String get slotIntoBreakfast => 'в сніданок';

  @override
  String get slotIntoDinner => 'у вечерю';

  @override
  String get slotIntoLunch => 'в обід';

  @override
  String slotIntoOther(String name) {
    return 'в «$name»';
  }

  @override
  String get slotIntoSnack => 'в перекус';

  @override
  String get slotKcal => 'ККАЛ';

  @override
  String get slotLog => 'Записати';

  @override
  String get slotLunch => 'Обід';

  @override
  String get slotSnack => 'Перекус';

  @override
  String get slotWriteWhat => 'Напиши, що було';

  @override
  String get startAbout => 'Про тебе';

  @override
  String get startAge => 'Вік';

  @override
  String startAgeYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count року',
      many: '$count років',
      few: '$count роки',
      one: '$count рік',
    );
    return '$_temp0';
  }

  @override
  String get startAgreeAnd => ' і ';

  @override
  String get startAgreeHead => 'Погоджуюсь з ';

  @override
  String get startAgreePrivacy => 'політикою приватності';

  @override
  String get startAgreeTerms => 'умовами користування';

  @override
  String get startAllergies => 'Алергії';

  @override
  String get startDeviceFirstRun => 'перший запуск';

  @override
  String get startGoal => 'Куди рухаємось';

  @override
  String get startGoalGain => 'Набрати';

  @override
  String get startGoalGainHint => 'профіцит під обраний темп';

  @override
  String get startGoalKeep => 'Тримати вагу';

  @override
  String get startGoalKeepHint => 'скільки витрачаєш, стільки й повертаєш';

  @override
  String get startGoalLose => 'Схуднути';

  @override
  String get startGoalLoseHint => 'дефіцит під обраний темп';

  @override
  String get startHeight => 'Зріст';

  @override
  String get startLife => 'Спосіб життя';

  @override
  String get startNorm => 'Твоя норма';

  @override
  String get startNormHold => 'тримаємо';

  @override
  String get startNormNora => 'Порахувала. Далі простіше.';

  @override
  String get startNormNoraHint =>
      'Пиши або кажи як зручно: «два яйця і тост», «випив 300 води». Решту, що знадобиться, спитаю в розмові.';

  @override
  String get startNormNote =>
      'Це розрахунок за формулою Міффліна-Сан Жеора, а не медична рекомендація. Якщо є захворювання, вагітність або призначена дієта, звіряйся з лікарем.';

  @override
  String get startNormPerDay => 'ккал на день';

  @override
  String get startNormWeeks => 'тижнів';

  @override
  String get startPace => 'Як швидко';

  @override
  String get startPaceEtaHead => 'Ціль приблизно ';

  @override
  String get startPaceEtaTail => ', це ';

  @override
  String get startPaceFast => 'швидко';

  @override
  String get startPaceSlow => 'повільно';

  @override
  String get startPaceUnit => 'кг на тиждень';

  @override
  String get startPaceUsual => 'звично';

  @override
  String get startPaceWarning =>
      'Такий темп тримається важко і зазвичай зривається. Нижче за 0.8 кг на тиждень результат виходить повільніший, але лишається.';

  @override
  String startPaceWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count тижня',
      many: '$count тижнів',
      few: '$count тижні',
      one: '$count тиждень',
    );
    return '$_temp0';
  }

  @override
  String get startSex => 'Стать';

  @override
  String get startSexFemale => 'Жіноча';

  @override
  String get startSexMale => 'Чоловіча';

  @override
  String get startSexOther => 'Інше';

  @override
  String get startSignInApple => 'Продовжити з Apple';

  @override
  String get startSignInBusy => 'Заходимо…';

  @override
  String get startSignInFailed => 'Не вдалось увійти. Спробуй ще раз або продовж без входу.';

  @override
  String startSignInFailedWhy(String why) {
    return 'Не вдалось увійти. $why';
  }

  @override
  String get startSignInGoogle => 'Продовжити з Google';

  @override
  String get startSignInSkip => 'Поки без входу';

  @override
  String get startSignInText =>
      'Норма порахована. Увійди, щоб вона лишилась при собі: історія, заміри й записи будуть на всіх пристроях, а не тільки тут.';

  @override
  String get startSignInTitle => 'Збережімо це';

  @override
  String get startTargetWeight => 'Цільова вага';

  @override
  String get startWeightNow => 'Вага зараз';

  @override
  String get startYearsShort => 'років';

  @override
  String get storageBroken =>
      'Не вдалось відкрити сховище. Записи на місці, але показати їх зараз нема чим.';

  @override
  String get themeAquarelle => 'Акварель';

  @override
  String get themeAquarelleHint => 'світла, з пастельними хмарами на тлі';

  @override
  String get themeDark => 'Темна';

  @override
  String get themeDarkHint => 'завжди темний інтерфейс';

  @override
  String get themeDawn => 'Світанок';

  @override
  String get themeDawnHint => 'світла, з теплим світлом збоку';

  @override
  String get themeLight => 'Світла';

  @override
  String get themeLightHint => 'завжди світлий інтерфейс';

  @override
  String get themeSectionLook => 'Вигляд';

  @override
  String get themeSystem => 'Тема пристрою';

  @override
  String get themeSystemHint => 'слухає налаштування системи';

  @override
  String get todayBarcode => 'Штрихкод';

  @override
  String todayCodeTalk(String code) {
    return 'Відсканував штрихкод $code, у базах його немає. Нічого не записуй: розпитай мене про цей продукт або підкажи, як його порахувати.';
  }

  @override
  String get todayDone => 'Готово.';

  @override
  String get todayFailedRetry => 'Не вийшло. Спробуй ще раз за хвилину.';

  @override
  String todayHowManyGrams(String dish) {
    return 'Скільки грамів було: $dish?';
  }

  @override
  String get todayLogFailed => 'Не вийшло записати. Спробуй ще раз.';

  @override
  String get todayLogged => 'Записала.';

  @override
  String todayLoggedAskWeight(String slotInto) {
    return 'Записала $slotInto. Скажи вагу, якщо хочеш точніше.';
  }

  @override
  String get todayLoggedAskWeightShort => 'Записала. Скажи вагу, якщо хочеш точніше.';

  @override
  String todayLoggedCount(int count) {
    return 'Записано $count';
  }

  @override
  String todayLoggedInto(String slotInto, String dish) {
    return 'Записала $slotInto: $dish.';
  }

  @override
  String todayLoggedIntoWithNumbers(String slotInto, String dish, int kcal, int grams) {
    return 'Записала $slotInto: $dish, $kcal ккал за $grams г.';
  }

  @override
  String get todayNoraSlow => 'Нора думає довше звичного. Спробуй ще раз, токен не списався.';

  @override
  String get todayOffline => 'Не дістаю мережі. Спробуй ще раз, коли зʼявиться.';

  @override
  String get todayOfflineSaved =>
      'Не дістаю мережі. Запис лишиться на телефоні і поїде, коли зʼявиться.';

  @override
  String get todayOutOfTokens => 'Токени скінчились. Записати вручну можна завжди.';

  @override
  String get todayPhotoMeal => 'Фото';

  @override
  String get todayQuestionClosed => 'Це питання вже закрите. Скажи вагу словами, якщо треба.';

  @override
  String get unitCm => 'см';

  @override
  String get unitG => 'г';

  @override
  String get unitKcal => 'ккал';

  @override
  String get unitKg => 'кг';

  @override
  String get unitMl => 'мл';

  @override
  String waterGlasses(int glasses) {
    return 'близько $glasses склянок';
  }

  @override
  String waterLess(int step) {
    return 'Менше на $step мл';
  }

  @override
  String waterMore(int step) {
    return 'Більше на $step мл';
  }

  @override
  String get waterNone => 'нічого не випито';

  @override
  String waterOf(String ml) {
    return ' / $ml мл';
  }

  @override
  String waterShare(int pct) {
    return '$pct% денної цілі';
  }

  @override
  String get waterTitle => 'Вода';

  @override
  String get wcNoTime => 'без тривалості';

  @override
  String get wdFri => 'Пт';

  @override
  String get wdMon => 'Пн';

  @override
  String get wdSat => 'Сб';

  @override
  String get wdSun => 'Нд';

  @override
  String get wdThu => 'Чт';

  @override
  String get wdTue => 'Вт';

  @override
  String get wdWed => 'Ср';

  @override
  String get weightHint => 'Скільки ти важиш сьогодні. Ціль і темп до неї живуть окремо.';

  @override
  String get weightNote =>
      'Записуй вагу вранці, до їжі: так добові коливання не перетворюють графік на шум. Один замір на тиждень уже дає тренд.';

  @override
  String get weightTitle => 'Вага';

  @override
  String get wfBurned => 'Спалено, ккал';

  @override
  String get wfDuration => 'Тривалість';

  @override
  String get wfDurationCap => 'Тривалість, хв';

  @override
  String get wfEstimate => 'Оцінка за твоєю вагою і типом активності';

  @override
  String get wfFromWatch => 'З годинника або тренажера';

  @override
  String get wfKcal => ' ккал';

  @override
  String get wfLog => 'Записати';

  @override
  String get wfManualKcal => 'Вручну ккал';

  @override
  String wfMin(int min) {
    return '$min хв';
  }

  @override
  String get wfMinutes => 'Хвилини';

  @override
  String get wfNote => 'Нотатка';

  @override
  String get wfNoteExample => 'Ноги, важко';

  @override
  String get wfOptional => '  необовʼязково';

  @override
  String get wheelLess => 'Менше';

  @override
  String get wheelMore => 'Більше';

  @override
  String get wkDaysOk => 'днів у нормі';

  @override
  String get wkEmpty =>
      'За цей тиждень ще нічого не записано. Запиши перший день, і тут з’явиться картина.';

  @override
  String get wkFactsHead => 'Разом за тиждень';

  @override
  String get wkKcalHead => 'Калорії';

  @override
  String get wkLoggedCap => 'днів записано';

  @override
  String wkLoggedValue(int n) {
    return '$n із 7';
  }

  @override
  String get wkMacroHead => 'БЖВ';

  @override
  String get wkNoWeight => 'вага: не зважувались';

  @override
  String get wkNoraBtn => 'Зробити розбір';

  @override
  String wkNoraFailed(String why) {
    return 'Не вийшло побудувати розбір: $why';
  }

  @override
  String get wkNoraGreet =>
      'Питай про будь-що з цього розбору: про страву, звичку чи що поправити першим.';

  @override
  String get wkNoraLoading => 'Нора вивчає тиждень…';

  @override
  String get wkNoraLocked => 'Аналітика буде доступна в пʼятницю';

  @override
  String get wkNoraNoNet => 'немає мережі';

  @override
  String get wkNoraNoTokens => 'токени скінчились';

  @override
  String get wkNoraP1 =>
      'Основа в тебе здорова, і це рідкість: майже все домашнє. Борщ, яєчня, вівсянка: на такій базі решта поправляється швидко.';

  @override
  String get wkNoraP2 =>
      'Тепер чесно. Овочів за тиждень майже не було, а солодке було щодня: млинці з медом, компот. Білка бракує не тому, що ти мало їси, а тому, що в тарілці багато вуглеводів і мало мʼяса, риби чи сиру. І три вечері з семи були після десятої.';

  @override
  String get wkNoraP3 =>
      'Поки нічого страшного, але саме так виглядає раціон, який у сорок здивує аналізами. Один крок на наступний тиждень, більше нічого не міняй: до кожного обіду щось зелене, а замість компоту вода.';

  @override
  String get wkNoraPlaceholder => 'Спитай про цей тиждень';

  @override
  String get wkNoraPromise =>
      'Чесний підсумок тижня: що вийшло, де просіло і один крок на наступний.';

  @override
  String get wkNoraReply1 =>
      'Найпростіший обмін цього тижня: компот на воду. Мінус ложка цукру щоразу, а борщу він нічого не винен.';

  @override
  String get wkNoraReply2 =>
      'Зелене до обіду не мусить бути салатом. Огірок або пів перця поруч із тарілкою вже роблять роботу.';

  @override
  String get wkNoraSlow => 'сервер довго відповідає';

  @override
  String get wkNoraTalk => 'Поговорити про це з Норою';

  @override
  String get wkNoraTitle => 'Розбір від Нори';

  @override
  String get wkNorm => 'норма';

  @override
  String wkOffNorm(String n) {
    return '$n від норми';
  }

  @override
  String get wkPastEmpty => 'Минулих розборів ще немає. Перший зʼявиться тут наступного понеділка.';

  @override
  String wkPastRow(String day) {
    return 'Тиждень від $day';
  }

  @override
  String get wkPastTitle => 'Минулі';

  @override
  String get wkPerDay => 'ккал у середньому за добу';

  @override
  String get wkPerDayAside => 'у середньому за добу';

  @override
  String get wkTitle => 'Тиждень';

  @override
  String get wkTotalCap => 'ккал за тиждень';

  @override
  String get wkWaterCap => 'води за добу';

  @override
  String wkWaterValue(String l) {
    return '$l л';
  }

  @override
  String get wkWeightCap => 'вага за тиждень';

  @override
  String get workoutAdd => 'Додати тренування';

  @override
  String workoutBurned(int kcal) {
    return '−$kcal ккал';
  }

  @override
  String get workoutCollapse => 'Згорнути';

  @override
  String get workoutNone => 'нічого не записано';

  @override
  String workoutSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сесії',
      many: '$count сесій',
      few: '$count сесії',
      one: '$count сесія',
    );
    return '$_temp0';
  }

  @override
  String get workoutTitle => 'Тренування';
}
