import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../data/meds.dart';
import '../../data/repeat.dart';
import '../../design/icons.dart';
import '../../design/ring.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../today/slot_card.dart';
import 'meds_form.dart';
import '../../l10n/app_localizations.dart';
import '../../data/day.dart';

/// Medication journal, laid out as the day itself.
///
/// A flat list answers «what do I take»; the question people actually open this
/// screen with is «what do I take next». So the doses sit on a rail running from
/// morning to night, the taken part of the rail is solid behind them, the rest
/// is dashed ahead, and the current hour cuts across it. Everything is the same
/// information a list would carry, arranged so the answer is the shape.
///
/// It records and reminds. It does not calculate doses, propose regimens or
/// comment on one: we are not doctors, and here a wrong number is not a wrong
/// number, it is harm.
class MedsScreen extends StatefulWidget {
  const MedsScreen({
    super.key,
    required this.meds,
    required this.onToggle,
    required this.onSave,
    required this.onFinish,
    required this.onRevive,
  });

  final List<Med> meds;
  /* Доза називається годиною, а не номером у списку.
   *
   * Номер працював, поки список годин був цілим. Тепер день бере з нього тільки
   * свої дози, і третя за списком година може стояти в дні першою: за номером
   * галочка лягла б на чужий прийом. Година це те саме, чим доза записана в
   * базі, тож і питати треба нею. */
  final void Function(String medId, String at) onToggle;
  final ValueChanged<Med> onSave;

  /// Закінчити курс: препарат переїжджає в «Минулі», історія лишається.
  final ValueChanged<String> onFinish;

  /// Повернути закінчений курс в активні. Потрібне рівно для промаху.
  final ValueChanged<String> onRevive;

  @override
  State<MedsScreen> createState() => _MedsScreenState();
}

class _MedsScreenState extends State<MedsScreen> {
  /* Чи розгорнутий список курсів. Згорнуто, як і минулі: рейка вище вже назвала
     все, що приймають сьогодні, а сюди заходять правити назву чи години. */
  bool _showMine = false;

  /// Чи розгорнуті минулі курси. Згорнуто за замовчуванням: це довідка.
  bool _showPast = false;

  /* Година пристрою. Саме вона ділить рейку на те, що вже минуло, і те, що
     попереду, тож зашите тут число робило неправильним не підпис, а весь екран.
     Перемальовується на межі хвилини, а не раз на секунду: поки цифра та сама,
     рахувати нема чого. */
  late String _now = hhmm(DateTime.now());
  Timer? _beat;

  /* Курс, який починається не сьогодні, сказаний уголос.
   *
   * Людина заводить о 14:00 ліки на 09:00, зберігає і бачить день без них. Без
   * цього рядка єдиний висновок, який вона може зробити, це що застосунок не
   * зберіг препарат. */
  String? _hint;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void dispose() {
    _beat?.cancel();
    super.dispose();
  }

  void _schedule() {
    final at = DateTime.now();
    /* До початку наступної хвилини, плюс півсекунди на дрейф таймера: без запасу
       він інколи прокидається за мить до межі, і хвилина стоїть на місці. */
    _beat = Timer(Duration(milliseconds: 60500 - at.second * 1000 - at.millisecond), () {
      setState(() => _now = hhmm(DateTime.now()));
      _schedule();
    });
  }

  /* Збереження проходить через екран, а не повз нього: тільки тут видно, чи
     дістався курс сьогоднішнього дня, і тільки звідси можна про це сказати. */
  void _save(Med m) {
    widget.onSave(m);
    final ahead = firstDoseAhead(m, DateTime.now());
    setState(() {
      _hint = ahead == null ? null : _firstDose(m, ahead.day, ahead.at);
    });
  }

  /// «Магній B6, перший прийом завтра о 09:00».
  String _firstDose(Med m, DateTime day, String at) {
    final l = L.of(context);
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final word = dayKeyOf(day) == dayKeyOf(tomorrow)
        ? l.medsTomorrow
        : '${day.day} ${monthShort(day.month)}';
    return l.medsFirstDose(m.name, word, at);
  }

  /* Стану форми тут більше немає: вона живе в аркуші, який сам знає, що
     редагує. Раніше цей рядок вирішував, який блок розгорнути в списку. */

  /* Тут два різні питання, і плутати їх не можна.
   *
   * [_live] це «які курси я взагалі веду», [_today] це «що з них пити сьогодні».
   * Обидва списки колись були одним, порахованим через [medsOn], і через це курс
   * «по понеділках», заведений у середу, зникав з екрана цілком: у середу він не
   * приймається, тож у список не потрапляв, а закінченим не був, тож і в
   * «Минулих» його не було. Людина заводила препарат і бачила «Тут порожньо». */
  List<Med> get _live => medsAhead(widget.meds);

  /// Дози, які припадають саме на сьогодні.
  List<Med> get _today => medsOn(_live, DateTime.now());

  /// Закінчені курси: рівно доповнення до [_live].
  List<Med> get _past => [
    for (final m in widget.meds)
      if (!m.stillRunning()) m,
  ];

  /* Закінчений курс: що це було і коли.
   *
   * Читається, не редагується. Редагувати курс, який уже не приймається, нема
   * навіщо, а от подивитись, що саме людина пила в березні, буває треба, і саме
   * заради цього препарат не видаляється. Єдина дія тут це повернення, і воно
   * потрібне рівно для промаху по кнопці. */
  void _openPast(Med m) {
    calviSheet<void>(
      context,
      title: m.name,
      doneLabel: L.of(context).actionClose,
      /* Відновити курс стоїть у ряду з виходом, а не блідою кнопкою всередині
         тексту: промах по «Закінчити курс» має відкочуватись там, де людина
         шукає кнопки, тобто внизу. */
      cancelLabel: L.of(context).medsResume,
      onCancel: () => widget.onRevive(m.id),
      builder: (sheetContext) {
        final c = sheetContext.c;
        final t = sheetContext.t;

        Widget line(String label, String value) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: t.bodyLarge?.copyWith(color: c.textSecondary)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(value, textAlign: TextAlign.right, style: t.bodyLarge),
              ),
            ],
          ),
        );

        return Padding(
          padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 4, CalviSize.gutter, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              line(L.of(sheetContext).medsDose, doseLabel(m.dose, m.form)),
              line(L.of(sheetContext).medsHours, m.times.map((x) => x.at).join(', ')),
              line(L.of(sheetContext).medsSchedule, repeatLabel(m.repeat)),
              line(L.of(sheetContext).medsCourse, _span(m)),
              if (m.note?.trim().isNotEmpty ?? false)
                line(L.of(sheetContext).medsNote, m.note!.trim()),
            ],
          ),
        );
      },
    );
  }

  List<({String at, List<({Med med, bool taken})> items})> get _groups {
    final map = <String, List<({Med med, bool taken})>>{};
    for (final m in _today) {
      for (final t in m.times) {
        map.putIfAbsent(t.at, () => []).add((med: m, taken: t.taken));
      }
    }
    final keys = map.keys.toList()..sort();
    return [for (final k in keys) (at: k, items: map[k]!)];
  }

  @override
  Widget build(BuildContext context) {
    /* Активні й закінчені окремо.
     *
     * Курс, який людина припинила, зникав із застосунку разом з історією: дні,
     * коли вона його справді приймала, ставали такими, ніби вона його не пила
     * ніколи. Тепер він переїжджає в «Минулі» і лишається там назавжди. */
    final c = context.c;
    final l = L.of(context);
    final meds = _live;
    final past = _past;
    // Смуга годин і кільце говорять про сьогодні, список нижче про весь курс.
    final today = _today;
    final total = medProgress(today);
    final due = nextDue(today, _now);
    final late = unmarked(today, _now);
    final groups = _groups;
    final nowAt = groups.indexWhere((g) => g.at.compareTo(_now) > 0);

    return CalviScreen(
      title: l.medsTitle,
      /* Додати препарат стоїть у шапці, навпроти «Назад», щойно список перестає
         бути порожнім. Рядком під списком ця кнопка з кожним новим курсом
         відходила далі вниз, а дія над списком не має мандрувати. Поки
         препаратів немає, вона лишається рядком під карткою Нори: на порожньому
         екрані вона єдина річ, заради якої на нього зайшли, і ховати її в кут
         сорока пікселями було б знущанням. */
      trailing: meds.isEmpty
          ? null
          : CalviAdd(
              label: l.medsAdd,
              onTap: () => openMedSheet(
                context,
                now: DateTime.now().millisecondsSinceEpoch,
                onSave: _save,
              ),
            ),
      children: [
        if (_hint != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 16),
            child: CalviNora(text: _hint!),
          ),

        if (meds.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              CalviSize.gutter,
              0,
              CalviSize.gutter,
              CalviSize.gapSection,
            ),
            child: CalviNora(text: l.medsEmpty, hint: l.medsEmptyHint),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 22),
            child: TweenAnimationBuilder<double>(
              // 17.2: it arrives once, from a little above, over 520 ms.
              tween: Tween(end: 1),
              duration: const Duration(milliseconds: 520),
              curve: CalviMotion.ease,
              builder: (context, t, child) => Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, -10 * (1 - t)),
                  child: Transform.scale(scale: 0.985 + 0.015 * t, child: child),
                ),
              ),
              child: Container(
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                decoration: BoxDecoration(
                  /* The one dark card of the day, in button ink on both themes:
                     the regimen summary is the headline, not another tile. */
                  color: c.button,
                  borderRadius: BorderRadius.circular(CalviSize.rLarge),
                  // Темна картка на світлому ґрунті плаває найвище: їй і тінь
                  // найглибша з трьох.
                  boxShadow: context.shadowPop,
                ),
                child: Stack(
                  children: [
                    // Warm light off the corner the ring sits in.
                    /* Painted with a shader rather than boxed in a decoration:
                       the web renderer showed the box of a decorated gradient,
                       and a canvas circle has no box to show. */
                    Positioned.fill(
                      child: CustomPaint(painter: _Glow(colour: c.accent)),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  text: '${total.done}',
                                  children: [
                                    TextSpan(
                                      text: ' / ${total.total}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                        color: c.buttonText.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                                style: context.t.displayLarge?.copyWith(
                                  fontSize: 38,
                                  height: 1,
                                  color: c.buttonText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text.rich(
                                /* Порожній день, день попереду, день позаду і
                                 * закритий день це чотири різні речі.
                                 *
                                 * «Все прийнято» на курсі «по понеділках» у
                                 * середу читалось би як похвала за те, чого
                                 * людина не робила, а під чотирма
                                 * непозначеними дозами о пів на дванадцяту
                                 * ночі це була б просто неправда. */
                                total.total == 0
                                    ? TextSpan(text: l.medsNoneToday)
                                    : due != null
                                    ? TextSpan(
                                        text: l.medsNextAt,
                                        children: [
                                          TextSpan(
                                            text: due.at,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: c.buttonText,
                                            ),
                                          ),
                                          TextSpan(text: ', ${due.name}'),
                                        ],
                                      )
                                    : late > 0
                                    ? TextSpan(
                                        text: l.medsUnmarked,
                                        children: [
                                          TextSpan(
                                            text: '$late',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: c.buttonText,
                                            ),
                                          ),
                                        ],
                                      )
                                    : TextSpan(text: l.medsAllTaken),
                                style: context.t.bodyMedium?.copyWith(
                                  fontSize: CalviSize.fsMicro,
                                  color: c.buttonText.withValues(alpha: 0.62),
                                ),
                              ),
                            ],
                          ),
                        ),
                        CalviRing(
                          progress: total.ratio,
                          size: 68,
                          stroke: 7,
                          color: total.ratio >= 1 ? c.success : c.accent,
                          // The track has to read on the dark card, so it is the
                          // card's own ink at low strength, not the page grey.
                          track: c.buttonText.withValues(alpha: 0.18),
                          child: CalviIcon(
                            total.ratio >= 1 ? 'check' : 'pill',
                            size: 22,
                            color: total.ratio >= 1 ? c.success : c.accent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          for (final (gi, g) in groups.indexed) ...[
            if (gi == nowAt) RepaintBoundary(child: _NowLine(now: _now)),
            _Arrive(
              rank: gi,
              child: _RailRow(
                at: g.at,
                items: g.items,
                last: gi == groups.length - 1,
                passed: g.at.compareTo(_now) <= 0,
                onToggle: widget.onToggle,
              ),
            ),
          ],

          /* Мітка стоїть перед першою годиною, яка ще попереду, а коли попереду
             вже нічого, то під усім днем: інакше ввечері вона зникала цілком, і
             екран переставав казати, котра година, саме тоді, коли пропущену
             дозу видно найкраще. */
          if (nowAt < 0 && groups.isNotEmpty) RepaintBoundary(child: _NowLine(now: _now)),

          /* Рейка відповідає, що далі; це відповідає, що взагалі в списку, і це
             єдине місце, де назву можна виправити, а курс закінчити.
             Заголовок і список тут та сама пара, що в минулих курсах: рядок
             картки, лічильник і стрілка. Розділ стояв підписом над великою
             карткою, і поруч із охайним рядком «Минулі» читався як недороблений. */
          if (meds.isNotEmpty) ...[
            _Group(
              title: l.medsMine,
              count: meds.length,
              open: _showMine,
              onTap: () => setState(() => _showMine = !_showMine),
              child: Column(
                children: [
                  for (final (i, m) in meds.indexed)
                    CalviRow(
                      icon: 'pill',
                      title: m.name,
                      first: i == 0,
                      value:
                          /* Розклад поруч із годинами: «08:00» щодня і «08:00»
                           через день це два різні курси. Щоденне не
                           підписується: воно і так найчастіше, і підпис до
                           кожного рядка перетворився б на шум. */
                          '${doseLabel(m.dose, m.form)} · ${m.times.map((t) => t.at).join(', ')}'
                          '${m.repeat is DailyRepeat ? '' : ' · ${repeatLabel(m.repeat)}'}',
                      onTap: () => openMedSheet(
                        context,
                        med: m,
                        now: DateTime.now().millisecondsSinceEpoch,
                        onSave: _save,
                        onFinish: widget.onFinish,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: CalviSize.gapSection),
          ],
        ],

        /* Порожній екран: кнопка стоїть рядком одразу під карткою Нори, бо тут
           вона єдина дія на екрані. Щойно зʼявляється перший курс, вона
           переїжджає в шапку. */
        if (meds.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CalviSize.gutter),
            child: AddRow(
              label: l.medsAdd,
              open: false,
              onTap: () => openMedSheet(
                context,
                now: DateTime.now().millisecondsSinceEpoch,
                onSave: _save,
              ),
            ),
          ),

        /* Минулі курси.
         *
         * Закінчений курс зникав із застосунку разом з історією, і дні, коли
         * людина його справді приймала, ставали такими, ніби вона його не пила
         * ніколи. Тепер він лишається тут: що приймали, скільки, з якого дня по
         * який. Згорнуто за замовчуванням, бо це довідка, а не щоденна робота.
         *
         * Розділ стоїть навіть порожній. Ховати його, поки минулих курсів немає,
         * здавалось охайним, а на ділі людина, яка шукає історію, не знаходила
         * навіть натяку на те, що історія десь є. */
        const SizedBox(height: CalviSize.gapCard),
        _Group(
          title: l.medsPast,
          count: past.length,
          open: _showPast,
          onTap: () => setState(() => _showPast = !_showPast),
          child: past.isEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
                  child: Text(
                    l.medsPastEmpty,
                    style: context.t.labelSmall?.copyWith(
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (final (i, m) in past.indexed)
                      CalviRow(
                        icon: 'pill',
                        title: m.name,
                        first: i == 0,
                        value: '${doseLabel(m.dose, m.form)} · ${_span(m)}',
                        onTap: () => _openPast(m),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  /// «12 серп – 19 серп» або «з 12 серп», якщо кінця ще немає.
  String _span(Med m) {
    String short(String key) {
      final p = key.split('-');
      if (p.length != 3) return key;
      final mm = (int.tryParse(p[1]) ?? 1).clamp(1, 12);
      return '${int.tryParse(p[2]) ?? p[2]} ${monthShort(mm)}';
    }

    final l = L.of(context);
    if (m.startDay.isEmpty) return m.endDay == null ? '' : l.medsUntil(short(m.endDay!));
    if (m.endDay == null) return l.medsSince(short(m.startDay));
    return '${short(m.startDay)} – ${short(m.endDay!)}';
  }
}

/// Група курсів: заголовок і список однією карткою.
///
/// Заголовок і список стояли двома окремими таблетками з проміжком, і звʼязок
/// між ними доводилось добудовувати в голові: стрілка вниз указувала на щось, що
/// виглядало сусідом, а не вмістом. Зрощення двох таблеток вимагало б міняти їм
/// заокруглення назустріч одна одній, а скільки не підбирай моменту такої заміни,
/// вона лишається заміною: кути стрибають з рівних на круглі.
///
/// Тому картка тут одна від початку. Тло, рамку, заокруглення й тінь тримає
/// сама група, а всередині свого не малює ніхто. Заокруглення не міняється
/// взагалі: міняється тільки висота, і низ із тими самими двадцятьма чотирма
/// їде вгору разом із нею. Обрізає теж вона, по цих же круглих кутах, тож
/// обрізати квадратом уже нема чому.
class _Group extends StatefulWidget {
  const _Group({
    required this.title,
    required this.count,
    required this.open,
    required this.onTap,
    required this.child,
  });

  final String title;
  final int count;
  final bool open;
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_Group> createState() => _GroupState();
}

class _GroupState extends State<_Group> with SingleTickerProviderStateMixin {
  /* Розгортається повільно й мʼяко, згортається швидко й рівно, як картки дня.
   *
   * Розділ, що закривається так само ліниво, як відкривався, читається так, ніби
   * застосунок над цим думає. Тому дві різні тривалості і дві різні криві, і
   * саме тому тут лічильник у мілісекундах, а не одна крива на весь хід: вміст
   * піднімається на такт пізніше за висоту і встигає ще трохи після неї.
   *
   * Розгортання триває 480, хоч висота доїжджає за 440: останні сорок це
   * дотягування вмісту, коли картка вже стоїть на повний зріст. */
  static const _openMs = 480.0;
  static const _shutMs = 220.0;

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
    reverseDuration: const Duration(milliseconds: 220),
    value: widget.open ? 1 : 0,
  );

  @override
  void didUpdateWidget(_Group old) {
    super.didUpdateWidget(old);
    if (widget.open != old.open) {
      widget.open ? _c.forward() : _c.reverse();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CalviSize.gutter),
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          border: Border.all(color: c.cardBorder),
          borderRadius: BorderRadius.circular(CalviSize.rLarge),
          boxShadow: context.shadowCard,
        ),
        clipBehavior: Clip.antiAlias,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            final opening = widget.open;
            // Скільки минуло від початку саме цього ходу, у мілісекундах.
            final ms = opening ? _c.value * _openMs : (1 - _c.value) * _shutMs;

            double leg(double from, double to, Curve curve) =>
                curve.transform(((ms - from) / (to - from)).clamp(0.0, 1.0));

            final t = opening
                ? leg(0, 440, CalviMotion.easeRise)
                : 1 - leg(0, _shutMs, CalviMotion.easeIn);
            final fade = opening ? leg(90, 350, Curves.linear) : 1 - leg(0, 140, Curves.linear);
            final lift = opening
                ? leg(60, _openMs, CalviMotion.easeRise)
                : 1 - leg(0, 180, CalviMotion.easeIn);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    /* Лінія розділу зʼявляється разом зі списком і згасає разом
                       із ним. Знята ривком, вона лишалась висіти під заголовком,
                       поки список іще їхав угору. Прозора рамка замість знятої
                       тримає висоту незмінною, тож заголовок не сіпається на
                       піксель туди-сюди. */
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: c.cardBorder.withValues(alpha: opening ? 1 : t),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          widget.title,
                          style: context.t.titleMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 15 * -0.02,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: c.fillSecondary,
                            borderRadius: BorderRadius.circular(CalviSize.rPill),
                          ),
                          child: Text(
                            '${widget.count}',
                            style: context.t.labelSmall?.copyWith(fontWeight: FontWeight.w400),
                          ),
                        ),
                        const Spacer(),
                        /* Чверть оберта: закрита стрілка дивиться вправо, як усі
                           стрілки рядків, розкрита вниз. Півоберта робила б із
                           неї вказівку вліво, тобто «назад».
                           Крутиться своїм ходом, а не разом із висотою: у картках
                           дня стрілка теж має власні 240 мс, і привʼязана до
                           складання вона поверталася б то за 440, то за 220. */
                        AnimatedRotation(
                          turns: widget.open ? 0.25 : 0,
                          duration: CalviMotion.normal,
                          curve: CalviMotion.ease,
                          child: CalviIcon('chevron', size: 16, color: c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                /* Висота дробом від власної висоти списку, а не числом: рядків
                   може бути один, а може десять, і будь-яка стеля або обрізала б
                   довгий список, або лишала б короткому порожній хід.
                   Згорнутого списку в дереві немає взагалі: невидимий рядок усе
                   одно лишається рядком для пошуку і для читалки з екрана, тобто
                   закінчений курс знаходився б серед активних. */
                if (_c.value > 0)
                  ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: t,
                      /* Вміст піднімається на такт пізніше за висоту, тож розділ
                         розгортається, а не просто стає вищим. */
                      child: Opacity(
                        opacity: fade,
                        child: Transform.translate(
                          offset: Offset(0, -10 * (1 - lift)),
                          child: child,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// Where the current hour cuts across the rail.
class _NowLine extends StatefulWidget {
  const _NowLine({required this.now});

  /// Година пристрою. Приходить згори, бо ділить вона не тільки цей рядок.
  final String now;

  @override
  State<_NowLine> createState() => _NowLineState();
}

class _NowLineState extends State<_NowLine> with SingleTickerProviderStateMixin {
  /* 16.25: a 2.4 second cycle. The marker is the only thing on the screen that
     moves on its own, which is what makes it read as the current hour rather
     than as another line. */
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 4, CalviSize.gutter, 12),
        child: Row(
          children: [
            /* Ті самі 46 і 26, у яких стоять години й вузли рейки. Тут було 44 і
               24 з проміжками по десять, тобто інша сітка, і крапка «зараз»
               лягала на сім пікселів праворуч від самої рейки. */
            SizedBox(
              width: 46,
              child: Text(
                L.of(context).medsNow,
                style: context.t.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: c.accent,
                ),
              ),
            ),
            SizedBox(
              width: 26,
              child: Center(
                /* One slow pulse, and only here. The current hour is the only
                   thing on this screen that moves on its own, so it needs no
                   more than that to be found. Fading the whole line instead made
                   the row look like it was loading. */
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.accent,
                    boxShadow: [
                      BoxShadow(
                        color: c.accent.withValues(
                          alpha: 0.55 * (1 - Curves.easeOut.transform(_pulse.value)),
                        ),
                        spreadRadius: 7 * Curves.easeOut.transform(_pulse.value),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Text(
              widget.now,
              style: context.t.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: c.accent,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: CustomPaint(
                size: const Size(double.infinity, 1),
                painter: _Dashes(colour: c.accent.withValues(alpha: 0.55)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RailRow extends StatelessWidget {
  const _RailRow({
    required this.at,
    required this.items,
    required this.last,
    required this.passed,
    required this.onToggle,
  });

  final String at;
  final List<({Med med, bool taken})> items;
  final bool last;

  /// The hour is behind the clock: anything untaken here is late, not upcoming.
  final bool passed;
  final void Function(String, String) onToggle;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final done = items.every((it) => it.taken);
    final late = !done && passed;

    return Padding(
      padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 46,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  at,
                  style: context.t.titleMedium?.copyWith(
                    fontSize: 14,
                    color: late ? c.protein : c.text,
                  ),
                ),
              ),
            ),

            // The rail: solid behind, hairline ahead.
            SizedBox(
              width: 26,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? c.success : c.card,
                      border: Border.all(color: done ? c.success : c.hairline, width: 2),
                    ),
                    child: done ? CalviIcon('check', size: 10, color: c.card) : null,
                  ),
                  /* Solid behind, dashed ahead. The rail is the day: what has
                     happened is a line, what has not is a plan. */
                  if (!last)
                    Expanded(
                      child: CustomPaint(
                        size: const Size(2, double.infinity),
                        painter: _RailLine(colour: done ? c.success : c.hairline, dashed: !done),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    for (final it in items)
                      _Dose(
                        med: it.med,
                        taken: it.taken,
                        onTap: () => onToggle(it.med.id, at),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dose extends StatelessWidget {
  const _Dose({required this.med, required this.taken, required this.onTap});

  final Med med;
  final bool taken;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: CalviMotion.fast,
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: taken ? c.success.withValues(alpha: 0.05) : c.card,
          border: Border.all(color: taken ? c.success.withValues(alpha: 0.32) : c.cardBorder),
          boxShadow: context.shadowCard,
          borderRadius: BorderRadius.circular(CalviSize.rCard),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med.name,
                    style: context.t.titleMedium?.copyWith(
                      fontSize: CalviSize.fsCaption,
                      letterSpacing: CalviSize.fsCaption * -0.02,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(doseLabel(med.dose, med.form), style: context.t.labelSmall),
                  if (med.note != null) ...[
                    const SizedBox(height: 2),
                    Text(med.note!, style: context.t.labelSmall?.copyWith(fontSize: 11)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            _Tick(taken: taken),
          ],
        ),
      ),
    );
  }
}

/// The rail between two hours.
/// The dashed run to the right of the now mark.
class _Dashes extends CustomPainter {
  _Dashes({required this.colour});

  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colour
      ..strokeWidth = 1;
    final y = size.height / 2;
    for (var x = 0.0; x < size.width; x += 6) {
      canvas.drawLine(Offset(x, y), Offset(math.min(x + 3, size.width), y), paint);
    }
  }

  @override
  bool shouldRepaint(_Dashes old) => old.colour != colour;
}

class _RailLine extends CustomPainter {
  _RailLine({required this.colour, required this.dashed});

  final Color colour;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colour
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final x = size.width / 2;

    if (!dashed) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      return;
    }
    for (var y = 0.0; y < size.height; y += 8) {
      canvas.drawLine(Offset(x, y), Offset(x, (y + 4).clamp(0, size.height)), paint);
    }
  }

  @override
  bool shouldRepaint(_RailLine old) => old.colour != colour || old.dashed != dashed;
}

/// The mark on a dose that has been taken.
///
/// It overshoots to 1.14 on the way in and settles back: a tick that simply
/// appears reads as the state having always been that way, and the one thing
/// worth feeling here is that you just did it.
class _Tick extends StatefulWidget {
  const _Tick({required this.taken});

  final bool taken;

  @override
  State<_Tick> createState() => _TickState();
}

class _TickState extends State<_Tick> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
    value: widget.taken ? 1 : 0,
  );

  @override
  void didUpdateWidget(_Tick old) {
    super.didUpdateWidget(old);
    // Only the arrival is worth an overshoot; untaking is a correction.
    if (widget.taken && !old.taken) {
      _c.forward(from: 0);
    } else if (!widget.taken && old.taken) {
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final at = CalviMotion.ease.transform(_c.value);
        // Up to 1.14 by two thirds of the way, back to 1 by the end.
        final scale = at < 0.66 ? 1 + 0.14 * (at / 0.66) : 1.14 - 0.14 * ((at - 0.66) / 0.34);
        return Transform.scale(
          scale: widget.taken ? scale : 1,
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.taken ? c.success : c.fillSecondary,
            ),
            child: CalviIcon(
              widget.taken ? 'check' : 'plus',
              size: 14,
              color: widget.taken ? c.card : c.textSecondary,
            ),
          ),
        );
      },
    );
  }
}

/// 16.24: a row of the rail arriving, 420 ms and 70 ms after the one above it.
///
/// The rail is read top to bottom, so it assembles top to bottom: all at once
/// would be a list appearing, and what is wanted is a day being laid out.
class _Arrive extends StatelessWidget {
  const _Arrive({required this.rank, required this.child});

  final int rank;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const step = 70;
    const run = 420;
    final total = run + step * rank;

    return TweenAnimationBuilder<double>(
      tween: Tween(end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(step * rank / total, 1, curve: CalviMotion.ease),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}

/// Warm light off the corner the ring sits in.
class _Glow extends CustomPainter {
  _Glow({required this.colour});

  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width + 40 - 90, -60 + 90);
    canvas.drawCircle(
      centre,
      90,
      Paint()
        ..shader = ui.Gradient.radial(centre, 90, [
          colour.withValues(alpha: 0.34),
          colour.withValues(alpha: 0),
        ]),
    );
  }

  @override
  bool shouldRepaint(_Glow old) => old.colour != colour;
}
