// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class LRu extends L {
  LRu([String locale = 'ru']) : super(locale);

  @override
  String get aboutContact => 'Связь';

  @override
  String get aboutDeveloper => 'Разработчик';

  @override
  String get aboutText =>
      'Дневник питания, который понимает обычные предложения. Числа считает помощница Нора, решения остаются за тобой.';

  @override
  String get aboutTitle => 'О приложении';

  @override
  String get aboutVersion => 'Версия';

  @override
  String get aboutWrite => 'Написать нам';

  @override
  String get accessAsk => 'ещё не запрашивали';

  @override
  String get accessCamera => 'Камера';

  @override
  String get accessMic => 'Микрофон';

  @override
  String get accessNote =>
      'Микрофон и распознавание речи нужны для диктовки, а распознавание ещё и часам: они записывают сказанное, а слова из него делает телефон. Нажатие на строку просит доступ или открывает настройки системы, где его можно выключить.';

  @override
  String get accessNotify => 'Уведомления';

  @override
  String get accessOff => 'запрещено';

  @override
  String get accessOn => 'разрешено';

  @override
  String get accessSpeech => 'Распознавание речи';

  @override
  String get accountBusy => 'Заходим…';

  @override
  String get accountGoogle => 'Продолжить с Google';

  @override
  String get accountKeepCloud => 'Тот, что в аккаунте';

  @override
  String get accountNoAccountNote =>
      'Дневник живёт только на этом телефоне. Сменишь телефон или сотрёшь приложение, и вернуть записи будет нечем: мы не знаем, чьи они.';

  @override
  String get accountScopeNote =>
      'Мы просим только почту. Имени, фото профиля и контактов Google нам не передаёт.';

  @override
  String get accountSettingsDevice => 'настройки';

  @override
  String get accountSignInFailed => 'Не удалось войти.';

  @override
  String accountSignInFailedWhy(String why) {
    return 'Не удалось войти. $why';
  }

  @override
  String get accountSignOut => 'Выйти';

  @override
  String get accountSignOutAction => 'Выйти из аккаунта';

  @override
  String get accountSignOutAsk => 'Выйти из аккаунта?';

  @override
  String get accountSignOutBack =>
      'Войди тем же аккаунтом, и всё вернётся на место. То, что записано без интернета и ещё не доехало на сервер, вернуть не выйдет.';

  @override
  String get accountSignOutNote =>
      'Этот телефон станет чистым: дневник, профиль, препараты и разговор с Норой исчезнут с него. Записи остаются на сервере, под твоим аккаунтом.';

  @override
  String get accountSince => 'С Calvi с';

  @override
  String get accountTitle => 'Учётная запись';

  @override
  String get accountVia => 'Вход через Google';

  @override
  String get accountViaApple => 'Вход через Apple';

  @override
  String get accountViaEmail => 'Вход через почту';

  @override
  String get accountWatch => 'Apple Watch';

  @override
  String get accountWhichDiary => 'Какой дневник оставляем?';

  @override
  String get accountWhichDiaryNote =>
      'В этом аккаунте уже есть записи, и на телефоне тоже. Оставить можно только один: тот, что в аккаунте, или тот, что на телефоне. Второй исчезнет.';

  @override
  String get actBasketball => 'Баскетбол';

  @override
  String get actBike => 'Велосипед';

  @override
  String get actDance => 'Танцы';

  @override
  String get actFootball => 'Футбол';

  @override
  String get actGym => 'Зал';

  @override
  String get actHiit => 'HIIT';

  @override
  String get actJumprope => 'Скакалка';

  @override
  String get actRun => 'Бег';

  @override
  String get actSki => 'Лыжи';

  @override
  String get actStretch => 'Растяжка';

  @override
  String get actSwim => 'Плавание';

  @override
  String get actTennis => 'Теннис';

  @override
  String get actWalk => 'Ходьба';

  @override
  String get actYoga => 'Йога';

  @override
  String get actionAdd => 'Добавить';

  @override
  String get actionBack => 'Назад';

  @override
  String get actionCancel => 'Отменить';

  @override
  String get actionClose => 'Закрыть';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionDone => 'Готово';

  @override
  String get actionGotIt => 'Понятно';

  @override
  String get actionNext => 'Дальше';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get activityHigh => 'Высокая';

  @override
  String get activityHighHint => '5-6 тренировок';

  @override
  String get activityLight => 'Лёгкая активность';

  @override
  String get activityLightHint => '1-2 тренировки в неделю';

  @override
  String get activityModerate => 'Умеренная';

  @override
  String get activityModerateHint => '3-4 тренировки';

  @override
  String get activitySedentary => 'Сидячий';

  @override
  String get activitySedentaryHint => 'почти без движения';

  @override
  String get activityVeryHigh => 'Очень высокая';

  @override
  String get activityVeryHighHint => 'физическая работа или спорт каждый день';

  @override
  String agoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня назад',
      many: '$count дней назад',
      few: '$count дня назад',
      one: '$count день назад',
    );
    return '$_temp0';
  }

  @override
  String get agoToday => 'сегодня';

  @override
  String get agoWeek => 'неделю назад';

  @override
  String agoWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count недели назад',
      many: '$count недель назад',
      few: '$count недели назад',
      one: '$count неделю назад',
    );
    return '$_temp0';
  }

  @override
  String get agoYesterday => 'вчера';

  @override
  String get allergyConfirm => 'Подтвердить';

  @override
  String get allergyMild => 'Лёгкая';

  @override
  String get allergyMildHint => 'Предупрежу в тексте, запись не блокирую.';

  @override
  String get allergyMildShort => 'лёгкая';

  @override
  String get allergyNote =>
      'Если состава продукта нет в базе, я не молчу и не считаю это безопасностью: скажу отдельно, что состав неизвестен.';

  @override
  String get allergyNothing =>
      'Ничего не нашлось. Если аллергена нет в списке, напиши Норе: добавим его в справочник, чтобы он работал у всех, а не оставался текстом у одного.';

  @override
  String get allergyRemove => 'Убрать';

  @override
  String allergySearch(int count) {
    return 'Поиск среди $count аллергенов';
  }

  @override
  String get allergySevere => 'Тяжёлая';

  @override
  String get allergySevereHint => 'Остановлю до записи и скажу прямо.';

  @override
  String get allergySevereShort => 'тяжёлая';

  @override
  String get allergyTitle => 'Аллергии';

  @override
  String anChartGoal(String value) {
    return 'цель $value';
  }

  @override
  String get anDaysInNorm => 'дней в норме';

  @override
  String anDonePercent(int percent) {
    return '$percent% пройдено';
  }

  @override
  String anEtaHead(String date) {
    return 'При текущем темпе цель около *$date*';
  }

  @override
  String get anForMonth => 'за месяц';

  @override
  String get anForQuarter => 'за 3 месяца';

  @override
  String get anForYear => 'за год';

  @override
  String get anGoalProgress => 'Прогресс к цели';

  @override
  String get anKcal => 'Калории';

  @override
  String get anKcalAvg => 'в среднем за день';

  @override
  String get anKcalEmpty =>
      'За этот период пока ничего не записано. Скажи Норе, что ешь, и график соберётся сам.';

  @override
  String anKcalTotal(Object u) {
    return 'за период, $u';
  }

  @override
  String anMacroGoal(String grams) {
    return 'норма $grams';
  }

  @override
  String get anMacrosAvg => 'БЖУ в среднем';

  @override
  String get anMacrosEmpty =>
      'Среднее появится, как только будет что усреднять: запиши хотя бы один день.';

  @override
  String get anMeasures => 'Замеры';

  @override
  String anMeasuresChange(String period) {
    return 'изменение $period';
  }

  @override
  String get anMeasuresEmpty => 'Замеров пока нет.';

  @override
  String get anMeasuresEmptyHint => 'Замеряйся раз в месяц, и я покажу, что движется';

  @override
  String get anMonth => 'Месяц';

  @override
  String get anNow => 'сейчас';

  @override
  String anNowKg(Object u) {
    return 'текущий, $u';
  }

  @override
  String get anOneReading => 'один замер';

  @override
  String get anOneWeighing =>
      'Пока один замер. Второй покажет направление, и с него начнётся линия.';

  @override
  String get anPerDay => 'за день';

  @override
  String get anQuarter => '3 месяца';

  @override
  String anShareOfNorm(int share) {
    return '$share% от нормы';
  }

  @override
  String anStartKg(Object u) {
    return 'старт, $u';
  }

  @override
  String anTargetKg(Object u) {
    return 'цель, $u';
  }

  @override
  String get anTitle => 'Аналитика';

  @override
  String get anWater => 'Гидратация';

  @override
  String anWaterAvg(Object u) {
    return 'в среднем, $u';
  }

  @override
  String anWaterGoal(String ml) {
    return 'норма $ml';
  }

  @override
  String get anWeek => 'Неделя';

  @override
  String get anWeightEmpty =>
      'Кривая появится после второго взвешивания. Скажи Норе вес, и она сама его запишет.';

  @override
  String get anYear => 'Год';

  @override
  String get assistantAddMemory => 'Добавить в память';

  @override
  String get assistantCollapse => 'Свернуть';

  @override
  String get assistantExample => 'Например, не ем грибы';

  @override
  String get assistantForget => 'Забыть';

  @override
  String assistantHint(String name) {
    return '$name ведёт дневник вместе с тобой и помнит то, что ты о себе расскажешь.';
  }

  @override
  String get assistantMemory => 'Память';

  @override
  String get assistantMemoryEmpty => 'Пока ничего не запомнила.';

  @override
  String get assistantMemoryEmptyHint => 'Память появляется из разговоров, или добавь вручную';

  @override
  String assistantPinned(int count, int pinned) {
    return '$count, закреплено $pinned';
  }

  @override
  String get assistantTitle => 'Помощник';

  @override
  String get assistantWhatToRemember => 'Что помнить';

  @override
  String get authAgain => 'Подтверждение пароля';

  @override
  String get authAgainDiffers => 'Пароли не совпадают';

  @override
  String get authAgainEmpty => 'Повтори пароль';

  @override
  String get authAgainHint => 'ещё раз';

  @override
  String authAgainIn(int sec) {
    return 'Отправить ещё раз можно через $sec с';
  }

  @override
  String get authCode => 'Код из письма';

  @override
  String get authCodeAction => 'Подтвердить';

  @override
  String get authCodeBad => 'Код не подходит или уже устарел';

  @override
  String authCodeHint(String mail) {
    return 'Отправили код на $mail. Введи шесть цифр из письма.';
  }

  @override
  String get authCodeShort => 'Код из 6 цифр';

  @override
  String get authCodeTitle => 'Подтверди почту';

  @override
  String get authForgotAction => 'Отправить код';

  @override
  String get authForgotHint => 'Отправим код на почту, а потом придумаешь новый пароль.';

  @override
  String get authForgotLink => 'Забыли?';

  @override
  String get authForgotTitle => 'Новый пароль';

  @override
  String get authMail => 'Почта';

  @override
  String get authMailBad => 'Похоже, в адресе ошибка';

  @override
  String get authOr => 'или';

  @override
  String get authPass => 'Пароль';

  @override
  String get authPassEmpty => 'Введи пароль';

  @override
  String get authPassHint => 'от 5 букв и знак';

  @override
  String get authPassNew => 'Новый пароль';

  @override
  String get authPassWeak => 'Пароль ненадёжный: минимум 5 букв и одна цифра или знак';

  @override
  String get authResetAction => 'Сохранить пароль';

  @override
  String get authSendAgain => 'Отправить ещё раз';

  @override
  String get authSignInAction => 'Войти';

  @override
  String get authSignInTitle => 'Вход';

  @override
  String get authSignUpAction => 'Создать аккаунт';

  @override
  String get authSignUpLink => 'Зарегистрироваться';

  @override
  String get authSignUpTitle => 'Заведём аккаунт';

  @override
  String get barCamera => 'Камера';

  @override
  String barGrams(String grams) {
    return '$grams';
  }

  @override
  String get barHint => 'Привет, я Нора. Пиши или говори как обычно, и я пойму.';

  @override
  String get barHintBorscht => 'Борщ 300 г на обед';

  @override
  String get barHintDelete => 'Удали последнюю запись';

  @override
  String get barHintEggs => 'Два яйца и тост';

  @override
  String get barHintMore =>
      '«два яйца и тост», «выпил 300 воды», «бег 40 минут»: разберу и запишу в нужную карточку';

  @override
  String get barHintProtein => 'Сколько белка осталось?';

  @override
  String get barHintRun => 'Бег 40 минут';

  @override
  String get barHintWater => 'Выпил 500 мл воды';

  @override
  String get barHintWeighed => 'Взвешивание: 78.8';

  @override
  String get barHintYesterday => 'Что я ел вчера?';

  @override
  String get barLogsInto => 'Записываю в ';

  @override
  String get barMic => 'Микрофон';

  @override
  String get barSend => 'Отправить';

  @override
  String get camAgain => 'Ещё раз';

  @override
  String get camAllergen => 'Аллерген!';

  @override
  String camAllergyContains(String list) {
    return 'Содержит твой аллерген: $list';
  }

  @override
  String camAllergyTraces(String list) {
    return 'Может содержать следы: $list';
  }

  @override
  String get camAskNoraInstead => 'Этикетки нет, спросить Нору';

  @override
  String get camBarcode => 'Штрихкод';

  @override
  String get camBusy => 'Камера не открылась. Чаще всего её занимает другое приложение.';

  @override
  String get camCouldNotRead => 'Не вышло разобрать снимок';

  @override
  String get camDish => 'Фото';

  @override
  String camEstimate(Object u) {
    return ' $u, оценка';
  }

  @override
  String get camFlash => 'Вспышка';

  @override
  String get camFromPack => 'Числа с упаковки. Запись не стоит токенов.';

  @override
  String get camGallery => 'Из галереи';

  @override
  String get camGapNote => 'Этого числа не знает ни одна база. Сними этикетку, и я его дочитаю.';

  @override
  String get camHintBarcode => 'код в рамку';

  @override
  String get camHintDish => 'наведи на тарелку или пачку';

  @override
  String camIngredients(String text) {
    return 'Состав: $text';
  }

  @override
  String camIntoSlot(String slot) {
    return 'в $slot';
  }

  @override
  String camKcalFor(String grams, Object u) {
    return ' $u за $grams';
  }

  @override
  String camKcalPer(String grams, Object u) {
    return ' $u на $grams';
  }

  @override
  String get camLabelAim => 'наведи на таблицу пищевой ценности';

  @override
  String get camLabelNoShot => 'Кадр не вышел. Попробуй снять этикетку ещё раз.';

  @override
  String camLogInto(String slotInto) {
    return 'Записать $slotInto';
  }

  @override
  String get camNoPermission => 'Нет доступа к камере. Его можно дать в настройках телефона.';

  @override
  String get camNoScanner => 'Этот телефон не умеет читать коды камерой.';

  @override
  String get camNoTokens => 'Токены кончились';

  @override
  String get camNotAProduct => 'Это не штрихкод товара';

  @override
  String get camNotAProductNote =>
      'Прочиталась ссылка или служебный код. Наведи на полоску с цифрами под ней.';

  @override
  String get camNotRead => 'Не разобрала';

  @override
  String get camOffline =>
      'Код прочитан, но спросить о нём некого. Попробуй, когда появится связь.';

  @override
  String get camOfflineShot => 'Не достаю сеть. Снимок можно отправить Норе позже';

  @override
  String get camOfflineTitle => 'Нет сети';

  @override
  String get camPer100 => 'Точного веса на упаковке нет: числа за 100 г.';

  @override
  String camPortionPack(String g) {
    return 'Порция с упаковки: $g. Числа за порцию.';
  }

  @override
  String get camReading => 'Читаю…';

  @override
  String get camSendToNora => 'Отправить Норе';

  @override
  String get camServerDown => 'Это не из-за кода и не из-за камеры. Попробуй через минуту.';

  @override
  String get camServerDownTitle => 'Наш сервер не ответил';

  @override
  String get camShoot => 'Снять';

  @override
  String get camShootLabel => 'Сфотографировать этикетку';

  @override
  String get camShotFailed => 'Кадр не вышел';

  @override
  String get camShotReady => 'Снимок готов';

  @override
  String get camShotReadyNote =>
      'Нора разберёт его и ответит в чате: назовёт блюдо, оценит порцию и покажет, откуда взялось число. Стоит два токена.';

  @override
  String get camSignedOut =>
      'Сессия недействительна, поэтому справочник нас не узнаёт. Войди в приложение заново, и сканер заработает.';

  @override
  String get camSignedOutTitle => 'Нужно войти заново';

  @override
  String get camSlow => 'Код прочитан, а справочник задержался. Попробуй ещё раз.';

  @override
  String get camSlowTitle => 'Ответ не успел';

  @override
  String get camStillWorks => 'Снимок блюда и галерея работают как всегда.';

  @override
  String get camTitle => 'Сканер';

  @override
  String get camTookTooLong => 'Разбор затянулся. Попробуй ещё раз';

  @override
  String get camUnknownCode => 'Этого товара нет ни в одной базе';

  @override
  String get camUnknownCodeNote =>
      'Ни в нашей, ни в открытой. Сними таблицу пищевой ценности с упаковки, и я перепишу числа с неё. Это бесплатно.';

  @override
  String get chatPro => 'Pro';

  @override
  String get deleteAskBody1 =>
      'Этот телефон станет чистым сразу: дневник, профиль, разговор с Норой, вход. Приложение вернётся на первый экран.';

  @override
  String get deleteAskBody2 =>
      'На сервере аккаунт встанет в очередь на окончательное удаление: оно занимает до 30 рабочих дней. Пока мы его не подтвердим, вход тем же аккаунтом вернёт всё назад и отменит запрос.';

  @override
  String get deleteAskCta => 'Да, удалить';

  @override
  String get deleteAskTitle => 'Удалить аккаунт?';

  @override
  String get deleteConfirm =>
      'Я понимаю, что данные будут удалены навсегда и восстановить их не выйдет.';

  @override
  String get deleteDays => 'Дней с Calvi';

  @override
  String get deleteEntries => 'Записей в дневнике';

  @override
  String deleteFailed(String why) {
    return 'Не удалось удалить: $why';
  }

  @override
  String get deleteForever => 'Удалить навсегда';

  @override
  String get deleteNote =>
      'Удаляется всё: дневник, вес, замеры, аллергии, препараты, история разговоров. Восстановить после этого невозможно.';

  @override
  String get deleteProManage => 'Управлять подпиской';

  @override
  String deleteProNote(String store) {
    return 'Удаление аккаунта не отменяет Calvi Pro. $store будет списывать деньги и дальше, пока саму подписку не отменили, поэтому отменить её нужно до удаления аккаунта.';
  }

  @override
  String get deleteProStoreAny => 'Магазин';

  @override
  String get deleteSubNote =>
      'Если дело в подписке, её можно отменить отдельно в App Store или Google Play, не удаляя аккаунт.';

  @override
  String get deleteTitle => 'Удалить аккаунт';

  @override
  String get deleteWeighings => 'Замеров веса';

  @override
  String get dictationBusy => 'Микрофон занят. Попробуй ещё раз';

  @override
  String get dictationFailed => 'Диктовка не вышла';

  @override
  String get dictationNoMatch => 'Не услышала ничего понятного';

  @override
  String get dictationNoNetwork => 'Распознаванию нужна сеть';

  @override
  String get dictationNoPermission => 'Нет доступа к микрофону';

  @override
  String get dictationSilence => 'Тишина. Попробуй ещё раз ближе к микрофону';

  @override
  String get dictationUnavailable => 'Диктовка недоступна на этом телефоне';

  @override
  String get doseCapFew => 'капсулы';

  @override
  String get doseCapMany => 'капсул';

  @override
  String get doseCapOne => 'капсула';

  @override
  String get doseDropFew => 'капли';

  @override
  String get doseDropMany => 'капель';

  @override
  String get doseDropOne => 'капля';

  @override
  String get doseMlFew => 'мл';

  @override
  String get doseMlMany => 'мл';

  @override
  String get doseMlOne => 'мл';

  @override
  String get doseShotFew => 'укола';

  @override
  String get doseShotMany => 'уколов';

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
      other: '$count записи',
      many: '$count записей',
      few: '$count записи',
      one: '$count запись',
      zero: '0 записей',
    );
    return '$_temp0';
  }

  @override
  String get eraseAskBody1 =>
      'Исчезнет весь дневник за всё время: блюда, вода, вес, замеры, тренировки, препараты и разговор с Норой. На всех устройствах, потому что стирается и копия на сервере.';

  @override
  String get eraseAskBody2 =>
      'Останутся: учётная запись, вход, токены с балансом и настройки профиля. Это не выход из аккаунта, это чистый лист в нём.';

  @override
  String get eraseAskCta => 'Удалить всё';

  @override
  String get eraseAskTitle => 'Удалить все записи?';

  @override
  String get eraseDataTitle => 'Удалить данные';

  @override
  String get eraseDone => 'Дневник стёрт. Чистый лист.';

  @override
  String eraseFailed(String why) {
    return 'Не удалось стереть: $why';
  }

  @override
  String get eraseNoNet => 'нет сети. Включи интернет и попробуй ещё раз';

  @override
  String get eraseSlow => 'сервер долго отвечает. Попробуй ещё раз через минуту';

  @override
  String get eraseSureBody =>
      'Это необратимо. Дневник исчезнет навсегда, и вернуть его не сможем ни ты, ни мы.';

  @override
  String get eraseSureCta => 'Да, удалить навсегда';

  @override
  String get eraseSureTitle => 'Точно удалить?';

  @override
  String get eveningAnd => ' и ';

  @override
  String get eveningBreakfastAcc => 'завтрак';

  @override
  String get eveningDinnerAcc => 'ужин';

  @override
  String get eveningEmptyDay => 'День пустой. Что сегодня было на еду?';

  @override
  String eveningLogged(String slot) {
    return 'Записала $slot?';
  }

  @override
  String get eveningLunchAcc => 'обед';

  @override
  String eveningMissing(String list) {
    return 'Ещё не записаны $list. Что из этого было?';
  }

  @override
  String get eveningWater => 'Сколько воды вышло за день?';

  @override
  String get fieldBiceps => 'Бицепс';

  @override
  String get fieldChest => 'Грудь';

  @override
  String get fieldHips => 'Бёдра';

  @override
  String get fieldNeck => 'Шея';

  @override
  String get fieldThigh => 'Бедро';

  @override
  String get fieldWaist => 'Талия';

  @override
  String get fieldWeight => 'Вес';

  @override
  String get fieldWrist => 'Запястье';

  @override
  String get goalBecomes => 'Станет';

  @override
  String get goalCurrent => 'Текущая цель ';

  @override
  String get goalDailyNorm => 'Дневная норма';

  @override
  String goalDiff(String kg) {
    return 'разница $kg';
  }

  @override
  String get goalDirection => 'Направление';

  @override
  String get goalEta => 'Цель примерно';

  @override
  String goalFromStart(String kg) {
    return ' от $kg на старте. ';
  }

  @override
  String get goalFromToday => 'Новая цель начнётся от сегодняшнего веса.';

  @override
  String get goalKeepNote => 'Норма держит текущий вес: сколько тратишь, столько и возвращаешь.';

  @override
  String get goalKeepShort => 'Держать';

  @override
  String get goalNew => 'Поставить новую цель';

  @override
  String get goalNewTitle => 'Новая цель';

  @override
  String get goalPace => 'Темп';

  @override
  String get goalPaceFast => 'Быстро';

  @override
  String get goalPaceOk => 'Это темп, который большинство выдерживает без срывов.';

  @override
  String get goalPaceSlow => 'Медленно';

  @override
  String goalPaceUnit(Object u) {
    return '$u в неделю';
  }

  @override
  String get goalPaceUsual => 'Рекомендовано';

  @override
  String goalRange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get goalReplaceNote =>
      'Цель не редактируется, она заменяется. Прогресс начнёт считаться от сегодняшнего веса, а старая цель останется в истории. Подтверждаешь замену?';

  @override
  String get goalSet => 'Поставить';

  @override
  String get goalTarget => 'Целевой вес';

  @override
  String get goalWas => 'Было';

  @override
  String gramsUnit(String grams) {
    return '$grams';
  }

  @override
  String get helloDishBread => 'Хлеб ржаной';

  @override
  String get helloDishEggs => 'Яичница из двух яиц';

  @override
  String get helloSaid => 'два яйца и тост';

  @override
  String get helloSlotSub => 'два блюда';

  @override
  String get helloStepCount => 'Посчитаю калории';

  @override
  String get helloStepLog => 'Запишу в день';

  @override
  String get helloStepSay => 'Скажи, что ешь';

  @override
  String heroBurned(String kcal) {
    return '-$kcal за тренировку';
  }

  @override
  String get heroDays => 'дней';

  @override
  String heroFrom(String kcal) {
    return ' от $kcal';
  }

  @override
  String heroGoalKg(Object u) {
    return 'цель, $u';
  }

  @override
  String heroKcal(Object u) {
    return ' $u';
  }

  @override
  String heroKg(Object u) {
    return ' $u';
  }

  @override
  String get heroLeft => 'осталось ';

  @override
  String heroOf(String kcal) {
    return ' из $kcal';
  }

  @override
  String get heroOver => 'перебор на ';

  @override
  String get heroWeekOpen => 'Разбор недели';

  @override
  String heroWeightFrom(String kg) {
    return 'сейчас, от $kg на старте цели';
  }

  @override
  String get islandLast => 'последний приём пищи';

  @override
  String get islandLeft => 'ккал осталось';

  @override
  String get islandNothing => 'сегодня ещё ничего не записано';

  @override
  String get islandOver => 'ккал перебор';

  @override
  String get islandToday => 'осталось на сегодня';

  @override
  String get islandTodayOver => 'перебор за сегодня';

  @override
  String kcalUnit(String kcal) {
    return '$kcal';
  }

  @override
  String get langSection => 'Язык интерфейса';

  @override
  String get langSystem => 'Язык устройства';

  @override
  String get legalOnTheWeb => 'Open on the web';

  @override
  String legalUpdated(String date) {
    return 'Updated $date';
  }

  @override
  String liveBody(String eaten, String goal) {
    return 'съедено $eaten из $goal';
  }

  @override
  String get liveChannel => 'Счётчик дня';

  @override
  String get liveChannelHint => 'Сколько осталось на сегодня, пока приложение работает';

  @override
  String liveLeft(String kcal) {
    return 'Осталось $kcal ккал';
  }

  @override
  String liveOver(String kcal) {
    return 'Перебор $kcal ккал';
  }

  @override
  String get loginNoToken => 'Google не отдал токен';

  @override
  String get loginNotConfigured => 'вход не настроен в этой сборке';

  @override
  String get loginNotSynced =>
      'Не все записи доехали на сервер. Попробуй ещё раз через минуту: вход ничего не стирает, пока не сохранено всё';

  @override
  String loginServer(String why) {
    return 'сервер: $why';
  }

  @override
  String get loginSlow => 'Google не ответил за минуту. Попробуй ещё раз';

  @override
  String get macroCNone => 'У ?';

  @override
  String macroCShort(int value) {
    return 'У $value';
  }

  @override
  String get macroCarbs => 'Углеводы';

  @override
  String get macroCarbsCaps => 'УГЛЕВОДЫ';

  @override
  String get macroCarbsLetter => 'У';

  @override
  String get macroFNone => 'Ж ?';

  @override
  String macroFShort(int value) {
    return 'Ж $value';
  }

  @override
  String get macroFat => 'Жиры';

  @override
  String get macroFatCaps => 'ЖИРЫ';

  @override
  String get macroFatLetter => 'Ж';

  @override
  String get macroMedsCaps => 'ПРЕПАРАТЫ';

  @override
  String macroOfGrams(String goal) {
    return ' / $goal';
  }

  @override
  String get macroPNone => 'Б ?';

  @override
  String macroPShort(int value) {
    return 'Б $value';
  }

  @override
  String get macroProtein => 'Белки';

  @override
  String get macroProteinCaps => 'БЕЛКИ';

  @override
  String get macroProteinLetter => 'Б';

  @override
  String get mealAuto => 'авто ';

  @override
  String get mealEditDelete => 'Удалить запись';

  @override
  String mealEditKcal(Object u) {
    return '$u';
  }

  @override
  String get mealEditSave => 'Сохранить';

  @override
  String get mealEmpty => 'Тут пока пусто. Напиши, что было, и я запишу.';

  @override
  String mealGrams(String grams) {
    return '$grams';
  }

  @override
  String get mealThinking => 'Нора считает…';

  @override
  String get measureAdd => 'Добавить замер';

  @override
  String get measureCollapse => 'Свернуть';

  @override
  String measureCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count замера',
      many: '$count замеров',
      few: '$count замера',
      one: '$count замер',
    );
    return '$_temp0';
  }

  @override
  String measureLast(String ago) {
    return 'последний $ago';
  }

  @override
  String get measureNever => 'ещё не делал';

  @override
  String get measureNothing => 'ещё ничего';

  @override
  String get measurePick =>
      'Выбери, что будешь мерить. Хватит одного, если остальное не интересует.';

  @override
  String get measureSave => 'Сохранить замеры';

  @override
  String get measureStats => 'Статистика замеров';

  @override
  String get measureTitle => 'Замеры';

  @override
  String get medsAdd => 'Добавить препарат';

  @override
  String get medsAllTaken => 'На сегодня всё принято';

  @override
  String get medsAt => 'Во сколько';

  @override
  String get medsCourse => 'Курс';

  @override
  String get medsDose => 'Доза';

  @override
  String get medsEmpty => 'Тут пусто. Добавь препарат, и я напомню в нужное время.';

  @override
  String get medsEmptyHint => 'Веду журнал приёмов, дозировку не считаю';

  @override
  String get medsFinish => 'Завершить курс';

  @override
  String medsFirstDose(String name, String day, String at) {
    return '$name, первый приём $day в $at';
  }

  @override
  String get medsHours => 'Часы';

  @override
  String get medsHowOften => 'Как часто';

  @override
  String get medsMine => 'Мои препараты';

  @override
  String get medsName => 'Название';

  @override
  String get medsNameExample => 'Например, Магний B6';

  @override
  String get medsNew => 'Новый препарат';

  @override
  String get medsNextAt => 'Дальше в ';

  @override
  String get medsNoneToday => 'Сегодня приёмов нет';

  @override
  String get medsNote => 'Заметка';

  @override
  String get medsNow => 'СЕЙЧАС';

  @override
  String get medsOne => 'Препарат';

  @override
  String get medsPast => 'Прошлые';

  @override
  String get medsPastEmpty =>
      'Тут будут курсы, которые ты уже не принимаешь. Препарат, убранный из списка, остаётся в днях, когда ты его пил.';

  @override
  String get medsPerTake => 'Сколько за раз';

  @override
  String get medsRemind => 'Напоминать';

  @override
  String get medsRemindHint => 'в выбранные часы';

  @override
  String get medsResume => 'Возобновить курс';

  @override
  String get medsSchedule => 'Расписание';

  @override
  String medsSince(String date) {
    return 'с $date';
  }

  @override
  String get medsTime => 'Время';

  @override
  String get medsTitle => 'Препараты';

  @override
  String get medsTomorrow => 'завтра';

  @override
  String get medsUnmarked => 'Ещё не отмечено: ';

  @override
  String medsUntil(String date) {
    return 'до $date';
  }

  @override
  String get menuAbout => 'О приложении';

  @override
  String get menuAllergy => 'Аллергии';

  @override
  String get menuAnalytics => 'Аналитика';

  @override
  String get menuDiary => 'Дневник';

  @override
  String get menuHintFree => 'бесплатный';

  @override
  String menuHintKcal(String n) {
    return 'сегодня $n';
  }

  @override
  String menuHintMore(int n) {
    return 'ещё $n';
  }

  @override
  String get menuHintNoAllergy => 'нет';

  @override
  String get menuHintNoMeds => 'без курсов';

  @override
  String get menuHintNothing => 'пока ничего не записано';

  @override
  String menuHintOnGoal(int ok, int total) {
    return 'в норме $ok из $total';
  }

  @override
  String get menuHintRecipes => 'от Норы, под твою норму';

  @override
  String get menuHintWeekFriday => 'с пятницы, 18:00';

  @override
  String get menuHintWeekOpen => 'открыто до воскресенья';

  @override
  String get menuHintWeekYoung => 'неделя только началась';

  @override
  String get menuMeds => 'Препараты';

  @override
  String get menuPlan => 'Подписка';

  @override
  String get menuRecipes => 'Рецепты';

  @override
  String get menuSettings => 'Настройки';

  @override
  String get menuTitle => 'Меню';

  @override
  String get menuWeek => 'Разбор недели';

  @override
  String get noraName => 'Нора';

  @override
  String get normAuto => 'Считать автоматически';

  @override
  String get normAutoFrom => 'Из веса на старте цели, роста, возраста, активности и темпа: ';

  @override
  String normAutoHint(String kcal) {
    return 'из веса, роста, возраста, активности и цели: $kcal';
  }

  @override
  String get normAutoShort => 'Автоматически';

  @override
  String get normByHand => 'Задать вручную';

  @override
  String get normByHandHint => 'аналитика будет считать относительно этого числа';

  @override
  String get normByHandShort => 'Вручную';

  @override
  String get normCalculatedHead => 'Расчётное значение ';

  @override
  String get normCalculatedTail => '. Вернуться к нему можно выбором «Автоматически».';

  @override
  String get normFitCarbs => 'Подогнать углеводы под норму';

  @override
  String get normFits => 'Состав сходится с нормой';

  @override
  String normGrams(String grams) {
    return '$grams';
  }

  @override
  String normKcalOf(String kcal) {
    return '$kcal';
  }

  @override
  String normMacroSplit(int protein, int fat, String carbs) {
    return '$protein / $fat / $carbs';
  }

  @override
  String get normMacros => 'БЖУ';

  @override
  String get normManual => 'переопределено вручную';

  @override
  String normOf(String kcal) {
    return 'из $kcal';
  }

  @override
  String normOffOver(String sum, int off) {
    return 'Состав даёт $sum, на $off больше нормы';
  }

  @override
  String normOffUnder(String sum, int off) {
    return 'Состав даёт $sum, на $off меньше нормы';
  }

  @override
  String normPerDay(Object u) {
    return '$u в день';
  }

  @override
  String get normTitle => 'Норма';

  @override
  String get normWater => 'Вода';

  @override
  String get normWaterHead => 'Это ';

  @override
  String normWaterPerKg(String ml) {
    return '$ml';
  }

  @override
  String get normWaterTail =>
      ' на килограмм веса. Привычная ориентировочная вилка это 30-40 мл, но она зависит от жары и тренировок, поэтому число тут не жёсткое.';

  @override
  String get normWhere => 'Откуда это число';

  @override
  String get notifyChannel => 'Напоминания';

  @override
  String get notifyChannelHint => 'Напоминания о еде, воде, препаратах и взвешивании';

  @override
  String get notifyDenied =>
      'Телефон не разрешил уведомления. Включи их в настройках системы, и напоминания заработают.';

  @override
  String get nutriAdded => 'Добавленный сахар';

  @override
  String nutriAddedNorm(int g, int better) {
    return 'до $g г, лучше до $better';
  }

  @override
  String get nutriAddedShort => 'Добавленный';

  @override
  String get nutriAddedSource => 'ВОЗ: меньше 10% калорий, лучше меньше 5%';

  @override
  String get nutriAddedWhat =>
      'Сахар, сиропы и мёд, которые кладут в продукт. Собственный сахар фрукта и молока сюда не входит.';

  @override
  String nutriAtLeast(String text) {
    return 'как минимум $text';
  }

  @override
  String get nutriFiber => 'Клетчатка';

  @override
  String nutriFiberNorm(int g) {
    return '$g г в сутки';
  }

  @override
  String get nutriFiberShort => 'Клетчатка';

  @override
  String get nutriFiberSource => 'EFSA: минимум 25 г, или 14 г на каждую тысячу калорий';

  @override
  String get nutriFiberWhat =>
      'Часть растительной еды, которую тело не переваривает. Держит пищеварение и дольше оставляет сытым.';

  @override
  String get nutriFrom => 'Откуда сегодня';

  @override
  String nutriGap(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count блюда без этих чисел, поэтому это нижняя граница.',
      many: '$count блюд без этих чисел, поэтому это нижняя граница.',
      few: '$count блюда без этих чисел, поэтому это нижняя граница.',
      one: 'Одно блюдо без этих чисел, поэтому это нижняя граница.',
    );
    return '$_temp0';
  }

  @override
  String get nutriGapAll =>
      'Об этом сегодня ещё ничего не известно: ни одно блюдо дня не несёт этих чисел.';

  @override
  String get nutriNorm => 'Норма';

  @override
  String nutriNowGoal(String now, int goal) {
    return '$now г сегодня из $goal';
  }

  @override
  String nutriNowSodium(String now, String salt) {
    return '$now г сегодня, это $salt г соли';
  }

  @override
  String nutriNowSugar(String now, String added) {
    return '$now г сегодня, из них добавленного $added';
  }

  @override
  String get nutriProHidden => 'доступно с Pro';

  @override
  String get nutriProKept =>
      'Считаются они уже сейчас, на каждой записи, и без подписки тоже. Ничего не теряется: как только появится Pro, этот день и весь месяц позади откроются с числами.';

  @override
  String get nutriProTitle => 'Нутриенты в Pro';

  @override
  String get nutriProWhat =>
      'Клетчатка, сахар, добавленный сахар, натрий и насыщенные жиры входят в Pro. Значки остаются на месте, а сами числа открывает подписка.';

  @override
  String nutriRest(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'и ещё $count',
      many: 'и ещё $count',
      few: 'и ещё $count',
      one: 'и ещё $count',
    );
    return '$_temp0';
  }

  @override
  String get nutriSat => 'Насыщенные жиры';

  @override
  String nutriSatNorm(int g) {
    return 'до $g г в сутки';
  }

  @override
  String get nutriSatShort => 'Насыщенные';

  @override
  String get nutriSatSource => 'ВОЗ 2023: меньше 10% калорий';

  @override
  String get nutriSatWhat =>
      'Жиры животных продуктов, масла и сыра, а также кокосового и пальмового масла.';

  @override
  String get nutriSodium => 'Натрий';

  @override
  String get nutriSodiumNorm => 'до 2 г в сутки, это 5 г соли';

  @override
  String get nutriSodiumNote =>
      'В домашнем блюде соль кладёт повар. Мы берём обычную норму для рода блюда, поправить можно в персонализации.';

  @override
  String get nutriSodiumShort => 'Натрий';

  @override
  String get nutriSodiumSource => 'ВОЗ. От калорийности не зависит';

  @override
  String get nutriSodiumWhat =>
      'Соль это натрий, умноженный на 2.5. Большую часть дают хлеб, колбасные, сыры и еда вне дома, а не солонка на столе.';

  @override
  String get nutriSugar => 'Сахар';

  @override
  String get nutriSugarNorm => 'нормы нет';

  @override
  String get nutriSugarNote =>
      'Шкала под общим сахаром назвала бы яблоко проблемой. Смотри на соседнее число.';

  @override
  String get nutriSugarShort => 'Сахар';

  @override
  String get nutriSugarSource => 'ВОЗ и EFSA ограничивают добавленный сахар, а не общий';

  @override
  String get nutriSugarWhat =>
      'Все сахара вместе: и добавленные, и собственные сахара фруктов и молока.';

  @override
  String get nutriUnknown => 'сегодня ещё не считали';

  @override
  String get payDish => 'Паэлья с морепродуктами';

  @override
  String get payHavePromo => 'У меня есть промокод';

  @override
  String get payPeas => 'Горошек';

  @override
  String get payPortion => 'Одна из четырёх порций · ≈350 г';

  @override
  String get payPromo => 'Промокод';

  @override
  String get payPromoApply => 'Применить';

  @override
  String get payPromoBad => 'Такого кода нет';

  @override
  String get payPromoDrop => 'Убрать промокод';

  @override
  String payPromoOff(int off) {
    return '−$off% на любой план';
  }

  @override
  String get payRice => 'Рис';

  @override
  String get payShrimp => 'Креветки';

  @override
  String payTrial(int n) {
    return 'Начать с $n пробными токенами';
  }

  @override
  String get photoDish => 'Блюдо';

  @override
  String get photoNotRecognized => 'Не узнала блюдо на этом снимке';

  @override
  String get planBuy => 'Оформить';

  @override
  String get planClose => 'Закрыть';

  @override
  String get planCurrent => 'текущий';

  @override
  String get planFailed => 'Покупка не прошла';

  @override
  String get planFree => 'Бесплатный';

  @override
  String planFrom(String plan, String date) {
    return '$plan с $date';
  }

  @override
  String planFromShort(String date) {
    return 'с $date';
  }

  @override
  String get planLater => 'Не сейчас';

  @override
  String get planManage => 'Управлять в магазине';

  @override
  String get planMonth => 'Месяц';

  @override
  String get planMonthBilled => 'ежемесячное списание';

  @override
  String get planMonthly => 'Pro месячная';

  @override
  String get planNext => 'Дальше';

  @override
  String get planNothingToRestore => 'Покупок на этом аккаунте нет';

  @override
  String get planNow => 'Сейчас';

  @override
  String get planOn => 'Pro';

  @override
  String get planPerMonth => '/мес';

  @override
  String get planPerkChat => 'Разговоры с Норой без ограничений';

  @override
  String get planPerkChatSub => 'сейчас одно сообщение это один токен';

  @override
  String get planPerkMemory => 'Персональная память Норы';

  @override
  String get planPerkMemorySub => 'новое она запоминает в разговоре, а разговор стоит токен';

  @override
  String get planPerkPhoto => 'Фото блюд без счёта';

  @override
  String get planPerkPhotoSub => 'сейчас снимок стоит два токена';

  @override
  String get planPerkRecipes => 'Рецепты от Норы без счёта';

  @override
  String get planPerkRecipesSub => 'сейчас подбор блюд стоит один токен';

  @override
  String get planPerkWeek => 'Разбор недели когда угодно';

  @override
  String get planPerkWeekSub => 'сейчас разбор стоит два токена';

  @override
  String get planPerks => 'Что даёт подписка';

  @override
  String get planPlan => 'План';

  @override
  String get planPrivacy => 'Политика конфиденциальности';

  @override
  String get planRenewal =>
      'Подписка продлевается сама, пока её не отменить. Отменить можно в любое время в настройках магазина, из которого она оформлена.';

  @override
  String get planRenews => 'Продлится';

  @override
  String get planRestore => 'Восстановить покупки';

  @override
  String get planSignInGo => 'Войти';

  @override
  String get planSignInNote =>
      'Подписка привязывается к учётной записи с почтой. Так она не потеряется при смене телефона и будет на всех твоих устройствах.';

  @override
  String get planSignInTitle => 'Сначала войди в профиль';

  @override
  String get planStoreAsking => 'Спрашиваю у магазина цены…';

  @override
  String get planStoreOffline => 'Магазин не отвечает. Проверь подключение к интернету';

  @override
  String get planStoreQuiet => 'Магазин не отвечает. Попробуй позже';

  @override
  String get planSwitchMonth => 'Перейти на месячную';

  @override
  String get planSwitchYear => 'Перейти на годовую';

  @override
  String get planTariffs => 'Тарифы';

  @override
  String get planTerms => 'Условия использования';

  @override
  String get planTitle => 'Подписка';

  @override
  String get planTokens => 'Токены';

  @override
  String get planTokensFree => '40 в месяц';

  @override
  String get planTokensPro => 'Без ограничений';

  @override
  String get planUntil => 'Действует до';

  @override
  String get planYear => 'Год';

  @override
  String planYearBilled(String price) {
    return '$price раз в год';
  }

  @override
  String get planYearly => 'Pro годовая';

  @override
  String plateFor(String grams) {
    return 'за $grams';
  }

  @override
  String plateGrams(Object u) {
    return ' $u';
  }

  @override
  String plateKcal(Object u) {
    return '$u';
  }

  @override
  String get plateThinking => 'думаю';

  @override
  String get plateTotal => 'всего';

  @override
  String get privacyCrash => 'Отчёты о сбоях';

  @override
  String get privacyCrashHint => 'стек ошибки, без данных дневника';

  @override
  String get privacyDiaryHead => 'Дневник остаётся у тебя';

  @override
  String get privacyDiarySub => 'ни блюда, ни вес не идут в аналитику';

  @override
  String get privacyHealthHead => 'Здоровье не передаётся никому';

  @override
  String get privacyHealthSub => 'аллергии и препараты не покидают приложение';

  @override
  String get privacyNoPhotosHead => 'Фото блюд не хранятся';

  @override
  String get privacyNoPhotosSub => 'снимок идёт в обработку и исчезает';

  @override
  String get privacyNotCollected => 'Что мы не собираем';

  @override
  String get privacyOptional => 'Что можно выключить';

  @override
  String get privacyPhotosBold => 'не хранятся';

  @override
  String get privacyPhotosHead => 'Фото блюд ';

  @override
  String get privacyPhotosTail =>
      ': снимок идёт в обработку и исчезает. В аналитику не попадают ни блюда, ни вес, ни аллергии, ни препараты. Это особая категория персональных данных, и отдавать её третьей стороне нельзя независимо от удобства.';

  @override
  String get privacyStats => 'Обезличенная статистика';

  @override
  String get privacyStatsHint => 'какие экраны открывают, без содержимого записей';

  @override
  String get privacyTitle => 'Приватность';

  @override
  String get profileActivity => 'Активность';

  @override
  String get profileAge => 'Возраст';

  @override
  String get profileHeight => 'Рост';

  @override
  String get profileSex => 'Пол';

  @override
  String rcAllergyWarn(String names) {
    return 'В составе $names, а это в твоих аллергиях. Осторожно с этим рецептом.';
  }

  @override
  String get rcAskPlaceholder => 'курица, брокколи, рис';

  @override
  String rcChatGreet(String name) {
    return 'Спрашивай про «$name»: чем заменить продукт, как не испортить, что сделать заранее. Подскажу по ходу готовки.';
  }

  @override
  String get rcChatHello => 'Скажи, что есть на кухне, и я составлю рецепт.';

  @override
  String get rcChatHint => '«курица, брокколи, рис»: посоветую несколько блюд и посчитаю порцию';

  @override
  String get rcChatHintDinner => 'Ужин на 500 ккал';

  @override
  String get rcChatHintEggs => 'Быстрый завтрак из яиц';

  @override
  String get rcChatHintMince => 'Что приготовить из фарша?';

  @override
  String get rcChatHintOnly => 'Есть только сыр и макароны';

  @override
  String get rcChatPicks =>
      'Вот что можно из этого приготовить. Выбери блюдо, и рецепт ляжет в книгу.';

  @override
  String rcCount(int n) {
    return '$n рецептов';
  }

  @override
  String rcCountFew(int n) {
    return '$n рецепта';
  }

  @override
  String get rcCountOne => '1 рецепт';

  @override
  String rcDeleteBody(String name) {
    return '«$name» исчезнет из книги. Записи в дневнике, сделанные по нему, останутся.';
  }

  @override
  String get rcDeleteCta => 'Удалить';

  @override
  String get rcDeleteFailed => 'Не вышло удалить. Попробуй ещё раз.';

  @override
  String get rcDeleteTitle => 'Удалить рецепт?';

  @override
  String get rcDishHint => '«чем заменить рис?», «как не пересушить филе?», «можно ли заранее?»';

  @override
  String get rcDishHintAhead => 'Можно ли приготовить заранее?';

  @override
  String get rcDishHintDry => 'Как не пересушить филе?';

  @override
  String get rcDishHintKeeps => 'Сколько это хранится?';

  @override
  String get rcDishHintSwap => 'Чем заменить рис?';

  @override
  String get rcEmpty => 'Тут пусто. Скажи Норе, что есть на кухне, и первый рецепт появится.';

  @override
  String get rcEmptyMine => 'Своих рецептов ещё нет. Продиктуй Норе любой, и он встанет тут.';

  @override
  String get rcEyebrow => 'Кухня';

  @override
  String get rcFromMine => 'Мой';

  @override
  String get rcFromNora => 'От Норы';

  @override
  String get rcHelps => 'Нора поможет тебе создать рецепт';

  @override
  String get rcHeroA => 'Что приготовить';

  @override
  String get rcHeroB => 'сегодня';

  @override
  String get rcHeroLede =>
      'Скажи, что есть дома. Нора посоветует и посчитает порцию; свой рецепт тоже можно продиктовать.';

  @override
  String get rcItemsHead => 'Продукты';

  @override
  String rcItemsTotal(String g) {
    return 'всего $g';
  }

  @override
  String get rcJustNow => 'только что';

  @override
  String get rcLoadFailed => 'Книга рецептов не загрузилась. Потяни, чтобы попробовать ещё.';

  @override
  String rcMinutes(int n) {
    return '$n мин';
  }

  @override
  String get rcNoTools => 'Ничего, кроме ножа и миски';

  @override
  String rcOfDay(int p) {
    return 'это $p% дневной нормы';
  }

  @override
  String get rcPerServing => 'на порцию';

  @override
  String get rcPerServingHead => 'На порцию';

  @override
  String rcPortion(String g) {
    return 'порция $g';
  }

  @override
  String rcServingsFew(int n) {
    return '$n порции';
  }

  @override
  String rcServingsMany(int n) {
    return '$n порций';
  }

  @override
  String get rcServingsOne => '1 порция';

  @override
  String get rcStepsHead => 'Как готовить';

  @override
  String get rcSuggestFailed => 'Нора не смогла составить рецепты. Попробуй ещё раз.';

  @override
  String get rcTabAll => 'Все';

  @override
  String get rcTabMine => 'Мои';

  @override
  String get rcTabNora => 'От Норы';

  @override
  String get rcTitle => 'Рецепты';

  @override
  String get rcToolBlender => 'Блендер';

  @override
  String get rcToolGrill => 'Гриль';

  @override
  String get rcToolMixer => 'Миксер';

  @override
  String get rcToolOven => 'Духовка';

  @override
  String get rcToolPan => 'Сковорода';

  @override
  String get rcToolPot => 'Кастрюля';

  @override
  String get rcToolsHead => 'Нужно на кухне';

  @override
  String rcWhole(String kcal, String g) {
    return 'Всё блюдо: $kcal, $g';
  }

  @override
  String get remAbout => 'О чём';

  @override
  String get remAdd => 'Добавить напоминание';

  @override
  String get remAt => 'Во сколько';

  @override
  String get remDelete => 'Удалить напоминание';

  @override
  String get remEdit => 'Напоминание';

  @override
  String get remEmpty => 'Пока ни одного напоминания.';

  @override
  String get remEmptyHint => 'Добавь то, о чём действительно забываешь, а не всё подряд';

  @override
  String get remHowOften => 'Как часто';

  @override
  String get remName => 'Название';

  @override
  String get remNew => 'Новое напоминание';

  @override
  String get remOpenMeds => 'Открыть препараты';

  @override
  String get remTime => 'Время';

  @override
  String get remTitle => 'Напоминания';

  @override
  String get reminderBodyMeal => 'Запиши, что было';

  @override
  String get reminderBodyMeds => 'По расписанию';

  @override
  String get reminderBodySummary => 'Что сегодня осталось незаписанным?';

  @override
  String get reminderBodyWater => 'Время попить';

  @override
  String get reminderBodyWeigh => 'Утром, до еды';

  @override
  String get reminderBodyWorkout => 'Запиши, если была';

  @override
  String get reminderMeal => 'Еда';

  @override
  String get reminderMealHint => 'напомню записать приём';

  @override
  String get reminderMeds => 'Препараты';

  @override
  String get reminderMedsHint => 'по расписанию из журнала';

  @override
  String get reminderSummary => 'Итог дня';

  @override
  String get reminderSummaryHint => 'коротко о дне перед сном';

  @override
  String get reminderWater => 'Вода';

  @override
  String get reminderWaterHint => 'напомню попить';

  @override
  String get reminderWeigh => 'Взвешивание';

  @override
  String get reminderWeighHint => 'чтобы график веса не рвался';

  @override
  String get reminderWorkout => 'Тренировка';

  @override
  String get reminderWorkoutHint => 'напомню о запланированной';

  @override
  String get repDaily => 'каждый день';

  @override
  String repEveryN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'каждые $count дня',
      many: 'каждые $count дней',
      few: 'каждые $count дня',
      one: 'каждый $count день',
    );
    return '$_temp0';
  }

  @override
  String get repEveryOther => 'через день';

  @override
  String get repPickDaily => 'Каждый день';

  @override
  String get repPickFromToday => 'Отсчёт от сегодня.';

  @override
  String get repPickInterval => 'Через день';

  @override
  String get repPickNoDays => 'Ни одного дня не выбрано, поэтому напоминание не сработает.';

  @override
  String get repPickWeekdays => 'Дни недели';

  @override
  String get repWeekdays => 'по будням';

  @override
  String get repWeekends => 'по выходным';

  @override
  String get repWeekly => 'раз в неделю';

  @override
  String get restoredBody1 =>
      'Этот аккаунт ждал удаления. Вход это отменил: дневник, профиль и настройки снова на этом телефоне.';

  @override
  String get restoredBody2 =>
      'Если аккаунт всё же нужно удалить, попроси об этом ещё раз в настройках. Любой вход до нашего подтверждения так же отменит запрос.';

  @override
  String get restoredOk => 'Понятно';

  @override
  String get restoredTitle => 'Данные восстановлены';

  @override
  String get setAbout => 'О приложении';

  @override
  String get setAccess => 'Доступ';

  @override
  String get setAllergies => 'Аллергии';

  @override
  String setAssistantLine(String name, int count) {
    return '$name, памяти $count';
  }

  @override
  String get setCustom => 'Персонализация';

  @override
  String get setCustomNote => 'Что показывает экран дня и как мы считаем соль';

  @override
  String get setDeleteAccount => 'Удалить аккаунт и данные';

  @override
  String get setFreeTierHead =>
      'Защитникам Украины, работникам ВСУ, ГСЧС, ДТЭК, медикам, волонтёрам и учителям прифронтовых зон платный тариф ';

  @override
  String get setFreeTierHow => ' Как получить';

  @override
  String get setFreeTierShort =>
      'Защитникам Украины, работникам ВСУ, ГСЧС, ДТЭК, медикам, волонтёрам и учителям прифронтовых зон платный тариф БЕСПЛАТНЫЙ';

  @override
  String get setFreeTierTelegram => 'Написать в Telegram';

  @override
  String get setFreeTierTitle => 'Бесплатный тариф';

  @override
  String get setFreeTierWord => 'БЕСПЛАТНЫЙ';

  @override
  String get setFreeTierWrite =>
      'Напишите разработчику, и платный тариф вам включат в тот же день.';

  @override
  String get setGoal => 'Цель';

  @override
  String get setGoalKeep => 'держать вес';

  @override
  String setGoalLine(String kg, String pace) {
    return '$kg, $pace/неделя';
  }

  @override
  String get setGroupAbout => 'О тебе';

  @override
  String get setGroupAccount => 'Аккаунт';

  @override
  String get setGroupAssistant => 'Помощник';

  @override
  String get setGroupDocs => 'Документы';

  @override
  String get setGroupHealth => 'Здоровье';

  @override
  String get setLang => 'Язык';

  @override
  String get setMedical => 'Медицинское предупреждение';

  @override
  String get setMeds => 'Препараты';

  @override
  String get setNorm => 'Норма';

  @override
  String setNormLine(String kcal) {
    return '$kcal';
  }

  @override
  String get setNutriLarge => 'Карточками';

  @override
  String get setNutriLargeHint => 'Пять столбиков с кольцами и подписями, как у макросов';

  @override
  String get setNutriNote => 'Клетчатка, сахар, натрий и насыщенные под макросами';

  @override
  String get setNutriOff => 'Не показывать';

  @override
  String get setNutriOffHint => 'Только белки, жиры и углеводы, как было';

  @override
  String get setNutriSmall => 'Строкой';

  @override
  String get setNutriSmallHint => 'Тихая строка под карточками: знак, число и цвет на грани';

  @override
  String get setNutriTitle => 'Нутриенты';

  @override
  String get setPlan => 'Подписка';

  @override
  String get setPlanFree => 'Бесплатно';

  @override
  String get setPolicy => 'Политика конфиденциальности';

  @override
  String get setPrivacy => 'Данные и аналитика';

  @override
  String get setProfile => 'Профиль';

  @override
  String setProfileLine(String sex, int age, String height) {
    return '$sex, $age, $height';
  }

  @override
  String get setReminders => 'Напоминания';

  @override
  String get setRemindersOff => 'выключены';

  @override
  String get setSaltLess => 'Меньше, чем обычно';

  @override
  String get setSaltMore => 'Больше, чем обычно';

  @override
  String get setSaltNote => 'Поправка к соли, которую мы предполагаем в домашнем блюде';

  @override
  String get setSaltTitle => 'Как ты солишь';

  @override
  String get setSaltUsual => 'Обычно';

  @override
  String get setTerms => 'Условия использования';

  @override
  String get setTheme => 'Тема';

  @override
  String get setTitle => 'Настройки';

  @override
  String get setUnits => 'Единицы';

  @override
  String get setUnset => 'не указано';

  @override
  String get sexOther => 'Другое';

  @override
  String get sexShortFemale => 'Ж';

  @override
  String get sexShortMale => 'М';

  @override
  String get slotBreakfast => 'Завтрак';

  @override
  String get slotByHand => 'Ввести числа вручную';

  @override
  String get slotCancel => 'Отменить';

  @override
  String get slotDinner => 'Ужин';

  @override
  String slotEraseBody(String name) {
    return '«$name» стоит без чисел. Строка исчезнет из дня.';
  }

  @override
  String get slotEraseDo => 'Убрать';

  @override
  String get slotEraseTitle => 'Убрать черновик?';

  @override
  String slotGrams(Object u) {
    return 'ВЕС, $u';
  }

  @override
  String get slotIntoBreakfast => 'в завтрак';

  @override
  String get slotIntoDinner => 'в ужин';

  @override
  String get slotIntoLunch => 'в обед';

  @override
  String slotIntoOther(String name) {
    return 'в «$name»';
  }

  @override
  String get slotIntoSnack => 'в перекус';

  @override
  String slotKcal(Object u) {
    return '$u';
  }

  @override
  String get slotLog => 'Записать';

  @override
  String get slotLunch => 'Обед';

  @override
  String get slotSnack => 'Перекус';

  @override
  String get slotWriteWhat => 'Напиши, что было';

  @override
  String get startAbout => 'О тебе';

  @override
  String get startAge => 'Возраст';

  @override
  String startAgeYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count года',
      many: '$count лет',
      few: '$count года',
      one: '$count год',
    );
    return '$_temp0';
  }

  @override
  String get startAgreeAnd => ' и ';

  @override
  String get startAgreeHead => 'Соглашаюсь с ';

  @override
  String get startAgreePrivacy => 'политикой конфиденциальности';

  @override
  String get startAgreeTerms => 'условиями использования';

  @override
  String get startDeviceFirstRun => 'первый запуск';

  @override
  String get startDocs => 'Документы';

  @override
  String get startGoal => 'Куда движемся';

  @override
  String get startGoalGain => 'Набрать';

  @override
  String get startGoalGainHint => 'профицит под выбранный темп';

  @override
  String get startGoalKeep => 'Держать вес';

  @override
  String get startGoalKeepHint => 'сколько тратишь, столько и возвращаешь';

  @override
  String get startGoalLose => 'Похудеть';

  @override
  String get startGoalLoseHint => 'дефицит под выбранный темп';

  @override
  String get startHeight => 'Рост';

  @override
  String get startHiHello => 'Добро пожаловать в';

  @override
  String get startHiNote => 'Шесть коротких вопросов, минута. Дальше Нора считает сама.';

  @override
  String get startLife => 'Образ жизни';

  @override
  String get startNorm => 'Твоя норма';

  @override
  String get startNormCounting => 'считаю…';

  @override
  String get startNormHold => 'держим';

  @override
  String get startNormNote =>
      'Это расчёт по формуле Миффлина-Сан Жеора, а не медицинская рекомендация. Если есть заболевание, беременность или назначенная диета, сверяйся с врачом.';

  @override
  String startNormPerDay(Object u) {
    return '$u в день';
  }

  @override
  String get startNormWeeks => 'недель';

  @override
  String get startPace => 'Как быстро';

  @override
  String get startPaceEtaHead => 'Цель примерно ';

  @override
  String get startPaceEtaTail => ', это ';

  @override
  String get startPaceFast => 'быстро';

  @override
  String get startPaceSlow => 'медленно';

  @override
  String startPaceUnit(Object u) {
    return '$u в неделю';
  }

  @override
  String get startPaceUsual => 'обычно';

  @override
  String get startPaceWarning =>
      'Такой темп держится тяжело и обычно срывается. Ниже 0.8 кг в неделю результат выходит медленнее, зато остаётся.';

  @override
  String startPaceWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count недели',
      many: '$count недель',
      few: '$count недели',
      one: '$count неделя',
    );
    return '$_temp0';
  }

  @override
  String get startSex => 'Пол';

  @override
  String get startSexFemale => 'Женский';

  @override
  String get startSexMale => 'Мужской';

  @override
  String get startSexOther => 'Другое';

  @override
  String get startSignInApple => 'Продолжить с Apple';

  @override
  String get startSignInBackText =>
      'Войди тем же аккаунтом, и всё вернётся на место: дневник, цель, норма и замеры. Заполнять заново ничего не нужно.';

  @override
  String get startSignInBackTitle => 'С возвращением';

  @override
  String get startSignInBusy => 'Заходим…';

  @override
  String get startSignInFailed => 'Не удалось войти. Попробуй ещё раз или продолжи без входа.';

  @override
  String startSignInFailedWhy(String why) {
    return 'Не удалось войти. $why';
  }

  @override
  String get startSignInGoogle => 'Продолжить с Google';

  @override
  String get startSignInSkip => 'Дальше без аккаунта';

  @override
  String get startSignInText =>
      'Норма посчитана. Войди, чтобы она осталась при тебе: история, замеры и записи будут на всех устройствах, а не только тут.';

  @override
  String get startSignInTitle => 'Сохраним это';

  @override
  String get startTargetWeight => 'Целевой вес';

  @override
  String get startWeightNow => 'Вес сейчас';

  @override
  String get startYearsShort => 'лет';

  @override
  String get storageBroken =>
      'Не удалось открыть хранилище. Записи на месте, но показать их сейчас нечем.';

  @override
  String get themeAquarelle => 'Акварель';

  @override
  String get themeAquarelleHint => 'светлая, с пастельными облаками на фоне';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeDarkHint => 'всегда тёмный интерфейс';

  @override
  String get themeDawn => 'Рассвет';

  @override
  String get themeDawnHint => 'светлая, с тёплым светом сбоку';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeLightHint => 'всегда светлый интерфейс';

  @override
  String get themeSectionLook => 'Вид';

  @override
  String get themeSystem => 'Тема устройства';

  @override
  String get themeSystemHint => 'слушает настройку системы';

  @override
  String get todayBarcode => 'Штрихкод';

  @override
  String todayCodeTalk(String code) {
    return 'Отсканировал штрихкод $code, в базах его нет. Ничего не записывай: расспроси меня об этом продукте или подскажи, как его посчитать.';
  }

  @override
  String get todayDone => 'Готово.';

  @override
  String get todayFailedRetry => 'Не вышло. Попробуй ещё раз через минуту.';

  @override
  String get todayGoalMet =>
      'Поздравляю! 🎉 Желанный вес твой, цель закрыта. И сделал это ты, а не приложение. Теперь я перевожу норму на удержание, чтобы результат остался с тобой.';

  @override
  String todayHowManyGrams(String dish) {
    return 'Сколько граммов было: $dish?';
  }

  @override
  String todayLabelTalk(String code) {
    return 'Это этикетка продукта со штрихкодом $code, в базах его нет. Перепиши таблицу пищевой ценности с упаковки.';
  }

  @override
  String get todayLogFailed => 'Не вышло записать. Попробуй ещё раз.';

  @override
  String get todayLogged => 'Записала.';

  @override
  String todayLoggedAskWeight(String slotInto) {
    return 'Записала $slotInto. Скажи вес, если хочешь точнее.';
  }

  @override
  String get todayLoggedAskWeightShort => 'Записала. Скажи вес, если хочешь точнее.';

  @override
  String todayLoggedCount(int count) {
    return 'Записано $count';
  }

  @override
  String todayLoggedInto(String slotInto, String dish) {
    return 'Записала $slotInto: $dish.';
  }

  @override
  String todayLoggedIntoWithNumbers(String slotInto, String dish, String kcal, String grams) {
    return 'Записала $slotInto: $dish, $kcal за $grams.';
  }

  @override
  String get todayNoraSlow => 'Нора думает дольше обычного. Попробуй ещё раз, токен не списался.';

  @override
  String get todayOffline => 'Не достаю сеть. Попробуй ещё раз, когда появится.';

  @override
  String get todayOfflineSaved =>
      'Не достаю сеть. Запись останется на телефоне и уедет, когда появится.';

  @override
  String get todayOutOfBody =>
      'Я пока молчу, но записывать вручную можно всегда, и это бесплатно. Подписка включает меня обратно и стоит как три кофе в месяц.';

  @override
  String get todayOutOfPlan => 'Подписка';

  @override
  String get todayOutOfTokens => 'Токены кончились.';

  @override
  String get todayPhotoLabel => 'Фото этикетки';

  @override
  String get todayPhotoMeal => 'Фото';

  @override
  String get todayQuestionClosed => 'Этот вопрос уже закрыт. Скажи вес словами, если нужно.';

  @override
  String get unitCm => 'см';

  @override
  String get unitCmName => 'Сантиметры';

  @override
  String get unitFlozName => 'Жидкие унции';

  @override
  String get unitG => 'г';

  @override
  String get unitGName => 'Граммы';

  @override
  String get unitInName => 'Дюймы';

  @override
  String get unitKcal => 'ккал';

  @override
  String get unitKcalName => 'Калории';

  @override
  String get unitKg => 'кг';

  @override
  String get unitKgName => 'Килограммы';

  @override
  String get unitKj => 'кДж';

  @override
  String get unitKjName => 'Килоджоули';

  @override
  String get unitLbName => 'Фунты';

  @override
  String get unitMl => 'мл';

  @override
  String get unitMlName => 'Миллилитры';

  @override
  String get unitOzName => 'Унции';

  @override
  String get unitStName => 'Стоуны';

  @override
  String get unitsEnergy => 'Энергия';

  @override
  String get unitsLength => 'Рост и обхваты';

  @override
  String get unitsMass => 'Вес тела';

  @override
  String get unitsPortion => 'Порции еды';

  @override
  String get unitsTitle => 'Какие единицы измерения';

  @override
  String get unitsVolume => 'Вода';

  @override
  String get watchLinked => 'подключены';

  @override
  String waterGlasses(int glasses) {
    return 'около $glasses стаканов';
  }

  @override
  String waterLess(String step) {
    return 'Меньше на $step';
  }

  @override
  String waterMore(String step) {
    return 'Больше на $step';
  }

  @override
  String get waterNone => 'ничего не выпито';

  @override
  String waterOf(String ml) {
    return ' / $ml';
  }

  @override
  String waterShare(int pct) {
    return '$pct% дневной цели';
  }

  @override
  String get waterTitle => 'Вода';

  @override
  String get wcNoTime => 'без длительности';

  @override
  String get wdFri => 'Пт';

  @override
  String get wdMon => 'Пн';

  @override
  String get wdSat => 'Сб';

  @override
  String get wdSun => 'Вс';

  @override
  String get wdThu => 'Чт';

  @override
  String get wdTue => 'Вт';

  @override
  String get wdWed => 'Ср';

  @override
  String get weightHint => 'Сколько ты весишь сегодня. Цель и темп к ней живут отдельно.';

  @override
  String get weightNote =>
      'Записывай вес утром, до еды: так суточные колебания не превращают график в шум. Один замер в неделю уже даёт тренд.';

  @override
  String get weightTitle => 'Вес';

  @override
  String get welEggs => 'Яичница из двух яиц';

  @override
  String get welEggsGrams => '120 г';

  @override
  String get welHaveAccount => 'У меня уже есть аккаунт';

  @override
  String get welLead => 'Считает калории из твоих слов';

  @override
  String get welSaid => 'Съел два яйца и тост';

  @override
  String get welStart => 'Начать';

  @override
  String get welToast => 'Тост с маслом';

  @override
  String get welToastGrams => '50 г';

  @override
  String get welTotal => 'Всего';

  @override
  String wfBurned(Object u) {
    return 'Сожжено, $u';
  }

  @override
  String get wfDuration => 'Длительность';

  @override
  String get wfDurationCap => 'Длительность, мин';

  @override
  String get wfEstimate => 'Оценка по твоему весу и типу активности';

  @override
  String get wfFromWatch => 'С часов или тренажёра';

  @override
  String wfKcal(Object u) {
    return ' $u';
  }

  @override
  String get wfLog => 'Записать';

  @override
  String wfManualKcal(Object u) {
    return 'Вручную $u';
  }

  @override
  String wfMin(int min) {
    return '$min мин';
  }

  @override
  String get wfMinutes => 'Минуты';

  @override
  String get wfNote => 'Заметка';

  @override
  String get wfNoteExample => 'Ноги, тяжело';

  @override
  String get wfOptional => '  необязательно';

  @override
  String get wheelLess => 'Меньше';

  @override
  String get wheelMore => 'Больше';

  @override
  String get wkDaysOk => 'дней в норме';

  @override
  String get wkEmpty =>
      'За эту неделю пока ничего не записано. Запиши первый день, и тут появится картина.';

  @override
  String get wkFactsHead => 'Всего за неделю';

  @override
  String get wkKcalHead => 'Калории';

  @override
  String get wkLoggedCap => 'дней записано';

  @override
  String wkLoggedValue(int n) {
    return '$n из 7';
  }

  @override
  String get wkMacroHead => 'БЖУ';

  @override
  String get wkNoWeight => 'вес: не взвешивались';

  @override
  String get wkNoraBtn => 'Сделать разбор';

  @override
  String wkNoraFailed(String why) {
    return 'Не вышло построить разбор: $why';
  }

  @override
  String get wkNoraGreet =>
      'Спрашивай о чём угодно из этого разбора: о блюде, привычке или о том, что поправить первым.';

  @override
  String get wkNoraLoading => 'Нора изучает неделю…';

  @override
  String get wkNoraLocked => 'Аналитика будет доступна в пятницу';

  @override
  String get wkNoraNoNet => 'нет сети';

  @override
  String get wkNoraNoTokens => 'токены кончились';

  @override
  String get wkNoraP1 =>
      'Основа у тебя здоровая, и это редкость: почти всё домашнее. Борщ, яичница, овсянка: на такой базе остальное правится быстро.';

  @override
  String get wkNoraP2 =>
      'Теперь честно. Овощей за неделю почти не было, а сладкое было каждый день: блины с мёдом, компот. Белка не хватает не потому, что ты мало ешь, а потому, что в тарелке много углеводов и мало мяса, рыбы или творога. И три ужина из семи были после десяти.';

  @override
  String get wkNoraP3 =>
      'Пока ничего страшного, но именно так выглядит рацион, который в сорок удивит анализами. Один шаг на следующую неделю, больше ничего не меняй: к каждому обеду что-то зелёное, а вместо компота вода.';

  @override
  String get wkNoraPlaceholder => 'Спроси про эту неделю';

  @override
  String get wkNoraPromise =>
      'Честный итог недели: что вышло, где просело и один шаг на следующую.';

  @override
  String get wkNoraReply1 =>
      'Самый простой обмен этой недели: компот на воду. Минус ложка сахара каждый раз, а борщ ему ничего не должен.';

  @override
  String get wkNoraReply2 =>
      'Зелёное к обеду не обязано быть салатом. Огурец или полперца рядом с тарелкой уже делают работу.';

  @override
  String get wkNoraSlow => 'сервер долго отвечает';

  @override
  String get wkNoraTalk => 'Поговорить об этом с Норой';

  @override
  String get wkNoraTitle => 'Разбор от Норы';

  @override
  String get wkNorm => 'норма';

  @override
  String wkOffNorm(String n) {
    return '$n от нормы';
  }

  @override
  String get wkPastEmpty =>
      'Прошлых разборов ещё нет. Первый появится тут в следующий понедельник.';

  @override
  String wkPastRow(String day) {
    return 'Неделя от $day';
  }

  @override
  String get wkPastTitle => 'Прошлые';

  @override
  String wkPerDay(Object u) {
    return '$u в среднем за сутки';
  }

  @override
  String get wkPerDayAside => 'в среднем за сутки';

  @override
  String get wkTitle => 'Неделя';

  @override
  String wkTotalCap(Object u) {
    return '$u за неделю';
  }

  @override
  String get wkWaterCap => 'воды за сутки';

  @override
  String wkWaterValue(String l) {
    return '$l л';
  }

  @override
  String get wkWeightCap => 'вес за неделю';

  @override
  String get workoutAdd => 'Добавить тренировку';

  @override
  String workoutBurned(String kcal) {
    return '−$kcal';
  }

  @override
  String get workoutCollapse => 'Свернуть';

  @override
  String get workoutMinUnit => 'мин';

  @override
  String get workoutNone => 'ничего не записано';

  @override
  String workoutSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сессии',
      many: '$count сессий',
      few: '$count сессии',
      one: '$count сессия',
    );
    return '$_temp0';
  }

  @override
  String get workoutTitle => 'Тренировка';
}
