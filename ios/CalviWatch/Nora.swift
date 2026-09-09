import Foundation

/// Одна страва так, як її записала Нора.
///
/// `Equatable` не для порівняння страв: без нього не збирається `Step`, бо
/// перелік зі списком страв усередині не вміє порівнювати сам себе, а SwiftUI
/// вимагає цього від стану екрана.
struct Dish: Identifiable, Codable, Equatable {
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

  static func say(_ text: String, token: String, lang: String) async throws -> Answer {
    var request = URLRequest(url: host.appendingPathComponent("v1/chat"))
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "content-type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "authorization")

    /* Ті самі два заголовки, що шле телефон. Без них сервер рахує запит як
       «невідомий клієнт» і без платформи: нічого не ламається, але в панелі
       зʼявляється стовпчик нізвідки, і зростання мобільних виглядає меншим, ніж
       воно є. Окремого значення під годинник поки немає, бо це зміна на сервері;
       коли воно знадобиться, міняти треба буде тут і в `platform.ts`. */
    request.setValue("mobile", forHTTPHeaderField: "x-calvi-client")
    request.setValue("ios", forHTTPHeaderField: "x-calvi-platform")

    request.timeoutInterval = 30

    let now = Date()
    let day = DateFormatter()
    day.dateFormat = "yyyy-MM-dd"
    day.locale = Locale(identifier: "en_US_POSIX")

    let body: [String: Any] = [
      "text": text,
      "idempotency_key": UUID().uuidString,
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
         а стан: запис рукою в телефоні працює й далі. */
      throw code == 402 || code == 429 ? NoraTrouble.dry : NoraTrouble.refused
    }

    guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      throw NoraTrouble.refused
    }

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
  private static let key = "pending"

  static var waiting: [String] {
    UserDefaults.standard.stringArray(forKey: key) ?? []
  }

  static func add(_ text: String) {
    var all = waiting
    all.append(text)
    UserDefaults.standard.set(all, forKey: key)
  }

  static func clear() {
    UserDefaults.standard.removeObject(forKey: key)
  }

  /// Пробує віддати все, що чекало. Мовчить, коли чекати нема чого.
  static func flush(token: String, lang: String) async {
    let all = waiting
    guard !all.isEmpty else { return }

    for text in all {
      do {
        _ = try await Nora.say(text, token: token, lang: lang)
      } catch {
        // Мережі досі немає: лишаємо чергу як є і спробуємо наступного разу.
        return
      }
    }
    clear()
  }
}
