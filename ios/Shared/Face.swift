import Foundation
import Security

/// Залишок дня для ускладнення на циферблаті.
///
/// Ускладнення живе в окремому розширенні, а розширення не бачить сховища
/// застосунку. Спільного між ними два: група застосунків і ланцюжок ключів.
/// Група вимагає окремої здатності на ідентифікаторі в порталі Apple, а
/// ланцюжок працює з одним рядком у правах обох цілей: група `keychain-access-
/// groups` під префіксом команди входить у кожен профіль сама собою.
///
/// Файл один на застосунок і розширення: `watch_target.rb` кладе його в обидві
/// цілі, і те, що пише одна, читає друга.
enum Face {
  struct State: Codable {
    var left: Int
    var norm: Int
  }

  private static let service = "calvi.face"

  private static var query: [String: Any] {
    [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
    ]
  }

  /// Пише стан для циферблата. Група не вказується навмисно: без неї запис іде
  /// в першу групу з прав цілі, і в обох цілей першою стоїть та сама.
  static func write(_ state: State) {
    guard let data = try? JSONEncoder().encode(state) else { return }
    SecItemDelete(query as CFDictionary)
    var add = query
    add[kSecValueData as String] = data
    // Ускладнення оновлюється й тоді, коли годинник на руці, але екран спить.
    add[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
    SecItemAdd(add as CFDictionary, nil)
  }

  static func read() -> State? {
    var ask = query
    ask[kSecReturnData as String] = true
    ask[kSecMatchLimit as String] = kSecMatchLimitOne
    var out: CFTypeRef?
    guard SecItemCopyMatching(ask as CFDictionary, &out) == errSecSuccess, let data = out as? Data else {
      return nil
    }
    return try? JSONDecoder().decode(State.self, from: data)
  }

  /// Вихід з акаунта: циферблат більше нічого не знає.
  static func clear() {
    SecItemDelete(query as CFDictionary)
  }
}
