// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class LPl extends L {
  LPl([String locale = 'pl']) : super(locale);

  @override
  String get aboutContact => 'Kontakt';

  @override
  String get aboutDeveloper => 'Deweloper';

  @override
  String get aboutText =>
      'Dziennik żywieniowy, który rozumie zwykłe zdania. Liczby liczy asystentka Nora, decyzje zostają przy tobie.';

  @override
  String get aboutTitle => 'O aplikacji';

  @override
  String get aboutVersion => 'Wersja';

  @override
  String get aboutWrite => 'Napisz do nas';

  @override
  String get accessAsk => 'jeszcze nie pytano';

  @override
  String get accessCamera => 'Aparat';

  @override
  String get accessMic => 'Mikrofon';

  @override
  String get accessNote =>
      'Mikrofon i rozpoznawanie mowy są potrzebne do dyktowania, a rozpoznawanie także zegarkowi: nagrywa, co mówisz, a telefon zamienia to w słowa. Dotknij wiersza, aby udzielić dostępu lub otworzyć ustawienia systemu i go wyłączyć.';

  @override
  String get accessNotify => 'Powiadomienia';

  @override
  String get accessOff => 'odmówiono';

  @override
  String get accessOn => 'dozwolone';

  @override
  String get accessSpeech => 'Rozpoznawanie mowy';

  @override
  String get accountBusy => 'Logowanie…';

  @override
  String get accountGoogle => 'Kontynuuj z Google';

  @override
  String get accountKeepCloud => 'Ten z konta';

  @override
  String get accountNoAccountNote =>
      'Dziennik żyje tylko na tym telefonie. Zmienisz telefon albo skasujesz aplikację i nie będzie czym przywrócić wpisów: nie wiemy, czyje są.';

  @override
  String get accountScopeNote =>
      'Prosimy tylko o adres e-mail. Imienia, zdjęcia profilowego ani kontaktów Google nam nie przekazuje.';

  @override
  String get accountSettingsDevice => 'ustawienia';

  @override
  String get accountSignInFailed => 'Nie udało się zalogować.';

  @override
  String accountSignInFailedWhy(String why) {
    return 'Nie udało się zalogować. $why';
  }

  @override
  String get accountSignOut => 'Wyloguj';

  @override
  String get accountSignOutAction => 'Wyloguj się z konta';

  @override
  String get accountSignOutAsk => 'Wylogować się?';

  @override
  String get accountSignOutBack =>
      'Zaloguj się tym samym kontem, a wszystko wróci na miejsce. Tego, co zapisano bez internetu i jeszcze nie dojechało na serwer, nie da się odzyskać.';

  @override
  String get accountSignOutNote =>
      'Ten telefon zrobi się czysty: dziennik, profil, leki i rozmowa z Norą z niego znikną. Wpisy zostają na serwerze, na twoim koncie.';

  @override
  String get accountSince => 'W Calvi od';

  @override
  String get accountTitle => 'Konto';

  @override
  String get accountVia => 'Logowanie przez Google';

  @override
  String get accountViaApple => 'Logowanie przez Apple';

  @override
  String get accountViaEmail => 'Logowanie przez e-mail';

  @override
  String get accountWatch => 'Apple Watch';

  @override
  String get accountWhichDiary => 'Który dziennik zostawiamy?';

  @override
  String get accountWhichDiaryNote =>
      'Na tym koncie są już wpisy, i na telefonie też. Zostawić można tylko jeden: ten z konta albo ten z telefonu. Drugi zniknie.';

  @override
  String get actBasketball => 'Koszykówka';

  @override
  String get actBike => 'Rower';

  @override
  String get actDance => 'Taniec';

  @override
  String get actFootball => 'Piłka nożna';

  @override
  String get actGym => 'Siłownia';

  @override
  String get actHiit => 'HIIT';

  @override
  String get actJumprope => 'Skakanka';

  @override
  String get actRun => 'Bieganie';

  @override
  String get actSki => 'Narty';

  @override
  String get actStretch => 'Rozciąganie';

  @override
  String get actSwim => 'Pływanie';

  @override
  String get actTennis => 'Tenis';

  @override
  String get actWalk => 'Chodzenie';

  @override
  String get actYoga => 'Joga';

  @override
  String get actionAdd => 'Dodaj';

  @override
  String get actionBack => 'Wstecz';

  @override
  String get actionCancel => 'Anuluj';

  @override
  String get actionClose => 'Zamknij';

  @override
  String get actionDelete => 'Usuń';

  @override
  String get actionDone => 'Gotowe';

  @override
  String get actionNext => 'Dalej';

  @override
  String get actionSave => 'Zapisz';

  @override
  String get activityHigh => 'Wysoka';

  @override
  String get activityHighHint => '5-6 treningów';

  @override
  String get activityLight => 'Lekka aktywność';

  @override
  String get activityLightHint => '1-2 treningi w tygodniu';

  @override
  String get activityModerate => 'Umiarkowana';

  @override
  String get activityModerateHint => '3-4 treningi';

  @override
  String get activitySedentary => 'Siedzący';

  @override
  String get activitySedentaryHint => 'prawie bez ruchu';

  @override
  String get activityVeryHigh => 'Bardzo wysoka';

  @override
  String get activityVeryHighHint => 'praca fizyczna albo sport codziennie';

  @override
  String agoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dnia temu',
      many: '$count dni temu',
      few: '$count dni temu',
      one: '$count dzień temu',
    );
    return '$_temp0';
  }

  @override
  String get agoToday => 'dzisiaj';

  @override
  String get agoWeek => 'tydzień temu';

  @override
  String agoWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tygodnia temu',
      many: '$count tygodni temu',
      few: '$count tygodnie temu',
      one: '$count tydzień temu',
    );
    return '$_temp0';
  }

  @override
  String get agoYesterday => 'wczoraj';

  @override
  String get allergyConfirm => 'Potwierdź';

  @override
  String get allergyMild => 'Lekka';

  @override
  String get allergyMildHint => 'Ostrzegę w tekście, zapisu nie blokuję.';

  @override
  String get allergyMildShort => 'lekka';

  @override
  String get allergyNote =>
      'Jeśli składu produktu nie ma w bazie, nie milczę i nie uznaję tego za bezpieczeństwo: powiem osobno, że skład jest nieznany.';

  @override
  String get allergyNothing =>
      'Nic nie znaleziono. Jeśli alergenu nie ma na liście, napisz do Nory: dodamy go do bazy, żeby działał u wszystkich, a nie został tekstem u jednej osoby.';

  @override
  String get allergyRemove => 'Usuń';

  @override
  String allergySearch(int count) {
    return 'Szukaj wśród $count alergenów';
  }

  @override
  String get allergySevere => 'Ciężka';

  @override
  String get allergySevereHint => 'Zatrzymam przed zapisem i powiem wprost.';

  @override
  String get allergySevereShort => 'ciężka';

  @override
  String get allergyTitle => 'Alergie';

  @override
  String anChartGoal(String value) {
    return 'cel $value';
  }

  @override
  String get anDaysInNorm => 'dni w normie';

  @override
  String anDonePercent(int percent) {
    return '$percent% zrobione';
  }

  @override
  String anEtaHead(String date) {
    return 'W tym tempie cel około *$date*';
  }

  @override
  String get anForMonth => 'w ciągu miesiąca';

  @override
  String get anForQuarter => 'w ciągu 3 miesięcy';

  @override
  String get anForYear => 'w ciągu roku';

  @override
  String get anGoalProgress => 'Postęp do celu';

  @override
  String get anKcal => 'Kalorie';

  @override
  String get anKcalAvg => 'średnio dziennie';

  @override
  String get anKcalEmpty =>
      'W tym okresie nic jeszcze nie zapisano. Zapisz, co jesz, a wykres zbuduje się sam.';

  @override
  String anKcalTotal(Object u) {
    return 'w okresie, $u';
  }

  @override
  String anMacroGoal(String grams) {
    return 'norma $grams';
  }

  @override
  String get anMacrosAvg => 'Makro średnio';

  @override
  String get anMacrosEmpty =>
      'Średnia pojawi się, gdy będzie co uśredniać: zapisz choć jeden dzień.';

  @override
  String get anMeasures => 'Pomiary';

  @override
  String anMeasuresChange(String period) {
    return 'zmiana $period';
  }

  @override
  String get anMeasuresEmpty => 'Nie ma jeszcze pomiarów.';

  @override
  String get anMeasuresEmptyHint => 'Mierz się raz w miesiącu, a pokażę, co się zmienia';

  @override
  String get anMonth => 'Miesiąc';

  @override
  String get anNow => 'teraz';

  @override
  String anNowKg(Object u) {
    return 'teraz, $u';
  }

  @override
  String get anOneReading => 'jeden pomiar';

  @override
  String get anOneWeighing =>
      'Na razie jeden pomiar. Drugi pokaże kierunek i od niego zacznie się linia.';

  @override
  String get anPerDay => 'dziennie';

  @override
  String get anQuarter => '3 miesiące';

  @override
  String anShareOfNorm(int share) {
    return '$share% normy';
  }

  @override
  String anStartKg(Object u) {
    return 'start, $u';
  }

  @override
  String anTargetKg(Object u) {
    return 'cel, $u';
  }

  @override
  String get anTitle => 'Statystyki';

  @override
  String get anWater => 'Nawodnienie';

  @override
  String anWaterAvg(Object u) {
    return 'średnio, $u';
  }

  @override
  String anWaterGoal(String ml) {
    return 'norma $ml';
  }

  @override
  String get anWeek => 'Tydzień';

  @override
  String get anWeightEmpty =>
      'Krzywa pojawi się po drugim ważeniu. Powiedz Norze swoją wagę, a ona sama ją zapisze.';

  @override
  String get anYear => 'Rok';

  @override
  String get assistantAddMemory => 'Dodaj do pamięci';

  @override
  String get assistantCollapse => 'Zwiń';

  @override
  String get assistantExample => 'Na przykład nie jem grzybów';

  @override
  String get assistantForget => 'Zapomnij';

  @override
  String assistantHint(String name) {
    return '$name prowadzi dziennik razem z tobą i pamięta to, co jej o sobie powiesz.';
  }

  @override
  String get assistantMemory => 'Pamięć';

  @override
  String get assistantMemoryEmpty => 'Na razie nic nie zapamiętałam.';

  @override
  String get assistantMemoryEmptyHint => 'Pamięć bierze się z rozmów, albo dodaj ręcznie';

  @override
  String assistantPinned(int count, int pinned) {
    return '$count, przypięto $pinned';
  }

  @override
  String get assistantTitle => 'Asystentka';

  @override
  String get assistantWhatToRemember => 'Co pamiętać';

  @override
  String get authAgain => 'Potwierdzenie hasła';

  @override
  String get authAgainDiffers => 'Hasła nie są takie same';

  @override
  String get authAgainEmpty => 'Powtórz hasło';

  @override
  String get authAgainHint => 'jeszcze raz';

  @override
  String authAgainIn(int sec) {
    return 'Ponownie można za $sec s';
  }

  @override
  String get authCode => 'Kod z listu';

  @override
  String get authCodeAction => 'Potwierdź';

  @override
  String get authCodeBad => 'Kod nie pasuje albo już wygasł';

  @override
  String authCodeHint(String mail) {
    return 'Wysłaliśmy kod na $mail. Wpisz sześć cyfr z listu.';
  }

  @override
  String get authCodeShort => 'Kod ma 6 cyfr';

  @override
  String get authCodeTitle => 'Potwierdź e-mail';

  @override
  String get authForgotAction => 'Wyślij kod';

  @override
  String get authForgotHint => 'Wyślemy kod na e-mail, a potem wybierzesz nowe hasło.';

  @override
  String get authForgotLink => 'Nie pamiętasz?';

  @override
  String get authForgotTitle => 'Nowe hasło';

  @override
  String get authMail => 'E-mail';

  @override
  String get authMailBad => 'Ten adres wygląda na błędny';

  @override
  String get authOr => 'lub';

  @override
  String get authPass => 'Hasło';

  @override
  String get authPassEmpty => 'Wpisz hasło';

  @override
  String get authPassHint => '5 liter i znak';

  @override
  String get authPassNew => 'Nowe hasło';

  @override
  String get authPassWeak => 'Słabe hasło: co najmniej 5 liter i jedna cyfra lub znak';

  @override
  String get authResetAction => 'Zapisz hasło';

  @override
  String get authSendAgain => 'Wyślij ponownie';

  @override
  String get authSignInAction => 'Zaloguj się';

  @override
  String get authSignInTitle => 'Logowanie';

  @override
  String get authSignUpAction => 'Utwórz konto';

  @override
  String get authSignUpLink => 'Zarejestruj się';

  @override
  String get authSignUpTitle => 'Załóżmy konto';

  @override
  String get barCamera => 'Aparat';

  @override
  String barGrams(String grams) {
    return '$grams';
  }

  @override
  String get barHint => 'Cześć, jestem Nora. Pisz albo mów jak zwykle, a zrozumiem.';

  @override
  String get barHintBorscht => 'Barszcz 300 g na obiad';

  @override
  String get barHintDelete => 'Usuń ostatni wpis';

  @override
  String get barHintEggs => 'Dwa jajka i tost';

  @override
  String get barHintMore =>
      '„dwa jajka i tost”, „wypiłem 300 wody”, „bieg 40 minut”: rozłożę i zapiszę do właściwej karty';

  @override
  String get barHintProtein => 'Ile białka zostało?';

  @override
  String get barHintRun => 'Bieg 40 minut';

  @override
  String get barHintWater => 'Wypiłem 500 ml wody';

  @override
  String get barHintWeighed => 'Ważenie: 78.8';

  @override
  String get barHintYesterday => 'Co jadłem wczoraj?';

  @override
  String get barLogsInto => 'Zapisuję: ';

  @override
  String get barMic => 'Mikrofon';

  @override
  String get barSend => 'Wyślij';

  @override
  String get camAgain => 'Jeszcze raz';

  @override
  String get camAllergen => 'Alergen!';

  @override
  String camAllergyContains(String list) {
    return 'Zawiera twój alergen: $list';
  }

  @override
  String camAllergyTraces(String list) {
    return 'Może zawierać śladowe ilości: $list';
  }

  @override
  String get camAskNoraInstead => 'Nie ma etykiety, zapytaj Norę';

  @override
  String get camBarcode => 'Kod kreskowy';

  @override
  String get camBusy => 'Aparat się nie otworzył. Najczęściej zajmuje go inna aplikacja.';

  @override
  String get camCouldNotRead => 'Nie udało się rozpoznać zdjęcia';

  @override
  String get camDish => 'Zdjęcie';

  @override
  String camEstimate(Object u) {
    return ' $u, szacunkowo';
  }

  @override
  String get camFlash => 'Lampa';

  @override
  String get camFromPack => 'Liczby z opakowania. Zapis nie kosztuje tokenów.';

  @override
  String get camGallery => 'Z galerii';

  @override
  String get camGapNote => 'Tej liczby nie zna żadna baza. Sfotografuj etykietę, a ją uzupełnię.';

  @override
  String get camHintBarcode => 'kod w ramce';

  @override
  String get camHintDish => 'wyceluj w talerz albo opakowanie';

  @override
  String camIngredients(String text) {
    return 'Skład: $text';
  }

  @override
  String camIntoSlot(String slot) {
    return 'Zapis: $slot';
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
  String get camLabelAim => 'wyceluj w tabelę wartości odżywczych';

  @override
  String get camLabelNoShot => 'Zdjęcie się nie udało. Spróbuj sfotografować etykietę jeszcze raz.';

  @override
  String get camLabelReading => 'Przepisuję liczby z opakowania…';

  @override
  String camLogInto(String slotInto) {
    return 'Zapisz $slotInto';
  }

  @override
  String get camNoPermission => 'Brak zgody na aparat. Można jej udzielić w ustawieniach telefonu.';

  @override
  String get camNoScanner => 'Ten telefon nie umie czytać kodów aparatem.';

  @override
  String get camNoTokens => 'Skończyły się tokeny';

  @override
  String get camNotAProduct => 'To nie jest kod produktu';

  @override
  String get camNotAProductNote =>
      'Odczytał się link albo kod służbowy. Wyceluj w paski z cyframi pod spodem.';

  @override
  String get camNotRead => 'Nie rozpoznałam';

  @override
  String get camOffline =>
      'Kod odczytany, ale nie ma kogo o niego zapytać. Spróbuj, gdy wróci połączenie.';

  @override
  String get camOfflineShot => 'Nie mam sieci. Zdjęcie można wysłać Norze później';

  @override
  String get camOfflineTitle => 'Brak sieci';

  @override
  String get camPer100 => 'Na opakowaniu nie ma dokładnej wagi: liczby na 100 g.';

  @override
  String camPortionPack(String g) {
    return 'Porcja z opakowania: $g. Liczby na porcję.';
  }

  @override
  String get camReading => 'Czytam…';

  @override
  String get camSendToNora => 'Wyślij Norze';

  @override
  String get camServerDown => 'To nie przez kod ani przez aparat. Spróbuj za minutę.';

  @override
  String get camServerDownTitle => 'Nasz serwer nie odpowiedział';

  @override
  String get camShoot => 'Zrób zdjęcie';

  @override
  String get camShootLabel => 'Sfotografuj etykietę';

  @override
  String get camShotFailed => 'Zdjęcie się nie udało';

  @override
  String get camShotReady => 'Zdjęcie gotowe';

  @override
  String get camShotReadyNote =>
      'Nora je przeanalizuje i odpowie na czacie: nazwie danie, oceni porcję i pokaże, skąd wzięła się liczba. Kosztuje dwa tokeny.';

  @override
  String get camSignedOut =>
      'Sesja jest nieważna, więc baza nas nie rozpoznaje. Zaloguj się w aplikacji od nowa, a skaner ruszy.';

  @override
  String get camSignedOutTitle => 'Trzeba zalogować się od nowa';

  @override
  String get camSlow => 'Kod odczytany, a baza się ociąga. Spróbuj jeszcze raz.';

  @override
  String get camSlowTitle => 'Odpowiedź nie zdążyła';

  @override
  String get camStillWorks => 'Zdjęcie dania i galeria działają jak zwykle.';

  @override
  String get camTitle => 'Skaner';

  @override
  String get camTookTooLong => 'Analiza się przeciąga. Spróbuj jeszcze raz';

  @override
  String get camUnknownCode => 'Nie ma tego produktu w bazie';

  @override
  String get camUnknownCodeNote =>
      'Ani w naszej, ani w otwartej. Sfotografuj tabelę wartości odżywczych z opakowania, a przepiszę z niej liczby. To za darmo.';

  @override
  String get chatPro => 'Pro';

  @override
  String get deleteAskBody1 =>
      'Ten telefon zrobi się czysty od razu: dziennik, profil, rozmowa z Norą, logowanie. Aplikacja wróci na pierwszy ekran.';

  @override
  String get deleteAskBody2 =>
      'Na serwerze konto stanie w kolejce do ostatecznego usunięcia: zajmuje ono do 30 dni roboczych. Dopóki tego nie potwierdzimy, zalogowanie tym samym kontem przywróci wszystko i anuluje prośbę.';

  @override
  String get deleteAskCta => 'Tak, usuń';

  @override
  String get deleteAskTitle => 'Usunąć konto?';

  @override
  String get deleteConfirm =>
      'Rozumiem, że dane zostaną usunięte na zawsze i nie da się ich odzyskać.';

  @override
  String get deleteDays => 'Dni z Calvi';

  @override
  String get deleteEntries => 'Wpisów w dzienniku';

  @override
  String deleteFailed(String why) {
    return 'Nie udało się usunąć: $why';
  }

  @override
  String get deleteForever => 'Usuń na zawsze';

  @override
  String get deleteNote =>
      'Usuwane jest wszystko: dziennik, waga, pomiary, alergie, leki, historia rozmów. Po tym nie da się tego odzyskać.';

  @override
  String get deleteProManage => 'Zarządzaj subskrypcją';

  @override
  String deleteProNote(String store) {
    return 'Usunięcie konta nie anuluje Calvi Pro. $store będzie pobierać pieniądze dalej, dopóki sama subskrypcja nie zostanie anulowana, więc trzeba to zrobić przed usunięciem konta.';
  }

  @override
  String get deleteProStoreAny => 'Sklep';

  @override
  String get deleteSubNote =>
      'Jeśli chodzi o subskrypcję, można ją anulować osobno w App Store albo Google Play, bez usuwania konta.';

  @override
  String get deleteTitle => 'Usuń konto';

  @override
  String get deleteWeighings => 'Pomiarów wagi';

  @override
  String get dictationBusy => 'Mikrofon zajęty. Spróbuj jeszcze raz';

  @override
  String get dictationFailed => 'Dyktowanie się nie udało';

  @override
  String get dictationNoMatch => 'Nie usłyszałam nic zrozumiałego';

  @override
  String get dictationNoNetwork => 'Rozpoznawanie potrzebuje sieci';

  @override
  String get dictationNoPermission => 'Brak zgody na mikrofon';

  @override
  String get dictationSilence => 'Cisza. Spróbuj jeszcze raz bliżej mikrofonu';

  @override
  String get dictationUnavailable => 'Dyktowanie niedostępne na tym telefonie';

  @override
  String get doseCapFew => 'kapsułki';

  @override
  String get doseCapMany => 'kapsułek';

  @override
  String get doseCapOne => 'kapsułka';

  @override
  String get doseDropFew => 'krople';

  @override
  String get doseDropMany => 'kropli';

  @override
  String get doseDropOne => 'kropla';

  @override
  String get doseMlFew => 'ml';

  @override
  String get doseMlMany => 'ml';

  @override
  String get doseMlOne => 'ml';

  @override
  String get doseShotFew => 'zastrzyki';

  @override
  String get doseShotMany => 'zastrzyków';

  @override
  String get doseShotOne => 'zastrzyk';

  @override
  String get doseTabFew => 'tabletki';

  @override
  String get doseTabMany => 'tabletek';

  @override
  String get doseTabOne => 'tabletka';

  @override
  String entries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wpisu',
      many: '$count wpisów',
      few: '$count wpisy',
      one: '$count wpis',
      zero: '0 wpisów',
    );
    return '$_temp0';
  }

  @override
  String get eraseAskBody1 =>
      'Zniknie cały dziennik z całego czasu: dania, woda, waga, pomiary, treningi, leki i rozmowa z Norą. Na wszystkich urządzeniach, bo kasowana jest też kopia na serwerze.';

  @override
  String get eraseAskBody2 =>
      'Zostaną: konto, logowanie, tokeny z saldem i ustawienia profilu. To nie jest wylogowanie, to czysta karta w koncie.';

  @override
  String get eraseAskCta => 'Usuń wszystko';

  @override
  String get eraseAskTitle => 'Usunąć wszystkie wpisy?';

  @override
  String get eraseDataTitle => 'Usuń dane';

  @override
  String get eraseDone => 'Dziennik wyczyszczony. Czysta karta.';

  @override
  String eraseFailed(String why) {
    return 'Nie udało się wyczyścić: $why';
  }

  @override
  String get eraseNoNet => 'brak sieci. Włącz internet i spróbuj jeszcze raz';

  @override
  String get eraseSlow => 'serwer długo odpowiada. Spróbuj jeszcze raz za minutę';

  @override
  String get eraseSureBody =>
      'To jest nieodwracalne. Dziennik zniknie na zawsze i nie przywrócimy go ani ty, ani my.';

  @override
  String get eraseSureCta => 'Tak, usuń na zawsze';

  @override
  String get eraseSureTitle => 'Na pewno usunąć?';

  @override
  String get eveningAnd => ' i ';

  @override
  String get eveningBreakfastAcc => 'śniadanie';

  @override
  String get eveningDinnerAcc => 'kolację';

  @override
  String get eveningEmptyDay => 'Dzień jest pusty. Co dziś jadłeś?';

  @override
  String eveningLogged(String slot) {
    return 'Zapisałam $slot?';
  }

  @override
  String get eveningLunchAcc => 'obiad';

  @override
  String eveningMissing(String list) {
    return 'Nie zapisano jeszcze $list. Co z tego było?';
  }

  @override
  String get eveningWater => 'Ile wody wyszło przez dzień?';

  @override
  String get fieldBiceps => 'Biceps';

  @override
  String get fieldChest => 'Klatka';

  @override
  String get fieldHips => 'Biodra';

  @override
  String get fieldNeck => 'Szyja';

  @override
  String get fieldThigh => 'Udo';

  @override
  String get fieldWaist => 'Talia';

  @override
  String get fieldWeight => 'Waga';

  @override
  String get fieldWrist => 'Nadgarstek';

  @override
  String get goalBecomes => 'Będzie';

  @override
  String get goalCurrent => 'Obecny cel ';

  @override
  String get goalDailyNorm => 'Norma dzienna';

  @override
  String goalDiff(String kg) {
    return 'różnica $kg';
  }

  @override
  String get goalDirection => 'Kierunek';

  @override
  String get goalEta => 'Cel mniej więcej';

  @override
  String goalFromStart(String kg) {
    return ' od $kg na starcie. ';
  }

  @override
  String get goalFromToday => 'Nowy cel zacznie się od dzisiejszej wagi.';

  @override
  String get goalKeepNote => 'Norma trzyma obecną wagę: ile wydajesz, tyle wracasz.';

  @override
  String get goalKeepShort => 'Utrzymać';

  @override
  String get goalNew => 'Ustaw nowy cel';

  @override
  String get goalNewTitle => 'Nowy cel';

  @override
  String get goalPace => 'Tempo';

  @override
  String get goalPaceFast => 'Szybko';

  @override
  String get goalPaceOk => 'To tempo, które większość wytrzymuje bez zrywów.';

  @override
  String get goalPaceSlow => 'Wolno';

  @override
  String goalPaceUnit(Object u) {
    return '$u na tydzień';
  }

  @override
  String get goalPaceUsual => 'Zalecane';

  @override
  String goalRange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get goalReplaceNote =>
      'Celu się nie edytuje, tylko zastępuje. Postęp zacznie liczyć się od dzisiejszej wagi, a stary cel zostanie w historii. Potwierdzasz zamianę?';

  @override
  String get goalSet => 'Ustaw';

  @override
  String get goalTarget => 'Waga docelowa';

  @override
  String get goalWas => 'Było';

  @override
  String gramsUnit(String grams) {
    return '$grams';
  }

  @override
  String get helloDishBread => 'Chleb żytni';

  @override
  String get helloDishEggs => 'Jajecznica z dwóch jajek';

  @override
  String get helloSaid => 'dwa jajka i tost';

  @override
  String get helloSlotSub => 'dwa dania';

  @override
  String get helloStepCount => 'Policzę kalorie';

  @override
  String get helloStepLog => 'Zapiszę w dniu';

  @override
  String get helloStepSay => 'Powiedz, co jesz';

  @override
  String heroBurned(String kcal) {
    return '-$kcal za trening';
  }

  @override
  String get heroDays => 'dni';

  @override
  String heroFrom(String kcal) {
    return ' od $kcal';
  }

  @override
  String heroGoalKg(Object u) {
    return 'cel, $u';
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
  String get heroLeft => 'zostało ';

  @override
  String heroOf(String kcal) {
    return ' z $kcal';
  }

  @override
  String get heroOver => 'nadmiar ';

  @override
  String get heroWeekOpen => 'Analiza tygodnia';

  @override
  String heroWeightFrom(String kg) {
    return 'teraz, od $kg na starcie celu';
  }

  @override
  String kcalUnit(String kcal) {
    return '$kcal';
  }

  @override
  String get langSection => 'Język interfejsu';

  @override
  String get langSystem => 'Język urządzenia';

  @override
  String get legalOnTheWeb => 'Open on the web';

  @override
  String legalUpdated(String date) {
    return 'Updated $date';
  }

  @override
  String get loginNoToken => 'Google nie oddał tokena';

  @override
  String get loginNotConfigured => 'logowanie nie jest skonfigurowane w tej wersji';

  @override
  String get loginNotSynced =>
      'Nie wszystkie wpisy dotarły na serwer. Spróbuj jeszcze raz za minutę: logowanie niczego nie kasuje, dopóki wszystko nie jest zapisane';

  @override
  String loginServer(String why) {
    return 'serwer: $why';
  }

  @override
  String get loginSlow => 'Google nie odpowiedział przez minutę. Spróbuj jeszcze raz';

  @override
  String get macroCNone => 'W ?';

  @override
  String macroCShort(int value) {
    return 'W $value';
  }

  @override
  String get macroCarbs => 'Węglowodany';

  @override
  String get macroCarbsCaps => 'WĘGLOWODANY';

  @override
  String get macroCarbsLetter => 'W';

  @override
  String get macroFNone => 'T ?';

  @override
  String macroFShort(int value) {
    return 'T $value';
  }

  @override
  String get macroFat => 'Tłuszcze';

  @override
  String get macroFatCaps => 'TŁUSZCZE';

  @override
  String get macroFatLetter => 'T';

  @override
  String get macroMedsCaps => 'LEKI';

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
  String get macroProtein => 'Białko';

  @override
  String get macroProteinCaps => 'BIAŁKO';

  @override
  String get macroProteinLetter => 'B';

  @override
  String get mealAuto => 'auto ';

  @override
  String get mealEditDelete => 'Usuń wpis';

  @override
  String mealEditKcal(Object u) {
    return '$u';
  }

  @override
  String get mealEditSave => 'Zapisz';

  @override
  String get mealEmpty => 'Tu na razie pusto. Napisz, co było, a zapiszę.';

  @override
  String mealGrams(String grams) {
    return '$grams';
  }

  @override
  String get mealThinking => 'Nora liczy…';

  @override
  String get measureAdd => 'Dodaj pomiar';

  @override
  String get measureCollapse => 'Zwiń';

  @override
  String measureCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pomiaru',
      many: '$count pomiarów',
      few: '$count pomiary',
      one: '$count pomiar',
    );
    return '$_temp0';
  }

  @override
  String measureLast(String ago) {
    return 'ostatni $ago';
  }

  @override
  String get measureNever => 'jeszcze nie było';

  @override
  String get measureNothing => 'jeszcze nic';

  @override
  String get measurePick =>
      'Wybierz, co będziesz mierzyć. Wystarczy jedno, jeśli reszta nie interesuje.';

  @override
  String get measureSave => 'Zapisz pomiary';

  @override
  String get measureStats => 'Statystyka pomiarów';

  @override
  String get measureTitle => 'Pomiary';

  @override
  String get medsAdd => 'Dodaj lek';

  @override
  String get medsAllTaken => 'Na dziś wszystko przyjęte';

  @override
  String get medsAt => 'O której';

  @override
  String get medsCourse => 'Kuracja';

  @override
  String get medsDose => 'Dawka';

  @override
  String get medsEmpty => 'Tu jest pusto. Dodaj lek, a przypomnę o nim w odpowiedniej chwili.';

  @override
  String get medsEmptyHint => 'Prowadzę dziennik przyjęć, dawkowania nie wyliczam';

  @override
  String get medsFinish => 'Zakończ kurację';

  @override
  String medsFirstDose(String name, String day, String at) {
    return '$name, pierwsza dawka $day o $at';
  }

  @override
  String get medsHours => 'Godziny';

  @override
  String get medsHowOften => 'Jak często';

  @override
  String get medsMine => 'Moje leki';

  @override
  String get medsName => 'Nazwa';

  @override
  String get medsNameExample => 'Na przykład Magnez B6';

  @override
  String get medsNew => 'Nowy lek';

  @override
  String get medsNextAt => 'Następne o ';

  @override
  String get medsNoneToday => 'Dziś nie ma nic do przyjęcia';

  @override
  String get medsNote => 'Notatka';

  @override
  String get medsNow => 'TERAZ';

  @override
  String get medsOne => 'Lek';

  @override
  String get medsPast => 'Zakończone';

  @override
  String get medsPastEmpty =>
      'Tu będą kuracje, których już nie bierzesz. Lek usunięty z listy zostaje w dniach, w których go brałeś.';

  @override
  String get medsPerTake => 'Ile na raz';

  @override
  String get medsRemind => 'Przypominaj';

  @override
  String get medsRemindHint => 'o wybranych godzinach';

  @override
  String get medsResume => 'Wznów kurację';

  @override
  String get medsSchedule => 'Harmonogram';

  @override
  String medsSince(String date) {
    return 'od $date';
  }

  @override
  String get medsTime => 'Godzina';

  @override
  String get medsTitle => 'Leki';

  @override
  String get medsTomorrow => 'jutro';

  @override
  String get medsUnmarked => 'Jeszcze nie oznaczono: ';

  @override
  String medsUntil(String date) {
    return 'do $date';
  }

  @override
  String get menuAbout => 'O aplikacji';

  @override
  String get menuAllergy => 'Alergie';

  @override
  String get menuAnalytics => 'Statystyki';

  @override
  String get menuDiary => 'Dziennik';

  @override
  String get menuHintFree => 'bezpłatny';

  @override
  String menuHintKcal(String n) {
    return 'dziś $n';
  }

  @override
  String menuHintMore(int n) {
    return '+$n';
  }

  @override
  String get menuHintNoAllergy => 'brak';

  @override
  String get menuHintNoMeds => 'brak kuracji';

  @override
  String get menuHintNothing => 'jeszcze nic nie zapisano';

  @override
  String menuHintOnGoal(int ok, int total) {
    return 'w normie $ok z $total';
  }

  @override
  String get menuHintRecipes => 'od Nory, pod twoją normę';

  @override
  String get menuHintWeekFriday => 'od piątku, 18:00';

  @override
  String get menuHintWeekOpen => 'otwarte do niedzieli';

  @override
  String get menuHintWeekYoung => 'tydzień dopiero się zaczął';

  @override
  String get menuMeds => 'Leki';

  @override
  String get menuPlan => 'Subskrypcja';

  @override
  String get menuRecipes => 'Przepisy';

  @override
  String get menuSettings => 'Ustawienia';

  @override
  String get menuTitle => 'Menu';

  @override
  String get menuWeek => 'Analiza tygodnia';

  @override
  String get noraName => 'Nora';

  @override
  String get normAuto => 'Licz automatycznie';

  @override
  String get normAutoFrom => 'Z wagi na starcie celu, wzrostu, wieku, aktywności i tempa: ';

  @override
  String normAutoHint(String kcal) {
    return 'z wagi, wzrostu, wieku, aktywności i celu: $kcal';
  }

  @override
  String get normAutoShort => 'Automatycznie';

  @override
  String get normByHand => 'Ustaw ręcznie';

  @override
  String get normByHandHint => 'statystyki będą liczyć względem tej liczby';

  @override
  String get normByHandShort => 'Ręcznie';

  @override
  String get normCalculatedHead => 'Wartość wyliczona ';

  @override
  String get normCalculatedTail => '. Można do niej wrócić, wybierając „Automatycznie”.';

  @override
  String get normFitCarbs => 'Dopasuj węglowodany do normy';

  @override
  String get normFits => 'Skład zgadza się z normą';

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
  String get normMacros => 'Makro';

  @override
  String get normManual => 'ustawione ręcznie';

  @override
  String normOf(String kcal) {
    return 'z $kcal';
  }

  @override
  String normOffOver(String sum, int off) {
    return 'Skład daje $sum, o $off więcej niż norma';
  }

  @override
  String normOffUnder(String sum, int off) {
    return 'Skład daje $sum, o $off mniej niż norma';
  }

  @override
  String normPerDay(Object u) {
    return '$u dziennie';
  }

  @override
  String get normTitle => 'Norma';

  @override
  String get normWater => 'Woda';

  @override
  String get normWaterHead => 'To ';

  @override
  String normWaterPerKg(String ml) {
    return '$ml';
  }

  @override
  String get normWaterTail =>
      ' na kilogram masy ciała. Zwykły orientacyjny przedział to 30-40 ml, ale zależy od upału i treningów, więc liczba nie jest sztywna.';

  @override
  String get normWhere => 'Skąd ta liczba';

  @override
  String get notifyChannel => 'Przypomnienia';

  @override
  String get notifyChannelHint => 'Przypomnienia o jedzeniu, wodzie, lekach i ważeniu';

  @override
  String get notifyDenied =>
      'Telefon nie zezwolił na powiadomienia. Włącz je w ustawieniach systemu, a przypomnienia ruszą.';

  @override
  String get photoDish => 'Danie';

  @override
  String get photoNotRecognized => 'Nie rozpoznałam dania na tym zdjęciu';

  @override
  String get planBuy => 'Wykup';

  @override
  String get planClose => 'Zamknij';

  @override
  String get planCurrent => 'aktualny';

  @override
  String get planFailed => 'Zakup się nie powiódł';

  @override
  String get planFree => 'Bezpłatny';

  @override
  String planFrom(String plan, String date) {
    return '$plan od $date';
  }

  @override
  String planFromShort(String date) {
    return 'od $date';
  }

  @override
  String get planLater => 'Nie teraz';

  @override
  String get planManage => 'Zarządzaj w sklepie';

  @override
  String get planMonth => 'Miesiąc';

  @override
  String get planMonthBilled => 'opłata co miesiąc';

  @override
  String get planMonthly => 'Pro miesięczna';

  @override
  String get planNext => 'Dalej';

  @override
  String get planNothingToRestore => 'Na tym koncie nie ma zakupów';

  @override
  String get planNow => 'Teraz';

  @override
  String get planOn => 'Pro';

  @override
  String get planPerMonth => '/mies.';

  @override
  String get planPerkChat => 'Rozmowy z Norą bez ograniczeń';

  @override
  String get planPerkChatSub => 'teraz jedna wiadomość to jeden token';

  @override
  String get planPerkMemory => 'Spersonalizowana pamięć Nory';

  @override
  String get planPerkMemorySub => 'nowe zapamiętuje w rozmowie, a rozmowa kosztuje token';

  @override
  String get planPerkPhoto => 'Zdjęcia dań bez limitu';

  @override
  String get planPerkPhotoSub => 'teraz zdjęcie kosztuje dwa tokeny';

  @override
  String get planPerkRecipes => 'Przepisy od Nory bez limitu';

  @override
  String get planPerkRecipesSub => 'teraz dobór dań kosztuje jeden token';

  @override
  String get planPerkWeek => 'Analiza tygodnia kiedy chcesz';

  @override
  String get planPerkWeekSub => 'teraz analiza kosztuje dwa tokeny';

  @override
  String get planPerks => 'Co daje subskrypcja';

  @override
  String get planPlan => 'Plan';

  @override
  String get planPrivacy => 'Polityka prywatności';

  @override
  String get planRenewal =>
      'Subskrypcja odnawia się sama, dopóki jej nie anulujesz. Anulować można w każdej chwili w ustawieniach sklepu, w którym została wykupiona.';

  @override
  String get planRenews => 'Odnowi się';

  @override
  String get planRestore => 'Przywróć zakupy';

  @override
  String get planSignInGo => 'Zaloguj się';

  @override
  String get planSignInNote =>
      'Subskrypcja jest przypisana do konta z adresem e-mail. Dzięki temu nie zginie przy zmianie telefonu i będzie na wszystkich twoich urządzeniach.';

  @override
  String get planSignInTitle => 'Najpierw zaloguj się do profilu';

  @override
  String get planStoreAsking => 'Pytam sklep o ceny…';

  @override
  String get planStoreOffline => 'Sklep nie odpowiada. Sprawdź połączenie z internetem';

  @override
  String get planStoreQuiet => 'Sklep nie odpowiada. Spróbuj później';

  @override
  String get planSwitchMonth => 'Przejdź na miesięczną';

  @override
  String get planSwitchYear => 'Przejdź na roczną';

  @override
  String get planTariffs => 'Plany';

  @override
  String get planTerms => 'Warunki korzystania';

  @override
  String get planTitle => 'Subskrypcja';

  @override
  String get planTokens => 'Tokeny';

  @override
  String get planTokensFree => '40 miesięcznie';

  @override
  String get planTokensPro => 'Bez ograniczeń';

  @override
  String get planUntil => 'Ważna do';

  @override
  String get planYear => 'Rok';

  @override
  String planYearBilled(String price) {
    return '$price raz w roku';
  }

  @override
  String get planYearly => 'Pro roczna';

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
  String get plateThinking => 'myślę';

  @override
  String get plateTotal => 'razem';

  @override
  String get privacyCrash => 'Raporty o awariach';

  @override
  String get privacyCrashHint => 'stos błędu, bez danych z dziennika';

  @override
  String get privacyDiaryHead => 'Dziennik zostaje u ciebie';

  @override
  String get privacyDiarySub => 'ani dania, ani waga nie idą do statystyk';

  @override
  String get privacyHealthHead => 'Zdrowie nie trafia do nikogo';

  @override
  String get privacyHealthSub => 'alergie i leki nie opuszczają aplikacji';

  @override
  String get privacyNoPhotosHead => 'Zdjęcia dań nie są przechowywane';

  @override
  String get privacyNoPhotosSub => 'zdjęcie idzie do analizy i znika';

  @override
  String get privacyNotCollected => 'Czego nie zbieramy';

  @override
  String get privacyOptional => 'Co można wyłączyć';

  @override
  String get privacyPhotosBold => 'nie są przechowywane';

  @override
  String get privacyPhotosHead => 'Zdjęcia dań ';

  @override
  String get privacyPhotosTail =>
      ': zdjęcie idzie do analizy i znika. Do statystyk nie trafiają ani dania, ani waga, ani alergie, ani leki. To szczególna kategoria danych osobowych i nie wolno jej oddawać stronie trzeciej niezależnie od wygody.';

  @override
  String get privacyStats => 'Anonimowa statystyka';

  @override
  String get privacyStatsHint => 'które ekrany się otwiera, bez treści wpisów';

  @override
  String get privacyTitle => 'Prywatność';

  @override
  String get profileActivity => 'Aktywność';

  @override
  String get profileAge => 'Wiek';

  @override
  String get profileHeight => 'Wzrost';

  @override
  String get profileSex => 'Płeć';

  @override
  String rcAllergyWarn(String names) {
    return 'W składzie jest $names, a to twój alergen. Ostrożnie z tym przepisem.';
  }

  @override
  String get rcAsk => 'Poproś Norę o przepis';

  @override
  String get rcAskAbout => 'Zapytaj Norę o ten przepis';

  @override
  String get rcAskCancel => 'Anuluj';

  @override
  String get rcAskGo => 'Zapytaj';

  @override
  String get rcAskPlaceholder => 'kurczak, brokuły, ryż';

  @override
  String get rcAskTitle => 'Co masz w kuchni?';

  @override
  String get rcAsking => 'Myślę…';

  @override
  String rcChatGreet(String name) {
    return 'Pytaj o „$name”: czym zastąpić produkt, jak nie zepsuć, co zrobić wcześniej. Podpowiem na bieżąco.';
  }

  @override
  String get rcChatPlaceholder => 'Zapytaj o ten przepis';

  @override
  String rcCount(int n) {
    return '$n przepisów';
  }

  @override
  String rcCountFew(int n) {
    return '$n przepisy';
  }

  @override
  String get rcCountOne => '1 przepis';

  @override
  String rcDeleteBody(String name) {
    return '„$name” zniknie z książki. Wpisy w dzienniku zrobione na jego podstawie zostaną.';
  }

  @override
  String get rcDeleteCta => 'Usuń';

  @override
  String get rcDeleteFailed => 'Nie udało się usunąć. Spróbuj jeszcze raz.';

  @override
  String get rcDeleteTitle => 'Usunąć przepis?';

  @override
  String get rcEmpty =>
      'Tu jest pusto. Powiedz Norze, co masz w kuchni, a pojawi się pierwszy przepis.';

  @override
  String get rcEmptyMine =>
      'Nie ma jeszcze własnych przepisów. Podyktuj Norze dowolny, a stanie tutaj.';

  @override
  String get rcEyebrow => 'Kuchnia';

  @override
  String get rcFromMine => 'Mój';

  @override
  String get rcFromNora => 'Od Nory';

  @override
  String get rcHeroA => 'Co ugotować';

  @override
  String get rcHeroB => 'dzisiaj';

  @override
  String get rcHeroLede =>
      'Powiedz, co masz w domu. Nora podpowie i policzy porcję; własny przepis też można podyktować.';

  @override
  String get rcItemsHead => 'Produkty';

  @override
  String rcItemsTotal(String g) {
    return 'razem $g';
  }

  @override
  String get rcJustNow => 'przed chwilą';

  @override
  String get rcLoadFailed =>
      'Książka przepisów się nie wczytała. Pociągnij, żeby spróbować jeszcze raz.';

  @override
  String rcMinutes(int n) {
    return '$n min';
  }

  @override
  String get rcNoTools => 'Nic poza nożem i miską';

  @override
  String rcOfDay(int p) {
    return 'to $p% normy dziennej';
  }

  @override
  String get rcPerServing => 'na porcję';

  @override
  String get rcPerServingHead => 'Na porcję';

  @override
  String get rcPickTitle => 'Wybierz danie';

  @override
  String rcPortion(String g) {
    return 'porcja $g';
  }

  @override
  String rcServingsFew(int n) {
    return '$n porcje';
  }

  @override
  String rcServingsMany(int n) {
    return '$n porcji';
  }

  @override
  String get rcServingsOne => '1 porcja';

  @override
  String get rcStepsHead => 'Jak przygotować';

  @override
  String get rcSuggestFailed => 'Nora nie zdołała ułożyć przepisów. Spróbuj jeszcze raz.';

  @override
  String get rcTabAll => 'Wszystkie';

  @override
  String get rcTabMine => 'Moje';

  @override
  String get rcTabNora => 'Od Nory';

  @override
  String get rcTitle => 'Przepisy';

  @override
  String get rcToolBlender => 'Blender';

  @override
  String get rcToolGrill => 'Grill';

  @override
  String get rcToolMixer => 'Mikser';

  @override
  String get rcToolOven => 'Piekarnik';

  @override
  String get rcToolPan => 'Patelnia';

  @override
  String get rcToolPot => 'Garnek';

  @override
  String get rcToolsHead => 'Potrzebne w kuchni';

  @override
  String rcWhole(String kcal, String g) {
    return 'Całe danie: $kcal, $g';
  }

  @override
  String get remAbout => 'O czym';

  @override
  String get remAdd => 'Dodaj przypomnienie';

  @override
  String get remAt => 'O której';

  @override
  String get remDelete => 'Usuń przypomnienie';

  @override
  String get remEdit => 'Przypomnienie';

  @override
  String get remEmpty => 'Na razie żadnego przypomnienia.';

  @override
  String get remEmptyHint => 'Dodaj to, o czym naprawdę zapominasz, a nie wszystko po kolei';

  @override
  String get remHowOften => 'Jak często';

  @override
  String get remName => 'Nazwa';

  @override
  String get remNew => 'Nowe przypomnienie';

  @override
  String get remOpenMeds => 'Otwórz leki';

  @override
  String get remTime => 'Godzina';

  @override
  String get remTitle => 'Przypomnienia';

  @override
  String get reminderBodyMeal => 'Zapisz, co było';

  @override
  String get reminderBodyMeds => 'Według harmonogramu';

  @override
  String get reminderBodySummary => 'Czego dziś nie zapisano?';

  @override
  String get reminderBodyWater => 'Czas się napić';

  @override
  String get reminderBodyWeigh => 'Rano, przed jedzeniem';

  @override
  String get reminderBodyWorkout => 'Zapisz, jeśli był';

  @override
  String get reminderMeal => 'Jedzenie';

  @override
  String get reminderMealHint => 'przypomnę o zapisaniu posiłku';

  @override
  String get reminderMeds => 'Leki';

  @override
  String get reminderMedsHint => 'według harmonogramu z dziennika';

  @override
  String get reminderSummary => 'Podsumowanie dnia';

  @override
  String get reminderSummaryHint => 'krótko o dniu przed snem';

  @override
  String get reminderWater => 'Woda';

  @override
  String get reminderWaterHint => 'przypomnę o piciu';

  @override
  String get reminderWeigh => 'Ważenie';

  @override
  String get reminderWeighHint => 'żeby wykres wagi się nie rwał';

  @override
  String get reminderWorkout => 'Trening';

  @override
  String get reminderWorkoutHint => 'przypomnę o zaplanowanym';

  @override
  String get repDaily => 'codziennie';

  @override
  String repEveryN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'co $count dnia',
      many: 'co $count dni',
      few: 'co $count dni',
      one: 'co $count dzień',
    );
    return '$_temp0';
  }

  @override
  String get repEveryOther => 'co drugi dzień';

  @override
  String get repPickDaily => 'Codziennie';

  @override
  String get repPickFromToday => 'Liczone od dzisiaj.';

  @override
  String get repPickInterval => 'Co drugi dzień';

  @override
  String get repPickNoDays => 'Nie wybrano żadnego dnia, więc przypomnienie się nie włączy.';

  @override
  String get repPickWeekdays => 'Dni tygodnia';

  @override
  String get repWeekdays => 'w dni robocze';

  @override
  String get repWeekends => 'w weekendy';

  @override
  String get repWeekly => 'raz w tygodniu';

  @override
  String get restoredBody1 =>
      'To konto czekało na usunięcie. Logowanie to anulowało: dziennik, profil i ustawienia znów są na tym telefonie.';

  @override
  String get restoredBody2 =>
      'Jeśli konto mimo wszystko trzeba usunąć, poproś o to jeszcze raz w ustawieniach. Każde logowanie przed naszym potwierdzeniem tak samo anuluje prośbę.';

  @override
  String get restoredOk => 'Rozumiem';

  @override
  String get restoredTitle => 'Dane przywrócone';

  @override
  String get setAbout => 'O aplikacji';

  @override
  String get setAccess => 'Dostęp';

  @override
  String get setAllergies => 'Alergie';

  @override
  String setAssistantLine(String name, int count) {
    return '$name, w pamięci $count';
  }

  @override
  String get setDeleteAccount => 'Usuń konto i dane';

  @override
  String get setFreeTierHead =>
      'Dla obrońców Ukrainy, pracowników Sił Zbrojnych, służb ratunkowych, DTEK, medyków, wolontariuszy i nauczycieli stref przyfrontowych plan jest ';

  @override
  String get setFreeTierHow => ' Jak otrzymać';

  @override
  String get setFreeTierShort =>
      'Dla obrońców Ukrainy, pracowników Sił Zbrojnych, służb ratunkowych, DTEK, medyków, wolontariuszy i nauczycieli stref przyfrontowych plan jest BEZPŁATNY';

  @override
  String get setFreeTierTelegram => 'Napisz na Telegramie';

  @override
  String get setFreeTierTitle => 'Plan bezpłatny';

  @override
  String get setFreeTierWord => 'BEZPŁATNY';

  @override
  String get setFreeTierWrite => 'Napisz do dewelopera, a jeszcze dziś aktywujemy płatny plan.';

  @override
  String get setGoal => 'Cel';

  @override
  String get setGoalKeep => 'utrzymać wagę';

  @override
  String setGoalLine(String kg, String pace) {
    return '$kg, $pace/tydzień';
  }

  @override
  String get setGroupAbout => 'O tobie';

  @override
  String get setGroupAccount => 'Konto';

  @override
  String get setGroupAssistant => 'Asystentka';

  @override
  String get setGroupDocs => 'Dokumenty';

  @override
  String get setGroupHealth => 'Zdrowie';

  @override
  String get setLang => 'Język';

  @override
  String get setMedical => 'Zastrzeżenie medyczne';

  @override
  String get setMeds => 'Leki';

  @override
  String get setNorm => 'Norma';

  @override
  String setNormLine(String kcal) {
    return '$kcal';
  }

  @override
  String get setPlan => 'Subskrypcja';

  @override
  String get setPlanFree => 'Za darmo';

  @override
  String get setPolicy => 'Polityka prywatności';

  @override
  String get setPrivacy => 'Dane i statystyki';

  @override
  String get setProfile => 'Profil';

  @override
  String setProfileLine(String sex, int age, String height) {
    return '$sex, $age, $height';
  }

  @override
  String get setReminders => 'Przypomnienia';

  @override
  String get setRemindersOff => 'wyłączone';

  @override
  String get setTerms => 'Warunki korzystania';

  @override
  String get setTheme => 'Motyw';

  @override
  String get setTitle => 'Ustawienia';

  @override
  String get setUnits => 'Jednostki';

  @override
  String get setUnset => 'nie podano';

  @override
  String get sexOther => 'Inna';

  @override
  String get sexShortFemale => 'K';

  @override
  String get sexShortMale => 'M';

  @override
  String get slotBreakfast => 'Śniadanie';

  @override
  String get slotByHand => 'Wpisz liczby samodzielnie';

  @override
  String get slotCancel => 'Anuluj';

  @override
  String get slotDinner => 'Kolacja';

  @override
  String slotEraseBody(String name) {
    return '„$name” stoi bez liczb. Wiersz zniknie z dnia.';
  }

  @override
  String get slotEraseDo => 'Usuń';

  @override
  String get slotEraseTitle => 'Usunąć szkic?';

  @override
  String slotGrams(Object u) {
    return 'WAGA, $u';
  }

  @override
  String get slotIntoBreakfast => 'na śniadanie';

  @override
  String get slotIntoDinner => 'na kolację';

  @override
  String get slotIntoLunch => 'na obiad';

  @override
  String slotIntoOther(String name) {
    return 'do „$name”';
  }

  @override
  String get slotIntoSnack => 'na przekąskę';

  @override
  String slotKcal(Object u) {
    return '$u';
  }

  @override
  String get slotLog => 'Zapisz';

  @override
  String get slotLunch => 'Obiad';

  @override
  String get slotSnack => 'Przekąska';

  @override
  String get slotWriteWhat => 'Napisz, co było';

  @override
  String get startAbout => 'O tobie';

  @override
  String get startAge => 'Wiek';

  @override
  String startAgeYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count roku',
      many: '$count lat',
      few: '$count lata',
      one: '$count rok',
    );
    return '$_temp0';
  }

  @override
  String get startAgreeAnd => ' i ';

  @override
  String get startAgreeHead => 'Zgadzam się z ';

  @override
  String get startAgreePrivacy => 'polityką prywatności';

  @override
  String get startAgreeTerms => 'warunkami korzystania';

  @override
  String get startDeviceFirstRun => 'pierwsze uruchomienie';

  @override
  String get startGoal => 'Dokąd idziemy';

  @override
  String get startGoalGain => 'Przytyć';

  @override
  String get startGoalGainHint => 'nadwyżka pod wybrane tempo';

  @override
  String get startGoalKeep => 'Utrzymać wagę';

  @override
  String get startGoalKeepHint => 'ile wydajesz, tyle wracasz';

  @override
  String get startGoalLose => 'Schudnąć';

  @override
  String get startGoalLoseHint => 'deficyt pod wybrane tempo';

  @override
  String get startHeight => 'Wzrost';

  @override
  String get startLife => 'Tryb życia';

  @override
  String get startNorm => 'Twoja norma';

  @override
  String get startNormCounting => 'liczę…';

  @override
  String get startNormHold => 'utrzymujemy';

  @override
  String get startNormNote =>
      'To wyliczenie według wzoru Mifflina-St Jeora, a nie zalecenie lekarskie. Jeśli masz chorobę, jesteś w ciąży albo masz przepisaną dietę, skonsultuj się z lekarzem.';

  @override
  String startNormPerDay(Object u) {
    return '$u dziennie';
  }

  @override
  String get startNormWeeks => 'tygodni';

  @override
  String get startPace => 'Jak szybko';

  @override
  String get startPaceEtaHead => 'Cel mniej więcej ';

  @override
  String get startPaceEtaTail => ', to ';

  @override
  String get startPaceFast => 'szybko';

  @override
  String get startPaceSlow => 'wolno';

  @override
  String startPaceUnit(Object u) {
    return '$u na tydzień';
  }

  @override
  String get startPaceUsual => 'zwyczajnie';

  @override
  String get startPaceWarning =>
      'Takie tempo trudno utrzymać i zwykle się urywa. Poniżej 0,8 kg na tydzień efekt idzie wolniej, ale zostaje.';

  @override
  String startPaceWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tygodnia',
      many: '$count tygodni',
      few: '$count tygodnie',
      one: '$count tydzień',
    );
    return '$_temp0';
  }

  @override
  String get startSex => 'Płeć';

  @override
  String get startSexFemale => 'Kobieta';

  @override
  String get startSexMale => 'Mężczyzna';

  @override
  String get startSexOther => 'Inna';

  @override
  String get startSignInApple => 'Kontynuuj z Apple';

  @override
  String get startSignInBackText =>
      'Zaloguj się tym samym kontem, a wszystko wróci na miejsce: dziennik, cel, norma i pomiary. Nie trzeba nic wypełniać od nowa.';

  @override
  String get startSignInBackTitle => 'Witaj z powrotem';

  @override
  String get startSignInBusy => 'Logowanie…';

  @override
  String get startSignInFailed =>
      'Nie udało się zalogować. Spróbuj jeszcze raz albo idź dalej bez logowania.';

  @override
  String startSignInFailedWhy(String why) {
    return 'Nie udało się zalogować. $why';
  }

  @override
  String get startSignInGoogle => 'Kontynuuj z Google';

  @override
  String get startSignInSkip => 'Dalej bez konta';

  @override
  String get startSignInText =>
      'Norma policzona. Zaloguj się, żeby została przy tobie: historia, pomiary i wpisy będą na wszystkich urządzeniach, a nie tylko tutaj.';

  @override
  String get startSignInTitle => 'Zachowajmy to';

  @override
  String get startTargetWeight => 'Waga docelowa';

  @override
  String get startWeightNow => 'Waga teraz';

  @override
  String get startYearsShort => 'lat';

  @override
  String get storageBroken =>
      'Nie udało się otworzyć pamięci. Wpisy są na miejscu, ale nie ma czym ich teraz pokazać.';

  @override
  String get themeAquarelle => 'Akwarela';

  @override
  String get themeAquarelleHint => 'jasny, z pastelowymi chmurami w tle';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get themeDarkHint => 'zawsze ciemny interfejs';

  @override
  String get themeDawn => 'Świt';

  @override
  String get themeDawnHint => 'jasny, z ciepłym światłem z boku';

  @override
  String get themeLight => 'Jasny';

  @override
  String get themeLightHint => 'zawsze jasny interfejs';

  @override
  String get themeSectionLook => 'Wygląd';

  @override
  String get themeSystem => 'Motyw urządzenia';

  @override
  String get themeSystemHint => 'słucha ustawień systemu';

  @override
  String get todayBarcode => 'Kod kreskowy';

  @override
  String todayCodeTalk(String code) {
    return 'Zeskanowałem kod $code, nie ma go w bazach. Nic nie zapisuj: dopytaj mnie o ten produkt albo podpowiedz, jak go policzyć.';
  }

  @override
  String get todayDone => 'Gotowe.';

  @override
  String get todayFailedRetry => 'Nie udało się. Spróbuj jeszcze raz za minutę.';

  @override
  String get todayGoalMet =>
      'Gratulacje! 🎉 Waga, o którą chodziło, jest twoja, cel zamknięty. I zrobiłeś to ty, nie aplikacja. Przestawiam teraz normę na utrzymanie, żeby wynik z tobą został.';

  @override
  String todayHowManyGrams(String dish) {
    return 'Ile gramów było: $dish?';
  }

  @override
  String get todayLogFailed => 'Nie udało się zapisać. Spróbuj jeszcze raz.';

  @override
  String get todayLogged => 'Zapisałam.';

  @override
  String todayLoggedAskWeight(String slotInto) {
    return 'Zapisałam $slotInto. Podaj wagę, jeśli chcesz dokładniej.';
  }

  @override
  String get todayLoggedAskWeightShort => 'Zapisałam. Podaj wagę, jeśli chcesz dokładniej.';

  @override
  String todayLoggedCount(int count) {
    return 'Zapisano $count';
  }

  @override
  String todayLoggedInto(String slotInto, String dish) {
    return 'Zapisałam $slotInto: $dish.';
  }

  @override
  String todayLoggedIntoWithNumbers(String slotInto, String dish, String kcal, String grams) {
    return 'Zapisałam $slotInto: $dish, $kcal za $grams.';
  }

  @override
  String get todayNoraSlow =>
      'Nora myśli dłużej niż zwykle. Spróbuj jeszcze raz, token nie został pobrany.';

  @override
  String get todayOffline => 'Nie mam sieci. Spróbuj jeszcze raz, gdy wróci.';

  @override
  String get todayOfflineSaved =>
      'Nie mam sieci. Wpis zostanie na telefonie i pojedzie, gdy wróci.';

  @override
  String get todayOutOfBody =>
      'Na razie milczę, ale wpisywać ręcznie możesz zawsze, i to za darmo. Subskrypcja włącza mnie z powrotem i kosztuje tyle, co trzy kawy miesięcznie.';

  @override
  String get todayOutOfPlan => 'Subskrypcja';

  @override
  String get todayOutOfTokens => 'Tokeny się skończyły.';

  @override
  String get todayPhotoMeal => 'Zdjęcie';

  @override
  String get todayQuestionClosed =>
      'To pytanie jest już zamknięte. Podaj wagę słowami, jeśli trzeba.';

  @override
  String get tourCamera => 'Aparat';

  @override
  String get tourCameraHow => 'talerz, etykieta albo kod kreskowy';

  @override
  String get tourDiary => 'Pamięć dziennika';

  @override
  String get tourDiaryHow => 'powiesz „barszcz” i weźmie zwykłą porcję';

  @override
  String get tourGuide => 'Przewodnik po aplikacji';

  @override
  String get tourGuideHow => 'zapytaj, gdzie co jest i jak to zrobić';

  @override
  String get tourMemory => 'Stała pamięć';

  @override
  String get tourMemoryHow => '„nie jem wieprzowiny” wystarczy raz';

  @override
  String get tourMore => 'Nie tylko jedzenie';

  @override
  String get tourMoreHow => 'woda, treningi, pomiary, przepisy';

  @override
  String get tourTitle => 'Co potrafi Nora';

  @override
  String get tourVoice => 'Głos albo tekst';

  @override
  String get tourVoiceHow => '„dwa jajka i tost” i wpis gotowy';

  @override
  String get tourWeek => 'Analiza dnia i tygodnia';

  @override
  String get tourWeekHow => 'co wyszło i co warto poprawić';

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
  String get unitsEnergy => 'Energia';

  @override
  String get unitsLength => 'Wzrost i obwody';

  @override
  String get unitsMass => 'Masa ciała';

  @override
  String get unitsPortion => 'Porcje jedzenia';

  @override
  String get unitsTitle => 'Jakie jednostki';

  @override
  String get unitsVolume => 'Woda';

  @override
  String get watchLinked => 'połączony, dane aktualne';

  @override
  String get watchNotInstalled => 'aplikacja nie jest zainstalowana na zegarku';

  @override
  String get watchWaiting => 'połączony, czeka na dane';

  @override
  String waterGlasses(int glasses) {
    return 'około $glasses szklanek';
  }

  @override
  String waterLess(String step) {
    return 'Mniej o $step';
  }

  @override
  String waterMore(String step) {
    return 'Więcej o $step';
  }

  @override
  String get waterNone => 'nic nie wypito';

  @override
  String waterOf(String ml) {
    return ' / $ml';
  }

  @override
  String waterShare(int pct) {
    return '$pct% celu dziennego';
  }

  @override
  String get waterTitle => 'Woda';

  @override
  String get wcNoTime => 'bez czasu trwania';

  @override
  String get wdFri => 'Pt';

  @override
  String get wdMon => 'Pn';

  @override
  String get wdSat => 'So';

  @override
  String get wdSun => 'Nd';

  @override
  String get wdThu => 'Cz';

  @override
  String get wdTue => 'Wt';

  @override
  String get wdWed => 'Śr';

  @override
  String get weightHint => 'Ile ważysz dzisiaj. Cel i tempo do niego są osobno.';

  @override
  String get weightNote =>
      'Zapisuj wagę rano, przed jedzeniem: wtedy dobowe wahania nie zamieniają wykresu w szum. Jeden pomiar w tygodniu już daje trend.';

  @override
  String get weightTitle => 'Waga';

  @override
  String get welEggs => 'Jajecznica z dwóch jajek';

  @override
  String get welEggsGrams => '120 g';

  @override
  String get welHaveAccount => 'Mam już konto';

  @override
  String get welLead => 'Liczy kalorie z twoich słów';

  @override
  String get welSaid => 'Zjadłem dwa jajka i tost';

  @override
  String get welStart => 'Zacznij';

  @override
  String get welToast => 'Tost z masłem';

  @override
  String get welToastGrams => '50 g';

  @override
  String get welTotal => 'Razem';

  @override
  String wfBurned(Object u) {
    return 'Spalone, $u';
  }

  @override
  String get wfDuration => 'Czas trwania';

  @override
  String get wfDurationCap => 'Czas trwania, min';

  @override
  String get wfEstimate => 'Szacunek na podstawie twojej wagi i rodzaju aktywności';

  @override
  String get wfFromWatch => 'Z zegarka albo sprzętu';

  @override
  String wfKcal(Object u) {
    return ' $u';
  }

  @override
  String get wfLog => 'Zapisz';

  @override
  String wfManualKcal(Object u) {
    return 'Ręcznie $u';
  }

  @override
  String wfMin(int min) {
    return '$min min';
  }

  @override
  String get wfMinutes => 'Minuty';

  @override
  String get wfNote => 'Notatka';

  @override
  String get wfNoteExample => 'Nogi, ciężko';

  @override
  String get wfOptional => '  opcjonalnie';

  @override
  String get wheelLess => 'Mniej';

  @override
  String get wheelMore => 'Więcej';

  @override
  String get wkDaysOk => 'dni w normie';

  @override
  String get wkEmpty =>
      'W tym tygodniu nic jeszcze nie zapisano. Zapisz pierwszy dzień, a pojawi się obraz całości.';

  @override
  String get wkFactsHead => 'Razem w tygodniu';

  @override
  String get wkKcalHead => 'Kalorie';

  @override
  String get wkLoggedCap => 'dni zapisano';

  @override
  String wkLoggedValue(int n) {
    return '$n z 7';
  }

  @override
  String get wkMacroHead => 'Makro';

  @override
  String get wkNoWeight => 'waga: brak ważeń';

  @override
  String get wkNoraBtn => 'Zrób podsumowanie';

  @override
  String wkNoraFailed(String why) {
    return 'Nie udało się zrobić podsumowania: $why';
  }

  @override
  String get wkNoraGreet =>
      'Pytaj o wszystko z tego podsumowania: o danie, o nawyk albo o to, co poprawić najpierw.';

  @override
  String get wkNoraLoading => 'Nora czyta twój tydzień…';

  @override
  String get wkNoraLocked => 'Podsumowanie będzie dostępne w piątek';

  @override
  String get wkNoraNoNet => 'brak sieci';

  @override
  String get wkNoraNoTokens => 'skończyły się tokeny';

  @override
  String get wkNoraP1 =>
      'Podstawa jest zdrowa, a to rzadkość: prawie wszystko domowe. Barszcz, jajecznica, owsianka: na takiej bazie reszta poprawia się szybko.';

  @override
  String get wkNoraP2 =>
      'Teraz szczerze. Warzyw przez cały tydzień prawie nie było, a słodkie było codziennie: naleśniki z miodem, kompot. Białka brakuje nie dlatego, że jesz mało, tylko dlatego, że na talerzu dużo węglowodanów, a mało mięsa, ryby czy sera. I trzy kolacje z siedmiu wypadły po dwudziestej drugiej.';

  @override
  String get wkNoraP3 =>
      'Na razie nic groźnego, ale właśnie tak wygląda jadłospis, który po czterdziestce zaskakuje wynikami badań. Jeden krok na następny tydzień, reszty nie zmieniaj: coś zielonego do każdego obiadu, a zamiast kompotu woda.';

  @override
  String get wkNoraPlaceholder => 'Zapytaj o ten tydzień';

  @override
  String get wkNoraPromise =>
      'Szczery przegląd tygodnia: co się udało, gdzie osiadło i jeden krok na następny.';

  @override
  String get wkNoraReply1 =>
      'Najprostsza zamiana w tym tygodniu: kompot na wodę. Łyżka cukru mniej za każdym razem, a barszcz nic nie jest temu winien.';

  @override
  String get wkNoraReply2 =>
      'Zielone do obiadu nie musi być sałatką. Ogórek albo pół papryki obok talerza już robi swoje.';

  @override
  String get wkNoraSlow => 'serwer długo odpowiada';

  @override
  String get wkNoraTalk => 'Porozmawiaj o tym z Norą';

  @override
  String get wkNoraTitle => 'Nora o twoim tygodniu';

  @override
  String get wkNorm => 'norma';

  @override
  String wkOffNorm(String n) {
    return '$n od normy';
  }

  @override
  String get wkPastEmpty =>
      'Nie ma jeszcze poprzednich podsumowań. Pierwsze pojawi się tu w następny poniedziałek.';

  @override
  String wkPastRow(String day) {
    return 'Tydzień od $day';
  }

  @override
  String get wkPastTitle => 'Poprzednie';

  @override
  String wkPerDay(Object u) {
    return '$u średnio na dobę';
  }

  @override
  String get wkPerDayAside => 'średnio na dobę';

  @override
  String get wkTitle => 'Tydzień';

  @override
  String wkTotalCap(Object u) {
    return '$u w tygodniu';
  }

  @override
  String get wkWaterCap => 'wody na dobę';

  @override
  String wkWaterValue(String l) {
    return '$l l';
  }

  @override
  String get wkWeightCap => 'waga w tym tygodniu';

  @override
  String get workoutAdd => 'Dodaj trening';

  @override
  String workoutBurned(String kcal) {
    return '−$kcal';
  }

  @override
  String get workoutCollapse => 'Zwiń';

  @override
  String get workoutMinUnit => 'min';

  @override
  String get workoutNone => 'nic nie zapisano';

  @override
  String workoutSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sesji',
      many: '$count sesji',
      few: '$count sesje',
      one: '$count sesja',
    );
    return '$_temp0';
  }

  @override
  String get workoutTitle => 'Trening';
}
