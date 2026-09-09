import Flutter
import Speech
import UIKit
import WatchConnectivity

/// Міст до годинника: телефон каже, годинник слухає, і один раз питає.
///
/// Телефон тримає годинник у курсі токена, мови і сьогоднішніх чисел через
/// `updateApplicationContext`: контекст один, він заміняє попередній і доїжджає
/// навіть тоді, коли годинниковий застосунок не запущений.
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
      guard call.method == "tell", let args = call.arguments as? [String: Any] else {
        result(FlutterMethodNotImplemented)
        return
      }
      bridge.tell(args)
      result(nil)
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

  /// Звук із годинника. Відповідь це або `text`, або `error` зі словами для
  /// екрана годинника.
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
    DispatchQueue.main.async {
      Hearing.transcribe(audio, lang: lang, done: replyHandler)
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
    /* Дозвіл уже є: його просила диктовка в застосунку, і це той самий дозвіл.
       Просити тут не можна, бо застосунок може бути піднятий у фоні, де вікна
       з питанням нема кому показати. */
    guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
      done(["error": "Дозволь розпізнавання мовлення в Calvi на телефоні"])
      return
    }

    // Замок на мові: розпізнавач саме цієї локалі, а не «яку почує».
    let id = locales[lang] ?? "en-US"
    guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: id)), recognizer.isAvailable else {
      done(["error": "Розпізнавання цією мовою зараз недоступне"])
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
        finish(["text": result.bestTranscription.formattedString])
      } else if error != nil {
        // Тиша, шум або не та мова: для годинника це одне й те саме.
        finish(["error": "Не почула. Скажи ще раз"])
      }
    }
  }
}
