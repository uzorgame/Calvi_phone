/* Одна крамниця з погляду застосунку: як зветься і яким ключем до неї стукати.
 *
 * Крамниць дві, Apple і Google, і кожна живе у своєму файлі поруч:
 * `apple_store.dart` і `google_store.dart`. Ключі, назви товарів і особливості
 * в них різні, а в одному файлі вони плутались. Тут тільки форма, спільна для
 * обох; вибір крамниці за платформою робить `Billing`. */
class StoreConfig {
  const StoreConfig({required this.name, required this.key});

  /// Для журналу: «App Store», «Google Play».
  final String name;

  /// Публічний ключ SDK RevenueCat цієї крамниці. Порожньо означає «крамниця
  /// ще не підключена»: оплата тихо вимкнена, застосунок працює щоденником, а
  /// екран підписки показує сторінку без цін.
  final String key;

  bool get ready => key.isNotEmpty;
}

/// Платформа без крамниці: веб і все, чого ми не знаємо.
const noStore = StoreConfig(name: '', key: '');
