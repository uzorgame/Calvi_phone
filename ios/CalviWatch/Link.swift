import Foundation
import WatchConnectivity

/// Те, що телефон розповів годиннику, і що годинник памʼятає між запусками.
///
/// Годинник не питає в телефона нічого. Телефон кладе контекст, коли має що
/// сказати, а годинник читає його тоді, коли його відкрили. Тому все, що
/// прийшло, одразу лягає на диск: людина може підняти руку через добу після
/// того, як телефон востаннє був поруч, і застосунок мусить працювати.
@MainActor
final class Link: NSObject, ObservableObject {
  static let shared = Link()

  /// Токен доступу. Без нього годинник не має чим підписати запит до Нори.
  @Published private(set) var token: String?

  /// Мова застосунку на телефоні. Нею годинник слухає і нею ж просить відповідь.
  @Published private(set) var lang: String = "en"

  /// Норма дня і скільки з неї лишалось на момент останнього слова телефона.
  @Published private(set) var norm: Int = 0
  @Published private(set) var left: Int = 0

  private let disk = UserDefaults.standard

  private override init() {
    super.init()
    load()

    guard WCSession.isSupported() else { return }
    WCSession.default.delegate = self
    WCSession.default.activate()
  }

  /// Чи готовий годинник працювати. Ні означає «відкрий Calvi на телефоні».
  var ready: Bool { token?.isEmpty == false }

  /* Залишок після власного запису. Годинник не чекає на телефон, щоб показати
     нове число: він щойно сам його і змінив. Телефон перепише це, коли дійде. */
  func spend(_ kcal: Int) {
    left -= kcal
    disk.set(left, forKey: "left")
  }

  private func load() {
    token = disk.string(forKey: "token")
    lang = disk.string(forKey: "lang") ?? "en"
    norm = disk.integer(forKey: "norm")
    left = disk.integer(forKey: "left")
  }

  fileprivate func take(_ context: [String: Any]) {
    if let v = context["token"] as? String {
      token = v
      disk.set(v, forKey: "token")
    }
    if let v = context["lang"] as? String {
      lang = v
      disk.set(v, forKey: "lang")
    }
    if let v = context["norm"] as? Int {
      norm = v
      disk.set(v, forKey: "norm")
    }
    if let v = context["left"] as? Int {
      left = v
      disk.set(v, forKey: "left")
    }
  }
}

extension Link: WCSessionDelegate {
  nonisolated func session(
    _ session: WCSession,
    activationDidCompleteWith state: WCSessionActivationState,
    error: Error?
  ) {
    /* Контекст, який телефон поклав, поки годинник спав, лежить і чекає. Його
       треба забрати руками одразу після активації: подія про нього вже пройшла,
       і вдруге вона не прийде. */
    let context = session.receivedApplicationContext
    guard !context.isEmpty else { return }
    Task { @MainActor in Link.shared.take(context) }
  }

  nonisolated func session(_ session: WCSession, didReceiveApplicationContext context: [String: Any]) {
    Task { @MainActor in Link.shared.take(context) }
  }
}
