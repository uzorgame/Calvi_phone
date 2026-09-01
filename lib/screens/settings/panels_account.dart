import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/app_scope.dart';
import '../../data/billing/billing.dart';
import '../../data/local/database.dart' show TokenStateData;

import '../../data/legal.dart';
import '../../data/settings.dart';
import '../../design/icons.dart';
import '../../design/shell.dart';
import '../menu.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/labels.dart';
import 'panel_legal.dart';

typedef SetSettings = void Function(SettingsState Function(SettingsState));

/// How the app looks.
///
/// Three options rather than a switch. «Тема пристрою» is not a midpoint
/// between light and dark, it is a refusal to choose on the person's behalf, and
/// it has to stand in the row as its own decision instead of hiding in the
/// position of a toggle.
class ThemePanel extends StatelessWidget {
  const ThemePanel({super.key, required this.s, required this.set, this.onBack});

  final SettingsState s;
  final SetSettings set;

  /// How the panel closes. It lives inside settings, not on top of it, so the
  /// way out is settings putting its list back rather than a route popping.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return CalviScreen(
      trailing: const CalviMenuButton(),
      onBack: onBack,
      title: l.setTheme,
      foot: CalviButton(label: l.actionDone, onTap: () => (onBack ?? Navigator.of(context).pop)()),
      children: [
        CalviSection(
          title: l.themeSectionLook,
          bare: true,
          children: [
            for (final t in themeOptions)
              CalviPick(
                label: themeTitle(context, t.id),
                hint: themeHint(context, t.id),
                icon: t.icon,
                on: s.theme == t.id,
                onTap: () => set((v) => v.copyWith(theme: t.id)),
              ),
          ],
        ),
      ],
    );
  }
}

/// Interface language.
///
/// The choice exists, the translation does not, and the screen says so plainly
/// instead of switching silently and leaving everything in Ukrainian. A promise
/// the interface does not keep costs more than a missing button.
class LangPanel extends StatelessWidget {
  const LangPanel({super.key, required this.s, required this.set, this.onBack});

  final SettingsState s;
  final SetSettings set;

  /// How the panel closes. It lives inside settings, not on top of it, so the
  /// way out is settings putting its list back rather than a route popping.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return CalviScreen(
      trailing: const CalviMenuButton(),
      onBack: onBack,
      title: l.setLang,
      foot: CalviButton(label: l.actionDone, onTap: () => (onBack ?? Navigator.of(context).pop)()),
      children: [
        CalviSection(
          title: l.langSection,
          bare: true,
          children: [
            for (final option in langOptions)
              CalviPick(
                label: langTitle(context, option),
                on: s.lang == option,
                onTap: () => set((v) => v.copyWith(lang: option)),
              ),
          ],
        ),
      ],
    );
  }
}

/// Subscription. Paid through the stores and nowhere else.
class PlanPanel extends StatefulWidget {
  const PlanPanel({super.key, this.onBack, this.onSignIn});

  /// How the panel closes: settings puts its list back rather than a route
  /// popping, because the panel lives inside settings.
  final VoidCallback? onBack;

  /// Куди вести, коли людина без акаунта хоче купити: до профілю, де живе
  /// вхід. Порожньо означає «просто закрити панель».
  final VoidCallback? onSignIn;

  @override
  State<PlanPanel> createState() => _PlanPanelState();
}

/* Ціни приходять тільки з магазину.
 *
 * Своїх чисел тут немає жодного, і це принципово. Доти на випадок мовчання
 * магазину стояли базові 9,99 і 39,99, і саме вони все й зіпсували: базова
 * ціна це ціна американської вітрини, тобто заглушка виглядала точно так
 * само, як справжня відповідь Apple. Відрізнити «працює» від «не працює»
 * стало неможливо навіть із телефоном у руках.
 *
 * Тепер немає відповіді, немає й числа: на місці ціни стоїть риска, а поруч
 * написано, що саме сказав магазин. */
class _PlanPanelState extends State<PlanPanel> {
  String _plan = 'year';

  /* Чи знято лічильник. Єдине джерело це сервер, а тут його дзеркало: той
     самий потік, що й у шапки чату, і сторінка міняється тієї ж миті, коли
     сервер підтвердить покупку. Поки перша відповідь у дорозі (`syncedAt`
     порожній), тариф вважається безкоштовним: інакше екран мигнув би «Pro»
     тим, хто не платить. */
  StreamSubscription<TokenStateData?>? _watch;
  bool _has = false;

  /* Який саме тариф, за словом магазину: 'month', 'year' або 'on', коли
     підписка є, а строк невідомий. Сервер каже лише «лічильник знято» і не
     каже, з якої підписки; це знає магазин, і в нього питаємо тільки напис. */
  String? _kind;

  /* Що показати: порожньо це безкоштовний, далі вид тарифу. Доступ вирішує
     сервер, магазин лише уточнює назву; без його відповіді стоїть 'on'. */
  String get _pro => !_has ? '' : (_kind ?? 'on');

  /// Тарифи, як їх віддав магазин. Порожньо означає «ще не приїхали» або
  /// «магазин не підключений», і тоді на екрані стоять базові числа.
  List<StorePlan> _store = const [];

  /// Поки триває покупка або відновлення. Другий дотик по кнопці в цей час
  /// відкрив би друге вікно магазину поверх першого.
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _watch ??= AppScope.maybeOf(context)?.db?.syncDao.watchTokens().listen((t) {
      final has = t?.syncedAt != null && t?.unlimited == true;
      if (has == _has) return;
      setState(() {
        _has = has;
        if (!has) _kind = null;
      });
      if (has) unawaited(_loadKind());
    });
  }

  @override
  void dispose() {
    _watch?.cancel();
    super.dispose();
  }

  /// Чому цін немає. Показується на екрані замість них, людською мовою.
  BillingTrouble _trouble = BillingTrouble.quiet;

  Future<void> _load() async {
    final plans = await Billing.plans();
    if (!mounted) return;
    setState(() {
      _store = plans;
      _trouble = Billing.trouble;
    });
  }

  Future<void> _loadKind() async {
    final kind = await Billing.activeKind();
    if (!mounted) return;
    setState(() {
      _kind = kind;
      // Чинний тариф стає обраним: картка з «чинний» не має стояти без обведення.
      if (kind == 'month' || kind == 'year') _plan = kind!;
    });
  }

  /* Пошук за видом тарифу, а не за назвою товару: у кожній крамниці назва
     своя, а місяць і рік скрізь місяць і рік. */
  StorePlan? _found(String kind) {
    for (final p in _store) {
      if (p.kind == kind) return p;
    }
    return null;
  }

  /* Чи магазин узагалі відповів.
   *
   * Доти екран малював базову ціну, коли магазин мовчав, і це була помилка:
   * американські 9,99 і 39,99 виглядають точно так само, як справжня ціна
   * американської вітрини. Відрізнити «працює» від «не працює» стало
   * неможливо, і на цьому згоріла ціла година. Тепер немає відповіді, немає й
   * чисел. */
  bool get _live => _store.isNotEmpty;

  String? get _monthPrice => _found('month')?.display;
  String? get _yearPrice => _found('year')?.display;

  /* Місячна вартість річної підписки, як її рахує людина в голові.
   *
   * Валюта береться з рядка магазину, а не підставляється своя: у ньому вже
   * стоїть і символ, і місцевий формат, і вигадати їх удруге означало б
   * показати «$3.33» тому, хто платить у злотих. */
  String? get _perMonth {
    final y = _found('year');
    if (y == null) return null;
    final per = (y.amount / 12).toStringAsFixed(2);
    // Число в рядку магазину замінюється порахованим, решта лишається як є.
    return y.display.replaceAll(RegExp(r'[\d.,]+'), per);
  }

  /// Наскільки річна дешевша. Рахується з того, що прийшло, а не з наших чисел.
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

  /* Купити обраний тариф.
   *
   * Доступ після цього дає не телефон, а сервер: магазин підтвердить покупку
   * RevenueCat, той стукне на наш вебхук, і лічильник токенів зникне сам.
   * Тому тут немає жодного запису в базу, тільки вікно магазину. */
  Future<void> _buy() async {
    final l = L.of(context);
    if (!await _signedIn()) {
      if (mounted) await _askSignIn();
      return;
    }
    final plan = _found(_plan);

    /* Магазин не відповів. Вдати покупку нема на чому, і чесніше сказати про це,
       ніж мовчки закрити сторінку. */
    if (plan == null) {
      _say(l.planStoreQuiet);
      return;
    }

    setState(() => _busy = true);
    final result = await Billing.buy(plan);
    if (!mounted) return;

    switch (result) {
      case BuyResult.done:
        /* Доступ дає сервер, а телефон про це дізнається від нього. Черговий
           обмін іде за сорок пʼять секунд, і півхвилини з лічильником після
           оплати читались би як «не спрацювало». Тому питаємо сервер одразу, а
           той сам звіряється з магазином. Сторінка лишається відкритою: її
           зміна на «Pro» і є підтвердженням, яке людина бачить очима. */
        await _confirm();
      // Передумала, а не помилилась. Казати тут нічого не треба.
      case BuyResult.canceled:
        break;
      case BuyResult.failed:
        _say(l.planFailed);
    }
    if (mounted) setState(() => _busy = false);
  }

  /* Підписка привʼязується до облікового запису з поштою, і саме тому вхід
     іде перед оплатою, а не після. Покупка на безіменному акаунті пристрою
     живе рівно до першого входу в інший акаунт або до зміни телефона: чек у
     магазині один, а акаунтів у нас уже два, і зіставляти їх доведеться руками
     через підтримку. Простіше не створювати цю розвилку. */
  Future<bool> _signedIn() async {
    final db = AppScope.maybeOf(context)?.db;
    // Без бази це демо або тест: там нема кого просити увійти.
    if (db == null) return true;
    return (await db.syncDao.state()).email != null;
  }

  /// Аркуш «спочатку увійди»: гучна кнопка веде до профілю, тиха закриває.
  Future<void> _askSignIn() {
    final l = L.of(context);
    return calviSheet<void>(
      context,
      title: l.planSignInTitle,
      doneLabel: l.planSignInGo,
      cancelLabel: l.planLater,
      onDone: () => (widget.onSignIn ?? widget.onBack)?.call(),
      builder: (sheet) => Padding(
        padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 4, CalviSize.gutter, 12),
        child: Text(l.planSignInNote, style: sheet.t.bodyMedium),
      ),
    );
  }

  /* Спитати сервер про покупку.
   *
   * Жодного напису внизу: підтвердження це сама сторінка, яка перемикається на
   * «Pro» тієї ж миті, коли сервер відповість. Доти тут стояв снекбар «Готово»,
   * і він лише дублював те, що екран уже показує. Якщо сервер ще не в курсі або
   * не відповів, штовхаємо обмін: він привезе правду за хвилину. */
  Future<void> _confirm() async {
    final sync = AppScope.of(context).sync;
    final confirmed = await sync?.confirmPurchase();
    if (!mounted) return;
    unawaited(_loadKind());
    if (confirmed != true) unawaited(sync?.now() ?? Future<void>.value());
  }

  /* Скасування і зміна тарифу живуть у магазині, так вимагають правила обох.
     Якщо адреси немає, підписки в цього акаунта теж немає. */
  Future<void> _manage() async {
    final l = L.of(context);
    final url = await Billing.manageUrl();
    if (!mounted) return;
    if (url == null) {
      _say(l.planStoreQuiet);
      return;
    }
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  /* Відновити покупки. Обовʼязкове за правилами сторів: людина, яка змінила
     телефон, має повернути оплачене без звернень у підтримку. */
  Future<void> _restore() async {
    final l = L.of(context);
    // Відновлене теж має лягти на акаунт із поштою, а не на безіменний.
    if (!await _signedIn()) {
      if (mounted) await _askSignIn();
      return;
    }
    setState(() => _busy = true);
    final found = await Billing.restore();
    if (!mounted) return;
    /* Знайдене в магазині ще треба донести до сервера: при перенесенні на новий
       акаунт RevenueCat шле вебхук без строку, і без цього запиту доступ
       зʼявився б аж із наступним поновленням. */
    if (found) {
      await _confirm();
    } else {
      _say(l.planNothingToRestore);
    }
    if (mounted) setState(() => _busy = false);
  }

  /* Що сказати про поточний стан. Рядок про дату поновлення тут не стоїть, хоч
     у демці він є: сервер віддає застосунку тільки `unlimited`, а вигадана
     дата на екрані підписки гірша за її відсутність. */
  List<(String, String)> _now(L l) => switch (_pro) {
    '' => [(l.planPlan, l.planFree), (l.planTokens, l.planTokensFree)],
    'year' => [(l.planPlan, l.planYearly), (l.planTokens, l.planTokensPro)],
    'month' => [(l.planPlan, l.planMonthly), (l.planTokens, l.planTokensPro)],
    _ => [(l.planPlan, l.planOn), (l.planTokens, l.planTokensPro)],
  };

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final c = context.c;
    final has = _pro.isNotEmpty;

    return CalviScreen(
      trailing: const CalviMenuButton(),
      onBack: widget.onBack,
      title: l.planTitle,
      /* Куплене не продають удруге: скасування і зміна тарифу живуть у
         магазині, а не в застосунку, так вимагають правила обох сторів. */
      foot: CalviButton(
        label: has ? l.planManage : l.planBuy,
        busy: _busy,
        onTap: has ? _manage : _buy,
        second: has ? l.planClose : l.planLater,
        onSecond: () => (widget.onBack ?? Navigator.of(context).pop)(),
      ),
      children: [
        CalviSection(
          title: l.planNow,
          bare: true,
          trail: 0,
          children: [CalviFacts(inset: false, rows: _now(l))],
        ),

        /* Кожен рядок правда і перевіряється по коду: прапорець unlimited
           знімає лічильник, а він стоїть на розмовах, фото, розборі й
           підборі рецептів. Під кожною перевагою написано, скільки це коштує
           зараз, щоб людина бачила, за що платить, а не вірила на слово.

           Памʼять сформульована через ріст, а не через доступ: вона не
           заблокована тарифом, і те, що Нора вже знає, працює без токенів. А
           от вивчити нове вона може лише в розмові, і саме розмова коштує. */
        CalviSection(
          title: l.planPerks,
          bare: true,
          trail: 0,
          children: [
            _Perks(
              rows: [
                (l.planPerkChat, l.planPerkChatSub),
                (l.planPerkPhoto, l.planPerkPhotoSub),
                (l.planPerkWeek, l.planPerkWeekSub),
                (l.planPerkRecipes, l.planPerkRecipesSub),
                (l.planPerkMemory, l.planPerkMemorySub),
              ],
            ),
          ],
        ),

        CalviSection(
          title: has ? l.planTariffs : l.planPlan,
          bare: true,
          children: [
            Row(
              children: [
                Expanded(
                  child: _PlanCard(
                    name: l.planYear,
                    // Чинний тариф позначається спокійно, а не як знижка.
                    save: _pro == 'year'
                        ? l.planCurrent
                        : (_saving == null ? null : '-$_saving%'),
                    current: _pro == 'year',
                    price: _perMonth,
                    unit: _live ? l.planPerMonth : null,
                    note: _yearPrice == null ? null : l.planYearBilled(_yearPrice!),
                    on: _plan == 'year',
                    onTap: () => setState(() => _plan = 'year'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PlanCard(
                    name: l.planMonth,
                    save: _pro == 'month' ? l.planCurrent : null,
                    current: _pro == 'month',
                    price: _monthPrice,
                    unit: _live ? l.planPerMonth : null,
                    note: _live ? l.planMonthBilled : null,
                    on: _plan == 'month',
                    onTap: () => setState(() => _plan = 'month'),
                  ),
                ),
              ],
            ),

            /* Магазин мовчить. Кажемо це прямо і показуємо, що саме він
               відповів: без цього рядка «не працює» і «працює, просто ціна
               така» виглядають однаково. */
            if (!_live)
              Padding(
                padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 10, CalviSize.gutter, 0),
                child: Text(
                  /* Одне речення і жодного коду помилки. Текст `PlatformException`
                     тут не місце: людині він нічого не каже, а лякає. Повний
                     текст лишається в логах, для нас. */
                  _trouble == BillingTrouble.offline ? l.planStoreOffline : l.planStoreQuiet,
                  style: context.t.labelSmall?.copyWith(color: c.faint, height: 1.4),
                ),
              ),
          ],
        ),

        /* Обовʼязкове за правилами обох сторів: відновлення покупок, чесний
           рядок про автопоновлення і посилання на документи. Без цього
           застосунок не проходить рев'ю, а людина не знає, на що підписалась. */
        Padding(
          padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 4, CalviSize.gutter, 8),
          child: Column(
            children: [
              GestureDetector(
                onTap: _restore,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    l.planRestore,
                    style: context.t.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l.planRenewal,
                textAlign: TextAlign.center,
                style: context.t.labelSmall?.copyWith(color: c.faint, height: 1.4),
              ),
              const SizedBox(height: 8),
              /* Два посилання одним рядком, і саме одним: перенесене на другий
                 рядок юридичне посилання читається як помилка верстки. Назви
                 документів довгі й у деяких мовах ширші за телефон, тож рядок
                 стискається цілком, а не ламається. */
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  children: [
                    _Link(l.planTerms, () => legalSheet(context, terms)),
                    Text('  ·  ', style: context.t.labelSmall?.copyWith(color: c.faint)),
                    _Link(l.planPrivacy, () => legalSheet(context, privacy)),
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

/// Тихе підкреслене посилання на документ у хвості сторінки підписки.
class _Link extends StatelessWidget {
  const _Link(this.label, this.onTap);

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Text(
      label,
      style: context.t.labelSmall?.copyWith(
        color: context.c.textSecondary,
        decoration: TextDecoration.underline,
        decorationColor: context.c.textSecondary,
      ),
    ),
  );
}

/// Privacy.
class PrivacyPanel extends StatelessWidget {
  const PrivacyPanel({super.key, required this.s, required this.set, this.onBack});

  final SettingsState s;
  final SetSettings set;

  /// How the panel closes. It lives inside settings, not on top of it, so the
  /// way out is settings putting its list back rather than a route popping.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return CalviScreen(
      trailing: const CalviMenuButton(),
      onBack: onBack,
      title: l.privacyTitle,
      foot: CalviButton(label: l.actionDone, onTap: () => (onBack ?? Navigator.of(context).pop)()),
      children: [
        /* Три обіцянки трьома рядками, а не абзацом.
           Це головне, що людина хоче тут прочитати, і суцільний сірий текст
           вона пробігає очима, не читаючи жодної з них. */
        CalviSection(
          title: l.privacyNotCollected,
          bare: true,
          trail: 0,
          children: [
            _Guarantees(
              rows: [
                (l.privacyNoPhotosHead, l.privacyNoPhotosSub),
                (l.privacyDiaryHead, l.privacyDiarySub),
                (l.privacyHealthHead, l.privacyHealthSub),
              ],
            ),
          ],
        ),
        CalviSection(
          title: l.privacyOptional,
          children: [
            CalviRow(
              icon: 'chart',
              first: true,
              title: l.privacyStats,
              hint: l.privacyStatsHint,
              trailing: CalviSwitch(
                on: s.analytics,
                onChanged: (v) => set((x) => x.copyWith(analytics: v)),
              ),
            ),
            CalviRow(
              icon: 'shield',
              title: l.privacyCrash,
              hint: l.privacyCrashHint,
              trailing: CalviSwitch(
                on: s.crash,
                onChanged: (v) => set((x) => x.copyWith(crash: v)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Deleting the account.
class DeletePanel extends StatefulWidget {
  const DeletePanel({super.key, this.onBack});

  /// How the panel closes: settings puts its list back rather than a route
  /// popping, because the panel lives inside settings.
  final VoidCallback? onBack;

  @override
  State<DeletePanel> createState() => _DeletePanelState();
}

class _DeletePanelState extends State<DeletePanel> {
  bool _sure = false;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return CalviScreen(
      trailing: const CalviMenuButton(),
      onBack: widget.onBack,
      title: l.deleteTitle,
      hint: l.deleteNote,
      foot: CalviButton(
        label: l.deleteForever,
        enabled: _sure,
        danger: true,
        onTap: () => (widget.onBack ?? Navigator.of(context).pop)(),
        second: l.actionCancel,
        onSecond: () => (widget.onBack ?? Navigator.of(context).pop)(),
      ),
      children: [
        CalviSection(
          bare: true,
          trail: 0,
          children: [
            CalviFacts(
              inset: false,
              rows: [(l.deleteEntries, '412'), (l.deleteWeighings, '37'), (l.deleteDays, '94')],
            ),
          ],
        ),
        CalviCheck(
          on: _sure,
          onToggle: () => setState(() => _sure = !_sure),
          text: l.deleteConfirm,
        ),
        CalviNote(l.deleteSubNote, lead: 12),
      ],
    );
  }
}

/// Гарантії списком, зі значком щита перед кожною.
///
/// Щит, а не галочка: тут перелік не переваг, а того, чого ми не робимо, і
/// значок має говорити про захист, а не про виконаний пункт.
class _Guarantees extends StatelessWidget {
  const _Guarantees({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: c.cardBorder),
        borderRadius: BorderRadius.circular(CalviSize.rLarge),
        boxShadow: context.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, row) in rows.indexed) ...[
            if (i > 0) const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.fats.withValues(alpha: 0.16),
                  ),
                  child: CalviIcon('shield', size: 12, color: c.fats),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.$1,
                        style: context.t.bodyLarge?.copyWith(
                          fontSize: CalviSize.fsCaption,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(row.$2, style: context.t.labelSmall),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Переваги списком, кожна окремим «так».
class _Perks extends StatelessWidget {
  const _Perks({required this.rows});

  /// Перевага і те, скільки вона коштує зараз. Друге пояснює перше.
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: c.cardBorder),
        borderRadius: BorderRadius.circular(CalviSize.rLarge),
        boxShadow: context.shadowCard,
      ),
      child: Column(
        children: [
          for (final (i, row) in rows.indexed) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.success.withValues(alpha: 0.16),
                  ),
                  child: CalviIcon('check', size: 12, color: c.success),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.$1,
                        style: context.t.bodyLarge?.copyWith(fontSize: CalviSize.fsCaption),
                      ),
                      const SizedBox(height: 2),
                      Text(row.$2, style: context.t.labelSmall?.copyWith(height: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Один план карткою: назва, ціна великим числом, умова списання дрібним.
///
/// Обраний обведений чорнилом, як обрана мова: це вибір серед рівних, а не
/// кнопка дії, і фарбувати його чорним означало б зробити з нього кнопку.
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.name,
    required this.price,
    required this.note,
    required this.on,
    required this.onTap,
    this.save,
    this.unit,
    this.current = false,
  });

  final String name;

  /* Ціна від магазину. Порожньо означає, що магазин не відповів, і тоді на
     її місці стоїть риска: вигадане число тут виглядало б як справжня ціна. */
  final String? price;
  final String? note;
  final bool on;
  final VoidCallback onTap;

  /// Скільки економить річний, числом на чіпі. Порожньо в місячного.
  final String? save;

  /// Дрібне після ціни: «/міс». Ціна приходить зі стору вже з валютою, тому
  /// одиниця стоїть окремо, а не зшивається в рядок перекладу.
  final String? unit;

  /// Це чинний тариф. Чіп тоді не про знижку, а про стан, і фарбується тихо.
  final bool current;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return CalviPress(
      onTap: onTap,
      builder: (context, down) => AnimatedScale(
        scale: down ? 0.98 : 1,
        duration: CalviMotion.fast,
        curve: CalviMotion.ease,
        child: AnimatedContainer(
          duration: CalviMotion.fast,
          curve: CalviMotion.ease,
          padding: EdgeInsets.all(on ? 13 : 14),
          decoration: BoxDecoration(
            color: c.card,
            border: Border.all(color: on ? c.button : c.cardBorder, width: on ? 2 : 1),
            borderRadius: BorderRadius.circular(CalviSize.rCard),
            boxShadow: context.shadowCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* Назва і чіп знижки в один рядок, і саме тому обидва мусять
                 уміти стискатись: на вузькому телефоні з великим системним
                 шрифтом «Рік» і «-17%» разом не влазили в половину ширини, і
                 екран показував смугастий бар замість карток. */
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.t.bodyLarge?.copyWith(
                        fontSize: CalviSize.fsCaption,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (save != null) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                        /* Чинний тариф позначається тихо: це констатація, а не
                           вигода, і зелений чіп на ньому читався б як знижка,
                           якої немає. */
                        decoration: BoxDecoration(
                          color: current
                              ? c.fillSecondary
                              : c.success.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(CalviSize.rPill),
                        ),
                        child: Text(
                          save!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.t.labelSmall?.copyWith(
                            fontSize: 11,
                            color: current ? c.textSecondary : c.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              /* Ціна великим, одиниця дрібним поруч. Одиниця окремо, а не в
                 рядку ціни: сам рядок приходить зі стору вже з валютою, і
                 дописувати до нього щось у перекладі не можна. */
              Text.rich(
                TextSpan(
                  text: price ?? '···',
                  children: [
                    if (unit != null)
                      TextSpan(
                        text: unit,
                        style: context.t.labelSmall?.copyWith(fontSize: 12),
                      ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.t.headlineMedium?.copyWith(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              if (note != null)
                Text(note!, style: context.t.labelSmall?.copyWith(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
