// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class LIt extends L {
  LIt([String locale = 'it']) : super(locale);

  @override
  String get aboutContact => 'Contatti';

  @override
  String get aboutDeveloper => 'Sviluppatore';

  @override
  String get aboutText =>
      'Un diario alimentare che capisce le frasi normali. Nora fa i conti, le decisioni restano tue.';

  @override
  String get aboutTitle => 'Informazioni sull\'app';

  @override
  String get aboutVersion => 'Versione';

  @override
  String get aboutWrite => 'Scrivici';

  @override
  String get accessAsk => 'non ancora richiesto';

  @override
  String get accessCamera => 'Fotocamera';

  @override
  String get accessMic => 'Microfono';

  @override
  String get accessNote =>
      'Microfono e riconoscimento vocale servono alla dettatura, e il riconoscimento anche allo smartwatch: registra ciò che dici e il telefono lo trasforma in parole. Tocca una riga per concedere il permesso o aprire le impostazioni di sistema e disattivarlo.';

  @override
  String get accessNotify => 'Notifiche';

  @override
  String get accessOff => 'negato';

  @override
  String get accessOn => 'consentito';

  @override
  String get accessSpeech => 'Riconoscimento vocale';

  @override
  String get accountBusy => 'Accedo…';

  @override
  String get accountGoogle => 'Continua con Google';

  @override
  String get accountKeepCloud => 'Quello dell\'account';

  @override
  String get accountNoAccountNote =>
      'Il diario vive solo su questo telefono. Cambia telefono o togli l\'app e non ci sarà con che riportare le voci: non sappiamo di chi sono.';

  @override
  String get accountScopeNote =>
      'Chiediamo solo l\'email. Google non ci passa il nome, la foto del profilo o i contatti.';

  @override
  String get accountSettingsDevice => 'impostazioni';

  @override
  String get accountSignInFailed => 'Accesso non riuscito.';

  @override
  String accountSignInFailedWhy(String why) {
    return 'Accesso non riuscito. $why';
  }

  @override
  String get accountSignOut => 'Esci';

  @override
  String get accountSignOutAction => 'Esci';

  @override
  String get accountSignOutAsk => 'Uscire dall\'account?';

  @override
  String get accountSignOutBack =>
      'Rientra con lo stesso account e torna tutto. Quello che hai scritto offline e non è ancora arrivato al server non si può recuperare.';

  @override
  String get accountSignOutNote =>
      'Questo telefono viene svuotato: se ne vanno il diario, il profilo, i farmaci e la conversazione con Nora. Le tue voci restano sul server, sotto il tuo account.';

  @override
  String get accountSince => 'Su Calvi da';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountVia => 'Accesso con Google';

  @override
  String get accountViaApple => 'Accesso con Apple';

  @override
  String get accountViaEmail => 'Accesso con e-mail';

  @override
  String get accountWatch => 'Apple Watch';

  @override
  String get accountWhichDiary => 'Quale diario teniamo?';

  @override
  String get accountWhichDiaryNote =>
      'Questo account ha già delle voci, e anche il telefono. Può restarne uno solo: quello dell\'account o quello del telefono. L\'altro va via.';

  @override
  String get actBasketball => 'Basket';

  @override
  String get actBike => 'Bici';

  @override
  String get actDance => 'Ballo';

  @override
  String get actFootball => 'Calcio';

  @override
  String get actGym => 'Palestra';

  @override
  String get actHiit => 'HIIT';

  @override
  String get actJumprope => 'Salto con la corda';

  @override
  String get actRun => 'Corsa';

  @override
  String get actSki => 'Sci';

  @override
  String get actStretch => 'Stretching';

  @override
  String get actSwim => 'Nuoto';

  @override
  String get actTennis => 'Tennis';

  @override
  String get actWalk => 'Camminata';

  @override
  String get actYoga => 'Yoga';

  @override
  String get actionAdd => 'Aggiungi';

  @override
  String get actionBack => 'Indietro';

  @override
  String get actionCancel => 'Annulla';

  @override
  String get actionClose => 'Chiudi';

  @override
  String get actionDelete => 'Elimina';

  @override
  String get actionDone => 'Fatto';

  @override
  String get actionGotIt => 'Ho capito';

  @override
  String get actionNext => 'Avanti';

  @override
  String get actionSave => 'Salva';

  @override
  String get activityHigh => 'Alto';

  @override
  String get activityHighHint => '5-6 allenamenti';

  @override
  String get activityLight => 'Poco attivo';

  @override
  String get activityLightHint => '1-2 allenamenti a settimana';

  @override
  String get activityModerate => 'Moderato';

  @override
  String get activityModerateHint => '3-4 allenamenti';

  @override
  String get activitySedentary => 'Sedentario';

  @override
  String get activitySedentaryHint => 'quasi nessun movimento';

  @override
  String get activityVeryHigh => 'Molto alto';

  @override
  String get activityVeryHighHint => 'lavoro fisico o sport ogni giorno';

  @override
  String agoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni fa',
      one: '1 giorno fa',
    );
    return '$_temp0';
  }

  @override
  String get agoToday => 'oggi';

  @override
  String get agoWeek => 'una settimana fa';

  @override
  String agoWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count settimane fa');
    return '$_temp0';
  }

  @override
  String get agoYesterday => 'ieri';

  @override
  String get allergyConfirm => 'Conferma';

  @override
  String get allergyMild => 'Lieve';

  @override
  String get allergyMildHint => 'Ti avviso nel testo, senza bloccare la voce.';

  @override
  String get allergyMildShort => 'lieve';

  @override
  String get allergyNote =>
      'Se la composizione di un prodotto non è nell\'archivio, non sto zitta e non do per scontato che vada bene: ti dico a parte che la composizione non si conosce.';

  @override
  String get allergyNothing =>
      'Non ho trovato niente. Se l\'allergene non è nella lista, dillo a Nora: lo aggiungiamo all\'archivio così funziona per tutti, invece di restare testo per una persona sola.';

  @override
  String get allergyRemove => 'Togli';

  @override
  String allergySearch(int count) {
    return 'Cerca tra $count allergeni';
  }

  @override
  String get allergySevere => 'Grave';

  @override
  String get allergySevereHint => 'Mi fermo prima di registrarlo e te lo dico chiaro.';

  @override
  String get allergySevereShort => 'grave';

  @override
  String get allergyTitle => 'Allergie';

  @override
  String anChartGoal(String value) {
    return 'obiettivo $value';
  }

  @override
  String get anDaysInNorm => 'giorni in obiettivo';

  @override
  String anDonePercent(int percent) {
    return '$percent% fatto';
  }

  @override
  String anEtaHead(String date) {
    return 'Di questo passo arrivi all\'obiettivo verso il *$date*';
  }

  @override
  String get anForMonth => 'nel mese';

  @override
  String get anForQuarter => 'in 3 mesi';

  @override
  String get anForYear => 'nell\'anno';

  @override
  String get anGoalProgress => 'Avanzamento verso l\'obiettivo';

  @override
  String get anKcal => 'Calorie';

  @override
  String get anKcalAvg => 'in media al giorno';

  @override
  String get anKcalEmpty =>
      'In questo periodo non c\'è ancora niente. Di\' a Nora che cosa hai mangiato e il grafico si costruisce da solo.';

  @override
  String anKcalTotal(Object u) {
    return 'nel periodo, $u';
  }

  @override
  String anMacroGoal(String grams) {
    return 'soglia $grams';
  }

  @override
  String get anMacrosAvg => 'Macro in media';

  @override
  String get anMacrosEmpty =>
      'La media compare appena c\'è qualcosa da mediare: registra almeno un giorno.';

  @override
  String get anMeasures => 'Misure';

  @override
  String anMeasuresChange(String period) {
    return 'variazione $period';
  }

  @override
  String get anMeasuresEmpty => 'Ancora nessuna misura.';

  @override
  String get anMeasuresEmptyHint => 'Misurati una volta al mese e ti mostro che cosa si muove';

  @override
  String get anMonth => 'Mese';

  @override
  String get anNow => 'ora';

  @override
  String anNowKg(Object u) {
    return 'ora, $u';
  }

  @override
  String get anOneReading => 'una misura';

  @override
  String get anOneWeighing =>
      'Per ora c\'è una sola misura. La seconda mostra la direzione, e la linea parte da lì.';

  @override
  String get anPerDay => 'al giorno';

  @override
  String get anQuarter => '3 mesi';

  @override
  String anShareOfNorm(int share) {
    return '$share% della soglia';
  }

  @override
  String anStartKg(Object u) {
    return 'inizio, $u';
  }

  @override
  String anTargetKg(Object u) {
    return 'obiettivo, $u';
  }

  @override
  String get anTitle => 'Statistiche';

  @override
  String get anWater => 'Idratazione';

  @override
  String anWaterAvg(Object u) {
    return 'in media, $u';
  }

  @override
  String anWaterGoal(String ml) {
    return 'soglia $ml';
  }

  @override
  String get anWeek => 'Settimana';

  @override
  String get anWeightEmpty =>
      'La curva compare dalla seconda pesata. Di\' il tuo peso a Nora e lo annota lei.';

  @override
  String get anYear => 'Anno';

  @override
  String get assistantAddMemory => 'Aggiungi alla memoria';

  @override
  String get assistantCollapse => 'Chiudi';

  @override
  String get assistantExample => 'Per esempio, non mangio funghi';

  @override
  String get assistantForget => 'Dimentica';

  @override
  String assistantHint(String name) {
    return '$name tiene il diario con te e ricorda quello che le hai detto di te.';
  }

  @override
  String get assistantMemory => 'Memoria';

  @override
  String get assistantMemoryEmpty => 'Non c\'è ancora niente in memoria.';

  @override
  String get assistantMemoryEmptyHint =>
      'La memoria nasce dalle conversazioni, oppure aggiungine una a mano';

  @override
  String assistantPinned(int count, int pinned) {
    return '$count, $pinned fissate';
  }

  @override
  String get assistantTitle => 'Assistente';

  @override
  String get assistantWhatToRemember => 'Che cosa ricordare';

  @override
  String get authAgain => 'Conferma password';

  @override
  String get authAgainDiffers => 'Le password non coincidono';

  @override
  String get authAgainEmpty => 'Ripeti la password';

  @override
  String get authAgainHint => 'ancora una volta';

  @override
  String authAgainIn(int sec) {
    return 'Puoi richiederlo tra $sec s';
  }

  @override
  String get authCode => 'Codice dalla mail';

  @override
  String get authCodeAction => 'Conferma';

  @override
  String get authCodeBad => 'Il codice non va bene o è scaduto';

  @override
  String authCodeHint(String mail) {
    return 'Abbiamo inviato un codice a $mail. Scrivi le sei cifre.';
  }

  @override
  String get authCodeShort => 'Il codice ha 6 cifre';

  @override
  String get authCodeTitle => 'Conferma la tua e-mail';

  @override
  String get authForgotAction => 'Invia il codice';

  @override
  String get authForgotHint =>
      'Invieremo un codice alla tua e-mail, poi sceglierai una nuova password.';

  @override
  String get authForgotLink => 'Dimenticata?';

  @override
  String get authForgotTitle => 'Nuova password';

  @override
  String get authMail => 'E-mail';

  @override
  String get authMailBad => 'Questo indirizzo sembra sbagliato';

  @override
  String get authOr => 'oppure';

  @override
  String get authPass => 'Password';

  @override
  String get authPassEmpty => 'Inserisci la password';

  @override
  String get authPassHint => '5 lettere e un segno';

  @override
  String get authPassNew => 'Nuova password';

  @override
  String get authPassWeak => 'Password debole: almeno 5 lettere e una cifra o un segno';

  @override
  String get authResetAction => 'Salva password';

  @override
  String get authSendAgain => 'Invia di nuovo';

  @override
  String get authSignInAction => 'Accedi';

  @override
  String get authSignInTitle => 'Accedi';

  @override
  String get authSignUpAction => 'Crea account';

  @override
  String get authSignUpLink => 'Registrati';

  @override
  String get authSignUpTitle => 'Creiamo un account';

  @override
  String get barCamera => 'Fotocamera';

  @override
  String barGrams(String grams) {
    return '$grams';
  }

  @override
  String get barHint => 'Ciao, sono Nora. Scrivi o parla come al solito, ti capisco.';

  @override
  String get barHintBorscht => 'Minestrone 300 g a pranzo';

  @override
  String get barHintDelete => 'Cancella l\'ultima voce';

  @override
  String get barHintEggs => 'Due uova e un toast';

  @override
  String get barHintMore =>
      '«due uova e un toast», «bevuto 300 di acqua», «corso 40 minuti»: ci arrivo io e lo metto nella scheda giusta';

  @override
  String get barHintProtein => 'Quante proteine mi restano?';

  @override
  String get barHintRun => 'Corso 40 minuti';

  @override
  String get barHintWater => 'Bevuto 500 ml di acqua';

  @override
  String get barHintWeighed => 'Peso: 78,8';

  @override
  String get barHintYesterday => 'Che cosa ho mangiato ieri?';

  @override
  String get barLogsInto => 'Registro in ';

  @override
  String get barMic => 'Microfono';

  @override
  String get barSend => 'Manda';

  @override
  String get camAgain => 'Di nuovo';

  @override
  String get camAllergen => 'Allergene!';

  @override
  String camAllergyContains(String list) {
    return 'Contiene il tuo allergene: $list';
  }

  @override
  String camAllergyTraces(String list) {
    return 'Può contenere tracce di: $list';
  }

  @override
  String get camAskNoraInstead => 'Senza etichetta, chiedi a Nora';

  @override
  String get camBarcode => 'Codice a barre';

  @override
  String get camBusy => 'La fotocamera non si è aperta. Di solito la sta usando un\'altra app.';

  @override
  String get camCouldNotRead => 'Non sono riuscita a leggere la foto';

  @override
  String get camDish => 'Foto';

  @override
  String camEstimate(Object u) {
    return ' $u, stima';
  }

  @override
  String get camFlash => 'Flash';

  @override
  String get camFromPack => 'Dati dalla confezione. Registrarlo non costa token.';

  @override
  String get camGallery => 'Dalla galleria';

  @override
  String get camGapNote =>
      'Questo valore non lo conosce nessun archivio. Fotografa l\'etichetta e lo completo.';

  @override
  String get camHintBarcode => 'il codice dentro la cornice';

  @override
  String get camHintDish => 'inquadra un piatto o una confezione';

  @override
  String camIngredients(String text) {
    return 'Ingredienti: $text';
  }

  @override
  String camIntoSlot(String slot) {
    return 'in $slot';
  }

  @override
  String camKcalFor(String grams, Object u) {
    return ' $u in $grams';
  }

  @override
  String camKcalPer(String grams, Object u) {
    return ' $u per $grams';
  }

  @override
  String get camLabelAim => 'inquadra la tabella nutrizionale';

  @override
  String get camLabelNoShot => 'La foto non è riuscita. Prova a fotografare di nuovo l\'etichetta.';

  @override
  String camLogInto(String slotInto) {
    return 'Registralo $slotInto';
  }

  @override
  String get camNoPermission =>
      'Manca il permesso della fotocamera. Puoi darlo nelle impostazioni del telefono.';

  @override
  String get camNoScanner => 'Questo telefono non riesce a leggere i codici con la fotocamera.';

  @override
  String get camNoTokens => 'Token finiti';

  @override
  String get camNotAProduct => 'Questo non è un codice di prodotto';

  @override
  String get camNotAProductNote =>
      'È stato letto un link o un codice interno. Inquadra le barre con le cifre sotto.';

  @override
  String get camNotRead => 'Non sono riuscita a distinguerlo';

  @override
  String get camOffline =>
      'Il codice è stato letto, ma non c\'è nessuno a cui chiedere. Riprova quando torni online.';

  @override
  String get camOfflineShot => 'Nessuna connessione. Puoi mandare la foto a Nora più tardi';

  @override
  String get camOfflineTitle => 'Nessuna rete';

  @override
  String get camPer100 => 'Sulla confezione non c\'è un peso esatto: i valori sono per 100 g.';

  @override
  String camPortionPack(String g) {
    return 'Porzione dalla confezione: $g. I valori sono per porzione.';
  }

  @override
  String get camReading => 'Leggo…';

  @override
  String get camSendToNora => 'Manda a Nora';

  @override
  String get camServerDown => 'Non dipende dal codice né dalla fotocamera. Riprova tra un minuto.';

  @override
  String get camServerDownTitle => 'Il nostro server non ha risposto';

  @override
  String get camShoot => 'Scatta una foto';

  @override
  String get camShootLabel => 'Fotografa l\'etichetta';

  @override
  String get camShotFailed => 'La foto non è riuscita';

  @override
  String get camShotReady => 'La foto è pronta';

  @override
  String get camShotReadyNote =>
      'Nora la legge e risponde in chat: dice che piatto è, stima la porzione e mostra da dove viene il numero. Costa due token.';

  @override
  String get camSignedOut =>
      'La sessione non vale più, quindi l\'archivio non ci riconosce. Accedi di nuovo e lo scanner funzionerà.';

  @override
  String get camSignedOutTitle => 'Accedi di nuovo';

  @override
  String get camSlow => 'Il codice è stato letto e l\'archivio ci ha messo troppo. Riprova.';

  @override
  String get camSlowTitle => 'La risposta non è arrivata';

  @override
  String get camStillWorks => 'Le foto dei piatti e la galleria funzionano come sempre.';

  @override
  String get camTitle => 'Scanner';

  @override
  String get camTookTooLong => 'Ci ha messo troppo a leggerla. Riprova';

  @override
  String get camUnknownCode => 'Questo prodotto non è in nessun archivio';

  @override
  String get camUnknownCodeNote =>
      'Né nel nostro né in quello aperto. Fotografa la tabella nutrizionale sulla confezione e copio i valori da lì. È gratis.';

  @override
  String get chatPro => 'Pro';

  @override
  String get deleteAskBody1 =>
      'Questo telefono viene svuotato subito: il diario, il profilo, la conversazione con Nora e l\'accesso. L\'app torna alla prima schermata.';

  @override
  String get deleteAskBody2 =>
      'Sul server l\'account entra in coda per l\'eliminazione definitiva, che richiede fino a 30 giorni lavorativi. Finché non la confermiamo, accedere con lo stesso account riporta tutto e annulla la richiesta.';

  @override
  String get deleteAskCta => 'Sì, elimina';

  @override
  String get deleteAskTitle => 'Eliminare l\'account?';

  @override
  String get deleteConfirm =>
      'Ho capito che i dati saranno eliminati per sempre e non si potranno recuperare.';

  @override
  String get deleteDays => 'Giorni con Calvi';

  @override
  String get deleteEntries => 'Voci nel diario';

  @override
  String deleteFailed(String why) {
    return 'Non sono riuscita a eliminare: $why';
  }

  @override
  String get deleteForever => 'Elimina per sempre';

  @override
  String get deleteNote =>
      'Va via tutto: il diario, il peso, le misure, le allergie, i farmaci e lo storico delle conversazioni. Non si torna indietro.';

  @override
  String get deleteProManage => 'Gestisci l\'abbonamento';

  @override
  String deleteProNote(String store) {
    return 'Eliminare l\'account non disdice Calvi Pro. $store continua ad addebitare finché non disdici l\'abbonamento stesso, quindi disdicilo prima di eliminare l\'account.';
  }

  @override
  String get deleteProStoreAny => 'Lo store';

  @override
  String get deleteSubNote =>
      'Se il punto è l\'abbonamento, si può disdire a parte nell\'App Store o su Google Play, senza eliminare l\'account.';

  @override
  String get deleteTitle => 'Elimina l\'account';

  @override
  String get deleteWeighings => 'Misure di peso';

  @override
  String get dictationBusy => 'Il microfono è occupato. Riprova';

  @override
  String get dictationFailed => 'La dettatura non ha funzionato';

  @override
  String get dictationNoMatch => 'Non ho sentito niente di comprensibile';

  @override
  String get dictationNoNetwork => 'Il riconoscimento ha bisogno della rete';

  @override
  String get dictationNoPermission => 'Manca il permesso del microfono';

  @override
  String get dictationSilence => 'Silenzio. Riprova, più vicino al microfono';

  @override
  String get dictationUnavailable => 'La dettatura non è disponibile su questo telefono';

  @override
  String get doseCapFew => 'capsule';

  @override
  String get doseCapMany => 'capsule';

  @override
  String get doseCapOne => 'capsula';

  @override
  String get doseDropFew => 'gocce';

  @override
  String get doseDropMany => 'gocce';

  @override
  String get doseDropOne => 'goccia';

  @override
  String get doseMlFew => 'ml';

  @override
  String get doseMlMany => 'ml';

  @override
  String get doseMlOne => 'ml';

  @override
  String get doseShotFew => 'iniezioni';

  @override
  String get doseShotMany => 'iniezioni';

  @override
  String get doseShotOne => 'iniezione';

  @override
  String get doseTabFew => 'compresse';

  @override
  String get doseTabMany => 'compresse';

  @override
  String get doseTabOne => 'compressa';

  @override
  String entries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voci',
      one: '1 voce',
      zero: 'nessuna voce',
    );
    return '$_temp0';
  }

  @override
  String get eraseAskBody1 =>
      'Va via il diario intero, di tutto il tempo: pasti, acqua, peso, misure, allenamenti, farmaci e la conversazione con Nora. Su ogni dispositivo, perché si cancella anche la copia sul server.';

  @override
  String get eraseAskBody2 =>
      'Che cosa resta: l\'account, l\'accesso, i token con il loro saldo e le impostazioni del profilo. Questo non è uscire dall\'account, è ripartire da zero dentro lo stesso account.';

  @override
  String get eraseAskCta => 'Elimina tutto';

  @override
  String get eraseAskTitle => 'Eliminare tutte le voci?';

  @override
  String get eraseDataTitle => 'Elimina i dati';

  @override
  String get eraseDone => 'Il diario è cancellato. Si riparte da zero.';

  @override
  String eraseFailed(String why) {
    return 'Non sono riuscita a cancellare: $why';
  }

  @override
  String get eraseNoNet => 'nessuna rete. Accendi internet e riprova';

  @override
  String get eraseSlow => 'il server ci mette troppo. Riprova tra un minuto';

  @override
  String get eraseSureBody =>
      'Questo non si può annullare. Il diario sparisce per sempre, e non possiamo riportarlo indietro né tu né noi.';

  @override
  String get eraseSureCta => 'Sì, elimina per sempre';

  @override
  String get eraseSureTitle => 'Elimino davvero?';

  @override
  String get eveningAnd => ' e ';

  @override
  String get eveningBreakfastAcc => 'la colazione';

  @override
  String get eveningDinnerAcc => 'la cena';

  @override
  String get eveningEmptyDay => 'La giornata è vuota. Che cosa hai mangiato oggi?';

  @override
  String eveningLogged(String slot) {
    return 'Hai registrato $slot?';
  }

  @override
  String get eveningLunchAcc => 'il pranzo';

  @override
  String eveningMissing(String list) {
    return '$list ancora da registrare. Quali ci sono stati?';
  }

  @override
  String get eveningWater => 'A quanta acqua è arrivata la giornata?';

  @override
  String get fieldBiceps => 'Bicipite';

  @override
  String get fieldChest => 'Petto';

  @override
  String get fieldHips => 'Fianchi';

  @override
  String get fieldNeck => 'Collo';

  @override
  String get fieldThigh => 'Coscia';

  @override
  String get fieldWaist => 'Vita';

  @override
  String get fieldWeight => 'Peso';

  @override
  String get fieldWrist => 'Polso';

  @override
  String get goalBecomes => 'Diventa';

  @override
  String get goalCurrent => 'Obiettivo attuale ';

  @override
  String get goalDailyNorm => 'Soglia giornaliera';

  @override
  String goalDiff(String kg) {
    return '$kg di differenza';
  }

  @override
  String get goalDirection => 'Direzione';

  @override
  String get goalEta => 'Obiettivo verso il';

  @override
  String goalFromStart(String kg) {
    return ' da $kg all\'inizio. ';
  }

  @override
  String get goalFromToday => 'Il nuovo obiettivo parte dal peso di oggi.';

  @override
  String get goalKeepNote =>
      'La soglia tiene il tuo peso attuale: rimetti esattamente quello che consumi.';

  @override
  String get goalKeepShort => 'Mantenere';

  @override
  String get goalNew => 'Imposta un nuovo obiettivo';

  @override
  String get goalNewTitle => 'Nuovo obiettivo';

  @override
  String get goalPace => 'Ritmo';

  @override
  String get goalPaceFast => 'Veloce';

  @override
  String get goalPaceOk => 'Questo è il ritmo che quasi tutti riescono a tenere senza spezzarsi.';

  @override
  String get goalPaceSlow => 'Lento';

  @override
  String goalPaceUnit(Object u) {
    return '$u a settimana';
  }

  @override
  String get goalPaceUsual => 'Consigliato';

  @override
  String goalRange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get goalReplaceNote =>
      'Un obiettivo non si modifica, si sostituisce. L\'avanzamento conterà dal peso di oggi, e quello vecchio resta nello storico. Confermi il cambio?';

  @override
  String get goalSet => 'Imposta';

  @override
  String get goalTarget => 'Peso obiettivo';

  @override
  String get goalWas => 'Era';

  @override
  String gramsUnit(String grams) {
    return '$grams';
  }

  @override
  String get helloDishBread => 'Pane di segale';

  @override
  String get helloDishEggs => 'Uova strapazzate';

  @override
  String get helloSaid => 'due uova e un toast';

  @override
  String get helloSlotSub => 'due voci';

  @override
  String get helloStepCount => 'Conto le calorie';

  @override
  String get helloStepLog => 'Lo annoto nella tua giornata';

  @override
  String get helloStepSay => 'Di\' che cosa hai mangiato';

  @override
  String heroBurned(String kcal) {
    return '-$kcal dall\'allenamento';
  }

  @override
  String get heroDays => 'giorni';

  @override
  String heroFrom(String kcal) {
    return ' di $kcal';
  }

  @override
  String heroGoalKg(Object u) {
    return 'obiettivo, $u';
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
  String get heroLeft => 'restano ';

  @override
  String heroOf(String kcal) {
    return ' di $kcal';
  }

  @override
  String get heroOver => 'sforato di ';

  @override
  String get heroWeekOpen => 'La settimana intera';

  @override
  String heroWeightFrom(String kg) {
    return 'ora, da $kg all\'inizio dell\'obiettivo';
  }

  @override
  String get islandLast => 'ultimo pasto';

  @override
  String get islandLeft => 'kcal rimaste';

  @override
  String get islandNothing => 'oggi ancora niente';

  @override
  String get islandOver => 'kcal in più';

  @override
  String get islandToday => 'resta per oggi';

  @override
  String get islandTodayOver => 'in più per oggi';

  @override
  String kcalUnit(String kcal) {
    return '$kcal';
  }

  @override
  String get langSection => 'Lingua dell\'interfaccia';

  @override
  String get langSystem => 'Lingua del dispositivo';

  @override
  String get legalOnTheWeb => 'Open on the web';

  @override
  String legalUpdated(String date) {
    return 'Updated $date';
  }

  @override
  String liveBody(String eaten, String goal) {
    return '$eaten di $goal mangiate';
  }

  @override
  String get liveChannel => 'Contatore del giorno';

  @override
  String get liveChannelHint => 'Quanto resta per oggi, finché l’app è attiva';

  @override
  String liveLeft(String kcal) {
    return 'Restano $kcal kcal';
  }

  @override
  String liveOver(String kcal) {
    return '$kcal kcal in più';
  }

  @override
  String get loginNoToken => 'Google non ha restituito un token';

  @override
  String get loginNotConfigured => 'l\'accesso non è configurato in questa build';

  @override
  String get loginNotSynced =>
      'Non tutte le voci sono arrivate al server. Riprova tra un minuto: accedere non cancella niente finché non è tutto salvato';

  @override
  String loginServer(String why) {
    return 'server: $why';
  }

  @override
  String get loginSlow => 'Google non ha risposto in un minuto. Riprova';

  @override
  String get macroCNone => 'C ?';

  @override
  String macroCShort(int value) {
    return 'C $value';
  }

  @override
  String get macroCarbs => 'Carboidrati';

  @override
  String get macroCarbsCaps => 'CARBOIDRATI';

  @override
  String get macroCarbsLetter => 'C';

  @override
  String get macroFNone => 'G ?';

  @override
  String macroFShort(int value) {
    return 'G $value';
  }

  @override
  String get macroFat => 'Grassi';

  @override
  String get macroFatCaps => 'GRASSI';

  @override
  String get macroFatLetter => 'G';

  @override
  String get macroMedsCaps => 'FARMACI';

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
  String get macroProtein => 'Proteine';

  @override
  String get macroProteinCaps => 'PROTEINE';

  @override
  String get macroProteinLetter => 'P';

  @override
  String get mealAuto => 'auto ';

  @override
  String get mealEditDelete => 'Elimina la voce';

  @override
  String mealEditKcal(Object u) {
    return '$u';
  }

  @override
  String get mealEditSave => 'Salva';

  @override
  String get mealEmpty => 'Qui non c\'è ancora niente. Scrivi che cos\'era e lo registro.';

  @override
  String mealGrams(String grams) {
    return '$grams';
  }

  @override
  String get mealThinking => 'Nora sta contando…';

  @override
  String get measureAdd => 'Aggiungi una misura';

  @override
  String get measureCollapse => 'Chiudi';

  @override
  String measureCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count misure',
      one: '1 misura',
    );
    return '$_temp0';
  }

  @override
  String measureLast(String ago) {
    return 'l\'ultima $ago';
  }

  @override
  String get measureNever => 'non ancora misurato';

  @override
  String get measureNothing => 'ancora niente';

  @override
  String get measurePick => 'Scegli che cosa misurerai. Ne basta una se il resto non ti interessa.';

  @override
  String get measureSave => 'Salva le misure';

  @override
  String get measureStats => 'Statistiche delle misure';

  @override
  String get measureTitle => 'Misure';

  @override
  String get medsAdd => 'Aggiungi un farmaco';

  @override
  String get medsAllTaken => 'Per oggi è tutto preso';

  @override
  String get medsAt => 'Alle';

  @override
  String get medsCourse => 'Cura';

  @override
  String get medsDose => 'Dose';

  @override
  String get medsEmpty =>
      'Qui non c\'è ancora niente. Aggiungi un farmaco e te lo ricordo all\'ora giusta.';

  @override
  String get medsEmptyHint => 'Tengo il registro delle assunzioni, la dose non la calcolo';

  @override
  String get medsFinish => 'Termina la cura';

  @override
  String medsFirstDose(String name, String day, String at) {
    return '$name, prima assunzione $day alle $at';
  }

  @override
  String get medsHours => 'Ore';

  @override
  String get medsHowOften => 'Ogni quanto';

  @override
  String get medsMine => 'I miei farmaci';

  @override
  String get medsName => 'Nome';

  @override
  String get medsNameExample => 'Per esempio, Magnesio B6';

  @override
  String get medsNew => 'Nuovo farmaco';

  @override
  String get medsNextAt => 'Prossima alle ';

  @override
  String get medsNoneToday => 'Oggi non ci sono assunzioni';

  @override
  String get medsNote => 'Nota';

  @override
  String get medsNow => 'ORA';

  @override
  String get medsOne => 'Farmaco';

  @override
  String get medsPast => 'Passati';

  @override
  String get medsPastEmpty =>
      'Qui finiranno le cure che non segui più. Un farmaco tolto dalla lista resta nei giorni in cui l\'hai preso.';

  @override
  String get medsPerTake => 'Quanto per volta';

  @override
  String get medsRemind => 'Ricordamelo';

  @override
  String get medsRemindHint => 'alle ore scelte';

  @override
  String get medsResume => 'Riprendi la cura';

  @override
  String get medsSchedule => 'Orario';

  @override
  String medsSince(String date) {
    return 'dal $date';
  }

  @override
  String get medsTime => 'Ora';

  @override
  String get medsTitle => 'Farmaci';

  @override
  String get medsTomorrow => 'domani';

  @override
  String get medsUnmarked => 'Ancora da segnare: ';

  @override
  String medsUntil(String date) {
    return 'fino al $date';
  }

  @override
  String get menuAbout => 'Informazioni';

  @override
  String get menuAllergy => 'Allergie';

  @override
  String get menuAnalytics => 'Statistiche';

  @override
  String get menuDiary => 'Diario';

  @override
  String get menuHintFree => 'gratuito';

  @override
  String menuHintKcal(String n) {
    return 'oggi $n';
  }

  @override
  String menuHintMore(int n) {
    return '+$n';
  }

  @override
  String get menuHintNoAllergy => 'nessuna';

  @override
  String get menuHintNoMeds => 'nessun ciclo';

  @override
  String get menuHintNothing => 'ancora nulla registrato';

  @override
  String menuHintOnGoal(int ok, int total) {
    return 'in obiettivo $ok su $total';
  }

  @override
  String get menuHintRecipes => 'da Nora, su misura per te';

  @override
  String get menuHintWeekFriday => 'da venerdì, 18:00';

  @override
  String get menuHintWeekOpen => 'aperto fino a domenica';

  @override
  String get menuHintWeekYoung => 'la settimana è appena iniziata';

  @override
  String get menuMeds => 'Farmaci';

  @override
  String get menuPlan => 'Abbonamento';

  @override
  String get menuRecipes => 'Ricette';

  @override
  String get menuSettings => 'Impostazioni';

  @override
  String get menuTitle => 'Menu';

  @override
  String get menuWeek => 'Riepilogo settimanale';

  @override
  String get noraName => 'Nora';

  @override
  String get normAuto => 'Calcolala automaticamente';

  @override
  String get normAutoFrom =>
      'Dal peso all\'inizio dell\'obiettivo, dall\'altezza, dall\'età, dall\'attività e dal ritmo: ';

  @override
  String normAutoHint(String kcal) {
    return 'dal peso, dall\'altezza, dall\'età, dall\'attività e dall\'obiettivo: $kcal';
  }

  @override
  String get normAutoShort => 'Automatica';

  @override
  String get normByHand => 'Impostala a mano';

  @override
  String get normByHandHint => 'le statistiche conteranno su questo numero';

  @override
  String get normByHandShort => 'A mano';

  @override
  String get normCalculatedHead => 'Il valore calcolato è ';

  @override
  String get normCalculatedTail => '. Puoi tornarci scegliendo «Automatica».';

  @override
  String get normFitCarbs => 'Adatta i carboidrati alla soglia';

  @override
  String get normFits => 'La ripartizione torna con la soglia';

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
  String get normMacros => 'Macro';

  @override
  String get normManual => 'impostata a mano';

  @override
  String normOf(String kcal) {
    return 'di $kcal';
  }

  @override
  String normOffOver(String sum, int off) {
    return 'La ripartizione dà $sum, $off sopra la soglia';
  }

  @override
  String normOffUnder(String sum, int off) {
    return 'La ripartizione dà $sum, $off sotto la soglia';
  }

  @override
  String normPerDay(Object u) {
    return '$u al giorno';
  }

  @override
  String get normTitle => 'Soglia';

  @override
  String get normWater => 'Acqua';

  @override
  String get normWaterHead => 'Cioè ';

  @override
  String normWaterPerKg(String ml) {
    return '$ml';
  }

  @override
  String get normWaterTail =>
      ' per chilo di peso. L\'intervallo indicativo di solito è 30-40 ml, ma dipende dal caldo e dagli allenamenti, quindi il numero qui non è rigido.';

  @override
  String get normWhere => 'Da dove viene questo numero';

  @override
  String get notifyChannel => 'Promemoria';

  @override
  String get notifyChannelHint => 'Promemoria su cibo, acqua, farmaci e pesate';

  @override
  String get notifyDenied =>
      'Il telefono ha rifiutato le notifiche. Attivale nelle impostazioni di sistema e i promemoria funzioneranno.';

  @override
  String get nutriAdded => 'Zucchero aggiunto';

  @override
  String nutriAddedNorm(int g, int better) {
    return 'fino a $g g, meglio fino a $better';
  }

  @override
  String get nutriAddedShort => 'Aggiunto';

  @override
  String get nutriAddedSource => 'OMS: meno del 10% delle calorie, meglio meno del 5%';

  @override
  String get nutriAddedWhat =>
      'Zucchero, sciroppi e miele messi in un prodotto. Lo zucchero proprio di frutta e latte non conta qui.';

  @override
  String nutriAtLeast(String text) {
    return 'almeno $text';
  }

  @override
  String get nutriFiber => 'Fibre';

  @override
  String nutriFiberNorm(int g) {
    return '$g g al giorno';
  }

  @override
  String get nutriFiberShort => 'Fibre';

  @override
  String get nutriFiberSource => 'EFSA: almeno 25 g, o 14 g per mille calorie';

  @override
  String get nutriFiberWhat =>
      'La parte dei cibi vegetali che il corpo non digerisce. Tiene in moto la digestione e sazia più a lungo.';

  @override
  String get nutriFrom => 'Da dove viene oggi';

  @override
  String nutriGap(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count piatti senza questi numeri, quindi è un minimo.',
      one: 'Un piatto senza questi numeri, quindi è un minimo.',
    );
    return '$_temp0';
  }

  @override
  String get nutriGapAll =>
      'Di questo oggi non si sa nulla: nessun piatto del giorno ha questi numeri.';

  @override
  String get nutriNorm => 'Riferimento';

  @override
  String nutriNowGoal(String now, int goal) {
    return '$now g oggi su $goal';
  }

  @override
  String nutriNowSodium(String now, String salt) {
    return '$now g oggi, cioè $salt g di sale';
  }

  @override
  String nutriNowSugar(String now, String added) {
    return '$now g oggi, di cui aggiunto $added';
  }

  @override
  String get nutriProHidden => 'disponibile con Pro';

  @override
  String get nutriProKept =>
      'Vengono già contati, a ogni voce, con o senza abbonamento. Non si perde nulla: appena arriva Pro, questa giornata e tutto il mese alle spalle si aprono con i loro numeri.';

  @override
  String get nutriProTitle => 'Nutrienti in Pro';

  @override
  String get nutriProWhat =>
      'Fibre, zuccheri, zuccheri aggiunti, sodio e grassi saturi fanno parte di Pro. I simboli restano al loro posto; i numeri li apre l’abbonamento.';

  @override
  String nutriRest(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'e altri $count',
      one: 'e altri $count',
    );
    return '$_temp0';
  }

  @override
  String get nutriSat => 'Grassi saturi';

  @override
  String nutriSatNorm(int g) {
    return 'fino a $g g al giorno';
  }

  @override
  String get nutriSatShort => 'Saturi';

  @override
  String get nutriSatSource => 'OMS 2023: meno del 10% delle calorie';

  @override
  String get nutriSatWhat =>
      'Grassi di prodotti animali, burro e formaggio, e di olio di cocco e di palma.';

  @override
  String get nutriSodium => 'Sodio';

  @override
  String get nutriSodiumNorm => 'fino a 2 g al giorno, cioè 5 g di sale';

  @override
  String get nutriSodiumNote =>
      'In un piatto fatto in casa il sale lo mette chi cucina. Prendiamo la quantità abituale per quel tipo di piatto, e si corregge nella personalizzazione.';

  @override
  String get nutriSodiumShort => 'Sodio';

  @override
  String get nutriSodiumSource => 'OMS. Non dipende dalle calorie';

  @override
  String get nutriSodiumWhat =>
      'Il sale è sodio per 2,5. La maggior parte viene da pane, salumi, formaggio e pasti fuori casa, non dalla saliera.';

  @override
  String get nutriSugar => 'Zucchero';

  @override
  String get nutriSugarNorm => 'nessun riferimento';

  @override
  String get nutriSugarNote =>
      'Una scala sotto lo zucchero totale farebbe di una mela un problema. Guarda il numero accanto.';

  @override
  String get nutriSugarShort => 'Zucchero';

  @override
  String get nutriSugarSource => 'OMS ed EFSA limitano lo zucchero aggiunto, non il totale';

  @override
  String get nutriSugarWhat =>
      'Tutti gli zuccheri insieme: quelli aggiunti e quelli di frutta e latte.';

  @override
  String get nutriUnknown => 'oggi non ancora contato';

  @override
  String get photoDish => 'Piatto';

  @override
  String get photoNotRecognized => 'Non sono riuscita a riconoscere il piatto in questa foto';

  @override
  String get planBuy => 'Abbonati';

  @override
  String get planClose => 'Chiudi';

  @override
  String get planCurrent => 'attuale';

  @override
  String get planFailed => 'L\'acquisto non è andato a buon fine';

  @override
  String get planFree => 'Gratis';

  @override
  String planFrom(String plan, String date) {
    return '$plan dal $date';
  }

  @override
  String planFromShort(String date) {
    return 'dal $date';
  }

  @override
  String get planLater => 'Non ora';

  @override
  String get planManage => 'Gestisci nello store';

  @override
  String get planMonth => 'Mese';

  @override
  String get planMonthBilled => 'addebito mensile';

  @override
  String get planMonthly => 'Pro mensile';

  @override
  String get planNext => 'Poi';

  @override
  String get planNothingToRestore => 'Nessun acquisto su questo account';

  @override
  String get planNow => 'Ora';

  @override
  String get planOn => 'Pro';

  @override
  String get planPerMonth => '/mese';

  @override
  String get planPerkChat => 'Conversazioni con Nora senza limiti';

  @override
  String get planPerkChatSub => 'oggi un messaggio costa un token';

  @override
  String get planPerkMemory => 'Nora si ricorda di te';

  @override
  String get planPerkMemorySub => 'impara cose nuove nella conversazione, e questo costa un token';

  @override
  String get planPerkPhoto => 'Foto dei pasti senza limiti';

  @override
  String get planPerkPhotoSub => 'oggi una foto costa due token';

  @override
  String get planPerkRecipes => 'Ricette di Nora senza limiti';

  @override
  String get planPerkRecipesSub => 'oggi una proposta costa un token';

  @override
  String get planPerkWeek => 'Riepilogo settimanale quando vuoi';

  @override
  String get planPerkWeekSub => 'oggi un riepilogo costa due token';

  @override
  String get planPerks => 'Che cosa dà l\'abbonamento';

  @override
  String get planPlan => 'Piano';

  @override
  String get planPrivacy => 'Informativa sulla privacy';

  @override
  String get planRenewal =>
      'L\'abbonamento si rinnova da solo finché non lo disdici. Puoi disdirlo quando vuoi nelle impostazioni dello store da cui l\'hai comprato.';

  @override
  String get planRenews => 'Si rinnova';

  @override
  String get planRestore => 'Ripristina gli acquisti';

  @override
  String get planSignInGo => 'Accedi';

  @override
  String get planSignInNote =>
      'L\'abbonamento è legato a un account con email. Così sopravvive a un telefono nuovo e funziona su tutti i tuoi dispositivi.';

  @override
  String get planSignInTitle => 'Prima accedi';

  @override
  String get planStoreAsking => 'Chiedo i prezzi allo store…';

  @override
  String get planStoreOffline => 'Lo store non risponde. Controlla la connessione a internet';

  @override
  String get planStoreQuiet => 'Lo store non risponde. Riprova più tardi';

  @override
  String get planSwitchMonth => 'Passa al mensile';

  @override
  String get planSwitchYear => 'Passa all\'annuale';

  @override
  String get planTariffs => 'Piani';

  @override
  String get planTerms => 'Condizioni d\'uso';

  @override
  String get planTitle => 'Abbonamento';

  @override
  String get planTokens => 'Token';

  @override
  String get planTokensFree => '40 al mese';

  @override
  String get planTokensPro => 'Senza limiti';

  @override
  String get planUntil => 'Attivo fino al';

  @override
  String get planYear => 'Anno';

  @override
  String planYearBilled(String price) {
    return '$price una volta all\'anno';
  }

  @override
  String get planYearly => 'Pro annuale';

  @override
  String plateFor(String grams) {
    return 'in $grams';
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
  String get plateThinking => 'ci penso';

  @override
  String get plateTotal => 'totale';

  @override
  String get privacyCrash => 'Segnalazioni di errore';

  @override
  String get privacyCrashHint => 'la traccia dell\'errore, senza i dati del diario';

  @override
  String get privacyDiaryHead => 'Il tuo diario resta tuo';

  @override
  String get privacyDiarySub => 'né i pasti né il peso finiscono nelle statistiche';

  @override
  String get privacyHealthHead => 'I dati sulla salute non vanno a nessuno';

  @override
  String get privacyHealthSub => 'allergie e farmaci non escono dall\'app';

  @override
  String get privacyNoPhotosHead => 'Le foto dei pasti non si conservano';

  @override
  String get privacyNoPhotosSub => 'la foto viene letta e sparisce';

  @override
  String get privacyNotCollected => 'Che cosa non raccogliamo';

  @override
  String get privacyOptional => 'Che cosa puoi disattivare';

  @override
  String get privacyPhotosBold => 'non si conservano';

  @override
  String get privacyPhotosHead => 'Le foto dei pasti ';

  @override
  String get privacyPhotosTail =>
      ': la foto va in elaborazione e sparisce. Le statistiche non vedono mai piatti, peso, allergie o farmaci. Quella è una categoria particolare di dati personali, e darla a terzi non se ne parla, per quanto sarebbe comodo.';

  @override
  String get privacyStats => 'Statistiche anonime';

  @override
  String get privacyStatsHint => 'quali schermate vengono aperte, senza il contenuto delle voci';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get profileActivity => 'Attività';

  @override
  String get profileAge => 'Età';

  @override
  String get profileHeight => 'Altezza';

  @override
  String get profileSex => 'Sesso';

  @override
  String rcAllergyWarn(String names) {
    return 'Contiene $names, che è nella tua lista di allergie. Vacci piano con questa.';
  }

  @override
  String get rcAskPlaceholder => 'pollo, broccoli, riso';

  @override
  String rcChatGreet(String name) {
    return 'Chiedi di «$name»: che cosa sostituire, come non rovinarla, che cosa preparare prima.';
  }

  @override
  String get rcChatHello => 'Dimmi che cosa c’è in cucina e ti costruisco una ricetta.';

  @override
  String get rcChatHint => '«pollo, broccoli, riso»: propongo qualche piatto e calcolo la porzione';

  @override
  String get rcChatHintDinner => 'Una cena da 500 kcal';

  @override
  String get rcChatHintEggs => 'Colazione veloce con le uova';

  @override
  String get rcChatHintMince => 'Che cosa faccio con la carne macinata?';

  @override
  String get rcChatHintOnly => 'Sono rimasti solo formaggio e pasta';

  @override
  String get rcChatPicks =>
      'Ecco che cosa puoi cucinare con questo. Scegli un piatto e la ricetta entra nel libro.';

  @override
  String rcCount(int n) {
    return '$n ricette';
  }

  @override
  String rcCountFew(int n) {
    return '$n ricette';
  }

  @override
  String get rcCountOne => '1 ricetta';

  @override
  String rcDeleteBody(String name) {
    return '«$name» esce dal ricettario. I registri del diario fatti da lei restano.';
  }

  @override
  String get rcDeleteCta => 'Elimina';

  @override
  String get rcDeleteFailed => 'Non sono riuscita a eliminarla. Riprova.';

  @override
  String get rcDeleteTitle => 'Eliminare questa ricetta?';

  @override
  String get rcDishHint =>
      '«con che cosa sostituisco il riso?», «come non seccare il filetto?», «posso prepararla prima?»';

  @override
  String get rcDishHintAhead => 'Posso prepararla prima?';

  @override
  String get rcDishHintDry => 'Come non seccare il filetto?';

  @override
  String get rcDishHintKeeps => 'Quanto si conserva?';

  @override
  String get rcDishHintSwap => 'Con che cosa sostituisco il riso?';

  @override
  String get rcEmpty =>
      'Qui non c\'è ancora niente. Di\' a Nora che cosa c\'è in cucina e compare la prima ricetta.';

  @override
  String get rcEmptyMine =>
      'Non ci sono ancora ricette tue. Dettane una qualsiasi a Nora e finisce qui.';

  @override
  String get rcEyebrow => 'La cucina';

  @override
  String get rcFromMine => 'Mia';

  @override
  String get rcFromNora => 'Da Nora';

  @override
  String get rcHelps => 'Nora ti aiuta a creare una ricetta';

  @override
  String get rcHeroA => 'Che cosa cucinare';

  @override
  String get rcHeroB => 'oggi';

  @override
  String get rcHeroLede =>
      'Di\' che cosa hai in casa. Nora propone e calcola la porzione; va bene anche la tua ricetta.';

  @override
  String get rcItemsHead => 'Ingredienti';

  @override
  String rcItemsTotal(String g) {
    return 'in tutto $g';
  }

  @override
  String get rcJustNow => 'adesso';

  @override
  String get rcLoadFailed => 'Il ricettario non si è caricato. Tira per riprovare.';

  @override
  String rcMinutes(int n) {
    return '$n min';
  }

  @override
  String get rcNoTools => 'Niente oltre a un coltello e una ciotola';

  @override
  String rcOfDay(int p) {
    return 'cioè il $p% della soglia giornaliera';
  }

  @override
  String get rcPerServing => 'a porzione';

  @override
  String get rcPerServingHead => 'A porzione';

  @override
  String rcPortion(String g) {
    return 'porzione $g';
  }

  @override
  String rcServingsFew(int n) {
    return '$n porzioni';
  }

  @override
  String rcServingsMany(int n) {
    return '$n porzioni';
  }

  @override
  String get rcServingsOne => '1 porzione';

  @override
  String get rcStepsHead => 'Come si cucina';

  @override
  String get rcSuggestFailed => 'Nora non è riuscita a comporre le ricette. Riprova.';

  @override
  String get rcTabAll => 'Tutte';

  @override
  String get rcTabMine => 'Mie';

  @override
  String get rcTabNora => 'Da Nora';

  @override
  String get rcTitle => 'Ricette';

  @override
  String get rcToolBlender => 'Frullatore';

  @override
  String get rcToolGrill => 'Griglia';

  @override
  String get rcToolMixer => 'Sbattitore';

  @override
  String get rcToolOven => 'Forno';

  @override
  String get rcToolPan => 'Padella';

  @override
  String get rcToolPot => 'Pentola';

  @override
  String get rcToolsHead => 'Che cosa serve in cucina';

  @override
  String rcWhole(String kcal, String g) {
    return 'Piatto intero: $kcal, $g';
  }

  @override
  String get remAbout => 'Su che cosa';

  @override
  String get remAdd => 'Aggiungi un promemoria';

  @override
  String get remAt => 'Alle';

  @override
  String get remDelete => 'Elimina il promemoria';

  @override
  String get remEdit => 'Promemoria';

  @override
  String get remEmpty => 'Non ci sono ancora promemoria.';

  @override
  String get remEmptyHint =>
      'Aggiungi l\'unica cosa che davvero dimentichi, non tutto in una volta';

  @override
  String get remHowOften => 'Ogni quanto';

  @override
  String get remName => 'Nome';

  @override
  String get remNew => 'Nuovo promemoria';

  @override
  String get remOpenMeds => 'Apri i farmaci';

  @override
  String get remTime => 'Ora';

  @override
  String get remTitle => 'Promemoria';

  @override
  String get reminderBodyMeal => 'Registra che cos\'era';

  @override
  String get reminderBodyMeds => 'Secondo l\'orario';

  @override
  String get reminderBodySummary => 'Che cosa non hai registrato oggi?';

  @override
  String get reminderBodyWater => 'È ora di bere';

  @override
  String get reminderBodyWeigh => 'Al mattino, prima di mangiare';

  @override
  String get reminderBodyWorkout => 'Registralo se c\'è stato';

  @override
  String get reminderMeal => 'Cibo';

  @override
  String get reminderMealHint => 'ti ricordo di registrare il pasto';

  @override
  String get reminderMeds => 'Farmaci';

  @override
  String get reminderMedsHint => 'secondo l\'orario del registro';

  @override
  String get reminderSummary => 'Riepilogo del giorno';

  @override
  String get reminderSummaryHint => 'in breve sulla giornata prima di dormire';

  @override
  String get reminderWater => 'Acqua';

  @override
  String get reminderWaterHint => 'ti ricordo di bere';

  @override
  String get reminderWeigh => 'Pesata';

  @override
  String get reminderWeighHint => 'così la curva del peso non si spezza';

  @override
  String get reminderWorkout => 'Allenamento';

  @override
  String get reminderWorkoutHint => 'ti ricordo quello in programma';

  @override
  String get repDaily => 'tutti i giorni';

  @override
  String repEveryN(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'ogni $count giorni');
    return '$_temp0';
  }

  @override
  String get repEveryOther => 'un giorno sì e uno no';

  @override
  String get repPickDaily => 'Tutti i giorni';

  @override
  String get repPickFromToday => 'Si conta da oggi.';

  @override
  String get repPickInterval => 'Un giorno sì e uno no';

  @override
  String get repPickNoDays => 'Non è scelto nessun giorno, quindi il promemoria non suonerà mai.';

  @override
  String get repPickWeekdays => 'Giorni della settimana';

  @override
  String get repWeekdays => 'nei giorni feriali';

  @override
  String get repWeekends => 'nel fine settimana';

  @override
  String get repWeekly => 'una volta a settimana';

  @override
  String get restoredBody1 =>
      'Questo account era in attesa di essere eliminato. L\'accesso ha annullato tutto: il diario, il profilo e le impostazioni sono di nuovo su questo telefono.';

  @override
  String get restoredBody2 =>
      'Se vuoi ancora che l\'account sparisca, chiedi di nuovo l\'eliminazione nelle Impostazioni. Qualsiasi accesso prima della conferma annulla la richiesta allo stesso modo.';

  @override
  String get restoredOk => 'Capito';

  @override
  String get restoredTitle => 'I tuoi dati sono tornati';

  @override
  String get setAbout => 'Informazioni sull\'app';

  @override
  String get setAccess => 'Accesso';

  @override
  String get setAllergies => 'Allergie';

  @override
  String setAssistantLine(String name, int count) {
    return '$name, $count in memoria';
  }

  @override
  String get setCustom => 'Personalizzazione';

  @override
  String get setCustomNote => 'Cosa mostra la schermata del giorno e come contiamo il sale';

  @override
  String get setDeleteAccount => 'Elimina account e dati';

  @override
  String get setFreeTierHead =>
      'Per i difensori dell\'Ucraina, e per chi presta servizio nelle Forze Armate, nel Servizio Statale di Emergenza, in DTEK, per il personale medico, i volontari e gli insegnanti nelle zone di prima linea, il piano a pagamento è ';

  @override
  String get setFreeTierHow => ' Come ottenerlo';

  @override
  String get setFreeTierShort =>
      'Per i difensori dell\'Ucraina, e per chi presta servizio nelle Forze Armate, nel Servizio Statale di Emergenza, in DTEK, per il personale medico, i volontari e gli insegnanti nelle zone di prima linea, il piano a pagamento è GRATIS';

  @override
  String get setFreeTierTelegram => 'Scrivi su Telegram';

  @override
  String get setFreeTierTitle => 'Piano gratuito';

  @override
  String get setFreeTierWord => 'GRATIS';

  @override
  String get setFreeTierWrite =>
      'Scrivi allo sviluppatore e il piano a pagamento ti viene attivato lo stesso giorno.';

  @override
  String get setGoal => 'Obiettivo';

  @override
  String get setGoalKeep => 'mantenere il peso';

  @override
  String setGoalLine(String kg, String pace) {
    return '$kg, $pace/settimana';
  }

  @override
  String get setGroupAbout => 'Su di te';

  @override
  String get setGroupAccount => 'Account';

  @override
  String get setGroupAssistant => 'Assistente';

  @override
  String get setGroupDocs => 'Documenti';

  @override
  String get setGroupHealth => 'Salute';

  @override
  String get setLang => 'Lingua';

  @override
  String get setMedical => 'Avviso medico';

  @override
  String get setMeds => 'Farmaci';

  @override
  String get setNorm => 'Soglia';

  @override
  String setNormLine(String kcal) {
    return '$kcal';
  }

  @override
  String get setNutriLarge => 'In carte';

  @override
  String get setNutriLargeHint => 'Cinque colonne con anelli ed etichette, come i macro';

  @override
  String get setNutriNote => 'Fibre, zucchero, sodio e grassi saturi sotto i macro';

  @override
  String get setNutriOff => 'Non mostrare';

  @override
  String get setNutriOffHint => 'Solo proteine, grassi e carboidrati, come prima';

  @override
  String get setNutriSmall => 'In riga';

  @override
  String get setNutriSmallHint =>
      'Una riga discreta sotto le carte: segno, numero, colore al limite';

  @override
  String get setNutriTitle => 'Nutrienti';

  @override
  String get setPlan => 'Abbonamento';

  @override
  String get setPlanFree => 'Gratis';

  @override
  String get setPolicy => 'Informativa sulla privacy';

  @override
  String get setPrivacy => 'Dati e statistiche';

  @override
  String get setProfile => 'Profilo';

  @override
  String setProfileLine(String sex, int age, String height) {
    return '$sex, $age, $height';
  }

  @override
  String get setReminders => 'Promemoria';

  @override
  String get setRemindersOff => 'disattivati';

  @override
  String get setSaltLess => 'Meno del solito';

  @override
  String get setSaltMore => 'Più del solito';

  @override
  String get setSaltNote => 'Una correzione al sale che ipotizziamo in un piatto fatto in casa';

  @override
  String get setSaltTitle => 'Come sali';

  @override
  String get setSaltUsual => 'Come al solito';

  @override
  String get setTerms => 'Condizioni d\'uso';

  @override
  String get setTheme => 'Tema';

  @override
  String get setTitle => 'Impostazioni';

  @override
  String get setUnits => 'Unità';

  @override
  String get setUnset => 'non impostato';

  @override
  String get sexOther => 'Altro';

  @override
  String get sexShortFemale => 'D';

  @override
  String get sexShortMale => 'U';

  @override
  String get slotBreakfast => 'Colazione';

  @override
  String get slotByHand => 'Metti i numeri tu';

  @override
  String get slotCancel => 'Annulla';

  @override
  String get slotDinner => 'Cena';

  @override
  String slotEraseBody(String name) {
    return '«$name» non ha ancora numeri. La riga esce dalla giornata.';
  }

  @override
  String get slotEraseDo => 'Togli';

  @override
  String get slotEraseTitle => 'Togliere la bozza?';

  @override
  String slotGrams(Object u) {
    return 'PESO, $u';
  }

  @override
  String get slotIntoBreakfast => 'a colazione';

  @override
  String get slotIntoDinner => 'a cena';

  @override
  String get slotIntoLunch => 'a pranzo';

  @override
  String slotIntoOther(String name) {
    return 'in «$name»';
  }

  @override
  String get slotIntoSnack => 'nello spuntino';

  @override
  String slotKcal(Object u) {
    return '$u';
  }

  @override
  String get slotLog => 'Registra';

  @override
  String get slotLunch => 'Pranzo';

  @override
  String get slotSnack => 'Spuntino';

  @override
  String get slotWriteWhat => 'Scrivi che cos\'era';

  @override
  String get startAbout => 'Su di te';

  @override
  String get startAge => 'Età';

  @override
  String startAgeYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anni',
      one: '1 anno',
    );
    return '$_temp0';
  }

  @override
  String get startAgreeAnd => ' e l\'';

  @override
  String get startAgreeHead => 'Accetto le ';

  @override
  String get startAgreePrivacy => 'informativa sulla privacy';

  @override
  String get startAgreeTerms => 'condizioni d\'uso';

  @override
  String get startDeviceFirstRun => 'primo avvio';

  @override
  String get startDocs => 'Documenti';

  @override
  String get startGoal => 'Dove andiamo';

  @override
  String get startGoalGain => 'Mettere peso';

  @override
  String get startGoalGainHint => 'un surplus al ritmo che scegli';

  @override
  String get startGoalKeep => 'Mantenere il peso';

  @override
  String get startGoalKeepHint => 'rimetti esattamente quello che consumi';

  @override
  String get startGoalLose => 'Dimagrire';

  @override
  String get startGoalLoseHint => 'un deficit al ritmo che scegli';

  @override
  String get startHeight => 'Altezza';

  @override
  String get startHiHello => 'Benvenuto in';

  @override
  String get startHiNote => 'Sei domande brevi, un minuto. Il resto lo calcola Nora.';

  @override
  String get startLife => 'Stile di vita';

  @override
  String get startNorm => 'La tua soglia';

  @override
  String get startNormCounting => 'calcolo…';

  @override
  String get startNormHold => 'mantenendo';

  @override
  String get startNormNote =>
      'Questa è la formula di Mifflin-St Jeor, non un consiglio medico. Se hai una patologia, sei incinta o segui una dieta prescritta, parlane con il tuo medico.';

  @override
  String startNormPerDay(Object u) {
    return '$u al giorno';
  }

  @override
  String get startNormWeeks => 'settimane';

  @override
  String get startPace => 'A che ritmo';

  @override
  String get startPaceEtaHead => 'Obiettivo verso il ';

  @override
  String get startPaceEtaTail => ', cioè ';

  @override
  String get startPaceFast => 'veloce';

  @override
  String get startPaceSlow => 'lento';

  @override
  String startPaceUnit(Object u) {
    return '$u a settimana';
  }

  @override
  String get startPaceUsual => 'costante';

  @override
  String get startPaceWarning =>
      'Un ritmo così è difficile da tenere e di solito si spezza. Sotto gli 0,8 kg a settimana il risultato arriva più lento, ma resta.';

  @override
  String startPaceWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count settimane',
      one: '1 settimana',
    );
    return '$_temp0';
  }

  @override
  String get startSex => 'Sesso';

  @override
  String get startSexFemale => 'Donna';

  @override
  String get startSexMale => 'Uomo';

  @override
  String get startSexOther => 'Altro';

  @override
  String get startSignInApple => 'Continua con Apple';

  @override
  String get startSignInBackText =>
      'Accedi con lo stesso account e torna tutto: il diario, l\'obiettivo, la soglia e le misure. Non c\'è niente da ricompilare.';

  @override
  String get startSignInBackTitle => 'Bentornato';

  @override
  String get startSignInBusy => 'Accedo…';

  @override
  String get startSignInFailed => 'Accesso non riuscito. Riprova, oppure continua senza account.';

  @override
  String startSignInFailedWhy(String why) {
    return 'Accesso non riuscito. $why';
  }

  @override
  String get startSignInGoogle => 'Continua con Google';

  @override
  String get startSignInSkip => 'Continua senza account';

  @override
  String get startSignInText =>
      'La soglia è calcolata. Accedi per conservarla: cronologia, misure e registri saranno su ogni dispositivo, non solo qui.';

  @override
  String get startSignInTitle => 'Teniamo tutto questo';

  @override
  String get startTargetWeight => 'Peso obiettivo';

  @override
  String get startWeightNow => 'Peso attuale';

  @override
  String get startYearsShort => 'anni';

  @override
  String get storageBroken =>
      'Non sono riuscita ad aprire l\'archivio. Le tue voci sono al sicuro, ma adesso non c\'è con che mostrarle.';

  @override
  String get themeAquarelle => 'Acquerello';

  @override
  String get themeAquarelleHint => 'chiara, con nuvole pastello sullo sfondo';

  @override
  String get themeDark => 'Scuro';

  @override
  String get themeDarkHint => 'sempre l\'interfaccia scura';

  @override
  String get themeDawn => 'Alba';

  @override
  String get themeDawnHint => 'chiara, con luce calda di lato';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeLightHint => 'sempre l\'interfaccia chiara';

  @override
  String get themeSectionLook => 'Aspetto';

  @override
  String get themeSystem => 'Tema del dispositivo';

  @override
  String get themeSystemHint => 'segue l\'impostazione di sistema';

  @override
  String get todayBarcode => 'Codice a barre';

  @override
  String todayCodeTalk(String code) {
    return 'Ho scansionato il codice a barre $code e non lo conosce nessun archivio. Non registrare niente: chiedimi di questo prodotto o dimmi come contarlo.';
  }

  @override
  String get todayDone => 'Fatto.';

  @override
  String get todayFailedRetry => 'Non è andata. Riprova tra un minuto.';

  @override
  String get todayGoalMet =>
      'Complimenti! 🎉 Il peso che volevi è tuo, l’obiettivo è chiuso. E l’hai fatto tu, non l’app. Ora passo la tua norma al mantenimento, così il risultato resta.';

  @override
  String todayHowManyGrams(String dish) {
    return 'Quanti grammi erano di $dish?';
  }

  @override
  String todayLabelTalk(String code) {
    return 'È l\'etichetta di un prodotto con codice a barre $code, nessuna base lo conosce. Trascrivi la tabella nutrizionale dalla confezione.';
  }

  @override
  String get todayLogFailed => 'Non sono riuscita a registrarlo. Riprova.';

  @override
  String get todayLogged => 'Registrato.';

  @override
  String todayLoggedAskWeight(String slotInto) {
    return 'Registrato $slotInto. Dimmi il peso se lo vuoi preciso.';
  }

  @override
  String get todayLoggedAskWeightShort => 'Registrato. Dimmi il peso se lo vuoi preciso.';

  @override
  String todayLoggedCount(int count) {
    return '$count registrati';
  }

  @override
  String todayLoggedInto(String slotInto, String dish) {
    return 'Registrato $slotInto: $dish.';
  }

  @override
  String todayLoggedIntoWithNumbers(String slotInto, String dish, String kcal, String grams) {
    return 'Registrato $slotInto: $dish, $kcal per $grams.';
  }

  @override
  String get todayNoraSlow =>
      'Nora ci sta pensando più del solito. Riprova, il token non è stato speso.';

  @override
  String get todayOffline => 'Nessuna connessione. Riprova quando torna.';

  @override
  String get todayOfflineSaved =>
      'Nessuna connessione. La voce resta sul telefono e sale quando torna.';

  @override
  String get todayOutOfBody =>
      'Per ora taccio, ma inserire a mano si può sempre, ed è gratis. L’abbonamento mi riaccende e costa quanto tre caffè al mese.';

  @override
  String get todayOutOfPlan => 'Abbonamento';

  @override
  String get todayOutOfTokens => 'I token sono finiti.';

  @override
  String get todayPhotoLabel => 'Foto dell\'etichetta';

  @override
  String get todayPhotoMeal => 'Foto';

  @override
  String get todayQuestionClosed => 'Quella domanda è già chiusa. Di\' il peso a parole se serve.';

  @override
  String get tourCamera => 'Fotocamera';

  @override
  String get tourCameraHow => 'un piatto, un\'etichetta o un codice a barre';

  @override
  String get tourDiary => 'Memoria del diario';

  @override
  String get tourDiaryHow => 'dici «borsch» e prende la porzione solita';

  @override
  String get tourGuide => 'Guida all\'app';

  @override
  String get tourGuideHow => 'chiedi dov\'è cosa e come si fa';

  @override
  String get tourMemory => 'Memoria duratura';

  @override
  String get tourMemoryHow => '«non mangio maiale» basta dirlo una volta';

  @override
  String get tourMore => 'Non solo cibo';

  @override
  String get tourMoreHow => 'acqua, allenamenti, misure, ricette';

  @override
  String get tourTitle => 'Cosa sa fare Nora';

  @override
  String get tourVoice => 'Voce o testo';

  @override
  String get tourVoiceHow => '«due uova e un toast», ed è registrato';

  @override
  String get tourWeek => 'Analisi del giorno e della settimana';

  @override
  String get tourWeekHow => 'cosa ha funzionato e cosa sistemare';

  @override
  String get unitCm => 'cm';

  @override
  String get unitCmName => 'Centimetri';

  @override
  String get unitFlozName => 'Once liquide';

  @override
  String get unitG => 'g';

  @override
  String get unitGName => 'Grammi';

  @override
  String get unitInName => 'Pollici';

  @override
  String get unitKcal => 'kcal';

  @override
  String get unitKcalName => 'Calorie';

  @override
  String get unitKg => 'kg';

  @override
  String get unitKgName => 'Chilogrammi';

  @override
  String get unitKj => 'kJ';

  @override
  String get unitKjName => 'Kilojoule';

  @override
  String get unitLbName => 'Libbre';

  @override
  String get unitMl => 'ml';

  @override
  String get unitMlName => 'Millilitri';

  @override
  String get unitOzName => 'Once';

  @override
  String get unitStName => 'Stone';

  @override
  String get unitsEnergy => 'Energia';

  @override
  String get unitsLength => 'Altezza e misure';

  @override
  String get unitsMass => 'Peso corporeo';

  @override
  String get unitsPortion => 'Porzioni';

  @override
  String get unitsTitle => 'Quali unità';

  @override
  String get unitsVolume => 'Acqua';

  @override
  String get watchLinked => 'collegato';

  @override
  String waterGlasses(int glasses) {
    return 'circa $glasses bicchieri';
  }

  @override
  String waterLess(String step) {
    return '$step in meno';
  }

  @override
  String waterMore(String step) {
    return '$step in più';
  }

  @override
  String get waterNone => 'niente bevuto';

  @override
  String waterOf(String ml) {
    return ' / $ml';
  }

  @override
  String waterShare(int pct) {
    return '$pct% dell\'obiettivo giornaliero';
  }

  @override
  String get waterTitle => 'Acqua';

  @override
  String get wcNoTime => 'senza durata';

  @override
  String get wdFri => 'Ven';

  @override
  String get wdMon => 'Lun';

  @override
  String get wdSat => 'Sab';

  @override
  String get wdSun => 'Dom';

  @override
  String get wdThu => 'Gio';

  @override
  String get wdTue => 'Mar';

  @override
  String get wdWed => 'Mer';

  @override
  String get weightHint =>
      'Quanto pesi oggi. L\'obiettivo e il ritmo verso di lui stanno da un\'altra parte.';

  @override
  String get weightNote =>
      'Pesati al mattino, prima di mangiare: così gli sbalzi della giornata non trasformano il grafico in rumore. Una misura a settimana è già una tendenza.';

  @override
  String get weightTitle => 'Peso';

  @override
  String get welEggs => 'Due uova fritte';

  @override
  String get welEggsGrams => '120 g';

  @override
  String get welHaveAccount => 'Ho già un account';

  @override
  String get welLead => 'Conta le calorie dalle tue parole';

  @override
  String get welSaid => 'Ho mangiato due uova e un toast';

  @override
  String get welStart => 'Iniziamo';

  @override
  String get welToast => 'Toast con burro';

  @override
  String get welToastGrams => '50 g';

  @override
  String get welTotal => 'In tutto';

  @override
  String wfBurned(Object u) {
    return 'Bruciate, $u';
  }

  @override
  String get wfDuration => 'Durata';

  @override
  String get wfDurationCap => 'Durata, min';

  @override
  String get wfEstimate => 'Una stima dal tuo peso e dal tipo di attività';

  @override
  String get wfFromWatch => 'Da un orologio o da un attrezzo';

  @override
  String wfKcal(Object u) {
    return ' $u';
  }

  @override
  String get wfLog => 'Registra';

  @override
  String wfManualKcal(Object u) {
    return '$u a mano';
  }

  @override
  String wfMin(int min) {
    return '$min min';
  }

  @override
  String get wfMinutes => 'Minuti';

  @override
  String get wfNote => 'Nota';

  @override
  String get wfNoteExample => 'Gambe, duro';

  @override
  String get wfOptional => '  facoltativo';

  @override
  String get wheelLess => 'Meno';

  @override
  String get wheelMore => 'Più';

  @override
  String get wkDaysOk => 'giorni in obiettivo';

  @override
  String get wkEmpty =>
      'Questa settimana non è ancora stato registrato niente. Registra il primo giorno e il quadro compare.';

  @override
  String get wkFactsHead => 'La settimana in totale';

  @override
  String get wkKcalHead => 'Calorie';

  @override
  String get wkLoggedCap => 'giorni registrati';

  @override
  String wkLoggedValue(int n) {
    return '$n su 7';
  }

  @override
  String get wkMacroHead => 'Macro';

  @override
  String get wkNoWeight => 'peso: nessuna pesata';

  @override
  String get wkNoraBtn => 'Crea l\'analisi';

  @override
  String wkNoraFailed(String why) {
    return 'Non sono riuscita a creare l\'analisi: $why';
  }

  @override
  String get wkNoraGreet =>
      'Chiedi quello che vuoi su questa lettura: un piatto, un\'abitudine o che cosa sistemare per primo.';

  @override
  String get wkNoraLoading => 'Nora sta leggendo la settimana…';

  @override
  String get wkNoraLocked => 'L\'analisi si apre venerdì';

  @override
  String get wkNoraNoNet => 'nessuna rete';

  @override
  String get wkNoraNoTokens => 'token finiti';

  @override
  String get wkNoraP1 =>
      'La tua base è sana, e capita di rado: quasi tutto è fatto in casa. Minestra, uova strapazzate, avena: su una base così il resto si aggiusta in fretta.';

  @override
  String get wkNoraP2 =>
      'Ora, onestamente. La verdura si è quasi mai vista in tutta la settimana, mentre il dolce c\'era ogni giorno: pancake con il miele, composta. Le proteine restano corte non perché mangi poco, ma perché il piatto è carico di carboidrati e leggero di carne, pesce o formaggio. E tre cene su sette sono arrivate dopo le dieci.';

  @override
  String get wkNoraP3 =>
      'Niente di grave per ora, ma è proprio la dieta che sorprende nelle analisi a quarant\'anni. Un passo per la settimana prossima, senza cambiare altro: qualcosa di verde a ogni pranzo, e acqua al posto della composta.';

  @override
  String get wkNoraPlaceholder => 'Chiedi di questa settimana';

  @override
  String get wkNoraPromise =>
      'Una lettura onesta della tua settimana: che cosa ha funzionato, che cosa è scivolato e un passo per la prossima.';

  @override
  String get wkNoraReply1 =>
      'Il cambio più facile di questa settimana: acqua al posto della composta. Un cucchiaio di zucchero in meno ogni volta, e la minestra non ci perde niente.';

  @override
  String get wkNoraReply2 =>
      'Verde a pranzo non vuol dire per forza insalata. Un cetriolo o mezzo peperone accanto al piatto bastano già.';

  @override
  String get wkNoraSlow => 'il server ci mette troppo';

  @override
  String get wkNoraTalk => 'Parlane con Nora';

  @override
  String get wkNoraTitle => 'Nora sulla tua settimana';

  @override
  String get wkNorm => 'obiettivo';

  @override
  String wkOffNorm(String n) {
    return '$n fuori obiettivo';
  }

  @override
  String get wkPastEmpty =>
      'Non ci sono ancora analisi passate. La prima comparirà qui lunedì prossimo.';

  @override
  String wkPastRow(String day) {
    return 'Settimana del $day';
  }

  @override
  String get wkPastTitle => 'Settimane passate';

  @override
  String wkPerDay(Object u) {
    return '$u al giorno in media';
  }

  @override
  String get wkPerDayAside => 'al giorno in media';

  @override
  String get wkTitle => 'La settimana';

  @override
  String wkTotalCap(Object u) {
    return '$u nella settimana';
  }

  @override
  String get wkWaterCap => 'di acqua al giorno';

  @override
  String wkWaterValue(String l) {
    return '$l l';
  }

  @override
  String get wkWeightCap => 'peso questa settimana';

  @override
  String get workoutAdd => 'Aggiungi un allenamento';

  @override
  String workoutBurned(String kcal) {
    return '−$kcal';
  }

  @override
  String get workoutCollapse => 'Chiudi';

  @override
  String get workoutMinUnit => 'min';

  @override
  String get workoutNone => 'niente registrato';

  @override
  String workoutSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessioni',
      one: '1 sessione',
    );
    return '$_temp0';
  }

  @override
  String get workoutTitle => 'Allenamento';
}
