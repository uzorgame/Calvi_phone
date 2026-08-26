// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get aboutContact => 'Contact';

  @override
  String get aboutDeveloper => 'Developer';

  @override
  String get aboutText =>
      'A food diary that understands ordinary sentences. Nora does the arithmetic, the decisions stay yours.';

  @override
  String get aboutTitle => 'About the app';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutWrite => 'Write to us';

  @override
  String get accountBusy => 'Signing in…';

  @override
  String get accountGoogle => 'Continue with Google';

  @override
  String get accountKeepCloud => 'The one in the account';

  @override
  String get accountNoAccountNote =>
      'The diary lives only on this phone. Change the phone or remove the app and there is nothing to bring the entries back with: we do not know whose they are.';

  @override
  String get accountScopeNote =>
      'We ask for the email only. Google does not pass us the name, the profile picture or the contacts.';

  @override
  String get accountSettingsDevice => 'settings';

  @override
  String get accountSignInFailed => 'Could not sign in.';

  @override
  String accountSignInFailedWhy(String why) {
    return 'Could not sign in. $why';
  }

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get accountSignOutAction => 'Sign out';

  @override
  String get accountSignOutAsk => 'Sign out?';

  @override
  String get accountSignOutBack =>
      'You can sign back in with the same account any time, right here.';

  @override
  String get accountSignOutNote =>
      'The entries stay on this phone: signing out does not wipe the diary. What stops is the rest, syncing with other devices and the ability to get the data back if the phone is lost.';

  @override
  String get accountSince => 'With Calvi since';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountVia => 'Signed in with Google';

  @override
  String get accountWhichDiary => 'Which diary do we keep?';

  @override
  String get accountWhichDiaryNote =>
      'This account already has entries, and so does the phone. Only one can stay: the one in the account, or the one on the phone. The other one goes.';

  @override
  String get actBasketball => 'Basketball';

  @override
  String get actBike => 'Cycling';

  @override
  String get actDance => 'Dancing';

  @override
  String get actFootball => 'Football';

  @override
  String get actGym => 'Gym';

  @override
  String get actHiit => 'HIIT';

  @override
  String get actJumprope => 'Skipping';

  @override
  String get actRun => 'Running';

  @override
  String get actSki => 'Skiing';

  @override
  String get actStretch => 'Stretching';

  @override
  String get actSwim => 'Swimming';

  @override
  String get actTennis => 'Tennis';

  @override
  String get actWalk => 'Walking';

  @override
  String get actYoga => 'Yoga';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionBack => 'Back';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionClose => 'Close';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionDone => 'Done';

  @override
  String get actionNext => 'Next';

  @override
  String get actionSave => 'Save';

  @override
  String get activityHigh => 'High';

  @override
  String get activityHighHint => '5-6 workouts';

  @override
  String get activityLight => 'Lightly active';

  @override
  String get activityLightHint => '1-2 workouts a week';

  @override
  String get activityModerate => 'Moderate';

  @override
  String get activityModerateHint => '3-4 workouts';

  @override
  String get activitySedentary => 'Sedentary';

  @override
  String get activitySedentaryHint => 'almost no movement';

  @override
  String get activityVeryHigh => 'Very high';

  @override
  String get activityVeryHighHint => 'physical work or sport every day';

  @override
  String agoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get agoToday => 'today';

  @override
  String get agoWeek => 'a week ago';

  @override
  String agoWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count weeks ago');
    return '$_temp0';
  }

  @override
  String get agoYesterday => 'yesterday';

  @override
  String get allergyConfirm => 'Confirm';

  @override
  String get allergyMild => 'Mild';

  @override
  String get allergyMildHint => 'I will warn you in the text, without blocking the entry.';

  @override
  String get allergyMildShort => 'mild';

  @override
  String get allergyNote =>
      'If a product\'s composition is not in the base, I do not stay quiet and I do not treat that as safe: I will say separately that the composition is unknown.';

  @override
  String get allergyNothing =>
      'Nothing found. If the allergen is not in the list, tell Nora: we will add it to the reference so it works for everyone, instead of staying as text for one person.';

  @override
  String get allergyRemove => 'Remove';

  @override
  String allergySearch(int count) {
    return 'Search $count allergens';
  }

  @override
  String get allergySevere => 'Severe';

  @override
  String get allergySevereHint => 'I will stop before logging and say so plainly.';

  @override
  String get allergySevereShort => 'severe';

  @override
  String get allergyTitle => 'Allergies';

  @override
  String anChartGoal(String value) {
    return 'goal $value';
  }

  @override
  String get anDaysInNorm => 'days on target';

  @override
  String anDonePercent(int percent) {
    return '$percent% done';
  }

  @override
  String anEtaHead(String date) {
    return 'At the current pace the goal is around *$date*';
  }

  @override
  String get anForMonth => 'over the month';

  @override
  String get anForQuarter => 'over 3 months';

  @override
  String get anForYear => 'over the year';

  @override
  String get anGoalProgress => 'Progress to the goal';

  @override
  String get anKcal => 'Calories';

  @override
  String get anKcalAvg => 'on average a day';

  @override
  String get anKcalEmpty =>
      'Nothing logged for this period yet. Tell Nora what you ate and the chart will build itself.';

  @override
  String get anKcalTotal => 'over the period, kcal';

  @override
  String anMacroGoal(int grams) {
    return 'norm $grams g';
  }

  @override
  String get anMacrosAvg => 'Macros on average';

  @override
  String get anMacrosEmpty =>
      'An average appears as soon as there is something to average: log at least one day.';

  @override
  String get anMeasures => 'Measurements';

  @override
  String anMeasuresChange(String period) {
    return 'change $period';
  }

  @override
  String get anMeasuresEmpty => 'No measurements yet.';

  @override
  String get anMeasuresEmptyHint => 'Measure once a month and I will show you what is moving';

  @override
  String get anMonth => 'Month';

  @override
  String get anNow => 'now';

  @override
  String get anNowKg => 'now, kg';

  @override
  String get anOneReading => 'one reading';

  @override
  String get anOneWeighing =>
      'One reading so far. The second one shows the direction, and the line starts from it.';

  @override
  String get anPerDay => 'a day';

  @override
  String get anQuarter => '3 months';

  @override
  String anShareOfNorm(int share) {
    return '$share% of the norm';
  }

  @override
  String get anTargetKg => 'goal, kg';

  @override
  String get anTitle => 'Analytics';

  @override
  String get anWater => 'Hydration';

  @override
  String get anWaterAvg => 'on average, ml';

  @override
  String anWaterGoal(String ml) {
    return 'norm $ml ml';
  }

  @override
  String get anWeek => 'Week';

  @override
  String get anWeightEmpty =>
      'The curve appears after the second weigh-in. Tell Nora your weight and she will log it herself.';

  @override
  String get anYear => 'Year';

  @override
  String get assistantAddMemory => 'Add to memory';

  @override
  String get assistantCollapse => 'Collapse';

  @override
  String get assistantExample => 'For example, I do not eat mushrooms';

  @override
  String get assistantForget => 'Forget';

  @override
  String assistantHint(String name) {
    return '$name keeps the diary with you and remembers what you told her about yourself.';
  }

  @override
  String get assistantMemory => 'Memory';

  @override
  String get assistantMemoryEmpty => 'Nothing remembered yet.';

  @override
  String get assistantMemoryEmptyHint => 'Memory comes out of conversations, or add one by hand';

  @override
  String assistantPinned(int count, int pinned) {
    return '$count, $pinned pinned';
  }

  @override
  String get assistantTitle => 'Assistant';

  @override
  String get assistantWhatToRemember => 'What to remember';

  @override
  String get barCamera => 'Camera';

  @override
  String barGrams(int grams) {
    return '$grams g';
  }

  @override
  String get barHint => 'Write the way you speak.';

  @override
  String get barHintMore =>
      '\"two eggs and toast\", \"drank 300 of water\", \"ran 40 minutes\": I will work it out and put it in the right card';

  @override
  String get barLogsInto => 'Logging into ';

  @override
  String get barMic => 'Microphone';

  @override
  String get barSend => 'Send';

  @override
  String get camAgain => 'Again';

  @override
  String get camAllergen => 'Allergen!';

  @override
  String camAllergyContains(String list) {
    return 'Contains your allergen: $list';
  }

  @override
  String camAllergyTraces(String list) {
    return 'May contain traces of: $list';
  }

  @override
  String get camBarcode => 'Barcode';

  @override
  String get camBusy => 'The camera did not open. Usually another app is holding it.';

  @override
  String get camCouldNotRead => 'Could not read the shot';

  @override
  String get camDish => 'Meal';

  @override
  String get camEstimate => ' kcal, an estimate';

  @override
  String get camFlash => 'Flash';

  @override
  String get camFromPack => 'Figures from the packaging. Logging this costs no tokens.';

  @override
  String get camGallery => 'From the gallery';

  @override
  String get camHintBarcode => 'the code inside the frame';

  @override
  String get camHintDish => 'point it at the plate';

  @override
  String camIngredients(String text) {
    return 'Ingredients: $text';
  }

  @override
  String camIntoSlot(String slot) {
    return 'into $slot';
  }

  @override
  String camKcalFor(int grams) {
    return ' kcal for $grams g';
  }

  @override
  String camKcalPer(int grams) {
    return ' kcal per $grams g';
  }

  @override
  String camLogInto(String slotInto) {
    return 'Log it $slotInto';
  }

  @override
  String get camNoPermission => 'No camera permission. You can grant it in the phone\'s settings.';

  @override
  String get camNoScanner => 'This phone cannot read codes with the camera.';

  @override
  String get camNoTokens => 'Out of tokens for today';

  @override
  String get camNotRead => 'Could not make it out';

  @override
  String get camOfflineShot => 'No connection. You can send the shot to Nora later';

  @override
  String get camPer100 => 'No exact weight on the packaging: figures are per 100 g.';

  @override
  String camPortionPack(int g) {
    return 'Portion from the packaging: $g g. Figures are per portion.';
  }

  @override
  String get camReading => 'Reading…';

  @override
  String get camSendToNora => 'Send to Nora';

  @override
  String get camShoot => 'Take a photo';

  @override
  String get camShotFailed => 'The shot did not work';

  @override
  String get camShotReady => 'The shot is ready';

  @override
  String get camShotReadyNote =>
      'Nora will read it and answer in the chat: she will name the dish, estimate the portion and show where the figure came from. It costs two tokens.';

  @override
  String get camStillWorks => 'Meal photos and the gallery work as usual.';

  @override
  String get camTitle => 'Scanner';

  @override
  String get camTookTooLong => 'Reading it took too long. Try again';

  @override
  String get camUnknownCode => 'I do not know this code';

  @override
  String get camUnknownCodeNote =>
      'It is not in our base, and not in the open one either. Photograph the meal itself or write the name in words, and Nora will count it.';

  @override
  String get deleteConfirm =>
      'I understand the data will be deleted forever and cannot be brought back.';

  @override
  String get deleteDays => 'Days with Calvi';

  @override
  String get deleteEntries => 'Entries in the diary';

  @override
  String get deleteForever => 'Delete forever';

  @override
  String get deleteNote =>
      'Everything goes: the diary, weight, measurements, allergies, medications, conversation history. There is no undoing it.';

  @override
  String get deleteSubNote =>
      'If it is about the subscription, that can be cancelled separately in the App Store or Google Play without deleting the account.';

  @override
  String get deleteTitle => 'Delete account';

  @override
  String get deleteWeighings => 'Weight readings';

  @override
  String get dictationBusy => 'The microphone is busy. Try again';

  @override
  String get dictationFailed => 'Dictation did not work';

  @override
  String get dictationNoMatch => 'I did not hear anything I could make out';

  @override
  String get dictationNoNetwork => 'Recognition needs a network';

  @override
  String get dictationNoPermission => 'No microphone permission';

  @override
  String get dictationSilence => 'Silence. Try again, closer to the microphone';

  @override
  String get dictationUnavailable => 'Dictation is not available on this phone';

  @override
  String get doseCapFew => 'capsules';

  @override
  String get doseCapMany => 'capsules';

  @override
  String get doseCapOne => 'capsule';

  @override
  String get doseDropFew => 'drops';

  @override
  String get doseDropMany => 'drops';

  @override
  String get doseDropOne => 'drop';

  @override
  String get doseMlFew => 'ml';

  @override
  String get doseMlMany => 'ml';

  @override
  String get doseMlOne => 'ml';

  @override
  String get doseShotFew => 'shots';

  @override
  String get doseShotMany => 'shots';

  @override
  String get doseShotOne => 'shot';

  @override
  String get doseTabFew => 'tablets';

  @override
  String get doseTabMany => 'tablets';

  @override
  String get doseTabOne => 'tablet';

  @override
  String entries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
      zero: 'no entries',
    );
    return '$_temp0';
  }

  @override
  String get eraseAskBody1 =>
      'The whole diary goes, for all time: meals, water, weight, measurements, workouts, medication and the talk with Nora. On every device, because the server copy is erased too.';

  @override
  String get eraseAskBody2 =>
      'What stays: the account, the sign-in, the tokens with their balance and the profile settings. This is not signing out, it is a clean slate inside the same account.';

  @override
  String get eraseAskCta => 'Delete everything';

  @override
  String get eraseAskTitle => 'Delete every entry?';

  @override
  String get eraseDataTitle => 'Delete data';

  @override
  String get eraseDone => 'The diary is erased. A clean slate.';

  @override
  String eraseFailed(String why) {
    return 'Could not erase: $why';
  }

  @override
  String get eraseSureBody =>
      'This cannot be undone. The diary disappears forever, and neither you nor we can bring it back.';

  @override
  String get eraseSureCta => 'Yes, delete forever';

  @override
  String get eraseSureTitle => 'Delete for sure?';

  @override
  String get eveningAnd => ' and ';

  @override
  String get eveningBreakfastAcc => 'breakfast';

  @override
  String get eveningDinnerAcc => 'dinner';

  @override
  String get eveningEmptyDay => 'The day is empty. What did you eat today?';

  @override
  String eveningLogged(String slot) {
    return 'Logged $slot?';
  }

  @override
  String get eveningLunchAcc => 'lunch';

  @override
  String eveningMissing(String list) {
    return '$list are not logged yet. Which of them happened?';
  }

  @override
  String get eveningWater => 'How much water did the day come to?';

  @override
  String get fieldBiceps => 'Biceps';

  @override
  String get fieldChest => 'Chest';

  @override
  String get fieldHips => 'Hips';

  @override
  String get fieldNeck => 'Neck';

  @override
  String get fieldThigh => 'Thigh';

  @override
  String get fieldWaist => 'Waist';

  @override
  String get fieldWeight => 'Weight';

  @override
  String get fieldWrist => 'Wrist';

  @override
  String get goalBecomes => 'Becomes';

  @override
  String get goalCurrent => 'Current goal ';

  @override
  String get goalDailyNorm => 'Daily norm';

  @override
  String goalDiff(String kg) {
    return '$kg kg apart';
  }

  @override
  String get goalDirection => 'Direction';

  @override
  String get goalEta => 'Goal around';

  @override
  String goalFromStart(String kg) {
    return ' from $kg kg at the start. ';
  }

  @override
  String get goalFromToday => 'The new goal will start from today\'s weight.';

  @override
  String get goalKeepNote =>
      'The norm holds your current weight: you put back exactly what you spend.';

  @override
  String get goalKeepShort => 'Keep';

  @override
  String get goalNew => 'Set a new goal';

  @override
  String get goalNewTitle => 'New goal';

  @override
  String get goalPace => 'Pace';

  @override
  String get goalPaceFast => 'Fast';

  @override
  String get goalPaceOk => 'This is the pace most people hold without breaking.';

  @override
  String get goalPaceSlow => 'Slow';

  @override
  String get goalPaceUnit => 'kg a week';

  @override
  String get goalPaceUsual => 'Recommended';

  @override
  String goalRange(String from, String to) {
    return '$from → $to kg';
  }

  @override
  String get goalReplaceNote =>
      'A goal is not edited, it is replaced. Progress will count from today\'s weight, and the old goal stays in the history. Confirm the replacement?';

  @override
  String get goalSet => 'Set';

  @override
  String get goalTarget => 'Target weight';

  @override
  String get goalWas => 'Was';

  @override
  String gramsUnit(int grams) {
    return '$grams g';
  }

  @override
  String get helloDishBread => 'Rye bread';

  @override
  String get helloDishEggs => 'Scrambled eggs';

  @override
  String get helloSaid => 'two eggs and toast';

  @override
  String get helloSlotSub => 'two items';

  @override
  String get helloStepCount => 'I\'ll count the calories';

  @override
  String get helloStepLog => 'I\'ll log it in your day';

  @override
  String get helloStepSay => 'Say what you ate';

  @override
  String heroBurned(int kcal) {
    return '-$kcal kcal from training';
  }

  @override
  String get heroDays => 'days';

  @override
  String heroFrom(String kcal) {
    return ' of $kcal';
  }

  @override
  String get heroGoalKg => 'goal, kg';

  @override
  String get heroKcal => ' kcal';

  @override
  String get heroKg => ' kg';

  @override
  String get heroLeft => 'left ';

  @override
  String heroOf(String kcal) {
    return ' of $kcal';
  }

  @override
  String get heroOver => 'over by ';

  @override
  String heroWeightFrom(String kg) {
    return 'now, from $kg kg at the start of the goal';
  }

  @override
  String kcalUnit(int kcal) {
    return '$kcal kcal';
  }

  @override
  String get langSection => 'Interface language';

  @override
  String get langSystem => 'Device language';

  @override
  String legalUpdated(String date) {
    return 'Updated $date';
  }

  @override
  String get loginNoToken => 'Google did not return a token';

  @override
  String get loginNotConfigured => 'sign-in is not configured in this build';

  @override
  String get loginNotSynced =>
      'Not every entry has reached the server yet. Try again in a minute: signing in erases nothing until everything is saved';

  @override
  String loginServer(String why) {
    return 'server: $why';
  }

  @override
  String get loginSlow => 'Google did not answer in a minute. Try again';

  @override
  String macroCShort(int value) {
    return 'C $value';
  }

  @override
  String get macroCarbs => 'Carbs';

  @override
  String get macroCarbsCaps => 'CARBS';

  @override
  String get macroCarbsLetter => 'C';

  @override
  String macroFShort(int value) {
    return 'F $value';
  }

  @override
  String get macroFat => 'Fat';

  @override
  String get macroFatCaps => 'FAT';

  @override
  String get macroFatLetter => 'F';

  @override
  String get macroMedsCaps => 'MEDS';

  @override
  String macroOfGrams(int goal) {
    return ' / ${goal}g';
  }

  @override
  String macroPShort(int value) {
    return 'P $value';
  }

  @override
  String get macroProtein => 'Protein';

  @override
  String get macroProteinCaps => 'PROTEIN';

  @override
  String get macroProteinLetter => 'P';

  @override
  String get mealAuto => 'auto ';

  @override
  String get mealEmpty => 'Nothing here yet. Write what it was and I will log it.';

  @override
  String mealGrams(int grams) {
    return '$grams g';
  }

  @override
  String get mealThinking => 'Nora is counting…';

  @override
  String get measureAdd => 'Add a measurement';

  @override
  String get measureCollapse => 'Collapse';

  @override
  String measureCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count readings',
      one: '1 reading',
    );
    return '$_temp0';
  }

  @override
  String measureLast(String ago) {
    return 'last one $ago';
  }

  @override
  String get measureNever => 'not measured yet';

  @override
  String get measureNothing => 'nothing yet';

  @override
  String get measurePick =>
      'Choose what you will measure. One is enough if the rest does not interest you.';

  @override
  String get measureSave => 'Save the readings';

  @override
  String get measureStats => 'Measurement statistics';

  @override
  String get measureTitle => 'Measurements';

  @override
  String get medsAdd => 'Add a medication';

  @override
  String get medsAllTaken => 'Everything for today is taken';

  @override
  String get medsAt => 'At';

  @override
  String get medsCourse => 'Course';

  @override
  String get medsDose => 'Dose';

  @override
  String get medsEmpty =>
      'Nothing here yet. Add a medication and I will remind you at the right time.';

  @override
  String get medsEmptyHint => 'I keep the log of doses taken, I do not work out the dosage';

  @override
  String get medsFinish => 'End the course';

  @override
  String get medsHours => 'Hours';

  @override
  String get medsHowOften => 'How often';

  @override
  String get medsMine => 'My medications';

  @override
  String get medsName => 'Name';

  @override
  String get medsNameExample => 'For example, Magnesium B6';

  @override
  String get medsNew => 'New medication';

  @override
  String get medsNextAt => 'Next at ';

  @override
  String get medsNoneToday => 'Nothing to take today';

  @override
  String get medsNote => 'Note';

  @override
  String get medsNow => 'NOW';

  @override
  String get medsOne => 'Medication';

  @override
  String get medsPast => 'Past';

  @override
  String get medsPastEmpty =>
      'Courses you no longer take will be here. A medication removed from the list stays in the days you took it.';

  @override
  String get medsPerTake => 'How much at a time';

  @override
  String get medsRemind => 'Remind me';

  @override
  String get medsRemindHint => 'at the chosen hours';

  @override
  String get medsResume => 'Resume the course';

  @override
  String get medsSchedule => 'Schedule';

  @override
  String medsSince(String date) {
    return 'since $date';
  }

  @override
  String get medsTime => 'Time';

  @override
  String get medsTitle => 'Medications';

  @override
  String medsUntil(String date) {
    return 'until $date';
  }

  @override
  String get noraName => 'Nora';

  @override
  String get normAuto => 'Count it automatically';

  @override
  String get normAutoFrom => 'From weight, height, age, activity and goal: ';

  @override
  String normAutoHint(String kcal) {
    return 'from weight, height, age, activity and the goal: $kcal kcal';
  }

  @override
  String get normAutoShort => 'Automatic';

  @override
  String get normByHand => 'Set it by hand';

  @override
  String get normByHandHint => 'analytics will count against this figure';

  @override
  String get normByHandShort => 'By hand';

  @override
  String get normCalculatedHead => 'The calculated value is ';

  @override
  String get normCalculatedTail => '. You can go back to it by choosing \"Automatic\".';

  @override
  String get normFitCarbs => 'Fit the carbs to the norm';

  @override
  String get normFits => 'The split matches the norm';

  @override
  String normGrams(int grams) {
    return '$grams g';
  }

  @override
  String normKcalOf(String kcal) {
    return '$kcal kcal';
  }

  @override
  String normMacroSplit(int protein, int fat, int carbs) {
    return '$protein / $fat / $carbs g';
  }

  @override
  String get normMacros => 'Macros';

  @override
  String get normManual => 'set by hand';

  @override
  String normOf(String kcal) {
    return 'of $kcal kcal';
  }

  @override
  String normOffBy(String sum, int off) {
    return 'The split gives $sum kcal, $off away';
  }

  @override
  String get normPerDay => 'kcal a day';

  @override
  String get normTitle => 'Norm';

  @override
  String get normWater => 'Water';

  @override
  String get normWaterHead => 'That is ';

  @override
  String normWaterPerKg(int ml) {
    return '$ml ml';
  }

  @override
  String get normWaterTail =>
      ' per kilogram of weight. The usual rough range is 30-40 ml, but it depends on heat and training, so the figure here is not rigid.';

  @override
  String get normWhere => 'Where this figure comes from';

  @override
  String get notifyChannel => 'Reminders';

  @override
  String get notifyChannelHint => 'Reminders about food, water, medications and weigh-ins';

  @override
  String get notifyDenied =>
      'The phone refused notifications. Switch them on in the system settings and the reminders will work.';

  @override
  String get photoDish => 'Dish';

  @override
  String get photoNotRecognized => 'I could not recognise the dish in this shot';

  @override
  String get planBuy => 'Subscribe';

  @override
  String get planFree => 'Free';

  @override
  String get planLater => 'Not now';

  @override
  String get planMonth => 'Month';

  @override
  String get planMonthBilled => 'billed monthly';

  @override
  String get planMonthPrice => '180 UAH';

  @override
  String get planNow => 'Now';

  @override
  String get planPerkChat => 'Unlimited conversations with Nora';

  @override
  String get planPerkHistory => 'History and analytics without limits';

  @override
  String get planPerkReports => 'Reports for any period';

  @override
  String get planPerks => 'What Premium gives';

  @override
  String get planPitch => 'Unlimited tokens, history without limits, and reports for any period.';

  @override
  String get planPlan => 'Plan';

  @override
  String get planSave => '-17%';

  @override
  String get planStoreNote =>
      'Payment goes through the App Store or Google Play. You can cancel in the same place, in subscription settings, and Calvi has no say in it.';

  @override
  String get planTitle => 'Subscription';

  @override
  String get planTokens => 'Tokens';

  @override
  String get planTokensFree => '2 a day';

  @override
  String get planYear => 'Year';

  @override
  String get planYearBilled => '1,800 UAH once a year';

  @override
  String get planYearHint => '150 UAH a month, charged once a year';

  @override
  String get planYearPrice => '150 UAH';

  @override
  String plateFor(int grams) {
    return 'for $grams g';
  }

  @override
  String get plateGrams => ' g';

  @override
  String get plateKcal => 'kcal';

  @override
  String get plateThinking => 'thinking';

  @override
  String get privacyCrash => 'Crash reports';

  @override
  String get privacyCrashHint => 'the error stack, without diary data';

  @override
  String get privacyDiaryHead => 'Your diary stays yours';

  @override
  String get privacyDiarySub => 'neither meals nor weight go into analytics';

  @override
  String get privacyHealthHead => 'Health data goes to nobody';

  @override
  String get privacyHealthSub => 'allergies and medications never leave the app';

  @override
  String get privacyNoPhotosHead => 'Meal photos are not stored';

  @override
  String get privacyNoPhotosSub => 'the shot goes to be read and is gone';

  @override
  String get privacyNotCollected => 'What we do not collect';

  @override
  String get privacyOptional => 'What you can switch off';

  @override
  String get privacyPhotosBold => 'are not kept';

  @override
  String get privacyPhotosHead => 'Meal photos ';

  @override
  String get privacyPhotosTail =>
      ': the shot goes for processing and is gone. Analytics never sees dishes, weight, allergies or medications. That is a special category of personal data, and handing it to a third party is not on, however convenient it would be.';

  @override
  String get privacyStats => 'Anonymous statistics';

  @override
  String get privacyStatsHint => 'which screens get opened, without the content of entries';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get profileActivity => 'Activity';

  @override
  String get profileAge => 'Age';

  @override
  String get profileHeight => 'Height';

  @override
  String get profileSex => 'Sex';

  @override
  String get remAbout => 'About what';

  @override
  String get remAdd => 'Add a reminder';

  @override
  String get remAt => 'At';

  @override
  String get remDelete => 'Delete reminder';

  @override
  String get remEdit => 'Reminder';

  @override
  String get remEmpty => 'No reminders yet.';

  @override
  String get remEmptyHint => 'Add the one thing you really forget, not everything at once';

  @override
  String get remHowOften => 'How often';

  @override
  String get remName => 'Name';

  @override
  String get remNew => 'New reminder';

  @override
  String get remOpenMeds => 'Open medications';

  @override
  String get remTime => 'Time';

  @override
  String get remTitle => 'Reminders';

  @override
  String get reminderBodyMeal => 'Log what it was';

  @override
  String get reminderBodyMeds => 'On schedule';

  @override
  String get reminderBodySummary => 'What did you not log today?';

  @override
  String get reminderBodyWater => 'Time to drink';

  @override
  String get reminderBodyWeigh => 'In the morning, before eating';

  @override
  String get reminderBodyWorkout => 'Log it if it happened';

  @override
  String get reminderMeal => 'Food';

  @override
  String get reminderMealHint => 'I will remind you to log the meal';

  @override
  String get reminderMeds => 'Medications';

  @override
  String get reminderMedsHint => 'on the schedule from the journal';

  @override
  String get reminderSummary => 'Day summary';

  @override
  String get reminderSummaryHint => 'briefly about the day before bed';

  @override
  String get reminderWater => 'Water';

  @override
  String get reminderWaterHint => 'I will remind you to drink';

  @override
  String get reminderWeigh => 'Weigh-in';

  @override
  String get reminderWeighHint => 'so the weight chart does not break';

  @override
  String get reminderWorkout => 'Workout';

  @override
  String get reminderWorkoutHint => 'I will remind you about the planned one';

  @override
  String get repDaily => 'every day';

  @override
  String repEveryN(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'every $count days');
    return '$_temp0';
  }

  @override
  String get repEveryOther => 'every other day';

  @override
  String get repPickDaily => 'Every day';

  @override
  String get repPickFromToday => 'Counting from today.';

  @override
  String get repPickInterval => 'Every other day';

  @override
  String get repPickNoDays => 'No day is chosen, so the reminder will never fire.';

  @override
  String get repPickWeekdays => 'Days of the week';

  @override
  String get repWeekdays => 'on weekdays';

  @override
  String get repWeekends => 'at weekends';

  @override
  String get repWeekly => 'once a week';

  @override
  String get setAbout => 'About the app';

  @override
  String get setAllergies => 'Allergies';

  @override
  String setAssistantLine(String name, int count) {
    return '$name, $count in memory';
  }

  @override
  String get setDeleteAccount => 'Delete account and data';

  @override
  String get setFreeTierHead =>
      'For Ukraine\'s defenders, and for those serving in the Armed Forces, the State Emergency Service, DTEK, medics, volunteers and teachers in front-line areas, the paid plan is ';

  @override
  String get setFreeTierHow => ' How to get it';

  @override
  String get setFreeTierShort =>
      'For Ukraine\'s defenders, and for those serving in the Armed Forces, the State Emergency Service, DTEK, medics, volunteers and teachers in front-line areas, the paid plan is FREE';

  @override
  String get setFreeTierTelegram => 'Write on Telegram';

  @override
  String get setFreeTierTitle => 'Free plan';

  @override
  String get setFreeTierWord => 'FREE';

  @override
  String get setFreeTierWrite =>
      'Write to the developer and the paid plan will be switched on for you the same day.';

  @override
  String get setGoal => 'Goal';

  @override
  String get setGoalKeep => 'keep weight';

  @override
  String setGoalLine(String kg, String pace) {
    return '$kg kg, $pace/week';
  }

  @override
  String get setGroupAbout => 'About you';

  @override
  String get setGroupAccount => 'Account';

  @override
  String get setGroupAssistant => 'Assistant';

  @override
  String get setGroupDocs => 'Documents';

  @override
  String get setGroupHealth => 'Health';

  @override
  String get setLang => 'Language';

  @override
  String get setMeds => 'Medications';

  @override
  String get setNorm => 'Norm';

  @override
  String setNormLine(String kcal) {
    return '$kcal kcal';
  }

  @override
  String get setPlan => 'Subscription';

  @override
  String get setPlanFree => 'Free';

  @override
  String get setPolicy => 'Privacy policy';

  @override
  String get setPrivacy => 'Data and analytics';

  @override
  String get setProfile => 'Profile';

  @override
  String setProfileLine(String sex, int age, int height) {
    return '$sex, $age, $height cm';
  }

  @override
  String get setReminders => 'Reminders';

  @override
  String get setRemindersOff => 'off';

  @override
  String get setTerms => 'Terms of use';

  @override
  String get setTheme => 'Theme';

  @override
  String get setTitle => 'Settings';

  @override
  String get setUnset => 'not set';

  @override
  String get sexOther => 'Other';

  @override
  String get sexShortFemale => 'F';

  @override
  String get sexShortMale => 'M';

  @override
  String get slotBreakfast => 'Breakfast';

  @override
  String get slotDinner => 'Dinner';

  @override
  String get slotIntoBreakfast => 'into breakfast';

  @override
  String get slotIntoDinner => 'into dinner';

  @override
  String get slotIntoLunch => 'into lunch';

  @override
  String slotIntoOther(String name) {
    return 'into “$name”';
  }

  @override
  String get slotIntoSnack => 'into a snack';

  @override
  String get slotLog => 'Log it';

  @override
  String get slotLunch => 'Lunch';

  @override
  String get slotSnack => 'Snack';

  @override
  String get slotWriteWhat => 'Write what it was';

  @override
  String get startAbout => 'About you';

  @override
  String get startAge => 'Age';

  @override
  String startAgeYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: '1 year',
    );
    return '$_temp0';
  }

  @override
  String get startAgreeAnd => ' and the ';

  @override
  String get startAgreeHead => 'I agree to the ';

  @override
  String get startAgreePrivacy => 'privacy policy';

  @override
  String get startAgreeTerms => 'terms of use';

  @override
  String get startAllergies => 'Allergies';

  @override
  String get startDeviceFirstRun => 'first run';

  @override
  String get startGoal => 'Where we are heading';

  @override
  String get startGoalGain => 'Gain weight';

  @override
  String get startGoalGainHint => 'a surplus at the pace you pick';

  @override
  String get startGoalKeep => 'Keep weight';

  @override
  String get startGoalKeepHint => 'you put back exactly what you spend';

  @override
  String get startGoalLose => 'Lose weight';

  @override
  String get startGoalLoseHint => 'a deficit at the pace you pick';

  @override
  String get startHeight => 'Height';

  @override
  String get startLife => 'Lifestyle';

  @override
  String get startNorm => 'Your norm';

  @override
  String get startNormHold => 'holding';

  @override
  String get startNormNora => 'Counted. It gets easier from here.';

  @override
  String get startNormNoraHint =>
      'Write or say it however suits you: \"two eggs and toast\", \"drank 300 of water\". Whatever else I need, I will ask in the conversation.';

  @override
  String get startNormNote =>
      'This is the Mifflin-St Jeor formula, not medical advice. If you have a condition, are pregnant, or follow a prescribed diet, check with your doctor.';

  @override
  String get startNormPerDay => 'kcal a day';

  @override
  String get startNormWeeks => 'weeks';

  @override
  String get startPace => 'How fast';

  @override
  String get startPaceEtaHead => 'Goal around ';

  @override
  String get startPaceEtaTail => ', that is ';

  @override
  String get startPaceFast => 'fast';

  @override
  String get startPaceSlow => 'slow';

  @override
  String get startPaceUnit => 'kg a week';

  @override
  String get startPaceUsual => 'steady';

  @override
  String get startPaceWarning =>
      'A pace like this is hard to hold and usually breaks. Under 0.8 kg a week the result comes slower but stays.';

  @override
  String startPaceWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: '1 week',
    );
    return '$_temp0';
  }

  @override
  String get startSex => 'Sex';

  @override
  String get startSexFemale => 'Female';

  @override
  String get startSexMale => 'Male';

  @override
  String get startSexOther => 'Other';

  @override
  String get startSignInApple => 'Continue with Apple';

  @override
  String get startSignInBusy => 'Signing in…';

  @override
  String get startSignInFailed => 'Could not sign in. Try again, or carry on without an account.';

  @override
  String startSignInFailedWhy(String why) {
    return 'Could not sign in. $why';
  }

  @override
  String get startSignInGoogle => 'Continue with Google';

  @override
  String get startSignInSkip => 'Not now';

  @override
  String get startSignInText =>
      'The norm is counted. Sign in to keep it: history, measurements and entries will be on every device, not only here.';

  @override
  String get startSignInTitle => 'Let us keep this';

  @override
  String get startTargetWeight => 'Target weight';

  @override
  String get startWeightNow => 'Weight now';

  @override
  String get startYearsShort => 'years';

  @override
  String get storageBroken =>
      'Could not open the storage. Your entries are safe, but there is nothing to show them with right now.';

  @override
  String get themeAquarelle => 'Watercolor';

  @override
  String get themeAquarelleHint => 'light, with pastel clouds on the ground';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeDarkHint => 'always the dark interface';

  @override
  String get themeDawn => 'Dawn';

  @override
  String get themeDawnHint => 'light, with warm light from the side';

  @override
  String get themeLight => 'Light';

  @override
  String get themeLightHint => 'always the light interface';

  @override
  String get themeSectionLook => 'Appearance';

  @override
  String get themeSystem => 'Device theme';

  @override
  String get themeSystemHint => 'follows the system setting';

  @override
  String get todayBarcode => 'Barcode';

  @override
  String todayCodeTalk(String code) {
    return 'I scanned barcode $code and no base knows it. Do not log anything: ask me about this product or tell me how to count it.';
  }

  @override
  String get todayDemo => 'Demo';

  @override
  String get todayDone => 'Done.';

  @override
  String get todayFailedRetry => 'Did not work. Try again in a minute.';

  @override
  String todayHowManyGrams(String dish) {
    return 'How many grams was the $dish?';
  }

  @override
  String get todayLogFailed => 'Could not log it. Try again.';

  @override
  String get todayLogged => 'Logged.';

  @override
  String todayLoggedAskWeight(String slotInto) {
    return 'Logged $slotInto. Tell me the weight if you want it exact.';
  }

  @override
  String get todayLoggedAskWeightShort => 'Logged. Tell me the weight if you want it exact.';

  @override
  String todayLoggedCount(int count) {
    return '$count logged';
  }

  @override
  String todayLoggedInto(String slotInto, String dish) {
    return 'Logged $slotInto: $dish.';
  }

  @override
  String todayLoggedIntoWithNumbers(String slotInto, String dish, int kcal, int grams) {
    return 'Logged $slotInto: $dish, $kcal kcal per $grams g.';
  }

  @override
  String get todayMine => 'Mine';

  @override
  String get todayNoraSlow =>
      'Nora is thinking longer than usual. Try again, the token was not spent.';

  @override
  String get todayOffline => 'No connection. Try again once it is back.';

  @override
  String get todayOfflineSaved =>
      'No connection. The entry stays on the phone and goes up when it returns.';

  @override
  String get todayOutOfTokens => 'Out of tokens for today. Logging by hand always works.';

  @override
  String get todayPhotoMeal => 'Meal photo';

  @override
  String get todayQuestionClosed =>
      'That question is already closed. Say the weight in words if you need to.';

  @override
  String get todayShowingDemo => 'Showing the sample day';

  @override
  String get todayShowingMine => 'Showing my entries';

  @override
  String get unitCm => 'cm';

  @override
  String get unitG => 'g';

  @override
  String get unitKcal => 'kcal';

  @override
  String get unitKg => 'kg';

  @override
  String get unitMl => 'ml';

  @override
  String waterGlasses(int glasses) {
    return 'about $glasses glasses';
  }

  @override
  String waterLess(int step) {
    return '$step ml less';
  }

  @override
  String waterMore(int step) {
    return '$step ml more';
  }

  @override
  String get waterNone => 'nothing drunk';

  @override
  String waterOf(String ml) {
    return ' / $ml ml';
  }

  @override
  String waterShare(int pct) {
    return '$pct% of the daily goal';
  }

  @override
  String get waterTitle => 'Water';

  @override
  String get wcNoTime => 'no duration';

  @override
  String get wdFri => 'Fri';

  @override
  String get wdMon => 'Mon';

  @override
  String get wdSat => 'Sat';

  @override
  String get wdSun => 'Sun';

  @override
  String get wdThu => 'Thu';

  @override
  String get wdTue => 'Tue';

  @override
  String get wdWed => 'Wed';

  @override
  String get weightHint =>
      'What you weigh today. The goal and the pace towards it live separately.';

  @override
  String get weightNote =>
      'Weigh yourself in the morning, before eating: that way the daily swings do not turn the chart into noise. One reading a week is already a trend.';

  @override
  String get weightTitle => 'Weight';

  @override
  String get wfBurned => 'Burned, kcal';

  @override
  String get wfDuration => 'Duration';

  @override
  String get wfDurationCap => 'Duration, min';

  @override
  String get wfEstimate => 'An estimate from your weight and the kind of activity';

  @override
  String get wfFromWatch => 'From a watch or a machine';

  @override
  String get wfKcal => ' kcal';

  @override
  String get wfLog => 'Log it';

  @override
  String get wfManualKcal => 'kcal by hand';

  @override
  String wfMin(int min) {
    return '$min min';
  }

  @override
  String get wfMinutes => 'Minutes';

  @override
  String get wfNote => 'Note';

  @override
  String get wfNoteExample => 'Legs, hard';

  @override
  String get wfOptional => '  optional';

  @override
  String get wheelLess => 'Less';

  @override
  String get wheelMore => 'More';

  @override
  String get workoutAdd => 'Add a workout';

  @override
  String workoutBurned(int kcal) {
    return '−$kcal kcal';
  }

  @override
  String get workoutCollapse => 'Collapse';

  @override
  String get workoutNone => 'nothing logged';

  @override
  String workoutSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
    );
    return '$_temp0';
  }

  @override
  String get workoutTitle => 'Workout';
}
