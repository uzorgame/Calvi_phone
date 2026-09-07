// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class LDe extends L {
  LDe([String locale = 'de']) : super(locale);

  @override
  String get aboutContact => 'Kontakt';

  @override
  String get aboutDeveloper => 'Entwickler';

  @override
  String get aboutText =>
      'Ein Ernährungstagebuch, das normale Sätze versteht. Nora rechnet, die Entscheidungen bleiben bei dir.';

  @override
  String get aboutTitle => 'Über die App';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutWrite => 'Schreib uns';

  @override
  String get accountBusy => 'Melde an…';

  @override
  String get accountGoogle => 'Weiter mit Google';

  @override
  String get accountKeepCloud => 'Das aus dem Konto';

  @override
  String get accountNoAccountNote =>
      'Das Tagebuch lebt nur auf diesem Telefon. Wechsel das Telefon oder lösch die App, und es gibt nichts, womit man die Einträge zurückholt: wir wissen nicht, wem sie gehören.';

  @override
  String get accountScopeNote =>
      'Wir fragen nur die E-Mail ab. Google gibt uns weder den Namen noch das Profilbild noch die Kontakte.';

  @override
  String get accountSettingsDevice => 'Einstellungen';

  @override
  String get accountSignInFailed => 'Anmelden hat nicht geklappt.';

  @override
  String accountSignInFailedWhy(String why) {
    return 'Anmelden hat nicht geklappt. $why';
  }

  @override
  String get accountSignOut => 'Abmelden';

  @override
  String get accountSignOutAction => 'Abmelden';

  @override
  String get accountSignOutAsk => 'Abmelden?';

  @override
  String get accountSignOutBack =>
      'Melde dich mit demselben Konto wieder an, dann ist alles zurück. Was offline geschrieben wurde und den Server noch nicht erreicht hat, lässt sich nicht zurückholen.';

  @override
  String get accountSignOutNote =>
      'Dieses Telefon wird geleert: Tagebuch, Profil, Medikamente und das Gespräch mit Nora gehen weg. Deine Einträge bleiben auf dem Server, unter deinem Konto.';

  @override
  String get accountSince => 'Bei Calvi seit';

  @override
  String get accountTitle => 'Konto';

  @override
  String get accountVia => 'Angemeldet mit Google';

  @override
  String get accountViaApple => 'Angemeldet mit Apple';

  @override
  String get accountWhichDiary => 'Welches Tagebuch behalten wir?';

  @override
  String get accountWhichDiaryNote =>
      'Dieses Konto hat schon Einträge, das Telefon auch. Bleiben kann nur eines: das aus dem Konto oder das vom Telefon. Das andere geht weg.';

  @override
  String get actBasketball => 'Basketball';

  @override
  String get actBike => 'Radfahren';

  @override
  String get actDance => 'Tanzen';

  @override
  String get actFootball => 'Fußball';

  @override
  String get actGym => 'Fitnessstudio';

  @override
  String get actHiit => 'HIIT';

  @override
  String get actJumprope => 'Seilspringen';

  @override
  String get actRun => 'Laufen';

  @override
  String get actSki => 'Ski';

  @override
  String get actStretch => 'Dehnen';

  @override
  String get actSwim => 'Schwimmen';

  @override
  String get actTennis => 'Tennis';

  @override
  String get actWalk => 'Gehen';

  @override
  String get actYoga => 'Yoga';

  @override
  String get actionAdd => 'Hinzufügen';

  @override
  String get actionBack => 'Zurück';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionClose => 'Schließen';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionDone => 'Fertig';

  @override
  String get actionNext => 'Weiter';

  @override
  String get actionSave => 'Speichern';

  @override
  String get activityHigh => 'Hoch';

  @override
  String get activityHighHint => '5-6 Einheiten';

  @override
  String get activityLight => 'Wenig aktiv';

  @override
  String get activityLightHint => '1-2 Einheiten pro Woche';

  @override
  String get activityModerate => 'Mittel';

  @override
  String get activityModerateHint => '3-4 Einheiten';

  @override
  String get activitySedentary => 'Sitzend';

  @override
  String get activitySedentaryHint => 'fast keine Bewegung';

  @override
  String get activityVeryHigh => 'Sehr hoch';

  @override
  String get activityVeryHighHint => 'körperliche Arbeit oder täglich Sport';

  @override
  String agoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Tagen',
      one: 'vor 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get agoToday => 'heute';

  @override
  String get agoWeek => 'vor einer Woche';

  @override
  String agoWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'vor $count Wochen');
    return '$_temp0';
  }

  @override
  String get agoYesterday => 'gestern';

  @override
  String get allergyConfirm => 'Bestätigen';

  @override
  String get allergyMild => 'Leicht';

  @override
  String get allergyMildHint => 'Ich warne dich im Text, ohne den Eintrag zu blockieren.';

  @override
  String get allergyMildShort => 'leicht';

  @override
  String get allergyNote =>
      'Wenn die Zusammensetzung eines Produkts nicht im Verzeichnis steht, schweige ich nicht und halte das auch nicht für unbedenklich: ich sage dir gesondert, dass die Zusammensetzung unbekannt ist.';

  @override
  String get allergyNothing =>
      'Nichts gefunden. Wenn das Allergen nicht in der Liste steht, sag es Nora: wir nehmen es ins Verzeichnis auf, damit es für alle wirkt, statt Text für eine einzelne Person zu bleiben.';

  @override
  String get allergyRemove => 'Entfernen';

  @override
  String allergySearch(int count) {
    return 'Unter $count Allergenen suchen';
  }

  @override
  String get allergySevere => 'Schwer';

  @override
  String get allergySevereHint => 'Ich halte vor dem Eintragen an und sage es dir deutlich.';

  @override
  String get allergySevereShort => 'schwer';

  @override
  String get allergyTitle => 'Allergien';

  @override
  String anChartGoal(String value) {
    return 'Ziel $value';
  }

  @override
  String get anDaysInNorm => 'Tage im Ziel';

  @override
  String anDonePercent(int percent) {
    return '$percent% geschafft';
  }

  @override
  String anEtaHead(String date) {
    return 'In diesem Tempo erreichst du das Ziel um den *$date*';
  }

  @override
  String get anForMonth => 'im Monat';

  @override
  String get anForQuarter => 'in 3 Monaten';

  @override
  String get anForYear => 'im Jahr';

  @override
  String get anGoalProgress => 'Fortschritt zum Ziel';

  @override
  String get anKcal => 'Kalorien';

  @override
  String get anKcalAvg => 'im Schnitt am Tag';

  @override
  String get anKcalEmpty =>
      'In diesem Zeitraum ist noch nichts eingetragen. Sag Nora, was du gegessen hast, und das Diagramm baut sich von selbst.';

  @override
  String get anKcalTotal => 'im Zeitraum, kcal';

  @override
  String anMacroGoal(int grams) {
    return 'Richtwert $grams g';
  }

  @override
  String get anMacrosAvg => 'Makros im Schnitt';

  @override
  String get anMacrosEmpty =>
      'Ein Schnitt entsteht, sobald es etwas zu mitteln gibt: trag wenigstens einen Tag ein.';

  @override
  String get anMeasures => 'Maße';

  @override
  String anMeasuresChange(String period) {
    return 'Veränderung $period';
  }

  @override
  String get anMeasuresEmpty => 'Noch keine Maße.';

  @override
  String get anMeasuresEmptyHint => 'Miss einmal im Monat, dann zeige ich dir, was sich bewegt';

  @override
  String get anMonth => 'Monat';

  @override
  String get anNow => 'jetzt';

  @override
  String get anNowKg => 'jetzt, kg';

  @override
  String get anOneReading => 'eine Messung';

  @override
  String get anOneWeighing =>
      'Bisher gibt es nur eine Messung. Die zweite zeigt die Richtung, und die Linie beginnt dort.';

  @override
  String get anPerDay => 'am Tag';

  @override
  String get anQuarter => '3 Monate';

  @override
  String anShareOfNorm(int share) {
    return '$share% des Richtwerts';
  }

  @override
  String get anStartKg => 'Start, kg';

  @override
  String get anTargetKg => 'Ziel, kg';

  @override
  String get anTitle => 'Statistik';

  @override
  String get anWater => 'Trinken';

  @override
  String get anWaterAvg => 'im Schnitt, ml';

  @override
  String anWaterGoal(String ml) {
    return 'Richtwert $ml ml';
  }

  @override
  String get anWeek => 'Woche';

  @override
  String get anWeightEmpty =>
      'Die Kurve entsteht ab dem zweiten Wiegen. Sag Nora dein Gewicht, sie trägt es selbst ein.';

  @override
  String get anYear => 'Jahr';

  @override
  String get assistantAddMemory => 'Zum Gedächtnis hinzufügen';

  @override
  String get assistantCollapse => 'Zuklappen';

  @override
  String get assistantExample => 'Zum Beispiel: ich esse keine Pilze';

  @override
  String get assistantForget => 'Vergessen';

  @override
  String assistantHint(String name) {
    return '$name führt das Tagebuch mit dir und merkt sich, was du ihr über dich erzählt hast.';
  }

  @override
  String get assistantMemory => 'Gedächtnis';

  @override
  String get assistantMemoryEmpty => 'Noch nichts gemerkt.';

  @override
  String get assistantMemoryEmptyHint =>
      'Das Gedächtnis entsteht aus Gesprächen, oder füg selbst etwas hinzu';

  @override
  String assistantPinned(int count, int pinned) {
    return '$count, $pinned angeheftet';
  }

  @override
  String get assistantTitle => 'Assistentin';

  @override
  String get assistantWhatToRemember => 'Was merken';

  @override
  String get authAgain => 'Passwort bestätigen';

  @override
  String get authAgainDiffers => 'Die Passwörter stimmen nicht überein';

  @override
  String get authAgainEmpty => 'Passwort wiederholen';

  @override
  String get authAgainHint => 'noch einmal';

  @override
  String authAgainIn(int sec) {
    return 'Erneut möglich in $sec s';
  }

  @override
  String get authCode => 'Code aus der E-Mail';

  @override
  String get authCodeAction => 'Bestätigen';

  @override
  String get authCodeBad => 'Der Code passt nicht oder ist abgelaufen';

  @override
  String authCodeHint(String mail) {
    return 'Wir haben einen Code an $mail geschickt. Gib die sechs Ziffern ein.';
  }

  @override
  String get authCodeShort => 'Der Code hat 6 Ziffern';

  @override
  String get authCodeTitle => 'E-Mail bestätigen';

  @override
  String get authForgotAction => 'Code senden';

  @override
  String get authForgotHint =>
      'Wir senden einen Code an deine E-Mail, dann wählst du ein neues Passwort.';

  @override
  String get authForgotLink => 'Vergessen?';

  @override
  String get authForgotTitle => 'Neues Passwort';

  @override
  String get authMail => 'E-Mail';

  @override
  String get authMailBad => 'Diese Adresse sieht falsch aus';

  @override
  String get authOr => 'oder';

  @override
  String get authPass => 'Passwort';

  @override
  String get authPassEmpty => 'Gib dein Passwort ein';

  @override
  String get authPassHint => '5 Buchstaben und ein Zeichen';

  @override
  String get authPassNew => 'Neues Passwort';

  @override
  String get authPassWeak =>
      'Schwaches Passwort: mindestens 5 Buchstaben und eine Ziffer oder ein Zeichen';

  @override
  String get authResetAction => 'Passwort speichern';

  @override
  String get authSendAgain => 'Erneut senden';

  @override
  String get authSignInAction => 'Anmelden';

  @override
  String get authSignInTitle => 'Anmelden';

  @override
  String get authSignUpAction => 'Konto erstellen';

  @override
  String get authSignUpLink => 'Registrieren';

  @override
  String get authSignUpTitle => 'Konto anlegen';

  @override
  String get barCamera => 'Kamera';

  @override
  String barGrams(int grams) {
    return '$grams g';
  }

  @override
  String get barHint => 'Schreib, wie du sprichst.';

  @override
  String get barHintBorscht => 'Linsensuppe 300 g zum Mittagessen';

  @override
  String get barHintDelete => 'Lösch den letzten Eintrag';

  @override
  String get barHintEggs => 'Zwei Eier und ein Toast';

  @override
  String get barHintMore =>
      '«zwei Eier und ein Toast», «300 Wasser getrunken», «40 Minuten gelaufen»: ich rechne es aus und lege es in die richtige Karte';

  @override
  String get barHintProtein => 'Wie viel Protein bleibt mir?';

  @override
  String get barHintRun => '40 Minuten gelaufen';

  @override
  String get barHintWater => '500 ml Wasser getrunken';

  @override
  String get barHintWeighed => 'Gewicht: 78,8';

  @override
  String get barHintYesterday => 'Was habe ich gestern gegessen?';

  @override
  String get barLogsInto => 'Eintrag in ';

  @override
  String get barMic => 'Mikrofon';

  @override
  String get barSend => 'Senden';

  @override
  String get camAgain => 'Noch einmal';

  @override
  String get camAllergen => 'Allergen!';

  @override
  String camAllergyContains(String list) {
    return 'Enthält dein Allergen: $list';
  }

  @override
  String camAllergyTraces(String list) {
    return 'Kann Spuren enthalten von: $list';
  }

  @override
  String get camAskNoraInstead => 'Kein Etikett, dann frag Nora';

  @override
  String get camBarcode => 'Barcode';

  @override
  String get camBusy => 'Die Kamera ging nicht auf. Meist hält sie gerade eine andere App.';

  @override
  String get camCouldNotRead => 'Ich konnte das Foto nicht lesen';

  @override
  String get camDish => 'Foto';

  @override
  String get camEstimate => ' kcal, geschätzt';

  @override
  String get camFlash => 'Blitz';

  @override
  String get camFromPack => 'Werte von der Verpackung. Das Eintragen kostet keine Tokens.';

  @override
  String get camGallery => 'Aus der Galerie';

  @override
  String get camGapNote =>
      'Diesen Wert kennt keine Datenbank. Fotografier das Etikett, dann trage ich ihn nach.';

  @override
  String get camHintBarcode => 'der Code im Rahmen';

  @override
  String get camHintDish => 'halte drauf: Teller oder Packung';

  @override
  String camIngredients(String text) {
    return 'Zutaten: $text';
  }

  @override
  String camIntoSlot(String slot) {
    return 'zu $slot';
  }

  @override
  String camKcalFor(int grams) {
    return ' kcal für $grams g';
  }

  @override
  String camKcalPer(int grams) {
    return ' kcal pro $grams g';
  }

  @override
  String get camLabelAim => 'halte auf die Nährwerttabelle';

  @override
  String get camLabelNoShot => 'Das Foto ist nichts geworden. Versuch das Etikett noch einmal.';

  @override
  String get camLabelReading => 'Übernehme die Werte von der Packung…';

  @override
  String camLogInto(String slotInto) {
    return 'Eintragen $slotInto';
  }

  @override
  String get camNoPermission =>
      'Keine Kameraberechtigung. Du kannst sie in den Einstellungen des Telefons geben.';

  @override
  String get camNoScanner => 'Dieses Telefon kann mit der Kamera keine Codes lesen.';

  @override
  String get camNoTokens => 'Keine Tokens mehr';

  @override
  String get camNotAProduct => 'Das ist kein Produktbarcode';

  @override
  String get camNotAProductNote =>
      'Gelesen wurde ein Link oder ein interner Code. Halt auf die Striche mit den Ziffern darunter.';

  @override
  String get camNotRead => 'Ich konnte es nicht erkennen';

  @override
  String get camOffline =>
      'Der Code wurde gelesen, aber es ist niemand da, den man fragen könnte. Versuch es wieder, wenn du online bist.';

  @override
  String get camOfflineShot => 'Keine Verbindung. Du kannst das Foto später an Nora schicken';

  @override
  String get camOfflineTitle => 'Kein Netz';

  @override
  String get camPer100 =>
      'Auf der Verpackung steht kein genaues Gewicht: die Werte gelten pro 100 g.';

  @override
  String camPortionPack(int g) {
    return 'Portion laut Verpackung: $g g. Die Werte gelten pro Portion.';
  }

  @override
  String get camReading => 'Lese…';

  @override
  String get camSendToNora => 'An Nora schicken';

  @override
  String get camServerDown =>
      'Das liegt nicht am Code und nicht an der Kamera. Versuch es in einer Minute.';

  @override
  String get camServerDownTitle => 'Unser Server hat nicht geantwortet';

  @override
  String get camShoot => 'Foto machen';

  @override
  String get camShootLabel => 'Etikett fotografieren';

  @override
  String get camShotFailed => 'Das Foto ist nichts geworden';

  @override
  String get camShotReady => 'Das Foto ist fertig';

  @override
  String get camShotReadyNote =>
      'Nora liest es und antwortet im Chat: sie nennt das Gericht, schätzt die Portion und zeigt, woher die Zahl kommt. Das kostet zwei Tokens.';

  @override
  String get camSignedOut =>
      'Die Sitzung gilt nicht mehr, deshalb erkennt uns die Datenbank nicht. Melde dich neu an, dann funktioniert der Scanner.';

  @override
  String get camSignedOutTitle => 'Bitte melde dich neu an';

  @override
  String get camSlow =>
      'Der Code wurde gelesen, die Datenbank hat zu lange gebraucht. Versuch es noch einmal.';

  @override
  String get camSlowTitle => 'Die Antwort kam nicht';

  @override
  String get camStillWorks => 'Fotos von Gerichten und die Galerie funktionieren wie immer.';

  @override
  String get camTitle => 'Scanner';

  @override
  String get camTookTooLong => 'Das Lesen hat zu lange gedauert. Versuch es noch einmal';

  @override
  String get camUnknownCode => 'Dieses Produkt steht in keiner Datenbank';

  @override
  String get camUnknownCodeNote =>
      'Weder in unserer noch in der offenen. Fotografier die Nährwerttabelle auf der Packung, dann übernehme ich die Werte von dort. Das ist kostenlos.';

  @override
  String get chatPro => 'Pro';

  @override
  String get deleteAskBody1 =>
      'Dieses Telefon wird sofort geleert: Tagebuch, Profil, das Gespräch mit Nora und die Anmeldung. Die App geht zurück zum ersten Bildschirm.';

  @override
  String get deleteAskBody2 =>
      'Auf dem Server kommt das Konto in die Warteschlange zur endgültigen Löschung, das dauert bis zu 30 Werktage. Bis wir sie bestätigen, holt eine Anmeldung mit demselben Konto alles zurück und storniert die Anfrage.';

  @override
  String get deleteAskCta => 'Ja, löschen';

  @override
  String get deleteAskTitle => 'Konto löschen?';

  @override
  String get deleteConfirm =>
      'Mir ist klar, dass die Daten für immer gelöscht werden und nicht zurückzuholen sind.';

  @override
  String get deleteDays => 'Tage mit Calvi';

  @override
  String get deleteEntries => 'Einträge im Tagebuch';

  @override
  String deleteFailed(String why) {
    return 'Löschen ging nicht: $why';
  }

  @override
  String get deleteForever => 'Für immer löschen';

  @override
  String get deleteNote =>
      'Es geht alles: Tagebuch, Gewicht, Maße, Allergien, Medikamente und der Gesprächsverlauf. Rückgängig geht das nicht.';

  @override
  String get deleteProManage => 'Abo verwalten';

  @override
  String deleteProNote(String store) {
    return 'Das Löschen des Kontos kündigt Calvi Pro nicht. $store bucht weiter ab, bis du das Abo selbst kündigst, kündige es also vor dem Löschen des Kontos.';
  }

  @override
  String get deleteProStoreAny => 'Der Store';

  @override
  String get deleteSubNote =>
      'Wenn es ums Abo geht: das kannst du separat im App Store oder bei Google Play kündigen, ohne das Konto zu löschen.';

  @override
  String get deleteTitle => 'Konto löschen';

  @override
  String get deleteWeighings => 'Gewichtsmessungen';

  @override
  String get dictationBusy => 'Das Mikrofon ist belegt. Versuch es noch einmal';

  @override
  String get dictationFailed => 'Diktieren hat nicht funktioniert';

  @override
  String get dictationNoMatch => 'Ich habe nichts Verständliches gehört';

  @override
  String get dictationNoNetwork => 'Die Erkennung braucht Netz';

  @override
  String get dictationNoPermission => 'Keine Mikrofonberechtigung';

  @override
  String get dictationSilence => 'Stille. Versuch es noch einmal, näher am Mikrofon';

  @override
  String get dictationUnavailable => 'Diktieren geht auf diesem Telefon nicht';

  @override
  String get doseCapFew => 'Kapseln';

  @override
  String get doseCapMany => 'Kapseln';

  @override
  String get doseCapOne => 'Kapsel';

  @override
  String get doseDropFew => 'Tropfen';

  @override
  String get doseDropMany => 'Tropfen';

  @override
  String get doseDropOne => 'Tropfen';

  @override
  String get doseMlFew => 'ml';

  @override
  String get doseMlMany => 'ml';

  @override
  String get doseMlOne => 'ml';

  @override
  String get doseShotFew => 'Spritzen';

  @override
  String get doseShotMany => 'Spritzen';

  @override
  String get doseShotOne => 'Spritze';

  @override
  String get doseTabFew => 'Tabletten';

  @override
  String get doseTabMany => 'Tabletten';

  @override
  String get doseTabOne => 'Tablette';

  @override
  String entries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge',
      one: '1 Eintrag',
      zero: '0 Einträge',
    );
    return '$_temp0';
  }

  @override
  String get eraseAskBody1 =>
      'Das ganze Tagebuch geht weg, für die gesamte Zeit: Mahlzeiten, Wasser, Gewicht, Maße, Training, Medikamente und das Gespräch mit Nora. Auf jedem Gerät, weil auch die Kopie auf dem Server gelöscht wird.';

  @override
  String get eraseAskBody2 =>
      'Was bleibt: das Konto, die Anmeldung, die Tokens mit ihrem Stand und die Profileinstellungen. Das ist kein Abmelden, sondern ein sauberer Start im selben Konto.';

  @override
  String get eraseAskCta => 'Alles löschen';

  @override
  String get eraseAskTitle => 'Alle Einträge löschen?';

  @override
  String get eraseDataTitle => 'Daten löschen';

  @override
  String get eraseDone => 'Das Tagebuch ist gelöscht. Sauberer Start.';

  @override
  String eraseFailed(String why) {
    return 'Löschen ging nicht: $why';
  }

  @override
  String get eraseNoNet => 'kein Netz. Schalte das Internet ein und versuch es noch einmal';

  @override
  String get eraseSlow => 'der Server braucht zu lange. Versuch es in einer Minute';

  @override
  String get eraseSureBody =>
      'Das lässt sich nicht rückgängig machen. Das Tagebuch verschwindet für immer, und weder du noch wir holen es zurück.';

  @override
  String get eraseSureCta => 'Ja, für immer löschen';

  @override
  String get eraseSureTitle => 'Wirklich löschen?';

  @override
  String get eveningAnd => ' und ';

  @override
  String get eveningBreakfastAcc => 'das Frühstück';

  @override
  String get eveningDinnerAcc => 'das Abendessen';

  @override
  String get eveningEmptyDay => 'Der Tag ist leer. Was hast du heute gegessen?';

  @override
  String eveningLogged(String slot) {
    return 'Hast du $slot eingetragen?';
  }

  @override
  String get eveningLunchAcc => 'das Mittagessen';

  @override
  String eveningMissing(String list) {
    return '$list fehlen noch. Was davon gab es?';
  }

  @override
  String get eveningWater => 'Auf wie viel Wasser kam der Tag?';

  @override
  String get fieldBiceps => 'Bizeps';

  @override
  String get fieldChest => 'Brust';

  @override
  String get fieldHips => 'Hüfte';

  @override
  String get fieldNeck => 'Hals';

  @override
  String get fieldThigh => 'Oberschenkel';

  @override
  String get fieldWaist => 'Taille';

  @override
  String get fieldWeight => 'Gewicht';

  @override
  String get fieldWrist => 'Handgelenk';

  @override
  String get goalBecomes => 'Wird';

  @override
  String get goalCurrent => 'Aktuelles Ziel ';

  @override
  String get goalDailyNorm => 'Tagesrichtwert';

  @override
  String goalDiff(String kg) {
    return '$kg kg Unterschied';
  }

  @override
  String get goalDirection => 'Richtung';

  @override
  String get goalEta => 'Ziel um den';

  @override
  String goalFromStart(String kg) {
    return ' von $kg kg zu Beginn. ';
  }

  @override
  String get goalFromToday => 'Das neue Ziel startet beim heutigen Gewicht.';

  @override
  String get goalKeepNote =>
      'Der Richtwert hält dein jetziges Gewicht: du holst genau das zurück, was du verbrauchst.';

  @override
  String get goalKeepShort => 'Halten';

  @override
  String get goalNew => 'Neues Ziel setzen';

  @override
  String get goalNewTitle => 'Neues Ziel';

  @override
  String get goalPace => 'Tempo';

  @override
  String get goalPaceFast => 'Schnell';

  @override
  String get goalPaceOk => 'Das ist das Tempo, das die meisten durchhalten, ohne dass es abreißt.';

  @override
  String get goalPaceSlow => 'Langsam';

  @override
  String get goalPaceUnit => 'kg pro Woche';

  @override
  String get goalPaceUsual => 'Empfohlen';

  @override
  String goalRange(String from, String to) {
    return '$from → $to kg';
  }

  @override
  String get goalReplaceNote =>
      'Ein Ziel wird nicht bearbeitet, sondern ersetzt. Der Fortschritt zählt ab dem heutigen Gewicht, das alte Ziel bleibt im Verlauf. Ersetzen bestätigen?';

  @override
  String get goalSet => 'Setzen';

  @override
  String get goalTarget => 'Zielgewicht';

  @override
  String get goalWas => 'War';

  @override
  String gramsUnit(int grams) {
    return '$grams g';
  }

  @override
  String get helloDishBread => 'Roggenbrot';

  @override
  String get helloDishEggs => 'Rührei';

  @override
  String get helloSaid => 'zwei Eier und ein Toast';

  @override
  String get helloSlotSub => 'zwei Einträge';

  @override
  String get helloStepCount => 'Ich zähle die Kalorien';

  @override
  String get helloStepLog => 'Ich trage es in deinen Tag ein';

  @override
  String get helloStepSay => 'Sag, was du gegessen hast';

  @override
  String heroBurned(int kcal) {
    return '-$kcal kcal vom Training';
  }

  @override
  String get heroDays => 'Tage';

  @override
  String heroFrom(String kcal) {
    return ' von $kcal';
  }

  @override
  String get heroGoalKg => 'Ziel, kg';

  @override
  String get heroKcal => ' kcal';

  @override
  String get heroKg => ' kg';

  @override
  String get heroLeft => 'übrig ';

  @override
  String heroOf(String kcal) {
    return ' von $kcal';
  }

  @override
  String get heroOver => 'drüber um ';

  @override
  String get heroWeekOpen => 'Die ganze Woche';

  @override
  String heroWeightFrom(String kg) {
    return 'jetzt, von $kg kg zu Beginn des Ziels';
  }

  @override
  String kcalUnit(int kcal) {
    return '$kcal kcal';
  }

  @override
  String get langSection => 'Sprache der Oberfläche';

  @override
  String get langSystem => 'Sprache des Geräts';

  @override
  String legalUpdated(String date) {
    return 'Updated $date';
  }

  @override
  String get loginNoToken => 'Google hat kein Token zurückgegeben';

  @override
  String get loginNotConfigured => 'die Anmeldung ist in diesem Build nicht eingerichtet';

  @override
  String get loginNotSynced =>
      'Noch nicht alle Einträge sind am Server angekommen. Versuch es in einer Minute: das Anmelden löscht nichts, solange nicht alles gespeichert ist';

  @override
  String loginServer(String why) {
    return 'Server: $why';
  }

  @override
  String get loginSlow => 'Google hat in einer Minute nicht geantwortet. Versuch es noch einmal';

  @override
  String get macroCNone => 'K ?';

  @override
  String macroCShort(int value) {
    return 'K $value';
  }

  @override
  String get macroCarbs => 'Kohlenhydrate';

  @override
  String get macroCarbsCaps => 'KH';

  @override
  String get macroCarbsLetter => 'K';

  @override
  String get macroFNone => 'F ?';

  @override
  String macroFShort(int value) {
    return 'F $value';
  }

  @override
  String get macroFat => 'Fett';

  @override
  String get macroFatCaps => 'FETT';

  @override
  String get macroFatLetter => 'F';

  @override
  String get macroMedsCaps => 'MEDIKAMENTE';

  @override
  String macroOfGrams(int goal) {
    return ' / ${goal}g';
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
  String get mealEditDelete => 'Eintrag löschen';

  @override
  String get mealEditKcal => 'kcal';

  @override
  String get mealEditSave => 'Speichern';

  @override
  String get mealEmpty => 'Hier ist noch nichts. Schreib, was es war, und ich trage es ein.';

  @override
  String mealGrams(int grams) {
    return '$grams g';
  }

  @override
  String get mealThinking => 'Nora rechnet…';

  @override
  String get measureAdd => 'Maß hinzufügen';

  @override
  String get measureCollapse => 'Zuklappen';

  @override
  String measureCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Messungen',
      one: '1 Messung',
    );
    return '$_temp0';
  }

  @override
  String measureLast(String ago) {
    return 'zuletzt $ago';
  }

  @override
  String get measureNever => 'noch nicht gemessen';

  @override
  String get measureNothing => 'noch nichts';

  @override
  String get measurePick =>
      'Wähl, was du messen willst. Eines reicht, wenn dich der Rest nicht interessiert.';

  @override
  String get measureSave => 'Messungen speichern';

  @override
  String get measureStats => 'Statistik der Maße';

  @override
  String get measureTitle => 'Maße';

  @override
  String get medsAdd => 'Medikament hinzufügen';

  @override
  String get medsAllTaken => 'Für heute ist alles genommen';

  @override
  String get medsAt => 'Um';

  @override
  String get medsCourse => 'Kur';

  @override
  String get medsDose => 'Dosis';

  @override
  String get medsEmpty =>
      'Hier ist noch nichts. Füg ein Medikament hinzu, und ich erinnere dich zur richtigen Zeit.';

  @override
  String get medsEmptyHint => 'Ich führe das Einnahmeprotokoll, die Dosis rechne ich nicht aus';

  @override
  String get medsFinish => 'Kur beenden';

  @override
  String medsFirstDose(String name, String day, String at) {
    return '$name, erste Einnahme $day um $at';
  }

  @override
  String get medsHours => 'Uhrzeiten';

  @override
  String get medsHowOften => 'Wie oft';

  @override
  String get medsMine => 'Meine Medikamente';

  @override
  String get medsName => 'Name';

  @override
  String get medsNameExample => 'Zum Beispiel Magnesium B6';

  @override
  String get medsNew => 'Neues Medikament';

  @override
  String get medsNextAt => 'Als Nächstes um ';

  @override
  String get medsNoneToday => 'Heute steht nichts an';

  @override
  String get medsNote => 'Notiz';

  @override
  String get medsNow => 'JETZT';

  @override
  String get medsOne => 'Medikament';

  @override
  String get medsPast => 'Beendet';

  @override
  String get medsPastEmpty =>
      'Hier stehen Kuren, die du nicht mehr nimmst. Ein Medikament, das du aus der Liste nimmst, bleibt an den Tagen, an denen du es genommen hast.';

  @override
  String get medsPerTake => 'Wie viel pro Einnahme';

  @override
  String get medsRemind => 'Erinnern';

  @override
  String get medsRemindHint => 'zu den gewählten Uhrzeiten';

  @override
  String get medsResume => 'Kur fortsetzen';

  @override
  String get medsSchedule => 'Zeitplan';

  @override
  String medsSince(String date) {
    return 'seit $date';
  }

  @override
  String get medsTime => 'Uhrzeit';

  @override
  String get medsTitle => 'Medikamente';

  @override
  String get medsTomorrow => 'morgen';

  @override
  String get medsUnmarked => 'Noch nicht abgehakt: ';

  @override
  String medsUntil(String date) {
    return 'bis $date';
  }

  @override
  String get menuAbout => 'Über die App';

  @override
  String get menuAllergy => 'Allergien';

  @override
  String get menuAnalytics => 'Statistik';

  @override
  String get menuDiary => 'Tagebuch';

  @override
  String get menuHintFree => 'kostenlos';

  @override
  String menuHintKcal(int n) {
    return 'heute $n kcal';
  }

  @override
  String menuHintMore(int n) {
    return '+$n';
  }

  @override
  String get menuHintNoAllergy => 'keine';

  @override
  String get menuHintNoMeds => 'keine Kuren';

  @override
  String get menuHintNothing => 'noch nichts eingetragen';

  @override
  String menuHintOnGoal(int ok, int total) {
    return '$ok von $total im Ziel';
  }

  @override
  String get menuHintRecipes => 'von Nora, passend zu deiner Norm';

  @override
  String get menuHintWeekFriday => 'ab Freitag, 18:00';

  @override
  String get menuHintWeekOpen => 'offen bis Sonntag';

  @override
  String get menuHintWeekYoung => 'die Woche hat gerade begonnen';

  @override
  String get menuMeds => 'Medikamente';

  @override
  String get menuPlan => 'Abo';

  @override
  String get menuRecipes => 'Rezepte';

  @override
  String get menuSettings => 'Einstellungen';

  @override
  String get menuTitle => 'Menü';

  @override
  String get menuWeek => 'Wochenrückblick';

  @override
  String get noraName => 'Nora';

  @override
  String get normAuto => 'Automatisch rechnen';

  @override
  String get normAutoFrom =>
      'Aus dem Gewicht zu Zielbeginn, der Größe, dem Alter, der Aktivität und dem Tempo: ';

  @override
  String normAutoHint(String kcal) {
    return 'aus Gewicht, Größe, Alter, Aktivität und Ziel: $kcal kcal';
  }

  @override
  String get normAutoShort => 'Automatisch';

  @override
  String get normByHand => 'Von Hand setzen';

  @override
  String get normByHandHint => 'die Statistik rechnet gegen diese Zahl';

  @override
  String get normByHandShort => 'Von Hand';

  @override
  String get normCalculatedHead => 'Der berechnete Wert ist ';

  @override
  String get normCalculatedTail => '. Mit «Automatisch» kommst du dorthin zurück.';

  @override
  String get normFitCarbs => 'Kohlenhydrate an den Richtwert anpassen';

  @override
  String get normFits => 'Die Aufteilung passt zum Richtwert';

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
  String get normMacros => 'Makros';

  @override
  String get normManual => 'von Hand gesetzt';

  @override
  String normOf(String kcal) {
    return 'von $kcal kcal';
  }

  @override
  String normOffOver(String sum, int off) {
    return 'Die Aufteilung ergibt $sum kcal, $off über dem Richtwert';
  }

  @override
  String normOffUnder(String sum, int off) {
    return 'Die Aufteilung ergibt $sum kcal, $off unter dem Richtwert';
  }

  @override
  String get normPerDay => 'kcal am Tag';

  @override
  String get normTitle => 'Richtwert';

  @override
  String get normWater => 'Wasser';

  @override
  String get normWaterHead => 'Das sind ';

  @override
  String normWaterPerKg(int ml) {
    return '$ml ml';
  }

  @override
  String get normWaterTail =>
      ' pro Kilo Gewicht. Der übliche grobe Bereich liegt bei 30 bis 40 ml, hängt aber von Hitze und Training ab, deshalb ist die Zahl hier nicht starr.';

  @override
  String get normWhere => 'Woher diese Zahl kommt';

  @override
  String get notifyChannel => 'Erinnerungen';

  @override
  String get notifyChannelHint => 'Erinnerungen an Essen, Wasser, Medikamente und Wiegen';

  @override
  String get notifyDenied =>
      'Das Telefon hat Mitteilungen abgelehnt. Schalte sie in den Systemeinstellungen ein, dann funktionieren die Erinnerungen.';

  @override
  String get photoDish => 'Gericht';

  @override
  String get photoNotRecognized => 'Ich konnte das Gericht auf diesem Foto nicht erkennen';

  @override
  String get planBuy => 'Abonnieren';

  @override
  String get planClose => 'Schließen';

  @override
  String get planCurrent => 'aktuell';

  @override
  String get planFailed => 'Der Kauf ist nicht durchgegangen';

  @override
  String get planFree => 'Kostenlos';

  @override
  String planFrom(String plan, String date) {
    return '$plan ab $date';
  }

  @override
  String planFromShort(String date) {
    return 'ab $date';
  }

  @override
  String get planLater => 'Jetzt nicht';

  @override
  String get planManage => 'Im Store verwalten';

  @override
  String get planMonth => 'Monat';

  @override
  String get planMonthBilled => 'monatliche Abrechnung';

  @override
  String get planMonthly => 'Pro monatlich';

  @override
  String get planNext => 'Danach';

  @override
  String get planNothingToRestore => 'Keine Käufe auf diesem Konto';

  @override
  String get planNow => 'Jetzt';

  @override
  String get planOn => 'Pro';

  @override
  String get planPerMonth => '/Mon.';

  @override
  String get planPerkChat => 'Gespräche mit Nora ohne Limit';

  @override
  String get planPerkChatSub => 'heute kostet eine Nachricht einen Token';

  @override
  String get planPerkMemory => 'Nora merkt sich dich';

  @override
  String get planPerkMemorySub => 'sie lernt Neues im Gespräch, und das kostet einen Token';

  @override
  String get planPerkPhoto => 'Fotos vom Essen ohne Limit';

  @override
  String get planPerkPhotoSub => 'heute kostet ein Foto zwei Tokens';

  @override
  String get planPerkRecipes => 'Rezepte von Nora ohne Limit';

  @override
  String get planPerkRecipesSub => 'heute kostet ein Vorschlag einen Token';

  @override
  String get planPerkWeek => 'Wochenrückblick, wann du willst';

  @override
  String get planPerkWeekSub => 'heute kostet ein Rückblick zwei Tokens';

  @override
  String get planPerks => 'Was das Abo bringt';

  @override
  String get planPlan => 'Tarif';

  @override
  String get planPrivacy => 'Datenschutzerklärung';

  @override
  String get planRenewal =>
      'Das Abo verlängert sich automatisch, bis du es kündigst. Kündigen kannst du jederzeit in den Einstellungen des Stores, in dem du es gekauft hast.';

  @override
  String get planRenews => 'Verlängert sich';

  @override
  String get planRestore => 'Käufe wiederherstellen';

  @override
  String get planSignInGo => 'Anmelden';

  @override
  String get planSignInNote =>
      'Das Abo hängt an einem Konto mit E-Mail. So übersteht es ein neues Telefon und gilt auf allen deinen Geräten.';

  @override
  String get planSignInTitle => 'Melde dich zuerst an';

  @override
  String get planStoreAsking => 'Frage die Preise beim Store ab…';

  @override
  String get planStoreOffline => 'Der Store antwortet nicht. Prüf deine Internetverbindung';

  @override
  String get planStoreQuiet => 'Der Store antwortet nicht. Versuch es später';

  @override
  String get planSwitchMonth => 'Auf monatlich wechseln';

  @override
  String get planSwitchYear => 'Auf jährlich wechseln';

  @override
  String get planTariffs => 'Tarife';

  @override
  String get planTerms => 'Nutzungsbedingungen';

  @override
  String get planTitle => 'Abo';

  @override
  String get planTokens => 'Tokens';

  @override
  String get planTokensFree => '40 im Monat';

  @override
  String get planTokensPro => 'Ohne Limit';

  @override
  String get planUntil => 'Aktiv bis';

  @override
  String get planYear => 'Jahr';

  @override
  String planYearBilled(String price) {
    return '$price einmal im Jahr';
  }

  @override
  String get planYearly => 'Pro jährlich';

  @override
  String plateFor(int grams) {
    return 'für $grams g';
  }

  @override
  String get plateGrams => ' g';

  @override
  String get plateKcal => 'kcal';

  @override
  String get plateThinking => 'denke';

  @override
  String get plateTotal => 'gesamt';

  @override
  String get privacyCrash => 'Absturzberichte';

  @override
  String get privacyCrashHint => 'der Fehler-Stack, ohne Daten aus dem Tagebuch';

  @override
  String get privacyDiaryHead => 'Dein Tagebuch bleibt deins';

  @override
  String get privacyDiarySub => 'weder Mahlzeiten noch Gewicht gehen in die Statistik';

  @override
  String get privacyHealthHead => 'Gesundheitsdaten gehen an niemanden';

  @override
  String get privacyHealthSub => 'Allergien und Medikamente verlassen die App nicht';

  @override
  String get privacyNoPhotosHead => 'Fotos vom Essen werden nicht gespeichert';

  @override
  String get privacyNoPhotosSub => 'das Foto wird gelesen und ist weg';

  @override
  String get privacyNotCollected => 'Was wir nicht sammeln';

  @override
  String get privacyOptional => 'Was du ausschalten kannst';

  @override
  String get privacyPhotosBold => 'werden nicht gespeichert';

  @override
  String get privacyPhotosHead => 'Fotos vom Essen ';

  @override
  String get privacyPhotosTail =>
      ': das Foto geht in die Verarbeitung und ist weg. Die Statistik sieht nie Gerichte, Gewicht, Allergien oder Medikamente. Das ist eine besondere Kategorie personenbezogener Daten, und sie an Dritte zu geben kommt nicht infrage, so bequem es auch wäre.';

  @override
  String get privacyStats => 'Anonyme Statistik';

  @override
  String get privacyStatsHint => 'welche Bildschirme geöffnet werden, ohne den Inhalt der Einträge';

  @override
  String get privacyTitle => 'Datenschutz';

  @override
  String get profileActivity => 'Aktivität';

  @override
  String get profileAge => 'Alter';

  @override
  String get profileHeight => 'Größe';

  @override
  String get profileSex => 'Geschlecht';

  @override
  String rcAllergyWarn(String names) {
    return 'Enthält $names, das steht auf deiner Allergieliste. Sei damit vorsichtig.';
  }

  @override
  String get rcAsk => 'Nora nach einem Rezept fragen';

  @override
  String get rcAskAbout => 'Nora zu diesem Rezept fragen';

  @override
  String get rcAskCancel => 'Abbrechen';

  @override
  String get rcAskGo => 'Fragen';

  @override
  String get rcAskPlaceholder => 'Hähnchen, Brokkoli, Reis';

  @override
  String get rcAskTitle => 'Was ist in der Küche?';

  @override
  String get rcAsking => 'Denke nach…';

  @override
  String rcChatGreet(String name) {
    return 'Frag zu «$name»: was man tauschen kann, wie man es nicht ruiniert, was man vorbereiten kann.';
  }

  @override
  String get rcChatPlaceholder => 'Frag zu diesem Rezept';

  @override
  String rcCount(int n) {
    return '$n Rezepte';
  }

  @override
  String rcCountFew(int n) {
    return '$n Rezepte';
  }

  @override
  String get rcCountOne => '1 Rezept';

  @override
  String rcDeleteBody(String name) {
    return '«$name» verlässt das Buch. Einträge im Tagebuch, die daraus entstanden sind, bleiben.';
  }

  @override
  String get rcDeleteCta => 'Löschen';

  @override
  String get rcDeleteFailed => 'Löschen ging nicht. Versuch es noch einmal.';

  @override
  String get rcDeleteTitle => 'Dieses Rezept löschen?';

  @override
  String get rcEmpty =>
      'Hier ist noch nichts. Sag Nora, was in der Küche ist, dann erscheint das erste Rezept.';

  @override
  String get rcEmptyMine =>
      'Noch keine eigenen Rezepte. Diktier Nora irgendeins, dann landet es hier.';

  @override
  String get rcEyebrow => 'Die Küche';

  @override
  String get rcFromMine => 'Meins';

  @override
  String get rcFromNora => 'Von Nora';

  @override
  String get rcHeroA => 'Was kochen wir';

  @override
  String get rcHeroB => 'heute';

  @override
  String get rcHeroLede =>
      'Sag, was du zu Hause hast. Nora schlägt vor und rechnet die Portion; dein eigenes Rezept geht auch.';

  @override
  String get rcItemsHead => 'Zutaten';

  @override
  String rcItemsTotal(int g) {
    return 'insgesamt $g g';
  }

  @override
  String get rcJustNow => 'gerade eben';

  @override
  String get rcLoadFailed =>
      'Das Rezeptbuch wurde nicht geladen. Zieh nach unten für einen neuen Versuch.';

  @override
  String rcMinutes(int n) {
    return '$n Min';
  }

  @override
  String get rcNoTools => 'Nichts außer Messer und Schüssel';

  @override
  String rcOfDay(int p) {
    return 'das sind $p% des Tagesrichtwerts';
  }

  @override
  String get rcPerServing => 'pro Portion';

  @override
  String get rcPerServingHead => 'Pro Portion';

  @override
  String get rcPickTitle => 'Wähl ein Gericht';

  @override
  String rcPortion(int g) {
    return 'Portion $g g';
  }

  @override
  String rcServingsFew(int n) {
    return '$n Portionen';
  }

  @override
  String rcServingsMany(int n) {
    return '$n Portionen';
  }

  @override
  String get rcServingsOne => '1 Portion';

  @override
  String get rcStepsHead => 'So wird es gekocht';

  @override
  String get rcSuggestFailed =>
      'Nora konnte keine Rezepte zusammenstellen. Versuch es noch einmal.';

  @override
  String get rcTabAll => 'Alle';

  @override
  String get rcTabMine => 'Meine';

  @override
  String get rcTabNora => 'Von Nora';

  @override
  String get rcTitle => 'Rezepte';

  @override
  String get rcToolBlender => 'Mixer';

  @override
  String get rcToolGrill => 'Grill';

  @override
  String get rcToolMixer => 'Handrührer';

  @override
  String get rcToolOven => 'Backofen';

  @override
  String get rcToolPan => 'Pfanne';

  @override
  String get rcToolPot => 'Topf';

  @override
  String get rcToolsHead => 'Was die Küche braucht';

  @override
  String rcWhole(int kcal, int g) {
    return 'Ganzes Gericht: $kcal kcal, $g g';
  }

  @override
  String get remAbout => 'Worum es geht';

  @override
  String get remAdd => 'Erinnerung hinzufügen';

  @override
  String get remAt => 'Um';

  @override
  String get remDelete => 'Erinnerung löschen';

  @override
  String get remEdit => 'Erinnerung';

  @override
  String get remEmpty => 'Noch keine Erinnerungen.';

  @override
  String get remEmptyHint => 'Füg das eine hinzu, das du wirklich vergisst, nicht alles auf einmal';

  @override
  String get remHowOften => 'Wie oft';

  @override
  String get remName => 'Name';

  @override
  String get remNew => 'Neue Erinnerung';

  @override
  String get remOpenMeds => 'Medikamente öffnen';

  @override
  String get remTime => 'Uhrzeit';

  @override
  String get remTitle => 'Erinnerungen';

  @override
  String get reminderBodyMeal => 'Trag ein, was es war';

  @override
  String get reminderBodyMeds => 'Laut Zeitplan';

  @override
  String get reminderBodySummary => 'Was hast du heute nicht eingetragen?';

  @override
  String get reminderBodyWater => 'Zeit zu trinken';

  @override
  String get reminderBodyWeigh => 'Morgens, vor dem Essen';

  @override
  String get reminderBodyWorkout => 'Trag es ein, falls es stattfand';

  @override
  String get reminderMeal => 'Essen';

  @override
  String get reminderMealHint => 'ich erinnere dich, die Mahlzeit einzutragen';

  @override
  String get reminderMeds => 'Medikamente';

  @override
  String get reminderMedsHint => 'nach dem Zeitplan aus dem Protokoll';

  @override
  String get reminderSummary => 'Tagesrückblick';

  @override
  String get reminderSummaryHint => 'kurz zum Tag vor dem Schlafen';

  @override
  String get reminderWater => 'Wasser';

  @override
  String get reminderWaterHint => 'ich erinnere dich ans Trinken';

  @override
  String get reminderWeigh => 'Wiegen';

  @override
  String get reminderWeighHint => 'damit die Gewichtskurve nicht abreißt';

  @override
  String get reminderWorkout => 'Training';

  @override
  String get reminderWorkoutHint => 'ich erinnere dich an das geplante';

  @override
  String get repDaily => 'jeden Tag';

  @override
  String repEveryN(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'alle $count Tage');
    return '$_temp0';
  }

  @override
  String get repEveryOther => 'jeden zweiten Tag';

  @override
  String get repPickDaily => 'Jeden Tag';

  @override
  String get repPickFromToday => 'Gezählt ab heute.';

  @override
  String get repPickInterval => 'Jeden zweiten Tag';

  @override
  String get repPickNoDays => 'Es ist kein Tag gewählt, die Erinnerung kommt also nie.';

  @override
  String get repPickWeekdays => 'Wochentage';

  @override
  String get repWeekdays => 'werktags';

  @override
  String get repWeekends => 'am Wochenende';

  @override
  String get repWeekly => 'einmal pro Woche';

  @override
  String get restoredBody1 =>
      'Dieses Konto wartete auf die Löschung. Die Anmeldung hat das storniert: Tagebuch, Profil und Einstellungen sind wieder auf diesem Telefon.';

  @override
  String get restoredBody2 =>
      'Wenn das Konto trotzdem weg soll, bitte in den Einstellungen erneut um die Löschung. Jede Anmeldung vor unserer Bestätigung storniert die Anfrage genauso.';

  @override
  String get restoredOk => 'Verstanden';

  @override
  String get restoredTitle => 'Deine Daten sind zurück';

  @override
  String get setAbout => 'Über die App';

  @override
  String get setAllergies => 'Allergien';

  @override
  String setAssistantLine(String name, int count) {
    return '$name, $count im Gedächtnis';
  }

  @override
  String get setDeleteAccount => 'Konto und Daten löschen';

  @override
  String get setFreeTierHead =>
      'Für die Verteidiger der Ukraine und für alle, die bei den Streitkräften, beim staatlichen Rettungsdienst, bei DTEK, als medizinisches Personal, als Freiwillige oder als Lehrkräfte in frontnahen Gebieten arbeiten, ist der Bezahltarif ';

  @override
  String get setFreeTierHow => ' So bekommst du ihn';

  @override
  String get setFreeTierShort =>
      'Für die Verteidiger der Ukraine und für alle, die bei den Streitkräften, beim staatlichen Rettungsdienst, bei DTEK, als medizinisches Personal, als Freiwillige oder als Lehrkräfte in frontnahen Gebieten arbeiten, ist der Bezahltarif KOSTENLOS';

  @override
  String get setFreeTierTelegram => 'Auf Telegram schreiben';

  @override
  String get setFreeTierTitle => 'Kostenloser Tarif';

  @override
  String get setFreeTierWord => 'KOSTENLOS';

  @override
  String get setFreeTierWrite =>
      'Schreib dem Entwickler, dann wird der Bezahltarif noch am selben Tag freigeschaltet.';

  @override
  String get setGoal => 'Ziel';

  @override
  String get setGoalKeep => 'Gewicht halten';

  @override
  String setGoalLine(String kg, String pace) {
    return '$kg kg, $pace/Woche';
  }

  @override
  String get setGroupAbout => 'Über dich';

  @override
  String get setGroupAccount => 'Konto';

  @override
  String get setGroupAssistant => 'Assistentin';

  @override
  String get setGroupDocs => 'Dokumente';

  @override
  String get setGroupHealth => 'Gesundheit';

  @override
  String get setLang => 'Sprache';

  @override
  String get setMeds => 'Medikamente';

  @override
  String get setNorm => 'Richtwert';

  @override
  String setNormLine(String kcal) {
    return '$kcal kcal';
  }

  @override
  String get setPlan => 'Abo';

  @override
  String get setPlanFree => 'Kostenlos';

  @override
  String get setPolicy => 'Datenschutzerklärung';

  @override
  String get setPrivacy => 'Daten und Statistik';

  @override
  String get setProfile => 'Profil';

  @override
  String setProfileLine(String sex, int age, int height) {
    return '$sex, $age, $height cm';
  }

  @override
  String get setReminders => 'Erinnerungen';

  @override
  String get setRemindersOff => 'aus';

  @override
  String get setTerms => 'Nutzungsbedingungen';

  @override
  String get setTheme => 'Design';

  @override
  String get setTitle => 'Einstellungen';

  @override
  String get setUnset => 'nicht gesetzt';

  @override
  String get sexOther => 'Divers';

  @override
  String get sexShortFemale => 'W';

  @override
  String get sexShortMale => 'M';

  @override
  String get slotBreakfast => 'Frühstück';

  @override
  String get slotByHand => 'Zahlen selbst eintragen';

  @override
  String get slotCancel => 'Abbrechen';

  @override
  String get slotDinner => 'Abendessen';

  @override
  String slotEraseBody(String name) {
    return '«$name» hat noch keine Zahlen. Die Zeile verlässt den Tag.';
  }

  @override
  String get slotEraseDo => 'Entfernen';

  @override
  String get slotEraseTitle => 'Entwurf entfernen?';

  @override
  String get slotGrams => 'GEWICHT, G';

  @override
  String get slotIntoBreakfast => 'zum Frühstück';

  @override
  String get slotIntoDinner => 'zum Abendessen';

  @override
  String get slotIntoLunch => 'zum Mittagessen';

  @override
  String slotIntoOther(String name) {
    return 'zu «$name»';
  }

  @override
  String get slotIntoSnack => 'zum Snack';

  @override
  String get slotKcal => 'KCAL';

  @override
  String get slotLog => 'Eintragen';

  @override
  String get slotLunch => 'Mittagessen';

  @override
  String get slotSnack => 'Snack';

  @override
  String get slotWriteWhat => 'Schreib, was es war';

  @override
  String get startAbout => 'Über dich';

  @override
  String get startAge => 'Alter';

  @override
  String startAgeYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Jahre',
      one: '1 Jahr',
    );
    return '$_temp0';
  }

  @override
  String get startAgreeAnd => ' und der ';

  @override
  String get startAgreeHead => 'Ich stimme den ';

  @override
  String get startAgreePrivacy => 'Datenschutzerklärung zu';

  @override
  String get startAgreeTerms => 'Nutzungsbedingungen';

  @override
  String get startAllergies => 'Allergien';

  @override
  String get startDeviceFirstRun => 'erster Start';

  @override
  String get startGoal => 'Wohin geht es';

  @override
  String get startGoalGain => 'Zunehmen';

  @override
  String get startGoalGainHint => 'ein Überschuss im Tempo deiner Wahl';

  @override
  String get startGoalKeep => 'Gewicht halten';

  @override
  String get startGoalKeepHint => 'du holst genau das zurück, was du verbrauchst';

  @override
  String get startGoalLose => 'Abnehmen';

  @override
  String get startGoalLoseHint => 'ein Defizit im Tempo deiner Wahl';

  @override
  String get startHeight => 'Größe';

  @override
  String get startLife => 'Lebensweise';

  @override
  String get startNorm => 'Dein Richtwert';

  @override
  String get startNormHold => 'halten';

  @override
  String get startNormNora => 'Gerechnet. Ab hier wird es leichter.';

  @override
  String get startNormNoraHint =>
      'Schreib oder sag es, wie es dir passt: «zwei Eier und ein Toast», «300 Wasser getrunken». Was mir fehlt, frage ich im Gespräch.';

  @override
  String get startNormNote =>
      'Das ist die Mifflin-St-Jeor-Formel, kein medizinischer Rat. Wenn du eine Erkrankung hast, schwanger bist oder eine verordnete Diät hältst, sprich mit deiner Ärztin oder deinem Arzt.';

  @override
  String get startNormPerDay => 'kcal am Tag';

  @override
  String get startNormWeeks => 'Wochen';

  @override
  String get startPace => 'Wie schnell';

  @override
  String get startPaceEtaHead => 'Ziel um den ';

  @override
  String get startPaceEtaTail => ', also ';

  @override
  String get startPaceFast => 'schnell';

  @override
  String get startPaceSlow => 'langsam';

  @override
  String get startPaceUnit => 'kg pro Woche';

  @override
  String get startPaceUsual => 'gleichmäßig';

  @override
  String get startPaceWarning =>
      'So ein Tempo hält man schwer durch, meistens reißt es ab. Unter 0,8 kg pro Woche kommt das Ergebnis langsamer, bleibt aber.';

  @override
  String startPaceWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wochen',
      one: '1 Woche',
    );
    return '$_temp0';
  }

  @override
  String get startSex => 'Geschlecht';

  @override
  String get startSexFemale => 'Frau';

  @override
  String get startSexMale => 'Mann';

  @override
  String get startSexOther => 'Divers';

  @override
  String get startSignInApple => 'Weiter mit Apple';

  @override
  String get startSignInBackText =>
      'Melde dich mit demselben Konto an, dann ist alles wieder da: Tagebuch, Ziel, Richtwert und Maße. Du musst nichts noch einmal ausfüllen.';

  @override
  String get startSignInBackTitle => 'Willkommen zurück';

  @override
  String get startSignInBusy => 'Melde an…';

  @override
  String get startSignInFailed =>
      'Anmelden hat nicht geklappt. Versuch es noch einmal oder mach ohne Konto weiter.';

  @override
  String startSignInFailedWhy(String why) {
    return 'Anmelden hat nicht geklappt. $why';
  }

  @override
  String get startSignInGoogle => 'Weiter mit Google';

  @override
  String get startSignInSkip => 'Ohne Konto weiter';

  @override
  String get startSignInText =>
      'Der Richtwert steht. Melde dich an, damit er bleibt: Verlauf, Maße und Einträge sind dann auf jedem Gerät, nicht nur hier.';

  @override
  String get startSignInTitle => 'Lass uns das behalten';

  @override
  String get startTargetWeight => 'Zielgewicht';

  @override
  String get startWeightNow => 'Gewicht jetzt';

  @override
  String get startYearsShort => 'Jahre';

  @override
  String get storageBroken =>
      'Der Speicher ließ sich nicht öffnen. Deine Einträge sind sicher, aber gerade gibt es nichts, womit man sie zeigen könnte.';

  @override
  String get themeAquarelle => 'Aquarell';

  @override
  String get themeAquarelleHint => 'hell, mit Pastellwolken im Hintergrund';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeDarkHint => 'immer die dunkle Oberfläche';

  @override
  String get themeDawn => 'Morgenrot';

  @override
  String get themeDawnHint => 'hell, mit warmem Licht von der Seite';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeLightHint => 'immer die helle Oberfläche';

  @override
  String get themeSectionLook => 'Aussehen';

  @override
  String get themeSystem => 'Design des Geräts';

  @override
  String get themeSystemHint => 'folgt der Systemeinstellung';

  @override
  String get todayBarcode => 'Barcode';

  @override
  String todayCodeTalk(String code) {
    return 'Ich habe den Barcode $code gescannt, und keine Datenbank kennt ihn. Trag nichts ein: frag mich zu diesem Produkt oder sag mir, wie ich es rechnen soll.';
  }

  @override
  String get todayDone => 'Fertig.';

  @override
  String get todayFailedRetry => 'Hat nicht geklappt. Versuch es in einer Minute.';

  @override
  String todayHowManyGrams(String dish) {
    return 'Wie viel Gramm waren es bei $dish?';
  }

  @override
  String get todayLogFailed => 'Eintragen ging nicht. Versuch es noch einmal.';

  @override
  String get todayLogged => 'Eingetragen.';

  @override
  String todayLoggedAskWeight(String slotInto) {
    return 'Eingetragen $slotInto. Sag mir das Gewicht, wenn du es genau willst.';
  }

  @override
  String get todayLoggedAskWeightShort =>
      'Eingetragen. Sag mir das Gewicht, wenn du es genau willst.';

  @override
  String todayLoggedCount(int count) {
    return '$count eingetragen';
  }

  @override
  String todayLoggedInto(String slotInto, String dish) {
    return 'Eingetragen $slotInto: $dish.';
  }

  @override
  String todayLoggedIntoWithNumbers(String slotInto, String dish, int kcal, int grams) {
    return 'Eingetragen $slotInto: $dish, $kcal kcal für $grams g.';
  }

  @override
  String get todayNoraSlow =>
      'Nora denkt länger als sonst. Versuch es noch einmal, der Token ist nicht weg.';

  @override
  String get todayOffline => 'Keine Verbindung. Versuch es, wenn sie zurück ist.';

  @override
  String get todayOfflineSaved =>
      'Keine Verbindung. Der Eintrag bleibt auf dem Telefon und geht hoch, sobald sie zurück ist.';

  @override
  String get todayOutOfTokens => 'Keine Tokens mehr. Von Hand eintragen geht immer.';

  @override
  String get todayPhotoMeal => 'Foto';

  @override
  String get todayQuestionClosed =>
      'Diese Frage ist schon geschlossen. Sag das Gewicht mit Worten, falls nötig.';

  @override
  String get tourCamera => 'Kamera';

  @override
  String get tourCameraHow => 'Teller, Etikett oder Strichcode';

  @override
  String get tourDiary => 'Gedächtnis des Tagebuchs';

  @override
  String get tourDiaryHow => 'sag „Borschtsch“ und sie nimmt die übliche Portion';

  @override
  String get tourGuide => 'Führung durch die App';

  @override
  String get tourGuideHow => 'frag, wo was liegt und wie es geht';

  @override
  String get tourMemory => 'Dauerhaftes Gedächtnis';

  @override
  String get tourMemoryHow => '„kein Schweinefleisch“ reicht einmal';

  @override
  String get tourMore => 'Nicht nur Essen';

  @override
  String get tourMoreHow => 'Wasser, Training, Maße, Rezepte';

  @override
  String get tourTitle => 'Was Nora kann';

  @override
  String get tourVoice => 'Stimme oder Text';

  @override
  String get tourVoiceHow => '„zwei Eier und Toast“, und der Eintrag steht';

  @override
  String get tourWeek => 'Tages- und Wochenanalyse';

  @override
  String get tourWeekHow => 'was geklappt hat und was anzupassen ist';

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
  String get unitsEnergy => 'Energie';

  @override
  String get unitsLength => 'Größe und Maße';

  @override
  String get unitsMass => 'Körpergewicht';

  @override
  String get unitsPortion => 'Portionen';

  @override
  String get unitsTitle => 'Welche Einheiten';

  @override
  String get unitsVolume => 'Wasser';

  @override
  String waterGlasses(int glasses) {
    return 'etwa $glasses Gläser';
  }

  @override
  String waterLess(int step) {
    return '$step ml weniger';
  }

  @override
  String waterMore(int step) {
    return '$step ml mehr';
  }

  @override
  String get waterNone => 'nichts getrunken';

  @override
  String waterOf(String ml) {
    return ' / $ml ml';
  }

  @override
  String waterShare(int pct) {
    return '$pct% des Tagesziels';
  }

  @override
  String get waterTitle => 'Wasser';

  @override
  String get wcNoTime => 'ohne Dauer';

  @override
  String get wdFri => 'Fr';

  @override
  String get wdMon => 'Mo';

  @override
  String get wdSat => 'Sa';

  @override
  String get wdSun => 'So';

  @override
  String get wdThu => 'Do';

  @override
  String get wdTue => 'Di';

  @override
  String get wdWed => 'Mi';

  @override
  String get weightHint =>
      'Was du heute wiegst. Das Ziel und das Tempo dorthin stehen getrennt davon.';

  @override
  String get weightNote =>
      'Wieg dich morgens, vor dem Essen: so machen die Schwankungen des Tages aus dem Diagramm kein Rauschen. Eine Messung pro Woche ist schon ein Trend.';

  @override
  String get weightTitle => 'Gewicht';

  @override
  String get welEggs => 'Zwei Spiegeleier';

  @override
  String get welEggsGrams => '120 g';

  @override
  String get welHaveAccount => 'Ich habe schon ein Konto';

  @override
  String get welLead => 'Zählt Kalorien aus deinen eigenen Worten';

  @override
  String get welSaid => 'Zwei Eier und ein Toast gegessen';

  @override
  String get welStart => 'Los geht\'s';

  @override
  String get welToast => 'Toast mit Butter';

  @override
  String get welToastGrams => '50 g';

  @override
  String get welTotal => 'Zusammen';

  @override
  String get wfBurned => 'Verbrannt, kcal';

  @override
  String get wfDuration => 'Dauer';

  @override
  String get wfDurationCap => 'Dauer, Min';

  @override
  String get wfEstimate => 'Eine Schätzung aus deinem Gewicht und der Art der Aktivität';

  @override
  String get wfFromWatch => 'Von einer Uhr oder einem Gerät';

  @override
  String get wfKcal => ' kcal';

  @override
  String get wfLog => 'Eintragen';

  @override
  String get wfManualKcal => 'kcal von Hand';

  @override
  String wfMin(int min) {
    return '$min Min';
  }

  @override
  String get wfMinutes => 'Minuten';

  @override
  String get wfNote => 'Notiz';

  @override
  String get wfNoteExample => 'Beine, hart';

  @override
  String get wfOptional => '  optional';

  @override
  String get wheelLess => 'Weniger';

  @override
  String get wheelMore => 'Mehr';

  @override
  String get wkDaysOk => 'Tage im Ziel';

  @override
  String get wkEmpty =>
      'Diese Woche ist noch nichts eingetragen. Trag den ersten Tag ein, dann entsteht das Bild.';

  @override
  String get wkFactsHead => 'Die Woche insgesamt';

  @override
  String get wkKcalHead => 'Kalorien';

  @override
  String get wkLoggedCap => 'Tage eingetragen';

  @override
  String wkLoggedValue(int n) {
    return '$n von 7';
  }

  @override
  String get wkMacroHead => 'Makros';

  @override
  String get wkNoWeight => 'Gewicht: nicht gewogen';

  @override
  String get wkNoraBtn => 'Auswertung erstellen';

  @override
  String wkNoraFailed(String why) {
    return 'Die Auswertung ging nicht: $why';
  }

  @override
  String get wkNoraGreet =>
      'Frag alles zu dieser Lesart: ein Gericht, eine Gewohnheit oder was du zuerst ändern solltest.';

  @override
  String get wkNoraLoading => 'Nora liest die Woche…';

  @override
  String get wkNoraLocked => 'Die Auswertung öffnet am Freitag';

  @override
  String get wkNoraNoNet => 'kein Netz';

  @override
  String get wkNoraNoTokens => 'keine Tokens mehr';

  @override
  String get wkNoraP1 =>
      'Deine Basis ist gesund, und das ist selten: fast alles ist selbst gekocht. Suppe, Rührei, Haferbrei: auf so einer Basis ist der Rest schnell gerichtet.';

  @override
  String get wkNoraP2 =>
      'Jetzt ehrlich. Gemüse kam die ganze Woche kaum vor, Süßes dagegen jeden Tag: Pfannkuchen mit Honig, Kompott. Das Protein bleibt knapp, nicht weil du wenig isst, sondern weil der Teller schwer an Kohlenhydraten und leicht an Fleisch, Fisch oder Käse ist. Und drei von sieben Abendessen kamen nach zehn.';

  @override
  String get wkNoraP3 =>
      'Noch ist nichts Schlimmes dabei, aber genau diese Ernährung überrascht mit vierzig beim Blutbild. Ein Schritt für nächste Woche, sonst ändere nichts: etwas Grünes zu jedem Mittagessen, und Wasser statt Kompott.';

  @override
  String get wkNoraPlaceholder => 'Frag zu dieser Woche';

  @override
  String get wkNoraPromise =>
      'Eine ehrliche Lesart deiner Woche: was funktioniert hat, was gerutscht ist und ein Schritt für die nächste.';

  @override
  String get wkNoraReply1 =>
      'Der leichteste Tausch diese Woche: Wasser statt Kompott. Jedes Mal ein Löffel Zucker weniger, und die Suppe verliert dabei nichts.';

  @override
  String get wkNoraReply2 =>
      'Grünes zum Mittag muss kein Salat sein. Eine Gurke oder eine halbe Paprika neben dem Teller reichen schon.';

  @override
  String get wkNoraSlow => 'der Server braucht zu lange';

  @override
  String get wkNoraTalk => 'Mit Nora darüber reden';

  @override
  String get wkNoraTitle => 'Nora über deine Woche';

  @override
  String get wkNorm => 'Ziel';

  @override
  String wkOffNorm(String n) {
    return '$n vom Ziel';
  }

  @override
  String get wkPastEmpty =>
      'Noch keine früheren Auswertungen. Die erste erscheint hier am nächsten Montag.';

  @override
  String wkPastRow(String day) {
    return 'Woche ab $day';
  }

  @override
  String get wkPastTitle => 'Frühere Wochen';

  @override
  String get wkPerDay => 'kcal am Tag im Schnitt';

  @override
  String get wkPerDayAside => 'am Tag im Schnitt';

  @override
  String get wkTitle => 'Die Woche';

  @override
  String get wkTotalCap => 'kcal in der Woche';

  @override
  String get wkWaterCap => 'Wasser am Tag';

  @override
  String wkWaterValue(String l) {
    return '$l l';
  }

  @override
  String get wkWeightCap => 'Gewicht diese Woche';

  @override
  String get workoutAdd => 'Training hinzufügen';

  @override
  String workoutBurned(int kcal) {
    return '−$kcal kcal';
  }

  @override
  String get workoutCollapse => 'Zuklappen';

  @override
  String get workoutMinUnit => 'Min';

  @override
  String get workoutNone => 'nichts eingetragen';

  @override
  String workoutSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einheiten',
      one: '1 Einheit',
    );
    return '$_temp0';
  }

  @override
  String get workoutTitle => 'Training';
}
