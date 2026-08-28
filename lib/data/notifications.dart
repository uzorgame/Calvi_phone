import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/data_lang.dart';
import 'meds.dart';
import 'repeat.dart';
import 'settings.dart';

/// Сповіщення нагадувань і препаратів.
///
/// Локальні, а не з сервера, і це не економія: нагадування має спрацювати в
/// літаку, у метро і на телефоні, який тиждень не бачив мережі. Час тут
/// настінний: восьма ранку лишається восьмою після перельоту, бо людина пʼє
/// таблетку вранці, а не о шостій за київським.
///
/// Тексти навмисно однакові щоразу. Це системне сповіщення в шторці, а не
/// повідомлення від Нори: воно має за пів секунди сказати, що робити, і зникнути
/// з дороги.
/// Як часто повторюється одне заплановане сповіщення.
enum Repeats { once, daily, weekly }

/// Куди лягають заплановані сповіщення.
///
/// Свій шов, а не плагін напряму: плагін однинний і не успадковується, а
/// перевіряти тут треба не показ (його дає система), а те, скільки сповіщень і
/// з якими словами кладеться в чергу. Саме там ховаються «нагадування не
/// прийшло» і «прийшло не те».
abstract class NotificationSink {
  Future<void> ready();
  Future<void> clearAll();
  Future<void> put({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    required Repeats repeats,

    /// Звідки це сповіщення: за нею вирішується, який екран відкрити по дотику.
    required String from,
  });

  /// Питає дозвіл. Повертає, чи його дали.
  Future<bool> ask();

  /// Чи дозволено показувати сповіщення просто зараз, без питання.
  Future<bool> granted();

  /// Кого кликати, коли людина торкнулась сповіщення.
  set onTap(void Function(String from)? handler);

  /// Мітка сповіщення, з якого щойно запустили застосунок, якщо такий був.
  Future<String?> launchedFrom();
}

/// Звідки сповіщення. Мітка їде разом із ним і повертається по дотику.
class From {
  static const meds = 'meds';
  static const reminder = 'reminder';

  /* Вечірнє питання має свою мітку, бо веде не туди, куди решта нагадувань:
     решта нагадує зробити, а це питає, і дотик має відкрити чат із самим
     питанням, а не просто застосунок. */
  static const evening = 'evening';
}

class Notifications {
  Notifications({NotificationSink? sink}) : _sink = sink ?? LocalSink();

  final NotificationSink _sink;

  /* Дотик по сповіщенню препаратів веде в препарати, а не на головну.
   *
   * Людина торкнулась «Магній B6, 2 таблетки» саме для того, щоб поставити
   * галочку. Висадити її на головному екрані означає змусити шукати дорогу до
   * того, за чим вона прийшла, і половина цього не робить. */
  set onTap(void Function(String from)? handler) => _sink.onTap = handler;

  /// Мітка сповіщення, з якого запустили застосунок, якщо такий був.
  Future<String?> launchedFrom() => _sink.launchedFrom();

  /// Готує все, що потрібно, щоб планувати.
  Future<void> start() => _sink.ready();

  /// Питає дозвіл показувати сповіщення.
  ///
  /// Питається на першому нагадуванні, а не при встановленні: питати наперед
  /// означає питати до того, як людина зрозуміла, навіщо це їй, і половина
  /// відмовляється не подумавши.
  Future<bool> ask() => _sink.ask();

  /// Чи дозволено показувати сповіщення просто зараз.
  ///
  /// Потрібне, щоб перемикач не брехав: увімкнений перемикач без системного
  /// дозволу це обіцянка, за якою нічого не станеться, і людина дізнається про
  /// це тільки з пропущеного прийому.
  Future<bool> granted() => _sink.granted();

  /// Перепланувати все з нуля.
  ///
  /// Саме з нуля, а не «додати нове»: людина міняє години й дні, і різницю між
  /// старим і новим розкладом дешевше не рахувати, ніж рахувати неправильно.
  /// Забуте старе сповіщення дзвонить о тій годині, яку вже скасували.
  /* Перепланування йдуть по черзі, а не навперейми.
   *
   * Кожне починається з того, що витирає чергу цілком, і при запуску їх два:
   * профіль і препарати читаються з диска паралельно, і обидва потім просять
   * перепланувати. Два таких виклики можуть перетнутись так, що «витерти»
   * другого ляже після «поставити» першого, і людина лишиться без сповіщень
   * до наступного дотику до налаштувань. */
  Future<void> _queue = Future<void>.value();

  Future<void> reschedule({
    required List<Reminder> reminders,
    required List<Med> meds,
    required bool medsRemind,
  }) {
    final next = _queue.then(
      (_) => _reschedule(reminders: reminders, meds: meds, medsRemind: medsRemind),
    );
    _queue = next.catchError((_) {});
    return next;
  }

  Future<void> _reschedule({
    required List<Reminder> reminders,
    required List<Med> meds,
    required bool medsRemind,
  }) async {
    await _sink.ready();
    await _sink.clearAll();

    var id = 1;

    for (final r in reminders) {
      if (!r.on) continue;
      for (final at in r.times) {
        id = await _plan(
          id,
          r.repeat,
          at,
          _title(r),
          _body(r.kind),
          r.kind == ReminderKind.summary ? From.evening : From.reminder,
        );
      }
    }

    if (medsRemind) {
      /* Закінчений курс не дзвонить.
       *
       * Препарат лишається в застосунку заради історії, і саме тому відсів
       * стоїть тут, у самому планувальнику: місць, які його викликають, більше
       * одного, і достатньо забути про це в одному з них, щоб людину будив
       * о восьмій ранку курс, який вона закрила минулого місяця. */
      for (final m in meds) {
        if (!m.stillRunning()) continue;
        if (!m.remind) continue;
        for (final t in m.times) {
          id = await _plan(id, m.repeat, t.at, m.name, doseLabel(m.dose, m.form), From.meds);
        }
      }
    }
  }

  /// Знімає всі заплановані сповіщення.
  Future<void> clear() async {
    await _sink.ready();
    await _sink.clearAll();
  }

  /// Ставить одну годину за її розкладом і повертає наступний вільний номер.
  Future<int> _plan(
    int id,
    Repeat repeat,
    String at,
    String title,
    String body,
    String from,
  ) async {
    final parts = at.split(':');
    final hh = int.tryParse(parts.first);
    final mm = parts.length > 1 ? int.tryParse(parts[1]) : 0;
    if (hh == null || mm == null) return id;

    switch (repeat) {
      case DailyRepeat():
        await _at(id, _next(hh, mm), title, body, Repeats.daily, from);
        return id + 1;

      case WeekdayRepeat(:final days):
        if (days.isEmpty) {
          await _at(id, _next(hh, mm), title, body, Repeats.daily, from);
          return id + 1;
        }
        for (final d in days) {
          await _at(id, _nextOn(d, hh, mm), title, body, Repeats.weekly, from);
          id++;
        }
        return id;

      case IntervalRepeat():
        /* Через N днів система повторювати не вміє: у неї є «щодня» і «щотижня»,
           і більше нічого. Тому найближчі кілька тижнів ставляться поштучно, а
           поповнюються вони щоразу, коли застосунок відкривають. Людина, яка не
           заходила місяць, і нагадувань не потребує так само. */
        var made = 0;
        final now = DateTime.now();

        for (var i = 0; i < 60 && made < 14; i++) {
          final at = DateTime(now.year, now.month, now.day + i, hh, mm);
          if (at.isBefore(now)) continue;
          if (!fallsOn(repeat, DateTime(at.year, at.month, at.day))) continue;

          await _at(id, at, title, body, Repeats.once, from);
          id++;
          made++;
        }
        return id;
    }
  }

  Future<void> _at(
    int id,
    DateTime when,
    String title,
    String body,
    Repeats repeats,
    String from,
  ) => _sink.put(id: id, title: title, body: body, at: when, repeats: repeats, from: from);

  /// Найближче настання цієї години.
  static DateTime _next(int hh, int mm) {
    final now = DateTime.now();
    var at = DateTime(now.year, now.month, now.day, hh, mm);
    if (!at.isAfter(now)) at = DateTime(now.year, now.month, now.day + 1, hh, mm);
    return at;
  }

  /// Найближчий такий день тижня о цій годині.
  static DateTime _nextOn(int weekday, int hh, int mm) {
    var at = _next(hh, mm);
    while (at.weekday != weekday) {
      // Доба додається конструктором, а не тривалістю: у ніч переходу на зимовий
      // час доба плюс двадцять чотири години це той самий день.
      at = DateTime(at.year, at.month, at.day + 1, hh, mm);
    }
    return at;
  }

  /* Слова тут беруться через [dataL], а не через `L.of(context)`, і причина не
     в зручності: черга сповіщень будується тоді, коли екрана може не бути
     взагалі. */

  /// Заголовок: назва нагадування, як його назвала людина.
  static String _title(Reminder r) {
    final own = r.label.trim();
    if (own.isNotEmpty) return own;

    final l = dataL;
    return switch (r.kind) {
      ReminderKind.meal => l.reminderMeal,
      ReminderKind.water => l.reminderWater,
      ReminderKind.meds => l.reminderMeds,
      ReminderKind.workout => l.reminderWorkout,
      ReminderKind.weigh => l.reminderWeigh,
      ReminderKind.summary => l.reminderSummary,
    };
  }

  /// Що робити, одним рядком. Без вигуків, емодзі й дорікань: нагадування, яке
  /// дорікає, вимикають на третій день.
  static String _body(ReminderKind kind) {
    final l = dataL;
    return switch (kind) {
      ReminderKind.meal => l.reminderBodyMeal,
      ReminderKind.water => l.reminderBodyWater,
      ReminderKind.workout => l.reminderBodyWorkout,
      ReminderKind.weigh => l.reminderBodyWeigh,
      /* Питання, а не звіт. «Скільки вийшло» це підсумок, який людина прочитає і
         закриє; питання вона може закрити однією фразою, і день стане повним. */
      ReminderKind.summary => l.reminderBodySummary,
      ReminderKind.meds => l.reminderBodyMeds,
    };
  }
}

/// Справжня черга сповіщень телефона.
///
/// Локальні, а не з сервера, і це не економія: нагадування має спрацювати в
/// літаку, у метро і на телефоні, який тиждень не бачив мережі. Час настінний:
/// восьма ранку лишається восьмою після перельоту, бо людина пʼє таблетку
/// вранці, а не о шостій за київським.
class LocalSink implements NotificationSink {
  LocalSink({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  /* Канал заводиться раз і живе в системних налаштуваннях телефона. Назва
     береться мовою застосунку на момент першого запуску: Android не міняє її
     заднім числом, і це нормально, бо змінити мову там людина може сама. */
  static AndroidNotificationChannel get _channel => AndroidNotificationChannel(
    'calvi.reminders',
    dataL.notifyChannel,
    description: dataL.notifyChannelHint,
    importance: Importance.high,
  );

  bool _started = false;

  @override
  set onTap(void Function(String from)? handler) => _onTap = handler;
  void Function(String from)? _onTap;

  @override
  Future<String?> launchedFrom() async {
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp != true) return null;
    return launch?.notificationResponse?.payload;
  }

  @override
  Future<void> ready() async {
    if (_started) return;

    tzdata.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (_) {
      // Невідомий пояс це не привід лишити людину без нагадувань зовсім.
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        /* Без цих `false` iOS питає дозвіл прямо при першому запуску, а він
           питається на першому нагадуванні, коли людина розуміє навіщо. */
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final from = response.payload;
        if (from != null) _onTap?.call(from);
      },
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    _started = true;
  }

  @override
  Future<bool> granted() async {
    await ready();
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) return await android.areNotificationsEnabled() ?? false;

    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    return (await ios?.checkPermissions())?.isEnabled ?? false;
  }

  @override
  Future<bool> ask() async {
    await ready();
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final allowed = await android.requestNotificationsPermission() ?? false;
      // Точний будильник це окремий дозвіл: без нього система має право зсунути
      // показ на десятки хвилин.
      await android.requestExactAlarmsPermission();
      return allowed;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    // Бейдж теж: системне вікно iOS показується один раз за життя встановлення,
    // і те, чого не спитали зараз, потім можна ввімкнути лише в налаштуваннях.
    return await ios?.requestPermissions(alert: true, sound: true, badge: true) ?? false;
  }

  @override
  Future<void> clearAll() => _plugin.cancelAll();

  @override
  Future<void> put({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    required Repeats repeats,
    required String from,
  }) async {
    /* Точний будильник це окремий дозвіл, і система має право його не дати.
     *
     * Коли не дає, `zonedSchedule` кидає помилку, і без цього перехоплення
     * сповіщення просто не ставилось: людина бачила увімкнений перемикач і
     * порожню шторку. Краще показати на кілька хвилин пізніше, ніж не показати
     * взагалі, тому запасний варіант це неточний будильник. */
    try {
      await _put(id, title, body, at, repeats, from, exact: true);
    } catch (e) {
      await _put(id, title, body, at, repeats, from, exact: false);
    }
  }

  Future<void> _put(
    int id,
    String title,
    String body,
    DateTime at,
    Repeats repeats,
    String from, {
    required bool exact,
  }) => _plugin.zonedSchedule(
    id: id,
    title: title,
    body: body,
    // Мітка їде разом зі сповіщенням і повертається по дотику: за нею
    // вирішується, який екран відкрити.
    payload: from,
    scheduledDate: at is tz.TZDateTime ? at : tz.TZDateTime.from(at, tz.local),
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
    androidScheduleMode: exact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: switch (repeats) {
      Repeats.once => null,
      Repeats.daily => DateTimeComponents.time,
      Repeats.weekly => DateTimeComponents.dayOfWeekAndTime,
    },
  );
}
