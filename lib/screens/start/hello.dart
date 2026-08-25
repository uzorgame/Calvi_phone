import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/day.dart';
import '../../data/meal.dart';
import '../../design/icons.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../today/meal_card.dart';

/* Заставка запуску: те, що видно щоразу, коли застосунок відкривають.
 *
 * Раніше це був перший крок «Старту» і показувався один раз у житті телефона.
 * Тепер він вітає при кожному запуску, а зі «Старту» прибраний: два однакових
 * екрани поспіль на першому запуску виглядали б як заїкання.
 *
 * Разом із переїздом зникли підпис і кнопка «Почати». Заставка не ставить питань
 * і нічого не чекає: вона грає сама і сама йде. Кнопка тут означала б, що між
 * людиною і застосунком щоразу стоїть зайвий дотик.
 *
 * ## Пʼять варіантів, і один із них щоразу
 *
 * Одна незмінна картинка на сотні запусків стає шпалерами, які перестаєш
 * помічати. Тому їх пʼять і береться випадковий.
 *
 * Але **назва стоїть у кожному**, тим самим накресленням того самого розміру.
 * Заставка це ще й те, чим застосунок себе називає; якби мінялося геть усе, у
 * нього не було б обличчя, і на двадцятий запуск людина не впізнала б, що
 * відкрила. Міняється те, що навколо назви.
 *
 * Жоден варіант не показує чисел, яких у людини немає, як своїх: числа тут
 * очевидно демонстраційні і стоять у демонстраційних картках. Показувати вигадану
 * норму на екрані власного щоденника означало б брехати двічі на день.
 *
 * ## Чому це шар зверху, а не окремий екран
 *
 * Спокуса зробити `готово ? застосунок : заставка` велика і коштує дорого.
 * Заміна кореня перебудовує все під ним, разом із навігатором, тобто застосунок
 * народжується аж після того, як заставка догра, і перший кадр після неї виходить
 * порожнім. Гірше: та сама помилка вже коштувала нам екрана налаштувань, який
 * викидало на початок списку.
 *
 * Тому застосунок стоїть у дереві з нульового кадру і спокійно прокидається під
 * заставкою: читає диск, піднімає базу, будує день. Заставка лежить над ним
 * окремим шаром і в кінці просто зникає. Дерево під нею при цьому не
 * ворухнеться: шар іде з кінця списку `Stack`, а не з середини.
 */

/// Скільки живе заставка від першого кадру до повного зникнення.
///
/// Дві секунди це верхня межа терпіння: усе, що довше, читається вже не як
/// вітання, а як повільний застосунок.
const helloSpan = Duration(milliseconds: 2000);

/// Коли починається зникання, часткою від [helloSpan].
const _leaveAt = 0.70;

/// Яка саме заставка грає.
enum Hello {
  /// Страви лягають на стіл довкола назви.
  table,

  /// Фраза і те, на що вона перетворилась, справжньою карткою застосунку.
  note,

  /// Три картки дня лягають у нещільний стос.
  deck,

  /// Стовпчики тижня виростають по черзі.
  week,

  /// Назва і три короткі рядки під нею.
  plain,
}

/* Годинник заставки.
 *
 * Одна лінійка часу на всі рухи всіх варіантів. Своя анімація в кожного шматка
 * означала б, що вони можуть розʼїхатись, а тут вони мусять іти разом: усе, що
 * зʼявляється, має закінчити зʼяву до початку зникання. */
class HelloBeat {
  const HelloBeat({required this.t, required this.gone, required this.spread});

  /// Від 0 до 1 за весь час заставки.
  final double t;

  /// Зникання, рівне: 0 доки видно, 1 коли зникло назовсім.
  final double gone;

  /// Те саме, але з прискоренням. Ним рухається все, що розходиться на виході.
  final double spread;

  /// Скільки пройдено від [fromMs] за [lenMs], у власних 0..1.
  ///
  /// У мілісекундах, а не в частках, навмисно: числа тут ті самі, що на макеті,
  /// і звіряти їх треба очима, не рахуючи в голові.
  double at(int fromMs, int lenMs, [Curve curve = CalviMotion.easeRise]) {
    final ms = t * helloSpan.inMilliseconds;
    return curve.transform(((ms - fromMs) / lenMs).clamp(0.0, 1.0));
  }
}

class HelloOverlay extends StatefulWidget {
  const HelloOverlay({super.key, required this.child, this.only, this.shown});

  /// Застосунок. Живий і працює під заставкою від першого кадру.
  final Widget child;

  /// Показати саме цю заставку замість випадкової. Тільки для тестів.
  final Hello? only;

  /* Коли застосунок справді зʼявився на екрані. Порожньо означає «спитати
   * систему», і на пристрої це єдиний правильний варіант.
   *
   * Підміняється тільки в перевірках: у тестовому каркасі растеризації не
   * існує, і системна обіцянка там не виконується ніколи, тобто заставка не
   * починалась би взагалі. */
  final Future<void>? shown;

  @override
  State<HelloOverlay> createState() => _HelloOverlayState();
}

class _HelloOverlayState extends State<HelloOverlay> with SingleTickerProviderStateMixin {
  /* Один контролер на всю заставку, і він не циклиться.
   *
   * Обидва рішення навмисні. Одна лінійка часу означає, що всі рухи ділять один
   * годинник і не можуть розʼїхатись; відсутність повтору означає, що анімація
   * має кінець, а отже `pumpAndSettle` у тесті дочекається його, а не висітиме
   * вічно на вічному обертанні. */
  late final AnimationController _run = AnimationController(vsync: this, duration: helloSpan)
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) setState(() => _over = true);
    });

  /* Відлік починається тоді, коли застосунок справді зʼявився на екрані, а не
   * тоді, коли його збудували. Різниця між цими двома митями величезна, і саме
   * вона з'їдала всю заставку.
   *
   * Android до першого намальованого кадру показує власну заставку з іконкою
   * застосунку. Flutter у цей час уже працює: будує дерево, крутить кадри,
   * рахує анімації. На емуляторі в режимі налагодження це триває секунд
   * десять. Заставка, пущена від побудови, встигала догра́ти цілком, і людина
   * бачила системну іконку, потім порожній ґрунт, і одразу день.
   *
   * Спіймано не міркуванням, а знімками з пристрою: чотири кадри поспіль після
   * системної заставки виявились **побайтово однаковими**, тобто в ту мить уже
   * ніщо не рухалось.
   *
   * `waitUntilFirstFrameRasterized` завершується рівно тоді, коли перший кадр
   * лягає на екран, тобто рівно тоді, коли Android прибирає свою заставку. Це і
   * є мить, коли нас видно. */
  @override
  void initState() {
    super.initState();
    (widget.shown ?? WidgetsBinding.instance.waitUntilFirstFrameRasterized).then((_) {
      if (mounted) _run.forward();
    });
  }

  /* Вибір робиться раз, у `initState`, а не в `build`.
   *
   * У `build` він мінявся б на кожній перебудові, тобто на зміні теми, повороті
   * і взагалі будь-коли: заставка перескакувала б з варіанта на варіант просто
   * посеред власного показу. */
  late final Hello _which = widget.only ?? Hello.values[math.Random().nextInt(Hello.values.length)];

  /// Заставка догра́ла і пішла з дерева назовсім.
  bool _over = false;

  @override
  void dispose() {
    _run.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        /* Заставка останнім елементом списку, і зникає теж з кінця. Прибраний
           останній нічого не зсуває: застосунок як був нульовим, так і
           лишається, а отже не перебудовується. */
        if (!_over)
          AnimatedBuilder(
            animation: _run,
            builder: (context, _) {
              /* Дві криві на один вихід, і кожна на своє.
               *
               * Прозорість рівна: розчинення з прискоренням око читає як
               * миготіння, а не як зникання. Спершу тут стояла `easeIn`, і
               * заставка трималась незмінною, а тоді обривалась; потім `ease`,
               * і вона зникала за піввікна, лишаючи по собі мертвий проміжок.
               * Рівна ламає обидві крайності.
               *
               * Рух навпаки, з прискоренням: сцена розходиться дедалі швидше,
               * ніби застосунок відкривається крізь неї. */
              final gone = ((_run.value - _leaveAt) / (1 - _leaveAt)).clamp(0.0, 1.0);
              final beat = HelloBeat(
                t: _run.value,
                gone: gone,
                spread: CalviMotion.easeIn.transform(gone),
              );

              /* Ковтає дотики рівно доти, доки щось видно. Це не косметика:
                 повний шар лишався б у дереві до останнього кадру і збирав
                 пальці ще довго після того, як зник з очей. */
              return AbsorbPointer(
                absorbing: gone < 1,
                child: gone >= 1
                    ? const SizedBox.shrink()
                    : Opacity(
                        opacity: 1 - gone,
                        /* Власний ґрунт поверх ґрунту застосунку: непрозорий,
                           знає тему, і саме він ховає застосунок, поки той
                           прокидається. */
                        child: CalviGround(
                          child: SafeArea(
                            child: Center(
                              /* Сцена вписується цілком, а не обрізається.
                               *
                               * Заставка це одна картинка, а не сторінка, тому
                               * на вузькому телефоні їй правильно поменшати, а
                               * не втратити край. Без цього «Тиждень» вилазив на
                               * 37 пікселів англійською на екрані 320 (сім
                               * підписів по три літери замість двох), а
                               * «Записка» на 405 пікселів униз на тому ж екрані
                               * зі збільшеним шрифтом.
                               *
                               * Збільшений шрифт при цьому не втрачається:
                               * усередині сцени він так само більший за
                               * звичайний, просто вся сцена стає меншою рівно
                               * настільки, щоб уміститись. */
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: CalviSize.gutter,
                                  vertical: 12,
                                ),
                                child: FittedBox(fit: BoxFit.scaleDown, child: _scene(beat)),
                              ),
                            ),
                          ),
                        ),
                      ),
              );
            },
          ),
      ],
    );
  }

  /* Ключ називає варіант уголос.
   *
   * Не для роботи, а щоб перевірка могла побачити, який саме випав: сам вибір
   * лежить у приватному стані, і дістатись до нього ззовні не можна, а питання
   * «чи справді випадковий» без цього не поставити. */
  Widget _scene(HelloBeat beat) => KeyedSubtree(
    key: ValueKey(_which),
    child: switch (_which) {
      Hello.table => _Table(beat: beat),
      Hello.note => _Note(beat: beat),
      Hello.deck => _Deck(beat: beat),
      Hello.week => _Week(beat: beat),
      Hello.plain => _Plain(beat: beat),
    },
  );
}

/* --- Спільне --- */

/// Назва. Одна на всі пʼять варіантів, і в цьому вся суть.
class _Mark extends StatelessWidget {
  const _Mark({required this.beat, this.size = 46});

  final HelloBeat beat;
  final double size;

  @override
  Widget build(BuildContext context) {
    final up = beat.at(0, 700);
    return Opacity(
      opacity: up,
      child: Transform.translate(
        offset: Offset(0, 10 * (1 - up)),
        // Ледь більшає на виході: застосунок ніби відкривається крізь назву.
        child: Transform.scale(
          scale: 1 + 0.06 * beat.spread,
          child: Text(
            'Calvi',
            style: context.t.displayLarge?.copyWith(fontSize: size, letterSpacing: size * -0.04),
          ),
        ),
      ),
    );
  }
}

/// Шматок сцени, який проступає знизу вгору у свій час.
class _Rise extends StatelessWidget {
  const _Rise({required this.beat, required this.fromMs, required this.lenMs, required this.child});

  final HelloBeat beat;
  final int fromMs;
  final int lenMs;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final up = beat.at(fromMs, lenMs);
    return Opacity(
      opacity: up,
      child: Transform.translate(offset: Offset(0, 14 * (1 - up)), child: child),
    );
  }
}

/* --- 1. Стіл ---
 *
 * Страви вилітають із центру по черзі й лягають колом навколо назви. По черзі, а
 * не разом: шість тарілок, поставлених одночасно, читаються як поява, а
 * поставлені одна за одною як дія. Це і є «накривають на стіл». */

const _table = ['egg', 'soup', 'bread', 'drink', 'fruit', 'meat'];

/// Радіус, на якому стоять страви, коли стіл накрито, і куди вони розходяться.
const _laid = 118.0;
const _open = 152.0;

class _Table extends StatelessWidget {
  const _Table({required this.beat});

  final HelloBeat beat;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final (i, name) in _table.indexed) _dish(context, c, i, name),
          _Mark(beat: beat),
        ],
      ),
    );
  }

  Widget _dish(BuildContext context, CalviColors c, int i, String name) {
    final lay = beat.at(i * 80, 620);

    /* Одна страва вгорі, решта рівно по колу. Кут теж їде, на третину радіана
       назад від кінцевого: без цього політ виходив прямим, як постріл, а з ним
       тарілка лягає на місце по дузі. Повільний знос за весь час заставки дає
       столу дихання: без нього коло стоїть як намальоване. */
    final angle = -math.pi / 2 + i * math.pi / 3 - 0.34 * (1 - lay) + beat.t * 0.07 * 2 * math.pi;

    return Transform.translate(
      offset: Offset.fromDirection(angle, _laid * lay + (_open - _laid) * beat.spread),
      child: Opacity(
        opacity: lay,
        child: Transform.scale(
          scale: 0.4 + 0.6 * lay,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.card,
              border: Border.all(color: c.cardBorder),
              boxShadow: context.shadowCard,
            ),
            child: CalviIcon(name, size: 19, color: c.textSecondary),
          ),
        ),
      ),
    );
  }
}

/* --- 2. Записка ---
 *
 * Одна фраза і те, на що вона перетворилась.
 *
 * Картка тут **справжня**: той самий [MealRow], що на екрані дня, у тій самій
 * оболонці з тим самим колом значка і тією самою пігулкою підсумку. Не схожа, а
 * та сама. Своя вигадана табличка була б гарна, але це була б картка з іншого
 * застосунку, і заставка обіцяла б одне, а відкривала інше. */

class _Note extends StatelessWidget {
  const _Note({required this.beat});

  final HelloBeat beat;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);

    final dishes = [
      Meal(
        id: 'hello-1',
        icon: 'egg',
        title: l.helloDishEggs,
        time: '09:12',
        slotId: 'breakfast',
        grams: 120,
        kcal: 196,
        protein: 13,
        fat: 14,
        carbs: 1,
      ),
      Meal(
        id: 'hello-2',
        icon: 'bread',
        title: l.helloDishBread,
        time: '09:12',
        slotId: 'breakfast',
        grams: 30,
        kcal: 82,
        protein: 3,
        fat: 1,
        carbs: 15,
      ),
    ];

    /* Стала ширина, а не «скільки дадуть».
     *
     * Сцена стоїть у `FittedBox`, тобто ширину їй ніхто не обмежує, і без свого
     * числа картка розтяглася б на всю уявну нескінченність. Це ж число робить
     * заставку однаковою на будь-якому телефоні: вона просто цілком меншає. */
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Менша за звичайну: під нею стоїть картка, і повний розмір почав би
          // з нею змагатися.
          Center(child: _Mark(beat: beat, size: 34)),
          const SizedBox(height: 16),

          Align(
            alignment: Alignment.centerRight,
            child: _Rise(
              beat: beat,
              fromMs: 300,
              lenMs: 480,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                decoration: BoxDecoration(
                  color: c.button,
                  borderRadius: BorderRadius.circular(CalviSize.rLarge),
                ),
                child: Text(
                  l.helloSaid,
                  style: context.t.bodyMedium?.copyWith(color: c.buttonText),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          _Rise(
            beat: beat,
            fromMs: 560,
            lenMs: 560,
            child: Container(
              decoration: BoxDecoration(
                color: c.card,
                border: Border.all(color: c.cardBorder),
                borderRadius: BorderRadius.circular(CalviSize.rLarge),
                boxShadow: context.shadowCard,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _head(context, c, l),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
                    child: Column(
                      children: [
                        for (final (i, meal) in dishes.indexed)
                          _Rise(
                            beat: beat,
                            fromMs: 820 + i * 180,
                            lenMs: 360,
                            child: MealRow(meal: meal),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Шапка картки: рівно та сама, що в `SlotCard`, без стрілки й без дотику.
  Widget _head(BuildContext context, CalviColors c, L l) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: c.iconCircle),
          child: const CalviIcon('sunrise', size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.slotBreakfast, style: context.t.titleMedium),
              const SizedBox(height: 2),
              Text(l.helloSlotSub, style: context.t.labelSmall),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: c.fillSecondary,
            borderRadius: BorderRadius.circular(CalviSize.rPill),
          ),
          child: Text(
            l.kcalUnit(278),
            style: context.t.titleMedium?.copyWith(fontSize: CalviSize.fsMicro),
          ),
        ),
      ],
    ),
  );
}

/* --- 3. Колода ---
 *
 * Три картки дня лягають у нещільний стос. Кути ледь різні навмисно: стос, який
 * хтось клав руками, а не вирівняний друкарською машинкою. */

class _Deck extends StatelessWidget {
  const _Deck({required this.beat});

  final HelloBeat beat;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);

    final cards = [
      ('sunrise', l.slotBreakfast, 278, -1.6),
      ('sun', l.slotLunch, 346, 1.1),
      ('moon', l.slotDinner, 512, 0.0),
    ];

    // Своя ширина, з тієї самої причини, що й у «Записки»: сцена стоїть у
    // `FittedBox` і ширини ззовні не отримує.
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _Mark(beat: beat)),
          const SizedBox(height: 22),
          for (final (i, (icon, title, kcal, tilt)) in cards.indexed) ...[
            if (i > 0) const SizedBox(height: 10),
            _Rise(
              beat: beat,
              fromMs: 380 + i * 180,
              lenMs: 560,
              child: Transform.rotate(
                angle: tilt * math.pi / 180,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: c.card,
                    border: Border.all(color: c.cardBorder),
                    borderRadius: BorderRadius.circular(CalviSize.rLarge),
                    boxShadow: context.shadowCard,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: c.iconCircle),
                        child: CalviIcon(icon, size: 18, color: c.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: context.t.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        l.kcalUnit(kcal),
                        style: context.t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/* --- 4. Тиждень ---
 *
 * Сім стовпчиків виростають по черзі, сьогоднішній чорнилом, решта тихо. Та сама
 * мова графіка, якою говорить екран аналітики.
 *
 * Тихі дні розведеним чорнилом, а не доріжкою: на ґрунті застосунку доріжку
 * майже не видно, і з семи стовпчиків читався б один. Той самий урок графік води
 * в аналітиці вже пройшов, і там про це є окремий коментар. */

const _week = [0.52, 0.78, 0.64, 0.9, 0.47, 0.71, 0.58];
const _today = 5;

class _Week extends StatelessWidget {
  const _Week({required this.beat});

  final HelloBeat beat;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final days = weekdaysFromMonday(Localizations.localeOf(context).languageCode);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Mark(beat: beat),
        const SizedBox(height: 30),
        SizedBox(
          height: 180,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (i, v) in _week.indexed) ...[
                if (i > 0) const SizedBox(width: 14),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    /* Росте знизу вгору, як наливається: масштабується сам
                       стовпчик, тому висота тут і є число. */
                    Align(
                      alignment: Alignment.bottomCenter,
                      heightFactor: 1,
                      child: Transform.scale(
                        scaleY: beat.at(380 + i * 70, 520),
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 22,
                          height: 143 * v,
                          decoration: BoxDecoration(
                            color: i == _today ? c.button : c.button.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(CalviSize.rPill),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      days[i],
                      style: context.t.labelSmall?.copyWith(
                        color: i == _today ? c.text : c.textSecondary,
                        fontWeight: i == _today ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/* --- 5. Чисто ---
 *
 * Сама типографіка: назва, а під нею обіцянка трьома короткими рядками, які
 * проступають один за одним.
 *
 * Рядки вирівняні по лівому краю, а по центру стоїть увесь блок. Кожен рядок
 * окремо центрувався б за власною довжиною, і три значки ставали б трьома
 * різними відступами: замість колонки виходили б сходинки. Англійська довша за
 * українську на третину, тому без цього зміна мови ще й зсувала б колонку. */

class _Plain extends StatelessWidget {
  const _Plain({required this.beat});

  final HelloBeat beat;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);

    final steps = [('mic', l.helloStepSay), ('flame', l.helloStepCount), ('check', l.helloStepLog)];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Mark(beat: beat),
        const SizedBox(height: 26),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, (icon, text)) in steps.indexed) ...[
              if (i > 0) const SizedBox(height: 13),
              _Rise(
                beat: beat,
                fromMs: 460 + i * 170,
                lenMs: 460,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: c.iconCircle),
                      child: CalviIcon(icon, size: 16, color: c.textSecondary),
                    ),
                    const SizedBox(width: 10),
                    /* Без `Flexible`: ширини ззовні тут немає, і гнутись немає
                       від чого. Довгий рядок робить сцену ширшою, а вписує її
                       `FittedBox` над усім. */
                    Text(text, style: context.t.bodyLarge),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
