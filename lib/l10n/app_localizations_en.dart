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
  String get accessAsk => 'not asked yet';

  @override
  String get accessCamera => 'Camera';

  @override
  String get accessMic => 'Microphone';

  @override
  String get accessNote =>
      'The microphone and speech recognition are needed for dictation, and recognition also serves the watch: it records what you say and the phone turns it into words. Tap a row to grant access or open the system settings to turn it off.';

  @override
  String get accessNotify => 'Notifications';

  @override
  String get accessOff => 'denied';

  @override
  String get accessOn => 'allowed';

  @override
  String get accessSpeech => 'Speech recognition';

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
      'Sign back in with the same account and everything comes back. Anything written offline that has not reached the server yet cannot be recovered.';

  @override
  String get accountSignOutNote =>
      'This phone is wiped: the diary, the profile, the medications and the conversation with Nora all go. Your entries stay on the server, under your account.';

  @override
  String get accountSince => 'With Calvi since';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountVia => 'Signed in with Google';

  @override
  String get accountViaApple => 'Signed in with Apple';

  @override
  String get accountViaEmail => 'Signed in with email';

  @override
  String get accountWatch => 'Apple Watch';

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
  String anKcalTotal(Object u) {
    return 'over the period, $u';
  }

  @override
  String anMacroGoal(String grams) {
    return 'norm $grams';
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
  String anNowKg(Object u) {
    return 'now, $u';
  }

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
  String anStartKg(Object u) {
    return 'start, $u';
  }

  @override
  String anTargetKg(Object u) {
    return 'goal, $u';
  }

  @override
  String get anTitle => 'Analytics';

  @override
  String get anWater => 'Hydration';

  @override
  String anWaterAvg(Object u) {
    return 'on average, $u';
  }

  @override
  String anWaterGoal(String ml) {
    return 'norm $ml';
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
  String get authAgain => 'Confirm password';

  @override
  String get authAgainDiffers => 'The passwords do not match';

  @override
  String get authAgainEmpty => 'Repeat the password';

  @override
  String get authAgainHint => 'once more';

  @override
  String authAgainIn(int sec) {
    return 'You can ask again in $sec s';
  }

  @override
  String get authCode => 'Code from the letter';

  @override
  String get authCodeAction => 'Confirm';

  @override
  String get authCodeBad => 'That code does not fit, or it has expired';

  @override
  String authCodeHint(String mail) {
    return 'We sent a code to $mail. Type the six digits from the letter.';
  }

  @override
  String get authCodeShort => 'The code has 6 digits';

  @override
  String get authCodeTitle => 'Confirm your email';

  @override
  String get authForgotAction => 'Send the code';

  @override
  String get authForgotHint => 'We will send a code to your email, then you pick a new password.';

  @override
  String get authForgotLink => 'Forgot it?';

  @override
  String get authForgotTitle => 'New password';

  @override
  String get authMail => 'Email';

  @override
  String get authMailBad => 'That address looks off';

  @override
  String get authOr => 'or';

  @override
  String get authPass => 'Password';

  @override
  String get authPassEmpty => 'Enter your password';

  @override
  String get authPassHint => '5 letters and a sign';

  @override
  String get authPassNew => 'New password';

  @override
  String get authPassWeak => 'Weak password: at least 5 letters and one digit or sign';

  @override
  String get authResetAction => 'Save password';

  @override
  String get authSendAgain => 'Send it again';

  @override
  String get authSignInAction => 'Sign in';

  @override
  String get authSignInTitle => 'Sign in';

  @override
  String get authSignUpAction => 'Create account';

  @override
  String get authSignUpLink => 'Create an account';

  @override
  String get authSignUpTitle => 'Let us make an account';

  @override
  String get barCamera => 'Camera';

  @override
  String barGrams(String grams) {
    return '$grams';
  }

  @override
  String get barHint => 'Hi, I am Nora. Write or speak as you always would, and I will understand.';

  @override
  String get barHintBorscht => 'Borscht 300 g for lunch';

  @override
  String get barHintDelete => 'Delete the last entry';

  @override
  String get barHintEggs => 'Two eggs and toast';

  @override
  String get barHintMore =>
      '\"two eggs and toast\", \"drank 300 of water\", \"ran 40 minutes\": I will work it out and put it in the right card';

  @override
  String get barHintProtein => 'How much protein is left?';

  @override
  String get barHintRun => 'Ran 40 minutes';

  @override
  String get barHintWater => 'Drank 500 ml of water';

  @override
  String get barHintWeighed => 'Weighed in: 78.8';

  @override
  String get barHintYesterday => 'What did I eat yesterday?';

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
  String get camAskNoraInstead => 'No label, ask Nora instead';

  @override
  String get camBarcode => 'Barcode';

  @override
  String get camBusy => 'The camera did not open. Usually another app is holding it.';

  @override
  String get camCouldNotRead => 'Could not read the shot';

  @override
  String get camDish => 'Photo';

  @override
  String camEstimate(Object u) {
    return ' $u, an estimate';
  }

  @override
  String get camFlash => 'Flash';

  @override
  String get camFromPack => 'Figures from the packaging. Logging this costs no tokens.';

  @override
  String get camGallery => 'From the gallery';

  @override
  String get camGapNote => 'No base knows this figure. Photograph the label and I will fill it in.';

  @override
  String get camHintBarcode => 'the code inside the frame';

  @override
  String get camHintDish => 'point it at a plate or a pack';

  @override
  String camIngredients(String text) {
    return 'Ingredients: $text';
  }

  @override
  String camIntoSlot(String slot) {
    return 'into $slot';
  }

  @override
  String camKcalFor(String grams, Object u) {
    return ' $u for $grams';
  }

  @override
  String camKcalPer(String grams, Object u) {
    return ' $u per $grams';
  }

  @override
  String get camLabelAim => 'aim at the nutrition table';

  @override
  String get camLabelNoShot => 'The shot did not come out. Try photographing the label again.';

  @override
  String get camLabelReading => 'Copying the figures off the packet…';

  @override
  String camLogInto(String slotInto) {
    return 'Log it $slotInto';
  }

  @override
  String get camNoPermission => 'No camera permission. You can grant it in the phone\'s settings.';

  @override
  String get camNoScanner => 'This phone cannot read codes with the camera.';

  @override
  String get camNoTokens => 'Out of tokens';

  @override
  String get camNotAProduct => 'That is not a product barcode';

  @override
  String get camNotAProductNote =>
      'A link or an internal code was read. Aim at the striped bar with digits under it.';

  @override
  String get camNotRead => 'Could not make it out';

  @override
  String get camOffline =>
      'The code was read, but there is nobody to ask about it. Try again when you are back online.';

  @override
  String get camOfflineShot => 'No connection. You can send the shot to Nora later';

  @override
  String get camOfflineTitle => 'No network';

  @override
  String get camPer100 => 'No exact weight on the packaging: figures are per 100 g.';

  @override
  String camPortionPack(String g) {
    return 'Portion from the packaging: $g. Figures are per portion.';
  }

  @override
  String get camReading => 'Reading…';

  @override
  String get camSendToNora => 'Send to Nora';

  @override
  String get camServerDown => 'This is not about the code or the camera. Try again in a minute.';

  @override
  String get camServerDownTitle => 'Our server did not answer';

  @override
  String get camShoot => 'Take a photo';

  @override
  String get camShootLabel => 'Photograph the label';

  @override
  String get camShotFailed => 'The shot did not work';

  @override
  String get camShotReady => 'The shot is ready';

  @override
  String get camShotReadyNote =>
      'Nora will read it and answer in the chat: she will name the dish, estimate the portion and show where the figure came from. It costs two tokens.';

  @override
  String get camSignedOut =>
      'The session is no longer valid, so the reference does not recognise us. Sign in again and the scanner will work.';

  @override
  String get camSignedOutTitle => 'Please sign in again';

  @override
  String get camSlow => 'The code was read and the reference took too long. Try again.';

  @override
  String get camSlowTitle => 'The answer did not arrive';

  @override
  String get camStillWorks => 'Meal photos and the gallery work as usual.';

  @override
  String get camTitle => 'Scanner';

  @override
  String get camTookTooLong => 'Reading it took too long. Try again';

  @override
  String get camUnknownCode => 'This product is not in any base';

  @override
  String get camUnknownCodeNote =>
      'Not in ours, and not in the open one. Photograph the nutrition table on the packet and I will copy the figures from it. This is free.';

  @override
  String get chatPro => 'Pro';

  @override
  String get deleteAskBody1 =>
      'This phone is wiped right away: the diary, the profile, the conversation with Nora, the sign-in. The app goes back to the first screen.';

  @override
  String get deleteAskBody2 =>
      'On the server the account is queued for permanent deletion, which takes up to 30 business days. Until we confirm it, signing in with the same account brings everything back and cancels the request.';

  @override
  String get deleteAskCta => 'Yes, delete';

  @override
  String get deleteAskTitle => 'Delete the account?';

  @override
  String get deleteConfirm =>
      'I understand the data will be deleted forever and cannot be brought back.';

  @override
  String get deleteDays => 'Days with Calvi';

  @override
  String get deleteEntries => 'Entries in the diary';

  @override
  String deleteFailed(String why) {
    return 'Could not delete: $why';
  }

  @override
  String get deleteForever => 'Delete forever';

  @override
  String get deleteNote =>
      'Everything goes: the diary, weight, measurements, allergies, medications, conversation history. There is no undoing it.';

  @override
  String get deleteProManage => 'Manage subscription';

  @override
  String deleteProNote(String store) {
    return 'Deleting the account does not cancel Calvi Pro. $store keeps billing until the subscription itself is cancelled, so cancel it before deleting the account.';
  }

  @override
  String get deleteProStoreAny => 'The store';

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
  String get eraseNoNet => 'no network. Turn on the internet and try again';

  @override
  String get eraseSlow => 'the server is taking too long. Try again in a minute';

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
    return '$kg apart';
  }

  @override
  String get goalDirection => 'Direction';

  @override
  String get goalEta => 'Goal around';

  @override
  String goalFromStart(String kg) {
    return ' from $kg at the start. ';
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
  String goalPaceUnit(Object u) {
    return '$u a week';
  }

  @override
  String get goalPaceUsual => 'Recommended';

  @override
  String goalRange(String from, String to) {
    return '$from → $to';
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
  String gramsUnit(String grams) {
    return '$grams';
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
  String heroBurned(String kcal) {
    return '-$kcal from training';
  }

  @override
  String get heroDays => 'days';

  @override
  String heroFrom(String kcal) {
    return ' of $kcal';
  }

  @override
  String heroGoalKg(Object u) {
    return 'goal, $u';
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
  String get heroLeft => 'left ';

  @override
  String heroOf(String kcal) {
    return ' of $kcal';
  }

  @override
  String get heroOver => 'over by ';

  @override
  String get heroWeekOpen => 'The week in full';

  @override
  String heroWeightFrom(String kg) {
    return 'now, from $kg at the start of the goal';
  }

  @override
  String kcalUnit(String kcal) {
    return '$kcal';
  }

  @override
  String get langSection => 'Interface language';

  @override
  String get langSystem => 'Device language';

  @override
  String get legalOnTheWeb => 'Open on the web';

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
  String get macroCNone => 'C ?';

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
  String get macroFNone => 'F ?';

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
  String macroOfGrams(String goal) {
    return ' / $goal';
  }

  @override
  String get macroPNone => 'P ?';

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
  String get mealEditDelete => 'Delete entry';

  @override
  String mealEditKcal(Object u) {
    return '$u';
  }

  @override
  String get mealEditSave => 'Save';

  @override
  String get mealEmpty => 'Nothing here yet. Write what it was and I will log it.';

  @override
  String mealGrams(String grams) {
    return '$grams';
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
  String medsFirstDose(String name, String day, String at) {
    return '$name, first dose $day at $at';
  }

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
  String get medsTomorrow => 'tomorrow';

  @override
  String get medsUnmarked => 'Not marked yet: ';

  @override
  String medsUntil(String date) {
    return 'until $date';
  }

  @override
  String get menuAbout => 'About';

  @override
  String get menuAllergy => 'Allergies';

  @override
  String get menuAnalytics => 'Analytics';

  @override
  String get menuDiary => 'Diary';

  @override
  String get menuHintFree => 'free';

  @override
  String menuHintKcal(String n) {
    return '$n today';
  }

  @override
  String menuHintMore(int n) {
    return '+$n';
  }

  @override
  String get menuHintNoAllergy => 'none';

  @override
  String get menuHintNoMeds => 'no courses';

  @override
  String get menuHintNothing => 'nothing logged yet';

  @override
  String menuHintOnGoal(int ok, int total) {
    return 'on goal $ok of $total';
  }

  @override
  String get menuHintRecipes => 'from Nora, sized to your norm';

  @override
  String get menuHintWeekFriday => 'from Friday, 18:00';

  @override
  String get menuHintWeekOpen => 'open until Sunday';

  @override
  String get menuHintWeekYoung => 'the week has just begun';

  @override
  String get menuMeds => 'Medications';

  @override
  String get menuPlan => 'Subscription';

  @override
  String get menuRecipes => 'Recipes';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuTitle => 'Menu';

  @override
  String get menuWeek => 'Weekly review';

  @override
  String get noraName => 'Nora';

  @override
  String get normAuto => 'Count it automatically';

  @override
  String get normAutoFrom => 'From weight at goal start, height, age, activity and pace: ';

  @override
  String normAutoHint(String kcal) {
    return 'from weight, height, age, activity and the goal: $kcal';
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
  String get normMacros => 'Macros';

  @override
  String get normManual => 'set by hand';

  @override
  String normOf(String kcal) {
    return 'of $kcal';
  }

  @override
  String normOffOver(String sum, int off) {
    return 'The split gives $sum, $off over the norm';
  }

  @override
  String normOffUnder(String sum, int off) {
    return 'The split gives $sum, $off under the norm';
  }

  @override
  String normPerDay(Object u) {
    return '$u a day';
  }

  @override
  String get normTitle => 'Norm';

  @override
  String get normWater => 'Water';

  @override
  String get normWaterHead => 'That is ';

  @override
  String normWaterPerKg(String ml) {
    return '$ml';
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
  String get planClose => 'Close';

  @override
  String get planCurrent => 'current';

  @override
  String get planFailed => 'The purchase did not go through';

  @override
  String get planFree => 'Free';

  @override
  String planFrom(String plan, String date) {
    return '$plan from $date';
  }

  @override
  String planFromShort(String date) {
    return 'from $date';
  }

  @override
  String get planLater => 'Not now';

  @override
  String get planManage => 'Manage in the store';

  @override
  String get planMonth => 'Month';

  @override
  String get planMonthBilled => 'billed monthly';

  @override
  String get planMonthly => 'Pro monthly';

  @override
  String get planNext => 'Next';

  @override
  String get planNothingToRestore => 'No purchases on this account';

  @override
  String get planNow => 'Now';

  @override
  String get planOn => 'Pro';

  @override
  String get planPerMonth => '/mo';

  @override
  String get planPerkChat => 'Unlimited conversations with Nora';

  @override
  String get planPerkChatSub => 'one message costs one token today';

  @override
  String get planPerkMemory => 'Nora remembers you';

  @override
  String get planPerkMemorySub => 'she learns new things in conversation, and that costs a token';

  @override
  String get planPerkPhoto => 'Unlimited meal photos';

  @override
  String get planPerkPhotoSub => 'a photo costs two tokens today';

  @override
  String get planPerkRecipes => 'Unlimited recipes from Nora';

  @override
  String get planPerkRecipesSub => 'a suggestion costs one token today';

  @override
  String get planPerkWeek => 'Weekly review whenever you want';

  @override
  String get planPerkWeekSub => 'a review costs two tokens today';

  @override
  String get planPerks => 'What the subscription gives';

  @override
  String get planPlan => 'Plan';

  @override
  String get planPrivacy => 'Privacy Policy';

  @override
  String get planRenewal =>
      'The subscription renews automatically until cancelled. You can cancel at any time in the settings of the store it was purchased from.';

  @override
  String get planRenews => 'Renews';

  @override
  String get planRestore => 'Restore purchases';

  @override
  String get planSignInGo => 'Sign in';

  @override
  String get planSignInNote =>
      'The subscription is tied to an account with an email. That way it survives a new phone and works on all your devices.';

  @override
  String get planSignInTitle => 'Sign in first';

  @override
  String get planStoreAsking => 'Asking the store for prices…';

  @override
  String get planStoreOffline => 'The store is not responding. Check your internet connection';

  @override
  String get planStoreQuiet => 'The store is not responding. Try again later';

  @override
  String get planSwitchMonth => 'Switch to monthly';

  @override
  String get planSwitchYear => 'Switch to yearly';

  @override
  String get planTariffs => 'Plans';

  @override
  String get planTerms => 'Terms of Use';

  @override
  String get planTitle => 'Subscription';

  @override
  String get planTokens => 'Tokens';

  @override
  String get planTokensFree => '40 a month';

  @override
  String get planTokensPro => 'Unlimited';

  @override
  String get planUntil => 'Active until';

  @override
  String get planYear => 'Year';

  @override
  String planYearBilled(String price) {
    return '$price once a year';
  }

  @override
  String get planYearly => 'Pro yearly';

  @override
  String plateFor(String grams) {
    return 'for $grams';
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
  String get plateThinking => 'thinking';

  @override
  String get plateTotal => 'total';

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
  String rcAllergyWarn(String names) {
    return 'Contains $names, which is on your allergy list. Be careful with this one.';
  }

  @override
  String get rcAsk => 'Ask Nora for a recipe';

  @override
  String get rcAskAbout => 'Ask Nora about this recipe';

  @override
  String get rcAskCancel => 'Cancel';

  @override
  String get rcAskGo => 'Ask';

  @override
  String get rcAskPlaceholder => 'chicken, broccoli, rice';

  @override
  String get rcAskTitle => 'What is in the kitchen?';

  @override
  String get rcAsking => 'Thinking…';

  @override
  String rcChatGreet(String name) {
    return 'Ask about \"$name\": what to swap, how not to ruin it, what to prep ahead.';
  }

  @override
  String get rcChatPlaceholder => 'Ask about this recipe';

  @override
  String rcCount(int n) {
    return '$n recipes';
  }

  @override
  String rcCountFew(int n) {
    return '$n recipes';
  }

  @override
  String get rcCountOne => '1 recipe';

  @override
  String rcDeleteBody(String name) {
    return '\"$name\" will leave the book. Diary entries logged from it will stay.';
  }

  @override
  String get rcDeleteCta => 'Delete';

  @override
  String get rcDeleteFailed => 'Could not delete. Try again.';

  @override
  String get rcDeleteTitle => 'Delete this recipe?';

  @override
  String get rcEmpty =>
      'Nothing here yet. Tell Nora what is in the kitchen and the first recipe appears.';

  @override
  String get rcEmptyMine => 'No recipes of your own yet. Dictate any to Nora and it lands here.';

  @override
  String get rcEyebrow => 'The kitchen';

  @override
  String get rcFromMine => 'Mine';

  @override
  String get rcFromNora => 'From Nora';

  @override
  String get rcHeroA => 'What to cook';

  @override
  String get rcHeroB => 'today';

  @override
  String get rcHeroLede =>
      'Say what you have at home. Nora suggests and counts the serving; your own recipe works too.';

  @override
  String get rcItemsHead => 'Products';

  @override
  String rcItemsTotal(String g) {
    return 'total $g';
  }

  @override
  String get rcJustNow => 'just now';

  @override
  String get rcLoadFailed => 'The recipe book failed to load. Pull to retry.';

  @override
  String rcMinutes(int n) {
    return '$n min';
  }

  @override
  String get rcNoTools => 'Nothing but a knife and a bowl';

  @override
  String rcOfDay(int p) {
    return 'that is $p% of the daily norm';
  }

  @override
  String get rcPerServing => 'per serving';

  @override
  String get rcPerServingHead => 'Per serving';

  @override
  String get rcPickTitle => 'Pick a dish';

  @override
  String rcPortion(String g) {
    return 'serving $g';
  }

  @override
  String rcServingsFew(int n) {
    return '$n servings';
  }

  @override
  String rcServingsMany(int n) {
    return '$n servings';
  }

  @override
  String get rcServingsOne => '1 serving';

  @override
  String get rcStepsHead => 'How to cook';

  @override
  String get rcSuggestFailed => 'Nora could not compose recipes. Try again.';

  @override
  String get rcTabAll => 'All';

  @override
  String get rcTabMine => 'Mine';

  @override
  String get rcTabNora => 'From Nora';

  @override
  String get rcTitle => 'Recipes';

  @override
  String get rcToolBlender => 'Blender';

  @override
  String get rcToolGrill => 'Grill';

  @override
  String get rcToolMixer => 'Mixer';

  @override
  String get rcToolOven => 'Oven';

  @override
  String get rcToolPan => 'Pan';

  @override
  String get rcToolPot => 'Pot';

  @override
  String get rcToolsHead => 'What the kitchen needs';

  @override
  String rcWhole(String kcal, String g) {
    return 'Whole dish: $kcal, $g';
  }

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
  String get restoredBody1 =>
      'This account was waiting to be deleted. Signing in cancelled that: the diary, the profile and the settings are on this phone again.';

  @override
  String get restoredBody2 =>
      'If you still want the account gone, ask for deletion again in Settings. Any sign-in before we confirm it cancels the request the same way.';

  @override
  String get restoredOk => 'Understood';

  @override
  String get restoredTitle => 'Your data is back';

  @override
  String get setAbout => 'About the app';

  @override
  String get setAccess => 'Access';

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
    return '$kg, $pace/week';
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
  String get setMedical => 'Medical disclaimer';

  @override
  String get setMeds => 'Medications';

  @override
  String get setNorm => 'Norm';

  @override
  String setNormLine(String kcal) {
    return '$kcal';
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
  String setProfileLine(String sex, int age, String height) {
    return '$sex, $age, $height';
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
  String get setUnits => 'Units';

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
  String get slotByHand => 'Enter the numbers yourself';

  @override
  String get slotCancel => 'Cancel';

  @override
  String get slotDinner => 'Dinner';

  @override
  String slotEraseBody(String name) {
    return '\"$name\" still has no numbers. The row will leave the day.';
  }

  @override
  String get slotEraseDo => 'Remove';

  @override
  String get slotEraseTitle => 'Remove the draft?';

  @override
  String slotGrams(Object u) {
    return 'WEIGHT, $u';
  }

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
  String slotKcal(Object u) {
    return '$u';
  }

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
  String get startNormCounting => 'counting…';

  @override
  String get startNormHold => 'holding';

  @override
  String get startNormNote =>
      'This is the Mifflin-St Jeor formula, not medical advice. If you have a condition, are pregnant, or follow a prescribed diet, check with your doctor.';

  @override
  String startNormPerDay(Object u) {
    return '$u a day';
  }

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
  String startPaceUnit(Object u) {
    return '$u a week';
  }

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
  String get startSignInBackText =>
      'Sign in with the same account and everything comes back: the diary, the goal, the norm and the measurements. Nothing to fill in again.';

  @override
  String get startSignInBackTitle => 'Welcome back';

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
  String get startSignInSkip => 'Continue without an account';

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
  String get todayDone => 'Done.';

  @override
  String get todayFailedRetry => 'Did not work. Try again in a minute.';

  @override
  String get todayGoalMet =>
      'Congratulations! 🎉 The weight you wanted is yours, and the goal is closed. And you did that, not the app. Now I am moving your norm to holding, so the result stays with you.';

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
  String todayLoggedIntoWithNumbers(String slotInto, String dish, String kcal, String grams) {
    return 'Logged $slotInto: $dish, $kcal per $grams.';
  }

  @override
  String get todayNoraSlow =>
      'Nora is thinking longer than usual. Try again, the token was not spent.';

  @override
  String get todayOffline => 'No connection. Try again once it is back.';

  @override
  String get todayOfflineSaved =>
      'No connection. The entry stays on the phone and goes up when it returns.';

  @override
  String get todayOutOfBody =>
      'I am quiet for now, but writing entries by hand is always there, and it is free. A subscription switches me back on, and costs about three coffees a month.';

  @override
  String get todayOutOfPlan => 'Subscription';

  @override
  String get todayOutOfTokens => 'The tokens are gone.';

  @override
  String get todayPhotoMeal => 'Photo';

  @override
  String get todayQuestionClosed =>
      'That question is already closed. Say the weight in words if you need to.';

  @override
  String get tourCamera => 'Camera';

  @override
  String get tourCameraHow => 'a plate, a label or a barcode';

  @override
  String get tourDiary => 'Diary memory';

  @override
  String get tourDiaryHow => 'say \"borscht\" and it takes your usual portion';

  @override
  String get tourGuide => 'Guide to the app';

  @override
  String get tourGuideHow => 'ask where things are and how to do them';

  @override
  String get tourMemory => 'Lasting memory';

  @override
  String get tourMemoryHow => '\"no pork\" is enough to say once';

  @override
  String get tourMore => 'Not only food';

  @override
  String get tourMoreHow => 'water, workouts, measurements, recipes';

  @override
  String get tourTitle => 'What Nora can do';

  @override
  String get tourVoice => 'Voice or text';

  @override
  String get tourVoiceHow => '\"two eggs and toast\", and it is logged';

  @override
  String get tourWeek => 'Day and week review';

  @override
  String get tourWeekHow => 'what worked and what to adjust';

  @override
  String get unitCm => 'cm';

  @override
  String get unitG => 'g';

  @override
  String get unitKcal => 'kcal';

  @override
  String get unitKg => 'kg';

  @override
  String get unitKj => 'kJ';

  @override
  String get unitMl => 'ml';

  @override
  String get unitsEnergy => 'Energy';

  @override
  String get unitsLength => 'Height and measurements';

  @override
  String get unitsMass => 'Body weight';

  @override
  String get unitsPortion => 'Food portions';

  @override
  String get unitsTitle => 'Which units';

  @override
  String get unitsVolume => 'Water';

  @override
  String get watchLinked => 'connected';

  @override
  String waterGlasses(int glasses) {
    return 'about $glasses glasses';
  }

  @override
  String waterLess(String step) {
    return '$step less';
  }

  @override
  String waterMore(String step) {
    return '$step more';
  }

  @override
  String get waterNone => 'nothing drunk';

  @override
  String waterOf(String ml) {
    return ' / $ml';
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
  String get welEggs => 'Two fried eggs';

  @override
  String get welEggsGrams => '120 g';

  @override
  String get welHaveAccount => 'I already have an account';

  @override
  String get welLead => 'Counts calories from your own words';

  @override
  String get welSaid => 'Had two eggs and toast';

  @override
  String get welStart => 'Get started';

  @override
  String get welToast => 'Toast with butter';

  @override
  String get welToastGrams => '50 g';

  @override
  String get welTotal => 'Together';

  @override
  String wfBurned(Object u) {
    return 'Burned, $u';
  }

  @override
  String get wfDuration => 'Duration';

  @override
  String get wfDurationCap => 'Duration, min';

  @override
  String get wfEstimate => 'An estimate from your weight and the kind of activity';

  @override
  String get wfFromWatch => 'From a watch or a machine';

  @override
  String wfKcal(Object u) {
    return ' $u';
  }

  @override
  String get wfLog => 'Log it';

  @override
  String wfManualKcal(Object u) {
    return '$u by hand';
  }

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
  String get wkDaysOk => 'days on goal';

  @override
  String get wkEmpty =>
      'Nothing has been logged this week yet. Log the first day and the picture appears.';

  @override
  String get wkFactsHead => 'The week in total';

  @override
  String get wkKcalHead => 'Calories';

  @override
  String get wkLoggedCap => 'days logged';

  @override
  String wkLoggedValue(int n) {
    return '$n of 7';
  }

  @override
  String get wkMacroHead => 'Macros';

  @override
  String get wkNoWeight => 'weight: no weigh-ins';

  @override
  String get wkNoraBtn => 'Build the analysis';

  @override
  String wkNoraFailed(String why) {
    return 'Could not build the analysis: $why';
  }

  @override
  String get wkNoraGreet =>
      'Ask about anything in this read: a dish, a habit, or what to fix first.';

  @override
  String get wkNoraLoading => 'Nora is reading the week…';

  @override
  String get wkNoraLocked => 'The analysis opens on Friday';

  @override
  String get wkNoraNoNet => 'no network';

  @override
  String get wkNoraNoTokens => 'out of tokens';

  @override
  String get wkNoraP1 =>
      'Your base is healthy, and that is rare: almost everything is home-cooked. Borscht, scrambled eggs, porridge: on a base like that the rest is quick to fix.';

  @override
  String get wkNoraP2 =>
      'Now honestly. Vegetables barely showed up all week, while sweets showed up daily: pancakes with honey, compote. Protein runs short not because you eat little, but because the plate is heavy on carbs and light on meat, fish or cheese. And three dinners out of seven landed after ten.';

  @override
  String get wkNoraP3 =>
      'Nothing scary yet, but this is exactly the diet that surprises your bloodwork at forty. One step for next week, change nothing else: something green with every lunch, and water instead of the compote.';

  @override
  String get wkNoraPlaceholder => 'Ask about this week';

  @override
  String get wkNoraPromise =>
      'An honest read of your week: what worked, what slipped, and one step for the next.';

  @override
  String get wkNoraReply1 =>
      'The easiest swap this week: water instead of the compote. A spoon of sugar less every time, and the borscht owes it nothing.';

  @override
  String get wkNoraReply2 =>
      'Greens with lunch do not have to mean a salad. A cucumber or half a pepper next to the plate already does the job.';

  @override
  String get wkNoraSlow => 'the server is taking too long';

  @override
  String get wkNoraTalk => 'Talk it over with Nora';

  @override
  String get wkNoraTitle => 'Nora on your week';

  @override
  String get wkNorm => 'goal';

  @override
  String wkOffNorm(String n) {
    return '$n off the goal';
  }

  @override
  String get wkPastEmpty => 'No past analyses yet. The first one will appear here next Monday.';

  @override
  String wkPastRow(String day) {
    return 'Week of $day';
  }

  @override
  String get wkPastTitle => 'Past weeks';

  @override
  String wkPerDay(Object u) {
    return '$u a day on average';
  }

  @override
  String get wkPerDayAside => 'a day on average';

  @override
  String get wkTitle => 'The week';

  @override
  String wkTotalCap(Object u) {
    return '$u over the week';
  }

  @override
  String get wkWaterCap => 'of water a day';

  @override
  String wkWaterValue(String l) {
    return '$l l';
  }

  @override
  String get wkWeightCap => 'weight this week';

  @override
  String get workoutAdd => 'Add a workout';

  @override
  String workoutBurned(String kcal) {
    return '−$kcal';
  }

  @override
  String get workoutCollapse => 'Collapse';

  @override
  String get workoutMinUnit => 'min';

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
