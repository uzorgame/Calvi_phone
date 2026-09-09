import Flutter
import Speech
import UIKit
import WatchConnectivity

/// Міст до годинника: телефон каже, годинник слухає, і один раз питає.
///
/// Телефон тримає годинник у курсі токена, мови і сьогоднішніх чисел через
/// `updateApplicationContext`: контекст один, він заміняє попередній і доїжджає
/// навіть тоді, коли годинниковий застосунок не запущений. Порожній токен у
/// контексті означає вихід з акаунта: годинник забуває людину тієї ж миті.
///
/// Єдине, про що годинник питає телефон, це слова зі звуку. На watchOS немає
/// розпізнавача, яким користується диктовка в застосунку, а вбудована диктовка
/// приносить свій екран. Тому годинник записує сказане і шле сюди, а телефон
/// розпізнає тим самим розпізнавачем Apple, що й у диктовці, тією самою мовою,
/// що стоїть у застосунку. Застосунок для цього відкривати не треба: iOS сама
/// підіймає його у фоні на кілька секунд, коли годинник надсилає повідомлення,
/// і телефон може лишатись заблокованим. Потрібно лише, щоб він був поруч.
final class WatchBridge: NSObject {
  private let session: WCSession?

  override init() {
    session = WCSession.isSupported() ? WCSession.default : nil
    super.init()
    session?.delegate = self
    session?.activate()
  }

  /// Підключає канал до Dart. Робиться один раз, при старті застосунку.
  static func attach(to messenger: FlutterBinaryMessenger) -> WatchBridge {
    let bridge = WatchBridge()
    let channel = FlutterMethodChannel(name: "calvi/watch", binaryMessenger: messenger)

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "tell":
        guard let args = call.arguments as? [String: Any] else {
          result(FlutterMethodNotImplemented)
          return
        }
        bridge.tell(args)
        result(nil)
      case "status":
        result(bridge.status())
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    return bridge
  }

  private func tell(_ state: [String: Any]) {
    guard let session, session.activationState == .activated else { return }

    /* Пари годиннику може не бути взагалі, і це звичайний випадок, а не збій:
       більшість людей ходить без нього. Кидати сюди помилку в Dart означало б
       лякати телефон тим, що його не стосується. */
    guard session.isPaired, session.isWatchAppInstalled else { return }

    do {
      try session.updateApplicationContext(state)
    } catch {
      /* Контекст не пішов. Наступна зміна дня надішле новий, а старий нікому не
         потрібен: там ті самі поля, тільки застарілі. */
      NSLog("watch: контекст не пішов, \(error.localizedDescription)")
    }
  }

  /// Що телефон знає про годинник, для рядка в налаштуваннях.
  ///
  /// «Актуальний» означає, що останній контекст ліг у канал: далі його доставить
  /// система, навіть якщо годинник зараз спить.
  private func status() -> [String: Any] {
    guard let session, session.activationState == .activated else {
      return ["paired": false, "installed": false, "current": false]
    }
    return [
      "paired": session.isPaired,
      "installed": session.isWatchAppInstalled,
      "current": !session.applicationContext.isEmpty,
    ]
  }
}

extension WatchBridge: WCSessionDelegate {
  func session(
    _ session: WCSession,
    activationDidCompleteWith state: WCSessionActivationState,
    error: Error?
  ) {}

  /* Обидва обовʼязкові на iOS і потрібні для однієї речі: коли людина
     перемикається на інший годинник, сесію треба підняти заново, інакше
     наступний контекст піде в нікуди. */
  func sessionDidBecomeInactive(_ session: WCSession) {}

  func sessionDidDeactivate(_ session: WCSession) {
    session.activate()
  }

  /// Звук із годинника.
  ///
  /// Відповідь на саме повідомлення це лише «прийняв», і йде вона одразу: канал
  /// чекає на неї лічені секунди, а холодний старт у фоні разом із
  /// розпізнаванням у них не завжди вкладається. Слова їдуть назад окремим
  /// повідомленням із тим самим номером, і на них годинник чекає стільки,
  /// скільки сам вирішив.
  func session(
    _ session: WCSession,
    didReceiveMessage message: [String: Any],
    replyHandler: @escaping ([String: Any]) -> Void
  ) {
    guard let audio = message["audio"] as? Data, !audio.isEmpty else {
      replyHandler(["error": "Не почула. Скажи ще раз"])
      return
    }
    let lang = message["lang"] as? String ?? "en"
    let id = message["id"] as? String ?? ""
    replyHandler(["ack": true])

    DispatchQueue.main.async {
      Hearing.transcribe(audio, lang: lang) { outcome in
        var back = outcome
        back["id"] = id
        session.sendMessage(back, replyHandler: nil) { error in
          // Годинник уже не в руці: слова нікому, і це не помилка телефона.
          NSLog("watch: слова не пішли, \(error.localizedDescription)")
        }
      }
    }
  }
}

/// Слова зі звуку, тим самим розпізнавачем і тією самою мовою, що в диктовці.
enum Hearing {
  /* Та сама таблиця, що в `dictation.dart`: мова застосунку і локаль
     розпізнавача. Розійтись їм не можна: тоді телефон і годинник чули б
     одну мову по-різному. */
  private static let locales: [String: String] = [
    "uk": "uk-UA", "en": "en-US", "es": "es-ES", "it": "it-IT",
    "de": "de-DE", "fr": "fr-FR", "pt": "pt-BR", "pl": "pl-PL",
  ]

  static func transcribe(_ audio: Data, lang: String, done: @escaping ([String: Any]) -> Void) {
    /* Дозвіл уже є: його просила диктовка в застосунку або екран «Доступ», і
       це той самий дозвіл. Просити тут не можна, бо застосунок може бути
       піднятий у фоні, де вікна з питанням нема кому показати. */
    guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
      done(["error": "Дозволь розпізнавання мовлення: Calvi, Налаштування, Доступ"])
      return
    }

    // Замок на мові: розпізнавач саме цієї локалі, а не «яку почує».
    let id = locales[lang] ?? "en-US"
    guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: id)) else {
      done(["error": "Розпізнавання цією мовою недоступне"])
      return
    }
    /* Розпізнавач Apple працює через мережу, і «недоступний» майже завжди
       означає, що телефон без неї. Так і кажемо, а не «мова недоступна». */
    guard recognizer.isAvailable else {
      done(["error": "Відсутнє підключення до мережі"])
      return
    }

    let file = FileManager.default.temporaryDirectory.appendingPathComponent("watch-\(UUID().uuidString).m4a")
    do {
      try audio.write(to: file)
    } catch {
      done(["error": "Не почула. Скажи ще раз"])
      return
    }

    /* Застосунок могли підняти у фоні рівно заради цього повідомлення, і iOS
       дає йому лічені секунди. Фонова задача просить ще трохи, щоб відповідь
       устигла піти назад на годинник. */
    var task = UIBackgroundTaskIdentifier.invalid
    task = UIApplication.shared.beginBackgroundTask {
      UIApplication.shared.endBackgroundTask(task)
      task = .invalid
    }

    let request = SFSpeechURLRecognitionRequest(url: file)
    request.shouldReportPartialResults = false
    request.taskHint = .dictation

    var answered = false
    let finish: ([String: Any]) -> Void = { reply in
      guard !answered else { return }
      answered = true
      try? FileManager.default.removeItem(at: file)
      done(reply)
      if task != .invalid {
        UIApplication.shared.endBackgroundTask(task)
        task = .invalid
      }
    }

    recognizer.recognitionTask(with: request) { result, error in
      if let result, result.isFinal {
        finish(["heard": result.bestTranscription.formattedString])
      } else if error != nil {
        // Тиша, шум або не та мова: для годинника це одне й те саме.
        finish(["error": "Не почула. Скажи ще раз"])
      }
    }
  }
}
