import '../data/day.dart' show dataLang;
import 'app_localizations.dart';
import 'app_localizations_en.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_uk.dart';

/* Саме поле теж видно звідси: ставить його `main`, а живе воно поряд із
   годинником, бо це така сама одна настройка шару даних. */
export '../data/day.dart' show dataLang;

/// Переклад для місць, куди `BuildContext` не дістає.
///
/// Сповіщення пишуться, коли екрана немає взагалі: їх ставить у чергу телефон, і
/// текст до нього доходить задовго до того, як застосунок відкриють. Так само
/// підписи, які збирає шар даних для самого себе.
///
/// Мова береться з [dataLang], яку ставить `main` при кожній зміні локалі.
/// Створювати обʼєкт щоразу дешево: у згенерованих класах немає ні стану, ні
/// таблиць, самі геттери зі сталими.
///
/// Це **не** заміна `L.of(context)`. Усе, що малює екран, має брати переклад
/// звідти: там він міняється разом із локалою і перемальовується сам.
/* Мова, якої тут немає, дістає англійську: та сама запасна, що й у
   `supportedLocales`. Ланцюжок тернарних тут уже був і саме він давав «la última
   today» в іспанському застосунку: третя мова мовчки падала в англійську. */
L get dataL => switch (dataLang) {
  'uk' => LUk(),
  'es' => LEs(),
  'it' => LIt(),
  'de' => LDe(),
  'fr' => LFr(),
  'pt' => LPt(),
  'pl' => LPl(),
  'cs' => LCs(),
  _ => LEn(),
};
