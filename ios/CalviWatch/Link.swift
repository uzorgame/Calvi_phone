import Foundation
import WatchConnectivity

/// Те, що телефон розповів годиннику, і що годинник памʼятає між запусками.
///
/// Годинник не питає в телефона нічого, крім слів зі звуку. Телефон кладе
/// контекст, коли має що сказати, а годинник читає його тоді, коли його
/// відкрили. Тому все, що прийшло, одразу лягає на диск: людина може підняти
/// руку через добу після того, як телефон востаннє був поруч, і застосунок
/// мусить працювати.
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

  /// Куди людина йде: lose, keep, gain. Від цього залежить, коли день уже
  /// читається як «план виконаний», за тим самим правилом, що в застосунку.
  @Published private(set) var direction = "keep"

  private let disk = UserDefaults.standard

  /// Слова, на які годинник ще чекає від телефона, за номером запису.
  private var pending: [String: CheckedContinuation<String, Error>] = [:]

  /// Слова, що прийшли раніше, ніж годинник почав на них чекати. Помилку без
  /// розпізнавання телефон шле тієї ж миті, що й «прийняв», і друге
  /// повідомлення може обігнати перше; загубити його означало б чекати
  /// п'ятнадцять секунд і сказати «не відповів» замість справжньої причини.
  private var early: [String: Result<String, Error>] = [:]

  /// Скільки чекати на слова. Холодний старт застосунку у фоні плюс саме
  /// розпізнавання вкладаються з запасом; довше означає, що телефон не відповість.
  static let patience: Duration = .seconds(15)

  /// Порція так, як її читає людина: грами цілі, унції з одним знаком.
  func portionText(_ grams: Int) -> String {
    portion == "oz"
      ? String(format: "%.1f oz", Double(grams) / 28.349523)
      : "\(grams) \(Words.of(lang).gram)"
  }

  func energyNum(_ kcal: Int) -> String {
    thousands(energy == "kj" ? Int((Double(kcal) * 4.184).rounded()) : kcal)
  }

  /// Слово одиниці енергії: «ккал» або «кДж» мовою застосунку.
  func energyUnit() -> String {
    energy == "kj" ? Words.of(lang).kj : Words.of(lang).kcal
  }

  func energyText(_ kcal: Int) -> String {
    "\(energyNum(kcal)) \(energyUnit())"
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

  /// Токен більше не годиться: сервер відмовив ним. Годинник повертається в
  /// стан «відкрий Calvi на телефоні», і телефон дасть свіжий.
  func forget() {
    token = nil
    disk.removeObject(forKey: "token")
  }

  private func load() {
    token = disk.string(forKey: "token")
    lang = disk.string(forKey: "lang") ?? "en"
    norm = disk.integer(forKey: "norm")
    left = disk.integer(forKey: "left")
    portion = disk.string(forKey: "portion") ?? "g"
    energy = disk.string(forKey: "energy") ?? "kcal"
    direction = disk.string(forKey: "direction") ?? "keep"
  }

  fileprivate func take(_ context: [String: Any]) {
    /* Порожній токен це вихід з акаунта на телефоні. Годинник забуває людину
       тієї ж миті, а не через тридцять днів, коли токен протух би сам. */
    if let v = context["token"] as? String {
      if v.isEmpty {
        forget()
      } else {
        token = v
        disk.set(v, forKey: "token")
      }
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
    if let v = context["direction"] as? String {
      direction = v
      disk.set(v, forKey: "direction")
    }
  }

  // MARK: Слова від телефона

  /// Слова зі звуку, від телефона.
  ///
  /// Звук іде на айфон разом із мовою застосунку, і той розпізнає тим самим
  /// розпізнавачем Apple, що й диктовка в застосунку, тільки цією мовою.
  /// Застосунок на телефоні відкривати не треба: iOS підіймає його у фоні
  /// сама, і телефон може лишатись заблокованим. Потрібно лише, щоб він був
  /// поруч, у межах Bluetooth або тієї самої мережі.
  ///
  /// Два кроки, а не один. Відповідь на повідомлення має прийти за лічені
  /// секунди, інакше канал сам рахує її простроченою; холодний старт
  /// застосунку у фоні разом із розпізнаванням у це не завжди вкладається.
  /// Тому телефон відповідає «прийняв» одразу, а слова шле окремим
  /// повідомленням, і на них годинник чекає стільки, скільки сам вирішив.
  func hear(_ file: URL, lang: String) async throws -> String {
    /* Без перевірки `isReachable` наперед: вона буває несвіжою, а надсилання
       й саме скаже «недосяжний», якщо телефона поруч немає. */
    let session = WCSession.default
    guard session.activationState == .activated else { throw LinkTrouble.far }
    let t = Words.of(lang)
    guard let audio = try? Data(contentsOf: file), !audio.isEmpty else {
      throw LinkTrouble.failed(t.notHeard)
    }

    let id = UUID().uuidString

    try await withCheckedThrowingContinuation { (next: CheckedContinuation<Void, Error>) in
      session.sendMessage(
        ["audio": audio, "lang": lang, "id": id],
        replyHandler: { reply in
          if let why = reply["error"] as? String {
            next.resume(throwing: LinkTrouble.failed(why))
          } else {
            next.resume()
          }
        },
        errorHandler: { error in
          /* Прострочене «прийняв» це не «далеко». Телефон міг щойно
             прокинутись у фоні і не встигнути відповісти, хоча звук уже в
             нього; тоді слова чекаються далі, як і після «прийняв». */
          if (error as? WCError)?.code == .messageReplyTimedOut {
            next.resume()
          } else {
            next.resume(throwing: Self.trouble(error, t))
          }
        }
      )
    }

    if let result = early.removeValue(forKey: id) { return try result.get() }
    return try await withCheckedThrowingContinuation { next in
      pending[id] = next
      Task { [weak self] in
        try? await Task.sleep(for: Self.patience)
        self?.settle(id, with: .failure(LinkTrouble.failed(t.phoneSilent)))
      }
    }
  }

  /// Один результат на один запис: хто перший, той і відповів.
  private func settle(_ id: String, with result: Result<String, Error>) {
    guard let next = pending.removeValue(forKey: id) else { return }
    next.resume(with: result)
  }

  fileprivate func heard(_ message: [String: Any]) {
    guard let id = message["id"] as? String else { return }
    let result: Result<String, Error>
    if let text = message["heard"] as? String {
      result = .success(text.trimmingCharacters(in: .whitespacesAndNewlines))
    } else {
      result = .failure(LinkTrouble.failed(message["error"] as? String ?? Words.of(lang).notHeard))
    }
    if pending[id] != nil {
      settle(id, with: result)
    } else {
      early[id] = result
    }
  }

  /* Не дістав: для людини це «телефон далеко». Решта помилок каналу лягає в
     «не відповів», бо порада та сама: підійти. */
  private nonisolated static func trouble(_ error: Error, _ t: Words) -> LinkTrouble {
    (error as? WCError)?.code == .notReachable ? .far : .failed(t.phoneSilent)
  }
}

/// Чому телефон не відповів словами.
enum LinkTrouble: Error {
  /// Телефона немає поруч, або він вимкнений.
  case far
  /// Телефон відповів, але не словами: без дозволу, без мови, без мережі.
  case failed(String)
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

  /// Слова, які телефон надіслав окремим повідомленням після «прийняв».
  nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    Task { @MainActor in Link.shared.heard(message) }
  }
}
