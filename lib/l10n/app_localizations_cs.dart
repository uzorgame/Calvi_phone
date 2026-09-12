// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class LCs extends L {
  LCs([String locale = 'cs']) : super(locale);

  @override
  String get aboutContact => 'Kontakt';

  @override
  String get aboutDeveloper => 'Vývojář';

  @override
  String get aboutText =>
      'Deník jídla, který rozumí obyčejným větám. Nora dělá počty, rozhodnutí zůstávají tvoje.';

  @override
  String get aboutTitle => 'O aplikaci';

  @override
  String get aboutVersion => 'Verze';

  @override
  String get aboutWrite => 'Napiš nám';

  @override
  String get accessAsk => 'zatím nežádáno';

  @override
  String get accessCamera => 'Fotoaparát';

  @override
  String get accessMic => 'Mikrofon';

  @override
  String get accessNote =>
      'Mikrofon a rozpoznávání řeči jsou potřeba na diktování, a rozpoznávání slouží i hodinkám: ty nahrají, co řekneš, a telefon z toho udělá slova. Klepnutím na řádek přístup povolíš, nebo otevřeš nastavení systému a vypneš ho.';

  @override
  String get accessNotify => 'Oznámení';

  @override
  String get accessOff => 'zakázáno';

  @override
  String get accessOn => 'povoleno';

  @override
  String get accessSpeech => 'Rozpoznávání řeči';

  @override
  String get accountBusy => 'Přihlašuji…';

  @override
  String get accountGoogle => 'Pokračovat přes Google';

  @override
  String get accountKeepCloud => 'Ten z účtu';

  @override
  String get accountNoAccountNote =>
      'Deník žije jen v tomto telefonu. Vyměň telefon nebo smaž aplikaci a záznamy nebude jak vrátit: nevíme, čí jsou.';

  @override
  String get accountScopeNote =>
      'Ptáme se jen na e-mail. Google nám nepředává jméno, profilovou fotku ani kontakty.';

  @override
  String get accountSettingsDevice => 'nastavení';

  @override
  String get accountSignInFailed => 'Přihlášení se nepovedlo.';

  @override
  String accountSignInFailedWhy(String why) {
    return 'Přihlášení se nepovedlo. $why';
  }

  @override
  String get accountSignOut => 'Odhlásit se';

  @override
  String get accountSignOutAction => 'Odhlásit se';

  @override
  String get accountSignOutAsk => 'Odhlásit se?';

  @override
  String get accountSignOutBack =>
      'Přihlas se stejným účtem a všechno se vrátí. Co bylo zapsáno offline a nestihlo dojít na server, obnovit nejde.';

  @override
  String get accountSignOutNote =>
      'Tento telefon se vymaže: deník, profil, léky i rozhovor s Norou. Tvé záznamy zůstanou na serveru, pod tvým účtem.';

  @override
  String get accountSince => 'S Calvi od';

  @override
  String get accountTitle => 'Účet';

  @override
  String get accountVia => 'Přihlášeno přes Google';

  @override
  String get accountViaApple => 'Přihlášeno přes Apple';

  @override
  String get accountViaEmail => 'Přihlášeno e-mailem';

  @override
  String get accountWatch => 'Apple Watch';

  @override
  String get accountWhichDiary => 'Který deník si necháme?';

  @override
  String get accountWhichDiaryNote =>
      'Na tomto účtu už záznamy jsou, a v telefonu taky. Zůstat může jen jeden: ten z účtu, nebo ten z telefonu. Druhý zmizí.';

  @override
  String get actBasketball => 'Basketbal';

  @override
  String get actBike => 'Kolo';

  @override
  String get actDance => 'Tanec';

  @override
  String get actFootball => 'Fotbal';

  @override
  String get actGym => 'Posilovna';

  @override
  String get actHiit => 'HIIT';

  @override
  String get actJumprope => 'Švihadlo';

  @override
  String get actRun => 'Běh';

  @override
  String get actSki => 'Lyžování';

  @override
  String get actStretch => 'Protahování';

  @override
  String get actSwim => 'Plavání';

  @override
  String get actTennis => 'Tenis';

  @override
  String get actWalk => 'Chůze';

  @override
  String get actYoga => 'Jóga';

  @override
  String get actionAdd => 'Přidat';

  @override
  String get actionBack => 'Zpět';

  @override
  String get actionCancel => 'Zrušit';

  @override
  String get actionClose => 'Zavřít';

  @override
  String get actionDelete => 'Smazat';

  @override
  String get actionDone => 'Hotovo';

  @override
  String get actionGotIt => 'Rozumím';

  @override
  String get actionNext => 'Dál';

  @override
  String get actionSave => 'Uložit';

  @override
  String get activityHigh => 'Vysoká';

  @override
  String get activityHighHint => '5-6 tréninků';

  @override
  String get activityLight => 'Lehce aktivní';

  @override
  String get activityLightHint => '1-2 tréninky týdně';

  @override
  String get activityModerate => 'Střední';

  @override
  String get activityModerateHint => '3-4 tréninky';

  @override
  String get activitySedentary => 'Sedavý';

  @override
  String get activitySedentaryHint => 'téměř žádný pohyb';

  @override
  String get activityVeryHigh => 'Velmi vysoká';

  @override
  String get activityVeryHighHint => 'fyzická práce nebo sport každý den';

  @override
  String agoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'před $count dny',
      few: 'před $count dny',
      one: 'před 1 dnem',
    );
    return '$_temp0';
  }

  @override
  String get agoToday => 'dnes';

  @override
  String get agoWeek => 'před týdnem';

  @override
  String agoWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'před $count týdny');
    return '$_temp0';
  }

  @override
  String get agoYesterday => 'včera';

  @override
  String get allergyConfirm => 'Potvrdit';

  @override
  String get allergyMild => 'Mírná';

  @override
  String get allergyMildHint => 'Upozorním v textu, zápis nezablokuji.';

  @override
  String get allergyMildShort => 'mírná';

  @override
  String get allergyNote =>
      'Pokud složení produktu v databázi není, nemlčím a neberu to jako bezpečné: zvlášť řeknu, že složení neznám.';

  @override
  String get allergyNothing =>
      'Nic nenalezeno. Pokud alergen v seznamu není, řekni to Noře: přidáme ho do číselníku, aby fungoval všem, místo aby zůstal textem u jednoho člověka.';

  @override
  String get allergyRemove => 'Odebrat';

  @override
  String allergySearch(int count) {
    return 'Hledat mezi $count alergeny';
  }

  @override
  String get allergySevere => 'Těžká';

  @override
  String get allergySevereHint => 'Před zápisem se zastavím a řeknu to natvrdo.';

  @override
  String get allergySevereShort => 'těžká';

  @override
  String get allergyTitle => 'Alergie';

  @override
  String anChartGoal(String value) {
    return 'cíl $value';
  }

  @override
  String get anDaysInNorm => 'dní v normě';

  @override
  String anDonePercent(int percent) {
    return 'hotovo $percent %';
  }

  @override
  String anEtaHead(String date) {
    return 'Při současném tempu je cíl kolem *$date*';
  }

  @override
  String get anForMonth => 'za měsíc';

  @override
  String get anForQuarter => 'za 3 měsíce';

  @override
  String get anForYear => 'za rok';

  @override
  String get anGoalProgress => 'Postup k cíli';

  @override
  String get anKcal => 'Kalorie';

  @override
  String get anKcalAvg => 'průměrně za den';

  @override
  String get anKcalEmpty =>
      'Za toto období zatím nic nezapsáno. Řekni Noře, co jíš, a graf se postaví sám.';

  @override
  String anKcalTotal(Object u) {
    return 'za období, $u';
  }

  @override
  String anMacroGoal(String grams) {
    return 'norma $grams';
  }

  @override
  String get anMacrosAvg => 'Makra v průměru';

  @override
  String get anMacrosEmpty =>
      'Průměr se objeví, jakmile bude z čeho počítat: zapiš aspoň jeden den.';

  @override
  String get anMeasures => 'Míry';

  @override
  String anMeasuresChange(String period) {
    return 'změna $period';
  }

  @override
  String get anMeasuresEmpty => 'Zatím žádné míry.';

  @override
  String get anMeasuresEmptyHint => 'Změř se jednou za měsíc a ukážu ti, co se hýbe';

  @override
  String get anMonth => 'Měsíc';

  @override
  String get anNow => 'teď';

  @override
  String anNowKg(Object u) {
    return 'teď, $u';
  }

  @override
  String get anOneReading => 'jeden záznam';

  @override
  String get anOneWeighing => 'Zatím jeden záznam. Druhý ukáže směr a od něj se čára rozjede.';

  @override
  String get anPerDay => 'za den';

  @override
  String get anQuarter => '3 měsíce';

  @override
  String anShareOfNorm(int share) {
    return '$share % normy';
  }

  @override
  String anStartKg(Object u) {
    return 'start, $u';
  }

  @override
  String anTargetKg(Object u) {
    return 'cíl, $u';
  }

  @override
  String get anTitle => 'Analýza';

  @override
  String get anWater => 'Pitný režim';

  @override
  String anWaterAvg(Object u) {
    return 'průměrně, $u';
  }

  @override
  String anWaterGoal(String ml) {
    return 'norma $ml';
  }

  @override
  String get anWeek => 'Týden';

  @override
  String get anWeightEmpty =>
      'Křivka se objeví po druhém vážení. Řekni Noře svou váhu a zapíše ji sama.';

  @override
  String get anYear => 'Rok';

  @override
  String get assistantAddMemory => 'Přidat do paměti';

  @override
  String get assistantCollapse => 'Sbalit';

  @override
  String get assistantExample => 'Například: houby nejím';

  @override
  String get assistantForget => 'Zapomenout';

  @override
  String assistantHint(String name) {
    return '$name vede deník s tebou a pamatuje si, co jí o sobě řekneš.';
  }

  @override
  String get assistantMemory => 'Paměť';

  @override
  String get assistantMemoryEmpty => 'Zatím nic zapamatováno.';

  @override
  String get assistantMemoryEmptyHint => 'Paměť vzniká z rozhovorů, nebo něco přidej ručně';

  @override
  String assistantPinned(int count, int pinned) {
    return '$count, $pinned připnuto';
  }

  @override
  String get assistantTitle => 'Asistentka';

  @override
  String get assistantWhatToRemember => 'Co si zapamatovat';

  @override
  String get authAgain => 'Potvrzení hesla';

  @override
  String get authAgainDiffers => 'Hesla se neshodují';

  @override
  String get authAgainEmpty => 'Zopakuj heslo';

  @override
  String get authAgainHint => 'ještě jednou';

  @override
  String authAgainIn(int sec) {
    return 'Znovu možné za $sec s';
  }

  @override
  String get authCode => 'Kód z e-mailu';

  @override
  String get authCodeAction => 'Potvrdit';

  @override
  String get authCodeBad => 'Tenhle kód nesedí, nebo mu vypršela platnost';

  @override
  String authCodeHint(String mail) {
    return 'Poslali jsme kód na $mail. Napiš šest číslic z e-mailu.';
  }

  @override
  String get authCodeShort => 'Kód má 6 číslic';

  @override
  String get authCodeTitle => 'Potvrď svůj e-mail';

  @override
  String get authForgotAction => 'Poslat kód';

  @override
  String get authForgotHint => 'Pošleme kód na tvůj e-mail a pak si zvolíš nové heslo.';

  @override
  String get authForgotLink => 'Nepamatuješ si?';

  @override
  String get authForgotTitle => 'Nové heslo';

  @override
  String get authMail => 'E-mail';

  @override
  String get authMailBad => 'Ta adresa vypadá divně';

  @override
  String get authOr => 'nebo';

  @override
  String get authPass => 'Heslo';

  @override
  String get authPassEmpty => 'Zadej heslo';

  @override
  String get authPassHint => '5 písmen a znak';

  @override
  String get authPassNew => 'Nové heslo';

  @override
  String get authPassWeak => 'Slabé heslo: aspoň 5 písmen a jedna číslice nebo znak';

  @override
  String get authResetAction => 'Uložit heslo';

  @override
  String get authSendAgain => 'Poslat znovu';

  @override
  String get authSignInAction => 'Přihlásit se';

  @override
  String get authSignInTitle => 'Přihlášení';

  @override
  String get authSignUpAction => 'Vytvořit účet';

  @override
  String get authSignUpLink => 'Vytvořit účet';

  @override
  String get authSignUpTitle => 'Založíme si účet';

  @override
  String get barCamera => 'Fotoaparát';

  @override
  String barGrams(String grams) {
    return '$grams';
  }

  @override
  String get barHint => 'Ahoj, jsem Nora. Piš nebo mluv jako vždycky a já ti porozumím.';

  @override
  String get barHintBorscht => 'Boršč 300 g k obědu';

  @override
  String get barHintDelete => 'Smaž poslední záznam';

  @override
  String get barHintEggs => 'Dvě vejce a toast';

  @override
  String get barHintMore =>
      '„dvě vejce a toast“, „vypil jsem 300 vody“, „běh 40 minut“: sama si to přeberu a dám do správné karty';

  @override
  String get barHintProtein => 'Kolik mi zbývá bílkovin?';

  @override
  String get barHintRun => 'Běh 40 minut';

  @override
  String get barHintWater => 'Vypil jsem 500 ml vody';

  @override
  String get barHintWeighed => 'Vážení: 78,8';

  @override
  String get barHintYesterday => 'Co jsem včera jedl?';

  @override
  String get barLogsInto => 'Zapisuji ';

  @override
  String get barMic => 'Mikrofon';

  @override
  String get barSend => 'Odeslat';

  @override
  String get camAgain => 'Znovu';

  @override
  String get camAllergen => 'Alergen!';

  @override
  String camAllergyContains(String list) {
    return 'Obsahuje tvůj alergen: $list';
  }

  @override
  String camAllergyTraces(String list) {
    return 'Může obsahovat stopy: $list';
  }

  @override
  String get camAskNoraInstead => 'Etiketu nemám, zeptám se Nory';

  @override
  String get camBarcode => 'Čárový kód';

  @override
  String get camBusy => 'Fotoaparát se neotevřel. Obvykle ho drží jiná aplikace.';

  @override
  String get camCouldNotRead => 'Snímek se nepodařilo přečíst';

  @override
  String get camDish => 'Foto';

  @override
  String camEstimate(Object u) {
    return ' $u, odhad';
  }

  @override
  String get camFlash => 'Blesk';

  @override
  String get camFromPack => 'Čísla z obalu. Zápis nestojí žádné tokeny.';

  @override
  String get camGallery => 'Z galerie';

  @override
  String get camGapNote => 'Tohle číslo nezná žádná databáze. Vyfoť etiketu a doplním ho.';

  @override
  String get camHintBarcode => 'kód do rámečku';

  @override
  String get camHintDish => 'namiř na talíř nebo na obal';

  @override
  String camIngredients(String text) {
    return 'Složení: $text';
  }

  @override
  String camIntoSlot(String slot) {
    return 'Zápis: $slot';
  }

  @override
  String camKcalFor(String grams, Object u) {
    return ' $u za $grams';
  }

  @override
  String camKcalPer(String grams, Object u) {
    return ' $u na $grams';
  }

  @override
  String get camLabelAim => 'miř na tabulku výživových hodnot';

  @override
  String get camLabelNoShot => 'Snímek se nepovedl. Zkus etiketu vyfotit znovu.';

  @override
  String get camLabelReading => 'Opisuji čísla z obalu…';

  @override
  String camLogInto(String slotInto) {
    return 'Zapsat $slotInto';
  }

  @override
  String get camNoPermission => 'Chybí povolení k fotoaparátu. Můžeš ho dát v nastavení telefonu.';

  @override
  String get camNoScanner => 'Tenhle telefon neumí číst kódy fotoaparátem.';

  @override
  String get camNoTokens => 'Došly tokeny';

  @override
  String get camNotAProduct => 'To není čárový kód produktu';

  @override
  String get camNotAProductNote =>
      'Načetl se odkaz nebo interní kód. Miř na pruhy s číslicemi pod nimi.';

  @override
  String get camNotRead => 'Nepodařilo se to rozluštit';

  @override
  String get camOffline => 'Kód se načetl, ale není se koho zeptat. Zkus to, až budeš online.';

  @override
  String get camOfflineShot => 'Není připojení. Snímek můžeš Noře poslat později';

  @override
  String get camOfflineTitle => 'Není síť';

  @override
  String get camPer100 => 'Na obalu není přesná váha: čísla jsou na 100 g.';

  @override
  String camPortionPack(String g) {
    return 'Porce z obalu: $g. Čísla jsou na porci.';
  }

  @override
  String get camReading => 'Čtu…';

  @override
  String get camSendToNora => 'Poslat Noře';

  @override
  String get camServerDown => 'Není to kódem ani fotoaparátem. Zkus to za minutu.';

  @override
  String get camServerDownTitle => 'Náš server neodpověděl';

  @override
  String get camShoot => 'Vyfotit';

  @override
  String get camShootLabel => 'Vyfotit etiketu';

  @override
  String get camShotFailed => 'Snímek se nepovedl';

  @override
  String get camShotReady => 'Snímek je hotový';

  @override
  String get camShotReadyNote =>
      'Nora ho přečte a odpoví v chatu: pojmenuje jídlo, odhadne porci a ukáže, odkud číslo vzala. Stojí to dva tokeny.';

  @override
  String get camSignedOut =>
      'Přihlášení už neplatí, takže nás databáze nepozná. Přihlas se znovu a skener bude fungovat.';

  @override
  String get camSignedOutTitle => 'Přihlas se prosím znovu';

  @override
  String get camSlow => 'Kód se načetl a databáze odpovídala příliš dlouho. Zkus to znovu.';

  @override
  String get camSlowTitle => 'Odpověď nedorazila';

  @override
  String get camStillWorks => 'Focení jídla a galerie fungují jako obvykle.';

  @override
  String get camTitle => 'Skener';

  @override
  String get camTookTooLong => 'Čtení trvalo příliš dlouho. Zkus to znovu';

  @override
  String get camUnknownCode => 'Tenhle produkt není v žádné databázi';

  @override
  String get camUnknownCodeNote =>
      'Není v naší ani v otevřené. Vyfoť tabulku výživových hodnot na obalu a čísla z ní opíšu. Je to zdarma.';

  @override
  String get chatPro => 'Pro';

  @override
  String get deleteAskBody1 =>
      'Tento telefon se vymaže hned: deník, profil, rozhovor s Norou i přihlášení. Aplikace se vrátí na první obrazovku.';

  @override
  String get deleteAskBody2 =>
      'Na serveru se účet zařadí k trvalému smazání, což trvá až 30 pracovních dní. Dokud to nepotvrdíme, přihlášení stejným účtem všechno vrátí a žádost zruší.';

  @override
  String get deleteAskCta => 'Ano, smazat';

  @override
  String get deleteAskTitle => 'Smazat účet?';

  @override
  String get deleteConfirm => 'Rozumím, že data budou smazána navždy a nejde je vrátit.';

  @override
  String get deleteDays => 'Dní s Calvi';

  @override
  String get deleteEntries => 'Záznamů v deníku';

  @override
  String deleteFailed(String why) {
    return 'Nepodařilo se smazat: $why';
  }

  @override
  String get deleteForever => 'Smazat navždy';

  @override
  String get deleteNote =>
      'Zmizí všechno: deník, váha, míry, alergie, léky, historie rozhovorů. Vrátit to nejde.';

  @override
  String get deleteProManage => 'Spravovat předplatné';

  @override
  String deleteProNote(String store) {
    return 'Smazání účtu neruší Calvi Pro. $store účtuje dál, dokud nezrušíš samotné předplatné, takže ho zruš ještě před smazáním účtu.';
  }

  @override
  String get deleteProStoreAny => 'Obchod';

  @override
  String get deleteSubNote =>
      'Pokud jde o předplatné, to se ruší zvlášť v App Store nebo Google Play, bez mazání účtu.';

  @override
  String get deleteTitle => 'Smazat účet';

  @override
  String get deleteWeighings => 'Vážení';

  @override
  String get dictationBusy => 'Mikrofon je obsazený. Zkus to znovu';

  @override
  String get dictationFailed => 'Diktování se nepovedlo';

  @override
  String get dictationNoMatch => 'Neslyšela jsem nic, čemu bych rozuměla';

  @override
  String get dictationNoNetwork => 'Rozpoznávání potřebuje síť';

  @override
  String get dictationNoPermission => 'Chybí povolení k mikrofonu';

  @override
  String get dictationSilence => 'Ticho. Zkus to znovu, blíž k mikrofonu';

  @override
  String get dictationUnavailable => 'Diktování není na tomto telefonu dostupné';

  @override
  String get doseCapFew => 'kapsle';

  @override
  String get doseCapMany => 'kapslí';

  @override
  String get doseCapOne => 'kapsle';

  @override
  String get doseDropFew => 'kapky';

  @override
  String get doseDropMany => 'kapek';

  @override
  String get doseDropOne => 'kapka';

  @override
  String get doseMlFew => 'ml';

  @override
  String get doseMlMany => 'ml';

  @override
  String get doseMlOne => 'ml';

  @override
  String get doseShotFew => 'injekce';

  @override
  String get doseShotMany => 'injekcí';

  @override
  String get doseShotOne => 'injekce';

  @override
  String get doseTabFew => 'tablety';

  @override
  String get doseTabMany => 'tablet';

  @override
  String get doseTabOne => 'tableta';

  @override
  String entries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count záznamů',
      few: '$count záznamy',
      one: '1 záznam',
      zero: '0 záznamů',
    );
    return '$_temp0';
  }

  @override
  String get eraseAskBody1 =>
      'Zmizí celý deník, za celou dobu: jídla, voda, váha, míry, tréninky, léky i rozhovor s Norou. Na všech zařízeních, protože se maže i kopie na serveru.';

  @override
  String get eraseAskBody2 =>
      'Co zůstává: účet, přihlášení, tokeny se zůstatkem a nastavení profilu. Tohle není odhlášení, je to čistý list uvnitř stejného účtu.';

  @override
  String get eraseAskCta => 'Smazat všechno';

  @override
  String get eraseAskTitle => 'Smazat všechny záznamy?';

  @override
  String get eraseDataTitle => 'Smazat data';

  @override
  String get eraseDone => 'Deník je smazaný. Čistý list.';

  @override
  String eraseFailed(String why) {
    return 'Nepodařilo se smazat: $why';
  }

  @override
  String get eraseNoNet => 'není síť. Zapni internet a zkus to znovu';

  @override
  String get eraseSlow => 'server odpovídá příliš dlouho. Zkus to za minutu';

  @override
  String get eraseSureBody =>
      'Tohle nejde vzít zpět. Deník zmizí navždy a vrátit ho nedokážeš ty ani my.';

  @override
  String get eraseSureCta => 'Ano, smazat navždy';

  @override
  String get eraseSureTitle => 'Opravdu smazat?';

  @override
  String get eveningAnd => ' a ';

  @override
  String get eveningBreakfastAcc => 'snídani';

  @override
  String get eveningDinnerAcc => 'večeři';

  @override
  String get eveningEmptyDay => 'Den je prázdný. Co dnes bylo k jídlu?';

  @override
  String eveningLogged(String slot) {
    return 'Zapsal jsi $slot?';
  }

  @override
  String get eveningLunchAcc => 'oběd';

  @override
  String eveningMissing(String list) {
    return '$list zatím nejsou zapsané. Co z toho bylo?';
  }

  @override
  String get eveningWater => 'Kolik vody za celý den?';

  @override
  String get fieldBiceps => 'Biceps';

  @override
  String get fieldChest => 'Hrudník';

  @override
  String get fieldHips => 'Boky';

  @override
  String get fieldNeck => 'Krk';

  @override
  String get fieldThigh => 'Stehno';

  @override
  String get fieldWaist => 'Pas';

  @override
  String get fieldWeight => 'Váha';

  @override
  String get fieldWrist => 'Zápěstí';

  @override
  String get goalBecomes => 'Bude';

  @override
  String get goalCurrent => 'Současný cíl ';

  @override
  String get goalDailyNorm => 'Denní norma';

  @override
  String goalDiff(String kg) {
    return 'rozdíl $kg';
  }

  @override
  String get goalDirection => 'Směr';

  @override
  String get goalEta => 'Cíl kolem';

  @override
  String goalFromStart(String kg) {
    return ' od $kg na startu. ';
  }

  @override
  String get goalFromToday => 'Nový cíl se bude počítat od dnešní váhy.';

  @override
  String get goalKeepNote => 'Norma drží tvou současnou váhu: vracíš přesně to, co vydáš.';

  @override
  String get goalKeepShort => 'Držet';

  @override
  String get goalNew => 'Nastavit nový cíl';

  @override
  String get goalNewTitle => 'Nový cíl';

  @override
  String get goalPace => 'Tempo';

  @override
  String get goalPaceFast => 'Rychlé';

  @override
  String get goalPaceOk => 'Tohle tempo většina lidí udrží, aniž by se zlomila.';

  @override
  String get goalPaceSlow => 'Pomalé';

  @override
  String goalPaceUnit(Object u) {
    return '$u týdně';
  }

  @override
  String get goalPaceUsual => 'Doporučené';

  @override
  String goalRange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get goalReplaceNote =>
      'Cíl se neupravuje, nahrazuje se. Postup se bude počítat od dnešní váhy a starý cíl zůstane v historii. Potvrdit nahrazení?';

  @override
  String get goalSet => 'Nastavit';

  @override
  String get goalTarget => 'Cílová váha';

  @override
  String get goalWas => 'Bylo';

  @override
  String gramsUnit(String grams) {
    return '$grams';
  }

  @override
  String get helloDishBread => 'Žitný chléb';

  @override
  String get helloDishEggs => 'Míchaná vejce';

  @override
  String get helloSaid => 'dvě vejce a toast';

  @override
  String get helloSlotSub => 'dvě položky';

  @override
  String get helloStepCount => 'Spočítám kalorie';

  @override
  String get helloStepLog => 'Zapíšu to do tvého dne';

  @override
  String get helloStepSay => 'Řekni, co jíš';

  @override
  String heroBurned(String kcal) {
    return '-$kcal z tréninku';
  }

  @override
  String get heroDays => 'dní';

  @override
  String heroFrom(String kcal) {
    return ' z $kcal';
  }

  @override
  String heroGoalKg(Object u) {
    return 'cíl, $u';
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
  String get heroLeft => 'zbývá ';

  @override
  String heroOf(String kcal) {
    return ' z $kcal';
  }

  @override
  String get heroOver => 'navíc ';

  @override
  String get heroWeekOpen => 'Celý týden';

  @override
  String heroWeightFrom(String kg) {
    return 'teď, od $kg na startu cíle';
  }

  @override
  String get islandLast => 'poslední jídlo';

  @override
  String get islandLeft => 'kcal zbývá';

  @override
  String get islandNothing => 'dnes zatím nic zapsáno';

  @override
  String get islandOver => 'kcal navíc';

  @override
  String get islandToday => 'zbývá na dnešek';

  @override
  String get islandTodayOver => 'navíc za dnešek';

  @override
  String kcalUnit(String kcal) {
    return '$kcal';
  }

  @override
  String get langSection => 'Jazyk rozhraní';

  @override
  String get langSystem => 'Jazyk zařízení';

  @override
  String get legalOnTheWeb => 'Open on the web';

  @override
  String legalUpdated(String date) {
    return 'Updated $date';
  }

  @override
  String liveBody(String eaten, String goal) {
    return 'snědeno $eaten z $goal';
  }

  @override
  String get liveChannel => 'Počítadlo dne';

  @override
  String get liveChannelHint => 'Kolik dnes zbývá, dokud aplikace běží';

  @override
  String liveLeft(String kcal) {
    return 'Zbývá $kcal kcal';
  }

  @override
  String liveOver(String kcal) {
    return '$kcal kcal navíc';
  }

  @override
  String get loginNoToken => 'Google nevrátil token';

  @override
  String get loginNotConfigured => 'přihlášení není v této verzi nastavené';

  @override
  String get loginNotSynced =>
      'Ne všechny záznamy došly na server. Zkus to za minutu: přihlášení nic nesmaže, dokud není všechno uložené';

  @override
  String loginServer(String why) {
    return 'server: $why';
  }

  @override
  String get loginSlow => 'Google neodpověděl ani za minutu. Zkus to znovu';

  @override
  String get macroCNone => 'S ?';

  @override
  String macroCShort(int value) {
    return 'S $value';
  }

  @override
  String get macroCarbs => 'Sacharidy';

  @override
  String get macroCarbsCaps => 'SACHARIDY';

  @override
  String get macroCarbsLetter => 'S';

  @override
  String get macroFNone => 'T ?';

  @override
  String macroFShort(int value) {
    return 'T $value';
  }

  @override
  String get macroFat => 'Tuky';

  @override
  String get macroFatCaps => 'TUKY';

  @override
  String get macroFatLetter => 'T';

  @override
  String get macroMedsCaps => 'LÉKY';

  @override
  String macroOfGrams(String goal) {
    return ' / $goal';
  }

  @override
  String get macroPNone => 'B ?';

  @override
  String macroPShort(int value) {
    return 'B $value';
  }

  @override
  String get macroProtein => 'Bílkoviny';

  @override
  String get macroProteinCaps => 'BÍLKOVINY';

  @override
  String get macroProteinLetter => 'B';

  @override
  String get mealAuto => 'auto ';

  @override
  String get mealEditDelete => 'Smazat záznam';

  @override
  String mealEditKcal(Object u) {
    return '$u';
  }

  @override
  String get mealEditSave => 'Uložit';

  @override
  String get mealEmpty => 'Zatím tu nic není. Napiš, co to bylo, a já to zapíšu.';

  @override
  String mealGrams(String grams) {
    return '$grams';
  }

  @override
  String get mealThinking => 'Nora počítá…';

  @override
  String get measureAdd => 'Přidat míru';

  @override
  String get measureCollapse => 'Sbalit';

  @override
  String measureCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count záznamů',
      few: '$count záznamy',
      one: '1 záznam',
    );
    return '$_temp0';
  }

  @override
  String measureLast(String ago) {
    return 'naposledy $ago';
  }

  @override
  String get measureNever => 'zatím neměřeno';

  @override
  String get measureNothing => 'zatím nic';

  @override
  String get measurePick => 'Vyber, co budeš měřit. Stačí jedno, pokud tě zbytek nezajímá.';

  @override
  String get measureSave => 'Uložit míry';

  @override
  String get measureStats => 'Statistika měr';

  @override
  String get measureTitle => 'Míry';

  @override
  String get medsAdd => 'Přidat lék';

  @override
  String get medsAllTaken => 'Všechno na dnešek je vzaté';

  @override
  String get medsAt => 'V';

  @override
  String get medsCourse => 'Kúra';

  @override
  String get medsDose => 'Dávka';

  @override
  String get medsEmpty => 'Zatím tu nic není. Přidej lék a připomenu ti ho ve správný čas.';

  @override
  String get medsEmptyHint => 'Vedu záznam o užitých dávkách, dávkování neurčuji';

  @override
  String get medsFinish => 'Ukončit kúru';

  @override
  String medsFirstDose(String name, String day, String at) {
    return '$name, první dávka $day v $at';
  }

  @override
  String get medsHours => 'Hodiny';

  @override
  String get medsHowOften => 'Jak často';

  @override
  String get medsMine => 'Moje léky';

  @override
  String get medsName => 'Název';

  @override
  String get medsNameExample => 'Například Magnesium B6';

  @override
  String get medsNew => 'Nový lék';

  @override
  String get medsNextAt => 'Další v ';

  @override
  String get medsNoneToday => 'Dnes není co brát';

  @override
  String get medsNote => 'Poznámka';

  @override
  String get medsNow => 'TEĎ';

  @override
  String get medsOne => 'Lék';

  @override
  String get medsPast => 'Dřívější';

  @override
  String get medsPastEmpty =>
      'Budou tu kúry, které už nebereš. Lék odebraný ze seznamu zůstane ve dnech, kdy jsi ho bral.';

  @override
  String get medsPerTake => 'Kolik najednou';

  @override
  String get medsRemind => 'Připomínat';

  @override
  String get medsRemindHint => 've zvolených hodinách';

  @override
  String get medsResume => 'Obnovit kúru';

  @override
  String get medsSchedule => 'Rozvrh';

  @override
  String medsSince(String date) {
    return 'od $date';
  }

  @override
  String get medsTime => 'Čas';

  @override
  String get medsTitle => 'Léky';

  @override
  String get medsTomorrow => 'zítra';

  @override
  String get medsUnmarked => 'Zatím neoznačeno: ';

  @override
  String medsUntil(String date) {
    return 'do $date';
  }

  @override
  String get menuAbout => 'O aplikaci';

  @override
  String get menuAllergy => 'Alergie';

  @override
  String get menuAnalytics => 'Analýza';

  @override
  String get menuDiary => 'Deník';

  @override
  String get menuHintFree => 'zdarma';

  @override
  String menuHintKcal(String n) {
    return '$n dnes';
  }

  @override
  String menuHintMore(int n) {
    return '+$n';
  }

  @override
  String get menuHintNoAllergy => 'žádné';

  @override
  String get menuHintNoMeds => 'žádné kúry';

  @override
  String get menuHintNothing => 'zatím nic zapsáno';

  @override
  String menuHintOnGoal(int ok, int total) {
    return 'v cíli $ok ze $total';
  }

  @override
  String get menuHintRecipes => 'od Nory, na míru tvé normě';

  @override
  String get menuHintWeekFriday => 'od pátku, 18:00';

  @override
  String get menuHintWeekOpen => 'otevřeno do neděle';

  @override
  String get menuHintWeekYoung => 'týden právě začal';

  @override
  String get menuMeds => 'Léky';

  @override
  String get menuPlan => 'Předplatné';

  @override
  String get menuRecipes => 'Recepty';

  @override
  String get menuSettings => 'Nastavení';

  @override
  String get menuTitle => 'Menu';

  @override
  String get menuWeek => 'Rozbor týdne';

  @override
  String get noraName => 'Nora';

  @override
  String get normAuto => 'Počítat automaticky';

  @override
  String get normAutoFrom => 'Z váhy na startu cíle, výšky, věku, aktivity a tempa: ';

  @override
  String normAutoHint(String kcal) {
    return 'z váhy, výšky, věku, aktivity a cíle: $kcal';
  }

  @override
  String get normAutoShort => 'Automaticky';

  @override
  String get normByHand => 'Nastavit ručně';

  @override
  String get normByHandHint => 'analýza bude počítat vůči tomuto číslu';

  @override
  String get normByHandShort => 'Ručně';

  @override
  String get normCalculatedHead => 'Vypočtená hodnota je ';

  @override
  String get normCalculatedTail => '. Vrátit se k ní můžeš volbou „Automaticky“.';

  @override
  String get normFitCarbs => 'Dopočítat sacharidy do normy';

  @override
  String get normFits => 'Rozdělení sedí na normu';

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
  String get normMacros => 'Makra';

  @override
  String get normManual => 'nastaveno ručně';

  @override
  String normOf(String kcal) {
    return 'z $kcal';
  }

  @override
  String normOffOver(String sum, int off) {
    return 'Rozdělení dává $sum, o $off nad normou';
  }

  @override
  String normOffUnder(String sum, int off) {
    return 'Rozdělení dává $sum, o $off pod normou';
  }

  @override
  String normPerDay(Object u) {
    return '$u denně';
  }

  @override
  String get normTitle => 'Norma';

  @override
  String get normWater => 'Voda';

  @override
  String get normWaterHead => 'To je ';

  @override
  String normWaterPerKg(String ml) {
    return '$ml';
  }

  @override
  String get normWaterTail =>
      ' na kilogram váhy. Obvyklé hrubé rozmezí je 30-40 ml, ale záleží na horku a trénincích, takže tohle číslo není svaté.';

  @override
  String get normWhere => 'Odkud se to číslo bere';

  @override
  String get notifyChannel => 'Připomínky';

  @override
  String get notifyChannelHint => 'Připomínky jídla, vody, léků a vážení';

  @override
  String get notifyDenied =>
      'Telefon oznámení odmítl. Zapni je v nastavení systému a připomínky začnou fungovat.';

  @override
  String get nutriAdded => 'Přidaný cukr';

  @override
  String nutriAddedNorm(int g, int better) {
    return 'do $g g, lépe do $better';
  }

  @override
  String get nutriAddedShort => 'Přidaný';

  @override
  String get nutriAddedSource => 'WHO: pod 10 % kalorií, lépe pod 5 %';

  @override
  String get nutriAddedWhat =>
      'Cukr, sirupy a med přidané do potraviny. Cukr z ovoce a mléka se sem nepočítá.';

  @override
  String nutriAtLeast(String text) {
    return 'nejméně $text';
  }

  @override
  String get nutriFiber => 'Vláknina';

  @override
  String nutriFiberNorm(int g) {
    return '$g g denně';
  }

  @override
  String get nutriFiberShort => 'Vláknina';

  @override
  String get nutriFiberSource => 'EFSA: nejméně 25 g, nebo 14 g na tisíc kalorií';

  @override
  String get nutriFiberWhat =>
      'Část rostlinné stravy, kterou tělo nestráví. Drží trávení v chodu a zasytí na déle.';

  @override
  String get nutriFrom => 'Odkud to dnes je';

  @override
  String nutriGap(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jídel bez těchto čísel, takže je to minimum.',
      few: '$count jídla bez těchto čísel, takže je to minimum.',
      one: 'Jedno jídlo bez těchto čísel, takže je to minimum.',
    );
    return '$_temp0';
  }

  @override
  String get nutriGapAll => 'O tomhle se dnes neví nic: žádné jídlo dne tato čísla nenese.';

  @override
  String get nutriNone => 'Tato jídla se nepočítala';

  @override
  String get nutriNorm => 'Norma';

  @override
  String nutriNowGoal(String now, int goal) {
    return '$now g dnes z $goal';
  }

  @override
  String nutriNowSodium(String now, String salt) {
    return '$now g dnes, to je $salt g soli';
  }

  @override
  String nutriNowSugar(String now, String added) {
    return '$now g dnes, z toho přidaného $added';
  }

  @override
  String nutriRest(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'a ještě $count');
    return '$_temp0';
  }

  @override
  String get nutriSat => 'Nasycené tuky';

  @override
  String nutriSatNorm(int g) {
    return 'do $g g denně';
  }

  @override
  String get nutriSatShort => 'Nasycené';

  @override
  String get nutriSatSource => 'WHO 2023: pod 10 % kalorií';

  @override
  String get nutriSatWhat =>
      'Tuky živočišných potravin, másla a sýrů, a také kokosového a palmového oleje.';

  @override
  String get nutriSodium => 'Sodík';

  @override
  String get nutriSodiumNorm => 'do 2 g denně, to je 5 g soli';

  @override
  String get nutriSodiumNote =>
      'V domácím jídle rozhoduje o soli ten, kdo vaří. Bereme obvyklé množství pro takové jídlo a ty ho můžeš upravit v personalizaci.';

  @override
  String get nutriSodiumShort => 'Sodík';

  @override
  String get nutriSodiumSource => 'WHO. Nezávisí na kaloriích';

  @override
  String get nutriSodiumWhat =>
      'Sůl je sodík krát 2,5. Většina ho pochází z pečiva, uzenin, sýrů a jídla mimo domov, ne ze slánky.';

  @override
  String get nutriSugar => 'Cukr';

  @override
  String get nutriSugarNorm => 'bez normy';

  @override
  String get nutriSugarNote =>
      'Stupnice pod celkovým cukrem by z jablka udělala problém. Dívej se na číslo vedle.';

  @override
  String get nutriSugarShort => 'Cukr';

  @override
  String get nutriSugarSource => 'WHO a EFSA omezují přidaný cukr, ne celkový';

  @override
  String get nutriSugarWhat => 'Všechny cukry dohromady: přidané i ty z ovoce a mléka.';

  @override
  String get nutriUnknown => 'dnes zatím nepočítáno';

  @override
  String get photoDish => 'Jídlo';

  @override
  String get photoNotRecognized => 'Na tomhle snímku jsem jídlo nerozpoznala';

  @override
  String get planBuy => 'Předplatit';

  @override
  String get planClose => 'Zavřít';

  @override
  String get planCurrent => 'současný';

  @override
  String get planFailed => 'Nákup neprošel';

  @override
  String get planFree => 'Zdarma';

  @override
  String planFrom(String plan, String date) {
    return '$plan od $date';
  }

  @override
  String planFromShort(String date) {
    return 'od $date';
  }

  @override
  String get planLater => 'Teď ne';

  @override
  String get planManage => 'Spravovat v obchodě';

  @override
  String get planMonth => 'Měsíc';

  @override
  String get planMonthBilled => 'účtováno měsíčně';

  @override
  String get planMonthly => 'Pro měsíčně';

  @override
  String get planNext => 'Další';

  @override
  String get planNothingToRestore => 'Na tomto účtu nejsou žádné nákupy';

  @override
  String get planNow => 'Teď';

  @override
  String get planOn => 'Pro';

  @override
  String get planPerMonth => '/měs';

  @override
  String get planPerkChat => 'Neomezené rozhovory s Norou';

  @override
  String get planPerkChatSub => 'jedna zpráva dnes stojí jeden token';

  @override
  String get planPerkMemory => 'Nora si tě pamatuje';

  @override
  String get planPerkMemorySub => 'učí se nové věci v rozhovoru, a to stojí token';

  @override
  String get planPerkPhoto => 'Neomezené focení jídla';

  @override
  String get planPerkPhotoSub => 'foto dnes stojí dva tokeny';

  @override
  String get planPerkRecipes => 'Neomezené recepty od Nory';

  @override
  String get planPerkRecipesSub => 'návrh dnes stojí jeden token';

  @override
  String get planPerkWeek => 'Rozbor týdne, kdykoli chceš';

  @override
  String get planPerkWeekSub => 'rozbor dnes stojí dva tokeny';

  @override
  String get planPerks => 'Co předplatné dává';

  @override
  String get planPlan => 'Plán';

  @override
  String get planPrivacy => 'Zásady soukromí';

  @override
  String get planRenewal =>
      'Předplatné se obnovuje automaticky, dokud ho nezrušíš. Zrušit ho můžeš kdykoli v nastavení obchodu, kde bylo koupeno.';

  @override
  String get planRenews => 'Obnoví se';

  @override
  String get planRestore => 'Obnovit nákupy';

  @override
  String get planSignInGo => 'Přihlásit se';

  @override
  String get planSignInNote =>
      'Předplatné je vázané na účet s e-mailem. Tak přežije nový telefon a funguje na všech tvých zařízeních.';

  @override
  String get planSignInTitle => 'Nejdřív se přihlas';

  @override
  String get planStoreAsking => 'Ptám se obchodu na ceny…';

  @override
  String get planStoreOffline => 'Obchod neodpovídá. Zkontroluj připojení k internetu';

  @override
  String get planStoreQuiet => 'Obchod neodpovídá. Zkus to později';

  @override
  String get planSwitchMonth => 'Přejít na měsíční';

  @override
  String get planSwitchYear => 'Přejít na roční';

  @override
  String get planTariffs => 'Plány';

  @override
  String get planTerms => 'Podmínky použití';

  @override
  String get planTitle => 'Předplatné';

  @override
  String get planTokens => 'Tokeny';

  @override
  String get planTokensFree => '40 měsíčně';

  @override
  String get planTokensPro => 'Neomezeně';

  @override
  String get planUntil => 'Aktivní do';

  @override
  String get planYear => 'Rok';

  @override
  String planYearBilled(String price) {
    return '$price jednou ročně';
  }

  @override
  String get planYearly => 'Pro ročně';

  @override
  String plateFor(String grams) {
    return 'za $grams';
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
  String get plateThinking => 'počítám';

  @override
  String get plateTotal => 'celkem';

  @override
  String get privacyCrash => 'Hlášení pádů';

  @override
  String get privacyCrashHint => 'výpis chyby, bez dat z deníku';

  @override
  String get privacyDiaryHead => 'Tvůj deník zůstává tvůj';

  @override
  String get privacyDiarySub => 'ani jídla, ani váha nejdou do analytiky';

  @override
  String get privacyHealthHead => 'Zdravotní údaje nejdou nikomu';

  @override
  String get privacyHealthSub => 'alergie a léky aplikaci nikdy neopustí';

  @override
  String get privacyNoPhotosHead => 'Fotky jídla se neukládají';

  @override
  String get privacyNoPhotosSub => 'snímek jde na přečtení a je pryč';

  @override
  String get privacyNotCollected => 'Co nesbíráme';

  @override
  String get privacyOptional => 'Co můžeš vypnout';

  @override
  String get privacyPhotosBold => 'se neuchovávají';

  @override
  String get privacyPhotosHead => 'Fotky jídla ';

  @override
  String get privacyPhotosTail =>
      ': snímek jde na zpracování a je pryč. Analytika nikdy nevidí jídla, váhu, alergie ani léky. To je zvláštní kategorie osobních údajů a předat ji třetí straně nepřipadá v úvahu, jakkoli by to bylo pohodlné.';

  @override
  String get privacyStats => 'Anonymní statistika';

  @override
  String get privacyStatsHint => 'které obrazovky se otevírají, bez obsahu záznamů';

  @override
  String get privacyTitle => 'Soukromí';

  @override
  String get profileActivity => 'Aktivita';

  @override
  String get profileAge => 'Věk';

  @override
  String get profileHeight => 'Výška';

  @override
  String get profileSex => 'Pohlaví';

  @override
  String rcAllergyWarn(String names) {
    return 'Obsahuje $names ze tvého seznamu alergií. S tímhle opatrně.';
  }

  @override
  String get rcAskPlaceholder => 'kuřecí, brokolice, rýže';

  @override
  String rcChatGreet(String name) {
    return 'Zeptej se na „$name“: co zaměnit, jak to nezkazit, co připravit dopředu.';
  }

  @override
  String get rcChatHello => 'Řekni, co máš v kuchyni, a sestavím recept.';

  @override
  String get rcChatHint => '„kuřecí, brokolice, rýže“: navrhnu pár jídel a spočítám porci';

  @override
  String get rcChatHintDinner => 'Večeře na 500 kcal';

  @override
  String get rcChatHintEggs => 'Rychlá snídaně s vejci';

  @override
  String get rcChatHintMince => 'Co udělám z mletého masa?';

  @override
  String get rcChatHintOnly => 'Zbyl jen sýr a těstoviny';

  @override
  String get rcChatPicks =>
      'Tady je, co z toho můžeš uvařit. Vyber jídlo a recept přistane v knize.';

  @override
  String rcCount(int n) {
    return '$n receptů';
  }

  @override
  String rcCountFew(int n) {
    return '$n recepty';
  }

  @override
  String get rcCountOne => '1 recept';

  @override
  String rcDeleteBody(String name) {
    return '„$name“ zmizí z knihy. Záznamy v deníku, zapsané z něj, zůstanou.';
  }

  @override
  String get rcDeleteCta => 'Smazat';

  @override
  String get rcDeleteFailed => 'Nepodařilo se smazat. Zkus to znovu.';

  @override
  String get rcDeleteTitle => 'Smazat tento recept?';

  @override
  String get rcDishHint =>
      '„čím nahradit rýži?“, „jak nevysušit filet?“, „dá se to připravit dopředu?“';

  @override
  String get rcDishHintAhead => 'Dá se to připravit dopředu?';

  @override
  String get rcDishHintDry => 'Jak nevysušit filet?';

  @override
  String get rcDishHintKeeps => 'Jak dlouho to vydrží?';

  @override
  String get rcDishHintSwap => 'Čím nahradit rýži?';

  @override
  String get rcEmpty =>
      'Zatím tu nic není. Řekni Noře, co máš v kuchyni, a objeví se první recept.';

  @override
  String get rcEmptyMine => 'Zatím žádné vlastní recepty. Nadiktuj Noře jakýkoli a přistane tady.';

  @override
  String get rcEyebrow => 'Kuchyně';

  @override
  String get rcFromMine => 'Moje';

  @override
  String get rcFromNora => 'Od Nory';

  @override
  String get rcHelps => 'Nora ti pomůže sestavit recept';

  @override
  String get rcHeroA => 'Co uvařit';

  @override
  String get rcHeroB => 'dnes';

  @override
  String get rcHeroLede =>
      'Řekni, co máš doma. Nora poradí a spočítá porci; vlastní recept funguje taky.';

  @override
  String get rcItemsHead => 'Suroviny';

  @override
  String rcItemsTotal(String g) {
    return 'celkem $g';
  }

  @override
  String get rcJustNow => 'právě teď';

  @override
  String get rcLoadFailed => 'Kniha receptů se nenačetla. Zatáhni pro nový pokus.';

  @override
  String rcMinutes(int n) {
    return '$n min';
  }

  @override
  String get rcNoTools => 'Nic kromě nože a misky';

  @override
  String rcOfDay(int p) {
    return 'to je $p % denní normy';
  }

  @override
  String get rcPerServing => 'na porci';

  @override
  String get rcPerServingHead => 'Na porci';

  @override
  String rcPortion(String g) {
    return 'porce $g';
  }

  @override
  String rcServingsFew(int n) {
    return '$n porce';
  }

  @override
  String rcServingsMany(int n) {
    return '$n porcí';
  }

  @override
  String get rcServingsOne => '1 porce';

  @override
  String get rcStepsHead => 'Jak vařit';

  @override
  String get rcSuggestFailed => 'Nora nedokázala sestavit recepty. Zkus to znovu.';

  @override
  String get rcTabAll => 'Vše';

  @override
  String get rcTabMine => 'Moje';

  @override
  String get rcTabNora => 'Od Nory';

  @override
  String get rcTitle => 'Recepty';

  @override
  String get rcToolBlender => 'Mixér';

  @override
  String get rcToolGrill => 'Gril';

  @override
  String get rcToolMixer => 'Šlehač';

  @override
  String get rcToolOven => 'Trouba';

  @override
  String get rcToolPan => 'Pánev';

  @override
  String get rcToolPot => 'Hrnec';

  @override
  String get rcToolsHead => 'Co je potřeba v kuchyni';

  @override
  String rcWhole(String kcal, String g) {
    return 'Celé jídlo: $kcal, $g';
  }

  @override
  String get remAbout => 'Na co';

  @override
  String get remAdd => 'Přidat připomínku';

  @override
  String get remAt => 'V';

  @override
  String get remDelete => 'Smazat připomínku';

  @override
  String get remEdit => 'Připomínka';

  @override
  String get remEmpty => 'Zatím žádné připomínky.';

  @override
  String get remEmptyHint =>
      'Přidej tu jednu věc, na kterou opravdu zapomínáš, ne všechno najednou';

  @override
  String get remHowOften => 'Jak často';

  @override
  String get remName => 'Název';

  @override
  String get remNew => 'Nová připomínka';

  @override
  String get remOpenMeds => 'Otevřít léky';

  @override
  String get remTime => 'Čas';

  @override
  String get remTitle => 'Připomínky';

  @override
  String get reminderBodyMeal => 'Zapiš, co to bylo';

  @override
  String get reminderBodyMeds => 'Podle rozvrhu';

  @override
  String get reminderBodySummary => 'Co dnes zůstalo nezapsané?';

  @override
  String get reminderBodyWater => 'Čas se napít';

  @override
  String get reminderBodyWeigh => 'Ráno, před jídlem';

  @override
  String get reminderBodyWorkout => 'Zapiš ho, pokud byl';

  @override
  String get reminderMeal => 'Jídlo';

  @override
  String get reminderMealHint => 'připomenu ti zapsat jídlo';

  @override
  String get reminderMeds => 'Léky';

  @override
  String get reminderMedsHint => 'podle rozvrhu z deníku';

  @override
  String get reminderSummary => 'Shrnutí dne';

  @override
  String get reminderSummaryHint => 'krátce o dni před spaním';

  @override
  String get reminderWater => 'Voda';

  @override
  String get reminderWaterHint => 'připomenu ti napít se';

  @override
  String get reminderWeigh => 'Vážení';

  @override
  String get reminderWeighHint => 'aby se graf váhy nepřetrhl';

  @override
  String get reminderWorkout => 'Trénink';

  @override
  String get reminderWorkoutHint => 'připomenu ti ten plánovaný';

  @override
  String get repDaily => 'každý den';

  @override
  String repEveryN(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'každých $count dní');
    return '$_temp0';
  }

  @override
  String get repEveryOther => 'obden';

  @override
  String get repPickDaily => 'Každý den';

  @override
  String get repPickFromToday => 'Počítá se ode dneška.';

  @override
  String get repPickInterval => 'Obden';

  @override
  String get repPickNoDays => 'Není vybraný žádný den, takže připomínka nikdy nepřijde.';

  @override
  String get repPickWeekdays => 'Dny v týdnu';

  @override
  String get repWeekdays => 've všední dny';

  @override
  String get repWeekends => 'o víkendech';

  @override
  String get repWeekly => 'jednou týdně';

  @override
  String get restoredBody1 =>
      'Tento účet čekal na smazání. Přihlášení to zrušilo: deník, profil i nastavení jsou zase v tomto telefonu.';

  @override
  String get restoredBody2 =>
      'Pokud chceš účet přece jen smazat, požádej o to znovu v Nastavení. Každé přihlášení před naším potvrzením žádost stejně tak zruší.';

  @override
  String get restoredOk => 'Rozumím';

  @override
  String get restoredTitle => 'Tvá data jsou zpátky';

  @override
  String get setAbout => 'O aplikaci';

  @override
  String get setAccess => 'Přístupy';

  @override
  String get setAllergies => 'Alergie';

  @override
  String setAssistantLine(String name, int count) {
    return '$name, $count v paměti';
  }

  @override
  String get setCustom => 'Personalizace';

  @override
  String get setCustomNote => 'Co ukazuje obrazovka dne a jak počítáme sůl';

  @override
  String get setDeleteAccount => 'Smazat účet a data';

  @override
  String get setFreeTierHead =>
      'Pro obránce Ukrajiny a pro ty, kdo slouží v ozbrojených silách, záchranných službách, DTEK, pro lékaře, dobrovolníky a učitele v oblastech u fronty je placený plán ';

  @override
  String get setFreeTierHow => ' Jak ho získat';

  @override
  String get setFreeTierShort =>
      'Pro obránce Ukrajiny a pro ty, kdo slouží v ozbrojených silách, záchranných službách, DTEK, pro lékaře, dobrovolníky a učitele v oblastech u fronty je placený plán ZDARMA';

  @override
  String get setFreeTierTelegram => 'Napsat na Telegramu';

  @override
  String get setFreeTierTitle => 'Plán zdarma';

  @override
  String get setFreeTierWord => 'ZDARMA';

  @override
  String get setFreeTierWrite => 'Napiš vývojáři a placený plán ti zapneme ještě týž den.';

  @override
  String get setGoal => 'Cíl';

  @override
  String get setGoalKeep => 'držet váhu';

  @override
  String setGoalLine(String kg, String pace) {
    return '$kg, $pace/týden';
  }

  @override
  String get setGroupAbout => 'O tobě';

  @override
  String get setGroupAccount => 'Účet';

  @override
  String get setGroupAssistant => 'Asistentka';

  @override
  String get setGroupDocs => 'Dokumenty';

  @override
  String get setGroupHealth => 'Zdraví';

  @override
  String get setLang => 'Jazyk';

  @override
  String get setMedical => 'Zdravotní upozornění';

  @override
  String get setMeds => 'Léky';

  @override
  String get setNorm => 'Norma';

  @override
  String setNormLine(String kcal) {
    return '$kcal';
  }

  @override
  String get setNutriLarge => 'Karty';

  @override
  String get setNutriLargeHint => 'Pět sloupců s kroužky a popisky, jako makra';

  @override
  String get setNutriNote => 'Vláknina, cukr, sodík a nasycené tuky pod makry';

  @override
  String get setNutriOff => 'Neukazovat';

  @override
  String get setNutriOffHint => 'Jen bílkoviny, tuky a sacharidy, jako dřív';

  @override
  String get setNutriSmall => 'Řádek';

  @override
  String get setNutriSmallHint => 'Tichá řádka pod kartami: značka, číslo, barva na hraně';

  @override
  String get setNutriTitle => 'Živiny';

  @override
  String get setPlan => 'Předplatné';

  @override
  String get setPlanFree => 'Zdarma';

  @override
  String get setPolicy => 'Zásady soukromí';

  @override
  String get setPrivacy => 'Data a analytika';

  @override
  String get setProfile => 'Profil';

  @override
  String setProfileLine(String sex, int age, String height) {
    return '$sex, $age, $height';
  }

  @override
  String get setReminders => 'Připomínky';

  @override
  String get setRemindersOff => 'vypnuto';

  @override
  String get setSaltLess => 'Méně než obvykle';

  @override
  String get setSaltMore => 'Více než obvykle';

  @override
  String get setSaltNote => 'Oprava soli, kterou předpokládáme v domácím vaření';

  @override
  String get setSaltTitle => 'Jak solíš';

  @override
  String get setSaltUsual => 'Jako obvykle';

  @override
  String get setTerms => 'Podmínky použití';

  @override
  String get setTheme => 'Motiv';

  @override
  String get setTitle => 'Nastavení';

  @override
  String get setUnits => 'Jednotky';

  @override
  String get setUnset => 'nenastaveno';

  @override
  String get sexOther => 'Jiné';

  @override
  String get sexShortFemale => 'Ž';

  @override
  String get sexShortMale => 'M';

  @override
  String get slotBreakfast => 'Snídaně';

  @override
  String get slotByHand => 'Zadej čísla ručně';

  @override
  String get slotCancel => 'Zrušit';

  @override
  String get slotDinner => 'Večeře';

  @override
  String slotEraseBody(String name) {
    return '„$name“ pořád nemá čísla. Řádek zmizí ze dne.';
  }

  @override
  String get slotEraseDo => 'Odstranit';

  @override
  String get slotEraseTitle => 'Odstranit koncept?';

  @override
  String slotGrams(Object u) {
    return 'VÁHA, $u';
  }

  @override
  String get slotIntoBreakfast => 'ke snídani';

  @override
  String get slotIntoDinner => 'k večeři';

  @override
  String get slotIntoLunch => 'k obědu';

  @override
  String slotIntoOther(String name) {
    return 'do „$name“';
  }

  @override
  String get slotIntoSnack => 'ke svačině';

  @override
  String slotKcal(Object u) {
    return '$u';
  }

  @override
  String get slotLog => 'Zapsat';

  @override
  String get slotLunch => 'Oběd';

  @override
  String get slotSnack => 'Svačina';

  @override
  String get slotWriteWhat => 'Napiš, co to bylo';

  @override
  String get startAbout => 'O tobě';

  @override
  String get startAge => 'Věk';

  @override
  String startAgeYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count let',
      few: '$count roky',
      one: '1 rok',
    );
    return '$_temp0';
  }

  @override
  String get startAgreeAnd => ' a se ';

  @override
  String get startAgreeHead => 'Souhlasím s ';

  @override
  String get startAgreePrivacy => 'zásadami soukromí';

  @override
  String get startAgreeTerms => 'podmínkami použití';

  @override
  String get startDeviceFirstRun => 'první spuštění';

  @override
  String get startDocs => 'Dokumenty';

  @override
  String get startGoal => 'Kam míříme';

  @override
  String get startGoalGain => 'Přibrat';

  @override
  String get startGoalGainHint => 'přebytek tempem, které si zvolíš';

  @override
  String get startGoalKeep => 'Držet váhu';

  @override
  String get startGoalKeepHint => 'vracíš přesně to, co vydáš';

  @override
  String get startGoalLose => 'Zhubnout';

  @override
  String get startGoalLoseHint => 'deficit tempem, které si zvolíš';

  @override
  String get startHeight => 'Výška';

  @override
  String get startHiHello => 'Vítej v';

  @override
  String get startHiNote => 'Šest krátkých otázek, asi minuta. Zbytek spočítá Nora.';

  @override
  String get startLife => 'Životní styl';

  @override
  String get startNorm => 'Tvoje norma';

  @override
  String get startNormCounting => 'počítám…';

  @override
  String get startNormHold => 'udržování';

  @override
  String get startNormNote =>
      'Je to vzorec Mifflin-St Jeor, ne lékařská rada. Pokud máš nějakou diagnózu, jsi těhotná nebo držíš předepsanou dietu, poraď se s lékařem.';

  @override
  String startNormPerDay(Object u) {
    return '$u denně';
  }

  @override
  String get startNormWeeks => 'týdnů';

  @override
  String get startPace => 'Jak rychle';

  @override
  String get startPaceEtaHead => 'Cíl kolem ';

  @override
  String get startPaceEtaTail => ', to je ';

  @override
  String get startPaceFast => 'rychle';

  @override
  String get startPaceSlow => 'pomalu';

  @override
  String startPaceUnit(Object u) {
    return '$u týdně';
  }

  @override
  String get startPaceUsual => 'obvykle';

  @override
  String get startPaceWarning =>
      'Takové tempo se drží těžko a obvykle se zlomí. Pod 0,8 kg týdně přijde výsledek pomaleji, zato zůstane.';

  @override
  String startPaceWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count týdnů',
      few: '$count týdny',
      one: '1 týden',
    );
    return '$_temp0';
  }

  @override
  String get startSex => 'Pohlaví';

  @override
  String get startSexFemale => 'Žena';

  @override
  String get startSexMale => 'Muž';

  @override
  String get startSexOther => 'Jiné';

  @override
  String get startSignInApple => 'Pokračovat přes Apple';

  @override
  String get startSignInBackText =>
      'Přihlas se stejným účtem a všechno se vrátí: deník, cíl, norma i míry. Nic nemusíš vyplňovat znovu.';

  @override
  String get startSignInBackTitle => 'Vítej zpátky';

  @override
  String get startSignInBusy => 'Přihlašuji…';

  @override
  String get startSignInFailed => 'Přihlášení se nepovedlo. Zkus to znovu, nebo pokračuj bez účtu.';

  @override
  String startSignInFailedWhy(String why) {
    return 'Přihlášení se nepovedlo. $why';
  }

  @override
  String get startSignInGoogle => 'Pokračovat přes Google';

  @override
  String get startSignInSkip => 'Pokračovat bez účtu';

  @override
  String get startSignInText =>
      'Norma je spočítaná. Přihlas se, aby ti zůstala: historie, míry a záznamy budou na každém zařízení, ne jen tady.';

  @override
  String get startSignInTitle => 'Uložme si to';

  @override
  String get startTargetWeight => 'Cílová váha';

  @override
  String get startWeightNow => 'Váha teď';

  @override
  String get startYearsShort => 'let';

  @override
  String get storageBroken =>
      'Nepodařilo se otevřít úložiště. Tvé záznamy jsou v pořádku, ale teď není čím je zobrazit.';

  @override
  String get themeAquarelle => 'Akvarel';

  @override
  String get themeAquarelleHint => 'světlý, s pastelovými oblaky na pozadí';

  @override
  String get themeDark => 'Tmavý';

  @override
  String get themeDarkHint => 'vždy tmavé rozhraní';

  @override
  String get themeDawn => 'Svítání';

  @override
  String get themeDawnHint => 'světlý, s teplým světlem ze strany';

  @override
  String get themeLight => 'Světlý';

  @override
  String get themeLightHint => 'vždy světlé rozhraní';

  @override
  String get themeSectionLook => 'Vzhled';

  @override
  String get themeSystem => 'Motiv zařízení';

  @override
  String get themeSystemHint => 'řídí se nastavením systému';

  @override
  String get todayBarcode => 'Čárový kód';

  @override
  String todayCodeTalk(String code) {
    return 'Načetl jsem čárový kód $code a žádná databáze ho nezná. Nic nezapisuj: zeptej se mě na tento produkt nebo mi řekni, jak ho spočítat.';
  }

  @override
  String get todayDone => 'Hotovo.';

  @override
  String get todayFailedRetry => 'Nevyšlo to. Zkus to za minutu znovu.';

  @override
  String get todayGoalMet =>
      'Gratuluji! 🎉 Vytoužená váha je tvoje a cíl je uzavřený. A je to tvoje zásluha, ne aplikace. Teď přepínám tvou normu na udržování, aby ti výsledek zůstal.';

  @override
  String todayHowManyGrams(String dish) {
    return 'Kolik gramů bylo $dish?';
  }

  @override
  String get todayLogFailed => 'Nepodařilo se to zapsat. Zkus to znovu.';

  @override
  String get todayLogged => 'Zapsáno.';

  @override
  String todayLoggedAskWeight(String slotInto) {
    return 'Zapsáno $slotInto. Řekni váhu, pokud to chceš přesně.';
  }

  @override
  String get todayLoggedAskWeightShort => 'Zapsáno. Řekni váhu, pokud to chceš přesně.';

  @override
  String todayLoggedCount(int count) {
    return 'zapsáno $count';
  }

  @override
  String todayLoggedInto(String slotInto, String dish) {
    return 'Zapsáno $slotInto: $dish.';
  }

  @override
  String todayLoggedIntoWithNumbers(String slotInto, String dish, String kcal, String grams) {
    return 'Zapsáno $slotInto: $dish, $kcal za $grams.';
  }

  @override
  String get todayNoraSlow => 'Nora přemýšlí déle než obvykle. Zkus to znovu, token se nestrhl.';

  @override
  String get todayOffline => 'Není připojení. Zkus to znovu, až se vrátí.';

  @override
  String get todayOfflineSaved =>
      'Není připojení. Záznam zůstává v telefonu a odejde, až se vrátí.';

  @override
  String get todayOutOfBody =>
      'Teď chvíli mlčím, ale zapisovat ručně můžeš pořád a je to zdarma. Předplatné mě zapne zpátky a stojí asi tři kávy měsíčně.';

  @override
  String get todayOutOfPlan => 'Předplatné';

  @override
  String get todayOutOfTokens => 'Tokeny došly.';

  @override
  String get todayPhotoMeal => 'Foto';

  @override
  String get todayQuestionClosed => 'Ta otázka je už uzavřená. Když je potřeba, řekni váhu slovy.';

  @override
  String get tourCamera => 'Fotoaparát';

  @override
  String get tourCameraHow => 'talíř, etiketa nebo čárový kód';

  @override
  String get tourDiary => 'Paměť deníku';

  @override
  String get tourDiaryHow => 'řekni „boršč“ a vezme tvou obvyklou porci';

  @override
  String get tourGuide => 'Průvodce aplikací';

  @override
  String get tourGuideHow => 'zeptej se, kde co je a jak to udělat';

  @override
  String get tourMemory => 'Trvalá paměť';

  @override
  String get tourMemoryHow => '„vepřové nejím“ stačí říct jednou';

  @override
  String get tourMore => 'Nejen jídlo';

  @override
  String get tourMoreHow => 'voda, tréninky, míry, recepty';

  @override
  String get tourTitle => 'Co Nora umí';

  @override
  String get tourVoice => 'Hlasem nebo textem';

  @override
  String get tourVoiceHow => '„dvě vejce a toast“, a je to zapsané';

  @override
  String get tourWeek => 'Rozbor dne a týdne';

  @override
  String get tourWeekHow => 'co vyšlo a co doladit';

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
  String get unitsLength => 'Výška a míry';

  @override
  String get unitsMass => 'Tělesná váha';

  @override
  String get unitsPortion => 'Porce jídla';

  @override
  String get unitsTitle => 'V jakých jednotkách';

  @override
  String get unitsVolume => 'Voda';

  @override
  String get watchLinked => 'připojené';

  @override
  String waterGlasses(int glasses) {
    return 'asi $glasses sklenic';
  }

  @override
  String waterLess(String step) {
    return '$step méně';
  }

  @override
  String waterMore(String step) {
    return '$step více';
  }

  @override
  String get waterNone => 'nic nevypito';

  @override
  String waterOf(String ml) {
    return ' / $ml';
  }

  @override
  String waterShare(int pct) {
    return '$pct % denního cíle';
  }

  @override
  String get waterTitle => 'Voda';

  @override
  String get wcNoTime => 'bez trvání';

  @override
  String get wdFri => 'Pá';

  @override
  String get wdMon => 'Po';

  @override
  String get wdSat => 'So';

  @override
  String get wdSun => 'Ne';

  @override
  String get wdThu => 'Čt';

  @override
  String get wdTue => 'Út';

  @override
  String get wdWed => 'St';

  @override
  String get weightHint => 'Kolik vážíš dnes. Cíl a tempo k němu žijí zvlášť.';

  @override
  String get weightNote =>
      'Važ se ráno, před jídlem: denní výkyvy pak z grafu neudělají šum. Jedno vážení týdně už je trend.';

  @override
  String get weightTitle => 'Váha';

  @override
  String get welEggs => 'Dvě smažená vejce';

  @override
  String get welEggsGrams => '120 g';

  @override
  String get welHaveAccount => 'Účet už mám';

  @override
  String get welLead => 'Počítá kalorie z tvých vlastních slov';

  @override
  String get welSaid => 'Měl jsem dvě vejce a toast';

  @override
  String get welStart => 'Začít';

  @override
  String get welToast => 'Toast s máslem';

  @override
  String get welToastGrams => '50 g';

  @override
  String get welTotal => 'Dohromady';

  @override
  String wfBurned(Object u) {
    return 'Spáleno, $u';
  }

  @override
  String get wfDuration => 'Trvání';

  @override
  String get wfDurationCap => 'Trvání, min';

  @override
  String get wfEstimate => 'Odhad z tvé váhy a druhu pohybu';

  @override
  String get wfFromWatch => 'Z hodinek nebo ze stroje';

  @override
  String wfKcal(Object u) {
    return ' $u';
  }

  @override
  String get wfLog => 'Zapsat';

  @override
  String wfManualKcal(Object u) {
    return '$u ručně';
  }

  @override
  String wfMin(int min) {
    return '$min min';
  }

  @override
  String get wfMinutes => 'Minuty';

  @override
  String get wfNote => 'Poznámka';

  @override
  String get wfNoteExample => 'Nohy, těžké';

  @override
  String get wfOptional => '  nepovinné';

  @override
  String get wheelLess => 'Méně';

  @override
  String get wheelMore => 'Více';

  @override
  String get wkDaysOk => 'dní v cíli';

  @override
  String get wkEmpty => 'Tento týden zatím nic nezapsáno. Zapiš první den a objeví se obraz celku.';

  @override
  String get wkFactsHead => 'Týden celkem';

  @override
  String get wkKcalHead => 'Kalorie';

  @override
  String get wkLoggedCap => 'zapsaných dní';

  @override
  String wkLoggedValue(int n) {
    return '$n ze 7';
  }

  @override
  String get wkMacroHead => 'Makra';

  @override
  String get wkNoWeight => 'váha: žádné vážení';

  @override
  String get wkNoraBtn => 'Sestavit rozbor';

  @override
  String wkNoraFailed(String why) {
    return 'Rozbor se nepodařilo sestavit: $why';
  }

  @override
  String get wkNoraGreet =>
      'Zeptej se na cokoli z tohoto čtení: na jídlo, na návyk nebo na to, co spravit první.';

  @override
  String get wkNoraLoading => 'Nora čte týden…';

  @override
  String get wkNoraLocked => 'Rozbor se otevře v pátek';

  @override
  String get wkNoraNoNet => 'není síť';

  @override
  String get wkNoraNoTokens => 'došly tokeny';

  @override
  String get wkNoraP1 =>
      'Základ máš zdravý, a to je vzácné: skoro všechno je doma uvařené. Boršč, míchaná vejce, kaše: na takovém základu se zbytek doladí rychle.';

  @override
  String get wkNoraP2 =>
      'Teď upřímně. Zelenina se za celý týden skoro neobjevila, zato sladké denně: lívance s medem, kompot. Bílkovin je málo ne proto, že jíš málo, ale proto, že na talíři převažují sacharidy a masa, ryby nebo sýra je poskrovnu. A tři večeře ze sedmi přišly po desáté.';

  @override
  String get wkNoraP3 =>
      'Nic hrozného zatím, ale přesně takové jídlo překvapí krevní testy ve čtyřiceti. Jeden krok na příští týden, nic jiného neměň: ke každému obědu něco zeleného a místo kompotu voda.';

  @override
  String get wkNoraPlaceholder => 'Zeptej se na tento týden';

  @override
  String get wkNoraPromise =>
      'Poctivé čtení tvého týdne: co vyšlo, co ujelo a jeden krok na příští.';

  @override
  String get wkNoraReply1 =>
      'Nejsnazší záměna tohoto týdne: voda místo kompotu. Pokaždé o lžíci cukru míň, a boršč o nic nepřijde.';

  @override
  String get wkNoraReply2 =>
      'Zelenina k obědu nemusí znamenat salát. Okurka nebo půlka papriky vedle talíře už svou práci udělají.';

  @override
  String get wkNoraSlow => 'server odpovídá příliš dlouho';

  @override
  String get wkNoraTalk => 'Probrat to s Norou';

  @override
  String get wkNoraTitle => 'Nora o tvém týdnu';

  @override
  String get wkNorm => 'cíl';

  @override
  String wkOffNorm(String n) {
    return '$n od cíle';
  }

  @override
  String get wkPastEmpty => 'Zatím žádné dřívější rozbory. První se tu objeví příští pondělí.';

  @override
  String wkPastRow(String day) {
    return 'Týden od $day';
  }

  @override
  String get wkPastTitle => 'Minulé týdny';

  @override
  String wkPerDay(Object u) {
    return '$u denně v průměru';
  }

  @override
  String get wkPerDayAside => 'denně v průměru';

  @override
  String get wkTitle => 'Týden';

  @override
  String wkTotalCap(Object u) {
    return '$u za týden';
  }

  @override
  String get wkWaterCap => 'vody denně';

  @override
  String wkWaterValue(String l) {
    return '$l l';
  }

  @override
  String get wkWeightCap => 'váha za týden';

  @override
  String get workoutAdd => 'Přidat trénink';

  @override
  String workoutBurned(String kcal) {
    return '−$kcal';
  }

  @override
  String get workoutCollapse => 'Sbalit';

  @override
  String get workoutMinUnit => 'min';

  @override
  String get workoutNone => 'nic nezapsáno';

  @override
  String workoutSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tréninků',
      few: '$count tréninky',
      one: '1 trénink',
    );
    return '$_temp0';
  }

  @override
  String get workoutTitle => 'Trénink';
}
