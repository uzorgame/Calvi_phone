import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/allergens.dart';
import '../../data/settings.dart';
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
import '../../format.dart';

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

/* Allergies asked at the start are only the common ones. The full reference is
   in settings; a first run is not the place to scroll thirty seven entries. */
const _common = [
  'peanut',
  'hazelnut',
  'milk',
  'egg',
  'gluten',
  'fish',
  'crustacean',
  'soy',
  'sesame',
];

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

  /* The same split the norm screen uses: protein by weight, fat by share, the
     rest carbohydrates. Shown at the end so the number is a plan, not a
     verdict. */
  int get _protein => (_weightKg * 1.7).round();
  int get _fat => (calcKcal(_draft) * 0.28 / 9).round();
  int get _carbs => ((calcKcal(_draft) - _protein * 4 - _fat * 9) / 4).round();

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
    final groups = <({String key, String title, List<String> labels, List<String> values})>[
      (key: 'mass', title: l.unitsMass, labels: [l.unitKg, 'lb', 'st'], values: ['kg', 'lb', 'st']),
      (key: 'length', title: l.unitsLength, labels: [l.unitCm, 'in'], values: ['cm', 'in']),
      (key: 'volume', title: l.unitsVolume, labels: [l.unitMl, 'fl oz'], values: ['ml', 'floz']),
      (key: 'portion', title: l.unitsPortion, labels: [l.unitG, 'oz'], values: ['g', 'oz']),
      (
        key: 'energy',
        title: l.unitsEnergy,
        labels: [l.unitKcal, l.unitKj],
        values: ['kcal', 'kj'],
      ),
    ];

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
        child: CalviSegments(
          labels: [l.startSexMale, l.startSexFemale, l.startSexOther],
          index: switch (_sex) {
            Sex.m => 0,
            Sex.f => 1,
            Sex.x => 2,
          },
          onPick: (i) => setState(
            () => _sex = switch (i) {
              0 => Sex.m,
              1 => Sex.f,
              _ => Sex.x,
            },
          ),
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
        aside: '$_heightCm ${l.unitCm}',
        child: CalviWheel(
          values: heights,
          value: _heightCm,
          suffix: l.unitCm,
          compact: true,
          onPick: (v) => setState(() => _heightCm = v),
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
        value: _weightKg,
        min: 40,
        max: 180,
        suffix: l.unitKg,
        onChange: (v) => setState(() => _weightKg = v),
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
          onTap: () => setState(() => _direction = g.id),
        ),
      if (_direction != Direction.keep)
        _Field(
          label: l.startTargetWeight,
          value: _targetKg.toStringAsFixed(1),
          unit: l.unitKg,
          child: CalviRuler(
            showValue: false,
            value: _targetKg,
            min: 40,
            max: 180,
            suffix: l.unitKg,
            onChange: (v) => setState(() => _targetKg = v),
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
            text: _pace.toStringAsFixed(1),
            children: [
              TextSpan(
                text: '  ${l.startPaceUnit}',
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
      const SizedBox(height: 26),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          l.startAllergies,
          style: context.t.titleMedium?.copyWith(fontSize: CalviSize.fsCaption),
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 7,
        runSpacing: 7,
        children: [
          for (final id in _common)
            if (allergenById(id) case final a?)
              _Chip(
                label: a.name,
                on: _allergies.contains(id),
                onTap: () => setState(
                  () => _allergies.contains(id) ? _allergies.remove(id) : _allergies.add(id),
                ),
              ),
        ],
      ),
    ],
  );

  Widget _normStep() {
    final c = context.c;
    final kcal = calcKcal(_draft);
    final weeks = weeksToTarget(_draft);

    return _Step(
      title: l.startNorm,
      cta: l.actionNext,
      onNext: () => _go(8),
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
                    Text(thousands(kcal), style: context.t.displayLarge?.copyWith(height: 1)),
                    const SizedBox(height: 6),
                    Text(l.startNormPerDay, style: context.t.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              CalviRing(
                progress: 1,
                size: 92,
                stroke: 9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      weeks > 0 ? '$weeks' : '∞',
                      style: context.t.headlineLarge?.copyWith(
                        fontSize: 24,
                        letterSpacing: 24 * -0.02,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      weeks > 0 ? l.startNormWeeks : l.startNormHold,
                      style: context.t.labelSmall?.copyWith(fontSize: 9, height: 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: CalviSize.gapCard),
        Row(
          children: [
            _MacroDot(label: l.macroProtein, value: _protein, colour: c.protein, icon: 'protein'),
            const SizedBox(width: CalviSize.gapCard),
            _MacroDot(label: l.macroFat, value: _fat, colour: c.fats, icon: 'fat'),
            const SizedBox(width: CalviSize.gapCard),
            _MacroDot(label: l.macroCarbs, value: _carbs, colour: c.carbs, icon: 'carbs'),
          ],
        ),
        const SizedBox(height: CalviSize.gapCard),
        CalviNora(text: l.startNormNora, hint: l.startNormNoraHint),
        _Note(l.startNormNote),
      ],
    );
  }
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
  });

  final String title;
  final String cta;
  final VoidCallback onNext;
  final List<Widget> children;

  /// Stands the content in the middle of the room it has, for a screen that
  /// holds one control: a lone tape at the top of an empty screen reads as
  /// something that failed to load below it.
  final bool middle;

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
        Padding(
          padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 26),
          child: CalviButton(label: cta, onTap: onNext),
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
              L.of(context).gramsUnit(value),
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

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.on, required this.onTap});

  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: CalviMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          /* Unpicked does not mean unavailable.
             These sat on `fillSecondary` over the page ground, one step of 255
             apart, so the chip had no shape at all, and `textSecondary` on it
             came to 2.99:1 where small text needs 4.5:1. Next to the activity
             options, which are white cards with dark titles, the one thing on
             the screen you have to tap looked like the one thing you could
             not. Ground it reads on, and ink you can read. */
          color: on ? c.button : c.track,
          borderRadius: BorderRadius.circular(CalviSize.rPill),
        ),
        child: Text(
          label,
          style: context.t.labelSmall?.copyWith(
            fontSize: CalviSize.fsMicro,
            fontWeight: on ? FontWeight.w600 : FontWeight.w400,
            color: on ? c.buttonText : c.text,
          ),
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

