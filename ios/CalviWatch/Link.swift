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

  /// Одиниці, у яких людина читає числа на телефоні: порції і енергія. Решта
  /// на годиннику не показується.
  @Published private(set) var portion = "g"
  @Published private(set) var energy = "kcal"

  private let disk = UserDefaults.standard

  /// Порція так, як її читає людина: грами цілі, унції з одним знаком.
  func portionText(_ grams: Int) -> String {
    portion == "oz" ? String(format: "%.1f oz", Double(grams) / 28.349523) : "\(grams) г"
  }

  func energyNum(_ kcal: Int) -> String {
    thousands(energy == "kj" ? Int((Double(kcal) * 4.184).rounded()) : kcal)
  }

  func energyText(_ kcal: Int) -> String {
    "\(energyNum(kcal)) \(energy == "kj" ? "кДж" : "ккал")"
  }

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
    portion = disk.string(forKey: "portion") ?? "g"
    energy = disk.string(forKey: "energy") ?? "kcal"
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
    if let v = context["portion"] as? String {
      portion = v
      disk.set(v, forKey: "portion")
    }
    if let v = context["energy"] as? String {
      energy = v
      disk.set(v, forKey: "energy")
    }
  }
}

/// Чому телефон не відповів словами.
enum LinkTrouble: Error {
  /// Телефона немає поруч, або він вимкнений.
  case far
  /// Телефон відповів, але не словами: без дозволу, без мови, без мережі.
  case failed(String)
}

extension Link {
  /// Слова зі звуку, від телефона.
  ///
  /// Звук іде на айфон разом із мовою застосунку, і той розпізнає тим самим
  /// розпізнавачем Apple, що й диктовка в застосунку, тільки цією мовою.
  /// Застосунок на телефоні відкривати не треба: iOS підіймає його у фоні
  /// сама, і телефон може лишатись заблокованим. Потрібно лише, щоб він був
  /// поруч, у межах Bluetooth або тієї самої мережі.
  func hear(_ file: URL, lang: String) async throws -> String {
    let session = WCSession.default
    guard session.activationState == .activated, session.isReachable else { throw LinkTrouble.far }
    guard let audio = try? Data(contentsOf: file), !audio.isEmpty else {
      throw LinkTrouble.failed("Не почула. Скажи ще раз")
    }

    return try await withCheckedThrowingContinuation { next in
      session.sendMessage(
        ["audio": audio, "lang": lang],
        replyHandler: { reply in
          if let text = reply["text"] as? String {
            next.resume(returning: text.trimmingCharacters(in: .whitespacesAndNewlines))
          } else {
            next.resume(throwing: LinkTrouble.failed(reply["error"] as? String ?? "Не почула. Скажи ще раз"))
          }
        },
        errorHandler: { error in
          /* Не дістав або не дочекався: для людини це одне «телефон далеко».
             Решта помилок каналу теж лягає сюди, бо порада та сама: підійти. */
          let code = (error as? WCError)?.code
          next.resume(throwing: code == .notReachable || code == .messageReplyTimedOut
            ? LinkTrouble.far
            : LinkTrouble.failed("Телефон не відповів"))
        }
      )
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
