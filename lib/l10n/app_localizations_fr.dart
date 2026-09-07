// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class LFr extends L {
  LFr([String locale = 'fr']) : super(locale);

  @override
  String get aboutContact => 'Contact';

  @override
  String get aboutDeveloper => 'Développeur';

  @override
  String get aboutText =>
      'Un journal alimentaire qui comprend les phrases normales. Nora fait les calculs, les décisions restent les tiennes.';

  @override
  String get aboutTitle => 'À propos de l\'app';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutWrite => 'Écris-nous';

  @override
  String get accountBusy => 'Connexion…';

  @override
  String get accountGoogle => 'Continuer avec Google';

  @override
  String get accountKeepCloud => 'Celui du compte';

  @override
  String get accountNoAccountNote =>
      'Le journal ne vit que sur ce téléphone. Change de téléphone ou supprime l\'app et il n\'y aura rien pour ramener les entrées : nous ne savons pas à qui elles sont.';

  @override
  String get accountScopeNote =>
      'Nous demandons seulement l\'adresse e-mail. Google ne nous transmet ni le nom, ni la photo de profil, ni les contacts.';

  @override
  String get accountSettingsDevice => 'réglages';

  @override
  String get accountSignInFailed => 'La connexion n\'a pas marché.';

  @override
  String accountSignInFailedWhy(String why) {
    return 'La connexion n\'a pas marché. $why';
  }

  @override
  String get accountSignOut => 'Se déconnecter';

  @override
  String get accountSignOutAction => 'Se déconnecter';

  @override
  String get accountSignOutAsk => 'Se déconnecter ?';

  @override
  String get accountSignOutBack =>
      'Reconnecte-toi avec le même compte et tout revient. Ce qui a été écrit hors ligne et n\'est pas encore arrivé au serveur ne peut pas être récupéré.';

  @override
  String get accountSignOutNote =>
      'Ce téléphone est vidé : le journal, le profil, les médicaments et la conversation avec Nora partent. Tes entrées restent sur le serveur, sous ton compte.';

  @override
  String get accountSince => 'Sur Calvi depuis le';

  @override
  String get accountTitle => 'Compte';

  @override
  String get accountVia => 'Connecté avec Google';

  @override
  String get accountViaApple => 'Connecté avec Apple';

  @override
  String get accountViaEmail => 'Connecté avec l\'e-mail';

  @override
  String get accountWhichDiary => 'Quel journal on garde ?';

  @override
  String get accountWhichDiaryNote =>
      'Ce compte a déjà des entrées, et le téléphone aussi. Un seul peut rester : celui du compte ou celui du téléphone. L\'autre part.';

  @override
  String get actBasketball => 'Basket';

  @override
  String get actBike => 'Vélo';

  @override
  String get actDance => 'Danse';

  @override
  String get actFootball => 'Football';

  @override
  String get actGym => 'Salle de sport';

  @override
  String get actHiit => 'HIIT';

  @override
  String get actJumprope => 'Corde à sauter';

  @override
  String get actRun => 'Course';

  @override
  String get actSki => 'Ski';

  @override
  String get actStretch => 'Étirements';

  @override
  String get actSwim => 'Natation';

  @override
  String get actTennis => 'Tennis';

  @override
  String get actWalk => 'Marche';

  @override
  String get actYoga => 'Yoga';

  @override
  String get actionAdd => 'Ajouter';

  @override
  String get actionBack => 'Retour';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionDone => 'Terminé';

  @override
  String get actionNext => 'Suivant';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get activityHigh => 'Élevé';

  @override
  String get activityHighHint => '5-6 séances';

  @override
  String get activityLight => 'Peu actif';

  @override
  String get activityLightHint => '1-2 séances par semaine';

  @override
  String get activityModerate => 'Modéré';

  @override
  String get activityModerateHint => '3-4 séances';

  @override
  String get activitySedentary => 'Sédentaire';

  @override
  String get activitySedentaryHint => 'presque aucun mouvement';

  @override
  String get activityVeryHigh => 'Très élevé';

  @override
  String get activityVeryHighHint => 'travail physique ou sport tous les jours';

  @override
  String agoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count jours',
      one: 'il y a 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get agoToday => 'aujourd\'hui';

  @override
  String get agoWeek => 'il y a une semaine';

  @override
  String agoWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count semaines',
    );
    return '$_temp0';
  }

  @override
  String get agoYesterday => 'hier';

  @override
  String get allergyConfirm => 'Confirmer';

  @override
  String get allergyMild => 'Légère';

  @override
  String get allergyMildHint => 'Je te préviens dans le texte, sans bloquer l\'entrée.';

  @override
  String get allergyMildShort => 'légère';

  @override
  String get allergyNote =>
      'Si la composition d\'un produit n\'est pas dans le référentiel, je ne me tais pas et je ne considère pas que c\'est sans risque : je te dis à part que la composition est inconnue.';

  @override
  String get allergyNothing =>
      'Rien trouvé. Si l\'allergène n\'est pas dans la liste, dis-le à Nora : nous l\'ajouterons au référentiel pour que ça marche pour tout le monde, au lieu de rester du texte pour une seule personne.';

  @override
  String get allergyRemove => 'Retirer';

  @override
  String allergySearch(int count) {
    return 'Chercher parmi $count allergènes';
  }

  @override
  String get allergySevere => 'Sévère';

  @override
  String get allergySevereHint => 'Je m\'arrête avant de le noter et je te le dis clairement.';

  @override
  String get allergySevereShort => 'sévère';

  @override
  String get allergyTitle => 'Allergies';

  @override
  String anChartGoal(String value) {
    return 'objectif $value';
  }

  @override
  String get anDaysInNorm => 'jours dans l\'objectif';

  @override
  String anDonePercent(int percent) {
    return '$percent% fait';
  }

  @override
  String anEtaHead(String date) {
    return 'À ce rythme tu atteins l\'objectif vers le *$date*';
  }

  @override
  String get anForMonth => 'sur le mois';

  @override
  String get anForQuarter => 'sur 3 mois';

  @override
  String get anForYear => 'sur l\'année';

  @override
  String get anGoalProgress => 'Progression vers l\'objectif';

  @override
  String get anKcal => 'Calories';

  @override
  String get anKcalAvg => 'en moyenne par jour';

  @override
  String get anKcalEmpty =>
      'Rien n\'est encore noté sur cette période. Dis à Nora ce que tu as mangé et le graphique se construit tout seul.';

  @override
  String get anKcalTotal => 'sur la période, kcal';

  @override
  String anMacroGoal(int grams) {
    return 'repère $grams g';
  }

  @override
  String get anMacrosAvg => 'Macros en moyenne';

  @override
  String get anMacrosEmpty =>
      'La moyenne apparaît dès qu\'il y a de quoi la faire : note au moins une journée.';

  @override
  String get anMeasures => 'Mesures';

  @override
  String anMeasuresChange(String period) {
    return 'évolution $period';
  }

  @override
  String get anMeasuresEmpty => 'Pas encore de mesures.';

  @override
  String get anMeasuresEmptyHint => 'Mesure-toi une fois par mois et je te montre ce qui bouge';

  @override
  String get anMonth => 'Mois';

  @override
  String get anNow => 'maintenant';

  @override
  String get anNowKg => 'maintenant, kg';

  @override
  String get anOneReading => 'une mesure';

  @override
  String get anOneWeighing =>
      'Pour l\'instant il n\'y a qu\'une mesure. La deuxième donne la direction, et la ligne part de là.';

  @override
  String get anPerDay => 'par jour';

  @override
  String get anQuarter => '3 mois';

  @override
  String anShareOfNorm(int share) {
    return '$share% du repère';
  }

  @override
  String get anStartKg => 'départ, kg';

  @override
  String get anTargetKg => 'objectif, kg';

  @override
  String get anTitle => 'Statistiques';

  @override
  String get anWater => 'Hydratation';

  @override
  String get anWaterAvg => 'en moyenne, ml';

  @override
  String anWaterGoal(String ml) {
    return 'repère $ml ml';
  }

  @override
  String get anWeek => 'Semaine';

  @override
  String get anWeightEmpty =>
      'La courbe apparaît à la deuxième pesée. Dis ton poids à Nora, elle le note elle-même.';

  @override
  String get anYear => 'Année';

  @override
  String get assistantAddMemory => 'Ajouter à la mémoire';

  @override
  String get assistantCollapse => 'Replier';

  @override
  String get assistantExample => 'Par exemple, je ne mange pas de champignons';

  @override
  String get assistantForget => 'Oublier';

  @override
  String assistantHint(String name) {
    return '$name tient le journal avec toi et retient ce que tu lui as dit sur toi.';
  }

  @override
  String get assistantMemory => 'Mémoire';

  @override
  String get assistantMemoryEmpty => 'Rien de retenu pour l\'instant.';

  @override
  String get assistantMemoryEmptyHint =>
      'La mémoire vient des conversations, ou ajoute quelque chose toi-même';

  @override
  String assistantPinned(int count, int pinned) {
    return '$count, $pinned épinglées';
  }

  @override
  String get assistantTitle => 'Assistante';

  @override
  String get assistantWhatToRemember => 'Quoi retenir';

  @override
  String get authAgain => 'Confirmer le mot de passe';

  @override
  String get authAgainDiffers => 'Les mots de passe ne correspondent pas';

  @override
  String get authAgainEmpty => 'Répète le mot de passe';

  @override
  String get authAgainHint => 'encore une fois';

  @override
  String authAgainIn(int sec) {
    return 'Tu peux redemander dans $sec s';
  }

  @override
  String get authCode => 'Code du courriel';

  @override
  String get authCodeAction => 'Confirmer';

  @override
  String get authCodeBad => 'Ce code ne convient pas ou a expiré';

  @override
  String authCodeHint(String mail) {
    return 'Nous avons envoyé un code à $mail. Saisis les six chiffres.';
  }

  @override
  String get authCodeShort => 'Le code a 6 chiffres';

  @override
  String get authCodeTitle => 'Confirme ton e-mail';

  @override
  String get authForgotAction => 'Envoyer le code';

  @override
  String get authForgotHint =>
      'Nous enverrons un code par e-mail, puis tu choisiras un nouveau mot de passe.';

  @override
  String get authForgotLink => 'Oublié ?';

  @override
  String get authForgotTitle => 'Nouveau mot de passe';

  @override
  String get authMail => 'E-mail';

  @override
  String get authMailBad => 'Cette adresse semble incorrecte';

  @override
  String get authOr => 'ou';

  @override
  String get authPass => 'Mot de passe';

  @override
  String get authPassEmpty => 'Saisis ton mot de passe';

  @override
  String get authPassHint => '5 lettres et un signe';

  @override
  String get authPassNew => 'Nouveau mot de passe';

  @override
  String get authPassWeak => 'Mot de passe faible : au moins 5 lettres et un chiffre ou un signe';

  @override
  String get authResetAction => 'Enregistrer';

  @override
  String get authSendAgain => 'Renvoyer';

  @override
  String get authSignInAction => 'Se connecter';

  @override
  String get authSignInTitle => 'Connexion';

  @override
  String get authSignUpAction => 'Créer le compte';

  @override
  String get authSignUpLink => 'S\'inscrire';

  @override
  String get authSignUpTitle => 'Créons un compte';

  @override
  String get barCamera => 'Caméra';

  @override
  String barGrams(int grams) {
    return '$grams g';
  }

  @override
  String get barHint => 'Écris comme tu parles.';

  @override
  String get barHintBorscht => 'Soupe de lentilles 300 g au déjeuner';

  @override
  String get barHintDelete => 'Supprime la dernière entrée';

  @override
  String get barHintEggs => 'Deux œufs et une tartine';

  @override
  String get barHintMore =>
      '«deux œufs et une tartine», «bu 300 d\'eau», «couru 40 minutes» : je m\'en occupe et je le mets dans la bonne carte';

  @override
  String get barHintProtein => 'Combien de protéines il me reste ?';

  @override
  String get barHintRun => 'Couru 40 minutes';

  @override
  String get barHintWater => 'Bu 500 ml d\'eau';

  @override
  String get barHintWeighed => 'Poids : 78,8';

  @override
  String get barHintYesterday => 'Qu\'est-ce que j\'ai mangé hier ?';

  @override
  String get barLogsInto => 'Je note dans ';

  @override
  String get barMic => 'Micro';

  @override
  String get barSend => 'Envoyer';

  @override
  String get camAgain => 'Encore';

  @override
  String get camAllergen => 'Allergène !';

  @override
  String camAllergyContains(String list) {
    return 'Contient ton allergène : $list';
  }

  @override
  String camAllergyTraces(String list) {
    return 'Peut contenir des traces de : $list';
  }

  @override
  String get camAskNoraInstead => 'Pas d\'étiquette, demande à Nora';

  @override
  String get camBarcode => 'Code-barres';

  @override
  String get camBusy => 'La caméra ne s\'est pas ouverte. En général une autre app la retient.';

  @override
  String get camCouldNotRead => 'Je n\'ai pas pu lire la photo';

  @override
  String get camDish => 'Photo';

  @override
  String get camEstimate => ' kcal, estimation';

  @override
  String get camFlash => 'Flash';

  @override
  String get camFromPack => 'Chiffres de l\'emballage. L\'enregistrer ne coûte aucun jeton.';

  @override
  String get camGallery => 'Depuis la galerie';

  @override
  String get camGapNote =>
      'Aucune base ne connaît ce chiffre. Photographie l\'étiquette et je le complète.';

  @override
  String get camHintBarcode => 'le code dans le cadre';

  @override
  String get camHintDish => 'vise une assiette ou un paquet';

  @override
  String camIngredients(String text) {
    return 'Ingrédients : $text';
  }

  @override
  String camIntoSlot(String slot) {
    return 'dans $slot';
  }

  @override
  String camKcalFor(int grams) {
    return ' kcal sur $grams g';
  }

  @override
  String camKcalPer(int grams) {
    return ' kcal pour $grams g';
  }

  @override
  String get camLabelAim => 'vise le tableau nutritionnel';

  @override
  String get camLabelNoShot => 'La photo n\'a pas marché. Réessaie l\'étiquette.';

  @override
  String get camLabelReading => 'Je recopie les chiffres du paquet…';

  @override
  String camLogInto(String slotInto) {
    return 'L\'enregistrer $slotInto';
  }

  @override
  String get camNoPermission =>
      'Pas d\'autorisation pour la caméra. Tu peux la donner dans les réglages du téléphone.';

  @override
  String get camNoScanner => 'Ce téléphone ne sait pas lire les codes avec la caméra.';

  @override
  String get camNoTokens => 'Plus de jetons';

  @override
  String get camNotAProduct => 'Ce n\'est pas un code-barres de produit';

  @override
  String get camNotAProductNote =>
      'C\'est un lien ou un code interne qui a été lu. Vise les barres avec les chiffres en dessous.';

  @override
  String get camNotRead => 'Je n\'ai pas réussi à distinguer';

  @override
  String get camOffline =>
      'Le code a été lu, mais il n\'y a personne à qui demander. Réessaie quand tu seras en ligne.';

  @override
  String get camOfflineShot => 'Pas de connexion. Tu pourras envoyer la photo à Nora plus tard';

  @override
  String get camOfflineTitle => 'Pas de réseau';

  @override
  String get camPer100 => 'Pas de poids exact sur l\'emballage : les chiffres sont pour 100 g.';

  @override
  String camPortionPack(int g) {
    return 'Portion de l\'emballage : $g g. Les chiffres sont par portion.';
  }

  @override
  String get camReading => 'Je lis…';

  @override
  String get camSendToNora => 'Envoyer à Nora';

  @override
  String get camServerDown => 'Ce n\'est ni le code ni la caméra. Réessaie dans une minute.';

  @override
  String get camServerDownTitle => 'Notre serveur n\'a pas répondu';

  @override
  String get camShoot => 'Prendre une photo';

  @override
  String get camShootLabel => 'Photographier l\'étiquette';

  @override
  String get camShotFailed => 'La photo n\'a pas marché';

  @override
  String get camShotReady => 'La photo est prête';

  @override
  String get camShotReadyNote =>
      'Nora la lit et répond dans le chat : elle nomme le plat, estime la portion et montre d\'où vient le chiffre. Cela coûte deux jetons.';

  @override
  String get camSignedOut =>
      'La session ne vaut plus, donc la base ne nous reconnaît pas. Reconnecte-toi et le scanner marchera.';

  @override
  String get camSignedOutTitle => 'Reconnecte-toi';

  @override
  String get camSlow => 'Le code a été lu et la base a pris trop de temps. Réessaie.';

  @override
  String get camSlowTitle => 'La réponse n\'est pas arrivée';

  @override
  String get camStillWorks => 'Les photos de plats et la galerie marchent comme d\'habitude.';

  @override
  String get camTitle => 'Scanner';

  @override
  String get camTookTooLong => 'La lecture a pris trop de temps. Réessaie';

  @override
  String get camUnknownCode => 'Ce produit n\'est dans aucune base';

  @override
  String get camUnknownCodeNote =>
      'Ni dans la nôtre ni dans l\'ouverte. Photographie le tableau nutritionnel sur le paquet et je recopie les chiffres. C\'est gratuit.';

  @override
  String get chatPro => 'Pro';

  @override
  String get deleteAskBody1 =>
      'Ce téléphone est vidé tout de suite : le journal, le profil, la conversation avec Nora et la connexion. L\'app revient au premier écran.';

  @override
  String get deleteAskBody2 =>
      'Sur le serveur, le compte entre dans la file pour la suppression définitive, ce qui prend jusqu\'à 30 jours ouvrés. Tant que nous ne l\'avons pas confirmée, se connecter avec le même compte ramène tout et annule la demande.';

  @override
  String get deleteAskCta => 'Oui, supprimer';

  @override
  String get deleteAskTitle => 'Supprimer le compte ?';

  @override
  String get deleteConfirm =>
      'Je comprends que les données seront supprimées pour toujours et qu\'on ne pourra pas les récupérer.';

  @override
  String get deleteDays => 'Jours avec Calvi';

  @override
  String get deleteEntries => 'Entrées dans le journal';

  @override
  String deleteFailed(String why) {
    return 'La suppression n\'a pas marché : $why';
  }

  @override
  String get deleteForever => 'Supprimer pour toujours';

  @override
  String get deleteNote =>
      'Tout part : le journal, le poids, les mesures, les allergies, les médicaments et l\'historique des conversations. Il n\'y a pas de retour en arrière.';

  @override
  String get deleteProManage => 'Gérer l\'abonnement';

  @override
  String deleteProNote(String store) {
    return 'Supprimer le compte n\'annule pas Calvi Pro. $store continue de prélever tant que l\'abonnement lui-même n\'est pas annulé, alors annule-le avant de supprimer le compte.';
  }

  @override
  String get deleteProStoreAny => 'Le store';

  @override
  String get deleteSubNote =>
      'Si c\'est une question d\'abonnement, il peut être annulé à part dans l\'App Store ou sur Google Play, sans supprimer le compte.';

  @override
  String get deleteTitle => 'Supprimer le compte';

  @override
  String get deleteWeighings => 'Pesées';

  @override
  String get dictationBusy => 'Le micro est occupé. Réessaie';

  @override
  String get dictationFailed => 'La dictée n\'a pas marché';

  @override
  String get dictationNoMatch => 'Je n\'ai rien entendu de compréhensible';

  @override
  String get dictationNoNetwork => 'La reconnaissance a besoin du réseau';

  @override
  String get dictationNoPermission => 'Pas d\'autorisation pour le micro';

  @override
  String get dictationSilence => 'Silence. Réessaie, plus près du micro';

  @override
  String get dictationUnavailable => 'La dictée n\'est pas disponible sur ce téléphone';

  @override
  String get doseCapFew => 'gélules';

  @override
  String get doseCapMany => 'gélules';

  @override
  String get doseCapOne => 'gélule';

  @override
  String get doseDropFew => 'gouttes';

  @override
  String get doseDropMany => 'gouttes';

  @override
  String get doseDropOne => 'goutte';

  @override
  String get doseMlFew => 'ml';

  @override
  String get doseMlMany => 'ml';

  @override
  String get doseMlOne => 'ml';

  @override
  String get doseShotFew => 'injections';

  @override
  String get doseShotMany => 'injections';

  @override
  String get doseShotOne => 'injection';

  @override
  String get doseTabFew => 'comprimés';

  @override
  String get doseTabMany => 'comprimés';

  @override
  String get doseTabOne => 'comprimé';

  @override
  String entries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrées',
      one: '1 entrée',
      zero: '0 entrée',
    );
    return '$_temp0';
  }

  @override
  String get eraseAskBody1 =>
      'Tout le journal part, sur toute la période : repas, eau, poids, mesures, entraînements, médicaments et la conversation avec Nora. Sur tous les appareils, parce que la copie du serveur est effacée aussi.';

  @override
  String get eraseAskBody2 =>
      'Ce qui reste : le compte, la connexion, les jetons avec leur solde et les réglages du profil. Ce n\'est pas une déconnexion, c\'est repartir de zéro dans le même compte.';

  @override
  String get eraseAskCta => 'Tout supprimer';

  @override
  String get eraseAskTitle => 'Supprimer toutes les entrées ?';

  @override
  String get eraseDataTitle => 'Supprimer les données';

  @override
  String get eraseDone => 'Le journal est effacé. On repart de zéro.';

  @override
  String eraseFailed(String why) {
    return 'L\'effacement n\'a pas marché : $why';
  }

  @override
  String get eraseNoNet => 'pas de réseau. Active internet et réessaie';

  @override
  String get eraseSlow => 'le serveur prend trop de temps. Réessaie dans une minute';

  @override
  String get eraseSureBody =>
      'C\'est irréversible. Le journal disparaît pour toujours, et ni toi ni nous ne pourrons le ramener.';

  @override
  String get eraseSureCta => 'Oui, supprimer pour toujours';

  @override
  String get eraseSureTitle => 'Vraiment supprimer ?';

  @override
  String get eveningAnd => ' et ';

  @override
  String get eveningBreakfastAcc => 'le petit-déjeuner';

  @override
  String get eveningDinnerAcc => 'le dîner';

  @override
  String get eveningEmptyDay => 'La journée est vide. Qu\'est-ce que tu as mangé aujourd\'hui ?';

  @override
  String eveningLogged(String slot) {
    return 'Tu as noté $slot ?';
  }

  @override
  String get eveningLunchAcc => 'le déjeuner';

  @override
  String eveningMissing(String list) {
    return '$list ne sont pas encore notés. Lesquels ont eu lieu ?';
  }

  @override
  String get eveningWater => 'La journée est montée à combien d\'eau ?';

  @override
  String get fieldBiceps => 'Biceps';

  @override
  String get fieldChest => 'Poitrine';

  @override
  String get fieldHips => 'Hanches';

  @override
  String get fieldNeck => 'Cou';

  @override
  String get fieldThigh => 'Cuisse';

  @override
  String get fieldWaist => 'Taille';

  @override
  String get fieldWeight => 'Poids';

  @override
  String get fieldWrist => 'Poignet';

  @override
  String get goalBecomes => 'Devient';

  @override
  String get goalCurrent => 'Objectif actuel ';

  @override
  String get goalDailyNorm => 'Repère journalier';

  @override
  String goalDiff(String kg) {
    return '$kg kg d\'écart';
  }

  @override
  String get goalDirection => 'Direction';

  @override
  String get goalEta => 'Objectif vers le';

  @override
  String goalFromStart(String kg) {
    return ' depuis $kg kg au départ. ';
  }

  @override
  String get goalFromToday => 'Le nouvel objectif part du poids d\'aujourd\'hui.';

  @override
  String get goalKeepNote =>
      'Le repère tient ton poids actuel : tu remets exactement ce que tu dépenses.';

  @override
  String get goalKeepShort => 'Garder';

  @override
  String get goalNew => 'Définir un nouvel objectif';

  @override
  String get goalNewTitle => 'Nouvel objectif';

  @override
  String get goalPace => 'Rythme';

  @override
  String get goalPaceFast => 'Rapide';

  @override
  String get goalPaceOk => 'C\'est le rythme que la plupart tiennent sans que ça casse.';

  @override
  String get goalPaceSlow => 'Lent';

  @override
  String get goalPaceUnit => 'kg par semaine';

  @override
  String get goalPaceUsual => 'Conseillé';

  @override
  String goalRange(String from, String to) {
    return '$from → $to kg';
  }

  @override
  String get goalReplaceNote =>
      'Un objectif ne se modifie pas, il se remplace. La progression comptera à partir du poids d\'aujourd\'hui, et l\'ancien objectif reste dans l\'historique. Confirmer le remplacement ?';

  @override
  String get goalSet => 'Définir';

  @override
  String get goalTarget => 'Poids visé';

  @override
  String get goalWas => 'Avant';

  @override
  String gramsUnit(int grams) {
    return '$grams g';
  }

  @override
  String get helloDishBread => 'Pain de seigle';

  @override
  String get helloDishEggs => 'Œufs brouillés';

  @override
  String get helloSaid => 'deux œufs et une tartine';

  @override
  String get helloSlotSub => 'deux entrées';

  @override
  String get helloStepCount => 'Je compte les calories';

  @override
  String get helloStepLog => 'Je le note dans ta journée';

  @override
  String get helloStepSay => 'Dis ce que tu as mangé';

  @override
  String heroBurned(int kcal) {
    return '-$kcal kcal grâce à l\'entraînement';
  }

  @override
  String get heroDays => 'jours';

  @override
  String heroFrom(String kcal) {
    return ' sur $kcal';
  }

  @override
  String get heroGoalKg => 'objectif, kg';

  @override
  String get heroKcal => ' kcal';

  @override
  String get heroKg => ' kg';

  @override
  String get heroLeft => 'reste ';

  @override
  String heroOf(String kcal) {
    return ' sur $kcal';
  }

  @override
  String get heroOver => 'dépassé de ';

  @override
  String get heroWeekOpen => 'La semaine entière';

  @override
  String heroWeightFrom(String kg) {
    return 'maintenant, depuis $kg kg au début de l\'objectif';
  }

  @override
  String kcalUnit(int kcal) {
    return '$kcal kcal';
  }

  @override
  String get langSection => 'Langue de l\'interface';

  @override
  String get langSystem => 'Langue de l\'appareil';

  @override
  String legalUpdated(String date) {
    return 'Updated $date';
  }

  @override
  String get loginNoToken => 'Google n\'a pas renvoyé de jeton';

  @override
  String get loginNotConfigured => 'la connexion n\'est pas configurée dans cette build';

  @override
  String get loginNotSynced =>
      'Toutes les entrées ne sont pas encore arrivées au serveur. Réessaie dans une minute : se connecter n\'efface rien tant que tout n\'est pas sauvegardé';

  @override
  String loginServer(String why) {
    return 'serveur : $why';
  }

  @override
  String get loginSlow => 'Google n\'a pas répondu en une minute. Réessaie';

  @override
  String get macroCNone => 'G ?';

  @override
  String macroCShort(int value) {
    return 'G $value';
  }

  @override
  String get macroCarbs => 'Glucides';

  @override
  String get macroCarbsCaps => 'GLUCIDES';

  @override
  String get macroCarbsLetter => 'G';

  @override
  String get macroFNone => 'L ?';

  @override
  String macroFShort(int value) {
    return 'L $value';
  }

  @override
  String get macroFat => 'Lipides';

  @override
  String get macroFatCaps => 'LIPIDES';

  @override
  String get macroFatLetter => 'L';

  @override
  String get macroMedsCaps => 'MÉDICAMENTS';

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
  String get macroProtein => 'Protéines';

  @override
  String get macroProteinCaps => 'PROTÉINES';

  @override
  String get macroProteinLetter => 'P';

  @override
  String get mealAuto => 'auto ';

  @override
  String get mealEditDelete => 'Supprimer l\'entrée';

  @override
  String get mealEditKcal => 'kcal';

  @override
  String get mealEditSave => 'Enregistrer';

  @override
  String get mealEmpty =>
      'Il n\'y a rien ici pour l\'instant. Écris ce que c\'était et je le note.';

  @override
  String mealGrams(int grams) {
    return '$grams g';
  }

  @override
  String get mealThinking => 'Nora compte…';

  @override
  String get measureAdd => 'Ajouter une mesure';

  @override
  String get measureCollapse => 'Replier';

  @override
  String measureCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mesures',
      one: '1 mesure',
    );
    return '$_temp0';
  }

  @override
  String measureLast(String ago) {
    return 'la dernière $ago';
  }

  @override
  String get measureNever => 'pas encore mesuré';

  @override
  String get measureNothing => 'rien pour l\'instant';

  @override
  String get measurePick =>
      'Choisis ce que tu vas mesurer. Une seule suffit si le reste ne t\'intéresse pas.';

  @override
  String get measureSave => 'Enregistrer les mesures';

  @override
  String get measureStats => 'Statistiques des mesures';

  @override
  String get measureTitle => 'Mesures';

  @override
  String get medsAdd => 'Ajouter un médicament';

  @override
  String get medsAllTaken => 'Tout est pris pour aujourd\'hui';

  @override
  String get medsAt => 'À';

  @override
  String get medsCourse => 'Cure';

  @override
  String get medsDose => 'Dose';

  @override
  String get medsEmpty =>
      'Il n\'y a rien ici pour l\'instant. Ajoute un médicament et je te rappelle à l\'heure.';

  @override
  String get medsEmptyHint => 'Je tiens le journal des prises, je ne calcule pas la dose';

  @override
  String get medsFinish => 'Terminer la cure';

  @override
  String medsFirstDose(String name, String day, String at) {
    return '$name, première prise $day à $at';
  }

  @override
  String get medsHours => 'Heures';

  @override
  String get medsHowOften => 'À quelle fréquence';

  @override
  String get medsMine => 'Mes médicaments';

  @override
  String get medsName => 'Nom';

  @override
  String get medsNameExample => 'Par exemple, Magnésium B6';

  @override
  String get medsNew => 'Nouveau médicament';

  @override
  String get medsNextAt => 'Ensuite à ';

  @override
  String get medsNoneToday => 'Aucune prise aujourd\'hui';

  @override
  String get medsNote => 'Note';

  @override
  String get medsNow => 'MAINTENANT';

  @override
  String get medsOne => 'Médicament';

  @override
  String get medsPast => 'Terminés';

  @override
  String get medsPastEmpty =>
      'Ici viendront les cures que tu ne suis plus. Un médicament retiré de la liste reste dans les jours où tu l\'as pris.';

  @override
  String get medsPerTake => 'Combien par prise';

  @override
  String get medsRemind => 'Me rappeler';

  @override
  String get medsRemindHint => 'aux heures choisies';

  @override
  String get medsResume => 'Reprendre la cure';

  @override
  String get medsSchedule => 'Horaire';

  @override
  String medsSince(String date) {
    return 'depuis le $date';
  }

  @override
  String get medsTime => 'Heure';

  @override
  String get medsTitle => 'Médicaments';

  @override
  String get medsTomorrow => 'demain';

  @override
  String get medsUnmarked => 'Pas encore coché : ';

  @override
  String medsUntil(String date) {
    return 'jusqu\'au $date';
  }

  @override
  String get menuAbout => 'À propos';

  @override
  String get menuAllergy => 'Allergies';

  @override
  String get menuAnalytics => 'Statistiques';

  @override
  String get menuDiary => 'Journal';

  @override
  String get menuHintFree => 'gratuit';

  @override
  String menuHintKcal(int n) {
    return 'aujourd\'hui $n kcal';
  }

  @override
  String menuHintMore(int n) {
    return '+$n';
  }

  @override
  String get menuHintNoAllergy => 'aucune';

  @override
  String get menuHintNoMeds => 'aucune cure';

  @override
  String get menuHintNothing => 'rien de noté pour l\'instant';

  @override
  String menuHintOnGoal(int ok, int total) {
    return 'dans l\'objectif $ok sur $total';
  }

  @override
  String get menuHintRecipes => 'de Nora, adaptées à ta norme';

  @override
  String get menuHintWeekFriday => 'dès vendredi, 18:00';

  @override
  String get menuHintWeekOpen => 'ouvert jusqu\'à dimanche';

  @override
  String get menuHintWeekYoung => 'la semaine vient de commencer';

  @override
  String get menuMeds => 'Médicaments';

  @override
  String get menuPlan => 'Abonnement';

  @override
  String get menuRecipes => 'Recettes';

  @override
  String get menuSettings => 'Réglages';

  @override
  String get menuTitle => 'Menu';

  @override
  String get menuWeek => 'Bilan de la semaine';

  @override
  String get noraName => 'Nora';

  @override
  String get normAuto => 'Le calculer automatiquement';

  @override
  String get normAutoFrom =>
      'À partir du poids au début de l\'objectif, de la taille, de l\'âge, de l\'activité et du rythme : ';

  @override
  String normAutoHint(String kcal) {
    return 'à partir du poids, de la taille, de l\'âge, de l\'activité et de l\'objectif : $kcal kcal';
  }

  @override
  String get normAutoShort => 'Automatique';

  @override
  String get normByHand => 'Le définir à la main';

  @override
  String get normByHandHint => 'les statistiques compteront contre ce chiffre';

  @override
  String get normByHandShort => 'À la main';

  @override
  String get normCalculatedHead => 'La valeur calculée est ';

  @override
  String get normCalculatedTail => '. Tu peux y revenir en choisissant «Automatique».';

  @override
  String get normFitCarbs => 'Ajuster les glucides au repère';

  @override
  String get normFits => 'La répartition colle au repère';

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
  String get normManual => 'défini à la main';

  @override
  String normOf(String kcal) {
    return 'sur $kcal kcal';
  }

  @override
  String normOffOver(String sum, int off) {
    return 'La répartition donne $sum kcal, $off au-dessus du repère';
  }

  @override
  String normOffUnder(String sum, int off) {
    return 'La répartition donne $sum kcal, $off sous le repère';
  }

  @override
  String get normPerDay => 'kcal par jour';

  @override
  String get normTitle => 'Repère';

  @override
  String get normWater => 'Eau';

  @override
  String get normWaterHead => 'Cela fait ';

  @override
  String normWaterPerKg(int ml) {
    return '$ml ml';
  }

  @override
  String get normWaterTail =>
      ' par kilo de poids. La fourchette habituelle va de 30 à 40 ml, mais cela dépend de la chaleur et des entraînements, donc le chiffre ici n\'est pas rigide.';

  @override
  String get normWhere => 'D\'où vient ce chiffre';

  @override
  String get notifyChannel => 'Rappels';

  @override
  String get notifyChannelHint => 'Rappels pour les repas, l\'eau, les médicaments et les pesées';

  @override
  String get notifyDenied =>
      'Le téléphone a refusé les notifications. Active-les dans les réglages système et les rappels marcheront.';

  @override
  String get photoDish => 'Plat';

  @override
  String get photoNotRecognized => 'Je n\'ai pas réussi à reconnaître le plat sur cette photo';

  @override
  String get planBuy => 'S\'abonner';

  @override
  String get planClose => 'Fermer';

  @override
  String get planCurrent => 'en cours';

  @override
  String get planFailed => 'L\'achat n\'est pas passé';

  @override
  String get planFree => 'Gratuit';

  @override
  String planFrom(String plan, String date) {
    return '$plan à partir du $date';
  }

  @override
  String planFromShort(String date) {
    return 'à partir du $date';
  }

  @override
  String get planLater => 'Pas maintenant';

  @override
  String get planManage => 'Gérer dans le store';

  @override
  String get planMonth => 'Mois';

  @override
  String get planMonthBilled => 'prélèvement mensuel';

  @override
  String get planMonthly => 'Pro mensuel';

  @override
  String get planNext => 'Ensuite';

  @override
  String get planNothingToRestore => 'Aucun achat sur ce compte';

  @override
  String get planNow => 'Maintenant';

  @override
  String get planOn => 'Pro';

  @override
  String get planPerMonth => '/mois';

  @override
  String get planPerkChat => 'Conversations avec Nora sans limite';

  @override
  String get planPerkChatSub => 'aujourd\'hui un message coûte un jeton';

  @override
  String get planPerkMemory => 'Nora se souvient de toi';

  @override
  String get planPerkMemorySub =>
      'elle apprend des choses dans la conversation, et cela coûte un jeton';

  @override
  String get planPerkPhoto => 'Photos de repas sans limite';

  @override
  String get planPerkPhotoSub => 'aujourd\'hui une photo coûte deux jetons';

  @override
  String get planPerkRecipes => 'Recettes de Nora sans limite';

  @override
  String get planPerkRecipesSub => 'aujourd\'hui une proposition coûte un jeton';

  @override
  String get planPerkWeek => 'Bilan de la semaine quand tu veux';

  @override
  String get planPerkWeekSub => 'aujourd\'hui un bilan coûte deux jetons';

  @override
  String get planPerks => 'Ce que donne l\'abonnement';

  @override
  String get planPlan => 'Formule';

  @override
  String get planPrivacy => 'Politique de confidentialité';

  @override
  String get planRenewal =>
      'L\'abonnement se renouvelle tout seul tant que tu ne l\'annules pas. Tu peux l\'annuler quand tu veux dans les réglages du store où tu l\'as pris.';

  @override
  String get planRenews => 'Se renouvelle';

  @override
  String get planRestore => 'Restaurer les achats';

  @override
  String get planSignInGo => 'Se connecter';

  @override
  String get planSignInNote =>
      'L\'abonnement est lié à un compte avec une adresse e-mail. Comme ça il survit à un nouveau téléphone et marche sur tous tes appareils.';

  @override
  String get planSignInTitle => 'Connecte-toi d\'abord';

  @override
  String get planStoreAsking => 'Je demande les prix au store…';

  @override
  String get planStoreOffline => 'Le store ne répond pas. Vérifie ta connexion internet';

  @override
  String get planStoreQuiet => 'Le store ne répond pas. Réessaie plus tard';

  @override
  String get planSwitchMonth => 'Passer au mensuel';

  @override
  String get planSwitchYear => 'Passer à l\'annuel';

  @override
  String get planTariffs => 'Formules';

  @override
  String get planTerms => 'Conditions d\'utilisation';

  @override
  String get planTitle => 'Abonnement';

  @override
  String get planTokens => 'Jetons';

  @override
  String get planTokensFree => '40 par mois';

  @override
  String get planTokensPro => 'Sans limite';

  @override
  String get planUntil => 'Actif jusqu\'au';

  @override
  String get planYear => 'An';

  @override
  String planYearBilled(String price) {
    return '$price une fois par an';
  }

  @override
  String get planYearly => 'Pro annuel';

  @override
  String plateFor(int grams) {
    return 'sur $grams g';
  }

  @override
  String get plateGrams => ' g';

  @override
  String get plateKcal => 'kcal';

  @override
  String get plateThinking => 'je réfléchis';

  @override
  String get plateTotal => 'total';

  @override
  String get privacyCrash => 'Rapports de plantage';

  @override
  String get privacyCrashHint => 'la trace de l\'erreur, sans les données du journal';

  @override
  String get privacyDiaryHead => 'Ton journal reste à toi';

  @override
  String get privacyDiarySub => 'ni les repas ni le poids ne vont dans les statistiques';

  @override
  String get privacyHealthHead => 'Les données de santé ne vont à personne';

  @override
  String get privacyHealthSub => 'les allergies et les médicaments ne quittent pas l\'app';

  @override
  String get privacyNoPhotosHead => 'Les photos de repas ne sont pas conservées';

  @override
  String get privacyNoPhotosSub => 'la photo est lue puis disparaît';

  @override
  String get privacyNotCollected => 'Ce que nous ne collectons pas';

  @override
  String get privacyOptional => 'Ce que tu peux désactiver';

  @override
  String get privacyPhotosBold => 'ne sont pas conservées';

  @override
  String get privacyPhotosHead => 'Les photos de repas ';

  @override
  String get privacyPhotosTail =>
      ' : la photo part en traitement et disparaît. Les statistiques ne voient jamais les plats, le poids, les allergies ni les médicaments. C\'est une catégorie particulière de données personnelles, et la donner à un tiers est hors de question, aussi pratique que ce serait.';

  @override
  String get privacyStats => 'Statistiques anonymes';

  @override
  String get privacyStatsHint => 'quels écrans sont ouverts, sans le contenu des entrées';

  @override
  String get privacyTitle => 'Confidentialité';

  @override
  String get profileActivity => 'Activité';

  @override
  String get profileAge => 'Âge';

  @override
  String get profileHeight => 'Taille';

  @override
  String get profileSex => 'Sexe';

  @override
  String rcAllergyWarn(String names) {
    return 'Contient $names, qui est sur ta liste d\'allergies. Fais attention avec celle-là.';
  }

  @override
  String get rcAsk => 'Demander une recette à Nora';

  @override
  String get rcAskAbout => 'Interroger Nora sur cette recette';

  @override
  String get rcAskCancel => 'Annuler';

  @override
  String get rcAskGo => 'Demander';

  @override
  String get rcAskPlaceholder => 'poulet, brocoli, riz';

  @override
  String get rcAskTitle => 'Qu\'est-ce qu\'il y a dans la cuisine ?';

  @override
  String get rcAsking => 'Je réfléchis…';

  @override
  String rcChatGreet(String name) {
    return 'Pose tes questions sur «$name» : quoi remplacer, comment ne pas la rater, quoi préparer à l\'avance.';
  }

  @override
  String get rcChatPlaceholder => 'Pose une question sur cette recette';

  @override
  String rcCount(int n) {
    return '$n recettes';
  }

  @override
  String rcCountFew(int n) {
    return '$n recettes';
  }

  @override
  String get rcCountOne => '1 recette';

  @override
  String rcDeleteBody(String name) {
    return '«$name» quitte le carnet. Les entrées du journal faites à partir d\'elle restent.';
  }

  @override
  String get rcDeleteCta => 'Supprimer';

  @override
  String get rcDeleteFailed => 'La suppression n\'a pas marché. Réessaie.';

  @override
  String get rcDeleteTitle => 'Supprimer cette recette ?';

  @override
  String get rcEmpty =>
      'Il n\'y a rien ici pour l\'instant. Dis à Nora ce qu\'il y a dans la cuisine et la première recette apparaît.';

  @override
  String get rcEmptyMine =>
      'Pas encore de recettes à toi. Dicte-en une à Nora et elle atterrit ici.';

  @override
  String get rcEyebrow => 'La cuisine';

  @override
  String get rcFromMine => 'À moi';

  @override
  String get rcFromNora => 'De Nora';

  @override
  String get rcHeroA => 'Quoi cuisiner';

  @override
  String get rcHeroB => 'aujourd\'hui';

  @override
  String get rcHeroLede =>
      'Dis ce que tu as à la maison. Nora propose et calcule la portion ; ta propre recette marche aussi.';

  @override
  String get rcItemsHead => 'Ingrédients';

  @override
  String rcItemsTotal(int g) {
    return 'au total $g g';
  }

  @override
  String get rcJustNow => 'à l\'instant';

  @override
  String get rcLoadFailed => 'Le carnet de recettes n\'a pas chargé. Tire pour réessayer.';

  @override
  String rcMinutes(int n) {
    return '$n min';
  }

  @override
  String get rcNoTools => 'Rien de plus qu\'un couteau et un saladier';

  @override
  String rcOfDay(int p) {
    return 'soit $p% du repère journalier';
  }

  @override
  String get rcPerServing => 'par portion';

  @override
  String get rcPerServingHead => 'Par portion';

  @override
  String get rcPickTitle => 'Choisis un plat';

  @override
  String rcPortion(int g) {
    return 'portion $g g';
  }

  @override
  String rcServingsFew(int n) {
    return '$n portions';
  }

  @override
  String rcServingsMany(int n) {
    return '$n portions';
  }

  @override
  String get rcServingsOne => '1 portion';

  @override
  String get rcStepsHead => 'Comment la faire';

  @override
  String get rcSuggestFailed => 'Nora n\'a pas pu composer de recettes. Réessaie.';

  @override
  String get rcTabAll => 'Toutes';

  @override
  String get rcTabMine => 'Les miennes';

  @override
  String get rcTabNora => 'De Nora';

  @override
  String get rcTitle => 'Recettes';

  @override
  String get rcToolBlender => 'Blender';

  @override
  String get rcToolGrill => 'Gril';

  @override
  String get rcToolMixer => 'Batteur';

  @override
  String get rcToolOven => 'Four';

  @override
  String get rcToolPan => 'Poêle';

  @override
  String get rcToolPot => 'Casserole';

  @override
  String get rcToolsHead => 'Ce qu\'il faut en cuisine';

  @override
  String rcWhole(int kcal, int g) {
    return 'Plat entier : $kcal kcal, $g g';
  }

  @override
  String get remAbout => 'À quel sujet';

  @override
  String get remAdd => 'Ajouter un rappel';

  @override
  String get remAt => 'À';

  @override
  String get remDelete => 'Supprimer le rappel';

  @override
  String get remEdit => 'Rappel';

  @override
  String get remEmpty => 'Pas encore de rappels.';

  @override
  String get remEmptyHint => 'Ajoute la seule chose que tu oublies vraiment, pas tout d\'un coup';

  @override
  String get remHowOften => 'À quelle fréquence';

  @override
  String get remName => 'Nom';

  @override
  String get remNew => 'Nouveau rappel';

  @override
  String get remOpenMeds => 'Ouvrir les médicaments';

  @override
  String get remTime => 'Heure';

  @override
  String get remTitle => 'Rappels';

  @override
  String get reminderBodyMeal => 'Note ce que c\'était';

  @override
  String get reminderBodyMeds => 'Selon l\'horaire';

  @override
  String get reminderBodySummary => 'Qu\'est-ce que tu n\'as pas noté aujourd\'hui ?';

  @override
  String get reminderBodyWater => 'C\'est l\'heure de boire';

  @override
  String get reminderBodyWeigh => 'Le matin, avant de manger';

  @override
  String get reminderBodyWorkout => 'Note-le si ça a eu lieu';

  @override
  String get reminderMeal => 'Repas';

  @override
  String get reminderMealHint => 'je te rappelle de noter le repas';

  @override
  String get reminderMeds => 'Médicaments';

  @override
  String get reminderMedsHint => 'selon l\'horaire du journal';

  @override
  String get reminderSummary => 'Bilan du jour';

  @override
  String get reminderSummaryHint => 'en bref sur la journée avant de dormir';

  @override
  String get reminderWater => 'Eau';

  @override
  String get reminderWaterHint => 'je te rappelle de boire';

  @override
  String get reminderWeigh => 'Pesée';

  @override
  String get reminderWeighHint => 'pour que la courbe du poids ne se coupe pas';

  @override
  String get reminderWorkout => 'Entraînement';

  @override
  String get reminderWorkoutHint => 'je te rappelle celui qui est prévu';

  @override
  String get repDaily => 'tous les jours';

  @override
  String repEveryN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tous les $count jours',
    );
    return '$_temp0';
  }

  @override
  String get repEveryOther => 'un jour sur deux';

  @override
  String get repPickDaily => 'Tous les jours';

  @override
  String get repPickFromToday => 'Compté à partir d\'aujourd\'hui.';

  @override
  String get repPickInterval => 'Un jour sur deux';

  @override
  String get repPickNoDays => 'Aucun jour n\'est choisi, le rappel ne se déclenchera donc jamais.';

  @override
  String get repPickWeekdays => 'Jours de la semaine';

  @override
  String get repWeekdays => 'en semaine';

  @override
  String get repWeekends => 'le week-end';

  @override
  String get repWeekly => 'une fois par semaine';

  @override
  String get restoredBody1 =>
      'Ce compte attendait d\'être supprimé. La connexion a annulé cela : le journal, le profil et les réglages sont de nouveau sur ce téléphone.';

  @override
  String get restoredBody2 =>
      'Si tu veux quand même que le compte disparaisse, redemande la suppression dans les Réglages. Toute connexion avant notre confirmation annule la demande de la même façon.';

  @override
  String get restoredOk => 'Compris';

  @override
  String get restoredTitle => 'Tes données sont revenues';

  @override
  String get setAbout => 'À propos de l\'app';

  @override
  String get setAllergies => 'Allergies';

  @override
  String setAssistantLine(String name, int count) {
    return '$name, $count en mémoire';
  }

  @override
  String get setDeleteAccount => 'Supprimer le compte et les données';

  @override
  String get setFreeTierHead =>
      'Pour les défenseurs de l\'Ukraine, et pour celles et ceux qui servent dans les Forces armées, au Service national d\'urgence, chez DTEK, pour le personnel médical, les bénévoles et les enseignants des zones proches du front, l\'offre payante est ';

  @override
  String get setFreeTierHow => ' Comment l\'obtenir';

  @override
  String get setFreeTierShort =>
      'Pour les défenseurs de l\'Ukraine, et pour celles et ceux qui servent dans les Forces armées, au Service national d\'urgence, chez DTEK, pour le personnel médical, les bénévoles et les enseignants des zones proches du front, l\'offre payante est GRATUITE';

  @override
  String get setFreeTierTelegram => 'Écrire sur Telegram';

  @override
  String get setFreeTierTitle => 'Offre gratuite';

  @override
  String get setFreeTierWord => 'GRATUITE';

  @override
  String get setFreeTierWrite =>
      'Écris au développeur et l\'offre payante est activée le jour même.';

  @override
  String get setGoal => 'Objectif';

  @override
  String get setGoalKeep => 'garder le poids';

  @override
  String setGoalLine(String kg, String pace) {
    return '$kg kg, $pace/semaine';
  }

  @override
  String get setGroupAbout => 'À propos de toi';

  @override
  String get setGroupAccount => 'Compte';

  @override
  String get setGroupAssistant => 'Assistante';

  @override
  String get setGroupDocs => 'Documents';

  @override
  String get setGroupHealth => 'Santé';

  @override
  String get setLang => 'Langue';

  @override
  String get setMedical => 'Avertissement médical';

  @override
  String get setMeds => 'Médicaments';

  @override
  String get setNorm => 'Repère';

  @override
  String setNormLine(String kcal) {
    return '$kcal kcal';
  }

  @override
  String get setPlan => 'Abonnement';

  @override
  String get setPlanFree => 'Gratuit';

  @override
  String get setPolicy => 'Politique de confidentialité';

  @override
  String get setPrivacy => 'Données et statistiques';

  @override
  String get setProfile => 'Profil';

  @override
  String setProfileLine(String sex, int age, int height) {
    return '$sex, $age, $height cm';
  }

  @override
  String get setReminders => 'Rappels';

  @override
  String get setRemindersOff => 'désactivés';

  @override
  String get setTerms => 'Conditions d\'utilisation';

  @override
  String get setTheme => 'Thème';

  @override
  String get setTitle => 'Réglages';

  @override
  String get setUnset => 'non défini';

  @override
  String get sexOther => 'Autre';

  @override
  String get sexShortFemale => 'F';

  @override
  String get sexShortMale => 'H';

  @override
  String get slotBreakfast => 'Petit-déjeuner';

  @override
  String get slotByHand => 'Mets les chiffres toi-même';

  @override
  String get slotCancel => 'Annuler';

  @override
  String get slotDinner => 'Dîner';

  @override
  String slotEraseBody(String name) {
    return '«$name» n\'a pas encore de chiffres. La ligne quitte la journée.';
  }

  @override
  String get slotEraseDo => 'Retirer';

  @override
  String get slotEraseTitle => 'Retirer le brouillon ?';

  @override
  String get slotGrams => 'POIDS, G';

  @override
  String get slotIntoBreakfast => 'au petit-déjeuner';

  @override
  String get slotIntoDinner => 'au dîner';

  @override
  String get slotIntoLunch => 'au déjeuner';

  @override
  String slotIntoOther(String name) {
    return 'dans «$name»';
  }

  @override
  String get slotIntoSnack => 'dans la collation';

  @override
  String get slotKcal => 'KCAL';

  @override
  String get slotLog => 'Noter';

  @override
  String get slotLunch => 'Déjeuner';

  @override
  String get slotSnack => 'Collation';

  @override
  String get slotWriteWhat => 'Écris ce que c\'était';

  @override
  String get startAbout => 'À propos de toi';

  @override
  String get startAge => 'Âge';

  @override
  String startAgeYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ans',
      one: '1 an',
    );
    return '$_temp0';
  }

  @override
  String get startAgreeAnd => ' et la ';

  @override
  String get startAgreeHead => 'J\'accepte les ';

  @override
  String get startAgreePrivacy => 'politique de confidentialité';

  @override
  String get startAgreeTerms => 'conditions d\'utilisation';

  @override
  String get startAllergies => 'Allergies';

  @override
  String get startDeviceFirstRun => 'premier lancement';

  @override
  String get startGoal => 'Où on va';

  @override
  String get startGoalGain => 'Prendre du poids';

  @override
  String get startGoalGainHint => 'un surplus au rythme que tu choisis';

  @override
  String get startGoalKeep => 'Garder le poids';

  @override
  String get startGoalKeepHint => 'tu remets exactement ce que tu dépenses';

  @override
  String get startGoalLose => 'Perdre du poids';

  @override
  String get startGoalLoseHint => 'un déficit au rythme que tu choisis';

  @override
  String get startHeight => 'Taille';

  @override
  String get startLife => 'Mode de vie';

  @override
  String get startNorm => 'Ton repère';

  @override
  String get startNormHold => 'à tenir';

  @override
  String get startNormNora => 'C\'est calculé. À partir d\'ici, c\'est plus simple.';

  @override
  String get startNormNoraHint =>
      'Écris-le ou dis-le comme ça vient : «deux œufs et une tartine», «bu 300 d\'eau». Ce qu\'il me manque, je te le demande dans la conversation.';

  @override
  String get startNormNote =>
      'C\'est la formule de Mifflin-St Jeor, pas un avis médical. Si tu as une pathologie, si tu es enceinte ou si tu suis un régime prescrit, parles-en à ton médecin.';

  @override
  String get startNormPerDay => 'kcal par jour';

  @override
  String get startNormWeeks => 'semaines';

  @override
  String get startPace => 'À quel rythme';

  @override
  String get startPaceEtaHead => 'Objectif vers le ';

  @override
  String get startPaceEtaTail => ', soit ';

  @override
  String get startPaceFast => 'rapide';

  @override
  String get startPaceSlow => 'lent';

  @override
  String get startPaceUnit => 'kg par semaine';

  @override
  String get startPaceUsual => 'régulier';

  @override
  String get startPaceWarning =>
      'Un rythme pareil est dur à tenir et casse en général. En dessous de 0,8 kg par semaine le résultat vient plus lentement, mais il reste.';

  @override
  String startPaceWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count semaines',
      one: '1 semaine',
    );
    return '$_temp0';
  }

  @override
  String get startSex => 'Sexe';

  @override
  String get startSexFemale => 'Femme';

  @override
  String get startSexMale => 'Homme';

  @override
  String get startSexOther => 'Autre';

  @override
  String get startSignInApple => 'Continuer avec Apple';

  @override
  String get startSignInBackText =>
      'Connecte-toi avec le même compte et tout revient : le journal, l\'objectif, le repère et les mesures. Rien à remplir de nouveau.';

  @override
  String get startSignInBackTitle => 'Content de te revoir';

  @override
  String get startSignInBusy => 'Connexion…';

  @override
  String get startSignInFailed =>
      'La connexion n\'a pas marché. Réessaie, ou continue sans compte.';

  @override
  String startSignInFailedWhy(String why) {
    return 'La connexion n\'a pas marché. $why';
  }

  @override
  String get startSignInGoogle => 'Continuer avec Google';

  @override
  String get startSignInSkip => 'Continuer sans compte';

  @override
  String get startSignInText =>
      'Le repère est calculé. Connecte-toi pour le garder : l\'historique, les mesures et les entrées seront sur tous tes appareils, pas seulement ici.';

  @override
  String get startSignInTitle => 'Gardons tout ça';

  @override
  String get startTargetWeight => 'Poids visé';

  @override
  String get startWeightNow => 'Poids actuel';

  @override
  String get startYearsShort => 'ans';

  @override
  String get storageBroken =>
      'Je n\'ai pas pu ouvrir le stockage. Tes entrées sont en sécurité, mais là il n\'y a rien pour les afficher.';

  @override
  String get themeAquarelle => 'Aquarelle';

  @override
  String get themeAquarelleHint => 'claire, avec des nuages pastel en fond';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeDarkHint => 'toujours l\'interface sombre';

  @override
  String get themeDawn => 'Aube';

  @override
  String get themeDawnHint => 'claire, avec une lumière chaude de côté';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeLightHint => 'toujours l\'interface claire';

  @override
  String get themeSectionLook => 'Apparence';

  @override
  String get themeSystem => 'Thème de l\'appareil';

  @override
  String get themeSystemHint => 'suit le réglage du système';

  @override
  String get todayBarcode => 'Code-barres';

  @override
  String todayCodeTalk(String code) {
    return 'J\'ai scanné le code-barres $code et aucune base ne le connaît. Ne note rien : demande-moi ce qu\'est ce produit ou dis-moi comment le compter.';
  }

  @override
  String get todayDone => 'Terminé.';

  @override
  String get todayFailedRetry => 'Ça n\'a pas marché. Réessaie dans une minute.';

  @override
  String todayHowManyGrams(String dish) {
    return 'Ça faisait combien de grammes, $dish ?';
  }

  @override
  String get todayLogFailed => 'Je n\'ai pas pu le noter. Réessaie.';

  @override
  String get todayLogged => 'Noté.';

  @override
  String todayLoggedAskWeight(String slotInto) {
    return 'Noté $slotInto. Dis-moi le poids si tu le veux précis.';
  }

  @override
  String get todayLoggedAskWeightShort => 'Noté. Dis-moi le poids si tu le veux précis.';

  @override
  String todayLoggedCount(int count) {
    return '$count notés';
  }

  @override
  String todayLoggedInto(String slotInto, String dish) {
    return 'Noté $slotInto : $dish.';
  }

  @override
  String todayLoggedIntoWithNumbers(String slotInto, String dish, int kcal, int grams) {
    return 'Noté $slotInto : $dish, $kcal kcal pour $grams g.';
  }

  @override
  String get todayNoraSlow =>
      'Nora réfléchit plus longtemps que d\'habitude. Réessaie, le jeton n\'a pas été dépensé.';

  @override
  String get todayOffline => 'Pas de connexion. Réessaie quand elle revient.';

  @override
  String get todayOfflineSaved =>
      'Pas de connexion. L\'entrée reste sur le téléphone et monte dès qu\'elle revient.';

  @override
  String get todayOutOfTokens => 'Plus de jetons. Noter à la main marche toujours.';

  @override
  String get todayPhotoMeal => 'Photo';

  @override
  String get todayQuestionClosed =>
      'Cette question est déjà close. Dis le poids avec des mots si besoin.';

  @override
  String get tourCamera => 'Appareil photo';

  @override
  String get tourCameraHow => 'une assiette, une étiquette ou un code-barres';

  @override
  String get tourDiary => 'Mémoire du journal';

  @override
  String get tourDiaryHow => 'dis « bortsch » et elle prend ta portion habituelle';

  @override
  String get tourGuide => 'Guide de l\'app';

  @override
  String get tourGuideHow => 'demande où se trouve quoi et comment faire';

  @override
  String get tourMemory => 'Mémoire durable';

  @override
  String get tourMemoryHow => '« je ne mange pas de porc » suffit une fois';

  @override
  String get tourMore => 'Pas seulement la nourriture';

  @override
  String get tourMoreHow => 'eau, séances, mesures, recettes';

  @override
  String get tourTitle => 'Ce que Nora sait faire';

  @override
  String get tourVoice => 'Voix ou texte';

  @override
  String get tourVoiceHow => '« deux œufs et un toast », et c\'est noté';

  @override
  String get tourWeek => 'Bilan du jour et de la semaine';

  @override
  String get tourWeekHow => 'ce qui a marché et ce qu\'il faut ajuster';

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
  String get unitsEnergy => 'Énergie';

  @override
  String get unitsLength => 'Taille et mensurations';

  @override
  String get unitsMass => 'Poids du corps';

  @override
  String get unitsPortion => 'Portions';

  @override
  String get unitsTitle => 'Quelles unités';

  @override
  String get unitsVolume => 'Eau';

  @override
  String waterGlasses(int glasses) {
    return 'environ $glasses verres';
  }

  @override
  String waterLess(int step) {
    return '$step ml de moins';
  }

  @override
  String waterMore(int step) {
    return '$step ml de plus';
  }

  @override
  String get waterNone => 'rien bu';

  @override
  String waterOf(String ml) {
    return ' / $ml ml';
  }

  @override
  String waterShare(int pct) {
    return '$pct% de l\'objectif du jour';
  }

  @override
  String get waterTitle => 'Eau';

  @override
  String get wcNoTime => 'sans durée';

  @override
  String get wdFri => 'Ven';

  @override
  String get wdMon => 'Lun';

  @override
  String get wdSat => 'Sam';

  @override
  String get wdSun => 'Dim';

  @override
  String get wdThu => 'Jeu';

  @override
  String get wdTue => 'Mar';

  @override
  String get wdWed => 'Mer';

  @override
  String get weightHint =>
      'Ce que tu pèses aujourd\'hui. L\'objectif et le rythme pour y aller vivent ailleurs.';

  @override
  String get weightNote =>
      'Pèse-toi le matin, avant de manger : comme ça les écarts de la journée ne transforment pas le graphique en bruit. Une mesure par semaine, c\'est déjà une tendance.';

  @override
  String get weightTitle => 'Poids';

  @override
  String get welEggs => 'Deux œufs au plat';

  @override
  String get welEggsGrams => '120 g';

  @override
  String get welHaveAccount => 'J\'ai déjà un compte';

  @override
  String get welLead => 'Compte les calories à partir de tes propres mots';

  @override
  String get welSaid => 'J\'ai mangé deux œufs et une tartine';

  @override
  String get welStart => 'C\'est parti';

  @override
  String get welToast => 'Tartine avec du beurre';

  @override
  String get welToastGrams => '50 g';

  @override
  String get welTotal => 'Au total';

  @override
  String get wfBurned => 'Brûlées, kcal';

  @override
  String get wfDuration => 'Durée';

  @override
  String get wfDurationCap => 'Durée, min';

  @override
  String get wfEstimate => 'Une estimation à partir de ton poids et du type d\'activité';

  @override
  String get wfFromWatch => 'D\'une montre ou d\'une machine';

  @override
  String get wfKcal => ' kcal';

  @override
  String get wfLog => 'Noter';

  @override
  String get wfManualKcal => 'kcal à la main';

  @override
  String wfMin(int min) {
    return '$min min';
  }

  @override
  String get wfMinutes => 'Minutes';

  @override
  String get wfNote => 'Note';

  @override
  String get wfNoteExample => 'Jambes, dur';

  @override
  String get wfOptional => '  facultatif';

  @override
  String get wheelLess => 'Moins';

  @override
  String get wheelMore => 'Plus';

  @override
  String get wkDaysOk => 'jours dans l\'objectif';

  @override
  String get wkEmpty =>
      'Rien n\'est encore noté cette semaine. Note le premier jour et l\'image apparaît.';

  @override
  String get wkFactsHead => 'La semaine au total';

  @override
  String get wkKcalHead => 'Calories';

  @override
  String get wkLoggedCap => 'jours notés';

  @override
  String wkLoggedValue(int n) {
    return '$n sur 7';
  }

  @override
  String get wkMacroHead => 'Macros';

  @override
  String get wkNoWeight => 'poids : aucune pesée';

  @override
  String get wkNoraBtn => 'Créer le bilan';

  @override
  String wkNoraFailed(String why) {
    return 'Je n\'ai pas pu créer le bilan : $why';
  }

  @override
  String get wkNoraGreet =>
      'Demande ce que tu veux sur cette lecture : un plat, une habitude, ou ce qu\'il faut corriger en premier.';

  @override
  String get wkNoraLoading => 'Nora lit la semaine…';

  @override
  String get wkNoraLocked => 'Le bilan s\'ouvre vendredi';

  @override
  String get wkNoraNoNet => 'pas de réseau';

  @override
  String get wkNoraNoTokens => 'plus de jetons';

  @override
  String get wkNoraP1 =>
      'Ta base est saine, et c\'est rare : presque tout est fait maison. Soupe, œufs brouillés, flocons d\'avoine : sur une base pareille, le reste se corrige vite.';

  @override
  String get wkNoraP2 =>
      'Maintenant, franchement. Les légumes ne sont presque pas apparus de la semaine, alors que le sucré revenait chaque jour : crêpes au miel, compote. Les protéines manquent non parce que tu manges peu, mais parce que l\'assiette est lourde en glucides et légère en viande, poisson ou fromage. Et trois dîners sur sept sont tombés après vingt-deux heures.';

  @override
  String get wkNoraP3 =>
      'Rien de grave pour l\'instant, mais c\'est exactement l\'alimentation qui surprend aux analyses à quarante ans. Un pas pour la semaine prochaine, sans rien changer d\'autre : quelque chose de vert à chaque déjeuner, et de l\'eau à la place de la compote.';

  @override
  String get wkNoraPlaceholder => 'Pose une question sur cette semaine';

  @override
  String get wkNoraPromise =>
      'Une lecture honnête de ta semaine : ce qui a marché, ce qui a glissé, et un pas pour la suivante.';

  @override
  String get wkNoraReply1 =>
      'L\'échange le plus facile cette semaine : de l\'eau à la place de la compote. Une cuillère de sucre en moins à chaque fois, et la soupe n\'y perd rien.';

  @override
  String get wkNoraReply2 =>
      'Du vert au déjeuner, ce n\'est pas forcément une salade. Un concombre ou un demi-poivron à côté de l\'assiette font déjà l\'affaire.';

  @override
  String get wkNoraSlow => 'le serveur prend trop de temps';

  @override
  String get wkNoraTalk => 'En parler avec Nora';

  @override
  String get wkNoraTitle => 'Nora sur ta semaine';

  @override
  String get wkNorm => 'objectif';

  @override
  String wkOffNorm(String n) {
    return '$n hors objectif';
  }

  @override
  String get wkPastEmpty =>
      'Pas encore de bilans passés. Le premier apparaîtra ici lundi prochain.';

  @override
  String wkPastRow(String day) {
    return 'Semaine du $day';
  }

  @override
  String get wkPastTitle => 'Semaines passées';

  @override
  String get wkPerDay => 'kcal par jour en moyenne';

  @override
  String get wkPerDayAside => 'par jour en moyenne';

  @override
  String get wkTitle => 'La semaine';

  @override
  String get wkTotalCap => 'kcal dans la semaine';

  @override
  String get wkWaterCap => 'd\'eau par jour';

  @override
  String wkWaterValue(String l) {
    return '$l l';
  }

  @override
  String get wkWeightCap => 'poids cette semaine';

  @override
  String get workoutAdd => 'Ajouter un entraînement';

  @override
  String workoutBurned(int kcal) {
    return '−$kcal kcal';
  }

  @override
  String get workoutCollapse => 'Replier';

  @override
  String get workoutMinUnit => 'min';

  @override
  String get workoutNone => 'rien de noté';

  @override
  String workoutSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count séances',
      one: '1 séance',
    );
    return '$_temp0';
  }

  @override
  String get workoutTitle => 'Entraînement';
}
