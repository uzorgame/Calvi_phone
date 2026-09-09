import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/units.dart';
import '../../design/icons.dart';
import '../../design/ring.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../l10n/app_localizations.dart';

/* Розвилка першого запуску.
 *
 * Заставка запуску йде сама і нічого не питає: вона показується щоразу, коли
 * застосунок відкривають. Цей екран інший і буває рівно один раз, поки на
 * телефоні немає ні акаунта, ні профілю. Він ставить єдине питання, на яке
 * застосунок сам відповісти не може: людина тут уперше чи повертається.
 *
 * **Показує, а не перелічує.** Замість переліку можливостей тут розігрується
 * те саме, що станеться з людиною за пів хвилини: фраза, яку вона напише, і
 * відповідь, яку отримає. Одна сцена пояснює більше, ніж три рядки, і не
 * вимагає вірити на слово.
 *
 * **Кнопок унизу немає.** Тут стояли дві: «Почати» і «У мене вже є акаунт».
 * Обидві питали те саме, що наступний екран питає й так, тільки формою, у якій
 * не помилишся: вхід і реєстрація тепер стоять на ньому поруч. Дві кнопки, які
 * ведуть на один екран, це два зайві дотики і одна розвилка, на якій можна
 * помилитись.
 *
 * Тому сцена догравається і сама йде далі. Час до переходу це не пауза, а
 * рівно стільки, скільки триває сама сцена: відповідь Нори має встигнути
 * зʼявитись і бути прочитаною.
 */
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, required this.onDone});

  /// Сцена догралась: далі вхід.
  final VoidCallback onDone;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

/// Коли приходить відповідь. Фраза до цього вже стоїть на своєму місці.
const _answerAt = Duration(milliseconds: 1000);

/* Коли екран іде далі сам. Відповідь приходить на першій секунді, числа в ній
   набігають майже секунду, і ще стільки ж треба, щоб їх прочитати. */
const _leaveAt = Duration(milliseconds: 3400);

/// Скільки триває поява кожної ланки і скільки триває набіг чисел.
const _riseMs = 620;
const _countMs = 900;

class _WelcomeScreenState extends State<WelcomeScreen> {
  /* Відповідь приходить не разом із фразою: спершу людина щось сказала, і аж
     потім застосунок відповів. Одна мить на двох робила б із розмови картинку. */
  bool _answered = false;
  Timer? _wait;
  Timer? _leave;

  @override
  void initState() {
    super.initState();
    _wait = Timer(_answerAt, () {
      if (mounted) setState(() => _answered = true);
    });
    // Далі екран іде сам: питати тут нічого, а чекати на дотик нема за чим.
    _leave = Timer(_leaveAt, () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _wait?.cancel();
    _leave?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);

    return Scaffold(
      // Прозорий: під сторінкою лежить ґрунт, який знає тему.
      backgroundColor: const Color(0x00000000),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /* Знак застосунку той самий, що на робочому столі, і намальований
                 тим самим кільцем, яким застосунок міряє день. Не картинка: так
                 він чіткий на будь-якому екрані, живе в темі разом з усім іншим
                 і домальовується при появі, як усі кільця тут. */
              const SizedBox(height: 64),
              _Rise(
                delay: 0,
                child: Center(
                  child: CalviRing(progress: 0.84, size: 66, stroke: 9.5, child: SizedBox()),
                ),
              ),

              const SizedBox(height: 14),
              _Rise(
                delay: 140,
                child: Text(
                  'Calvi',
                  textAlign: TextAlign.center,
                  style: context.t.displayLarge?.copyWith(fontSize: 40, height: 1),
                ),
              ),

              const SizedBox(height: 6),
              _Rise(
                delay: 260,
                child: Text(
                  l.welLead,
                  textAlign: TextAlign.center,
                  style: context.t.bodyLarge?.copyWith(color: c.textSecondary),
                ),
              ),

              // --- Сцена: фраза, а за нею відповідь ---
              const SizedBox(height: 36),
              _Rise(
                delay: 480,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 260),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                    decoration: BoxDecoration(
                      color: c.button,
                      borderRadius: BorderRadius.circular(CalviSize.rCard),
                    ),
                    child: Text(
                      l.welSaid,
                      style: context.t.bodyLarge?.copyWith(color: c.buttonText),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              /* Картка приходить у відповідь, тому її поява починається не за
                 годинником екрана, а за тим, коли Нора «відповіла». */
              if (_answered) _Rise(delay: 0, child: _Answer(count: _countMs)),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

/// Картка розбору: те, що людина побачить у застосунку після кожного запису.
class _Answer extends StatelessWidget {
  const _Answer({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: c.cardBorder),
        borderRadius: BorderRadius.circular(CalviSize.rLarge),
        boxShadow: context.shadowCard,
      ),
      child: Column(
        children: [
          _Dish(icon: 'egg', name: l.welEggs, grams: l.welEggsGrams, kcal: 196, ms: count),
          _Dish(icon: 'bread', name: l.welToast, grams: l.welToastGrams, kcal: 140, ms: count),

          // Підсумок під рискою: кільце і число, як на картці дня.
          const SizedBox(height: 10),
          Divider(height: 1, thickness: 1, color: c.cardBorder),
          const SizedBox(height: 12),
          Row(
            children: [
              const CalviRing(progress: 0.34, size: 38, stroke: 4, child: SizedBox()),
              const SizedBox(width: 12),
              _Counted(
                to: 336,
                ms: count,
                builder: (value) => Text.rich(
                  TextSpan(
                    text: '${l.welTotal} ',
                    children: [
                      TextSpan(
                        text: dataUnits.enNum(value),
                        style: TextStyle(color: c.text, fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: ' ${dataUnits.enLabel}'),
                    ],
                  ),
                  style: context.t.bodyLarge?.copyWith(color: c.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Dish extends StatelessWidget {
  const _Dish({
    required this.icon,
    required this.name,
    required this.grams,
    required this.kcal,
    required this.ms,
  });

  final String icon;
  final String name;
  final String grams;
  final int kcal;
  final int ms;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.fillSecondary, shape: BoxShape.circle),
            child: CalviIcon(icon, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: context.t.bodyLarge),
                const SizedBox(height: 2),
                Text(grams, style: context.t.labelSmall?.copyWith(fontSize: CalviSize.fsMicro)),
              ],
            ),
          ),
          _Counted(
            to: kcal,
            ms: ms,
            builder: (value) => Text(
              '$value',
              style: context.t.headlineMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/* Число, що набігає до свого значення.
 *
 * Усі три числа картки йдуть разом: одне живе число серед двох завмерлих
 * читалось би як помилка, а не як розрахунок. Це той самий рух, який людина
 * побачить на картці дня після кожного запису. */
class _Counted extends StatelessWidget {
  const _Counted({required this.to, required this.ms, required this.builder});

  final int to;
  final int ms;
  final Widget Function(int value) builder;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: to.toDouble()),
      duration: Duration(milliseconds: ms),
      curve: CalviMotion.easeRise,
      builder: (context, value, _) => builder(value.round()),
    );
  }
}

/* Поява однієї ланки: коротке проступання знизу, зі своєю затримкою.
 *
 * Кожна ланка заходить після попередньої, і екран читається як розмова, що йде
 * на очах, а не як сторінка, що з'явилась готовою. */
class _Rise extends StatelessWidget {
  const _Rise({required this.delay, required this.child});

  final int delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Затримка схована в криву: перші кадри руху немає.
    final total = delay + _riseMs;
    final start = delay / total;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(start, 1, curve: CalviMotion.easeRise),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 10 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}
