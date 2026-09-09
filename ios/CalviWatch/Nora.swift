import Foundation

/// Одна страва так, як її записала Нора.
///
/// `Hashable` не для порівняння страв: без нього не збирається `Step`, бо
/// перелік зі списком страв усередині не вміє порівнювати сам себе, а SwiftUI
/// вимагає цього від стану екрана і від ключа, за яким екран змінюється.
struct Dish: Identifiable, Codable, Hashable {
  let id: String
  let name: String
  let grams: Int
  let kcal: Int
}

/// Що повернулось із сервера на одне продиктоване речення.
struct Answer {
  let dishes: [Dish]
  let balance: Int
}

enum NoraTrouble: Error {
  /// Токенів більше немає: підписка скінчилась або баланс на нулі.
  case dry
  /// Мережі немає. Сказане не пропадає, воно лягає в чергу.
  case offline
  /// Токен більше не годиться: людина вийшла на телефоні або токен протух.
  case stale
  /// Сервер відмовив з іншої причини.
  case refused
}

/// Розмова з Норою з годинника.
///
/// Той самий маршрут, що й у телефона, і та сама позначка «продиктовано»: сервер
/// уже вміє не питати про вагу і брати звичну порцію, тому окремого маршруту під
/// годинник не треба. Один розбір на два пристрої означає, що вони не розійдуться.
enum Nora {
  private static let host = URL(string: "https://calvi.uk")!

  /// Запит на сервер із усім, що телефон шле завжди.
  private static func post(_ path: String, token: String) -> URLRequest {
    var request = URLRequest(url: host.appendingPathComponent(path))
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "content-type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "authorization")

    /* Той самий клієнт, що й телефон, але своя платформа. Сервер рахує
       годинник як iOS у профілі людини, а в панелі показує його час окремою
       плиткою: та сама Нора, але своя дорога до сервера і своє чекання. */
    request.setValue("mobile", forHTTPHeaderField: "x-calvi-client")
    request.setValue("watchos", forHTTPHeaderField: "x-calvi-platform")

    request.timeoutInterval = 30
    return request
  }

  /// Відповідь сервера як JSON, або та сама трійка помилок, що й у чаті.
  private static func send(_ request: URLRequest) async throws -> [String: Any] {
    let data: Data
    let response: URLResponse
    do {
      (data, response) = try await URLSession.shared.data(for: request)
    } catch {
      throw NoraTrouble.offline
    }

    let code = (response as? HTTPURLResponse)?.statusCode ?? 0
    guard code == 200 else {
      /* Сервер каже про порожній баланс окремим кодом. Для людини це не помилка,
         а стан: запис рукою в телефоні працює й далі. Чужий чи протухлий токен
         теж окремо: порада тут «відкрий Calvi на телефоні», а не «спробуй
         пізніше». */
      switch code {
      case 401: throw NoraTrouble.stale
      case 402, 429: throw NoraTrouble.dry
      default: throw NoraTrouble.refused
      }
    }

    guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      throw NoraTrouble.refused
    }
    return json
  }

  /// Записує сказане. `key` живе разом із реченням, а не з запитом: та сама
  /// фраза, надіслана вдруге після обриву, приходить на сервер із тим самим
  /// ключем, і він упізнає її замість того, щоб записати двічі.
  static func say(_ text: String, key: String, token: String, lang: String) async throws -> Answer {
    var request = post("v1/chat", token: token)

    let now = Date()
    let day = DateFormatter()
    day.dateFormat = "yyyy-MM-dd"
    day.locale = Locale(identifier: "en_US_POSIX")

    let body: [String: Any] = [
      "text": text,
      "idempotency_key": key,
      /* Слот за годиною, як і на телефоні. Пізню вечерю чи пізній сніданок
         перейменує сама Нора: це її робота, а не годинника. */
      "slot": slot(at: now),
      "day": day.string(from: now),
      "tz_offset_min": TimeZone.current.secondsFromGMT(for: now) / 60,
      /* Головне поле в цьому запиті. Воно означає «про вагу не питай, бери
         звичну порцію», а без нього Нора почала б діалог, якого на годиннику
         вести нема де. */
      "entry": "voice",
      "lang": lang,
    ]
    request.httpBody = try JSONSerialization.data(withJSONObject: body)

    let json = try await send(request)

    let logged = (json["logged"] as? [[String: Any]] ?? []).map {
      Dish(
        id: $0["id"] as? String ?? UUID().uuidString,
        name: $0["name"] as? String ?? "",
        grams: Int($0["grams"] as? Double ?? 0),
        kcal: Int($0["kcal"] as? Double ?? 0)
      )
    }

    return Answer(dishes: logged, balance: json["balance"] as? Int ?? 0)
  }

  /* Картка за годиною, і правило тут не своє, а телефонне.
   *
   * Своє в мене було зі смугами по годинах, і воно розходилось із застосунком
   * одразу в кількох місцях: о третій дня телефон кладе в перекус, а годинник
   * клав би в обід; об одинадцятій вечора телефон кладе у вечерю, а годинник
   * у перекус. Дві машини, які пишуть в один щоденник за різними правилами, це
   * не дрібниця: людина бачила б їжу не в тій картці й вирішила б, що застосунок
   * плутається.
   *
   * Тому тут `nearestSlot` із `meal.dart` слово в слово: ніч до пів на пʼяту йде
   * в перекус, далі береться картка, чия година найближча до теперішньої.
   * Години карток теж звідти: 8, 13, 19 і 16. */
  private static let hours: [(slot: String, hour: Int)] = [
    ("breakfast", 8), ("lunch", 13), ("dinner", 19), ("snack", 16),
  ]

  private static func slot(at when: Date) -> String {
    let parts = Calendar.current.dateComponents([.hour, .minute], from: when)
    let hour = parts.hour ?? 0
    let minute = parts.minute ?? 0

    /* Ніч закінчується о пів на пʼяту. До того наступний запис іде в перекус:
       за самою годиною найближчою о другій ночі виходив сніданок, і те, що їдять
       уночі, лягало в ранок. */
    if hour * 60 + minute < 4 * 60 + 30 { return "snack" }

    var best = hours[0]
    for one in hours where abs(one.hour - hour) < abs(best.hour - hour) { best = one }
    return best.slot
  }
}

/// Сказане, яке не пішло: лежить на годиннику і чекає на мережу.
///
/// Без черги сказане на пробіжці без звʼязку зникало б разом з екраном, і людина
/// дізнавалась би про це ввечері, дивлячись на порожній день.
enum Queue {
  private static let store = "pending"

  /// Речення разом зі своїм ключем ідемпотентності. Ключ народжується з
  /// реченням і йде з ним у кожну спробу: сервер, який уже записав його, а
  /// відповісти не встиг, побачить той самий ключ і не запише вдруге.
  static var waiting: [(text: String, key: String)] {
    let raw = UserDefaults.standard.array(forKey: store) as? [[String: String]] ?? []
    return raw.compactMap { one in
      guard let text = one["text"], let key = one["key"] else { return nil }
      return (text, key)
    }
  }

  static func add(_ text: String, key: String) {
    var all = UserDefaults.standard.array(forKey: store) as? [[String: String]] ?? []
    all.append(["text": text, "key": key])
    UserDefaults.standard.set(all, forKey: store)
  }

  static func clear() {
    UserDefaults.standard.removeObject(forKey: store)
  }

  /// Пробує віддати все, що чекало. Мовчить, коли чекати нема чого.
  ///
  /// На 401 годинник просить у телефона свіжий токен і йде далі з ним. Черга
  /// зникає лише тоді, коли телефон сказав, що людини більше немає: тоді
  /// годинник уже забув токен, і сказане нікому не належить.
  @MainActor
  static func flush(token: String, lang: String) async {
    let all = waiting
    guard !all.isEmpty else { return }

    var token = token
    var renewed = false
    for one in all {
      do {
        _ = try await Nora.say(one.text, key: one.key, token: token, lang: lang)
      } catch NoraTrouble.stale {
        guard !renewed, let fresh = try? await Link.shared.renew() else {
          if Link.shared.token == nil { clear() }
          return
        }
        renewed = true
        token = fresh
        // Те саме речення з тим самим ключем: сервер не запише його двічі.
        guard (try? await Nora.say(one.text, key: one.key, token: token, lang: lang)) != nil else { return }
      } catch {
        // Мережі досі немає: лишаємо чергу як є і спробуємо наступного разу.
        return
      }
    }
    clear()
  }
}
