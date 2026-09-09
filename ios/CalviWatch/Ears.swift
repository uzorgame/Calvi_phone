import AVFoundation
import Foundation

/// Мікрофон годинника: пише сказане у файл і показує рівень, поки людина
/// говорить.
///
/// **Тут не розпізнається нічого.** На watchOS немає `Speech`, а вбудована
/// диктовка приносить свій екран замість нашого. Тому годинник записує звук,
/// а слова з нього робить телефон поруч, тим самим розпізнавачем і тією самою
/// мовою, що й диктовка в застосунку: як і телефон, годинник чує тільки її.
///
/// Рівень для метра береться з самого запису (`averagePower`), а не з другого
/// входу: мікрофон один, і два слухачі на ньому заважали б один одному.
@MainActor
final class Ears: NSObject, ObservableObject {
  /// Гучність зараз, від 0 до 1. Метр читає її кожні пʼятдесят мілісекунд.
  @Published private(set) var level: Double = 0

  /// Чому не вийшло почати. Порожньо означає «слухаю».
  @Published private(set) var trouble: String?

  private var recorder: AVAudioRecorder?
  private var meter: Timer?
  private var file: URL?

  /* Стиснутий AAC, моно, 16 кГц, 24 кбіт/с: речення про обід це кілька
     десятків кілобайт. Межа має значення: одне повідомлення на телефон несе не
     більше за 64 кілобайти, і пʼятнадцять секунд на цій швидкості вміщаються
     із запасом. */
  private static let settings: [String: Any] = [
    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
    AVSampleRateKey: 16_000,
    AVNumberOfChannelsKey: 1,
    AVEncoderBitRateKey: 24_000,
    AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
  ]

  /// Стеля запису. Довше за це не скажеш про одну їжу, а файл переріс би
  /// повідомлення.
  private static let longest: TimeInterval = 15

  func start() async {
    trouble = nil
    level = 0

    guard await AVAudioApplication.requestRecordPermission() else {
      trouble = "Дозволь мікрофон у налаштуваннях"
      return
    }

    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.record, mode: .measurement, options: [])
      try session.setActive(true)

      let url = FileManager.default.temporaryDirectory.appendingPathComponent("said.m4a")
      try? FileManager.default.removeItem(at: url)

      let r = try AVAudioRecorder(url: url, settings: Self.settings)
      r.isMeteringEnabled = true
      guard r.record(forDuration: Self.longest) else {
        trouble = "Мікрофон не відповів"
        return
      }
      recorder = r
      file = url

      meter = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
        Task { @MainActor in self?.tick() }
      }
    } catch {
      trouble = "Мікрофон не відповів"
    }
  }

  private func tick() {
    guard let r = recorder else { return }
    r.updateMeters()
    /* Децибели від -160 до 0 переводяться в лінійну гучність, а та стискається
       так само, як на телефоні: тихий голос уже видно, крик не впирається в
       стелю. */
    let linear = pow(10, Double(r.averagePower(forChannel: 0)) / 20)
    level = min(1, pow(linear * 6.2, 0.72))
  }

  /// Зупиняє запис і віддає файл. Порожньо, коли запису не було.
  func finish() -> URL? {
    meter?.invalidate()
    meter = nil
    level = 0

    guard let r = recorder else { return nil }
    r.stop()
    recorder = nil
    try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    return file
  }
}
