import AVFoundation
import Flutter
import Speech
import UIKit
import WatchConnectivity

/// Міст до годинника: телефон каже, годинник слухає, і один раз питає.
///
/// Телефон тримає годинник у курсі токена, мови і сьогоднішніх чисел через
/// `updateApplicationContext`: контекст один, він заміняє попередній і доїжджає
/// навіть тоді, коли годинниковий застосунок не запущений. Порожній токен у
/// контексті означає вихід з акаунта: годинник забуває людину тієї ж миті.
///
/// Єдине, про що годинник питає телефон, це слова зі звуку. На watchOS немає
/// розпізнавача, яким користується диктовка в застосунку, а вбудована диктовка
/// приносить свій екран. Тому годинник записує сказане і шле сюди, а телефон
/// розпізнає тим самим розпізнавачем Apple, що й у диктовці, тією самою мовою,
/// що стоїть у застосунку. Застосунок для цього відкривати не треба: iOS сама
/// підіймає його у фоні на кілька секунд, коли годинник надсилає повідомлення,
/// і телефон може лишатись заблокованим. Потрібно лише, щоб він був поруч.
final class WatchBridge: NSObject {
  private let session: WCSession?

  override init() {
    session = WCSession.isSupported() ? WCSession.default : nil
    super.init()
    session?.delegate = self
    session?.activate()
  }

  /// Підключає канал до Dart. Робиться один раз, при старті застосунку з
  /// екраном. Сесія до цього моменту вже жива: її піднімає `init`, і в
  /// фоновому запуску заради звуку з годинника канал не потрібен зовсім.
  func attach(to messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "calvi/watch", binaryMessenger: messenger)

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterMethodNotImplemented)
        return
      }
      switch call.method {
      case "tell":
        guard let args = call.arguments as? [String: Any] else {
          result(FlutterMethodNotImplemented)
          return
        }
        self.tell(args)
        result(nil)
      case "status":
        result(self.status())
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func tell(_ state: [String: Any]) {
    guard let session, session.activationState == .activated else { return }

    /* Пари годиннику може не бути взагалі, і це звичайний випадок, а не збій:
       більшість людей ходить без нього. Кидати сюди помилку в Dart означало б
       лякати телефон тим, що його не стосується. */
    guard session.isPaired, session.isWatchAppInstalled else { return }

    /* Сесія і адреса сервера лишаються на телефоні. Годиннику вони не
       потрібні, а мосту потрібні: за ними він бере свіжий токен, коли годинник
       про це просить, і застосунок для цього відкривати не треба. */
    var context = state
    if let refresh = context.removeValue(forKey: "refresh") as? String {
      Renewal.keep(refresh: refresh)
    }
    if let api = context.removeValue(forKey: "api") as? String {
      Renewal.keep(api: api)
    }

    if let told = context["token"] as? String {
      if told.isEmpty {
        // Вихід з акаунта: сесія цієї людини мосту більше не належить.
        Renewal.forget()
      } else if let newer = Renewal.newer(than: told) {
        /* Токен, оновлений тут для годинника, свіжіший за той, що Dart ще
           тримає. Старий пішов би на годинник і зустрів 401 без причини. */
        context["token"] = newer
      }
    }

    do {
      try session.updateApplicationContext(context)
    } catch {
      /* Контекст не пішов. Наступна зміна дня надішле новий, а старий нікому не
         потрібен: там ті самі поля, тільки застарілі. */
      NSLog("watch: контекст не пішов, \(error.localizedDescription)")
    }
  }

  /// Що телефон знає про годинник, для рядка в налаштуваннях.
  ///
  /// «Актуальний» означає, що останній контекст ліг у канал: далі його доставить
  /// система, навіть якщо годинник зараз спить.
  private func status() -> [String: Any] {
    guard let session, session.activationState == .activated else {
      return ["paired": false, "installed": false, "current": false]
    }
    return [
      "paired": session.isPaired,
      "installed": session.isWatchAppInstalled,
      "current": !session.applicationContext.isEmpty,
    ]
  }
}

extension WatchBridge: WCSessionDelegate {
  func session(
    _ session: WCSession,
    activationDidCompleteWith state: WCSessionActivationState,
    error: Error?
  ) {}

  /* Обидва обовʼязкові на iOS і потрібні для однієї речі: коли людина
     перемикається на інший годинник, сесію треба підняти заново, інакше
     наступний контекст піде в нікуди. */
  func sessionDidBecomeInactive(_ session: WCSession) {}

  func sessionDidDeactivate(_ session: WCSession) {
    session.activate()
  }

  /// Звук із годинника.
  ///
  /// Відповідь на саме повідомлення це лише «прийняв», і йде вона одразу: канал
  /// чекає на неї лічені секунди, а холодний старт у фоні разом із
  /// розпізнаванням у них не завжди вкладається. Слова їдуть назад окремим
  /// повідомленням із тим самим номером, і на них годинник чекає стільки,
  /// скільки сам вирішив.
  func session(
    _ session: WCSession,
    didReceiveMessage message: [String: Any],
    replyHandler: @escaping ([String: Any]) -> Void
  ) {
    /* Годинник отримав 401 і просить свіжий токен. Телефон бере його за своєю
       сесією, кладе в контекст, щоб годинник мав його і після перезапуску, і
       відповідає ним же. «Сесії немає» означає вихід або зниклий акаунт:
       годинник на це забуває людину. */
    if message["renew"] != nil {
      var task = UIBackgroundTaskIdentifier.invalid
      task = UIApplication.shared.beginBackgroundTask {
        UIApplication.shared.endBackgroundTask(task)
        task = .invalid
      }
      Renewal.fresh { outcome in
        switch outcome {
        case .success(let token):
          var context = session.applicationContext
          context["token"] = token
          try? session.updateApplicationContext(context)
          replyHandler(["token": token])
        case .failure(.dead):
          replyHandler(["dead": true])
        case .failure(.offline):
          replyHandler(["offline": true])
        }
        if task != .invalid {
          UIApplication.shared.endBackgroundTask(task)
          task = .invalid
        }
      }
      return
    }

    let lang = message["lang"] as? String ?? "en"
    guard let audio = message["audio"] as? Data, !audio.isEmpty else {
      replyHandler(["error": Hearing.say(.notHeard, lang)])
      return
    }
    let id = message["id"] as? String ?? ""
    replyHandler(["ack": true])

    DispatchQueue.main.async {
      Hearing.transcribe(audio, lang: lang) { outcome in
        var back = outcome
        back["id"] = id
        session.sendMessage(back, replyHandler: nil) { error in
          // Годинник уже не в руці: слова нікому, і це не помилка телефона.
          NSLog("watch: слова не пішли, \(error.localizedDescription)")
        }
      }
    }
  }
}

/// Слова зі звуку, тим самим розпізнавачем і тією самою мовою, що в диктовці.
enum Hearing {
  /* Та сама таблиця, що в `dictation.dart`: мова застосунку і локаль
     розпізнавача. Розійтись їм не можна: тоді телефон і годинник чули б
     одну мову по-різному. */
  private static let locales: [String: String] = [
    "uk": "uk-UA", "en": "en-US", "es": "es-ES", "it": "it-IT",
    "de": "de-DE", "fr": "fr-FR", "pt": "pt-BR", "pl": "pl-PL",
    "cs": "cs-CZ", "ru": "ru-RU",
    /* Білоруську розпізнавач Apple не знає. Рядок тут потрібен усе одно:
       без нього мова падала б в англійську і телефон чув би зовсім не те,
       а так він чесно скаже, що цією мовою не вміє, і годинник у
       замкненому телефоні піде на сервер, де вона є. */
    "be": "be-BY",
  ]

  /// Що телефон відповідає годиннику словами. Мовою застосунку, як і сам
  /// годинник: помилка українською на англійському екрані читалась би як збій.
  enum Reply { case notHeard, needSpeech, noNetwork, noLanguage, locked }

  static func say(_ what: Reply, _ lang: String) -> String {
    let table: [String: [Reply: String]] = [
      "uk": [
        .notHeard: "Не почула. Скажи ще раз",
        .needSpeech: "На телефоні: Calvi, Налаштування, Доступ, увімкни розпізнавання мовлення",
        .noNetwork: "Відсутнє підключення до мережі",
        .noLanguage: "Розпізнавання цією мовою недоступне",
        .locked: "Розблокуй телефон і скажи ще раз",
      ],
      "en": [
        .notHeard: "Did not catch that. Say it again",
        .needSpeech: "On the phone: Calvi, Settings, Access, turn on speech recognition",
        .noNetwork: "No network connection",
        .noLanguage: "Recognition is not available in this language",
        .locked: "Unlock the phone and say it again",
      ],
      "es": [
        .notHeard: "No te oí. Dilo otra vez",
        .needSpeech: "En el teléfono: Calvi, Ajustes, Acceso, activa el reconocimiento de voz",
        .noNetwork: "Sin conexión de red",
        .noLanguage: "El reconocimiento no está disponible en este idioma",
        .locked: "Desbloquea el teléfono y dilo otra vez",
      ],
      "it": [
        .notHeard: "Non ho sentito. Ripeti",
        .needSpeech: "Sul telefono: Calvi, Impostazioni, Accesso, attiva il riconoscimento vocale",
        .noNetwork: "Nessuna connessione di rete",
        .noLanguage: "Il riconoscimento non è disponibile in questa lingua",
        .locked: "Sblocca il telefono e ripeti",
      ],
      "de": [
        .notHeard: "Nicht verstanden. Sag es noch einmal",
        .needSpeech: "Am Telefon: Calvi, Einstellungen, Zugriff, Spracherkennung einschalten",
        .noNetwork: "Keine Netzverbindung",
        .noLanguage: "Erkennung in dieser Sprache nicht verfügbar",
        .locked: "Entsperre das Telefon und sag es noch einmal",
      ],
      "fr": [
        .notHeard: "Je n’ai pas entendu. Répète",
        .needSpeech: "Sur le téléphone : Calvi, Réglages, Accès, active la reconnaissance vocale",
        .noNetwork: "Pas de connexion réseau",
        .noLanguage: "La reconnaissance n’est pas disponible dans cette langue",
        .locked: "Déverrouille le téléphone et répète",
      ],
      "pt": [
        .notHeard: "Não ouvi. Diga de novo",
        .needSpeech: "No telefone: Calvi, Ajustes, Acesso, ative o reconhecimento de fala",
        .noNetwork: "Sem conexão de rede",
        .noLanguage: "Reconhecimento indisponível neste idioma",
        .locked: "Desbloqueie o telefone e diga de novo",
      ],
      "pl": [
        .notHeard: "Nie usłyszałam. Powtórz",
        .needSpeech: "W telefonie: Calvi, Ustawienia, Dostęp, włącz rozpoznawanie mowy",
        .noNetwork: "Brak połączenia z siecią",
        .noLanguage: "Rozpoznawanie niedostępne w tym języku",
        .locked: "Odblokuj telefon i powtórz",
      ],
      "cs": [
        .notHeard: "Neslyšela jsem. Řekni to znovu",
        .needSpeech: "V telefonu: Calvi, Nastavení, Přístupy, zapni rozpoznávání řeči",
        .noNetwork: "Není připojení k síti",
        .noLanguage: "Rozpoznávání není v tomto jazyce dostupné",
        .locked: "Odemkni telefon a řekni to znovu",
      ],
      "ru": [
        .notHeard: "Не услышала. Скажи ещё раз",
        .needSpeech: "На телефоне: Calvi, Настройки, Доступ, включи распознавание речи",
        .noNetwork: "Нет подключения к сети",
        .noLanguage: "Распознавание на этом языке недоступно",
        .locked: "Разблокируй телефон и скажи ещё раз",
      ],
      "be": [
        .notHeard: "Не пачула. Скажы яшчэ раз",
        .needSpeech: "У тэлефоне: Calvi, Налады, Доступ, уключы распазнаванне маўлення",
        .noNetwork: "Няма падлучэння да сеткі",
        .noLanguage: "Распазнаванне на гэтай мове недаступнае",
        .locked: "Разблакуй тэлефон і скажы яшчэ раз",
      ],
    ]
    return (table[lang] ?? table["en"]!)[what]!
  }

  /// Той самий запис, підтягнутий до нормальної гучності. Мікрофон годинника
  /// тихий, і розпізнавач на тихому файлі відповідав «нічого не сказано».
  /// Найгучніший відлік стає -1 дБ; запис, який і так гучний, лишається як є.
  /// Порожньо, коли файл не прочитався: тоді хай розпізнавач пробує сирий.
  /* Що телефон побачив у записі: пік і тривалість. Іде на годинник дрібним
     рядком під помилкою, бо інакше «не почула» не каже, де саме обірвалось:
     у мікрофоні годинника, у файлі чи в розпізнавачі. Слів тут немає. */
  private static var stats = "no audio"

  private static func louder(_ url: URL) -> URL? {
    stats = "no audio"
    guard let input = try? AVAudioFile(forReading: url) else { return nil }
    let format = input.processingFormat
    guard
      input.length > 0,
      let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(input.length)),
      (try? input.read(into: buffer)) != nil,
      let channels = buffer.floatChannelData,
      buffer.frameLength > 0
    else { return nil }

    let frames = Int(buffer.frameLength)
    let count = Int(format.channelCount)
    var peak: Float = 0
    for c in 0..<count {
      let samples = channels[c]
      for i in 0..<frames { peak = max(peak, abs(samples[i])) }
    }
    stats = String(format: "peak %.2f · %.1fs", peak, Double(frames) / format.sampleRate)
    // Тиша не підсилюється: із шуму слів не зробиш, а стелю він продавив би.
    guard peak > 0.001 else { return nil }
    if peak > 0.5 { return url }

    // Не більше за тридцять разів: далі це вже шум, а не голос.
    let gain = min(0.9 / peak, 30)
    for c in 0..<count {
      let samples = channels[c]
      for i in 0..<frames { samples[i] *= gain }
    }

    /* Звичайний WAV, 16 біт, канали впереміш: найпростіший формат, який
       читає будь-що. Налаштування буфера з плавучою комою й роздільними
       каналами для файлу не годяться, файл їх може не прийняти. */
    let out = url.deletingPathExtension().appendingPathExtension("wav")
    let settings: [String: Any] = [
      AVFormatIDKey: Int(kAudioFormatLinearPCM),
      AVSampleRateKey: format.sampleRate,
      AVNumberOfChannelsKey: Int(format.channelCount),
      AVLinearPCMBitDepthKey: 16,
      AVLinearPCMIsFloatKey: false,
      AVLinearPCMIsBigEndianKey: false,
      AVLinearPCMIsNonInterleaved: false,
    ]
    guard
      let output = try? AVAudioFile(
        forWriting: out, settings: settings, commonFormat: .pcmFormatFloat32, interleaved: false),
      (try? output.write(from: buffer)) != nil
    else { return nil }
    return out
  }

  static func transcribe(_ audio: Data, lang: String, done: @escaping ([String: Any]) -> Void) {
    /* Дозвіл уже є: його просила диктовка в застосунку або екран «Доступ», і
       це той самий дозвіл. Просити тут не можна, бо застосунок може бути
       піднятий у фоні, де вікна з питанням нема кому показати. */
    guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
      /* Дозволу ще немає, і просити його з фону нема кому. Але звук уже є, і
         сервер чує без жодних дозволів на телефоні: годинник іде туди, а
         порада про «Доступ» лишається на випадок, коли й сервер не почув.
         Так перший запуск працює одразу, а не після походу в налаштування. */
      done(["error": say(.needSpeech, lang), "fallback": true])
      return
    }

    /* Заблокований телефон. Розпізнавач Apple через мережу на ньому відмовляє,
       і годинник чув «не почула» на кожне слово, хоч телефон усе отримав.
       Прапорець системи каже саме про замок: він гасне, щойно екран замкнувся.
       Відповідь із позначкою «замкнений» веде годинник на сервер, а слова в
       ній лишаються на випадок, коли й сервер не чує. */
    let locked = !UIApplication.shared.isProtectedDataAvailable
    let lockedReply: [String: Any] = ["locked": true, "error": say(.locked, lang)]

    // Замок на мові: розпізнавач саме цієї локалі, а не «яку почує».
    let id = locales[lang] ?? "en-US"
    guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: id)) else {
      done(locked ? lockedReply : ["error": say(.noLanguage, lang)])
      return
    }
    /* Розпізнавач Apple працює через мережу, і «недоступний» майже завжди
       означає, що телефон без неї. Так і кажемо, а не «мова недоступна».
       Під замком він теж буває «недоступний», і тоді відповідь та сама, що
       для замка: годинник має піти на сервер, а не чути «немає мережі». */
    guard recognizer.isAvailable else {
      done(locked ? lockedReply : ["error": say(.noNetwork, lang)])
      return
    }

    let file = FileManager.default.temporaryDirectory.appendingPathComponent("watch-\(UUID().uuidString).m4a")
    do {
      try audio.write(to: file)
    } catch {
      done(["error": say(.notHeard, lang)])
      return
    }

    /* Застосунок могли підняти у фоні рівно заради цього повідомлення, і iOS
       дає йому лічені секунди. Фонова задача просить ще трохи, щоб відповідь
       устигла піти назад на годинник. */
    var task = UIBackgroundTaskIdentifier.invalid
    task = UIApplication.shared.beginBackgroundTask {
      UIApplication.shared.endBackgroundTask(task)
      task = .invalid
    }

    let source = louder(file) ?? file
    let request = SFSpeechURLRecognitionRequest(url: source)
    request.shouldReportPartialResults = false
    request.taskHint = .dictation

    var answered = false
    let finish: ([String: Any]) -> Void = { reply in
      guard !answered else { return }
      answered = true
      try? FileManager.default.removeItem(at: file)
      try? FileManager.default.removeItem(at: source)
      done(reply)
      if task != .invalid {
        UIApplication.shared.endBackgroundTask(task)
        task = .invalid
      }
    }

    /* На замкненому телефоні лишається розпізнавання на самому пристрої, без
       мережі: воно не ходить до служби, яка відмовляє під замком. Є воно не
       для кожної мови, і тоді чесна порада одна: розблокувати й повторити. */
    /* Разом зі словами йде позначка «замкнений»: годинник тоді шле звук на
       сервер, а слова лишає на випадок, коли сервер не чує. */
    if locked {
      guard recognizer.supportsOnDeviceRecognition else {
        finish(lockedReply)
        return
      }
      request.requiresOnDeviceRecognition = true
    }

    recognizer.recognitionTask(with: request) { result, error in
      if let result, result.isFinal {
        let text = result.bestTranscription.formattedString
        var back: [String: Any] = ["heard": text]
        if text.isEmpty {
          back["note"] = "\(locked ? "L" : "U") · \(stats) · empty"
          // Порожньо від Apple ще не означає тишу: хай спробує сервер.
          back["fallback"] = true
        }
        finish(back)
      } else if let error {
        /* Причина лишається в журналі телефона, а годиннику йде одна з трьох:
           замок, коли телефон замкнений, мережа, коли впала вона, інакше «не
           почула». Тиша, шум і не та мова для годинника одне й те саме. */
        NSLog("watch: розпізнавання не вдалось, \(error)")
        let network = (error as NSError).domain == NSURLErrorDomain
        var back: [String: Any] = ["error": say(locked ? .locked : network ? .noNetwork : .notHeard, lang)]
        if locked { back["locked"] = true }
        /* Будь-яка відмова розпізнавача, крім мережі, це привід для годинника
           спробувати сервер: він не залежить від замка, від стану застосунку і
           від того, що саме не сподобалось Apple у файлі. Слова лишаються на
           випадок, коли й сервер не почує. */
        if !network { back["fallback"] = true }
        let e = error as NSError
        back["note"] = "\(locked ? "L" : "U") · \(stats) · \(e.domain) \(e.code)"
        finish(back)
      }
    }
  }
}

/// Свіжий токен доступу для годинника, за сесією телефона.
///
/// Токен доступу живе тридцять днів, сесія рік. Годинник, який зустрів 401,
/// просить телефон, а не показує вхід: телефон бере новий токен за сесією тут,
/// у рідному коді, тому це працює і з закритим застосунком, у фоні, куди iOS
/// підіймає його заради повідомлення. Сесія і адреса сервера лежать у
/// сховищі застосунку, там само, де й база з тією самою сесією.
enum Renewal {
  enum Failure: Error {
    /// Сесії більше немає: вихід, відкликання або видалення акаунта.
    case dead
    /// Мережі немає або сервер не відповів: спробувати можна пізніше.
    case offline
  }

  private static let disk = UserDefaults.standard
  private static let refreshKey = "calvi.watch.refresh"
  private static let apiKey = "calvi.watch.api"
  private static let renewedKey = "calvi.watch.renewed"

  static func keep(refresh: String) { disk.set(refresh, forKey: refreshKey) }
  static func keep(api: String) { disk.set(api, forKey: apiKey) }

  static func forget() {
    disk.removeObject(forKey: refreshKey)
    disk.removeObject(forKey: renewedKey)
  }

  /// Токен, оновлений тут, якщо він молодший за той, що приніс Dart.
  static func newer(than token: String) -> String? {
    guard let mine = disk.string(forKey: renewedKey), mine != token else { return nil }
    guard let a = issued(mine), let b = issued(token), a > b else { return nil }
    return mine
  }

  /// Коли токен підписано, з його ж тіла. Порожньо для будь-чого, що не JWT.
  private static func issued(_ jwt: String) -> Int? {
    let parts = jwt.split(separator: ".")
    guard parts.count == 3 else { return nil }
    var raw = String(parts[1]).replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
    while raw.count % 4 != 0 { raw += "=" }
    guard
      let data = Data(base64Encoded: raw),
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else { return nil }
    return json["iat"] as? Int
  }

  static func fresh(_ done: @escaping (Result<String, Failure>) -> Void) {
    guard
      let refresh = disk.string(forKey: refreshKey),
      let api = disk.string(forKey: apiKey),
      let url = URL(string: api)?.appendingPathComponent("v1/auth/refresh")
    else {
      done(.failure(.dead))
      return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("phone", forHTTPHeaderField: "X-Calvi-Client")
    request.httpBody = try? JSONSerialization.data(withJSONObject: ["refresh_token": refresh])
    request.timeoutInterval = 15

    URLSession.shared.dataTask(with: request) { data, response, _ in
      let code = (response as? HTTPURLResponse)?.statusCode ?? 0
      if code == 401 {
        done(.failure(.dead))
        return
      }
      guard
        code == 200,
        let data,
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
        let token = json["access_token"] as? String,
        !token.isEmpty
      else {
        done(.failure(.offline))
        return
      }
      disk.set(token, forKey: renewedKey)
      done(.success(token))
    }.resume()
  }
}
