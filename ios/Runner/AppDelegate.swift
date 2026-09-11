import ActivityKit
import AudioToolbox
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  /* Готові до відтворення звуки, за іменем файла.
   *
   * Створення коштує читання файла з диска, а звук грається на дотик пальця,
   * тобто в найгіршу для цього мить. Ідентифікатори живуть скільки й застосунок:
   * їх два, вони крихітні, і звільняти тут нічого. */
  private var sounds: [String: SystemSoundID] = [:]

  /* Міст до годинника живе стільки ж, скільки застосунок: він тримає сесію
     WatchConnectivity, а та вимагає постійного делегата. Локальна змінна вмерла
     б одразу після старту, і контекст не пішов би нікуди. */
  private var watch: WatchBridge?

  /* Живий запис дня на острівці.
   *
   * Живе стільки ж, скільки застосунок: він тримає посилання на саму
   * активність, а без нього оновлювати було б нічого. Знімається запис у
   * `applicationWillTerminate`: активність, яка лишилась після закритого
   * застосунку, показує вчорашні числа і не має кому їх оновити. */
  private let live = LiveBridge()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    /* Міст піднімається першим і без жодних умов. Коли годинник шле звук, iOS
       запускає застосунок у фоні, без екрана, і саме в цьому запуску сесію
       треба активувати, інакше повідомлення нікому прийняти. Канал до Dart
       підключається нижче, окремо: він потрібен лише відкритому застосунку. */
    watch = WatchBridge()

    /* flutter_local_notifications вимагає віддати себе делегатом центру
       сповіщень: без цього дотик по нагадуванню не доходить до Dart, і
       сповіщення у відкритому застосунку не показуються взагалі. */
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate

    /* Службові звуки початку і кінця запису голосу.
     *
     * Тільки тут, бо на Android їх грає сама система розпізнавання, а на iOS
     * `SFSpeechRecognizer` не грає нічого.
     *
     * `AudioServicesPlaySystemSound`, а не програвач: під час диктування
     * аудіосесія стоїть у режимі запису, і програвач став би її
     * переналаштовувати рівно тієї миті, коли мікрофон вмикається або щойно
     * вимкнувся. Системний виклик у сесію не лізе, він для коротких службових
     * сигналів і зроблений, і сам мовчить, коли телефон у беззвучному режимі. */
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "calvi/earcon",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "play", let name = call.arguments as? String else {
          result(FlutterMethodNotImplemented)
          return
        }
        self?.play(named: name, in: controller, done: result)
      }

      watch?.attach(to: controller.binaryMessenger)
      live.attach(to: controller.binaryMessenger)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /* Застосунок закривають: живий запис іде разом із ним.
   *
   * Dart знімає його на `detached`, але iOS не завжди встигає цей стан дати:
   * коли застосунок вбивають змахом, система інколи просто забирає процес. Цей
   * виклик друга спроба з того ж приводу, і коштує вона нічого.
   *
   * Активність, яка пережила застосунок, показує вчорашні числа і не має кому їх
   * оновити: це гірше за її відсутність, бо виглядає як факт. */
  override func applicationWillTerminate(_ application: UIApplication) {
    live.hide()
    super.applicationWillTerminate(application)
  }

  /* Відповідь іде тоді, коли звук ДОГРАВ, а не коли почав.
     Стартовий сигнал мусить закінчитись до відкриття мікрофона: щойно плагін
     розпізнавання переводить аудіосесію в режим запису, системні звуки
     глушаться, і сигнал, пущений після цього, не чує ніхто. Дартовий бік чекає
     на цю відповідь перед стартом слухання, зі своєю межею по часу на випадок,
     коли заглушений звук про завершення не скаже ніколи. */
  private func play(named name: String, in controller: FlutterViewController, done: @escaping FlutterResult) {
    if let ready = sounds[name] {
      AudioServicesPlaySystemSoundWithCompletion(ready) {
        DispatchQueue.main.async { done(nil) }
      }
      return
    }

    /* Шлях питається у Flutter, а не пишеться руками. Ресурси Flutter лежать у
       зібраному застосунку не там, де в проєкті, і будь-який зашитий шлях
       розійшовся б із дійсністю на першій же зміні складання. */
    let key = controller.lookupKey(forAsset: "assets/sounds/\(name).wav")
    guard let path = Bundle.main.path(forResource: key, ofType: nil) else {
      done(nil)
      return
    }

    var id: SystemSoundID = 0
    let url = URL(fileURLWithPath: path) as CFURL
    guard AudioServicesCreateSystemSoundID(url, &id) == kAudioServicesNoError else {
      done(nil)
      return
    }

    sounds[name] = id
    AudioServicesPlaySystemSoundWithCompletion(id) {
      DispatchQueue.main.async { done(nil) }
    }
  }
}

/* Міст до ActivityKit.
 *
 * Уся розмова з Dart це три слова: показати, оновити, зняти. Числа приходять
 * готовими, бо рахує їх щоденник, а не острівець.
 *
 * Кожна гілка мовчки відмовляє там, де живих активностей немає: iOS до 16.2,
 * вимкнені активності в налаштуваннях, збірка без розширення. Живий запис це
 * зручність поверх щоденника, і валити через нього застосунок не можна.
 */
final class LiveBridge {
  private var channel: FlutterMethodChannel?

  /// Сама активність, поки вона жива. Через неї йдуть і оновлення, і зняття.
  private var current: Any?

  func attach(to messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "calvi/live", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "show":
        self?.show(call.arguments as? [String: Any] ?? [:])
        result(nil)
      case "hide":
        self?.hide()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    self.channel = channel
  }

  func hide() {
    guard #available(iOS 16.2, *), let activity = current as? Activity<CalviLiveAttributes> else {
      return
    }
    current = nil
    Task { await activity.end(nil, dismissalPolicy: .immediate) }
  }

  private func show(_ args: [String: Any]) {
    guard #available(iOS 16.2, *) else { return }

    /* Слова приходять готовими, як і числа: перекладів на цьому боці немає
       взагалі, і складати тут нема чого. Порожній рядок означає рівно те, що
       він означає на екрані, тому запасні значення теж порожні. */
    let state = CalviLiveAttributes.ContentState(
      progress: args["progress"] as? Double ?? 0,
      shown: args["shown"] as? String ?? "",
      caption: args["caption"] as? String ?? "",
      lock: args["lock"] as? String ?? "",
      unit: args["unit"] as? String ?? "",
      lastLabel: args["lastLabel"] as? String ?? "",
      lastValue: args["lastValue"] as? String ?? ""
    )

    /* Позначка «застаріло»: північ.
     *
     * Після неї числа стосуються вчора, і система має право сказати про це
     * сама, приглушивши картку. Без позначки активність вважається свіжою
     * назавжди, і о другій ночі острівець показував би вчорашній залишок як
     * сьогоднішній. */
    let midnight = Calendar.current.nextDate(
      after: Date(),
      matching: DateComponents(hour: 0, minute: 0),
      matchingPolicy: .nextTime
    )

    /* Оновлення того, що вже висить, замість другої активності поруч. Система
       дозволяє кілька активностей одного застосунку, і без цієї гілки кожен
       запис страви заводив би ще одну.
     *
     * Стан перевіряється, бо активність могла вже померти без нас: людина
     * змахнула її з замкненого екрана, або система прибрала за часом. Тоді
     * оновлювати нічого, і треба заводити наново. */
    if let activity = current as? Activity<CalviLiveAttributes> {
      if activity.activityState == .active {
        Task { await activity.update(ActivityContent(state: state, staleDate: midnight)) }
        return
      }
      current = nil
    }

    /* Людина може вимкнути живі активності для застосунку в налаштуваннях
       телефона, і це її право: мовчки нічого не робимо. */
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

    do {
      current = try Activity.request(
        attributes: CalviLiveAttributes(),
        content: ActivityContent(state: state, staleDate: midnight),
        pushType: nil
      )
    } catch {
      // Межа системи на кількість активностей, фонова заборона і таке інше.
      current = nil
    }
  }
}

