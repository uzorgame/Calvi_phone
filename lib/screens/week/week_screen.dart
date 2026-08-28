import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../data/chat.dart';
import '../../data/local/chat_store.dart';
import '../../data/remote/api.dart';
import '../../data/settings.dart';
import '../../data/week.dart';
import '../../design/fold.dart';
import '../../design/icons.dart';
import '../../design/macro_row.dart';
import '../../design/section.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../format.dart';
import '../../l10n/app_localizations.dart';

/// Тижнева аналітика: окрема сторінка, вхід із третьої сторони картки дня.
///
/// **Не другий екран аналітики, а її молодша сестра.** Аналітика відповідає на
/// «як воно йшло» місяцями, ця сторінка про сім днів, які щойно минули. Тому
/// тут немає перемикача періоду: тиждень це тиждень.
///
/// Мова та сама, що в аналітики, буквально: [CalviStat], [CalviFigure] і ті
/// самі стовпчики. Це зумисне: людина вже вивчила цю мову на сусідній сторінці,
/// і друга мова тут була б другим інтерфейсом.
class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key, required this.summary, required this.onSettings, this.now});

  final WeekSummary summary;

  /// Та сама кнопка, що в шапці аналітики. Сторінка тижня це сторінка того ж
  /// роду, і виходити з неї в налаштування має так само.
  final VoidCallback onSettings;

  /// Годинник для тестів: стани сторінки залежать від дня тижня і години.
  final DateTime? now;

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  /* Розбори з сервера, найновіший перший. Порожньо, поки відповідь у дорозі:
     сторінка з числами живе і без неї, а «Минулі» доростуть, коли приїде. */
  List<WeekReviewData>? _reviews;
  bool _asked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_asked) return;
    _asked = true;

    final scope = AppScope.of(context);
    if (!scope.real || scope.sync == null) return;

    /* Тихо: сторінку відкривають заради чисел, і мережа їм не потрібна.
       Не приїхало, значить «Минулі» порожні, а розбір цього тижня, якщо він
       був, добудується кнопкою: повторний запит збереженого нічого не коштує. */
    unawaited(
      scope.sync!
          .weekReviews()
          .then((rows) {
            if (mounted) setState(() => _reviews = rows);
          })
          .catchError((_) {}),
    );
  }

  /// Розбір, збудований щойно, стає в чоло списку: «Минулі» і поточний блок
  /// читають один список, і другого джерела правди тут немає.
  void _keep(WeekReviewData fresh) {
    setState(() => _reviews = [fresh, ...?_reviews?.where((r) => r.week != fresh.week)]);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final w = widget.summary;
    final scope = AppScope.of(context);
    final week = reviewWeekKey(widget.now);

    /* Демо показує сторінку з усіма її можливостями, тому минулі там
       показові, а кнопка не замикається на будні: день відкриття демки не
       має вирішувати, що людина побачить. */
    final rows = scope.real
        ? (_reviews ?? const <WeekReviewData>[])
        : [
            WeekReviewData(
              week: _weekBefore(week, 1),
              body: '${l.wkNoraP1}\n\n${l.wkNoraP2}\n\n${l.wkNoraP3}',
            ),
            WeekReviewData(week: _weekBefore(week, 2), body: '${l.wkNoraP1}\n\n${l.wkNoraP3}'),
          ];

    final stored = rows.where((r) => r.week == week).firstOrNull;
    final past = [
      for (final r in rows)
        if (r.week != week) r,
    ];

    if (w.daysLogged == 0) {
      /* «Минулі» стоять і на порожньому тижні. Кожен новий тиждень починається
         порожнім, і без цього архів ставав би недосяжним рівно з понеділка,
         тобто саме тоді, коли туди переїхав свіжий розбір. */
      return CalviScreen(
        title: l.wkTitle,
        trailing: _Settings(onTap: widget.onSettings),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 40, CalviSize.gutter, 24),
            child: Text(
              l.wkEmpty,
              textAlign: TextAlign.center,
              style: context.t.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
          _pastSection(context, l, past),
        ],
      );
    }

    final off = w.offNorm;
    final total = w.byDay.fold<int>(0, (a, d) => a + d.kcal);
    final dw = w.weightChange;

    return CalviScreen(
      title: l.wkTitle,
      trailing: _Settings(onTap: widget.onSettings),
      children: [
        /* Розбір найпершим, над усіма числами: числа нижче це матеріал, а
           розбір це відповідь, і людина приходить сюди по відповідь. */
        _NoraBlock(
          key: ValueKey('nora-$week'),
          real: scope.real,
          stored: stored?.body,
          now: widget.now,
          onFresh: _keep,
        ),

        CalviStat(
          title: l.wkKcalHead,
          badge: l.wkOffNorm('${off > 0 ? '+' : '−'}${thousands(off.abs())}'),
          warn: off > 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CalviFigure(value: thousands(w.avgKcal), cap: l.wkPerDay),
                  const _Sep(),
                  CalviFigure(
                    value: '${w.daysOnGoal}',
                    suffix: ' / ${w.daysFinished}',
                    cap: l.wkDaysOk,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _DayBars(week: w, normLabel: l.wkNorm),
            ],
          ),
        ),

        /* БЖВ мовою карток дня: число з нормою через риску, кільце зі знаком,
           підпис капсом. Але одна картка на трьох, а не три окремі: це один
           факт «як тиждень годував», а не три лічильники. */
        CalviStat(
          title: l.wkMacroHead,
          aside: l.wkPerDayAside,
          child: Builder(
            builder: (context) {
              final g = goalOf(AppScope.of(context).s);
              return MacroRow(
                cells: [
                  (
                    label: l.macroProteinCaps,
                    icon: 'protein',
                    value: w.avgProtein,
                    goal: g.protein,
                    colour: context.c.protein,
                  ),
                  (
                    label: l.macroFatCaps,
                    icon: 'fat',
                    value: w.avgFat,
                    goal: g.fat,
                    colour: context.c.fats,
                  ),
                  (
                    label: l.macroCarbsCaps,
                    icon: 'carbs',
                    value: w.avgCarbs,
                    goal: g.carbs,
                    colour: context.c.carbs,
                  ),
                ],
              );
            },
          ),
        ),

        CalviStat(
          title: l.wkFactsHead,
          child: Column(
            children: [
              Row(
                children: [
                  _Fact(value: thousands(total), cap: l.wkTotalCap),
                  _Fact(value: l.wkLoggedValue(w.daysLogged), cap: l.wkLoggedCap),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _Fact(
                    value: l.wkWaterValue((w.avgWaterMl / 1000).toStringAsFixed(1)),
                    cap: l.wkWaterCap,
                  ),
                  _Fact(
                    // Прочерк там, де числа немає: коротка риска, не довга.
                    value: dw == null
                        ? '–'
                        : '${dw > 0 ? '+' : ''}${dw.toStringAsFixed(1)} ${l.heroKg.trim()}',
                    cap: dw == null ? l.wkNoWeight : l.wkWeightCap,
                  ),
                ],
              ),
            ],
          ),
        ),

        _pastSection(context, l, past),
      ],
    );
  }

  /* Минулі розбори, найнижче. Вбрання те саме, що в рядків налаштувань:
     значок, назва тижня, шеврон. Це архів, а не подія, і виглядати він має
     тихо. З понеділка сюди переїжджає розбір тижня, що минув, а розмова про
     нього лишається в минулому тижні. */
  Widget _pastSection(BuildContext context, L l, List<WeekReviewData> past) => CalviSection(
    title: l.wkPastTitle,
    children: [
      if (past.isEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Text(l.wkPastEmpty, style: context.t.bodyMedium?.copyWith(height: 1.5)),
        )
      else
        for (final (i, r) in past.indexed)
          CalviRow(
            icon: 'note',
            first: i == 0,
            title: l.wkPastRow(_dot(r.week)),
            onTap: () => _openPast(context, r),
          ),
    ],
  );

  /// «2026-08-24» у людське «24.08.2026».
  static String _dot(String week) {
    final p = week.split('-');
    return p.length == 3 ? '${p[2]}.${p[1]}.${p[0]}' : week;
  }

  /// Понеділок на N тижнів раніше за названий. Для показових минулих у демо.
  static String _weekBefore(String week, int n) {
    final d = DateTime.tryParse(week);
    if (d == null) return week;
    final m = DateTime(d.year, d.month, d.day - 7 * n);
    return '${m.year.toString().padLeft(4, '0')}-'
        '${m.month.toString().padLeft(2, '0')}-'
        '${m.day.toString().padLeft(2, '0')}';
  }

  /// Минулий розбір читається аркушем: це сторінка з текстом, а не діалог.
  void _openPast(BuildContext context, WeekReviewData r) {
    final l = L.of(context);
    calviSheet<void>(
      context,
      title: l.wkPastRow(_dot(r.week)),
      info: true,
      builder: (sheet) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: CalviSize.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final p in r.body.split('\n\n'))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(p, style: sheet.t.bodyMedium?.copyWith(height: 1.55)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Кнопка налаштувань у шапці, один в один як на аналітиці.
class _Settings extends StatelessWidget {
  const _Settings({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: context.c.fillSecondary),
      child: const CalviIcon('settings', size: 18),
    ),
  );
}

/// Розділова риска між парою чисел, як на аналітиці.
class _Sep extends StatelessWidget {
  const _Sep();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 46,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    color: context.c.cardBorder,
  );
}

/// Сім стовпчиків із рискою норми, на шасі води з аналітики.
class _DayBars extends StatelessWidget {
  const _DayBars({required this.week, required this.normLabel});

  final WeekSummary week;
  final String normLabel;

  static const _height = 86.0;

  /* Вхід, знятий із демки один в один: стовпчики виростають знизу за 620 мс
     тією самою пружною кривою cubic-bezier(0.22, 1, 0.36, 1). Сторінка, де
     графік уже стоїть готовим на першому кадрі, читається як таблиця, а не як
     сторінка, що ожила. */
  static const _grow = Duration(milliseconds: 620);
  static const _rise = Cubic(0.22, 1, 0.36, 1);

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    /* Шкала впирається у найвищий день, але не нижче за норму: тиждень
       суцільного недобору, намальований до стелі, виглядав би виконаним. */
    final top = week.byDay.fold<int>(week.normKcal, (a, d) => d.kcal > a ? d.kcal : a);
    final max = (top * 1.12).clamp(1, double.infinity);

    return Column(
      children: [
        SizedBox(
          height: _height,
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final d in week.byDay)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: _grow,
                          curve: _rise,
                          builder: (context, t, child) => FractionallySizedBox(
                            widthFactor: 1,
                            heightFactor: ((d.kcal / max).clamp(0.035, 1.0)) * t,
                            alignment: Alignment.bottomCenter,
                            child: child,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              /* Зелений день витриманий, бордовий ні, і це
                                 стосується обох боків: недоїсти на тисячу це
                                 теж не успіх худнення, а голодування.

                                 Тут стояв колір за одним лише перебором, і
                                 недобір фарбувався так само, як влучання: два
                                 різні дні виглядали однаково. Правило тепер те
                                 саме, що фарбує кружечки в стрічці дня.

                                 Сьогодні і дні без запису лишаються чорнилом
                                 упівсили: вердикту в них ще немає. */
                              color: !d.logged
                                  ? c.track
                                  : switch (d.ok) {
                                      true => c.success,
                                      false => c.protein,
                                      null => Color.lerp(c.track, c.button, 0.55)!,
                                    },
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: _height * (week.normKcal / max),
                child: Row(
                  children: [
                    Expanded(child: Container(height: 1, color: c.hairline)),
                    const SizedBox(width: 6),
                    Text(normLabel, style: context.t.labelSmall?.copyWith(fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final d in week.byDay)
              Expanded(
                child: Text(
                  d.label,
                  textAlign: TextAlign.center,
                  style: context.t.labelSmall?.copyWith(fontSize: 11),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Одне число з підписом у сітці «Разом за тиждень».
class _Fact extends StatelessWidget {
  const _Fact({required this.value, required this.cap});

  final String value;
  final String cap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, maxLines: 1, style: context.t.headlineLarge?.copyWith(fontSize: 21, height: 1)),
        const SizedBox(height: 4),
        Text(cap, style: context.t.labelSmall?.copyWith(fontWeight: FontWeight.w400)),
      ],
    ),
  );
}

/* Розмови про розбір, по тижнях. Поза станом сторінки навмисно: людина
   виходить зі сторінки і повертається, а розмова триває. З понеділка ключ
   тижня стає іншим, і стара розмова просто перестає читатись: лишається сам
   розбір у «Минулих», як і задумано. Перезапуск застосунку розмову не
   зберігає, і це свідомий компроміс: розбір сплачений і живе на сервері,
   розмова про нього ні. */
final _weekTalks = <String, List<({bool me, String text})>>{};

/// Кнопка «Аналітика від Нори» і все, на що вона перетворюється.
///
/// Стани, і кожен наступний росте з попереднього на місці, штовхаючи решту
/// сторінки вниз:
///
///   1. будні до вечора пʼятниці: прогрес-лінія «буде доступна в пʼятницю».
///      Тиждень ще набирається, і розбір двох сніданків нікому не потрібен;
///   2. з пʼятниці 18:00 до кінця неділі: кнопка з ціною у два токени;
///   3. та сама кнопка з завантаженням усередині, поки Нора вивчає тиждень;
///   4. картка розбору, і під текстом «Поговорити про це з Норою»: розмова
///      прямо тут, до кінця неділі. З понеділка розбір переїжджає в «Минулі».
///
/// Розбір говорить про їжу, а не про калорії: числа вже стоять картками нижче,
/// і переказувати їх словами означало б бути калькулятором із обличчям.
class _NoraBlock extends StatefulWidget {
  const _NoraBlock({
    super.key,
    required this.real,
    required this.stored,
    required this.now,
    required this.onFresh,
  });

  /// Демо не кличе модель і не замикається на будні: воно показує сторінку.
  final bool real;

  /// Розбір цього тижня, якщо він уже збудований. Тоді кнопки немає зовсім.
  final String? stored;

  /// Годинник для тестів.
  final DateTime? now;

  /// Щойно збудований розбір: сторінка кладе його в свій список.
  final ValueChanged<WeekReviewData> onFresh;

  @override
  State<_NoraBlock> createState() => _NoraBlockState();
}

enum _Phase { idle, loading, open }

class _NoraBlockState extends State<_NoraBlock> {
  _Phase _phase = _Phase.idle;

  /// Текст розбору: збережений або збудований щойно.
  String? _body;

  /* Чи картка розбору розгорнута. Щойно збудований розбір відкривається сам,
     бо його ще не читали; збережений зустрічає кожен вхід згорнутим, як рядок
     «Минулих»: сторінку відкривають заради чисел, а розбір уже читали. */
  bool _open = true;

  bool _chat = false;
  bool _thinking = false;
  int _replyAt = 0;

  final _draft = TextEditingController();
  Timer? _timer;

  /// Розмова демки: показова, вмирає разом із блоком.
  final _demoMsgs = <({bool me, String text})>[];

  /// Розмова цього тижня. У режимі «мої» спільна зі сторінкою, яку закрили й
  /// відкрили; у демо своя щоразу, бо демо це вітрина, а не щоденник.
  List<({bool me, String text})> get _msgs =>
      widget.real ? _weekTalks.putIfAbsent(reviewWeekKey(widget.now), () => []) : _demoMsgs;

  @override
  void initState() {
    super.initState();
    _body = widget.stored;
    if (_body != null) {
      _phase = _Phase.open;
      _open = false;
    }
    if (_msgs.isNotEmpty) _chat = true;
  }

  @override
  void didUpdateWidget(_NoraBlock old) {
    super.didUpdateWidget(old);
    /* Список розборів приїжджає з сервера пізніше за перший кадр сторінки:
       збережена картка має зʼявитись, щойно про неї стало відомо, але
       згорнутою: розбір уже читали. */
    if (_body == null && widget.stored != null) {
      _body = widget.stored;
      _phase = _Phase.open;
      _open = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _draft.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() => _phase = _Phase.loading);

    /* Демо тримає витриману паузу і показовий текст: моделі в демо немає,
       а миттєвий «розбір» читався б як несправжній. */
    if (!widget.real) {
      _timer = Timer(const Duration(milliseconds: 2300), () {
        if (!mounted) return;
        final l = L.of(context);
        setState(() {
          _body = '${l.wkNoraP1}\n\n${l.wkNoraP2}\n\n${l.wkNoraP3}';
          _phase = _Phase.open;
          _open = true;
        });
      });
      return;
    }

    final scope = AppScope.of(context);
    final sync = scope.sync;
    final messenger = ScaffoldMessenger.of(context);
    final l = L.of(context);
    if (sync == null) {
      setState(() => _phase = _Phase.idle);
      return;
    }

    try {
      final review = await sync.weekReview();
      if (!mounted) return;
      widget.onFresh(review);
      setState(() {
        _body = review.body;
        _phase = _Phase.open;
        // Щойно збудований розгортається сам: його ще не читали.
        _open = true;
      });
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() => _phase = _Phase.idle);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l.wkNoraFailed(switch (e.code) {
              'offline' => l.wkNoraNoNet,
              'slow' => l.wkNoraSlow,
              'no_tokens' => l.wkNoraNoTokens,
              _ => e.code,
            }),
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _phase = _Phase.idle);
    }
  }

  Future<void> _send() async {
    final text = _draft.text.trim();
    if (text.isEmpty || _thinking) return;
    setState(() {
      _draft.clear();
      _msgs.add((me: true, text: text));
      _thinking = true;
    });

    if (!widget.real) {
      _timer = Timer(const Duration(milliseconds: 1100), () {
        if (!mounted) return;
        final l = L.of(context);
        final canned = [l.wkNoraReply1, l.wkNoraReply2][_replyAt % 2];
        setState(() {
          _replyAt++;
          _thinking = false;
          _msgs.add((me: false, text: canned));
        });
      });
      return;
    }

    /* Питання йде тим самим чатом, що й усе сказане Норі, і лягає в ту саму
       розмову: Нора одна, з однією памʼяттю. Історія береться зі спільного
       сховища розмови, а бриф тижня і повний розбір докладає сервер сам за
       міткою place: тут їх не треба ні обрізати, ні возити проводом. */
    final scope = AppScope.of(context);
    final sync = scope.sync;
    final db = scope.db;
    final l = L.of(context);
    if (sync == null) return;

    /* Історія до свого повідомлення, а збереження після: інакше питання
       поїхало б моделі двічі, і в історії, і самим текстом. */
    final talk = db == null ? null : ChatStore(db);
    final shared = talk == null ? const <Msg>[] : await talk.load();
    final tail = shared.length > 3 ? shared.sublist(shared.length - 3) : shared;
    unawaited(talk?.save(msg(from: MsgFrom.me, text: text)) ?? Future<void>.value());

    try {
      final answer = await sync.ask(
        text: text,
        slot: 'snack',
        place: 'week',
        history: [
          for (final m in tail)
            if (m.text.trim().isNotEmpty)
              {
                'role': m.from == MsgFrom.me ? 'user' : 'model',
                'text': m.text.length > 900 ? m.text.substring(0, 900) : m.text,
              },
        ],
      );
      if (!mounted) return;
      final said = answer.text.isEmpty ? l.todayDone : answer.text;
      unawaited(talk?.save(msg(from: MsgFrom.nora, text: said)) ?? Future<void>.value());
      setState(() {
        _thinking = false;
        _msgs.add((me: false, text: said));
      });
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _thinking = false;
        _msgs.add((
          me: false,
          text: switch (e.code) {
            'offline' => l.todayOfflineSaved,
            'slow' => l.todayNoraSlow,
            'no_tokens' => l.todayOutOfTokens,
            _ => l.todayFailedRetry,
          },
        ));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _thinking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);

    /* Замок живе тільки в режимі «мої» і тільки поки розбору ще немає:
       збудований у пʼятницю розбір читається всю суботу й неділю. */
    final locked = widget.real && _phase != _Phase.open && !reviewOpen(widget.now);

    return Padding(
      padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 12, CalviSize.gutter, 0),
      /* Росте до природної висоти сама: у Flutter це вміє AnimatedSize, і
         підпирати її виміряними числами не треба. */
      child: AnimatedSize(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutQuart,
        alignment: Alignment.topCenter,
        child: _phase == _Phase.open
            ? _card(context)
            : locked
            ? _lockedLine(context, c, l)
            : _cta(context, c, l),
      ),
    );
  }

  /* Прогрес-лінія замість кнопки в будні: тиждень набирається, і з ним
     набирається те, про що буде розбір. Тиха заливка, а не чорна кнопка:
     натискати тут нема чого. */
  Widget _lockedLine(BuildContext context, CalviColors c, L l) {
    final run = reviewProgress(widget.now);

    return Container(
      key: const Key('wk-locked'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
      decoration: BoxDecoration(
        color: c.fillSecondary,
        borderRadius: BorderRadius.circular(CalviSize.rLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.wkNoraLocked, style: context.t.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(CalviSize.rPill),
            child: SizedBox(
              height: 5,
              width: double.infinity,
              child: Stack(
                children: [
                  ColoredBox(color: c.track, child: const SizedBox.expand()),
                  FractionallySizedBox(
                    widthFactor: run.clamp(0.02, 1.0),
                    child: ColoredBox(color: c.button, child: const SizedBox.expand()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* Запрошення до розбору: та сама біла картка, в якій він потім житиме.
     Заголовок і рядок обіцянки кажуть, що саме купується, кнопка лише
     погоджується: гола темна пігулка на пів екрана казала «плати», не
     сказавши за що. */
  Widget _cta(BuildContext context, CalviColors c, L l) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
    decoration: BoxDecoration(
      color: c.card,
      border: Border.all(color: c.cardBorder),
      borderRadius: BorderRadius.circular(CalviSize.rLarge),
      boxShadow: context.shadowCard,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.wkNoraTitle.toUpperCase(),
          style: context.t.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: CalviSize.fsMicro * 0.04,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l.wkNoraPromise,
          style: context.t.bodyMedium?.copyWith(color: c.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: _phase == _Phase.idle ? _start : null,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.button,
              borderRadius: BorderRadius.circular(CalviSize.rCard),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_phase == _Phase.loading) ...[
                  // Кільце очікування всередині кнопки: людина бачить, що працює
                  // саме те, що вона натиснула, а не десь щось.
                  SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: c.buttonText,
                      backgroundColor: c.buttonText.withValues(alpha: 0.28),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                /* Гнучкий, бо напис очікування довший за назву кнопки, а
                   системний шрифт уміє додати до нього ще третину. */
                Flexible(
                  child: Text(
                    _phase == _Phase.loading ? l.wkNoraLoading : l.wkNoraBtn,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.t.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: c.buttonText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  /* Готовий розбір живе згортуваною карткою.
   *
   * Розбір читають раз, а сторінку відкривають усі вихідні: розгорнутий назавжди
   * текст на пів екрана відсував би числа тижня щоразу. Тому кожен вхід на
   * сторінку починається зі згорнутої картки (як рядок «Минулих»), і лише
   * щойно збудований розбір розгортається сам: його ще не читали.
   *
   * Рух той самий, що в карток дня ([CalviFold]), стрілка та сама, що в рядків
   * налаштувань: праворуч коли згорнуто, донизу коли розгорнуто. */
  Widget _card(BuildContext context) {
    final c = context.c;
    final l = L.of(context);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: c.cardBorder),
        borderRadius: BorderRadius.circular(CalviSize.rLarge),
        boxShadow: context.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l.wkNoraTitle.toUpperCase(),
                      style: context.t.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: CalviSize.fsMicro * 0.04,
                      ),
                    ),
                  ),
                  /* Праворуч коли згорнуто, донизу коли відкрито: стрілка
                     показує, куди розгорнеться тіло, як у рядків налаштувань,
                     а не куди поїде дотик. */
                  AnimatedRotation(
                    turns: _open ? 0.25 : 0,
                    duration: CalviMotion.normal,
                    curve: CalviMotion.ease,
                    child: CalviIcon('chevron', size: 16, color: c.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          CalviFold(open: _open, child: _cardBody(context, c, l)),
        ],
      ),
    );
  }

  Widget _cardBody(BuildContext context, CalviColors c, L l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Абзаци, як їх написала Нора: порожній рядок ділить, заголовків немає.
          for (final p in (_body ?? '').split('\n\n'))
            if (p.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  p.trim(),
                  style: context.t.bodyMedium?.copyWith(color: c.text, height: 1.55),
                ),
              ),
          const SizedBox(height: 4),
          if (!_chat)
            GestureDetector(
              onTap: () => setState(() {
                _chat = true;
                _msgs.add((me: false, text: l.wkNoraGreet));
              }),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  // Тихіша за головну: розбір уже є, це наступний крок, а не
                  // єдиний.
                  color: c.fillSecondary,
                  borderRadius: BorderRadius.circular(CalviSize.rCard),
                ),
                child: Text(
                  l.wkNoraTalk,
                  style: context.t.bodyMedium?.copyWith(color: c.text, fontWeight: FontWeight.w600),
                ),
              ),
            )
          else
            _chatBody(context, c, l),
        ],
      ),
    );
  }

  Widget _chatBody(BuildContext context, CalviColors c, L l) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Container(height: 1, color: c.cardBorder),
      for (final m in _msgs)
        Align(
          alignment: m.me ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.62),
            decoration: BoxDecoration(
              color: m.me ? c.button : c.fillSecondary,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(CalviSize.rCard),
                topRight: const Radius.circular(CalviSize.rCard),
                bottomLeft: Radius.circular(m.me ? CalviSize.rCard : 6),
                bottomRight: Radius.circular(m.me ? 6 : CalviSize.rCard),
              ),
            ),
            child: Text(
              m.text,
              style: context.t.bodyMedium?.copyWith(
                color: m.me ? c.buttonText : c.text,
                height: 1.45,
              ),
            ),
          ),
        ),
      if (_thinking)
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: c.fillSecondary,
              borderRadius: BorderRadius.circular(CalviSize.rCard),
            ),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: c.text,
                backgroundColor: c.text.withValues(alpha: 0.16),
              ),
            ),
          ),
        ),
      Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: TextField(
                  controller: _draft,
                  onSubmitted: (_) => _send(),
                  textInputAction: TextInputAction.send,
                  style: context.t.bodyMedium?.copyWith(color: c.text),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: l.wkNoraPlaceholder,
                    hintStyle: context.t.bodyMedium?.copyWith(color: c.faint),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: c.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(CalviSize.rPill),
                      borderSide: BorderSide(color: c.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(CalviSize.rPill),
                      borderSide: BorderSide(color: c.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(CalviSize.rPill),
                      borderSide: BorderSide(color: c.text),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: c.button),
                // Той самий знак, що на кнопці надсилання в нижній смузі.
                child: CalviIcon('send', size: 18, color: c.buttonText),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
