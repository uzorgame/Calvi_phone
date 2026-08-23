import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/allergens.dart';
import '../../data/chat.dart';
import '../../data/day.dart';
import '../../data/fixtures.dart';
import '../../data/meal.dart';
import '../../data/app_scope.dart';
// Only the handle: the generated row classes carry names the screens already
// use for their own models, and `Workout` is one of them.
import '../../data/local/database.dart' show CalviDb;
import '../../data/local/chat_store.dart';
import '../../data/local/day_reader.dart';
import '../../data/remote/api.dart';
import '../../data/remote/sync_service.dart';
import '../../data/measure.dart';
import '../../data/meds.dart';
import '../../data/settings.dart';
import '../../data/workout.dart';
import '../../design/icons.dart';
import '../../design/theme.dart';
import '../../design/shell.dart';
import '../../design/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/labels.dart';
import '../../design/slide.dart';
import '../analytics/analytics_screen.dart';
import '../camera/camera_screen.dart';
import '../voice/dictation.dart';
import '../voice/voice_overlay.dart';
import 'bottom_bar.dart';
import 'hero_card.dart';
import 'macro_cards.dart';
import 'meal_card.dart';
import 'measure_card.dart';
import 'slot_card.dart';
import 'water_card.dart';
import 'week_strip.dart';
import 'workout_card.dart';

/// Today.
///
/// Top to bottom: the header, the run of days, the day's main card, the three
/// macros, and then the day itself. Navigation lives up here beside the figures
/// rather than in a tab bar, because the bottom belongs to the input field.
class TodayScreen extends StatefulWidget {
  const TodayScreen({
    super.key,
    required this.onSettings,
    required this.onMeds,
    this.chatOpen = false,
    this.openCard,
    this.ask,
  });

  final VoidCallback onSettings;

  /// Only the dev entry passes this, to land straight in the chat.
  final bool chatOpen;

  /// And this, to land with one of the day cards already open.
  final String? openCard;

  /// The fourth macro card opens the medications.
  final VoidCallback onMeds;

  /* Вечірнє питання, з яким відкрили застосунок. Порожньо, коли зайшли самі.
   *
   * Приходить згори, бо порахувати його можна лише над цілим днем, а поставити
   * лише в чаті. Ставиться один раз: питання, яке повторюється на кожній
   * перемальовці, це не питання, а заїкання. */
  final String? ask;

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> with WidgetsBindingObserver {
  /* Переклад під рукою в усьому екрані.
   *
   * Геттером, а не полем: `L.of` тягне залежність від локалі, і збережене в
   * `initState` значення пережило б зміну мови, лишивши на екрані старі написи.
   * Так само не годиться писати `L.of(context)` у кожному з двадцяти місць. */
  L get l => L.of(context);

  int _date = todayDate;

  /// Which way the week was moved, so the day under the strip goes the same way.
  int _dayDir = 0;

  /* Вода і тренування, дописані поверх показового дня.
   *
   * Тільки для демо: фікстури сталі, а день має мінятись, поки на нього
   * дивляться. У режимі «мої» ці два поля не читаються і не пишуться взагалі,
   * бо там усе йде в базу.
   *
   * Раніше туди йшло і в режимі «мої» теж, і це коштувало дорого: людина
   * додавала двісті мілілітрів, закривала застосунок, і вода зникала разом із
   * ним. Записи в базу є, синхронізація на сервер є, не було рівно одного
   * рядка, який поєднує кнопку зі сховищем. */
  final _water = <int, int>{};
  final _extraWorkouts = <int, List<Workout>>{};

  /// Коли саме сталось те, що записують на цей екран.
  ///
  /// Для сьогодні це просто зараз. Для минулого дня це його полудень: час у
  /// записі має лежати всередині свого дня, інакше склянка води за вівторок
  /// опиниться в понеділковій ночі.
  DateTime _when() =>
      _date == todayDate ? DateTime.now() : calendarDay(_date).add(const Duration(hours: 12));
  /* Стрічка вимірювань приходить із бази разом із рештою підсумків.
   *
   * Тут лежав список у памʼяті екрана, і в нього писалось усе, крім ваги: талія,
   * груди, біцепс. Виглядало як записане, показувалось в аналітиці, а після
   * перезапуску зникало без сліду. Найгірший різновид втрати, бо людина
   * дізнавалась про неї не одразу, а через місяць, коли прийшла подивитись на
   * зміну. */
  List<Measure> _measuresFor(AppScope scope) => scope.stats.measures;

  /// Записаний замір: кожне поле в базу, як воно і має бути.
  ///
  /// Пишеться і в режимі «демо». Число, яке людина набрала сантиметром, це її
  /// число, у якому б режимі вона на нього не дивилась, і мовчки викинути його
  /// гірше, ніж показати не там. На екрані демо його не видно, бо там показові
  /// дані, але після перемикання на «мої» воно на місці.
  void _saveMeasure(AppScope scope, Measure m) {
    final db = scope.db;
    if (db == null) return;

    final at = _when();
    Future<void> write() async {
      for (final e in m.values.entries) {
        if (e.key == 'weightKg') {
          await db.diaryDao.setWeight(kg: e.value, at: at);
        } else {
          await db.diaryDao.setMeasure(part: e.key, cm: e.value, at: at);
        }
      }
    }

    /* Вага живе у двох місцях, і обидва мають дізнатись про неї одночасно.
     *
     * У базі це запис зважування, з якого будується крива. У налаштуваннях це
     * поточна вага людини, і саме її показує картка на головному, прогрес до
     * цілі й аналітика. Записувалась досі тільки перша, тому людина ставила 76
     * кг, бачила «75.0» на картці й справедливо вирішувала, що заміри не
     * працюють. Вони працювали, просто про них ніхто не сказав тому, хто малює
     * число. */
    final kg = m['weightKg'];
    if (kg != null && kg != scope.s.weightKg) {
      scope.set((s) => s.copyWith(weightKg: kg));
    }

    unawaited(write().then((_) => scope.sync?.now()));
  }

  /* Розмова піднімається з диска один раз, коли екран народжується. Порожній
     чат після кожного перезапуску виглядав так, ніби помічник забуває все, що
     йому сказали, і в застосунку, який памʼятає звички, це особливо дивно. */
  ChatStore? _chat;

  late bool _chatOpen = widget.chatOpen;

  /// Чи вечірнє питання вже поставлене.
  bool _asked = false;
  late String? _openCard = widget.openCard;
  /* Диктування: звідки вилетіла рідина і чи вона вже пливе назад.
   *
   * Станів саме два, і це навмисне: палець відпустили раніше, ніж накладка
   * зникла. Сказане йде на розбір тієї ж миті, а накладка ще доживає зворотний
   * шлях. */
  ({VoiceOrigin from, bool leaving})? _dictating;

  /* Диктування живе, поки палець на кнопці. Записує з першої мілісекунди
     натискання, а віддає почуте з першої мілісекунди відпускання.
   *
   * Обʼєкт один на застосунок, бо двигун під ним теж один. Створювати свій на
   * кожне натискання означало мати кількох претендентів на один мікрофон, і
   * саме звідти бралися нескінченні системні звуки запису. */
  final Dictation _ears = Dictation.shared;

  /// Чи ми зараз слухаємо.
  ///
  /// Окремим прапорцем, а не «обʼєкт існує»: сеанс лишається зайнятим і поки
  /// він зупиняється, тобто до секунди після того, як палець прибрали.
  bool _listening = false;

  /* Екран запису відкривається не одразу.
   *
   * Тап по мікрофону це промах, а не запис, і показувати заради нього повний
   * екран із рідиною означає блимнути ним ні за чим. Слухати починаємо з першої
   * мілісекунди, а показуємо аж коли стало ясно, що палець таки тримають. */
  Timer? _showing;

  /// Через скільки утримання показуємо екран запису.
  static const _holdBefore = Duration(milliseconds: 200);

  /* Коротше за це не фраза, а промах, навіть якщо екран уже блимнув.
   *
   * Саме лише запізнення показу дірки не закриває: відпускання на двохсот
   * пʼятдесятій мілісекунді встигало показати екран і одразу починало його
   * закривати, тобто блимало анімацією майже секунду. Такий випадок знімається
   * без зворотного шляху, різко: це промах, а не завершена фраза. */
  static const _minPhrase = Duration(milliseconds: 420);

  /// Коли палець ліг на мікрофон.
  DateTime? _heldFrom;

  final _messages = <Msg>[];

  /// Палець ліг на мікрофон. Слухати починаємо тієї ж миті.
  Future<void> _holdMic(Offset at, double size) async {
    /* Ознакою зайнятості тепер є [_listening], а не «обʼєкт існує».
     *
     * Раніше екран обнуляв посилання на початку відпускання і чекав до
     * секунди на останнє слово. Натискання в це вікно проходило повз захист і
     * заводило другий сеанс на тому самому мікрофоні. */
    if (_dictating != null || _listening) return;
    _listening = true;

    _heldFrom = DateTime.now();
    _showing?.cancel();
    _showing = Timer(_holdBefore, () {
      if (!mounted || !_listening) return;
      setState(() => _dictating = (from: VoiceOrigin(at: at, size: size), leaving: false));
    });

    /* Слова нікуди не показуються: людина побачить їх у чаті, коли договорить.
       Показувати їх під час мовлення означало б показувати те, чого ще ніхто не
       розбирав. */
    final ok = await _ears.start(onWords: (_) {});
    if (!mounted || ok) return;

    /* Старт не вдався. Доти про це не дізнавався ніхто: накладка лишалась
       дихати над мікрофоном, якого немає, а кнопка мовчала до перезапуску. */
    _showing?.cancel();
    _listening = false;
    _heldFrom = null;
    setState(() => _dictating = null);
    _micTrouble();
  }

  /// Палець прибрали: запис спиняється, і сказане йде до Нори.
  Future<void> _letGoMic() async {
    /* Друге відпускання того самого натискання нічого не робить: перше вже
       володіє зупинкою і доведе її до кінця. Так буває, коли за `up` приходить
       ще й `cancel`. */
    if (!_listening) return;

    _showing?.cancel();
    _showing = null;

    final held = _heldFrom == null ? Duration.zero : DateTime.now().difference(_heldFrom!);
    _heldFrom = null;

    final was = _dictating;
    if (was == null || held < _minPhrase) {
      /* Палець прибрали надто швидко: це тап, а не фраза. Сеанс кидаємо
         скасуванням, а не зупинкою: зупинка оформила б підсумок і дала зайвий
         системний звук кінця запису заради тексту, який ми однаково викидаємо. */
      _listening = false;
      if (was != null) setState(() => _dictating = null);
      unawaited(_ears.cancel());
      return;
    }

    setState(() => _dictating = (from: was.from, leaving: true));

    final text = (await _ears.stop()).trim();
    _listening = false;
    if (!mounted) return;

    if (text.isEmpty) {
      _micTrouble();
      return;
    }
    _say(msg(from: MsgFrom.me, kind: MsgKind.voice, text: text), noraVoice);
  }

  /// Сказати, чому диктування не вийшло.
  ///
  /// Речення для кожного випадку були написані від початку, і жодне з них не
  /// доходило до екрана: людина бачила смуги, тишу і нічого більше.
  void _micTrouble() {
    final why = _ears.failure;
    if (why == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(why)));
  }

  /* Питання ставиться після кадру: чат має вже існувати, а стрічка домотатись
     до нового рядка, як вона робить це для будь-якої відповіді Нори. */
  void _askEvening() {
    final ask = widget.ask;
    if (ask == null || ask.isEmpty || _asked) return;
    _asked = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _chatOpen = true;
        _messages.add(msg(from: MsgFrom.nora, text: ask));
      });
    });
  }

  void _openAnalytics(BuildContext context) => Navigator.of(context).push(
    slideRoute(
      AnalyticsScreen(measures: _measuresFor(AppScope.of(context)), onSettings: widget.onSettings),
    ),
  );

  void _toggle(String id) => setState(() => _openCard = _openCard == id ? null : id);

  /* One place where anything said to Nora arrives, whatever said it: the field,
     the camera or dictation. Three call sites that each append their own pair of
     messages is three chances for the chat to answer itself differently. */
  void _say(Msg mine, String reply) {
    final waiting = _wait(mine);

    /* Real data means a real answer: the message goes to our server, which
       spends the token, calls the model and writes what it recognised. The
       canned line below is the demo's, and only the demo's. */
    final scope = AppScope.of(context);
    final sync = scope.sync;
    /* Продиктоване це той самий текст: для сервера різниці немає, а для людини
       тим паче. Раніше сюди пускало лише набране з клавіатури, і голос мовчки
       отримував показову відповідь. */
    final typed = mine.kind == MsgKind.text || mine.kind == MsgKind.voice;
    if (scope.real && sync != null && typed) {
      unawaited(_askNora(sync, mine.text, waiting: waiting));
      return;
    }

    /* The answer lands a beat later. Both at once would say the reply was
       already written, which is the one thing a conversation is not. */
    _reply?.cancel();
    _reply = Timer(const Duration(milliseconds: 700), () => _answer(waiting, reply));
  }

  /* Кільце очікування, на місці майбутньої відповіді.
   *
   * Порожній чат на кілька секунд читається як «залагало», і людина тисне ще
   * раз. Тому очікування це не значок збоку, а те саме повідомлення Нори, ще без
   * слів: коли слова приходять, бульбашка доростає з кільця, а не виникає з
   * нічого поруч. */
  void _keep(Msg m, {bool store = true}) {
    _messages.add(m);
    if (store) unawaited(_chat?.save(m) ?? Future.value());
  }

  Msg _wait(Msg mine) {
    final waiting = msg(from: MsgFrom.nora, text: '', pending: true);
    setState(() {
      _keep(mine);
      // Кільце на диск не йде: це стан екрана, а не рядок розмови.
      _keep(waiting, store: false);
      _chatOpen = true;
    });
    return waiting;
  }

  /// Кладе відповідь на місце кільця, не додаючи нової бульбашки.
  void _answer(Msg waiting, String text, {MealPlate? plate, List<int> weights = const []}) {
    if (!mounted) return;
    final at = _messages.indexWhere((m) => m.id == waiting.id);
    if (at < 0) return;

    final said = Msg(
      id: waiting.id,
      from: waiting.from,
      kind: waiting.kind,
      text: text,
      plate: plate,
      /* Три ваги живуть на самому питанні, а не поруч із ним: коли людина
         відповість, вони мають зникнути разом із ним, а не висіти в розмові. */
      weights: weights,
    );
    setState(() => _messages[at] = said);
    unawaited(_chat?.save(said) ?? Future.value());
  }

  /* Обрана вага: один дотик замість набирання.
   *
   * Токен не списується. Питання було не про страву, а про порцію: страву вже
   * розібрано попереднім повідомленням, її числа лежать на сервері, і лишилось
   * помножити їх на вагу. Чекати на модель тут теж немає за чим, тому кільце
   * очікування не ставиться: відповідь приходить одразу.
   */
  Future<void> _pickWeight(String id, int grams) async {
    final scope = AppScope.of(context);
    final sync = scope.sync;
    if (sync == null) return;

    // Кнопки гаснуть тієї ж миті: другий дотик по сусідній вазі був би другим
    // записом тієї самої страви.
    final at = _messages.indexWhere((m) => m.id == id);
    /* Номер питання береться з самої бульбашки: на екрані їх може стояти кілька,
       і відповідь має закрити рівно те, під яким натиснули. */
    final askId = at >= 0 ? _messages[at].askId : null;
    if (at >= 0) setState(() => _messages[at] = _messages[at].picked(grams));

    final mine = msg(from: MsgFrom.me, text: l.gramsUnit(grams));
    setState(() => _messages.add(mine));
    unawaited(_chat?.save(mine) ?? Future.value());

    try {
      final answer = await sync.weigh(
        grams: grams,
        askId: askId,
        slot: _nextSlotId(_dayNow(scope)),
      );
      if (!mounted) return;

      final said = msg(
        from: MsgFrom.nora,
        text: answer.text.isEmpty ? l.todayLogged : answer.text,
        plate: _plateOf(answer.logged),
      );
      setState(() => _messages.add(said));
      unawaited(_chat?.save(said) ?? Future.value());
      unawaited(sync.now());
    } on ApiFailure catch (e) {
      if (!mounted) return;
      final said = msg(
        from: MsgFrom.nora,
        text: switch (e.code) {
          'offline' => l.todayOffline,
          'not_found' => l.todayQuestionClosed,
          _ => l.todayLogFailed,
        },
      );
      setState(() => _messages.add(said));
    }
  }

  /// Те саме, що [_say], але з кадром: знімок їде до моделі разом із
  /// повідомленням, і відповідь приходить у ту саму розмову.
  void _shotToNora(Msg mine, String reply, Shot? shot) {
    final waiting = _wait(mine);

    final scope = AppScope.of(context);
    final sync = scope.sync;

    if (scope.real && sync != null && shot != null) {
      unawaited(_askNora(sync, mine.text, image: shot, waiting: waiting));
      return;
    }

    /* Без кадру або в демо лишається показова відповідь: вигадати розбір знімка
       на телефоні неможливо, а тиша виглядала б як поломка. */
    _reply?.cancel();
    _reply = Timer(const Duration(milliseconds: 700), () => _answer(waiting, reply));
  }

  /* Незнайомий код їде розмовою, а не записом.
   *
   * Записувати нема чого: жодна база продукту не знає, і будь-яке число тут
   * було б вигаданим. Тому в чат іде сам код, Нора розпитує про продукт, і в
   * день лягає лише те, що людина скаже словами. */
  void _codeToNora(String code) {
    final mine = msg(from: MsgFrom.me, kind: MsgKind.barcode, text: l.todayBarcode, code: code);
    final waiting = _wait(mine);

    final scope = AppScope.of(context);
    final sync = scope.sync;
    if (scope.real && sync != null) {
      unawaited(_askNora(sync, l.todayCodeTalk(code), waiting: waiting));
      return;
    }

    _reply?.cancel();
    _reply = Timer(const Duration(milliseconds: 700), () => _answer(waiting, noraCodeTalk));
  }

  /// Пише в день продукт, прочитаний зі штрихкоду.
  ///
  /// Не коштує нічого і не питає нікого: код прочитав сам телефон, числа взяті з
  /// упаковки, і моделі тут робити нічого. У чат лягає рядок, щоб дія не зникла
  /// без сліду, але це наш текст, а не відповідь Нори.
  Future<void> _logScanned(String slot, String code, FoodHit food) async {
    final scope = AppScope.of(context);
    final db = scope.db;
    final plate = food.forGrams();

    /* Не лише «записала», а й факти про продукт: алерген, коли він у списку
       людини, і склад з упаковки. Це не багатослівʼя, а память розмови: ці
       рядки їдуть Норі історією, і «а що там у складі?» наступним повідомленням
       отримує відповідь про саме цей продукт, а не здогадку. */
    final said = StringBuffer(
      l.todayLoggedIntoWithNumbers(
        slotIntoLabel(context, slot),
        food.name,
        plate.kcal,
        plate.grams.round(),
      ),
    );
    if (food.warnContains.isNotEmpty) {
      final names = food.warnContains
          .map((id) => allergenById(id)?.name ?? id)
          .join(', ')
          .toLowerCase();
      said.write(' ${l.camAllergen} ${l.camAllergyContains(names)}');
    }
    if (food.ingredients != null && food.ingredients!.isNotEmpty) {
      final text = food.ingredients!;
      said.write('\n${l.camIngredients(text.length > 300 ? '${text.substring(0, 300)}…' : text)}');
    }

    setState(() {
      _keep(msg(from: MsgFrom.me, kind: MsgKind.barcode, text: l.todayBarcode, code: code));
      _keep(msg(from: MsgFrom.nora, text: said.toString()));
      _chatOpen = true;
    });

    if (!scope.real || db == null) return;

    await db.diaryDao.addMeal(
      slot: _slotIdFor(slot),
      name: food.name,
      kcal: plate.kcal,
      grams: plate.grams,
      protein: plate.protein,
      fat: plate.fat,
      carbs: plate.carbs,
      icon: food.icon,
      canonicalName: food.canonicalName,
      source: 'barcode',
    );

    unawaited(scope.sync?.now() ?? Future.value());
  }

  /// Вода дня. Картка каже, скільки має стати, а не скільки додати.
  void _setWater(AppScope scope, int ml) {
    final db = scope.db;
    if (!scope.real || db == null) {
      setState(() => _water[_date] = ml);
      return;
    }

    /* Без `setState`: екран слухає базу, і число прийде звідти. Намалювати його
       ще й тут означало б мати дві правди про одну склянку. */
    unawaited(db.diaryDao.setWaterTotal(ml, at: _when()).then((_) => scope.sync?.now()));
  }

  /// Тренування дня.
  void _addWorkout(AppScope scope, Workout w) {
    final db = scope.db;
    if (!scope.real || db == null) {
      setState(() => _extraWorkouts.putIfAbsent(_date, () => []).add(w));
      return;
    }

    unawaited(
      db.diaryDao
          .addWorkout(kind: w.activity, minutes: w.minutes, kcal: w.kcal, at: _when())
          .then((_) => scope.sync?.now()),
    );
  }

  /// Cancellable: a reply that outlives the screen is a screen still running.
  Timer? _reply;

  /* Прапорця «Нора думає» тут більше немає.
   *
   * Він лишався з тих часів, коли ним ховали круг у рядку, і саме тому круг
   * зникав разом із питанням. Те, що Нора думає, і так видно: у самого
   * повідомлення є ознака очікування, і кружечок «думаю» малюється з неї. */

  /// Sends what was typed and puts the answer in the thread.
  ///
  /// Every failure has its own sentence: «немає токенів» and «немає мережі» are
  /// different problems and a single «щось пішло не так» teaches nothing.
  /* Останні репліки розмови, які їдуть разом із питанням.
   *
   * Нора питає «скільки це було?», людина відповідає «тарілка», і без цих
   * рядків відповідь приходить без страви, до якої стосується. Беруться дві
   * пари: цього вистачає на уточнення, а переказувати весь день не треба, бо
   * історія рахується як вхідні токени в кожному запиті.
   *
   * Викидається те, чого моделі бачити нема сенсу: щойно надіслане повідомлення
   * (воно і так їде окремо), бульбашка очікування і рядки помилок. */
  List<Map<String, String>> _recent(Msg waiting) {
    final out = <Map<String, String>>[];

    for (final m in _messages.reversed) {
      if (m.id == waiting.id || m.pending || m.code != null) continue;
      if (m.text.trim().isEmpty) continue;
      if (out.length >= 4) break;

      out.add({
        'role': m.from == MsgFrom.me ? 'user' : 'model',
        'text': m.text.length > 1000 ? m.text.substring(0, 1000) : m.text,
      });
    }

    // Зібрано з кінця, а модель читає згори вниз.
    return out.reversed.toList();
  }

  Future<void> _askNora(SyncService sync, String text, {Shot? image, required Msg waiting}) async {
    try {
      final answer = await sync.ask(
        text: text,
        slot: _nextSlotId(_dayNow(AppScope.of(context))),
        image: image,
        history: _recent(waiting),
      );
      if (!mounted) return;

      final line = [
        if (answer.warning != null) answer.warning!,
        if (answer.text.isNotEmpty) answer.text,
      ].join(' ');

      _answer(waiting, line.isEmpty ? l.todayDone : line, plate: _plateOf(answer.logged));

      /* Питання про вагу окремими бульбашками, по одній на страву.
       *
       * Раніше ваги висіли на самій відповіді, тобто набір був один на все
       * повідомлення. Три страви без ваги давали одне питання про останню з них,
       * а перші дві мовчки лишались без грамів.
       *
       * Речення складає застосунок із назви, яку сказала людина, а не модель.
       * Модель на двох стравах писала одне питання на обидві: «скільки грамів
       * було спагеті і тостів?», а одне число не описує двох страв. */
      for (final ask in answer.asks) {
        final question = msg(
          from: MsgFrom.nora,
          text: l.todayHowManyGrams(ask.name),
          weights: ask.weights,
          askId: ask.id,
        );
        setState(() => _messages.add(question));
        unawaited(_chat?.save(question) ?? Future.value());
      }

      /* Вага, записана Норою, має дійти й до картки на головному.
       *
       * Вона живе у двох місцях: рядком зважування, з якого будується крива, і
       * поточним числом у налаштуваннях, яке малює картка і прогрес до цілі.
       * Рядок кладе репозиторій, а число тут: без цього людина чула «записала
       * вагу 77.5» і бачила на екрані стару. */
      // Тільки сьогоднішнє зважування: вчорашнє, записане навздогін, не має
      // ставати поточною вагою.
      final now = DateTime.now();
      final key =
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';

      final weighed = answer.measures.where((m) => m.part == 'weight' && m.day == key).lastOrNull;
      if (weighed != null && weighed.value != AppScope.of(context).s.weightKg) {
        AppScope.of(context).set((s) => s.copyWith(weightKg: weighed.value));
      }

      /* Запамʼятане лягає в налаштування тут же.
       *
       * Сторінка памʼяті читає їх, і чекати на профільну синхронізацію означало
       * б показати порожню сторінку одразу після слів «запамʼятала». Саме це
       * людина й побачила: Нора пообіцяла, сторінка порожня. */
      if (answer.remembered.isNotEmpty) {
        final scope = AppScope.of(context);
        final had = scope.s.memory;
        final fresh = [
          for (final r in answer.remembered)
            if (!had.any((m) => m.id == r.id)) Memo(id: r.id, text: r.text, pinned: r.pinned),
        ];
        final name = answer.remembered
            .map((r) => r.name)
            .firstWhere((n) => n != null && n.isNotEmpty, orElse: () => null);

        if (fresh.isNotEmpty || name != null) {
          scope.set((s) => s.copyWith(memory: [...fresh, ...had], addressAs: name ?? s.addressAs));
        }
      }

      // Whatever was written on the server arrives as an ordinary row.
      unawaited(sync.now());
    } on ApiFailure catch (e) {
      _answer(waiting, switch (e.code) {
        'no_tokens' => l.todayOutOfTokens,
        'offline' => l.todayOfflineSaved,
        'slow' => l.todayNoraSlow,
        _ => l.todayFailedRetry,
      });
    }
  }

  /* Числа записаного, зведені в одну смужку.
   *
   * Одна страва показується сама собою, кілька складаються разом: людина
   * написала одну фразу і чекає на один підсумок, а не на три картки під одним
   * реченням. Порожньо, коли Нора нічого не записала: смужка з нулями під
   * «привіт» це не дані, а шум.
   *
   * Грами додаються тільки якщо їх знають про кожну страву. Інакше «за 210 г»
   * під сумою двох страв, з яких одну зважили, а другу ні, це число, яке ні про
   * що не говорить. */
  MealPlate? _plateOf(List<LoggedMeal> logged) {
    if (logged.isEmpty) return null;

    final grams = logged.every((m) => m.grams != null)
        ? logged.fold<double>(0, (a, m) => a + m.grams!)
        : null;

    return MealPlate(
      name: logged.length == 1 ? logged.first.name : l.todayLoggedCount(logged.length),
      grams: grams,
      kcal: logged.fold<int>(0, (a, m) => a + m.kcal),
      protein: logged.fold<double>(0, (a, m) => a + m.protein).round(),
      fat: logged.fold<double>(0, (a, m) => a + m.fat).round(),
      carbs: logged.fold<double>(0, (a, m) => a + m.carbs).round(),
    );
  }

  /// Writes what was typed into the slot, then tries to make it a real entry.
  ///
  /// Two steps on purpose. The row is saved first and without a network, so the
  /// diary never depends on the signal. Then the food reference is asked, which
  /// costs no tokens: if it knows the dish, the entry stops being «0 ккал» by
  /// itself, and the day's figures move under the person's eyes.
  Future<void> _typed(CalviDb db, SyncService? sync, String slotId, String text) async {
    final id = await DayReader(db).addTyped(slotId: slotId, text: text);
    if (sync == null) return;

    await sync.enrich(id, text);
    // The corrected row is ours now, so the server should hear about it.
    unawaited(sync.now());
  }

  /// The day as it is stored, while the switch says «мої». Null until the first
  /// row arrives, which on an empty database is immediately.
  DayModel? _stored;
  StreamSubscription<DayModel>? _feed;

  static const _emptyDay = DayModel(slots: [], meals: []);

  /// What the current subscription is for. Dependencies change for reasons that
  /// have nothing to do with the day, and resubscribing on each of them threw
  /// away the rows that had just arrived.
  String? _feedFor;

  /// Follows the stored day, and follows the right one: the subscription is
  /// replaced when the person picks another day or flips the switch, and left
  /// alone otherwise.
  void _follow() {
    final scope = AppScope.of(context);
    final db = scope.db;
    final wanted = !scope.real || db == null ? null : '${identityHashCode(db)}:$_date';

    if (wanted == _feedFor) return;

    _feed?.cancel();
    _feed = null;
    _stored = null;
    _feedFor = wanted;
    if (wanted == null || db == null) return;

    _feed = DayReader(db).watch(calendarDay(_date)).listen((day) {
      if (mounted) setState(() => _stored = day);
    });
  }

  @override
  void initState() {
    super.initState();
    // Щоб дізнатись, що застосунок згорнули: мікрофон має замовкнути з ним.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _follow();
    unawaited(_openChat());
  }

  /// Піднімає збережену розмову. Один раз за життя екрана.
  Future<void> _openChat() async {
    final scope = AppScope.of(context);
    final db = scope.db;
    if (_chat != null || !scope.real || db == null) return;

    final store = ChatStore(db);
    _chat = store;

    final was = await store.load();
    if (!mounted || was.isEmpty || _messages.isNotEmpty) return;
    setState(() => _messages.addAll(was));
  }

  /* Застосунок згорнули посеред диктування.
   *
   * Мікрофон має замовкнути разом із ним. Доти він лишався слухати в кишені:
   * накладки на екрані вже немає, зупинити нема чим, а система чесно світить
   * зеленою крапкою запису. */
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) return;
    if (!_listening) return;

    _showing?.cancel();
    _listening = false;
    _heldFrom = null;
    unawaited(_ears.cancel());
    if (mounted && _dictating != null) setState(() => _dictating = null);
  }

  @override
  void dispose() {
    _reply?.cancel();
    _feed?.cancel();
    _showing?.cancel();
    WidgetsBinding.instance.removeObserver(this);

    /* Екран зникає, мікрофон гасне. Раніше тут не було цього рядка, і людина,
       яка посеред диктування відкривала налаштування, лишала запис увімкненим
       до кінця життя застосунку. */
    if (_listening) unawaited(_ears.cancel());
    super.dispose();
  }

  /* The shot leaves as a message. The viewfinder closes behind it and the chat
     opens with it already sent, because that is where the answer will arrive. */
  Future<void> _openCamera(BuildContext context) async {
    final slot = _nextSlot(_dayNow(AppScope.of(context)));
    await Navigator.of(context).push(
      slideRoute(
        CameraScreen(
          slot: slot,
          /* Дві різні дії, і різниця між ними принципова. Прочитаний штрихкод
             це готові числа з довідника, які пишуться безкоштовно. А кадр
             страви їде повідомленням до Нори: чат відкривається з уже
             надісланим фото, і відповідь приходить туди. */
          onSend: (result) {
            Navigator.of(context).pop();
            switch (result) {
              case PhotoShot(:final shot):
                _shotToNora(
                  msg(from: MsgFrom.me, kind: MsgKind.photo, text: l.todayPhotoMeal),
                  noraPhoto,
                  shot,
                );
              case CodeShot(:final code, :final food):
                _logScanned(slot, code, food);
              case CodeTalk(:final code):
                _codeToNora(code);
            }
          },
        ),
      ),
    );
  }

  /* Demo or stored, and nothing that calls this knows the difference. That is
     the whole design of the switch: one shape of day, two sources.
   *
   * Окремим методом, а не рядком у `build`, саме тому, що це потрібно не лише
   * для малювання. Картку, у яку піде наступний запис, рахували завжди з
   * показового дня: Норі їхав слот із демонстрації, а не з того, що людина
   * справді їла сьогодні, і камера підписувала кнопку так само навмання. */
  DayModel _dayNow(AppScope scope) =>
      scope.real && scope.db != null ? (_stored ?? _emptyDay) : dayFor(_date);

  @override
  void didUpdateWidget(TodayScreen old) {
    super.didUpdateWidget(old);
    if (widget.ask != old.ask) _asked = false;
    _askEvening();
  }

  @override
  Widget build(BuildContext context) {
    _askEvening();
    final scope = AppScope.of(context);
    final real = scope.real && scope.db != null;
    final day = _dayNow(scope);
    final totals = day.totals;

    /* Склад дня запамʼятовується після кадру, а не під час нього: поки кадр
       будується, картки ще питають, чи вони нові. */
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _remember([for (final s in day.ordered) s.id]),
    );
    /* У режимі «мої» день приходить зі сховища цілим, дописувати до нього нічого
       не треба. Дописане з памʼяті лишається тільки для показового дня. */
    final workouts = real ? day.workouts : [...day.workouts, ...?_extraWorkouts[_date]];
    final waterMl = real ? day.waterMl : (_water[_date] ?? day.waterMl);
    /* Тільки ті препарати, які приймаються в показаний день.
     *
     * Розклад мав силу лише в планувальнику сповіщень: картка й кільце рахували
     * всі препарати щодня, тому «через день» у неробочий день висів незакритим
     * обовʼязком, а сповіщення в той самий день чесно мовчало. Плюс препарат,
     * заведений сьогодні, зʼявлявся в кожному минулому дні. */
    final meds = medsOnDay(scope.meds, calendarDay(_date), day.medTakes);
    final goal = goalOf(scope.s);

    return Scaffold(
      /* Прозорий навмисно: під сторінкою лежить ґрунт, а суцільне тло
         Scaffold накрило б його рівним кольором і від «Вугілля» лишився б
         один тон. Непрозорість сторінки під час переходу дає CalviGround,
         а не це поле, тож нічого не просвічує. */
      backgroundColor: const Color(0x00000000),
      // The bar lifts itself over the keyboard; see the padding below it.
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          /* The day is a layer of its own, so the panel moving over it does not
             make it paint again: without the boundary every frame of the chat
             opening repainted the whole day underneath. */
          RepaintBoundary(
            child: SafeArea(
              bottom: false,
              /* Every card at once, not a lazy list. There are eight of them and
               they are all cheap, and a lazy list guesses the height of what it
               has not built yet: the guess is replaced by the truth the moment a
               card comes into range, the end of the list moves by the
               difference, and a page sitting at that end is dragged with it.
               That was the jerk after opening a card from the far end. */
              child: SingleChildScrollView(
                // Room for the bar, which floats over the day rather than pushing it.
                padding: EdgeInsets.only(
                  bottom: CalviSize.barRoom + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 4, CalviSize.gutter, 18),
                      child: Row(
                        children: [
                          /* Гнучкий замість назви й розпірки окремо: на вузькому
                             телефоні з великим системним шрифтом назва, значок
                             джерела і дві кнопки разом ширші за екран, а ряд без
                             жодного гнучкого учасника не поступається нікому. */
                          Expanded(
                            child: Text(
                              'Calvi',
                              style: context.t.headlineLarge?.copyWith(fontSize: 23),
                            ),
                          ),
                          Flexible(
                            child: _Source(real: real, onTap: () => scope.setReal(!scope.real)),
                          ),
                          const SizedBox(width: 8),
                          // Square and dark: this one leaves the screen, while the round
                          // one beside it only opens a drawer of the same app.
                          _Square(icon: 'chart', onTap: () => _openAnalytics(context)),
                          const SizedBox(width: 8),
                          _Round(icon: 'settings', onTap: widget.onSettings),
                        ],
                      ),
                    ),

                    WeekStrip(
                      date: _date,
                      onPick: (d) {
                        setState(() {
                          _dayDir = d > _date ? 1 : -1;
                          _date = d;
                        });
                        _follow();
                      },
                    ),
                    const SizedBox(height: 4),

                    /* Everything below the strip belongs to the chosen day, so it
                   slides as one block in the direction the week was moved. */
                    Slide(
                      value: _date,
                      dir: _dayDir,
                      // День не має власного тла, тому дні розчиняються один в
                      // одному: інакше обидва видно разом, картка на картці.
                      fade: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: CalviSize.gutter),
                        child: Column(
                          children: [
                            /* Burned is passed in rather than read off the day: a
                           session logged just now has to move the hero's figure
                           too. In a layer of its own because the card turns by
                           itself, and a deck that turns should not cost the
                           whole day a repaint. */
                            RepaintBoundary(
                              child: HeroCard(
                                key: ValueKey(_date),
                                day: day,
                                burned: workouts.fold<int>(0, (s, w) => s + w.kcal),
                                goal: goal,
                              ),
                            ),
                            const SizedBox(height: CalviSize.gapCard),
                            MacroCards(
                              totals: totals,
                              goal: goal,
                              meds: meds,
                              // Галочки того дня, який показано, а не сьогоднішні.
                              takes: day.medTakes,
                              onMeds: widget.onMeds,
                            ),
                            const SizedBox(height: CalviSize.gapSection),

                            /* Meals, then water, then training, then the tape: the order
                     the day is lived in. Water sits above training because it is
                     filled all day, while training happened once. */
                            /* Кожна картка малюється у своєму шарі. Без цього
                               одна картка, що росте, змушує перемальовувати
                               весь день разом із десятком тіней під картками, і
                               так усі двадцять шість кадрів її відкриття. */
                            for (final slot in day.ordered)
                              Arriving(
                                key: ValueKey('arrive-$_date-${slot.id}'),
                                play: _isNew(slot.id),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: CalviSize.gapCard),
                                  child: RepaintBoundary(
                                    child: MealCard(
                                      slot: slot,
                                      meals: day.inSlot(slot.id),
                                      open: _openCard == slot.id,
                                      onToggle: () => _toggle(slot.id),
                                      onAdd: (text) {
                                        final db = scope.db;
                                        if (real && db != null) {
                                          /* Written by hand, so it costs nothing and
                                       needs no network. The entry lands in the
                                       day at once; the reference fills in the
                                       calories a moment later, and if it has
                                       never heard of the dish, Nora is the one
                                       who gets asked. */
                                          unawaited(_typed(db, scope.sync, slot.id, text));
                                          return;
                                        }
                                        _say(
                                          msg(from: MsgFrom.me, text: text),
                                          l.todayLoggedAskWeight(slotInto(context, slot)),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),

                            Padding(
                              padding: const EdgeInsets.only(bottom: CalviSize.gapCard),
                              child: RepaintBoundary(
                                child: WaterCard(
                                  ml: waterMl,
                                  goalMl: goal.waterMl,
                                  onChange: (ml) => _setWater(scope, ml),
                                  open: _openCard == 'water',
                                  onToggle: () => _toggle('water'),
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(bottom: CalviSize.gapCard),
                              child: RepaintBoundary(
                                child: WorkoutCard(
                                  workouts: workouts,
                                  onAdd: (w) => _addWorkout(scope, w),
                                  open: _openCard == 'workout',
                                  onToggle: () => _toggle('workout'),
                                ),
                              ),
                            ),

                            RepaintBoundary(
                              child: MeasureCard(
                                date: _date,
                                list: _measuresFor(scope),
                                /* Перелік живе в профілі, а не в памʼяті екрана:
                                 інакше він скидався на вагу й талію при кожному
                                 перезапуску. */
                                tracked: scope.s.tracked,
                                onTrack: (keys) => scope.set((v) => v.copyWith(tracked: keys)),
                                onSave: (m) => _saveMeasure(scope, m),
                                onStats: () => _openAnalytics(context),
                                open: _openCard == 'measure',
                                onToggle: () => _toggle('measure'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: BottomBar(
              slot: _nextSlot(day),
              open: _chatOpen,
              /* Ховається тільки на час диктування, коли її закриває збільшена
                 кнопка. Поки Нора думає, вона лишається на місці: доти круг
                 зникав разом із питанням, і в рядку лишалась сама камера, ніби
                 сказати більше нічим. Думає Нора, а не людина. */
              muteMic: _dictating != null,
              onOpen: (_) => setState(() => _chatOpen = true),
              onClose: () => setState(() => _chatOpen = false),
              onWeigh: _pickWeight,
              onSend: (text) =>
                  _say(msg(from: MsgFrom.me, text: text), l.todayLoggedAskWeightShort),
              onCamera: () => _openCamera(context),
              onHold: _holdMic,
              onLetGo: _letGoMic,
              messages: _messages,
            ),
          ),

          // Dictation covers everything, including the bar that started it.
          if (_dictating case final d?)
            VoiceOverlay(
              origin: d.from,
              leaving: d.leaving,
              onClosed: () => setState(() => _dictating = null),
              source: _ears,
            ),
        ],
      ),
    );
  }

  /// Which card the next sentence lands in.
  ///
  /// The hour decides, not the last card that was tapped: somebody writing at
  /// two in the afternoon means lunch whatever they were reading a moment ago.
  /* Які картки вже стояли на екрані, і за який день.
   *
   * Потрібне рівно для того, щоб відрізнити «зʼявилась щойно» від «була тут
   * увесь час». Перший показ дня не грає нічого: якби грав, то весь день
   * вивалювався б анімацією на кожному відкритті, і поява перекусу загубилась
   * би серед неї. */
  String? _drawnFor;
  var _drawn = <String>{};

  /// Чи ця картка народилась щойно, у людини на очах.
  bool _isNew(String id) {
    final key = '$_date';
    if (_drawnFor != key) return false;
    return !_drawn.contains(id);
  }

  /// Запамʼятати склад дня після того, як його намалювали.
  void _remember(Iterable<String> ids) {
    _drawnFor = '$_date';
    _drawn = ids.toSet();
  }

  /// Ідентифікатор картки за її написом.
  ///
  /// Екрани оперують назвою («Обід»), а база ідентифікатором («lunch»), бо
  /// картку можна перейменувати, і запис від цього не має переїжджати в інший
  /// прийом.
  String _slotIdFor(String label) {
    final scope = AppScope.of(context);
    final day = scope.real ? (_stored ?? _emptyDay) : dayFor(_date);

    for (final s in day.slots) {
      if (s.label == label) return s.id;
    }
    for (final s in baseSlots.values) {
      if (s.label == label) return s.id;
    }
    return 'snack';
  }

  /// Ідентифікатор картки, у яку піде наступний запис.
  ///
  /// Саме ідентифікатор, а не напис. Сервер приймає закритий перелік із чотирьох
  /// значень, і напис «Обід» він відхиляв як неправильний запит: у застосунку це
  /// виглядало як «не вийшло, спробуй за хвилину», хоча спроба через хвилину не
  /// могла допомогти нічим. Написи живуть на екрані, ідентифікатори їдуть у
  /// мережу.
  ///
  /// Береться прямо з картки, а не через її напис. Доти тут стояв пошук за
  /// написом, і щойно напис став перекладеним, англійське «Lunch» перестало
  /// збігатись із «Обід» у даних: запис поїхав би в перекус.
  String _nextSlotId(DayModel day) => _nextSlotDef(day)?.id ?? 'snack';

  /// Картка, у яку піде наступний запис. Вибирає година, а не останній дотик.
  ///
  /// Через той самий годинник, що й дати. Тут стояв власний виклик до
  /// системного часу, і він лишався єдиною діркою в закріпленому годиннику:
  /// знімок екрана розходився залежно від того, о котрій його зняли, бо підпис
  /// у рядку називав то обід, то вечерю.
  SlotDef? _nextSlotDef(DayModel day) {
    final hour = nowHour;
    SlotDef? best;
    for (final s in day.slots) {
      if (best == null || (s.order - hour).abs() < (best.order - hour).abs()) best = s;
    }
    return best;
  }

  /// Її назва для людини.
  ///
  /// Через `slotTitle`, а не власним написом картки. Назви стандартних карток
  /// лежать у коді українською, бо це їхні імена в даних, а не те, що бачить
  /// людина. Звідси в англійському застосунку виходило «Logging into Обід»:
  /// половина рядка перекладена, половина ні, і саме так воно й поїхало на
  /// знімки для стору.
  String _nextSlot(DayModel day) {
    final best = _nextSlotDef(day);
    return best == null ? l.slotSnack : slotTitle(context, best);
  }
}

class _Round extends StatelessWidget {
  const _Round({required this.icon, required this.onTap});

  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return CalviPress(
      onTap: onTap,
      builder: (context, down) => AnimatedContainer(
        duration: CalviMotion.fast,
        curve: CalviMotion.ease,
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, color: down ? c.hover : c.fillSecondary),
        child: CalviIcon(icon, size: 20),
      ),
    );
  }
}

class _Square extends StatelessWidget {
  const _Square({required this.icon, required this.onTap});

  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return CalviPress(
      onTap: onTap,
      builder: (context, down) => AnimatedScale(
        scale: down ? 0.92 : 1,
        duration: CalviMotion.fast,
        curve: CalviMotion.ease,
        child: AnimatedContainer(
          duration: CalviMotion.fast,
          curve: CalviMotion.ease,
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: down ? c.buttonPress : c.button,
            borderRadius: BorderRadius.circular(12),
          ),
          child: CalviIcon(icon, size: 19, color: c.buttonText),
        ),
      ),
    );
  }
}

/// Demo day or stored day, and which one is showing.
///
/// A word rather than an icon: there is no picture that says «the data you
/// actually wrote», and a guessed pictogram here would be worse than a label.
class _Source extends StatelessWidget {
  const _Source({required this.real, required this.onTap});

  final bool real;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      button: true,
      label: real ? L.of(context).todayShowingMine : L.of(context).todayShowingDemo,
      child: CalviPress(
        onTap: onTap,
        builder: (context, down) => AnimatedScale(
          scale: down ? 0.94 : 1,
          duration: CalviMotion.fast,
          curve: CalviMotion.ease,
          child: AnimatedContainer(
            duration: CalviMotion.normal,
            curve: CalviMotion.ease,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: real ? c.button : c.fillSecondary,
              borderRadius: BorderRadius.circular(CalviSize.rPill),
            ),
            child: Text(
              real ? L.of(context).todayMine : L.of(context).todayDemo,
              style: context.t.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: real ? c.buttonText : c.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
