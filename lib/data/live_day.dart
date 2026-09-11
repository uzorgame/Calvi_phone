import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

import '../l10n/data_lang.dart';

/* Живий запис дня: те, що видно, не відкриваючи застосунок.
 *
 * На iPhone це жива активність на динамічному острівці, на Android стійке
 * сповіщення. Речі різні, а питання одне: скільки калорій лишилось на сьогодні,
 * без відкривання застосунку. Тому числа тут спільні, а розходяться лише
 * останні кілька рядків, де кожна система малює по-своєму.
 *
 * **Висить тільки поки застосунок живий.** Заводиться, коли він працює або
 * згорнутий, і знімається, коли його закрили. Запис, який лишається після
 * закритого застосунку, показує вчорашні числа і не має кому їх оновити: це
 * гірше за відсутність запису, бо виглядає як факт.
 */

/// Числа, які показує живий запис. Ті самі, що на картці дня.
class LiveFacts {
  const LiveFacts({required this.left, required this.goal, required this.eaten, this.last});

  /// Скільки лишилось до норми. Відʼємне означає перебір.
  final int left;

  /// Норма дня.
  final int goal;

  /// Скільки вже зʼїдено, нетто: спалене на тренуваннях уже відняте.
  final int eaten;

  /* Скільки калорій в останньому записі, або порожньо, коли сьогодні ще нічого
     не записували. Показує його лише розгорнутий вигляд острівця: у стислому і
     в сповіщенні на нього немає ні місця, ні потреби. */
  final int? last;

  /// Скільки норми пройдено, 0..1 і більше. Кільце і смуга беруть саме її.
  double get progress => goal <= 0 ? 0 : (eaten < 0 ? 0 : eaten / goal);

  /// Перебір це не відʼємне число на екрані, а інше слово поруч із додатним.
  bool get over => left < 0;

  @override
  bool operator ==(Object other) =>
      other is LiveFacts &&
      other.left == left &&
      other.goal == goal &&
      other.eaten == eaten &&
      other.last == last;

  @override
  int get hashCode => Object.hash(left, goal, eaten, last);
}

/// Куди йде живий запис. Свій шов, щоб перевіряти рішення без телефона.
abstract class LiveSink {
  Future<void> show(LiveFacts facts);
  Future<void> hide();
}

/// Живий запис, який уміє не робити зайвого.
class LiveDay {
  LiveDay({LiveSink? sink}) : _sink = sink ?? platformSink();

  /// Той шов, який годиться цій системі. Порожній там, де живих записів немає.
  static LiveSink platformSink() {
    if (kIsWeb) return const _Silent();
    if (Platform.isAndroid) return AndroidLive();
    if (Platform.isIOS) return const IosLive();
    return const _Silent();
  }

  final LiveSink _sink;

  /// Що вже показано. Потрібне, щоб не смикати систему тими самими числами:
  /// підсумки дня приходять потоком і часто повторюються.
  LiveFacts? _shown;
  bool _on = false;

  /// Показати або оновити. Поки застосунок живий, це можна кликати скільки
  /// завгодно разів: однакові числа далі не йдуть.
  Future<void> put(LiveFacts facts) async {
    if (_on && _shown == facts) return;
    _shown = facts;
    _on = true;
    await _sink.show(facts);
  }

  /// Зняти. Викликається, коли застосунок закривають.
  Future<void> off() async {
    if (!_on) return;
    _on = false;
    _shown = null;
    await _sink.hide();
  }

  /* Забути показане, нічого не знімаючи.
   *
   * Потрібне рівно в одному випадку: дозвіл на сповіщення щойно дали. Доти числа
   * вже пішли в систему, вона мовчки їх викинула (на Android 13 і новіших без
   * дозволу сповіщення просто не зʼявляється), а тут лишилось памʼятати, що
   * запис ніби стоїть. Ті самі числа далі не пішли б нікуди, і живий запис
   * зʼявився б аж із наступною записаною стравою.
   *
   * Не `off()`: знімати нема чого, бо нічого й не висить, а зайвий виклик до
   * системи тут нічого б не виправив. */
  void forget() {
    _on = false;
    _shown = null;
  }
}

/* Число так, як його пише застосунок: з тонким пробілом між тисячами.
 *
 * Одиниці тут навмисно не питаються. Сповіщення це рядок у шторці, а не екран
 * застосунку: людина, яка рахує у фунтах, усе одно рахує калорії калоріями. */
String _num(int v) {
  final digits = v.abs().toString();
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(' ');
    out.write(digits[i]);
  }
  return v < 0 ? '-$out' : out.toString();
}

/// Там, де живих записів немає: веб і все інше.
class _Silent implements LiveSink {
  const _Silent();

  @override
  Future<void> show(LiveFacts facts) async {}

  @override
  Future<void> hide() async {}
}

/* --- Android ---
 *
 * Стійке сповіщення зі смугою, а на Android 16 і новіших ще й фішка в рядку
 * стану поруч із годинником: там видно, чиє це сповіщення, цілий день.
 *
 * **Малює його наш власний код, а не плагін сповіщень.** Усе інше застосунок
 * кладе в чергу через `flutter_local_notifications`, і живий запис довго йшов
 * тією ж дорогою. Але фішка в рядку стану вмикається двома речами, яких плагін
 * не знає: стилем поступу і прапорцем «це живе оновлення». Передати їх крізь
 * нього неможливо, тому це єдине сповіщення будується на Kotlin.
 *
 * Звідси йдуть готові слова, а не числа. Усі вісім мов живуть тут, і другий
 * переклад на тому боці розійшовся б із цим на першій же правці.
 *
 * Канал, тиша без звуку й вібрації, змах, шестигодинна межа і решта міркувань
 * лишились ті самі, тільки переїхали в `LiveNotice.kt`.
 */
class AndroidLive implements LiveSink {
  const AndroidLive();

  /* Свій канал, окремий від острівцевого. Острівець просить числа, сповіщення
     просить готові слова, і одне імʼя на два різні вантажі було б запрошенням
     передати туди не те. */
  static const _channel = MethodChannel('calvi/live.android');

  @override
  Future<void> show(LiveFacts facts) async {
    /* Смуга рахується у відсотках, а не в калоріях: перебір інакше вилітав би
       за межу, і система малювала б її порожньою замість повної. */
    final done = (facts.progress * 100).round().clamp(0, 100);

    try {
      await _channel.invokeMethod<void>('show', {
        'title': facts.over
            ? dataL.liveOver(_num(facts.left.abs()))
            : dataL.liveLeft(_num(facts.left)),
        'body': dataL.liveBody(_num(facts.eaten), _num(facts.goal)),
        'channel': dataL.liveChannel,
        'channelHint': dataL.liveChannelHint,
        'progress': done,
      });
    } on PlatformException {
      // Сповіщення це зручність поверх щоденника, а не сам щоденник.
    } on MissingPluginException {
      // Збірка без нативної частини, наприклад у тестах.
    }
  }

  @override
  Future<void> hide() async {
    try {
      await _channel.invokeMethod<void>('hide');
    } on PlatformException {
      // Нема чого знімати.
    } on MissingPluginException {
      // Те саме.
    }
  }
}

/* --- iOS ---
 *
 * Жива активність заводиться не з Dart: ActivityKit це Swift, і малює її окреме
 * розширення застосунку. Коли розширення в збірці немає, канал мовчки відмовляє
 * і застосунок працює далі.
 *
 * Звідси йдуть готові слова, а не самі числа, і це не дрібниця формату.
 * Розширення живе окремим процесом: у нього немає ні `BuildContext`, ні локалі
 * застосунку, тому будь-який рядок, написаний там, лишається одномовним. Саме
 * так і було: острівець казав «ккал лишилось» українською в кожному телефоні,
 * хай якою мовою людина поставила застосунок. Тепер там не лишилось жодного
 * свого слова, рівно як в Android.
 */
class IosLive implements LiveSink {
  const IosLive();

  static const _channel = MethodChannel('calvi/live');

  @override
  Future<void> show(LiveFacts facts) async {
    try {
      await _channel.invokeMethod<void>('show', {
        /* Кільце і смуга беруть частку, і вона підрізана тут: перебір це інше
           слово поруч із додатним числом, а не смуга, що вилізла за край. */
        'progress': facts.progress.clamp(0.0, 1.0),
        'shown': _num(facts.left.abs()),
        'caption': facts.over ? dataL.islandOver : dataL.islandLeft,
        'lock': facts.over ? dataL.islandTodayOver : dataL.islandToday,
        // Порожнє значення означає «сьогодні ще нічого», і підпис скаже саме це.
        'lastLabel': facts.last == null ? dataL.islandNothing : dataL.islandLast,
        'lastValue': facts.last == null ? '' : '${_num(facts.last!)} ${dataL.unitKcal}',
        'unit': dataL.unitKcal,
      });
    } on PlatformException {
      /* Телефон без острівця, вимкнені живі активності в налаштуваннях, збірка
         без розширення. Жоден із трьох випадків не привід валити застосунок:
         живий запис це зручність поверх щоденника, а не сам щоденник. */
    } on MissingPluginException {
      // Те саме: збірка без нативної частини, наприклад у тестах.
    }
  }

  @override
  Future<void> hide() async {
    try {
      await _channel.invokeMethod<void>('hide');
    } on PlatformException {
      // Нема чого знімати.
    } on MissingPluginException {
      // Те саме.
    }
  }
}
