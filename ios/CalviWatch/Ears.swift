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

  /// Скільки з відведеного часу минуло, від 0 до 1. Смужка під «Слухаю…».
  @Published private(set) var elapsed: Double = 0

  /// Запис дійшов до стелі й зупинився сам. Екран на це відповідає так, ніби
  /// натиснули «Готово»: мовчазна зупинка означала б, що людина говорить у
  /// вимкнений мікрофон і не знає про це.
  @Published private(set) var ended = false

  /// Чому не вийшло почати. Порожньо означає «слухаю».
  @Published private(set) var trouble: String?

  private var recorder: AVAudioRecorder?
  private var meter: Timer?
  private var file: URL?

  /* Стиснутий AAC, моно, 16 кГц, 20 кбіт/с: речення про обід це кілька
     десятків кілобайт. Межа має значення: одне повідомлення на телефон несе не
     більше за 64 кілобайти, і двадцять секунд на цій швидкості дають п'ятдесят,
     із запасом на заголовок файлу. */
  private static let settings: [String: Any] = [
    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
    AVSampleRateKey: 16_000,
    AVNumberOfChannelsKey: 1,
    AVEncoderBitRateKey: 20_000,
    AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
  ]

  /// Стеля запису. Довше за це не скажеш про одну їжу, а файл переріс би
  /// повідомлення.
  static let longest: TimeInterval = 20

  /// `lang` лише для слів помилок: мова застосунку на телефоні.
  func start(lang: String) async {
    let t = Words.of(lang)
    trouble = nil
    level = 0
    elapsed = 0
    ended = false

    guard await AVAudioApplication.requestRecordPermission() else {
      trouble = t.micDenied
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
      r.delegate = self
      guard r.record(forDuration: Self.longest) else {
        trouble = t.micFailed
        return
      }
      recorder = r
      file = url

      meter = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
        Task { @MainActor in self?.tick() }
      }
    } catch {
      trouble = t.micFailed
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
    elapsed = min(1, r.currentTime / Self.longest)
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

extension Ears: AVAudioRecorderDelegate {
  /* Стеля спрацювала. Приходить із чужого потоку, тому назад на головний. */
  nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    Task { @MainActor in
      guard self.recorder != nil else { return }
      self.elapsed = 1
      self.ended = true
    }
  }
}
