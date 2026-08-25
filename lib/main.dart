import 'dart:async';
import 'package:flutter/material.dart';

import 'data/evening.dart';
import 'data/local/database.dart';
import 'data/remote/sync_service.dart';
import 'data/meds.dart';
import 'data/settings.dart';
import 'data/app_scope.dart';
import 'data/day_stats.dart';
import 'data/local/day_reader.dart';
import 'data/local/meds_store.dart';
import 'data/notifications.dart';
import 'data/local/profile_store.dart';
import 'design/slide.dart';
import 'l10n/app_localizations.dart';
import 'design/theme.dart';
import 'data/measure.dart';
import 'screens/analytics/analytics_screen.dart';
import 'screens/camera/camera_screen.dart';
import 'screens/voice/level_source.dart';
import 'screens/voice/voice_overlay.dart';
import 'screens/meds/meds_route.dart';
import 'screens/settings/panel_allergy.dart';
import 'screens/settings/panel_assistant.dart';
import 'screens/settings/panel_reminders.dart';
import 'screens/settings/panels_account.dart';
import 'screens/settings/panels_body.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/start/hello.dart';
import 'screens/start/start_screen.dart';
import 'screens/today/today_screen.dart';
import 'data/meal.dart';
import 'l10n/data_lang.dart';

void main() => runApp(const CalviApp());

class CalviApp extends StatefulWidget {
  const CalviApp({super.key, this.storage = true, this.hello = true});

  /// Off in tests that are about a screen rather than about data: opening the
  /// database and starting a sync leaves timers running in a widget test, and a
  /// test of the theme has no business talking to a server.
  final bool storage;

  /// Заставка «Стіл» при запуску.
  ///
  /// Вимикається в тестах, які дивляться на екран під нею: дві секунди
  /// непрозорого шару, що ковтає дотики, це рівно те, що тесту про кнопку
  /// заважає, і рівно те, чого людина при запуску хоче.
  final bool hello;

  @override
  State<CalviApp> createState() => _CalviAppState();
}

class _CalviAppState extends State<CalviApp> {
  /* Settings and medications live above every screen, not inside the screens
     that edit them: the goal and the weight set in settings are read by the home
     card, and state that dies on the way out would leave that card showing
     figures nobody has any more. */
  /* Демонстраційна людина, доки не прочитано справжню. У демо-режимі вона ж і
     лишається: вітрина показує заповнений застосунок, а не порожній. */
  SettingsState _s = initialSettings();

  /// Профіль на диску. Зʼявляється разом із базою, тобто на першому справжньому
  /// запуску.
  ProfileStore? _profiles;

  /// Препарати на диску. Доти список жив тільки в памʼяті екрана і зникав
  /// разом із застосунком, а на сервер не потрапляв ніколи.
  MedsStore? _meds_;

  /* Сповіщення. Один на застосунок: розклад переплановується цілком, і два
     планувальники, які не знають один про одного, лишили б по собі привидів
     старих годин. */
  final _bell = Notifications();

  /* Ключ навігатора, щоб відкрити екран у відповідь на сповіщення.
   *
   * Дотик приходить не з дерева віджетів, а ззовні, і контексту в нього немає.
   * Ключ це єдиний спосіб дістатись до навігатора звідти. */
  final _nav = GlobalKey<NavigatorState>();

  /// Чи дозволила система показувати сповіщення. Питається один раз на запуск.
  bool _bellOk = false;
  /* Empty on purpose, same as the demo: the fourth card on the home row is
     earned by adding a regimen, not granted by a fixture. */
  List<Med> _meds = const [];

  /* The first run is a state of the app, not a route: it has no back door and
     nothing behind it to return to, so it replaces the home rather than sitting
     on top of it. It ends by folding what it collected into the settings, which
     is the whole point of asking.
   *
   * Порожньо означає «ще не знаємо»: сховище відповідає не тієї ж миті, а за
   * кілька кадрів. Показати за цей час «Старт» означало б блимнути онбордингом
   * в обличчя людині, яка проходила його місяць тому, тому доки відповіді
   * немає, на екрані не показується ніщо. */
  bool? _onboarding;

  /* The phone's own database, opened once and only when it is first needed. An
     app that never leaves the demo never touches the file, and a screen that
     mounts in a test never opens one at all. */
  CalviDb? _db;

  /* Which day the screens read: what is actually stored, or the demo. Real is
     the default now: the demo is a thing to look at, not a thing to start in.
     The switch stays on the home screen, because it is used while looking at
     the home screen. */
  bool _real = true;

  /// Carries local changes to the server and brings back what other devices
  /// wrote. Started with the database, which is to say on the first real use.
  SyncService? _sync;

  /* Підсумки днів для стрічки тижня і аналітики. У демо це фікстури, у режимі
     «мої» це те, що справді записано, і воно оновлюється саме, бо йде потоком. */
  DayStats _stats = DayStats.demo();
  StreamSubscription<DayStats>? _statsFeed;

  @override
  void dispose() {
    _statsFeed?.cancel();
    _saveLater?.cancel();
    _sync?.stop();
    _db?.close();
    super.dispose();
  }

  /// Switching to «мої» is what opens the database, and the first switch is the
  /// first time this phone writes anything of its own.
  void _setReal(bool real) => setState(() {
    if (real && widget.storage) unawaited(_open());
    _real = real;
    // Назад у демо: підсумки теж мають бути демонстраційні, інакше на екрані
    // опиниться половина одного тижня і половина іншого.
    if (!real) {
      _statsFeed?.cancel();
      _statsFeed = null;
      _stats = DayStats.demo();
    } else {
      _follow(_db);
    }
  });

  /* Opens the database once, and starts the sync that follows it.
   *
   * Спершу одне порожнє звертання до бази, і аж тоді все інше.
   *
   * `CalviDb()` не відкриває нічого: файл відкривається на першому ж запиті, і
   * невдача випливає геть в іншому місці. Доти вона не випливала взагалі:
   * профіль, препарати, підсумки й синхронізація йшли до бази кожен своєю
   * дорогою, кожен без `catch`, і кожен лишав по собі необроблений виняток. На
   * екрані при цьому був порожній день, тобто найстрашніше з можливих
   * повідомлень, сказане тим, що не сказано нічого.
   *
   * Причин рівно три: зіпсований файл бази, телефон без місця, і браузер без
   * `sqlite3.wasm`. Останнє й показало решту: у зібраному під web застосунку
   * сторінка крутила той самий виняток без кінця.
   *
   * **Після проби обовʼязково `setState`.** Поля читає `AppScope`, а він
   * збирається в `build`, і виставити їх після `await` без перебудови означає
   * лишити дерево з `sync: null`. Найкоротший шлях до цього це перемикач «Демо
   * → Мої»: він кличе `_open()` уже всередині `setState`, тобто перебудова
   * відбувається раніше, ніж зʼявляється те, заради чого її робили, і картка
   * акаунта показує застосунок, у якому входу не існує. */
  Future<void> _open() async {
    if (_db != null) return;
    final db = CalviDb();

    try {
      await db.syncDao.state();
    } catch (_) {
      unawaited(db.close().catchError((_) {}));
      if (!mounted) return;
      // Не вийшло, значить лишаємось на показовому дні і кажемо про це вголос:
      // демо це не «твої записи», але це принаймні чесно.
      setState(() => _onboarding = false);
      _say(dataL.storageBroken);
      return;
    }

    if (!mounted) {
      unawaited(db.close().catchError((_) {}));
      return;
    }

    setState(() {
      _db = db;
      _sync = SyncService(db)..start();
      _profiles = ProfileStore(db);
      _meds_ = MedsStore(db);
    });

    /* Дотик по сповіщенню препаратів веде в препарати, а не на головну.
     *
     * Людина торкнулась «Магній B6, 2 таблетки» саме для того, щоб поставити
     * галочку. Висадити її на головному екрані означає змусити шукати дорогу до
     * того, за чим вона прийшла. */
    unawaited(
      _bell.granted().then((ok) {
        if (mounted) _bellOk = ok;
      }),
    );
    _bell.onTap = _openFrom;
    unawaited(
      _bell.launchedFrom().then((from) {
        if (from != null) _openFrom(from);
      }),
    );
    _follow(db);
    unawaited(_loadProfile());
    unawaited(_loadMeds());
  }

  /// Читає збережений профіль і вирішує, чи це перший запуск.
  ///
  /// Саме тут закінчується онбординг, який раніше починався щоразу: питання
  /// «чи проходили ми це» має ставитись диску, а не полю в памʼяті, яке вмирає
  /// разом із застосунком.
  Future<void> _loadProfile() async {
    final saved = await _profiles?.load();
    if (!mounted) return;
    setState(() {
      if (saved != null) _s = saved;
      _onboarding = saved == null;
    });
    _replan();
  }

  /// Кінець «Старту»: те, що зібрали, стає профілем і одразу лягає на диск.
  void _finishStart(StartDraft draft) {
    final next = draft.applyTo(emptySettings());
    setState(() {
      _s = next;
      _onboarding = false;
    });
    /* І одразу на сервер. Раніше профіль лежав на телефоні до наступного
       запису в щоденник: людина проходила «Старт», закривала застосунок, і на
       сервері про неї не було нічого. */
    unawaited(_profiles?.save(next).then((_) => _sync?.now()));
  }

  /// Слухає підсумки днів зі сховища. Порожні, поки перша відповідь не прийшла.
  /* Чи сховище вже підвело. Один раз на запуск, бо і сказати про це треба один
     раз: повідомлення, яке повторюється на кожній спробі, це не повідомлення. */
  bool _storageBroken = false;

  void _follow(CalviDb? db) {
    _statsFeed?.cancel();
    if (db == null) return;

    _stats = DayStats.empty;
    _statsFeed = DayReader(db).watchStats().listen(
      (next) {
        if (mounted) setState(() => _stats = next);
      },
      /* База не відкрилась.
       *
       * Доти помилка йшла в нікуди: підписка вмирала мовчки, підсумки лишались
       * порожніми назавжди, і людина бачила день без жодного запису. Тобто
       * найстрашніше з можливих повідомлень, «твої дані зникли», сказане тим,
       * що не сказано нічого.
       *
       * Причин рівно дві, і жодна не наша: зіпсований файл бази і телефон, на
       * якому не лишилось місця. У браузері до цього додається третя, відсутній
       * `sqlite3.wasm`, і саме на ній це й знайшлось: сторінка крутила той самий
       * необроблений виняток без кінця.
       *
       * Тепер спроба одна, і про невдачу кажуть уголос. */
      onError: (Object _) {
        _statsFeed?.cancel();
        _statsFeed = null;
        if (_storageBroken) return;
        _storageBroken = true;
        _say(dataL.storageBroken);
      },
    );
  }

  /* Пише не одразу, а трохи згодом.
   *
   * Налаштування міняються не по одному натисканню: лінійка ваги і колесо віку
   * шлють нове значення на кожен кадр перетягування. Запис на кожен із них це
   * сотні транзакцій за один жест і сотні брудних рядків у чергу на сервер.
   * Півсекунди тиші означає, що людина відпустила. */
  Timer? _saveLater;

  void _set(SettingsState Function(SettingsState) patch) {
    final had = _s.reminders;
    setState(() => _s = patch(_s));

    /* Нагадування переставляються одразу, а дозвіл питається на першому з них.
     *
     * Не при встановленні: питати наперед означає питати до того, як людина
     * зрозуміла, навіщо це їй. Тут вона щойно завела нагадування власноруч, і
     * питання читається як частина тієї ж дії. */
    if (!identical(had, _s.reminders)) {
      unawaited(
        _guard(
          wants: _s.reminders.any((r) => r.on),
          off: () => _set(
            (v) => v.copyWith(reminders: [for (final r in v.reminders) r.copyWith(on: false)]),
          ),
        ),
      );
    }

    // У демо міняють вітрину, а не свій профіль: писати це на диск не можна.
    if (!_real || _onboarding != false) return;

    final snapshot = _s;
    _saveLater?.cancel();
    _saveLater = Timer(
      const Duration(milliseconds: 500),
      () => unawaited(_profiles?.save(snapshot).then((_) => _sync?.now())),
    );
  }

  /* День, за який зараз показані галочки прийому.
   *
   * Потрібен, бо «прийняв» це властивість дня, а не препарату: та сама таблетка
   * о восьмій вчора і сьогодні це дві різні позначки. */
  /* Береться щоразу заново, а не запамʼятовується при запуску.
   *
   * Тут стояло поле, ініціалізоване `DateTime.now()` один раз. Телефон,
   * залишений увімкненим через північ, писав ранкову таблетку у вчорашній день:
   * екран уже показував нову дату, а галочка лягала в стару. */
  DateTime? _medsDayPin;
  DateTime get _medsDay => _medsDayPin ?? DateTime.now();

  /// Читає препарати з диска. Порожньо, поки людина не завела жодного.
  Future<void> _loadMeds({DateTime? on}) async {
    if (on != null) _medsDayPin = on;
    final saved = await _meds_?.load(on: _medsDay);
    if (!mounted || saved == null) return;
    setState(() => _meds = saved);
    _replan();
  }

  /* Кожна зміна списку одразу лягає на диск і стає в чергу на сервер.
   *
   * Порівнюється те, що було, з тим, що стало: екран віддає весь список, а не
   * говорить, що саме змінилось. Дешевше порівняти два коротких списки, ніж
   * провести через увесь застосунок ще один тип події. */
  void _setMeds(List<Med> Function(List<Med>) patch) {
    final was = _meds;

    /* Курс без початку це курс «від завжди», і в минулих днях він виглядає так,
       ніби людина пила його все життя. Тут єдине місце, через яке проходять усі
       зміни списку, тому запобіжник стоїть саме тут. */
    final today = dayKeyOf(DateTime.now());
    final now = [
      for (final m in patch(was))
        if (m.startDay.isEmpty) m.copyWith(startDay: today) else m,
    ];
    setState(() => _meds = now);

    final store = _meds_;
    if (store == null) return;

    Future<void> write() async {
      for (final m in now) {
        final before = was.where((x) => x.id == m.id).firstOrNull;
        if (before == null || !_sameMed(before, m)) await store.save(m);

        /* Галочки прийому це окремі рядки, і міняються вони найчастіше: саме на
           них людина тисне щодня. */
        for (final t in m.times) {
          final had = before?.times.where((x) => x.at == t.at).firstOrNull;
          if (had == null || had.taken != t.taken) {
            await store.setTaken(medId: m.id, at: t.at, taken: t.taken, on: _medsDay);
          }
        }
      }

      /* Зниклий зі списку препарат означає «курс закінчено», а не «його не
         було». Дні, коли людина його справді приймала, лишаються в щоденнику:
         інакше історія переписується заднім числом. */
      for (final gone in was.where((m) => now.every((x) => x.id != m.id))) {
        await store.stop(gone.id);
      }
    }

    unawaited(write().then((_) => _sync?.now()));

    /* Дозвіл питається і тут теж.
     *
     * Раніше він питався тільки при першому нагадуванні, а препарати йшли цією
     * дорогою і не питали нічого. Людина заводила препарат, перемикач ставав
     * «увімкнено», системного дозволу не було, і сповіщення лягало в порожнечу.
     * Дізнатись про це можна було тільки з пропущеного прийому. */
    unawaited(
      _guard(
        wants: now.any((m) => m.remind),
        off: () => _setMeds(
          (list) => [
            for (final m in list)
              if (m.remind)
                Med(
                  id: m.id,
                  name: m.name,
                  dose: m.dose,
                  form: m.form,
                  remind: false,
                  repeat: m.repeat,
                  times: m.times,
                  note: m.note,
                )
              else
                m,
          ],
        ),
      ),
    );
  }

  /* Перемикач не має брехати.
   *
   * Увімкнений перемикач без системного дозволу це обіцянка, за якою нічого не
   * станеться. Тому коли людина щось вмикає, ми питаємо систему, і якщо вона
   * відмовила, повертаємо перемикач у вимкнене й кажемо чому. Мовчки лишити
   * його увімкненим означало б, що застосунок бреше в очі. */
  Future<void> _guard({required bool wants, required VoidCallback off}) async {
    if (!wants) {
      _replan();
      return;
    }

    if (_bellOk) {
      _replan();
      return;
    }

    _bellOk = await _bell.granted();
    if (!_bellOk) _bellOk = await _bell.ask();

    if (_bellOk) {
      _replan();
      return;
    }

    off();
    /* Повідомлення береться через [dataL], бо екрана в цю мить може ще не бути:
       дозвіл питають на самому старті. */
    _say(dataL.notifyDenied);
  }

  /// Коротке повідомлення внизу екрана.
  void _say(String text) {
    final nav = _nav.currentState;
    final ctx = nav?.overlay?.context;
    if (ctx == null) return;
    ScaffoldMessenger.maybeOf(
      ctx,
    )?.showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 6)));
  }

  /// Куди веде дотик по сповіщенню.
  void _openFrom(String from) {
    /* Після кадру, а не тієї ж миті: сповіщення може прийти до того, як
       навігатор узагалі народився, і штовхати екран у порожнечу нема сенсу. */
    if (from == From.evening) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _askEvening());
      return;
    }
    if (from != From.meds) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = _nav.currentState;
      if (nav == null) return;
      nav.push(slideRoute(const MedsRoute()));
    });
  }

  /* Вечірнє питання ставиться з самого дня, а не завченою фразою.
   *
   * Питати «як минув день» у того, хто все записав, означає навчити людину
   * змахувати сповіщення не читаючи. Тому якщо в дні нічого не бракує, чат
   * просто відкривається без питання. */
  Future<void> _askEvening() async {
    final db = _db;
    if (db == null || !mounted) return;

    final today = await DayReader(db).read(DateTime.now());
    final ask = eveningAsk(day: today, goal: goalOf(_s));
    if (!mounted || ask == null) return;

    setState(() => _evening = ask);
  }

  /* Питання, яке чекає, поки відкриється день. Порожньо, коли питати нема про
     що або коли його вже поставили. */
  String? _evening;

  /* Розклад переставляється щоразу, коли міняється те, з чого він складається.
   *
   * Через N днів система повторювати не вміє, тому такі сповіщення ставляться
   * поштучно на кілька тижнів уперед і поповнюються тут же: застосунок
   * відкривають частіше, ніж раз на два тижні, а хто не відкривав місяць, тому
   * нагадування вже й не потрібні. */
  /* Закінчені курси відсіює сам планувальник, тому сюди їде весь список.
   *
   * Перемикач «нагадувати про препарати» теж дивиться тільки на ті, що ще
   * приймаються: інакше єдиний закритий курс з увімкненим дзвіночком тримав би
   * його ввімкненим для всіх. */
  void _replan() {
    final live = medsAhead(_meds);
    unawaited(
      _bell.reschedule(reminders: _s.reminders, meds: _meds, medsRemind: live.any((m) => m.remind)),
    );
  }

  /// Чи змінилось у препараті щось, що варто писати в базу.
  static bool _sameMed(Med a, Med b) =>
      a.name == b.name &&
      a.dose == b.dose &&
      a.form == b.form &&
      a.remind == b.remind &&
      /* Межі курсу теж рахуються за зміну.
       *
       * Без них «закінчити курс» нічого не писало в базу: останній день міняв
       * тільки те, що лежить у памʼяті, і після перезапуску препарат
       * повертався в активні, ніби нічого не було. */
      a.startDay == b.startDay &&
      a.endDay == b.endDay &&
      a.note == b.note &&
      repeatToJson(a.repeat) == repeatToJson(b.repeat) &&
      a.times.map((t) => t.at).join(',') == b.times.map((t) => t.at).join(',');

  ThemeMode get _mode => switch (_s.theme) {
    AppTheme.light || AppTheme.aquarelle || AppTheme.dawn => ThemeMode.light,
    AppTheme.dark => ThemeMode.dark,
    AppTheme.system => ThemeMode.system,
  };

  /* Which light theme that is. The decorated grounds are light themes with
     weather on the page, so the split lives here and not in ThemeMode: the
     system setting still flips them into the same dark theme at night. */
  ThemeData get _light => switch (_s.theme) {
    AppTheme.aquarelle => calviAquaTheme,
    AppTheme.dawn => calviDawnTheme,
    _ => calviLightTheme,
  };

  @override
  void initState() {
    super.initState();
    // Real from the first frame, so nothing has to be switched on to be used.
    if (_real && widget.storage) {
      unawaited(_open());
      return;
    }
    /* Без сховища питати нема кого, і відповідь тут одна: показати «Старт».
       Так поводиться тест про екран і збірка, яка навмисно не чіпає диску. */
    _onboarding = true;
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      s: _s,
      set: _set,
      meds: _meds,
      setMeds: _setMeds,
      db: _db,
      sync: _sync,
      real: _real,
      stats: _stats,
      setReal: _setReal,
      child: MaterialApp(
        navigatorKey: _nav,
        title: 'Calvi',
        debugShowCheckedModeBanner: false,
        scrollBehavior: const CalviScroll(),
        theme: _light,
        darkTheme: calviDarkTheme,
        themeMode: _mode,

        localizationsDelegates: L.localizationsDelegates,

        /* Англійська **першою**, і це не про пріоритет, а про запасний варіант:
           Flutter бере першу підтримувану мову для пристроїв, чиєї мови в списку
           немає. Українська стоїть другою і вмикається сама на українському
           телефоні. */
        supportedLocales: const [Locale('en'), Locale('uk')],

        /* `null` означає «спитай пристрій». Людина, яка обрала мову руками,
           перебиває це, і її вибір переживає перезапуск: він лежить у профілі
           поруч із темою. */
        locale: switch (_s.lang) {
          Lang.system => null,
          Lang.uk => const Locale('uk'),
          Lang.en => const Locale('en'),
        },
        /* Шар даних дізнається про мову звідси.
         *
         * Сповіщення, вечірнє питання і підписи, які збирає сховище для самого
         * себе, малюються тоді, коли екрана може не бути взагалі, і `L.of` їм
         * недоступний. Тому мова, обрана вище, дублюється в одне поле, а
         * читається воно через `l10n/data_lang.dart`.
         *
         * Саме тут, а не в `build` вище: до цієї миті Flutter уже вирішив, яку
         * з підтримуваних мов він узяв, зокрема коли вибір лишили за пристроєм. */
        /* Ґрунт під усім, що малює застосунок. У темряві він градієнтний, а
           колір Scaffold градієнта не тримає, тому це окремий шар під деревом
           екранів. */
        /* Заставка стоїть тут, над навігатором і під нічим.
         *
         * Це єдине місце в застосунку, яке обгортає геть усе: і день, і
         * «Старт», і будь-який відкритий аркуш. Заставці саме це й потрібно, бо
         * вона вітає із застосунком, а не з якимось із його екранів. */
        builder: (context, child) {
          final app = child ?? const SizedBox();
          return CalviGround(child: widget.hello ? HelloOverlay(child: app) : app);
        },
        home: Builder(
          builder: (context) {
            dataLang = Localizations.localeOf(context).languageCode;
            return _start(switch (_onboarding) {
              /* Диск ще не відповів. Порожній екран кольору застосунку триває
                 кадр або два і виглядає як продовження заставки; будь-що інше
                 тут блимнуло б і зникло.
               *
               * Прозорий, а не білий: під ним лежить ґрунт, який знає тему, а
               * зашитий білий давав спалах у темряві саме тієї миті, коли
               * застосунок відкривають уночі. */
              null => const SizedBox.expand(),
              true => StartScreen(onFinish: _finishStart),
              false => TodayScreen(
                ask: _evening,
                onSettings: () => Navigator.of(context).push(slideRoute(const SettingsScreen())),
                onMeds: () => Navigator.of(context).push(slideRoute(const MedsRoute())),
              ),
            });
          },
        ),
      ),
    );
  }
}

/* Which screen the app opens on.
   `?screen=settings` in the address bar goes straight there. It exists for the
   same reason the demo has a control panel: a screen five taps deep cannot be
   looked at every time a colour moves, and «tap through to check» is how a
   detail stays broken for a week. Off in a normal build. */

/// Off unless the build asks for it: --dart-define=CALVI_DEV_SCREENS=true
const _devScreens = bool.fromEnvironment('CALVI_DEV_SCREENS');

Widget _start(Widget home) {
  if (!_devScreens) return home;
  final want = Uri.base.queryParameters['screen'];
  if (want == null) return home;
  return Builder(
    builder: (context) {
      final scope = AppScope.of(context);
      return switch (want) {
        'settings' => const SettingsScreen(),
        'profile' => ProfilePanel(s: scope.s, set: scope.set),
        'weight' => WeightPanel(s: scope.s, set: scope.set),
        'goal' => GoalPanel(s: scope.s, set: scope.set),
        'norm' => NormPanel(s: scope.s, set: scope.set),
        'theme' => ThemePanel(s: scope.s, set: scope.set),
        'lang' => LangPanel(s: scope.s, set: scope.set),
        'plan' => const PlanPanel(),
        'privacy' => PrivacyPanel(s: scope.s, set: scope.set),
        'delete' => const DeletePanel(),
        'allergy' => AllergyPanel(s: scope.s, set: scope.set),
        'assistant' => AssistantPanel(s: scope.s, set: scope.set),
        'reminders' => RemindersPanel(
          s: scope.s,
          set: scope.set,
          medsRemind: true,
          onMedsRemind: (_) {},
          onMeds: () {},
          now: 0,
        ),
        'meds' => Builder(
          builder: (context) {
            // The dev entry seeds the demo regimen so there is something to see.
            final scope = AppScope.of(context);
            if (scope.meds.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) => scope.setMeds((_) => demoMeds));
            }
            return const MedsRoute();
          },
        ),
        'analytics' => AnalyticsScreen(measures: demoMeasures, onSettings: () {}),
        'camera' => CameraScreen(slot: baseSlots['lunch']!.label, onSend: (_) {}),
        /* Диктування окремим маршрутом, щоб дивитись на нього в браузері.
           Кнопка стоїть там же, де в барі: справа внизу. */
        'voice' => Scaffold(
          body: Builder(
            builder: (context) {
              final size = MediaQuery.sizeOf(context);
              return VoiceOverlay(
                origin: VoiceOrigin(at: Offset(size.width - 53, size.height - 51), size: 42),
                leaving: false,
                onClosed: () {},
                source: const BreathingLevel(),
              );
            },
          ),
        ),
        'start' => StartScreen(
          onFinish: (_) {},
          step: int.tryParse(Uri.base.queryParameters['step'] ?? '') ?? 0,
        ),
        'today' => Builder(
          builder: (context) {
            // ?meds=1 seeds the regimen, which is what puts a fourth card in the
            // macro row: it cannot be reached from a cold start otherwise.
            final scope = AppScope.of(context);
            if (Uri.base.queryParameters['meds'] == '1' && scope.meds.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) => scope.setMeds((_) => demoMeds));
            }
            return TodayScreen(
              chatOpen: Uri.base.queryParameters['chat'] == '1',
              openCard: Uri.base.queryParameters['card'],
              onSettings: () => Navigator.of(context).push(slideRoute(const SettingsScreen())),
              onMeds: () => Navigator.of(context).push(slideRoute(const MedsRoute())),
            );
          },
        ),
        _ => home,
      };
    },
  );
}
