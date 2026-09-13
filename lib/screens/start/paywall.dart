import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/app_scope.dart';
import '../../data/billing/billing.dart';
import '../../data/legal.dart';
import '../../data/nutrients.dart';
import '../../design/icons.dart';
import '../../design/nutri_row.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../settings/panel_legal.dart';
import '../settings/panels_account.dart' show PlanCard;

/// Пейвол: остання картка «Старту», один в один з демкою.
///
/// Стоїть після норми, а не перед анкетою. Просити гроші до того, як людина
/// побачила, що саме купує, означає продавати рахунок, а не помічницю. Тут вона
/// вже відповіла на анкету і побачила свою норму, і рахунок читається як
/// рахунок за побачене.
///
/// **Фото, яке працює, а не ілюструє.** Верхня частина екрана це сцена: рамка
/// видошукача зі сканера, промінь, що проходить по тарілці, підписи над
/// інгредієнтами і картка результату, як картка страви в щоденнику. Людина
/// бачить не «у нас є фото», а те, що станеться з її тарілкою, і бачить це за
/// дві секунди, доки рука ще не дійшла до кнопки. Нутрієнти на картці стоять з
/// числами і міткою Pro: це саме той рядок, який підписка відкриває.
///
/// **Без прокрутки.** Усе, що під фото, має сталу висоту, а фото забирає решту:
/// квадрат розміром із менше з двох, ширини або того, що лишилось. На високому
/// телефоні це повна ширина, на короткому квадрат менший, але ціни й кнопки на
/// місці завжди. Пейвол, у якому ціну треба гортати, ховає її.
///
/// **Безкоштовний шлях це вибір, а не лазівка.** Сорок токенів ми даємо кожному
/// на реєстрації, і кнопка «Почати із пробними токенами» стоїть під головною,
/// повним рядком, а не сірим хрестиком у куті.
class Paywall extends StatefulWidget {
  const Paywall({super.key, required this.onDone, required this.onSignIn});

  /// Куди йти далі: у щоденник. Та сама дорога і після оплати, і без неї.
  final VoidCallback onDone;

  /// Куди вести, коли людина без акаунта хоче купити: на екран входу.
  final VoidCallback onSignIn;

  @override
  State<Paywall> createState() => _PaywallState();
}

/// Скільки токенів дає реєстрація. Те саме число, що `SIGNUP_GRANT` на сервері.
const _trialTokens = 40;

class _PaywallState extends State<Paywall> {
  String _plan = 'year';
  List<StorePlan> _store = const [];
  bool _busy = false;

  /// Застосований промокод: сам код і скільки відсотків він знімає.
  ({String code, int off})? _promo;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final plans = await Billing.plans();
    if (mounted) setState(() => _store = plans);
  }

  StorePlan? _found(String kind) {
    for (final p in _store) {
      if (p.kind == kind) return p;
    }
    return null;
  }

  int get _off => _promo?.off ?? 0;

  /// Ціна тарифу зі знижкою, коли вона є, рядком магазину.
  String? _priceOf(String kind) {
    final p = _found(kind);
    if (p == null) return null;
    return Billing.withAmount(p.display, Billing.withOff(p.amount, _off));
  }

  String? get _perMonth {
    final y = _found('year');
    if (y == null) return null;
    return Billing.withAmount(y.display, Billing.withOff(y.amount, _off) / 12);
  }

  int? get _saving {
    final m = _found('month');
    final y = _found('year');
    if (m == null || y == null || m.amount == 0) return null;
    return ((1 - y.amount / 12 / m.amount) * 100).round();
  }

  void _say(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  /* Купити обраний тариф. Той самий шлях, що на сторінці підписки: вхід перед
     оплатою, вікно магазину, підтвердження в сервера. Далі щоденник: сторінка
     закривається за покупкою, а лічильник зникне сам, щойно сервер підтвердить. */
  Future<void> _buy() async {
    final l = L.of(context);
    final db = AppScope.maybeOf(context)?.db;
    // Без бази це демо або тест: там нема кого просити увійти.
    final signedIn = db == null || (await db.syncDao.state()).email != null;
    if (!mounted) return;
    if (!signedIn) {
      await calviSheet<void>(
        context,
        title: l.planSignInTitle,
        doneLabel: l.planSignInGo,
        cancelLabel: l.planLater,
        onDone: widget.onSignIn,
        builder: (sheet) => Padding(
          padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 4, CalviSize.gutter, 12),
          child: Text(l.planSignInNote, style: sheet.t.bodyMedium),
        ),
      );
      return;
    }

    final plan = _found(_plan);
    if (plan == null) {
      _say(l.planStoreQuiet);
      return;
    }

    setState(() => _busy = true);
    final result = await Billing.buy(plan);
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result) {
      case BuyResult.done:
        final sync = AppScope.maybeOf(context)?.sync;
        final confirmed = await sync?.confirmPurchase();
        if (confirmed != true) unawaited(sync?.now() ?? Future<void>.value());
        if (mounted) widget.onDone();
      case BuyResult.canceled:
        break;
      case BuyResult.failed:
        _say(l.planFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final c = context.c;
    final live = _store.isNotEmpty;
    final yearPrice = _priceOf('year');

    return Column(
      children: [
        /* Фото забирає все, що лишилось після сталого низу, і ніколи не більше:
           квадрат по центру, розміром із менше з двох. */
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: CalviSize.gutter),
            child: Center(child: AspectRatio(aspectRatio: 1, child: _Scene())),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 16, CalviSize.gutter, 12),
          child: Column(
            children: [
              _Promo(promo: _promo, onPromo: (p) => setState(() => _promo = p)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PlanCard(
                      name: l.planYear,
                      save: _saving == null ? null : '-$_saving%',
                      price: _perMonth,
                      unit: live ? l.planPerMonth : null,
                      note: yearPrice == null ? null : l.planYearBilled(yearPrice),
                      on: _plan == 'year',
                      flash: _promo != null,
                      tight: true,
                      onTap: () => setState(() => _plan = 'year'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PlanCard(
                      name: l.planMonth,
                      price: _priceOf('month'),
                      unit: live ? l.planPerMonth : null,
                      note: live ? l.planMonthBilled : null,
                      on: _plan == 'month',
                      flash: _promo != null,
                      tight: true,
                      onTap: () => setState(() => _plan = 'month'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        /* Саме слово, без ціни: ціна і строк стоять на обраній картці просто над
           кнопкою. Під нею повним рядком безкоштовна дорога, під тією два
           документи, ті самі, що на «Ласкаво просимо», і той самий аркуш. */
        Padding(
          padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 10, CalviSize.gutter, 26),
          child: Column(
            children: [
              CalviButton(label: l.planBuy, busy: _busy, onTap: () => unawaited(_buy())),
              const SizedBox(height: 2),
              _Quiet(label: l.payTrial(_trialTokens), onTap: widget.onDone),
              const SizedBox(height: 2),
              /* Стискається, а не переноситься: другий рядок з одним словом під
                 кнопками читався б як недогляд. */
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Link(label: l.planTerms, onTap: () => unawaited(legalSheet(context, terms))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('·', style: TextStyle(fontSize: 11, color: c.faint)),
                    ),
                    _Link(
                      label: l.planPrivacy,
                      onTap: () => unawaited(legalSheet(context, privacy)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Тиха кнопка повним рядком: помітна, але не сперечається з головною за погляд.
class _Quiet extends StatelessWidget {
  const _Quiet({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => CalviPress(
    onTap: onTap,
    builder: (context, down) => AnimatedOpacity(
      opacity: down ? 0.6 : 1,
      duration: CalviMotion.fast,
      child: SizedBox(
        height: 36,
        child: Center(
          child: Text(
            label,
            style: context.t.bodyLarge?.copyWith(
              fontSize: CalviSize.fsCaption,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ),
  );
}

class _Link extends StatelessWidget {
  const _Link({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => CalviPress(
    onTap: onTap,
    builder: (context, down) => AnimatedOpacity(
      opacity: down ? 0.6 : 1,
      duration: CalviMotion.fast,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          label,
          style: context.t.labelSmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.underline,
            decorationColor: context.c.textSecondary,
          ),
        ),
      ),
    ),
  );
}

/* ── Промокод ──────────────────────────────────────────────────────────── */

/* Спершу один тихий рядок «Маю промокод»: поле на весь екран для кожного, хоч
   код є в одного з десяти, читалось би як ще одна анкета. Дотик відкриває поле
   на тому самому місці; застосований код стає міткою з галочкою, кодом і
   відсотком, а ціни на картках перекочуються на нові. Незнайомий код не карає:
   поле здригається, підказка червоніє, і можна набирати далі.

   Рамка сталої висоти під усі три стани: тарифи під нею стоять на місці. */
class _Promo extends StatefulWidget {
  const _Promo({required this.promo, required this.onPromo});

  final ({String code, int off})? promo;
  final ValueChanged<({String code, int off})?> onPromo;

  @override
  State<_Promo> createState() => _PromoState();
}

class _PromoState extends State<_Promo> {
  bool _ask = false;
  int _bad = 0;
  final _code = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _apply() => unawaited(_check(_code.text.trim().toUpperCase()));

  Future<void> _check(String key) async {
    _code.clear();
    final off = await Billing.promo(key);
    if (!mounted) return;
    if (off == null) {
      setState(() => _bad++);
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _bad = 0);
    widget.onPromo((code: key, off: off));
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final promo = widget.promo;

    return SizedBox(
      height: 50,
      child: Center(
        child: promo != null
            ? _Applied(
                code: promo.code,
                off: promo.off,
                onDrop: () {
                  HapticFeedback.selectionClick();
                  widget.onPromo(null);
                },
              )
            : _ask
            ? _Field(
                key: ValueKey(_bad),
                controller: _code,
                focus: _focus,
                bad: _bad > 0,
                onApply: _apply,
              )
            : CalviPress(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _ask = true);
                },
                builder: (context, down) => AnimatedOpacity(
                  opacity: down ? 0.6 : 1,
                  duration: CalviMotion.fast,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Text(
                      l.payHavePromo,
                      style: context.t.labelSmall?.copyWith(fontSize: CalviSize.fsMicro),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

/* Поле і мітка це та сама картка, що й тарифи під ними: біла, з тонкою рамкою
   і тією самою тінню. Праворуч кружок із галочкою, як на обраному тарифі:
   порожній, поки нема що застосовувати, чорнильний, щойно є. */
class _Field extends StatefulWidget {
  const _Field({
    super.key,
    required this.controller,
    required this.focus,
    required this.bad,
    required this.onApply,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final bool bad;
  final VoidCallback onApply;

  @override
  State<_Field> createState() => _FieldState();
}

/// Що б не набрали, у полі стоїть капс.
final _upper = TextInputFormatter.withFunction((old, v) => v.copyWith(text: v.text.toUpperCase()));

class _FieldState extends State<_Field> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.focus.requestFocus());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  void _changed() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);
    final has = widget.controller.text.trim().isNotEmpty;

    /* Здригання незнайомого коду: рамка червоніє тим самим тоном, яким день
       каже про перебір. Без окремого рядка помилки: він зсунув би тарифи, а
       підказка в самому полі каже те саме на місці. */
    return _Shake(
      on: widget.bad,
      child: _Appear(
        child: Container(
          height: 50,
          padding: const EdgeInsets.only(left: 16, right: 9),
          decoration: BoxDecoration(
            color: c.card,
            border: Border.all(color: widget.bad ? c.protein : c.cardBorder),
            borderRadius: BorderRadius.circular(CalviSize.rCard),
            boxShadow: context.shadowCard,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focus,
                  textCapitalization: TextCapitalization.characters,
                  // Капсом одразу, як у демці: так код виглядає на купоні.
                  inputFormatters: [_upper],
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => widget.onApply(),
                  style: context.t.bodyLarge?.copyWith(
                    fontSize: CalviSize.fsCaption,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.6,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: widget.bad ? l.payPromoBad : l.payPromo,
                    hintStyle: context.t.bodyLarge?.copyWith(
                      fontSize: CalviSize.fsCaption,
                      color: widget.bad ? c.protein : c.faint,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Semantics(
                button: true,
                enabled: has,
                label: l.payPromoApply,
                child: CalviPress(
                  onTap: has ? widget.onApply : () {},
                  builder: (context, down) => AnimatedScale(
                    scale: down && has ? 0.92 : 1,
                    duration: CalviMotion.fast,
                    child: AnimatedContainer(
                      duration: CalviMotion.fast,
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: has ? c.button : c.fillSecondary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: CalviIcon('check', size: 14, color: has ? c.buttonText : c.faint),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* Застосований код: та сама картка, лише замість поля зелена галочка, код і
   відсоток, а праворуч хрестик, щоб передумати. Картку зеленим не заливаємо:
   стан каже галочка, як усюди в застосунку, а не колір поверхні.

   Хрестик зʼявляється рівно там, де щойно була галочка «застосувати», під тим
   самим пальцем, і перші пів секунди дотиків не приймає: другий дотик на тому
   самому місці знімав би код, який людина щойно ввела. */
class _Applied extends StatefulWidget {
  const _Applied({required this.code, required this.off, required this.onDrop});

  final String code;
  final int off;
  final VoidCallback onDrop;

  @override
  State<_Applied> createState() => _AppliedState();
}

class _AppliedState extends State<_Applied> {
  bool _armed = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => _armed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);

    return _Appear(
      child: Container(
        height: 50,
        padding: const EdgeInsets.only(left: 12, right: 9),
        decoration: BoxDecoration(
          color: c.card,
          border: Border.all(color: c.cardBorder),
          borderRadius: BorderRadius.circular(CalviSize.rCard),
          boxShadow: context.shadowCard,
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(color: c.success, shape: BoxShape.circle),
              child: const Center(child: CalviIcon('check', size: 12, color: Colors.white)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.t.titleMedium?.copyWith(
                      fontSize: CalviSize.fsCaption,
                      letterSpacing: 0.6,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    l.payPromoOff(widget.off),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.t.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IgnorePointer(
              ignoring: !_armed,
              child: Semantics(
                button: true,
                label: l.payPromoDrop,
                child: CalviPress(
                  onTap: widget.onDrop,
                  builder: (context, down) => AnimatedOpacity(
                    opacity: down ? 0.6 : 1,
                    duration: CalviMotion.fast,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: c.fillSecondary, shape: BoxShape.circle),
                      child: Center(
                        child: Transform.rotate(
                          angle: math.pi / 4,
                          child: CalviIcon('plus', size: 16, color: c.textSecondary),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Проявляється на місці рядка, злегка виростаючи: 320 мс, як у демці.
class _Appear extends StatelessWidget {
  const _Appear({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 320),
    curve: CalviMotion.easeRise,
    builder: (context, t, child) => Opacity(
      opacity: t,
      child: Transform.scale(scale: 0.97 + 0.03 * t, child: child),
    ),
    child: child,
  );
}

/// Здригання вбік, 420 мс, за тими самими ключами, що в демці.
class _Shake extends StatelessWidget {
  const _Shake({required this.on, required this.child});

  final bool on;
  final Widget child;

  /* Ті самі ключові кадри, що в демці, з лінійним переходом між ними: до
     десятої частини мінус один, далі два, чотири в обидва боки, і назад. */
  static const _keys = [0.0, -1.0, 2.0, -4.0, 4.0, -4.0, 4.0, -4.0, 2.0, -1.0, 0.0];

  static double _dx(double t) {
    final pos = (t * 10).clamp(0.0, 10.0);
    final i = pos.floor().clamp(0, 9);
    return _keys[i] + (_keys[i + 1] - _keys[i]) * (pos - i);
  }

  @override
  Widget build(BuildContext context) {
    if (!on) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.linear,
      builder: (context, t, child) => Transform.translate(offset: Offset(_dx(t), 0), child: child),
      child: child,
    );
  }
}

/* ── Сцена на фото ─────────────────────────────────────────────────────── */

/* Що Нора «побачила» на фото.
 *
 * На фото ціла пательня, а не тарілка, і картка каже це прямо: чотири порції,
 * рахуємо одну. Числа за порцію на 350 г, і макроси дають ті самі калорії, що
 * стоять зверху. Сама камера поки що пательню від тарілки не відрізняє; тут
 * стоїть те, що вона має казати. */
const _kcal = 540;
const _protein = 28;
const _fat = 16;
const _carbs = 70;

/// Нутрієнти за порцію, у порядку ряду дня: клітковина, цукор, доданий,
/// натрій у грамах, насичені.
const _nutri = ['4', '3', '0', '1.2', '3'];

/* Підписи стоять над тим, що підписують: рис між креветками вгорі, велика
   креветка праворуч від центру, горошок ліворуч, усі вище картки. Крапка в
   тоні макросу, з якого інгредієнт здебільшого складається. Затримка кожного
   це мить, коли промінь проходить його рядок. Частки від сторони квадрата. */
class _Tag {
  const _Tag(this.name, this.x, this.y, this.at);

  final String Function(L) name;
  final double x;
  final double y;
  final double at;
}

final _tags = [
  _Tag((l) => l.payRice, 0.58, 0.22, 0.9),
  _Tag((l) => l.payShrimp, 0.66, 0.42, 1.5),
  _Tag((l) => l.payPeas, 0.26, 0.44, 1.6),
];

const _photo = 'assets/img/paella.webp';

/// Уся сцена триває стільки, а після цього стоїть.
const _sceneMs = 2500;

class _Scene extends StatefulWidget {
  @override
  State<_Scene> createState() => _SceneState();
}

class _SceneState extends State<_Scene> with SingleTickerProviderStateMixin {
  bool _started = false;
  late final AnimationController _t = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _sceneMs),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    /* Кому рух заважає, той бачить сцену одразу в кінцевому стані: підписи і
       картка на місці, без променя. */
    if (MediaQuery.disableAnimationsOf(context)) {
      _t.value = 1;
      return;
    }
    /* Спершу фото, потім сцена. У демці фото вже в кеші, і рамка з променем
       ідуть по тарілці; тут кадр розкодовується мить, і без цього перші
       підписи виринали б над сірим квадратом, а не над їжею. */
    unawaited(
      precacheImage(const AssetImage(_photo), context).then((_) {
        if (mounted) _t.forward();
      }),
    );
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  /// Частка від 0 до 1 між двома мітками часу сцени, у секундах.
  double _span(double from, double to, [Curve curve = Curves.linear]) {
    final s = _t.value * _sceneMs / 1000;
    final raw = ((s - from) / (to - from)).clamp(0.0, 1.0);
    return curve.transform(raw);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);
    final tints = [c.carbs, c.protein, c.success];

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CalviSize.rLarge),
        boxShadow: context.shadowCard,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CalviSize.rLarge),
        child: DecoratedBox(
          decoration: BoxDecoration(color: c.fillSecondary),
          child: LayoutBuilder(
            builder: (context, box) {
              final side = box.maxWidth;
              return AnimatedBuilder(
                animation: _t,
                builder: (context, _) {
                  final frame = _span(0, 0.62, CalviMotion.easeRise);
                  final beam = _span(0.4, 2.0, Curves.easeInOut);
                  final card = _span(2.0, 2.48, CalviMotion.easeRise);

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(_photo, fit: BoxFit.cover),

                      /* Рамка видошукача з кутами зі сканера, на весь квадрат, з
                       полем 14 від країв, і промінь: та сама лінія, що
                       гойдається над штрихкодом, тут проходить вікно згори
                       донизу один раз і гасне. */
                      Positioned.fill(
                        child: Opacity(
                          opacity: frame,
                          child: Transform.scale(
                            scale: 1.06 - 0.06 * frame,
                            child: CustomPaint(painter: _CornersPainter()),
                          ),
                        ),
                      ),
                      if (beam > 0 && beam < 1)
                        Positioned(
                          left: 20,
                          right: 20,
                          top: 14 + (side - 28) * beam,
                          child: Opacity(
                            opacity: beam < 0.5 ? 0.35 + 1.3 * beam : 1 - (beam - 0.5) * 2,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: const LinearGradient(
                                  colors: [Color(0x00FFFFFF), Colors.white, Color(0x00FFFFFF)],
                                ),
                              ),
                            ),
                          ),
                        ),

                      for (final (i, tag) in _tags.indexed)
                        _Pop(
                          t: _span(tag.at, tag.at + 0.42, CalviMotion.easeRise),
                          x: side * tag.x,
                          y: side * tag.y,
                          child: _TagPill(name: tag.name(l), tint: tints[i]),
                        ),

                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: Opacity(
                          opacity: card,
                          child: Transform.translate(
                            offset: Offset(0, 14 * (1 - card)),
                            child: const _Result(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Скільки місця займе напис: щоб знати, чи влізе ряд без стискання.
double _width(String text, TextStyle? style) {
  final p = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  return p.width;
}

/// Кути один в один зі сканером: 30 px, 2.4 px білого, скруглення 12 px,
/// поле 14 від країв фото.
class _CornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const inset = 14.0;
    const arm = 30.0;
    const r = 12.0;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final left = inset;
    final top = inset;
    final right = size.width - inset;
    final bottom = size.height - inset;

    Path corner(double x, double y, double sx, double sy) => Path()
      ..moveTo(x, y + sy * arm)
      ..lineTo(x, y + sy * r)
      ..arcToPoint(Offset(x + sx * r, y), radius: const Radius.circular(r), clockwise: sx == sy)
      ..lineTo(x + sx * arm, y);

    canvas.drawPath(corner(left, top, 1, 1), paint);
    canvas.drawPath(corner(right, top, -1, 1), paint);
    canvas.drawPath(corner(left, bottom, 1, -1), paint);
    canvas.drawPath(corner(right, bottom, -1, -1), paint);
  }

  @override
  bool shouldRepaint(_CornersPainter old) => false;
}

/// Підпис, що виринає на своєму місці: 420 мс, з 0.8 до повного.
class _Pop extends StatelessWidget {
  const _Pop({required this.t, required this.x, required this.y, required this.child});

  final double t;
  final double x;
  final double y;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (t == 0) return const SizedBox.shrink();
    return Positioned(
      left: x,
      top: y,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Opacity(
          opacity: t,
          child: Transform.scale(scale: 0.8 + 0.2 * t, child: child),
        ),
      ),
    );
  }
}

/// Дрібна пігулка на склі з крапкою в тоні макросу і назвою. Світла в
/// будь-якій темі: стоїть на фото, а не на сторінці.
class _TagPill extends StatelessWidget {
  const _TagPill({required this.name, required this.tint});

  final String name;
  final Color tint;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(CalviSize.rPill),
      boxShadow: const [BoxShadow(color: Color(0x2E000000), blurRadius: 8, offset: Offset(0, 2))],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: tint,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: tint.withValues(alpha: 0.3), spreadRadius: 2)],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          name,
          style: context.t.titleMedium?.copyWith(
            fontSize: 11,
            height: 1,
            color: const Color(0xFF101012),
          ),
        ),
      ],
    ),
  );
}

/* Картка результату поверх фото, як картка страви в щоденнику: назва і
   калорії, під ними клітинки Б/Ж/В із чату, під ними тихий ряд нутрієнтів із
   дня і мітка Pro. Останній рядок і є товар: людина бачить його з числами тут,
   і без чисел на своєму дні, доки не оформить. Колір із теми: у темній темі
   картка темна, як і картки застосунку. */
class _Result extends StatelessWidget {
  const _Result();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);
    final marks = nutriMarks(context, nutrientGoals(2000));
    final cells = [
      (l.macroProteinLetter, _protein, c.protein),
      (l.macroFatLetter, _fat, c.fats),
      (l.macroCarbsLetter, _carbs, c.carbs),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x2E000000), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  l.payDish,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.t.titleMedium?.copyWith(fontSize: 15, letterSpacing: -0.3),
                ),
              ),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                  text: '$_kcal',
                  style: context.t.headlineMedium?.copyWith(fontSize: 19, letterSpacing: -0.4),
                  children: [
                    TextSpan(
                      text: ' ${l.unitKcal}',
                      style: context.t.labelSmall?.copyWith(
                        fontSize: CalviSize.fsMicro,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            l.payPortion,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.t.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final (i, cell) in cells.indexed)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                      decoration: BoxDecoration(
                        color: cell.$3.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${cell.$1} ${cell.$2} ${l.unitG}',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: context.t.titleMedium?.copyWith(
                          fontSize: CalviSize.fsMicro,
                          color: cell.$3,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: c.cardBorder),
          const SizedBox(height: 8),
          /* Пʼять знаків із числами і мітка Pro, розкидані по ширині, як у демці.
             На найменшому телефоні, де вони не влазять і впритул, ряд
             стискається, а не вилазить за картку. */
          LayoutBuilder(
            builder: (context, box) {
              final small = context.t.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w400,
              );
              final items = [
                for (final (i, m) in marks.indexed)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CalviIcon(m.icon, size: 13, color: m.tint),
                      const SizedBox(width: 4),
                      Text('${_nutri[i]} ${l.unitG}', style: small),
                    ],
                  ),
              ];
              final pill = Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: c.button,
                  borderRadius: BorderRadius.circular(CalviSize.rPill),
                ),
                child: Text(
                  l.planOn,
                  style: context.t.labelSmall?.copyWith(
                    fontSize: 10,
                    height: 1,
                    letterSpacing: 0.2,
                    color: c.buttonText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );

              var need =
                  _width(
                    l.planOn,
                    context.t.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w600),
                  ) +
                  14;
              for (final (i, _) in marks.indexed) {
                need += 13 + 4 + _width('${_nutri[i]} ${l.unitG}', small) + 8;
              }
              if (need <= box.maxWidth) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [...items, pill],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final (i, it) in items.indexed) ...[
                            if (i > 0) const SizedBox(width: 8),
                            it,
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  pill,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
