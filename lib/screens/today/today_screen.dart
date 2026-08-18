import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/chat.dart';
import '../../data/day.dart';
import '../../data/fixtures.dart';
import '../../data/meal.dart';
import '../../data/app_scope.dart';
// Only the handle: the generated row classes carry names the screens already
// use for their own models, and `Workout` is one of them.
import '../../data/local/database.dart' show CalviDb;
import '../../data/local/day_reader.dart';
import '../../data/remote/api.dart';
import '../../data/remote/sync_service.dart';
import '../../data/measure.dart';
import '../../data/settings.dart';
import '../../data/workout.dart';
import '../../design/icons.dart';
import '../../design/theme.dart';
import '../../design/shell.dart';
import '../../design/tokens.dart';
import '../../design/slide.dart';
import '../analytics/analytics_screen.dart';
import '../camera/camera_screen.dart';
import '../voice/voice_overlay.dart';
import 'bottom_bar.dart';
import 'hero_card.dart';
import 'macro_cards.dart';
import 'meal_card.dart';
import 'measure_card.dart';
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
  });

  final VoidCallback onSettings;

  /// Only the dev entry passes this, to land straight in the chat.
  final bool chatOpen;

  /// And this, to land with one of the day cards already open.
  final String? openCard;

  /// The fourth macro card opens the medications.
  final VoidCallback onMeds;

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
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
  /* Стрічка вимірювань. Порожня, поки людина сама щось не заміряла: показові
     обхвати талії й грудей у власному профілі це чужі числа, видані за свої.
     У режимі «мої» вона збирається з ваг, які справді записані, а решта полів
     поки живе тільки тут і поїде в базу разом із рештою сутностей. */
  final _measures = <Measure>[];

  List<Measure> _measuresFor(AppScope scope) {
    if (!scope.real) return [...demoMeasures, ..._measures];

    final stored = [
      for (final e in scope.stats.weights.entries)
        Measure(date: e.key, values: {'weightKg': e.value}),
    ];
    // Свіжі заміри інших полів лишаються поверх: вони ще нікуди не їдуть.
    final extra = _measures.where((m) => m.values.keys.any((k) => k != 'weightKg'));
    return [...stored, ...extra]..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Записаний замір: вагу в базу, решту поки в пам'ять.
  void _saveMeasure(AppScope scope, Measure m) {
    final kg = m['weightKg'];
    final db = scope.db;

    if (scope.real && db != null && kg != null) {
      unawaited(db.diaryDao.setWeight(kg: kg, at: DateTime.now()));
    }
    if (!scope.real || m.values.keys.any((k) => k != 'weightKg')) {
      setState(() => _measures.add(m));
    }
  }
  var _tracked = <String>[...defaultTracked];

  late bool _chatOpen = widget.chatOpen;
  late String? _openCard = widget.openCard;
  bool _dictating = false;
  final _messages = <Msg>[];

  void _openAnalytics(BuildContext context) => Navigator.of(
    context,
  ).push(
    slideRoute(
      AnalyticsScreen(
        measures: _measuresFor(AppScope.of(context)),
        onSettings: widget.onSettings,
      ),
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
  Msg _wait(Msg mine) {
    final waiting = msg(from: MsgFrom.nora, text: '', pending: true);
    setState(() {
      _messages
        ..add(mine)
        ..add(waiting);
      _chatOpen = true;
    });
    return waiting;
  }

  /// Кладе відповідь на місце кільця, не додаючи нової бульбашки.
  void _answer(Msg waiting, String text, {MealPlate? plate}) {
    if (!mounted) return;
    final at = _messages.indexWhere((m) => m.id == waiting.id);
    if (at < 0) return;
    setState(() => _messages[at] = waiting.answered(text: text, plate: plate));
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

  /// Пише в день продукт, прочитаний зі штрихкоду.
  ///
  /// Не коштує нічого і не питає нікого: код прочитав сам телефон, числа взяті з
  /// упаковки, і моделі тут робити нічого. У чат лягає рядок, щоб дія не зникла
  /// без сліду, але це наш текст, а не відповідь Нори.
  /// Пише страву, яку людина підтвердила на екрані сканера.
  ///
  /// Модель тут більше не питається: вона вже відповіла, і за це вже списано.
  /// Другий виклик заради того самого знімка був би другою платою за ту саму
  /// роботу.
  Future<void> _logDish(String slot, Estimate dish) async {
    final scope = AppScope.of(context);
    final db = scope.db;

    setState(() {
      _messages.add(msg(from: MsgFrom.me, kind: MsgKind.photo, text: 'Фото страви'));
      _messages.add(
        msg(
          from: MsgFrom.nora,
          text: 'Записала в ${slot.toLowerCase()}: ${dish.name.toLowerCase()}.',
          plate: MealPlate(
            name: dish.name,
            grams: dish.grams,
            kcal: dish.kcal,
            protein: dish.protein.round(),
            fat: dish.fat.round(),
            carbs: dish.carbs.round(),
          ),
        ),
      );
      _chatOpen = true;
    });

    if (!scope.real || db == null) return;

    await db.diaryDao.addMeal(
      slot: _slotIdFor(slot),
      name: dish.name,
      kcal: dish.kcal,
      grams: dish.grams,
      protein: dish.protein,
      fat: dish.fat,
      carbs: dish.carbs,
      icon: dish.icon,
      canonicalName: dish.canonicalName,
      source: 'photo',
    );

    unawaited(scope.sync?.now() ?? Future.value());
  }

  Future<void> _logScanned(String slot, String code, FoodHit food) async {
    final scope = AppScope.of(context);
    final db = scope.db;
    final plate = food.forGrams();

    setState(() {
      _messages.add(msg(from: MsgFrom.me, kind: MsgKind.barcode, text: 'Штрихкод', code: code));
      _messages.add(
        msg(
          from: MsgFrom.nora,
          text: 'Записала в ${slot.toLowerCase()}: ${food.name}, '
              '${plate.kcal} ккал за ${plate.grams.round()} г.',
        ),
      );
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
    unawaited(
      db.diaryDao
          .setWaterTotal(ml, at: _when())
          .then((_) => scope.sync?.now()),
    );
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

  /// True while Nora is being asked, so the bar can say «читаю» rather than
  /// looking as though the message went nowhere.
  bool _asking = false;

  /// Sends what was typed and puts the answer in the thread.
  ///
  /// Every failure has its own sentence: «немає токенів» and «немає мережі» are
  /// different problems and a single «щось пішло не так» teaches nothing.
  Future<void> _askNora(
    SyncService sync,
    String text, {
    Shot? image,
    required Msg waiting,
  }) async {
    setState(() => _asking = true);
    try {
      final answer = await sync.ask(
        text: text,
        slot: _nextSlotId(_dayNow(AppScope.of(context))),
        image: image,
      );
      if (!mounted) return;

      final line = [
        if (answer.warning != null) answer.warning!,
        if (answer.text.isNotEmpty) answer.text,
      ].join(' ');

      _answer(waiting, line.isEmpty ? 'Готово.' : line);
      // Whatever was written on the server arrives as an ordinary row.
      unawaited(sync.now());
    } on ApiFailure catch (e) {
      _answer(waiting, switch (e.code) {
        'no_tokens' => 'Токени на сьогодні скінчились. Записати вручну можна завжди.',
        'offline' => 'Не дістаю мережі. Запис лишиться на телефоні і поїде, коли зʼявиться.',
        'slow' => 'Нора думає довше звичного. Спробуй ще раз, токен не списався.',
        _ => 'Не вийшло. Спробуй ще раз за хвилину.',
      });
    } finally {
      if (mounted) setState(() => _asking = false);
    }
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _follow();
  }

  @override
  void dispose() {
    _reply?.cancel();
    _feed?.cancel();
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
          /* Три різні дії, і різниця між ними принципова. Прочитаний штрихкод
             це готові числа з довідника, які пишуться безкоштовно. Розібрана
             страва це оцінка моделі, за яку вже заплачено на екрані сканера, і
             лишається тільки записати. А голий кадр доїжджає сюди лише тоді,
             коли розбору не сталось: без мережі він їде в чат і чекає там. */
          onSend: (result) {
            Navigator.of(context).pop();
            switch (result) {
              case PhotoShot(:final shot):
                _shotToNora(
                  msg(from: MsgFrom.me, kind: MsgKind.photo, text: 'Фото страви'),
                  noraPhoto,
                  shot,
                );
              case CodeShot(:final code, :final food):
                _logScanned(slot, code, food);
              case DishShot(:final dish):
                _logDish(slot, dish);
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
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final real = scope.real && scope.db != null;
    final day = _dayNow(scope);
    final totals = day.totals;
    /* У режимі «мої» день приходить зі сховища цілим, дописувати до нього нічого
       не треба. Дописане з памʼяті лишається тільки для показового дня. */
    final workouts = real ? day.workouts : [...day.workouts, ...?_extraWorkouts[_date]];
    final waterMl = real ? day.waterMl : (_water[_date] ?? day.waterMl);
    final meds = scope.meds;
    final goal = goalOf(scope.s);

    return Scaffold(
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
                    padding: const EdgeInsets.fromLTRB(
                      CalviSize.gutter,
                      4,
                      CalviSize.gutter,
                      18,
                    ),
                    child: Row(
                      children: [
                        Text('Calvi', style: context.t.headlineLarge?.copyWith(fontSize: 23)),
                        const Spacer(),
                        _Source(
                          real: real,
                          onTap: () => scope.setReal(!scope.real),
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
                            onMeds: widget.onMeds,
                          ),
                          const SizedBox(height: CalviSize.gapSection),

                          /* Meals, then water, then training, then the tape: the order
                     the day is lived in. Water sits above training because it is
                     filled all day, while training happened once. */
                          for (final slot in day.ordered)
                            Padding(
                              padding: const EdgeInsets.only(bottom: CalviSize.gapCard),
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
                                    'Записав у ${slot.label.toLowerCase()}. Скажи вагу, якщо хочеш точніше.',
                                  );
                                },
                              ),
                            ),

                          Padding(
                            padding: const EdgeInsets.only(bottom: CalviSize.gapCard),
                            child: WaterCard(
                              ml: waterMl,
                              goalMl: goal.waterMl,
                              onChange: (ml) => _setWater(scope, ml),
                              open: _openCard == 'water',
                              onToggle: () => _toggle('water'),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(bottom: CalviSize.gapCard),
                            child: WorkoutCard(
                              workouts: workouts,
                              onAdd: (w) => _addWorkout(scope, w),
                              open: _openCard == 'workout',
                              onToggle: () => _toggle('workout'),
                            ),
                          ),

                          MeasureCard(
                            list: _measuresFor(scope),
                            tracked: _tracked,
                            onTrack: (keys) => setState(() => _tracked = keys),
                            onSave: (m) => _saveMeasure(scope, m),
                            onStats: () => _openAnalytics(context),
                            open: _openCard == 'measure',
                            onToggle: () => _toggle('measure'),
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
              muteMic: _dictating || _asking,
              onOpen: (_) => setState(() => _chatOpen = true),
              onClose: () => setState(() => _chatOpen = false),
              onSend: (text) => _say(
                msg(from: MsgFrom.me, text: text),
                'Записав. Скажи вагу, якщо хочеш точніше.',
              ),
              onCamera: () => _openCamera(context),
              onVoice: () => setState(() => _dictating = true),
              messages: _messages,
            ),
          ),

          // Dictation covers everything, including the bar that started it.
          if (_dictating)
            VoiceOverlay(
              onDone: (text) {
                setState(() => _dictating = false);
                if (text.isEmpty) return;
                _say(msg(from: MsgFrom.me, kind: MsgKind.voice, text: text), noraVoice);
              },
            ),
        ],
      ),
    );
  }

  /// Which card the next sentence lands in.
  ///
  /// The hour decides, not the last card that was tapped: somebody writing at
  /// two in the afternoon means lunch whatever they were reading a moment ago.
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
  String _nextSlotId(DayModel day) => _slotIdFor(_nextSlot(day));

  String _nextSlot(DayModel day) {
    final hour = TimeOfDay.now().hour;
    SlotDef? best;
    for (final s in day.slots) {
      if (best == null || (s.order - hour).abs() < (best.order - hour).abs()) best = s;
    }
    return best?.label ?? 'Перекус';
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
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: down ? c.hover : c.fillSecondary,
        ),
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
      label: real ? 'Показані мої записи' : 'Показаний демонстраційний день',
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
              real ? 'Мої' : 'Демо',
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
