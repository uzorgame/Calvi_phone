import AVFoundation
import Foundation
import Speech

/// Слухання на годиннику: свій мікрофон, своє розпізнавання, свій метр.
///
/// Системне диктування Apple було б безкоштовним і не просило б дозволів, але
/// воно малює свій екран посеред нашого застосунку, і виглядає він саме як
/// чужий. Ціна власного екрана в тому, що запис і розпізнавання доводиться
/// вести самим.
@MainActor
final class Ears: NSObject, ObservableObject {
  /// Рівень голосу, від нуля до одиниці. Це і є те, за чим ходить метр.
  @Published private(set) var level: Double = 0

  /// Розпізнане на цю мить. Останнє значення і піде до Нори.
  @Published private(set) var heard: String = ""

  /// Чому не вийшло. Порожньо означає, що все гаразд.
  @Published private(set) var trouble: String?

  private let engine = AVAudioEngine()
  private var recognizer: SFSpeechRecognizer?
  private var request: SFSpeechAudioBufferRecognitionRequest?
  private var task: SFSpeechRecognitionTask?

  /* Мова розпізнавання за мовою застосунку. Таблиця та сама, що на телефоні, і
     тримати її треба разом із тією: телефон із польським застосунком, який
     слухає українською моделлю, повертає кирилицею те, що йому здалося.
     Португальська бразильська навмисно, як і там. */
  private static let locales: [String: String] = [
    "uk": "uk-UA", "en": "en-US", "es": "es-ES", "it": "it-IT",
    "de": "de-DE", "fr": "fr-FR", "pt": "pt-BR", "pl": "pl-PL",
  ]

  /// Локаль для мови застосунку, з відкатом на ту саму мову іншої країни.
  ///
  /// Мова передається двигуну навіть тоді, коли він не назвав її серед своїх:
  /// гірше за спробу тут нічого немає, а локаль годинника це гарантовано не та
  /// мова, якої просили.
  static func locale(for lang: String) -> Locale {
    let want = locales[lang] ?? "en-US"
    let have = SFSpeechRecognizer.supportedLocales().map(\.identifier)

    if have.contains(want) { return Locale(identifier: want) }

    let family = want.split(separator: "-").first.map(String.init) ?? want
    if let near = have.first(where: { $0.hasPrefix(family) }) { return Locale(identifier: near) }

    return Locale(identifier: want)
  }

  /// Питає дозволи і починає слухати. Помилка лягає в [trouble].
  func start(lang: String) async {
    heard = ""
    trouble = nil
    level = 0

    guard await ask() else {
      trouble = "Немає дозволу на мікрофон"
      return
    }

    let locale = Self.locale(for: lang)
    guard let speech = SFSpeechRecognizer(locale: locale), speech.isAvailable else {
      trouble = "Ця мова тут не розпізнається"
      return
    }
    recognizer = speech

    do {
      try listen(with: speech)
    } catch {
      trouble = "Мікрофон не відкрився"
      stop()
    }
  }

  /// Спиняє слухання і віддає почуте. Порожньо означає, що не почули нічого.
  @discardableResult
  func finish() -> String {
    stop()
    return heard.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func ask() async -> Bool {
    let speech = await withCheckedContinuation { go in
      SFSpeechRecognizer.requestAuthorization { go.resume(returning: $0 == .authorized) }
    }
    guard speech else { return false }

    return await withCheckedContinuation { go in
      AVAudioApplication.requestRecordPermission { go.resume(returning: $0) }
    }
  }

  private func listen(with speech: SFSpeechRecognizer) throws {
    let audio = AVAudioSession.sharedInstance()
    /* Без додаткових опцій. `duckOthers` для запису на годиннику зайвий: він
       стосується чужого звуку, а чужого звуку під час диктування і так немає. */
    try audio.setCategory(.record, mode: .measurement)
    try audio.setActive(true, options: .notifyOthersOnDeactivation)

    let ask = SFSpeechAudioBufferRecognitionRequest()
    ask.shouldReportPartialResults = true
    /* Просимо розпізнавати на самому годиннику, якщо він уміє. Не вміє: піде
       через мережу, і це теж робота, просто повільніша. Забороняти мережу не
       можна, бо саме через неї працює більшість мов. */
    ask.requiresOnDeviceRecognition = false
    request = ask

    let input = engine.inputNode
    let format = input.outputFormat(forBus: 0)

    input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
      ask.append(buffer)
      guard let loud = Self.loudness(of: buffer) else { return }
      Task { @MainActor in self?.level = loud }
    }

    engine.prepare()
    try engine.start()

    task = speech.recognitionTask(with: ask) { [weak self] result, error in
      guard let self else { return }
      Task { @MainActor in
        if let words = result?.bestTranscription.formattedString { self.heard = words }
        /* Помилку тут не показуємо: слухання спиняє людина кнопкою, і будь-яка
           зупинка приходить сюди помилкою. Порожнє почуте скаже про це краще. */
        if error != nil, result?.isFinal != true { self.stop() }
      }
    }
  }

  private func stop() {
    engine.inputNode.removeTap(onBus: 0)
    if engine.isRunning { engine.stop() }
    request?.endAudio()
    task?.cancel()
    request = nil
    task = nil
    level = 0
    try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
  }

  /* Гучність пачки як середньоквадратичне.
   *
   * Показник менший за одиницю навмисно: тихе стає помітним, а гучне не
   * впирається в стелю з першого складу. Вухо чує саме так, не лінійно, і метр
   * має ходити за вухом, а не за числом. */
  private nonisolated static func loudness(of buffer: AVAudioPCMBuffer) -> Double? {
    guard let data = buffer.floatChannelData?[0] else { return nil }
    let n = Int(buffer.frameLength)
    guard n > 0 else { return nil }

    var sum: Float = 0
    for i in 0..<n { sum += data[i] * data[i] }
    let rms = Double((sum / Float(n)).squareRoot())

    return min(1, pow(rms * 6.2, 0.72))
  }
}
