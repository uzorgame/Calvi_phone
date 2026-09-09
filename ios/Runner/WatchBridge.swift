import Flutter
import WatchConnectivity

/// Міст до годинника: телефон каже, годинник слухає.
///
/// Односторонній навмисно. Годинник не питає в телефона нічого: він ходить на
/// сервер сам, бо на пробіжці телефона поруч може не бути зовсім, а запит без
/// нього однаково має піти. Телефону лишається одне: тримати годинник у курсі
/// токена, мови і сьогоднішніх чисел.
///
/// `updateApplicationContext`, а не повідомлення. Контекст один, він заміняє
/// попередній і доїжджає навіть тоді, коли годинниковий застосунок не
/// запущений: саме це й потрібно, бо стан має бути свіжим на момент, коли його
/// відкриють, а не на момент, коли ми його послали.
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
}
