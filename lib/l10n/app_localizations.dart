import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('uk')];

  /// No description provided for @aboutContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get aboutContact;

  /// No description provided for @aboutDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get aboutDeveloper;

  /// No description provided for @aboutText.
  ///
  /// In en, this message translates to:
  /// **'A food diary that understands ordinary sentences. Nora does the arithmetic, the decisions stay yours.'**
  String get aboutText;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About the app'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @aboutWrite.
  ///
  /// In en, this message translates to:
  /// **'Write to us'**
  String get aboutWrite;

  /// No description provided for @accountBusy.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get accountBusy;

  /// No description provided for @accountGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get accountGoogle;

  /// No description provided for @accountKeepCloud.
  ///
  /// In en, this message translates to:
  /// **'The one in the account'**
  String get accountKeepCloud;

  /// No description provided for @accountNoAccountNote.
  ///
  /// In en, this message translates to:
  /// **'The diary lives only on this phone. Change the phone or remove the app and there is nothing to bring the entries back with: we do not know whose they are.'**
  String get accountNoAccountNote;

  /// No description provided for @accountScopeNote.
  ///
  /// In en, this message translates to:
  /// **'We ask for the email only. Google does not pass us the name, the profile picture or the contacts.'**
  String get accountScopeNote;

  /// No description provided for @accountSettingsDevice.
  ///
  /// In en, this message translates to:
  /// **'settings'**
  String get accountSettingsDevice;

  /// No description provided for @accountSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in.'**
  String get accountSignInFailed;

  /// No description provided for @accountSignInFailedWhy.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. {why}'**
  String accountSignInFailedWhy(String why);

  /// No description provided for @accountSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accountSignOut;

  /// No description provided for @accountSignOutAction.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accountSignOutAction;

  /// No description provided for @accountSignOutAsk.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get accountSignOutAsk;

  /// No description provided for @accountSignOutBack.
  ///
  /// In en, this message translates to:
  /// **'You can sign back in with the same account any time, right here.'**
  String get accountSignOutBack;

  /// No description provided for @accountSignOutNote.
  ///
  /// In en, this message translates to:
  /// **'The entries stay on this phone: signing out does not wipe the diary. What stops is the rest, syncing with other devices and the ability to get the data back if the phone is lost.'**
  String get accountSignOutNote;

  /// No description provided for @accountSince.
  ///
  /// In en, this message translates to:
  /// **'With Calvi since'**
  String get accountSince;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @accountVia.
  ///
  /// In en, this message translates to:
  /// **'Signed in with Google'**
  String get accountVia;

  /// No description provided for @accountWhichDiary.
  ///
  /// In en, this message translates to:
  /// **'Which diary do we keep?'**
  String get accountWhichDiary;

  /// No description provided for @accountWhichDiaryNote.
  ///
  /// In en, this message translates to:
  /// **'This account already has entries, and so does the phone. Only one can stay: the one in the account, or the one on the phone. The other one goes.'**
  String get accountWhichDiaryNote;

  /// No description provided for @actBasketball.
  ///
  /// In en, this message translates to:
  /// **'Basketball'**
  String get actBasketball;

  /// No description provided for @actBike.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get actBike;

  /// No description provided for @actDance.
  ///
  /// In en, this message translates to:
  /// **'Dancing'**
  String get actDance;

  /// No description provided for @actFootball.
  ///
  /// In en, this message translates to:
  /// **'Football'**
  String get actFootball;

  /// No description provided for @actGym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get actGym;

  /// No description provided for @actHiit.
  ///
  /// In en, this message translates to:
  /// **'HIIT'**
  String get actHiit;

  /// No description provided for @actJumprope.
  ///
  /// In en, this message translates to:
  /// **'Skipping'**
  String get actJumprope;

  /// No description provided for @actRun.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get actRun;

  /// No description provided for @actSki.
  ///
  /// In en, this message translates to:
  /// **'Skiing'**
  String get actSki;

  /// No description provided for @actStretch.
  ///
  /// In en, this message translates to:
  /// **'Stretching'**
  String get actStretch;

  /// No description provided for @actSwim.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get actSwim;

  /// No description provided for @actTennis.
  ///
  /// In en, this message translates to:
  /// **'Tennis'**
  String get actTennis;

  /// No description provided for @actWalk.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get actWalk;

  /// No description provided for @actYoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get actYoga;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @activityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get activityHigh;

  /// No description provided for @activityHighHint.
  ///
  /// In en, this message translates to:
  /// **'5-6 workouts'**
  String get activityHighHint;

  /// No description provided for @activityLight.
  ///
  /// In en, this message translates to:
  /// **'Lightly active'**
  String get activityLight;

  /// No description provided for @activityLightHint.
  ///
  /// In en, this message translates to:
  /// **'1-2 workouts a week'**
  String get activityLightHint;

  /// No description provided for @activityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get activityModerate;

  /// No description provided for @activityModerateHint.
  ///
  /// In en, this message translates to:
  /// **'3-4 workouts'**
  String get activityModerateHint;

  /// No description provided for @activitySedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get activitySedentary;

  /// No description provided for @activitySedentaryHint.
  ///
  /// In en, this message translates to:
  /// **'almost no movement'**
  String get activitySedentaryHint;

  /// No description provided for @activityVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very high'**
  String get activityVeryHigh;

  /// No description provided for @activityVeryHighHint.
  ///
  /// In en, this message translates to:
  /// **'physical work or sport every day'**
  String get activityVeryHighHint;

  /// No description provided for @agoDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String agoDays(int count);

  /// No description provided for @agoToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get agoToday;

  /// No description provided for @agoWeek.
  ///
  /// In en, this message translates to:
  /// **'a week ago'**
  String get agoWeek;

  /// No description provided for @agoWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} weeks ago}}'**
  String agoWeeks(int count);

  /// No description provided for @agoYesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get agoYesterday;

  /// No description provided for @allergyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get allergyConfirm;

  /// No description provided for @allergyMild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get allergyMild;

  /// No description provided for @allergyMildHint.
  ///
  /// In en, this message translates to:
  /// **'I will warn you in the text, without blocking the entry.'**
  String get allergyMildHint;

  /// No description provided for @allergyMildShort.
  ///
  /// In en, this message translates to:
  /// **'mild'**
  String get allergyMildShort;

  /// No description provided for @allergyNote.
  ///
  /// In en, this message translates to:
  /// **'If a product\'s composition is not in the base, I do not stay quiet and I do not treat that as safe: I will say separately that the composition is unknown.'**
  String get allergyNote;

  /// No description provided for @allergyNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing found. If the allergen is not in the list, tell Nora: we will add it to the reference so it works for everyone, instead of staying as text for one person.'**
  String get allergyNothing;

  /// No description provided for @allergyRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get allergyRemove;

  /// No description provided for @allergySearch.
  ///
  /// In en, this message translates to:
  /// **'Search {count} allergens'**
  String allergySearch(int count);

  /// No description provided for @allergySevere.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get allergySevere;

  /// No description provided for @allergySevereHint.
  ///
  /// In en, this message translates to:
  /// **'I will stop before logging and say so plainly.'**
  String get allergySevereHint;

  /// No description provided for @allergySevereShort.
  ///
  /// In en, this message translates to:
  /// **'severe'**
  String get allergySevereShort;

  /// No description provided for @allergyTitle.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergyTitle;

  /// No description provided for @anChartGoal.
  ///
  /// In en, this message translates to:
  /// **'goal {value}'**
  String anChartGoal(String value);

  /// No description provided for @anDaysInNorm.
  ///
  /// In en, this message translates to:
  /// **'days on target'**
  String get anDaysInNorm;

  /// No description provided for @anDonePercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% done'**
  String anDonePercent(int percent);

  /// The asterisks mark the part drawn in bold; the note widget reads them.
  ///
  /// In en, this message translates to:
  /// **'At the current pace the goal is around *{date}*'**
  String anEtaHead(String date);

  /// No description provided for @anForMonth.
  ///
  /// In en, this message translates to:
  /// **'over the month'**
  String get anForMonth;

  /// No description provided for @anForQuarter.
  ///
  /// In en, this message translates to:
  /// **'over 3 months'**
  String get anForQuarter;

  /// No description provided for @anForYear.
  ///
  /// In en, this message translates to:
  /// **'over the year'**
  String get anForYear;

  /// No description provided for @anGoalProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress to the goal'**
  String get anGoalProgress;

  /// No description provided for @anKcal.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get anKcal;

  /// No description provided for @anKcalAvg.
  ///
  /// In en, this message translates to:
  /// **'on average a day'**
  String get anKcalAvg;

  /// No description provided for @anKcalEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged for this period yet. Tell Nora what you ate and the chart will build itself.'**
  String get anKcalEmpty;

  /// No description provided for @anKcalTotal.
  ///
  /// In en, this message translates to:
  /// **'over the period, kcal'**
  String get anKcalTotal;

  /// No description provided for @anMacroGoal.
  ///
  /// In en, this message translates to:
  /// **'norm {grams} g'**
  String anMacroGoal(int grams);

  /// No description provided for @anMacrosAvg.
  ///
  /// In en, this message translates to:
  /// **'Macros on average'**
  String get anMacrosAvg;

  /// No description provided for @anMacrosEmpty.
  ///
  /// In en, this message translates to:
  /// **'An average appears as soon as there is something to average: log at least one day.'**
  String get anMacrosEmpty;

  /// No description provided for @anMeasures.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get anMeasures;

  /// No description provided for @anMeasuresChange.
  ///
  /// In en, this message translates to:
  /// **'change {period}'**
  String anMeasuresChange(String period);

  /// No description provided for @anMeasuresEmpty.
  ///
  /// In en, this message translates to:
  /// **'No measurements yet.'**
  String get anMeasuresEmpty;

  /// No description provided for @anMeasuresEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Measure once a month and I will show you what is moving'**
  String get anMeasuresEmptyHint;

  /// No description provided for @anMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get anMonth;

  /// No description provided for @anNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get anNow;

  /// No description provided for @anNowKg.
  ///
  /// In en, this message translates to:
  /// **'now, kg'**
  String get anNowKg;

  /// No description provided for @anOneReading.
  ///
  /// In en, this message translates to:
  /// **'one reading'**
  String get anOneReading;

  /// No description provided for @anOneWeighing.
  ///
  /// In en, this message translates to:
  /// **'One reading so far. The second one shows the direction, and the line starts from it.'**
  String get anOneWeighing;

  /// No description provided for @anPerDay.
  ///
  /// In en, this message translates to:
  /// **'a day'**
  String get anPerDay;

  /// No description provided for @anQuarter.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get anQuarter;

  /// No description provided for @anShareOfNorm.
  ///
  /// In en, this message translates to:
  /// **'{share}% of the norm'**
  String anShareOfNorm(int share);

  /// No description provided for @anTargetKg.
  ///
  /// In en, this message translates to:
  /// **'goal, kg'**
  String get anTargetKg;

  /// No description provided for @anTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get anTitle;

  /// No description provided for @anWater.
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get anWater;

  /// No description provided for @anWaterAvg.
  ///
  /// In en, this message translates to:
  /// **'on average, ml'**
  String get anWaterAvg;

  /// No description provided for @anWaterGoal.
  ///
  /// In en, this message translates to:
  /// **'norm {ml} ml'**
  String anWaterGoal(String ml);

  /// No description provided for @anWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get anWeek;

  /// No description provided for @anWeightEmpty.
  ///
  /// In en, this message translates to:
  /// **'The curve appears after the second weigh-in. Tell Nora your weight and she will log it herself.'**
  String get anWeightEmpty;

  /// No description provided for @anYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get anYear;

  /// No description provided for @assistantAddMemory.
  ///
  /// In en, this message translates to:
  /// **'Add to memory'**
  String get assistantAddMemory;

  /// No description provided for @assistantCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get assistantCollapse;

  /// No description provided for @assistantExample.
  ///
  /// In en, this message translates to:
  /// **'For example, I do not eat mushrooms'**
  String get assistantExample;

  /// No description provided for @assistantForget.
  ///
  /// In en, this message translates to:
  /// **'Forget'**
  String get assistantForget;

  /// No description provided for @assistantHint.
  ///
  /// In en, this message translates to:
  /// **'{name} keeps the diary with you and remembers what you told her about yourself.'**
  String assistantHint(String name);

  /// No description provided for @assistantMemory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get assistantMemory;

  /// No description provided for @assistantMemoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing remembered yet.'**
  String get assistantMemoryEmpty;

  /// No description provided for @assistantMemoryEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Memory comes out of conversations, or add one by hand'**
  String get assistantMemoryEmptyHint;

  /// No description provided for @assistantPinned.
  ///
  /// In en, this message translates to:
  /// **'{count}, {pinned} pinned'**
  String assistantPinned(int count, int pinned);

  /// No description provided for @assistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get assistantTitle;

  /// No description provided for @assistantWhatToRemember.
  ///
  /// In en, this message translates to:
  /// **'What to remember'**
  String get assistantWhatToRemember;

  /// No description provided for @barCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get barCamera;

  /// No description provided for @barGrams.
  ///
  /// In en, this message translates to:
  /// **'{grams} g'**
  String barGrams(int grams);

  /// No description provided for @barHint.
  ///
  /// In en, this message translates to:
  /// **'Write the way you speak.'**
  String get barHint;

  /// No description provided for @barHintMore.
  ///
  /// In en, this message translates to:
  /// **'\"two eggs and toast\", \"drank 300 of water\", \"ran 40 minutes\": I will work it out and put it in the right card'**
  String get barHintMore;

  /// No description provided for @barLogsInto.
  ///
  /// In en, this message translates to:
  /// **'Logging into '**
  String get barLogsInto;

  /// No description provided for @barMic.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get barMic;

  /// No description provided for @barSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get barSend;

  /// No description provided for @camAgain.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get camAgain;

  /// No description provided for @camAllergen.
  ///
  /// In en, this message translates to:
  /// **'Allergen!'**
  String get camAllergen;

  /// No description provided for @camAllergyContains.
  ///
  /// In en, this message translates to:
  /// **'Contains your allergen: {list}'**
  String camAllergyContains(String list);

  /// No description provided for @camAllergyTraces.
  ///
  /// In en, this message translates to:
  /// **'May contain traces of: {list}'**
  String camAllergyTraces(String list);

  /// No description provided for @camBarcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get camBarcode;

  /// No description provided for @camBusy.
  ///
  /// In en, this message translates to:
  /// **'The camera did not open. Usually another app is holding it.'**
  String get camBusy;

  /// No description provided for @camCouldNotRead.
  ///
  /// In en, this message translates to:
  /// **'Could not read the shot'**
  String get camCouldNotRead;

  /// No description provided for @camDish.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get camDish;

  /// No description provided for @camEstimate.
  ///
  /// In en, this message translates to:
  /// **' kcal, an estimate'**
  String get camEstimate;

  /// No description provided for @camFlash.
  ///
  /// In en, this message translates to:
  /// **'Flash'**
  String get camFlash;

  /// No description provided for @camFromPack.
  ///
  /// In en, this message translates to:
  /// **'Figures from the packaging. Logging this costs no tokens.'**
  String get camFromPack;

  /// No description provided for @camGallery.
  ///
  /// In en, this message translates to:
  /// **'From the gallery'**
  String get camGallery;

  /// No description provided for @camHintBarcode.
  ///
  /// In en, this message translates to:
  /// **'the code inside the frame'**
  String get camHintBarcode;

  /// No description provided for @camHintDish.
  ///
  /// In en, this message translates to:
  /// **'point it at the plate'**
  String get camHintDish;

  /// No description provided for @camIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients: {text}'**
  String camIngredients(String text);

  /// Under the shutter: which card the shot will be written into.
  ///
  /// In en, this message translates to:
  /// **'into {slot}'**
  String camIntoSlot(String slot);

  /// No description provided for @camKcalFor.
  ///
  /// In en, this message translates to:
  /// **' kcal for {grams} g'**
  String camKcalFor(int grams);

  /// No description provided for @camKcalPer.
  ///
  /// In en, this message translates to:
  /// **' kcal per {grams} g'**
  String camKcalPer(int grams);

  /// The whole phrase comes from the shared slot phrases, because Ukrainian declines the card name after the preposition.
  ///
  /// In en, this message translates to:
  /// **'Log it {slotInto}'**
  String camLogInto(String slotInto);

  /// No description provided for @camNoPermission.
  ///
  /// In en, this message translates to:
  /// **'No camera permission. You can grant it in the phone\'s settings.'**
  String get camNoPermission;

  /// No description provided for @camNoScanner.
  ///
  /// In en, this message translates to:
  /// **'This phone cannot read codes with the camera.'**
  String get camNoScanner;

  /// No description provided for @camNoTokens.
  ///
  /// In en, this message translates to:
  /// **'Out of tokens for today'**
  String get camNoTokens;

  /// No description provided for @camNotRead.
  ///
  /// In en, this message translates to:
  /// **'Could not make it out'**
  String get camNotRead;

  /// No description provided for @camOfflineShot.
  ///
  /// In en, this message translates to:
  /// **'No connection. You can send the shot to Nora later'**
  String get camOfflineShot;

  /// No description provided for @camPer100.
  ///
  /// In en, this message translates to:
  /// **'No exact weight on the packaging: figures are per 100 g.'**
  String get camPer100;

  /// No description provided for @camPortionPack.
  ///
  /// In en, this message translates to:
  /// **'Portion from the packaging: {g} g. Figures are per portion.'**
  String camPortionPack(int g);

  /// No description provided for @camReading.
  ///
  /// In en, this message translates to:
  /// **'Reading…'**
  String get camReading;

  /// No description provided for @camSendToNora.
  ///
  /// In en, this message translates to:
  /// **'Send to Nora'**
  String get camSendToNora;

  /// No description provided for @camShoot.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get camShoot;

  /// No description provided for @camShotFailed.
  ///
  /// In en, this message translates to:
  /// **'The shot did not work'**
  String get camShotFailed;

  /// No description provided for @camShotReady.
  ///
  /// In en, this message translates to:
  /// **'The shot is ready'**
  String get camShotReady;

  /// No description provided for @camShotReadyNote.
  ///
  /// In en, this message translates to:
  /// **'Nora will read it and answer in the chat: she will name the dish, estimate the portion and show where the figure came from. It costs two tokens.'**
  String get camShotReadyNote;

  /// No description provided for @camStillWorks.
  ///
  /// In en, this message translates to:
  /// **'Meal photos and the gallery work as usual.'**
  String get camStillWorks;

  /// No description provided for @camTitle.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get camTitle;

  /// No description provided for @camTookTooLong.
  ///
  /// In en, this message translates to:
  /// **'Reading it took too long. Try again'**
  String get camTookTooLong;

  /// No description provided for @camUnknownCode.
  ///
  /// In en, this message translates to:
  /// **'I do not know this code'**
  String get camUnknownCode;

  /// No description provided for @camUnknownCodeNote.
  ///
  /// In en, this message translates to:
  /// **'It is not in our base, and not in the open one either. Photograph the meal itself or write the name in words, and Nora will count it.'**
  String get camUnknownCodeNote;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'I understand the data will be deleted forever and cannot be brought back.'**
  String get deleteConfirm;

  /// No description provided for @deleteDays.
  ///
  /// In en, this message translates to:
  /// **'Days with Calvi'**
  String get deleteDays;

  /// No description provided for @deleteEntries.
  ///
  /// In en, this message translates to:
  /// **'Entries in the diary'**
  String get deleteEntries;

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete forever'**
  String get deleteForever;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Everything goes: the diary, weight, measurements, allergies, medications, conversation history. There is no undoing it.'**
  String get deleteNote;

  /// No description provided for @deleteSubNote.
  ///
  /// In en, this message translates to:
  /// **'If it is about the subscription, that can be cancelled separately in the App Store or Google Play without deleting the account.'**
  String get deleteSubNote;

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteTitle;

  /// No description provided for @deleteWeighings.
  ///
  /// In en, this message translates to:
  /// **'Weight readings'**
  String get deleteWeighings;

  /// No description provided for @dictationBusy.
  ///
  /// In en, this message translates to:
  /// **'The microphone is busy. Try again'**
  String get dictationBusy;

  /// No description provided for @dictationFailed.
  ///
  /// In en, this message translates to:
  /// **'Dictation did not work'**
  String get dictationFailed;

  /// No description provided for @dictationNoMatch.
  ///
  /// In en, this message translates to:
  /// **'I did not hear anything I could make out'**
  String get dictationNoMatch;

  /// No description provided for @dictationNoNetwork.
  ///
  /// In en, this message translates to:
  /// **'Recognition needs a network'**
  String get dictationNoNetwork;

  /// No description provided for @dictationNoPermission.
  ///
  /// In en, this message translates to:
  /// **'No microphone permission'**
  String get dictationNoPermission;

  /// No description provided for @dictationSilence.
  ///
  /// In en, this message translates to:
  /// **'Silence. Try again, closer to the microphone'**
  String get dictationSilence;

  /// No description provided for @dictationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Dictation is not available on this phone'**
  String get dictationUnavailable;

  /// No description provided for @doseCapFew.
  ///
  /// In en, this message translates to:
  /// **'capsules'**
  String get doseCapFew;

  /// No description provided for @doseCapMany.
  ///
  /// In en, this message translates to:
  /// **'capsules'**
  String get doseCapMany;

  /// No description provided for @doseCapOne.
  ///
  /// In en, this message translates to:
  /// **'capsule'**
  String get doseCapOne;

  /// No description provided for @doseDropFew.
  ///
  /// In en, this message translates to:
  /// **'drops'**
  String get doseDropFew;

  /// No description provided for @doseDropMany.
  ///
  /// In en, this message translates to:
  /// **'drops'**
  String get doseDropMany;

  /// No description provided for @doseDropOne.
  ///
  /// In en, this message translates to:
  /// **'drop'**
  String get doseDropOne;

  /// No description provided for @doseMlFew.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get doseMlFew;

  /// No description provided for @doseMlMany.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get doseMlMany;

  /// No description provided for @doseMlOne.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get doseMlOne;

  /// No description provided for @doseShotFew.
  ///
  /// In en, this message translates to:
  /// **'shots'**
  String get doseShotFew;

  /// No description provided for @doseShotMany.
  ///
  /// In en, this message translates to:
  /// **'shots'**
  String get doseShotMany;

  /// No description provided for @doseShotOne.
  ///
  /// In en, this message translates to:
  /// **'shot'**
  String get doseShotOne;

  /// No description provided for @doseTabFew.
  ///
  /// In en, this message translates to:
  /// **'tablets'**
  String get doseTabFew;

  /// No description provided for @doseTabMany.
  ///
  /// In en, this message translates to:
  /// **'tablets'**
  String get doseTabMany;

  /// Dose forms. Three each, because Ukrainian picks between them by the number in front; English uses the same word for the last two.
  ///
  /// In en, this message translates to:
  /// **'tablet'**
  String get doseTabOne;

  /// How many records a meal card holds. Ukrainian needs three forms here, which is why this is a plural and not a joined string.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no entries} =1{1 entry} other{{count} entries}}'**
  String entries(int count);

  /// No description provided for @eraseAskBody1.
  ///
  /// In en, this message translates to:
  /// **'The whole diary goes, for all time: meals, water, weight, measurements, workouts, medication and the talk with Nora. On every device, because the server copy is erased too.'**
  String get eraseAskBody1;

  /// No description provided for @eraseAskBody2.
  ///
  /// In en, this message translates to:
  /// **'What stays: the account, the sign-in, the tokens with their balance and the profile settings. This is not signing out, it is a clean slate inside the same account.'**
  String get eraseAskBody2;

  /// No description provided for @eraseAskCta.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get eraseAskCta;

  /// No description provided for @eraseAskTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete every entry?'**
  String get eraseAskTitle;

  /// No description provided for @eraseDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete data'**
  String get eraseDataTitle;

  /// No description provided for @eraseDone.
  ///
  /// In en, this message translates to:
  /// **'The diary is erased. A clean slate.'**
  String get eraseDone;

  /// No description provided for @eraseFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not erase: {why}'**
  String eraseFailed(String why);

  /// No description provided for @eraseSureBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. The diary disappears forever, and neither you nor we can bring it back.'**
  String get eraseSureBody;

  /// No description provided for @eraseSureCta.
  ///
  /// In en, this message translates to:
  /// **'Yes, delete forever'**
  String get eraseSureCta;

  /// No description provided for @eraseSureTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete for sure?'**
  String get eraseSureTitle;

  /// No description provided for @eveningAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get eveningAnd;

  /// No description provided for @eveningBreakfastAcc.
  ///
  /// In en, this message translates to:
  /// **'breakfast'**
  String get eveningBreakfastAcc;

  /// No description provided for @eveningDinnerAcc.
  ///
  /// In en, this message translates to:
  /// **'dinner'**
  String get eveningDinnerAcc;

  /// No description provided for @eveningEmptyDay.
  ///
  /// In en, this message translates to:
  /// **'The day is empty. What did you eat today?'**
  String get eveningEmptyDay;

  /// The evening question. The card name arrives already in the case the sentence needs, because Ukrainian declines it.
  ///
  /// In en, this message translates to:
  /// **'Logged {slot}?'**
  String eveningLogged(String slot);

  /// No description provided for @eveningLunchAcc.
  ///
  /// In en, this message translates to:
  /// **'lunch'**
  String get eveningLunchAcc;

  /// No description provided for @eveningMissing.
  ///
  /// In en, this message translates to:
  /// **'{list} are not logged yet. Which of them happened?'**
  String eveningMissing(String list);

  /// No description provided for @eveningWater.
  ///
  /// In en, this message translates to:
  /// **'How much water did the day come to?'**
  String get eveningWater;

  /// No description provided for @fieldBiceps.
  ///
  /// In en, this message translates to:
  /// **'Biceps'**
  String get fieldBiceps;

  /// No description provided for @fieldChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get fieldChest;

  /// No description provided for @fieldHips.
  ///
  /// In en, this message translates to:
  /// **'Hips'**
  String get fieldHips;

  /// No description provided for @fieldNeck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get fieldNeck;

  /// No description provided for @fieldThigh.
  ///
  /// In en, this message translates to:
  /// **'Thigh'**
  String get fieldThigh;

  /// No description provided for @fieldWaist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get fieldWaist;

  /// No description provided for @fieldWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get fieldWeight;

  /// No description provided for @fieldWrist.
  ///
  /// In en, this message translates to:
  /// **'Wrist'**
  String get fieldWrist;

  /// No description provided for @goalBecomes.
  ///
  /// In en, this message translates to:
  /// **'Becomes'**
  String get goalBecomes;

  /// No description provided for @goalCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current goal '**
  String get goalCurrent;

  /// No description provided for @goalDailyNorm.
  ///
  /// In en, this message translates to:
  /// **'Daily norm'**
  String get goalDailyNorm;

  /// No description provided for @goalDiff.
  ///
  /// In en, this message translates to:
  /// **'{kg} kg apart'**
  String goalDiff(String kg);

  /// No description provided for @goalDirection.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get goalDirection;

  /// No description provided for @goalEta.
  ///
  /// In en, this message translates to:
  /// **'Goal around'**
  String get goalEta;

  /// No description provided for @goalFromStart.
  ///
  /// In en, this message translates to:
  /// **' from {kg} kg at the start. '**
  String goalFromStart(String kg);

  /// No description provided for @goalFromToday.
  ///
  /// In en, this message translates to:
  /// **'The new goal will start from today\'s weight.'**
  String get goalFromToday;

  /// No description provided for @goalKeepNote.
  ///
  /// In en, this message translates to:
  /// **'The norm holds your current weight: you put back exactly what you spend.'**
  String get goalKeepNote;

  /// No description provided for @goalKeepShort.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get goalKeepShort;

  /// No description provided for @goalNew.
  ///
  /// In en, this message translates to:
  /// **'Set a new goal'**
  String get goalNew;

  /// No description provided for @goalNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get goalNewTitle;

  /// No description provided for @goalPace.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get goalPace;

  /// No description provided for @goalPaceFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get goalPaceFast;

  /// No description provided for @goalPaceOk.
  ///
  /// In en, this message translates to:
  /// **'This is the pace most people hold without breaking.'**
  String get goalPaceOk;

  /// No description provided for @goalPaceSlow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get goalPaceSlow;

  /// No description provided for @goalPaceUnit.
  ///
  /// In en, this message translates to:
  /// **'kg a week'**
  String get goalPaceUnit;

  /// No description provided for @goalPaceUsual.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get goalPaceUsual;

  /// No description provided for @goalRange.
  ///
  /// In en, this message translates to:
  /// **'{from} → {to} kg'**
  String goalRange(String from, String to);

  /// No description provided for @goalReplaceNote.
  ///
  /// In en, this message translates to:
  /// **'A goal is not edited, it is replaced. Progress will count from today\'s weight, and the old goal stays in the history. Confirm the replacement?'**
  String get goalReplaceNote;

  /// No description provided for @goalSet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get goalSet;

  /// No description provided for @goalTarget.
  ///
  /// In en, this message translates to:
  /// **'Target weight'**
  String get goalTarget;

  /// No description provided for @goalWas.
  ///
  /// In en, this message translates to:
  /// **'Was'**
  String get goalWas;

  /// Weight with the unit.
  ///
  /// In en, this message translates to:
  /// **'{grams} g'**
  String gramsUnit(int grams);

  /// No description provided for @helloDishBread.
  ///
  /// In en, this message translates to:
  /// **'Rye bread'**
  String get helloDishBread;

  /// Launch splash «Note». There are 155 logical pixels for a dish title before it is cut with an ellipsis; «Two-egg omelette» measured 149 and sat flush against the edge, so the shorter name is deliberate.
  ///
  /// In en, this message translates to:
  /// **'Scrambled eggs'**
  String get helloDishEggs;

  /// Launch splash «Note»: the spoken phrase above the card. Kept short on purpose, it sits in a chat bubble on a screen that lasts two seconds.
  ///
  /// In en, this message translates to:
  /// **'two eggs and toast'**
  String get helloSaid;

  /// No description provided for @helloSlotSub.
  ///
  /// In en, this message translates to:
  /// **'two items'**
  String get helloSlotSub;

  /// No description provided for @helloStepCount.
  ///
  /// In en, this message translates to:
  /// **'I\'ll count the calories'**
  String get helloStepCount;

  /// No description provided for @helloStepLog.
  ///
  /// In en, this message translates to:
  /// **'I\'ll log it in your day'**
  String get helloStepLog;

  /// Launch splash «Plain»: three short promises, one per row. The longest English row measures 205 of the 342 available pixels.
  ///
  /// In en, this message translates to:
  /// **'Say what you ate'**
  String get helloStepSay;

  /// No description provided for @heroBurned.
  ///
  /// In en, this message translates to:
  /// **'-{kcal} kcal from training'**
  String heroBurned(int kcal);

  /// No description provided for @heroDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get heroDays;

  /// No description provided for @heroFrom.
  ///
  /// In en, this message translates to:
  /// **' of {kcal}'**
  String heroFrom(String kcal);

  /// No description provided for @heroGoalKg.
  ///
  /// In en, this message translates to:
  /// **'goal, kg'**
  String get heroGoalKg;

  /// No description provided for @heroKcal.
  ///
  /// In en, this message translates to:
  /// **' kcal'**
  String get heroKcal;

  /// No description provided for @heroKg.
  ///
  /// In en, this message translates to:
  /// **' kg'**
  String get heroKg;

  /// No description provided for @heroLeft.
  ///
  /// In en, this message translates to:
  /// **'left '**
  String get heroLeft;

  /// No description provided for @heroOf.
  ///
  /// In en, this message translates to:
  /// **' of {kcal}'**
  String heroOf(String kcal);

  /// No description provided for @heroOver.
  ///
  /// In en, this message translates to:
  /// **'over by '**
  String get heroOver;

  /// No description provided for @heroWeightFrom.
  ///
  /// In en, this message translates to:
  /// **'now, from {kg} kg at the start of the goal'**
  String heroWeightFrom(String kg);

  /// Calories with the unit, as it stands on badges and cards.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal'**
  String kcalUnit(int kcal);

  /// No description provided for @langSection.
  ///
  /// In en, this message translates to:
  /// **'Interface language'**
  String get langSection;

  /// No description provided for @langSystem.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get langSystem;

  /// No description provided for @legalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String legalUpdated(String date);

  /// No description provided for @loginNoToken.
  ///
  /// In en, this message translates to:
  /// **'Google did not return a token'**
  String get loginNoToken;

  /// No description provided for @loginNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'sign-in is not configured in this build'**
  String get loginNotConfigured;

  /// No description provided for @loginServer.
  ///
  /// In en, this message translates to:
  /// **'server: {why}'**
  String loginServer(String why);

  /// No description provided for @loginSlow.
  ///
  /// In en, this message translates to:
  /// **'Google did not answer in a minute. Try again'**
  String get loginSlow;

  /// No description provided for @macroCShort.
  ///
  /// In en, this message translates to:
  /// **'C {value}'**
  String macroCShort(int value);

  /// No description provided for @macroCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get macroCarbs;

  /// No description provided for @macroCarbsCaps.
  ///
  /// In en, this message translates to:
  /// **'CARBS'**
  String get macroCarbsCaps;

  /// No description provided for @macroCarbsLetter.
  ///
  /// In en, this message translates to:
  /// **'C'**
  String get macroCarbsLetter;

  /// No description provided for @macroFShort.
  ///
  /// In en, this message translates to:
  /// **'F {value}'**
  String macroFShort(int value);

  /// No description provided for @macroFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get macroFat;

  /// No description provided for @macroFatCaps.
  ///
  /// In en, this message translates to:
  /// **'FAT'**
  String get macroFatCaps;

  /// No description provided for @macroFatLetter.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get macroFatLetter;

  /// No description provided for @macroMedsCaps.
  ///
  /// In en, this message translates to:
  /// **'MEDS'**
  String get macroMedsCaps;

  /// No description provided for @macroOfGrams.
  ///
  /// In en, this message translates to:
  /// **' / {goal}g'**
  String macroOfGrams(int goal);

  /// Macro chips under a dish: one letter and the grams.
  ///
  /// In en, this message translates to:
  /// **'P {value}'**
  String macroPShort(int value);

  /// No description provided for @macroProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get macroProtein;

  /// No description provided for @macroProteinCaps.
  ///
  /// In en, this message translates to:
  /// **'PROTEIN'**
  String get macroProteinCaps;

  /// One letter over a macro column on the plate strip.
  ///
  /// In en, this message translates to:
  /// **'P'**
  String get macroProteinLetter;

  /// No description provided for @mealAuto.
  ///
  /// In en, this message translates to:
  /// **'auto '**
  String get mealAuto;

  /// No description provided for @mealEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet. Write what it was and I will log it.'**
  String get mealEmpty;

  /// No description provided for @mealGrams.
  ///
  /// In en, this message translates to:
  /// **'{grams} g'**
  String mealGrams(int grams);

  /// No description provided for @mealThinking.
  ///
  /// In en, this message translates to:
  /// **'Nora is counting…'**
  String get mealThinking;

  /// No description provided for @measureAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a measurement'**
  String get measureAdd;

  /// No description provided for @measureCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get measureCollapse;

  /// No description provided for @measureCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reading} other{{count} readings}}'**
  String measureCount(int count);

  /// No description provided for @measureLast.
  ///
  /// In en, this message translates to:
  /// **'last one {ago}'**
  String measureLast(String ago);

  /// No description provided for @measureNever.
  ///
  /// In en, this message translates to:
  /// **'not measured yet'**
  String get measureNever;

  /// No description provided for @measureNothing.
  ///
  /// In en, this message translates to:
  /// **'nothing yet'**
  String get measureNothing;

  /// No description provided for @measurePick.
  ///
  /// In en, this message translates to:
  /// **'Choose what you will measure. One is enough if the rest does not interest you.'**
  String get measurePick;

  /// No description provided for @measureSave.
  ///
  /// In en, this message translates to:
  /// **'Save the readings'**
  String get measureSave;

  /// No description provided for @measureStats.
  ///
  /// In en, this message translates to:
  /// **'Measurement statistics'**
  String get measureStats;

  /// No description provided for @measureTitle.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get measureTitle;

  /// No description provided for @medsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a medication'**
  String get medsAdd;

  /// No description provided for @medsAllTaken.
  ///
  /// In en, this message translates to:
  /// **'Everything for today is taken'**
  String get medsAllTaken;

  /// No description provided for @medsAt.
  ///
  /// In en, this message translates to:
  /// **'At'**
  String get medsAt;

  /// No description provided for @medsCourse.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get medsCourse;

  /// No description provided for @medsDose.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get medsDose;

  /// No description provided for @medsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet. Add a medication and I will remind you at the right time.'**
  String get medsEmpty;

  /// No description provided for @medsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'I keep the log of doses taken, I do not work out the dosage'**
  String get medsEmptyHint;

  /// No description provided for @medsFinish.
  ///
  /// In en, this message translates to:
  /// **'End the course'**
  String get medsFinish;

  /// No description provided for @medsHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get medsHours;

  /// No description provided for @medsHowOften.
  ///
  /// In en, this message translates to:
  /// **'How often'**
  String get medsHowOften;

  /// No description provided for @medsMine.
  ///
  /// In en, this message translates to:
  /// **'My medications'**
  String get medsMine;

  /// No description provided for @medsName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get medsName;

  /// No description provided for @medsNameExample.
  ///
  /// In en, this message translates to:
  /// **'For example, Magnesium B6'**
  String get medsNameExample;

  /// No description provided for @medsNew.
  ///
  /// In en, this message translates to:
  /// **'New medication'**
  String get medsNew;

  /// No description provided for @medsNextAt.
  ///
  /// In en, this message translates to:
  /// **'Next at '**
  String get medsNextAt;

  /// No description provided for @medsNoneToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing to take today'**
  String get medsNoneToday;

  /// No description provided for @medsNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get medsNote;

  /// No description provided for @medsNow.
  ///
  /// In en, this message translates to:
  /// **'NOW'**
  String get medsNow;

  /// No description provided for @medsOne.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medsOne;

  /// No description provided for @medsPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get medsPast;

  /// No description provided for @medsPastEmpty.
  ///
  /// In en, this message translates to:
  /// **'Courses you no longer take will be here. A medication removed from the list stays in the days you took it.'**
  String get medsPastEmpty;

  /// No description provided for @medsPerTake.
  ///
  /// In en, this message translates to:
  /// **'How much at a time'**
  String get medsPerTake;

  /// No description provided for @medsRemind.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get medsRemind;

  /// No description provided for @medsRemindHint.
  ///
  /// In en, this message translates to:
  /// **'at the chosen hours'**
  String get medsRemindHint;

  /// No description provided for @medsResume.
  ///
  /// In en, this message translates to:
  /// **'Resume the course'**
  String get medsResume;

  /// No description provided for @medsSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get medsSchedule;

  /// No description provided for @medsSince.
  ///
  /// In en, this message translates to:
  /// **'since {date}'**
  String medsSince(String date);

  /// No description provided for @medsTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get medsTime;

  /// No description provided for @medsTitle.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medsTitle;

  /// No description provided for @medsUntil.
  ///
  /// In en, this message translates to:
  /// **'until {date}'**
  String medsUntil(String date);

  /// No description provided for @noraName.
  ///
  /// In en, this message translates to:
  /// **'Nora'**
  String get noraName;

  /// No description provided for @normAuto.
  ///
  /// In en, this message translates to:
  /// **'Count it automatically'**
  String get normAuto;

  /// No description provided for @normAutoFrom.
  ///
  /// In en, this message translates to:
  /// **'From weight, height, age, activity and goal: '**
  String get normAutoFrom;

  /// No description provided for @normAutoHint.
  ///
  /// In en, this message translates to:
  /// **'from weight, height, age, activity and the goal: {kcal} kcal'**
  String normAutoHint(String kcal);

  /// No description provided for @normAutoShort.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get normAutoShort;

  /// No description provided for @normByHand.
  ///
  /// In en, this message translates to:
  /// **'Set it by hand'**
  String get normByHand;

  /// No description provided for @normByHandHint.
  ///
  /// In en, this message translates to:
  /// **'analytics will count against this figure'**
  String get normByHandHint;

  /// No description provided for @normByHandShort.
  ///
  /// In en, this message translates to:
  /// **'By hand'**
  String get normByHandShort;

  /// No description provided for @normCalculatedHead.
  ///
  /// In en, this message translates to:
  /// **'The calculated value is '**
  String get normCalculatedHead;

  /// No description provided for @normCalculatedTail.
  ///
  /// In en, this message translates to:
  /// **'. You can go back to it by choosing \"Automatic\".'**
  String get normCalculatedTail;

  /// No description provided for @normFitCarbs.
  ///
  /// In en, this message translates to:
  /// **'Fit the carbs to the norm'**
  String get normFitCarbs;

  /// No description provided for @normFits.
  ///
  /// In en, this message translates to:
  /// **'The split matches the norm'**
  String get normFits;

  /// No description provided for @normGrams.
  ///
  /// In en, this message translates to:
  /// **'{grams} g'**
  String normGrams(int grams);

  /// No description provided for @normKcalOf.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal'**
  String normKcalOf(String kcal);

  /// No description provided for @normMacroSplit.
  ///
  /// In en, this message translates to:
  /// **'{protein} / {fat} / {carbs} g'**
  String normMacroSplit(int protein, int fat, int carbs);

  /// No description provided for @normMacros.
  ///
  /// In en, this message translates to:
  /// **'Macros'**
  String get normMacros;

  /// No description provided for @normManual.
  ///
  /// In en, this message translates to:
  /// **'set by hand'**
  String get normManual;

  /// No description provided for @normOf.
  ///
  /// In en, this message translates to:
  /// **'of {kcal} kcal'**
  String normOf(String kcal);

  /// No description provided for @normOffBy.
  ///
  /// In en, this message translates to:
  /// **'The split gives {sum} kcal, {off} away'**
  String normOffBy(String sum, int off);

  /// No description provided for @normPerDay.
  ///
  /// In en, this message translates to:
  /// **'kcal a day'**
  String get normPerDay;

  /// No description provided for @normTitle.
  ///
  /// In en, this message translates to:
  /// **'Norm'**
  String get normTitle;

  /// No description provided for @normWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get normWater;

  /// No description provided for @normWaterHead.
  ///
  /// In en, this message translates to:
  /// **'That is '**
  String get normWaterHead;

  /// No description provided for @normWaterPerKg.
  ///
  /// In en, this message translates to:
  /// **'{ml} ml'**
  String normWaterPerKg(int ml);

  /// No description provided for @normWaterTail.
  ///
  /// In en, this message translates to:
  /// **' per kilogram of weight. The usual rough range is 30-40 ml, but it depends on heat and training, so the figure here is not rigid.'**
  String get normWaterTail;

  /// No description provided for @normWhere.
  ///
  /// In en, this message translates to:
  /// **'Where this figure comes from'**
  String get normWhere;

  /// No description provided for @notifyChannel.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get notifyChannel;

  /// No description provided for @notifyChannelHint.
  ///
  /// In en, this message translates to:
  /// **'Reminders about food, water, medications and weigh-ins'**
  String get notifyChannelHint;

  /// No description provided for @notifyDenied.
  ///
  /// In en, this message translates to:
  /// **'The phone refused notifications. Switch them on in the system settings and the reminders will work.'**
  String get notifyDenied;

  /// No description provided for @photoDish.
  ///
  /// In en, this message translates to:
  /// **'Dish'**
  String get photoDish;

  /// No description provided for @photoNotRecognized.
  ///
  /// In en, this message translates to:
  /// **'I could not recognise the dish in this shot'**
  String get photoNotRecognized;

  /// No description provided for @planBuy.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get planBuy;

  /// No description provided for @planFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get planFree;

  /// No description provided for @planLater.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get planLater;

  /// No description provided for @planMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get planMonth;

  /// No description provided for @planMonthBilled.
  ///
  /// In en, this message translates to:
  /// **'billed monthly'**
  String get planMonthBilled;

  /// No description provided for @planMonthPrice.
  ///
  /// In en, this message translates to:
  /// **'180 UAH'**
  String get planMonthPrice;

  /// No description provided for @planNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get planNow;

  /// No description provided for @planPerkChat.
  ///
  /// In en, this message translates to:
  /// **'Unlimited conversations with Nora'**
  String get planPerkChat;

  /// No description provided for @planPerkHistory.
  ///
  /// In en, this message translates to:
  /// **'History and analytics without limits'**
  String get planPerkHistory;

  /// No description provided for @planPerkReports.
  ///
  /// In en, this message translates to:
  /// **'Reports for any period'**
  String get planPerkReports;

  /// No description provided for @planPerks.
  ///
  /// In en, this message translates to:
  /// **'What Premium gives'**
  String get planPerks;

  /// No description provided for @planPitch.
  ///
  /// In en, this message translates to:
  /// **'Unlimited tokens, history without limits, and reports for any period.'**
  String get planPitch;

  /// No description provided for @planPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get planPlan;

  /// No description provided for @planSave.
  ///
  /// In en, this message translates to:
  /// **'-17%'**
  String get planSave;

  /// No description provided for @planStoreNote.
  ///
  /// In en, this message translates to:
  /// **'Payment goes through the App Store or Google Play. You can cancel in the same place, in subscription settings, and Calvi has no say in it.'**
  String get planStoreNote;

  /// No description provided for @planTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get planTitle;

  /// No description provided for @planTokens.
  ///
  /// In en, this message translates to:
  /// **'Tokens'**
  String get planTokens;

  /// No description provided for @planTokensFree.
  ///
  /// In en, this message translates to:
  /// **'2 a day'**
  String get planTokensFree;

  /// No description provided for @planYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get planYear;

  /// No description provided for @planYearBilled.
  ///
  /// In en, this message translates to:
  /// **'1,800 UAH once a year'**
  String get planYearBilled;

  /// No description provided for @planYearHint.
  ///
  /// In en, this message translates to:
  /// **'150 UAH a month, charged once a year'**
  String get planYearHint;

  /// No description provided for @planYearPrice.
  ///
  /// In en, this message translates to:
  /// **'150 UAH'**
  String get planYearPrice;

  /// No description provided for @plateFor.
  ///
  /// In en, this message translates to:
  /// **'for {grams} g'**
  String plateFor(int grams);

  /// No description provided for @plateGrams.
  ///
  /// In en, this message translates to:
  /// **' g'**
  String get plateGrams;

  /// No description provided for @plateKcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get plateKcal;

  /// No description provided for @plateThinking.
  ///
  /// In en, this message translates to:
  /// **'thinking'**
  String get plateThinking;

  /// No description provided for @privacyCrash.
  ///
  /// In en, this message translates to:
  /// **'Crash reports'**
  String get privacyCrash;

  /// No description provided for @privacyCrashHint.
  ///
  /// In en, this message translates to:
  /// **'the error stack, without diary data'**
  String get privacyCrashHint;

  /// No description provided for @privacyDiaryHead.
  ///
  /// In en, this message translates to:
  /// **'Your diary stays yours'**
  String get privacyDiaryHead;

  /// No description provided for @privacyDiarySub.
  ///
  /// In en, this message translates to:
  /// **'neither meals nor weight go into analytics'**
  String get privacyDiarySub;

  /// No description provided for @privacyHealthHead.
  ///
  /// In en, this message translates to:
  /// **'Health data goes to nobody'**
  String get privacyHealthHead;

  /// No description provided for @privacyHealthSub.
  ///
  /// In en, this message translates to:
  /// **'allergies and medications never leave the app'**
  String get privacyHealthSub;

  /// No description provided for @privacyNoPhotosHead.
  ///
  /// In en, this message translates to:
  /// **'Meal photos are not stored'**
  String get privacyNoPhotosHead;

  /// No description provided for @privacyNoPhotosSub.
  ///
  /// In en, this message translates to:
  /// **'the shot goes to be read and is gone'**
  String get privacyNoPhotosSub;

  /// No description provided for @privacyNotCollected.
  ///
  /// In en, this message translates to:
  /// **'What we do not collect'**
  String get privacyNotCollected;

  /// No description provided for @privacyOptional.
  ///
  /// In en, this message translates to:
  /// **'What you can switch off'**
  String get privacyOptional;

  /// No description provided for @privacyPhotosBold.
  ///
  /// In en, this message translates to:
  /// **'are not kept'**
  String get privacyPhotosBold;

  /// No description provided for @privacyPhotosHead.
  ///
  /// In en, this message translates to:
  /// **'Meal photos '**
  String get privacyPhotosHead;

  /// No description provided for @privacyPhotosTail.
  ///
  /// In en, this message translates to:
  /// **': the shot goes for processing and is gone. Analytics never sees dishes, weight, allergies or medications. That is a special category of personal data, and handing it to a third party is not on, however convenient it would be.'**
  String get privacyPhotosTail;

  /// No description provided for @privacyStats.
  ///
  /// In en, this message translates to:
  /// **'Anonymous statistics'**
  String get privacyStats;

  /// No description provided for @privacyStatsHint.
  ///
  /// In en, this message translates to:
  /// **'which screens get opened, without the content of entries'**
  String get privacyStatsHint;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyTitle;

  /// No description provided for @profileActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get profileActivity;

  /// No description provided for @profileAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get profileAge;

  /// No description provided for @profileHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get profileHeight;

  /// No description provided for @profileSex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get profileSex;

  /// No description provided for @remAbout.
  ///
  /// In en, this message translates to:
  /// **'About what'**
  String get remAbout;

  /// No description provided for @remAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a reminder'**
  String get remAdd;

  /// No description provided for @remAt.
  ///
  /// In en, this message translates to:
  /// **'At'**
  String get remAt;

  /// No description provided for @remDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete reminder'**
  String get remDelete;

  /// No description provided for @remEdit.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get remEdit;

  /// No description provided for @remEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet.'**
  String get remEmpty;

  /// No description provided for @remEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add the one thing you really forget, not everything at once'**
  String get remEmptyHint;

  /// No description provided for @remHowOften.
  ///
  /// In en, this message translates to:
  /// **'How often'**
  String get remHowOften;

  /// No description provided for @remName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get remName;

  /// No description provided for @remNew.
  ///
  /// In en, this message translates to:
  /// **'New reminder'**
  String get remNew;

  /// No description provided for @remOpenMeds.
  ///
  /// In en, this message translates to:
  /// **'Open medications'**
  String get remOpenMeds;

  /// No description provided for @remTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get remTime;

  /// No description provided for @remTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remTitle;

  /// The one line inside a notification. No exclamation marks, emoji or reproach: a reminder that nags gets switched off on the third day.
  ///
  /// In en, this message translates to:
  /// **'Log what it was'**
  String get reminderBodyMeal;

  /// No description provided for @reminderBodyMeds.
  ///
  /// In en, this message translates to:
  /// **'On schedule'**
  String get reminderBodyMeds;

  /// No description provided for @reminderBodySummary.
  ///
  /// In en, this message translates to:
  /// **'What did you not log today?'**
  String get reminderBodySummary;

  /// No description provided for @reminderBodyWater.
  ///
  /// In en, this message translates to:
  /// **'Time to drink'**
  String get reminderBodyWater;

  /// No description provided for @reminderBodyWeigh.
  ///
  /// In en, this message translates to:
  /// **'In the morning, before eating'**
  String get reminderBodyWeigh;

  /// No description provided for @reminderBodyWorkout.
  ///
  /// In en, this message translates to:
  /// **'Log it if it happened'**
  String get reminderBodyWorkout;

  /// No description provided for @reminderMeal.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get reminderMeal;

  /// No description provided for @reminderMealHint.
  ///
  /// In en, this message translates to:
  /// **'I will remind you to log the meal'**
  String get reminderMealHint;

  /// No description provided for @reminderMeds.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get reminderMeds;

  /// No description provided for @reminderMedsHint.
  ///
  /// In en, this message translates to:
  /// **'on the schedule from the journal'**
  String get reminderMedsHint;

  /// No description provided for @reminderSummary.
  ///
  /// In en, this message translates to:
  /// **'Day summary'**
  String get reminderSummary;

  /// No description provided for @reminderSummaryHint.
  ///
  /// In en, this message translates to:
  /// **'briefly about the day before bed'**
  String get reminderSummaryHint;

  /// No description provided for @reminderWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get reminderWater;

  /// No description provided for @reminderWaterHint.
  ///
  /// In en, this message translates to:
  /// **'I will remind you to drink'**
  String get reminderWaterHint;

  /// No description provided for @reminderWeigh.
  ///
  /// In en, this message translates to:
  /// **'Weigh-in'**
  String get reminderWeigh;

  /// No description provided for @reminderWeighHint.
  ///
  /// In en, this message translates to:
  /// **'so the weight chart does not break'**
  String get reminderWeighHint;

  /// No description provided for @reminderWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get reminderWorkout;

  /// No description provided for @reminderWorkoutHint.
  ///
  /// In en, this message translates to:
  /// **'I will remind you about the planned one'**
  String get reminderWorkoutHint;

  /// No description provided for @repDaily.
  ///
  /// In en, this message translates to:
  /// **'every day'**
  String get repDaily;

  /// No description provided for @repEveryN.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{every {count} days}}'**
  String repEveryN(int count);

  /// No description provided for @repEveryOther.
  ///
  /// In en, this message translates to:
  /// **'every other day'**
  String get repEveryOther;

  /// No description provided for @repPickDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get repPickDaily;

  /// No description provided for @repPickFromToday.
  ///
  /// In en, this message translates to:
  /// **'Counting from today.'**
  String get repPickFromToday;

  /// No description provided for @repPickInterval.
  ///
  /// In en, this message translates to:
  /// **'Every other day'**
  String get repPickInterval;

  /// No description provided for @repPickNoDays.
  ///
  /// In en, this message translates to:
  /// **'No day is chosen, so the reminder will never fire.'**
  String get repPickNoDays;

  /// No description provided for @repPickWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Days of the week'**
  String get repPickWeekdays;

  /// No description provided for @repWeekdays.
  ///
  /// In en, this message translates to:
  /// **'on weekdays'**
  String get repWeekdays;

  /// No description provided for @repWeekends.
  ///
  /// In en, this message translates to:
  /// **'at weekends'**
  String get repWeekends;

  /// No description provided for @repWeekly.
  ///
  /// In en, this message translates to:
  /// **'once a week'**
  String get repWeekly;

  /// No description provided for @setAbout.
  ///
  /// In en, this message translates to:
  /// **'About the app'**
  String get setAbout;

  /// No description provided for @setAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get setAllergies;

  /// No description provided for @setAssistantLine.
  ///
  /// In en, this message translates to:
  /// **'{name}, {count} in memory'**
  String setAssistantLine(String name, int count);

  /// No description provided for @setDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account and data'**
  String get setDeleteAccount;

  /// No description provided for @setFreeTierHead.
  ///
  /// In en, this message translates to:
  /// **'For Ukraine\'s defenders, and for those serving in the Armed Forces, the State Emergency Service, DTEK, medics, volunteers and teachers in front-line areas, the paid plan is '**
  String get setFreeTierHead;

  /// No description provided for @setFreeTierHow.
  ///
  /// In en, this message translates to:
  /// **' How to get it'**
  String get setFreeTierHow;

  /// No description provided for @setFreeTierShort.
  ///
  /// In en, this message translates to:
  /// **'For Ukraine\'s defenders, and for those serving in the Armed Forces, the State Emergency Service, DTEK, medics, volunteers and teachers in front-line areas, the paid plan is FREE'**
  String get setFreeTierShort;

  /// No description provided for @setFreeTierTelegram.
  ///
  /// In en, this message translates to:
  /// **'Write on Telegram'**
  String get setFreeTierTelegram;

  /// No description provided for @setFreeTierTitle.
  ///
  /// In en, this message translates to:
  /// **'Free plan'**
  String get setFreeTierTitle;

  /// No description provided for @setFreeTierWord.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get setFreeTierWord;

  /// No description provided for @setFreeTierWrite.
  ///
  /// In en, this message translates to:
  /// **'Write to the developer and the paid plan will be switched on for you the same day.'**
  String get setFreeTierWrite;

  /// No description provided for @setGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get setGoal;

  /// No description provided for @setGoalKeep.
  ///
  /// In en, this message translates to:
  /// **'keep weight'**
  String get setGoalKeep;

  /// No description provided for @setGoalLine.
  ///
  /// In en, this message translates to:
  /// **'{kg} kg, {pace}/week'**
  String setGoalLine(String kg, String pace);

  /// No description provided for @setGroupAbout.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get setGroupAbout;

  /// No description provided for @setGroupAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get setGroupAccount;

  /// No description provided for @setGroupAssistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get setGroupAssistant;

  /// No description provided for @setGroupDocs.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get setGroupDocs;

  /// No description provided for @setGroupHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get setGroupHealth;

  /// No description provided for @setLang.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get setLang;

  /// No description provided for @setMeds.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get setMeds;

  /// No description provided for @setNorm.
  ///
  /// In en, this message translates to:
  /// **'Norm'**
  String get setNorm;

  /// No description provided for @setNormLine.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal'**
  String setNormLine(String kcal);

  /// No description provided for @setPlan.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get setPlan;

  /// No description provided for @setPlanFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get setPlanFree;

  /// No description provided for @setPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get setPolicy;

  /// No description provided for @setPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data and analytics'**
  String get setPrivacy;

  /// No description provided for @setProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get setProfile;

  /// The one-line summary under Profile: sex, age, height.
  ///
  /// In en, this message translates to:
  /// **'{sex}, {age}, {height} cm'**
  String setProfileLine(String sex, int age, int height);

  /// No description provided for @setReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get setReminders;

  /// No description provided for @setRemindersOff.
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get setRemindersOff;

  /// No description provided for @setTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get setTerms;

  /// No description provided for @setTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get setTheme;

  /// No description provided for @setTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get setTitle;

  /// No description provided for @setUnset.
  ///
  /// In en, this message translates to:
  /// **'not set'**
  String get setUnset;

  /// No description provided for @sexOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get sexOther;

  /// No description provided for @sexShortFemale.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get sexShortFemale;

  /// One letter, as the profile row prints it beside age and height.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get sexShortMale;

  /// The four meal cards. The assistant may rename a card by the time it happened, and then its own words are shown instead of these.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get slotBreakfast;

  /// No description provided for @slotDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get slotDinner;

  /// «Logged into breakfast». A whole phrase, not a preposition glued to the name: Ukrainian declines the noun after it («у вечерю», not «в вечеря») and alternates the preposition itself for sound, so neither half survives being assembled in code.
  ///
  /// In en, this message translates to:
  /// **'into breakfast'**
  String get slotIntoBreakfast;

  /// No description provided for @slotIntoDinner.
  ///
  /// In en, this message translates to:
  /// **'into dinner'**
  String get slotIntoDinner;

  /// No description provided for @slotIntoLunch.
  ///
  /// In en, this message translates to:
  /// **'into lunch'**
  String get slotIntoLunch;

  /// A card the assistant renamed by the time it happened. Its name arrives in her own words and cannot be declined, so quotes hold it out of the sentence instead.
  ///
  /// In en, this message translates to:
  /// **'into “{name}”'**
  String slotIntoOther(String name);

  /// No description provided for @slotIntoSnack.
  ///
  /// In en, this message translates to:
  /// **'into a snack'**
  String get slotIntoSnack;

  /// No description provided for @slotLog.
  ///
  /// In en, this message translates to:
  /// **'Log it'**
  String get slotLog;

  /// No description provided for @slotLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get slotLunch;

  /// No description provided for @slotSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get slotSnack;

  /// No description provided for @slotWriteWhat.
  ///
  /// In en, this message translates to:
  /// **'Write what it was'**
  String get slotWriteWhat;

  /// No description provided for @startAbout.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get startAbout;

  /// No description provided for @startAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get startAge;

  /// Age beside the drum. Ukrainian needs three forms, which is why this is a plural rather than a joined string.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year} other{{count} years}}'**
  String startAgeYears(int count);

  /// No description provided for @startAgreeAnd.
  ///
  /// In en, this message translates to:
  /// **' and the '**
  String get startAgreeAnd;

  /// The consent line is assembled from spans, because the two document names are tappable.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get startAgreeHead;

  /// No description provided for @startAgreePrivacy.
  ///
  /// In en, this message translates to:
  /// **'privacy policy'**
  String get startAgreePrivacy;

  /// No description provided for @startAgreeTerms.
  ///
  /// In en, this message translates to:
  /// **'terms of use'**
  String get startAgreeTerms;

  /// No description provided for @startAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get startAllergies;

  /// No description provided for @startDeviceFirstRun.
  ///
  /// In en, this message translates to:
  /// **'first run'**
  String get startDeviceFirstRun;

  /// No description provided for @startGoal.
  ///
  /// In en, this message translates to:
  /// **'Where we are heading'**
  String get startGoal;

  /// No description provided for @startGoalGain.
  ///
  /// In en, this message translates to:
  /// **'Gain weight'**
  String get startGoalGain;

  /// No description provided for @startGoalGainHint.
  ///
  /// In en, this message translates to:
  /// **'a surplus at the pace you pick'**
  String get startGoalGainHint;

  /// No description provided for @startGoalKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep weight'**
  String get startGoalKeep;

  /// No description provided for @startGoalKeepHint.
  ///
  /// In en, this message translates to:
  /// **'you put back exactly what you spend'**
  String get startGoalKeepHint;

  /// No description provided for @startGoalLose.
  ///
  /// In en, this message translates to:
  /// **'Lose weight'**
  String get startGoalLose;

  /// No description provided for @startGoalLoseHint.
  ///
  /// In en, this message translates to:
  /// **'a deficit at the pace you pick'**
  String get startGoalLoseHint;

  /// No description provided for @startHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get startHeight;

  /// No description provided for @startLife.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get startLife;

  /// No description provided for @startNorm.
  ///
  /// In en, this message translates to:
  /// **'Your norm'**
  String get startNorm;

  /// No description provided for @startNormHold.
  ///
  /// In en, this message translates to:
  /// **'holding'**
  String get startNormHold;

  /// No description provided for @startNormNora.
  ///
  /// In en, this message translates to:
  /// **'Counted. It gets easier from here.'**
  String get startNormNora;

  /// No description provided for @startNormNoraHint.
  ///
  /// In en, this message translates to:
  /// **'Write or say it however suits you: \"two eggs and toast\", \"drank 300 of water\". Whatever else I need, I will ask in the conversation.'**
  String get startNormNoraHint;

  /// No description provided for @startNormNote.
  ///
  /// In en, this message translates to:
  /// **'This is the Mifflin-St Jeor formula, not medical advice. If you have a condition, are pregnant, or follow a prescribed diet, check with your doctor.'**
  String get startNormNote;

  /// No description provided for @startNormPerDay.
  ///
  /// In en, this message translates to:
  /// **'kcal a day'**
  String get startNormPerDay;

  /// No description provided for @startNormWeeks.
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get startNormWeeks;

  /// No description provided for @startPace.
  ///
  /// In en, this message translates to:
  /// **'How fast'**
  String get startPace;

  /// Opening of the line that names the date. The date itself is bold, so the sentence arrives in three pieces.
  ///
  /// In en, this message translates to:
  /// **'Goal around '**
  String get startPaceEtaHead;

  /// No description provided for @startPaceEtaTail.
  ///
  /// In en, this message translates to:
  /// **', that is '**
  String get startPaceEtaTail;

  /// No description provided for @startPaceFast.
  ///
  /// In en, this message translates to:
  /// **'fast'**
  String get startPaceFast;

  /// No description provided for @startPaceSlow.
  ///
  /// In en, this message translates to:
  /// **'slow'**
  String get startPaceSlow;

  /// No description provided for @startPaceUnit.
  ///
  /// In en, this message translates to:
  /// **'kg a week'**
  String get startPaceUnit;

  /// No description provided for @startPaceUsual.
  ///
  /// In en, this message translates to:
  /// **'steady'**
  String get startPaceUsual;

  /// No description provided for @startPaceWarning.
  ///
  /// In en, this message translates to:
  /// **'A pace like this is hard to hold and usually breaks. Under 0.8 kg a week the result comes slower but stays.'**
  String get startPaceWarning;

  /// No description provided for @startPaceWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week} other{{count} weeks}}'**
  String startPaceWeeks(int count);

  /// No description provided for @startSex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get startSex;

  /// No description provided for @startSexFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get startSexFemale;

  /// No description provided for @startSexMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get startSexMale;

  /// No description provided for @startSexOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get startSexOther;

  /// No description provided for @startSignInApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get startSignInApple;

  /// No description provided for @startSignInBusy.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get startSignInBusy;

  /// No description provided for @startSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. Try again, or carry on without an account.'**
  String get startSignInFailed;

  /// No description provided for @startSignInFailedWhy.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. {why}'**
  String startSignInFailedWhy(String why);

  /// No description provided for @startSignInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get startSignInGoogle;

  /// No description provided for @startSignInSkip.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get startSignInSkip;

  /// No description provided for @startSignInText.
  ///
  /// In en, this message translates to:
  /// **'The norm is counted. Sign in to keep it: history, measurements and entries will be on every device, not only here.'**
  String get startSignInText;

  /// No description provided for @startSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Let us keep this'**
  String get startSignInTitle;

  /// No description provided for @startTargetWeight.
  ///
  /// In en, this message translates to:
  /// **'Target weight'**
  String get startTargetWeight;

  /// No description provided for @startWeightNow.
  ///
  /// In en, this message translates to:
  /// **'Weight now'**
  String get startWeightNow;

  /// No description provided for @startYearsShort.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get startYearsShort;

  /// No description provided for @storageBroken.
  ///
  /// In en, this message translates to:
  /// **'Could not open the storage. Your entries are safe, but there is nothing to show them with right now.'**
  String get storageBroken;

  /// No description provided for @themeAquarelle.
  ///
  /// In en, this message translates to:
  /// **'Watercolor'**
  String get themeAquarelle;

  /// No description provided for @themeAquarelleHint.
  ///
  /// In en, this message translates to:
  /// **'light, with pastel clouds on the ground'**
  String get themeAquarelleHint;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeDarkHint.
  ///
  /// In en, this message translates to:
  /// **'always the dark interface'**
  String get themeDarkHint;

  /// No description provided for @themeDawn.
  ///
  /// In en, this message translates to:
  /// **'Dawn'**
  String get themeDawn;

  /// No description provided for @themeDawnHint.
  ///
  /// In en, this message translates to:
  /// **'light, with warm light from the side'**
  String get themeDawnHint;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeLightHint.
  ///
  /// In en, this message translates to:
  /// **'always the light interface'**
  String get themeLightHint;

  /// No description provided for @themeSectionLook.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get themeSectionLook;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Device theme'**
  String get themeSystem;

  /// No description provided for @themeSystemHint.
  ///
  /// In en, this message translates to:
  /// **'follows the system setting'**
  String get themeSystemHint;

  /// No description provided for @todayBarcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get todayBarcode;

  /// No description provided for @todayCodeTalk.
  ///
  /// In en, this message translates to:
  /// **'I scanned barcode {code} and no base knows it. Do not log anything: ask me about this product or tell me how to count it.'**
  String todayCodeTalk(String code);

  /// No description provided for @todayDemo.
  ///
  /// In en, this message translates to:
  /// **'Demo'**
  String get todayDemo;

  /// No description provided for @todayDone.
  ///
  /// In en, this message translates to:
  /// **'Done.'**
  String get todayDone;

  /// No description provided for @todayFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Did not work. Try again in a minute.'**
  String get todayFailedRetry;

  /// One question per dish whose weight was not stated. The app writes it, not the model: on two dishes the model wrote one question for both, and one number cannot answer for two dishes.
  ///
  /// In en, this message translates to:
  /// **'How many grams was the {dish}?'**
  String todayHowManyGrams(String dish);

  /// No description provided for @todayLogFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not log it. Try again.'**
  String get todayLogFailed;

  /// No description provided for @todayLogged.
  ///
  /// In en, this message translates to:
  /// **'Logged.'**
  String get todayLogged;

  /// No description provided for @todayLoggedAskWeight.
  ///
  /// In en, this message translates to:
  /// **'Logged {slotInto}. Tell me the weight if you want it exact.'**
  String todayLoggedAskWeight(String slotInto);

  /// No description provided for @todayLoggedAskWeightShort.
  ///
  /// In en, this message translates to:
  /// **'Logged. Tell me the weight if you want it exact.'**
  String get todayLoggedAskWeightShort;

  /// No description provided for @todayLoggedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} logged'**
  String todayLoggedCount(int count);

  /// No description provided for @todayLoggedInto.
  ///
  /// In en, this message translates to:
  /// **'Logged {slotInto}: {dish}.'**
  String todayLoggedInto(String slotInto, String dish);

  /// No description provided for @todayLoggedIntoWithNumbers.
  ///
  /// In en, this message translates to:
  /// **'Logged {slotInto}: {dish}, {kcal} kcal per {grams} g.'**
  String todayLoggedIntoWithNumbers(String slotInto, String dish, int kcal, int grams);

  /// No description provided for @todayMine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get todayMine;

  /// No description provided for @todayNoraSlow.
  ///
  /// In en, this message translates to:
  /// **'Nora is thinking longer than usual. Try again, the token was not spent.'**
  String get todayNoraSlow;

  /// No description provided for @todayOffline.
  ///
  /// In en, this message translates to:
  /// **'No connection. Try again once it is back.'**
  String get todayOffline;

  /// No description provided for @todayOfflineSaved.
  ///
  /// In en, this message translates to:
  /// **'No connection. The entry stays on the phone and goes up when it returns.'**
  String get todayOfflineSaved;

  /// No description provided for @todayOutOfTokens.
  ///
  /// In en, this message translates to:
  /// **'Out of tokens for today. Logging by hand always works.'**
  String get todayOutOfTokens;

  /// No description provided for @todayPhotoMeal.
  ///
  /// In en, this message translates to:
  /// **'Meal photo'**
  String get todayPhotoMeal;

  /// No description provided for @todayQuestionClosed.
  ///
  /// In en, this message translates to:
  /// **'That question is already closed. Say the weight in words if you need to.'**
  String get todayQuestionClosed;

  /// No description provided for @todayShowingDemo.
  ///
  /// In en, this message translates to:
  /// **'Showing the sample day'**
  String get todayShowingDemo;

  /// No description provided for @todayShowingMine.
  ///
  /// In en, this message translates to:
  /// **'Showing my entries'**
  String get todayShowingMine;

  /// No description provided for @unitCm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get unitCm;

  /// No description provided for @unitG.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get unitG;

  /// Bare units, for places that set the figure and the unit in different type.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get unitKcal;

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitMl.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitMl;

  /// No description provided for @waterGlasses.
  ///
  /// In en, this message translates to:
  /// **'about {glasses} glasses'**
  String waterGlasses(int glasses);

  /// No description provided for @waterLess.
  ///
  /// In en, this message translates to:
  /// **'{step} ml less'**
  String waterLess(int step);

  /// No description provided for @waterMore.
  ///
  /// In en, this message translates to:
  /// **'{step} ml more'**
  String waterMore(int step);

  /// No description provided for @waterNone.
  ///
  /// In en, this message translates to:
  /// **'nothing drunk'**
  String get waterNone;

  /// No description provided for @waterOf.
  ///
  /// In en, this message translates to:
  /// **' / {ml} ml'**
  String waterOf(String ml);

  /// No description provided for @waterShare.
  ///
  /// In en, this message translates to:
  /// **'{pct}% of the daily goal'**
  String waterShare(int pct);

  /// No description provided for @waterTitle.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get waterTitle;

  /// No description provided for @wcNoTime.
  ///
  /// In en, this message translates to:
  /// **'no duration'**
  String get wcNoTime;

  /// No description provided for @wdFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get wdFri;

  /// No description provided for @wdMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get wdMon;

  /// No description provided for @wdSat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get wdSat;

  /// No description provided for @wdSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get wdSun;

  /// No description provided for @wdThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get wdThu;

  /// No description provided for @wdTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get wdTue;

  /// No description provided for @wdWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wdWed;

  /// No description provided for @weightHint.
  ///
  /// In en, this message translates to:
  /// **'What you weigh today. The goal and the pace towards it live separately.'**
  String get weightHint;

  /// No description provided for @weightNote.
  ///
  /// In en, this message translates to:
  /// **'Weigh yourself in the morning, before eating: that way the daily swings do not turn the chart into noise. One reading a week is already a trend.'**
  String get weightNote;

  /// No description provided for @weightTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightTitle;

  /// No description provided for @wfBurned.
  ///
  /// In en, this message translates to:
  /// **'Burned, kcal'**
  String get wfBurned;

  /// No description provided for @wfDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get wfDuration;

  /// No description provided for @wfDurationCap.
  ///
  /// In en, this message translates to:
  /// **'Duration, min'**
  String get wfDurationCap;

  /// No description provided for @wfEstimate.
  ///
  /// In en, this message translates to:
  /// **'An estimate from your weight and the kind of activity'**
  String get wfEstimate;

  /// No description provided for @wfFromWatch.
  ///
  /// In en, this message translates to:
  /// **'From a watch or a machine'**
  String get wfFromWatch;

  /// No description provided for @wfKcal.
  ///
  /// In en, this message translates to:
  /// **' kcal'**
  String get wfKcal;

  /// No description provided for @wfLog.
  ///
  /// In en, this message translates to:
  /// **'Log it'**
  String get wfLog;

  /// No description provided for @wfManualKcal.
  ///
  /// In en, this message translates to:
  /// **'kcal by hand'**
  String get wfManualKcal;

  /// No description provided for @wfMin.
  ///
  /// In en, this message translates to:
  /// **'{min} min'**
  String wfMin(int min);

  /// No description provided for @wfMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get wfMinutes;

  /// No description provided for @wfNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get wfNote;

  /// No description provided for @wfNoteExample.
  ///
  /// In en, this message translates to:
  /// **'Legs, hard'**
  String get wfNoteExample;

  /// No description provided for @wfOptional.
  ///
  /// In en, this message translates to:
  /// **'  optional'**
  String get wfOptional;

  /// No description provided for @wheelLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get wheelLess;

  /// No description provided for @wheelMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get wheelMore;

  /// No description provided for @workoutAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a workout'**
  String get workoutAdd;

  /// No description provided for @workoutBurned.
  ///
  /// In en, this message translates to:
  /// **'−{kcal} kcal'**
  String workoutBurned(int kcal);

  /// No description provided for @workoutCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get workoutCollapse;

  /// No description provided for @workoutNone.
  ///
  /// In en, this message translates to:
  /// **'nothing logged'**
  String get workoutNone;

  /// No description provided for @workoutSessions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session} other{{count} sessions}}'**
  String workoutSessions(int count);

  /// No description provided for @workoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workoutTitle;
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return LEn();
    case 'uk':
      return LUk();
  }

  throw FlutterError(
    'L.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
