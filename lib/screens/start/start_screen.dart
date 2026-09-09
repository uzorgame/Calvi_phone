import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/settings.dart';
import '../../data/units.dart';
import '../../design/icons.dart';
import '../../design/ring.dart';
import '../../design/ruler.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import 'nora_tour.dart';
import 'sign_in.dart';
import 'welcome.dart';
import '../../design/wheel.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/labels.dart';

/* Скільки кроків у першому запуску.
 *
 * Тільки число: заповнення смуги вгорі це єдине, що з нього читають, а самі
 * назви ніде не показуються. Раніше тут лежав список їхніх імен, і це був
 * єдиний перелік у застосунку, який ніхто ніколи не бачив.
 *
 * Стать, вік і зріст стояли трьома екранами на дві секунди роботи кожен.
 * Питання одного роду і одного призначення: всі три йдуть у формулу норми і
 * жодне з них не потребує роздумів. Разом вони коротші, ніж три «Далі».
 *
 * Вітання «Стіл» звідси пішло і стало заставкою при кожному запуску, див.
 * `hello.dart`. Тут воно було екраном, який нічого не питав, і його доводилось
 * закривати кнопкою: єдиний дотик за весь «Старт», який нічого не означав. */
const startSteps = 9;

/// Три напрямки, словами тієї мови, якою зараз говорить застосунок.
List<({Direction id, String label, String hint})> _goals(L l) => [
  (id: Direction.lose, label: l.startGoalLose, hint: l.startGoalLoseHint),
  (id: Direction.keep, label: l.startGoalKeep, hint: l.startGoalKeepHint),
  (id: Direction.gain, label: l.startGoalGain, hint: l.startGoalGainHint),
];

/// First run, nine screens.
///
/// A competitor spends twenty eight of them, most on selling. We ask only what
/// the daily norm cannot be calculated without, one question to a screen, and
/// Nora picks up the rest in conversation over the first week.
///
/// **The account is the last screen.** The norm is already on the table by then,
/// so signing in is keeping something rather than paying for something not yet
/// seen. The cost is real and known: work done before the account exists is work
/// that can be lost if the app closes, and the sign-in has to earn its place by
/// arriving after the payoff rather than before it.
///
/// There is no social proof here and no testimonials. We have no users yet, and
/// a review invented for a demo is a lie that ships.
class StartScreen extends StatefulWidget {
  const StartScreen({super.key, required this.onFinish, this.onSignedIn, this.step = 0});

  /// Where the finished profile goes.
  final void Function(StartDraft) onFinish;

  /* Вхід у наявний акаунт, коли анкети не було.
   *
   * Інший кінець «Старту», і навмисно не [onFinish]: тут нема чого зберігати.
   * Профіль людини лежить на сервері, і віддати замість нього заводську
   * чернетку означало б затерти справжні цілі тими, яких ніхто не вводив.
   *
   * `false` у відповідь означає, що в акаунті профілю не виявилось, і анкету
   * все-таки доведеться пройти. */
  final Future<bool> Function()? onSignedIn;

  /// Which screen to open on. Only the demo entry point passes anything else.
  final int step;

  @override
  State<StartScreen> createState() => _StartScreenState();
}

/// Everything the first run collects, and nothing else.
///
/// A record of its own rather than a half-filled [SettingsState]: the caller
/// decides what to do with it, and a draft that pretends to be settings invites
/// somebody to hand it straight to a screen that expects every field.
class StartDraft {
  const StartDraft({
    required this.sex,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.direction,
    required this.targetKg,
    required this.pace,
    required this.activity,
    required this.allergies,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.units = metricUnits,
  });

  final Sex sex;
  final int age;
  final int heightCm;
  final double weightKg;
  final Direction direction;
  final double targetKg;
  final double pace;
  final double activity;
  final List<String> allergies;
  final int protein;
  final int fat;
  final int carbs;

  /// В яких одиницях людина себе важить і міряє.
  final Units units;

  /// Folded into the app's settings, with the goal anchored to today's weight.
  SettingsState applyTo(SettingsState s) => s.copyWith(
    sex: sex,
    age: age,
    heightCm: heightCm,
    weightKg: weightKg,
    goalStartKg: weightKg,
    targetKg: targetKg,
    direction: direction,
    pace: pace,
    activity: activity,
    allergies: [for (final id in allergies) Allergy(id: id, severe: false)],
    protein: protein,
    fat: fat,
    carbs: carbs,
    units: units,
  );
}

class _StartScreenState extends State<StartScreen> {
  /* Переклад геттером, а не полем: `L.of` тягне залежність від локалі, і
     збережене в `initState` значення пережило б зміну мови. */
  L get l => L.of(context);

  late int _step = widget.step;

  /* Вітання показується тільки на справжньому першому запуску. Демо-вхід
     просить конкретний крок, і зустрічати його розвилкою означало б не
     виконати прохання. */
  late bool _welcome = widget.step == 0;

  /// Вхід відкрили з вітання: анкети не було, і екран входу каже інше.
  bool _returning = false;

  Sex _sex = Sex.m;
  int _age = 26;
  int _heightCm = 178;
  double _weightKg = 80;

  Direction _direction = Direction.lose;
  double _targetKg = 74;
  double _pace = 0.5;

  double _activity = 1.55;
  final _allergies = <String>[];
  Units _units = metricUnits;

  /* Сторінка входу живе тут, а не всередині самого входу.
   *
   * Реєстрація і підтвердження пошти це підсторінки першого кроку, і назад із
   * них веде та сама стрілка згори, що й з решти анкети. Стрілка намальована в
   * шапці «Старту», тож знати, куди вона веде, має «Старт». Тримати цей стан
   * усередині форми означало б малювати їй другу кнопку назад, і на екрані
   * стояли б дві стрілки з різною поведінкою. */
  AuthPage _auth = AuthPage.in_;

  /// The profile as it stands, so every screen can show what it adds up to.
  SettingsState get _draft => initialSettings().copyWith(
    sex: _sex,
    age: _age,
    heightCm: _heightCm,
    weightKg: _weightKg,
    goalStartKg: _weightKg,
    targetKg: _targetKg,
    direction: _direction,
    pace: _pace,
    activity: _activity,
  );

  /* Розкладка живе в `settings.dart`, поруч із самою нормою: одне правило, а не
     дві копії одного правила. Показується в кінці, щоб число було планом, а не
     вироком. */
  int get _protein => macrosFor(_draft).protein;
  int get _fat => macrosFor(_draft).fat;
  int get _carbs => macrosFor(_draft).carbs;

  /* Ціль і напрямок це один стан, а не два.
   *
   * Доти вони були двома, і суперечили одне одному відкрито: можна було обрати
   * «Схуднути» і виставити цільову вагу вищу за свою. Картка казала «дефіцит»,
   * формула рахувала набір, а прогноз обіцяв тижні до ваги, від якої людина
   * тікає. Кожне з цих чисел окремо не було неправдою, а разом вони не
   * означали нічого.
   *
   * Тепер сторона стрічки і є напрямком. Тягнеш вище за свою вагу, і напрямок
   * сам стає «Набрати». Тиснеш «Тримати вагу», і стрічка сама доїжджає до
   * твоєї ваги, а не зникає з чужим числом усередині. */

  /// Куди відвести стрічку. Порожньо, поки її ніхто не відсилав.
  double? _seek;

  /* Стрічка зараз їде сама. Поки їде, напрямок не слухає її: по дорозі вона
     проходить і повз вагу людини, і це кадри руху, а не рішення. */
  bool _walking = false;
  Timer? _stops;

  /// Скільки кілограмів між вагою і ціллю, коли своєї відстані ще немає.
  static const _stepKg = 6.0;

  void _sendTo(double to) {
    _stops?.cancel();
    setState(() {
      _walking = true;
      _seek = double.parse(to.toStringAsFixed(1));
    });
    /* Час трохи більший за саму дорогу: барабан гальмує згасаючи, і остання
       десята кілограма доїжджає довше за першу. */
    _stops = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _walking = false);
    });
  }

  void _pickGoal(Direction id) {
    setState(() => _direction = id);

    /* Відстань зберігається, а не вигадується: людина щойно сказала «на шість
       кілограмів», і якщо вона перекидає напрямок, то йдеться про ті самі шість
       у інший бік. Своєї відстані ще немає тільки після «Тримати вагу». */
    final gap = (_targetKg - _weightKg).abs() == 0 ? _stepKg : (_targetKg - _weightKg).abs();

    if (id == Direction.keep) {
      _sendTo(_weightKg);
    } else if (id == Direction.lose && _targetKg >= _weightKg) {
      _sendTo(_weightKg - gap);
    } else if (id == Direction.gain && _targetKg <= _weightKg) {
      _sendTo(_weightKg + gap);
    }
  }

  void _aimAt(double v) {
    setState(() => _targetKg = v);
    if (_walking) return;
    if (v > _weightKg && _direction != Direction.gain) {
      setState(() => _direction = Direction.gain);
    } else if (v < _weightKg && _direction != Direction.lose) {
      setState(() => _direction = Direction.lose);
    }
  }

  @override
  void dispose() {
    _stops?.cancel();
    super.dispose();
  }

  void _go(int n) => setState(() => _step = n);

  /* Куди веде стрілка згори, або нікуди, якщо йти нема куди.
   *
   * На самому вході її немає: це перший екран застосунку, і позаду нього
   * нічого. На реєстрації вона повертає до входу, з підтвердження пошти до
   * реєстрації, з відновлення пароля до входу. Далі по анкеті це просто
   * попередній крок. */
  VoidCallback? get _back {
    if (_step > 0) return () => _go(_step - 1);

    return switch (_auth) {
      AuthPage.in_ => null,
      AuthPage.up || AuthPage.forgot => () => setState(() => _auth = AuthPage.in_),
      AuthPage.code => () => setState(() => _auth = AuthPage.up),
    };
  }

  /* Вхід відбувся, а профілю в акаунті не виявилось: анкету все одно треба
     пройти. Прапорець знімається, бо далі це звичайна дорога новачка. */
  void _toForm() => setState(() {
    _returning = false;
    _auth = AuthPage.in_;
    _step = 1;
  });

  /* Зайшли в наявний акаунт. Нічого не збираємо і нічого не зберігаємо: профіль
     приходить з обміну таким, яким лежить на сервері. */
  Future<void> _entered() async {
    final ok = await widget.onSignedIn?.call() ?? false;
    if (!ok && mounted) _toForm();
  }

  void _done() => widget.onFinish(
    StartDraft(
      sex: _sex,
      age: _age,
      heightCm: _heightCm,
      weightKg: _weightKg,
      direction: _direction,
      targetKg: _targetKg,
      pace: _pace,
      activity: _activity,
      allergies: [..._allergies],
      protein: _protein,
      fat: _fat,
      carbs: _carbs,
      units: _units,
    ),
  );

  @override
  Widget build(BuildContext context) {
    /* Вітання нічого не питає і ні про що не питає: воно догрує сцену і само
       веде далі, на вхід. Розвилки «уперше чи повертаєшся» тут більше немає,
       бо наступний екран і є нею: вхід і реєстрація стоять на ньому поруч.
       Демо-вхід на конкретний крок вітання минає, бо йому показують саме те
       питання, яке попросили. */
    if (_welcome) {
      return WelcomeScreen(onDone: () => setState(() => _welcome = false));
    }

    return Scaffold(
      /* Прозорий навмисно: під сторінкою лежить ґрунт, а суцільне тло
         Scaffold накрило б його рівним кольором і від «Вугілля» лишився б
         один тон. Непрозорість сторінки під час переходу дає CalviGround,
         а не це поле, тож нічого не просвічує. */
      backgroundColor: const Color(0x00000000),
      body: SafeArea(
        child: Column(
          children: [
            /* Смуга стоїть завжди, з першого ж питання.
             *
             * Раніше її на першому екрані не було, бо першим екраном було
             * вітання, яке кроком не рахувалось. Тепер перший екран це вже
             * питання, і сховати від нього смугу означало б сказати «ти ще не
             * почав» тому, хто вже відповідає.
             *
             * Безумовно, а не через `if`: шар, який то є, то немає, змінює
             * форму дерева під собою і перебудовує все, що нижче. Тут це
             * коштувало б втрати позиції барабанів на кожному переході. Тому
             * кнопка «назад» на першому кроці ховається, а місце своє тримає. */
            Padding(
              padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 6, CalviSize.gutter, 22),
              child: Row(
                children: [
                  Visibility(
                    visible: _back != null,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: _Back(onTap: () => _back?.call()),
                  ),
                  const SizedBox(width: 14),
                  /* Крок плюс один: людина на першому питанні пройшла одну
                     сьому, а не нічого. Порожня смуга на екрані, де вже щось
                     роблять, читається як зламана. */
                  Expanded(child: _Progress(at: (_step + 1) / startSteps)),
                ],
              ),
            ),
            /* No slide between steps. The demo keys its slide by screen, not by
               step, so the flow moves on one thing only: the bar filling. */
            Expanded(
              child: KeyedSubtree(key: ValueKey(_step), child: _body()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() => switch (_step) {
    /* Вхід стоїть першим, а не останнім.
     *
     * Доти він був сьомим екраном, і міркування було таке: норма вже
     * порахована, тому вхід зберігає зроблене, а не просить довіри наперед.
     * Ціна цього виявилась вища за користь. Той, хто вже має акаунт, мусив
     * пройти шість екранів анкети, щоб дістатись до входу і побачити, що всі
     * відповіді в нього і так на сервері. А той, хто заповнив анкету і закрив
     * застосунок до останнього екрана, втрачав її цілком.
     *
     * Тепер навпаки: спершу питаємо, хто це, і той, хто повертається, забирає
     * свій профіль замість того, щоб набирати його наново. */
    0 => SignIn(
      page: _auth,
      onPage: (p) => setState(() => _auth = p),
      onNew: () {
        setState(() => _auth = AuthPage.in_);
        _go(1);
      },
      onEntered: _entered,
      returning: _returning,
    ),
    1 => _aboutStep(),
    2 => _unitsStep(),
    3 => _weightStep(),
    4 => _goalStep(),
    5 => _paceStep(),
    6 => _lifeStep(),
    7 => _normStep(),
    // Остання картка: що вміє Нора. За нею вже щоденник.
    _ => NoraTour(onDone: _done),
  };

  /* Одиниці питаються один раз і більше не питаються: далі вони живуть у
     налаштуваннях. Перед вагою, а не після: наступний екран просить число, і
     воно має бути в тих одиницях, у яких людина себе важить. Спитати після
     означало б переписувати щойно введене.
     Пʼять окремих питань, бо кухонні ваги в грамах цілком уживаються з вагою
     тіла у фунтах. */
  Widget _unitsStep() {
    final groups = unitGroups(l);

    return _Step(
      title: l.unitsTitle,
      cta: l.actionNext,
      onNext: () => _go(3),
      children: [
        for (final g in groups)
          _Block(
            title: g.title,
            child: CalviSegments(
              labels: g.labels,
              index: g.values.indexOf(_units.byKey(g.key)).clamp(0, g.values.length - 1),
              onPick: (i) => setState(() => _units = _units.withKey(g.key, g.values[i])),
            ),
          ),
      ],
    );
  }

  /* Три відповіді одним екраном, і всі три без роздумів.
   *
   * Стать рядом, а не трьома картками: три слова без пояснень займають висоту
   * одного рядка і читаються так само. Барабани стиснуті до трьох рядів, щоб
   * екран уміщався цілком: прокрутка тут означала б, що людина не бачить
   * кнопку, поки не догортає до неї. */
  Widget _aboutStep() => _Step(
    title: l.startAbout,
    cta: l.actionNext,
    onNext: () => _go(2),
    children: [
      _Block(
        title: l.startSex,
        /* Дві відповіді, бо питання тут не про людину, а про формулу.
           Міффлін-Сан Жеор має рівно два коефіцієнти, і третій варіант
           однаково рахувався б за чоловічий: вибір, який ні на що не впливає,
           це вибір, який вводить в оману. */
        child: CalviSegments(
          labels: [l.startSexMale, l.startSexFemale],
          index: _sex == Sex.f ? 1 : 0,
          onPick: (i) => setState(() => _sex = i == 1 ? Sex.f : Sex.m),
        ),
      ),
      _Block(
        title: l.startAge,
        aside: l.startAgeYears(_age),
        child: CalviWheel(
          values: ages,
          value: _age,
          suffix: l.startYearsShort,
          compact: true,
          onPick: (v) => setState(() => _age = v),
        ),
      ),
      _Block(
        title: l.startHeight,
        aside: _units.heightText(_heightCm),
        child: CalviWheel(
          values: _units.heightWheel,
          value: _units.heightOut(_heightCm),
          suffix: _units.length == 'in' ? '' : l.unitCm,
          format: _units.length == 'in' ? _units.heightNum : null,
          compact: true,
          onPick: (v) => setState(() => _heightCm = _units.heightIn(v)),
        ),
      ),
    ],
  );

  /* The weight has a screen to itself and stands in the middle of it: it is the
     one number here that will be asked again every week. */
  Widget _weightStep() => _Step(
    title: l.startWeightNow,
    cta: l.actionNext,
    onNext: () => _go(4),
    middle: true,
    children: [
      CalviRuler(
        value: _units.massOut(_weightKg),
        min: _units.massBound(40),
        max: _units.massBound(180),
        suffix: _units.massLabel,
        onChange: (v) => setState(() => _weightKg = _units.massIn(v)),
      ),
    ],
  );

  Widget _goalStep() => _Step(
    title: l.startGoal,
    cta: l.actionNext,
    // Holding weight needs no target and no pace, so the next step is skipped.
    onNext: () => _go(_direction == Direction.keep ? 6 : 5),
    children: [
      for (final g in _goals(l))
        CalviPick(
          label: g.label,
          hint: g.hint,
          on: _direction == g.id,
          onTap: () => _pickGoal(g.id),
        ),
      /* Поки стрічка їде до ваги, вона лишається на екрані, хоч напрямок уже
         «Тримати». Інакше рух, заради якого все це, стався б за зачиненими
         дверима: картка спалахнула б, а стрічка зникла б разом із ним. */
      if (_direction != Direction.keep || _walking)
        _Field(
          label: l.startTargetWeight,
          value: _units.massNum(_targetKg),
          unit: _units.massLabel,
          child: CalviRuler(
            showValue: false,
            value: _units.massOut(_targetKg),
            seek: _seek == null ? null : _units.massOut(_seek!),
            min: _units.massBound(40),
            max: _units.massBound(180),
            suffix: _units.massLabel,
            onChange: (v) => _aimAt(_units.massIn(v)),
          ),
        ),
    ],
  );

  /* Pace on its own screen. It is the one answer here that decides how the next
     few months feel, and it deserves more than a slider under a drum. */
  Widget _paceStep() {
    final weeks = weeksToTarget(_draft);
    return _Step(
      title: l.startPace,
      cta: l.actionNext,
      onNext: () => _go(6),
      children: [
        Text.rich(
          TextSpan(
            text: _units.massNum(_pace),
            children: [
              TextSpan(
                text: '  ${l.startPaceUnit(_units.massLabel)}',
                style: context.t.bodyMedium?.copyWith(fontSize: CalviSize.fsBody),
              ),
            ],
          ),
          style: context.t.displayLarge?.copyWith(height: 1),
        ),
        const SizedBox(height: 26),
        CalviSlider(
          value: _pace,
          min: 0.2,
          max: 1.2,
          step: 0.1,
          marks: [l.startPaceSlow, l.startPaceUsual, l.startPaceFast],
          onChange: (v) => setState(() => _pace = v),
        ),
        if (weeks > 0)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: context.c.fillSecondary,
                borderRadius: BorderRadius.circular(CalviSize.rCard),
              ),
              /* Речення трьома шматками, бо дата і строк у ньому жирні.
               *
               * Скільки тижнів це окремий рядок із множиною, а не число плюс
               * слово: українська має тут три форми, і склеєне в коді давало
               * «5 тижні». */
              child: Text.rich(
                TextSpan(
                  text: l.startPaceEtaHead,
                  children: [
                    TextSpan(
                      text: targetDate(weeks),
                      style: TextStyle(color: context.c.text, fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: l.startPaceEtaTail),
                    TextSpan(
                      text: l.startPaceWeeks(weeks),
                      style: TextStyle(color: context.c.text, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                style: context.t.bodyMedium,
              ),
            ),
          ),

        /* Only when there is something to say. A line that confirms nothing is
           wrong teaches people to stop reading the lines. */
        if (_pace > 0.8) _Note(l.startPaceWarning),
      ],
    );
  }

  Widget _lifeStep() => _Step(
    title: l.startLife,
    cta: l.actionNext,
    onNext: () => _go(7),
    children: [
      for (final a in activityLevels)
        CalviPick(
          label: activityTitle(context, a.v),
          hint: activityHint(context, a.v),
          on: _activity == a.v,
          onTap: () => setState(() => _activity = a.v),
        ),
      /* Тут стояли алергії, девʼять чипів під питанням про спосіб життя.
         Пішли, і це не спрощення заради спрощення: алергія це не крок анкети, а
         постійна властивість людини, і живе вона в налаштуваннях, де її можна
         дописати будь-коли. На першому запуску її питали в того, хто ще жодного
         разу нічого не записав, і девʼять кнопок стояли між ним і його нормою. */
    ],
  );

  /* Норму рахує Нора, і це видно. Сам екран живе окремим віджетом, див.
     `_NormStep`: у нього свої таймери, і починатись вони мають, коли зʼявився
     він, а не коли зʼявився «Старт». */
  Widget _normStep() => _NormStep(
    // The choice from step two, not the saved one: nothing is saved yet.
    units: _units,
    kcal: calcKcal(_draft),
    weeks: weeksToTarget(_draft),
    protein: _protein,
    fat: _fat,
    carbs: _carbs,
    /* Те, з чого вона рахує, і рівно тими словами, якими це щойно питали.
       Числа беруться з відповідей, а не з прикладу: зріст із барабана, вага з
       лінійки, вік із барабана, спосіб життя з вибраної картки. */
    reads: [
      '${l.startHeight} ${_units.heightText(_heightCm)}',
      '${l.weightTitle} ${_round(_units.massOut(_weightKg))} ${_units.massLabel}',
      '${l.startAge} ${l.startAgeYears(_age)}',
      activityTitle(context, _activity),
    ],
    onNext: () => _go(8),
  );

  /// Вага без хвоста, коли він нульовий: «80 кг», а не «80.0 кг».
  static String _round(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}

/* Скільки Нора «рахує» норму.
 *
 * Формула коротка, і число готове тієї ж миті. Але людина щойно відповіла на
 * сім питань, і відповідь, що зʼявилась миттєво, читається як заготовка: ніхто
 * не рахував, просто показали заздалегідь відоме. Півтори секунди з іменем
 * того, хто рахує, і те саме число читається як відповідь саме на її слова.
 *
 * Час узятий не зі стелі: рівно стільки чекають на Нору в чаті, і це єдиний
 * екран анкети, де вона працює, а не питає. */
const _counting = Duration(milliseconds: 1500);

/* Скільки прочитані відповіді йдуть з екрана, перш ніж на їхнє місце приходить
   результат. Рівно стільки триває їхній рух: піти вони мають самі, а не
   зникнути в тому ж кадрі, у якому щось приходить. */
const _leaving = Duration(milliseconds: 220);

/* Три такти, а не два, і це головне в цьому екрані.
 *
 * Спершу було два: рахує і готово. Виглядало кривувато, і не через самі
 * анімації, а тому що в один кадр мінялось усе одразу: число зупинялось, рядки
 * відповідей зникали без сліду, макроси падали на їхнє місце, і знизу
 * вискакувала кнопка. Чотири події в одному кадрі читаються як смикання, хоч
 * кожна з них окремо плавна.
 *
 * Тепер вони розведені. `land` це двісті міліcекунд, за які число
 * приземляється, а прочитані відповіді встигають піти своїм рухом. І тільки
 * потім, на порожнє вже місце, приходить решта. */
enum _Phase { read, land, done }

class _NormStep extends StatefulWidget {
  const _NormStep({
    required this.units,
    required this.kcal,
    required this.weeks,
    required this.reads,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.onNext,
  });

  final Units units;
  final int kcal;
  final int weeks;

  /// Відповіді, з яких вона рахує. Відмічаються по черзі, поки йде рахунок.
  final List<String> reads;
  final int protein;
  final int fat;
  final int carbs;
  final VoidCallback onNext;

  @override
  State<_NormStep> createState() => _NormStepState();
}

class _NormStepState extends State<_NormStep> with SingleTickerProviderStateMixin {
  _Phase _phase = _Phase.read;

  /* Число, поки воно ще не число.
   *
   * Крутиться на своєму власному місці, у тій самій коробці, де за секунду
   * стане відповідь. Порожній екран із кільцем збоку каже «зачекай», а це каже
   * «рахую», і різниця між ними в тому, що людина бачить свою норму, яка шукає
   * себе, а не заставку. */
  late int _spin = widget.kcal;
  final _dice = math.Random();

  Timer? _roll;
  Timer? _lands;
  Timer? _shows;

  /* Кільце малюється саме, від нуля до повного, рівно за час рахунку. Воно і є
     індикатором: окремий значок очікування поруч був би другим годинником на
     тій самій стіні. */
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: _counting,
  );

  @override
  void initState() {
    super.initState();

    _lands = Timer(_counting, () => setState(() => _phase = _Phase.land));
    _shows = Timer(_counting + _leaving, () => setState(() => _phase = _Phase.done));

    /* Систему просили менше рухів. Тоді число не крутиться і кільце не їде: те
       саме чекання показується самим часом і рядками відповідей. */
    if (WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations) {
      _sweep.value = 1;
      return;
    }

    _sweep.forward();
    _roll = Timer.periodic(
      const Duration(milliseconds: 70),
      (_) => setState(() => _spin = 1200 + _dice.nextInt(2200)),
    );
  }

  @override
  void dispose() {
    _roll?.cancel();
    _lands?.cancel();
    _shows?.cancel();
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);
    final reading = _phase == _Phase.read;
    final done = _phase == _Phase.done;

    return _Step(
      title: l.startNorm,
      cta: l.actionNext,
      onNext: widget.onNext,
      busy: !done,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: c.card,
            border: Border.all(color: c.cardBorder),
            borderRadius: BorderRadius.circular(CalviSize.rLarge),
            boxShadow: context.shadowCard,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /* Число приземляється на такт раніше за все інше, і це
                       навмисно: воно тут головне, і йому належить окрема мить.
                     *
                       Не поява з нічого, а зупинка: колір доходить від
                       приглушеного до звичайного, і разом із ним іде ледь
                       помітний поштовх. Цифри при цьому ті самі і на тому
                       самому місці, тому око читає це як «крутилось і стало». */
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: reading ? 0 : 1),
                      duration: const Duration(milliseconds: 520),
                      curve: CalviMotion.easeRise,
                      builder: (context, t, child) => Transform.scale(
                        scale: 1 + 0.05 * (1 - t),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.units.enNum(reading ? _spin : widget.kcal),
                          style: context.t.displayLarge?.copyWith(
                            height: 1,
                            color: Color.lerp(c.textSecondary, c.text, t),
                            /* Моноширинні цифри, інакше кожна зміна смикала б
                               рядок туди-сюди, і рух читався б як збій, а не як
                               робота. */
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      reading ? l.startNormCounting : l.startNormPerDay(widget.units.enLabel),
                      style: context.t.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              /* Поки триває рахунок, кільце їде саме і всередині порожнє: тижнів
                 ще немає. Місце під нього стоїть від першого кадру, тому коли
                 число зʼявиться, нічого не стрибне. */
              AnimatedBuilder(
                animation: _sweep,
                builder: (context, _) => CalviRing(
                  progress: reading ? CalviMotion.easeRise.transform(_sweep.value) : 1,
                  size: 92,
                  stroke: 9,
                  fill: false,
                  child: reading
                      ? null
                      : _Appear(
                          duration: const Duration(milliseconds: 320),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.weeks > 0 ? '${widget.weeks}' : '∞',
                                style: context.t.headlineLarge?.copyWith(
                                  fontSize: 24,
                                  letterSpacing: 24 * -0.02,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.weeks > 0 ? l.startNormWeeks : l.startNormHold,
                                style: context.t.labelSmall?.copyWith(fontSize: 9, height: 1),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        if (!done)
          /* Що саме вона читає. Рядки відмічаються по черзі, і це не прикраса:
             норма це не магія, а чотири відповіді, які людина щойно дала.
             Побачити їх списком означає повірити числу, яке з них вийшло.
           *
             Йдуть вони теж самі, а не зникають: доки триває їхній вихід, місце
             лишається за ними, і результат приходить на порожнє, а не поверх. */
          Padding(
            padding: const EdgeInsets.only(top: CalviSize.gapCard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, r) in widget.reads.indexed)
                  Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
                    child: _Read(text: r, at: i, leaving: _phase == _Phase.land),
                  ),
              ],
            ),
          )
        else
          _Appear(
            duration: const Duration(milliseconds: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: CalviSize.gapCard),
                Row(
                  children: [
                    _MacroDot(
                      label: l.macroProtein,
                      value: widget.protein,
                      colour: c.protein,
                      icon: 'protein',
                    ),
                    const SizedBox(width: CalviSize.gapCard),
                    _MacroDot(label: l.macroFat, value: widget.fat, colour: c.fats, icon: 'fat'),
                    const SizedBox(width: CalviSize.gapCard),
                    _MacroDot(
                      label: l.macroCarbs,
                      value: widget.carbs,
                      colour: c.carbs,
                      icon: 'carbs',
                    ),
                  ],
                ),
                _Note(l.startNormNote),
              ],
            ),
          ),
      ],
    );
  }
}

/* Один прочитаний рядок: галочка і слова.
 *
 * Заходить із затримкою за своїм номером, а йде разом з усіма: на виході
 * затримки скидаються, інакше останній рядок починав би виходити тоді, коли
 * решта вже пішла. */
class _Read extends StatelessWidget {
  const _Read({required this.text, required this.at, required this.leaving});

  final String text;
  final int at;
  final bool leaving;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final row = Row(
      children: [
        CalviIcon('check', size: 14, color: c.button),
        const SizedBox(width: 10),
        Flexible(child: Text(text, style: context.t.bodyMedium)),
      ],
    );

    return TweenAnimationBuilder<double>(
      key: ValueKey(leaving),
      tween: Tween(begin: leaving ? 1 : 0, end: leaving ? 0 : 1),
      duration: leaving
          ? const Duration(milliseconds: 200)
          : const Duration(milliseconds: 420),
      curve: leaving ? CalviMotion.ease : CalviMotion.easeRise,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.translate(
          // Приходять збоку, а йдуть угору: туди, куди щойно приземлилось число.
          offset: leaving ? Offset(0, -8 * (1 - t)) : Offset(-10 * (1 - t), 0),
          child: child,
        ),
      ),
      child: row,
    );
  }
}

/* Поява одним рухом: те саме, що `form-in` у демці. Знизу і трохи зменшене,
   бо так з'являється все, що в цьому застосунку приходить на екран. */
class _Appear extends StatelessWidget {
  const _Appear({required this.child, required this.duration});

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: duration,
    curve: CalviMotion.easeRise,
    builder: (context, t, child) => Opacity(
      opacity: t,
      child: Transform.translate(
        offset: Offset(0, 12 * (1 - t)),
        child: Transform.scale(scale: 0.98 + 0.02 * t, child: child),
      ),
    ),
    child: child,
  );
}

class _Progress extends StatelessWidget {
  const _Progress({required this.at});

  final double at;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 3,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: c.hairline)),
            // Grows rather than jumps: the bar is the same object getting longer.
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 460),
              curve: CalviMotion.easeRise,
              widthFactor: at.clamp(0.0, 1.0),
              heightFactor: 1,
              alignment: Alignment.centerLeft,
              child: ColoredBox(color: c.button),
            ),
          ],
        ),
      ),
    );
  }
}

/// The shell every step after the first shares.
/// The question at the top of a step.
class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Text(
      text,
      style: context.t.displayLarge?.copyWith(
        fontSize: 34,
        letterSpacing: 34 * -0.03,
        height: 1.12,
      ),
    ),
  );
}

class _Block extends StatelessWidget {
  const _Block({required this.title, this.aside, required this.child});

  final String title;

  /// Число, яке відповідає на заголовок, справа того ж рядка. Не в кожного
  /// блока воно є: у вибору статі відповідь стоїть у самому ряду кнопок.
  final String? aside;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: CalviSize.gapSection),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: Text(title, style: context.t.titleMedium)),
              if (aside != null) Text(aside!, style: context.t.bodyMedium),
            ],
          ),
        ),
        child,
      ],
    ),
  );
}

class _Step extends StatelessWidget {
  const _Step({
    required this.title,
    required this.cta,
    required this.onNext,
    required this.children,
    this.middle = false,
    this.busy = false,
  });

  final String title;
  final String cta;
  final VoidCallback onNext;
  final List<Widget> children;

  /// Stands the content in the middle of the room it has, for a screen that
  /// holds one control: a lone tape at the top of an empty screen reads as
  /// something that failed to load below it.
  final bool middle;

  /* Крок ще працює, і кнопки немає. Не вимкнена, а відсутня: вимкнена кнопка
     запрошує в неї тицяти і мовчки відмовляє, а тут просто нема чого
     приймати, поки відповіді немає. */
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          // A screen with one control has nothing to scroll, so it is a column
          // that hands the leftover room to the control rather than a list.
          child: middle
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: CalviSize.gutter),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Title(title),
                      Expanded(
                        child: Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: children),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 16),
                  children: [_Title(title), ...children],
                ),
        ),
        /* A band under the action, so content scrolls behind it instead of
           through it: a button floating over a tape reads as a fault. The fade
           above the band is where the content goes out, not a hard cut. */
        SizedBox(
          height: 26,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [context.on.withValues(alpha: 0), context.on],
              ),
            ),
            child: const SizedBox.expand(),
          ),
        ),
        if (!busy)
          Padding(
            padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 26),
            /* Кнопка, яка щойно зʼявилась, заходить рухом, а не виникає: вона
               не подія, вона дозвіл іти далі, і приходить останньою. */
            child: _Appear(
              duration: const Duration(milliseconds: 360),
              child: CalviButton(label: cta, onTap: onNext),
            ),
          ),
      ],
    );
  }
}

/// The back mark of the flow. Plainer than [CalviBack] on purpose: the demo
/// draws no ring here, because the bar beside it is already the progress.
class _Back extends StatefulWidget {
  const _Back({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_Back> createState() => _BackState();
}

class _BackState extends State<_Back> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: L.of(context).actionBack,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _down ? 0.92 : 1,
          duration: CalviMotion.fast,
          curve: CalviMotion.ease,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: context.c.fillSecondary),
            child: Transform.rotate(angle: math.pi, child: const CalviIcon('chevron', size: 19)),
          ),
        ),
      ),
    );
  }
}

/// One option, as a card rather than a row: a first run has room for it, and a
/// choice that fills the thumb is easier than a list item.

/* A ruler with its own heading, so a screen carrying three of them does not read
   as three identical drums. */
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value, required this.unit, required this.child});

  final String label;
  final String value;
  final String unit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    /* No card. In the demo a field of the flow is a heading line and the naked
       tape under it, the full width of the content: the box my first version
       drew around each drum made three loud frames out of three quiet scales. */
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: Text(label, style: context.t.bodyMedium)),
              Text.rich(
                TextSpan(
                  text: value,
                  children: [
                    TextSpan(
                      text: ' $unit',
                      style: context.t.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.c.textSecondary,
                      ),
                    ),
                  ],
                ),
                style: context.t.headlineMedium?.copyWith(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 21 * -0.02,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          child,
        ],
      ),
    );
  }
}

/* Знак у кільці той самий, що на картках дня.
 *
 * Тут кільця стояли порожніми, і три однакові кола відрізнялись лише кольором:
 * людина бачила їх уперше і мусила читати підпис, щоб зрозуміти, котре з них
 * котре. На дні ці самі величини вже позначені знаками, і саме тут вони
 * зустрічаються вперше, тож саме тут знак і має з'явитись. */
class _MacroDot extends StatelessWidget {
  const _MacroDot({
    required this.label,
    required this.value,
    required this.colour,
    required this.icon,
  });

  final String label;
  final int value;
  final Color colour;
  final String icon;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          color: c.card,
          border: Border.all(color: c.cardBorder),
          borderRadius: BorderRadius.circular(CalviSize.rCard),
          boxShadow: context.shadowCard,
        ),
        child: Column(
          children: [
            CalviRing(
              progress: 1,
              size: 40,
              stroke: 5,
              color: colour,
              child: CalviIcon(icon, size: 14, color: colour),
            ),
            const SizedBox(height: 8),
            Text(
              // Macros are grams in every unit system.
              L.of(context).gramsUnit('$value ${L.of(context).unitG}'),
              style: context.t.titleMedium?.copyWith(fontSize: CalviSize.fsBody),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: context.t.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: Text(
      text,
      style: context.t.bodyMedium?.copyWith(fontSize: CalviSize.fsMicro, height: 1.5),
    ),
  );
}

