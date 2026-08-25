import AudioToolbox
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  /* Готові до відтворення звуки, за іменем файла.
   *
   * Створення коштує читання файла з диска, а звук грається на дотик пальця,
   * тобто в найгіршу для цього мить. Ідентифікатори живуть скільки й застосунок:
   * їх два, вони крихітні, і звільняти тут нічого. */
  private var sounds: [String: SystemSoundID] = [:]

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    /* Службові звуки початку і кінця запису голосу.
     *
     * Тільки тут, бо на Android їх грає сама система розпізнавання, а на iOS
     * `SFSpeechRecognizer` не грає нічого.
     *
     * `AudioServicesPlaySystemSound`, а не програвач: під час диктування
     * аудіосесія стоїть у режимі запису, і програвач став би її
     * переналаштовувати рівно тієї миті, коли мікрофон вмикається або щойно
     * вимкнувся. Системний виклик у сесію не лізе, він для коротких службових
     * сигналів і зроблений, і сам мовчить, коли телефон у беззвучному режимі. */
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "calvi/earcon",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "play", let name = call.arguments as? String else {
          result(FlutterMethodNotImplemented)
          return
        }
        self?.play(named: name, in: controller)
        result(nil)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func play(named name: String, in controller: FlutterViewController) {
    if let ready = sounds[name] {
      AudioServicesPlaySystemSound(ready)
      return
    }

    /* Шлях питається у Flutter, а не пишеться руками. Ресурси Flutter лежать у
       зібраному застосунку не там, де в проєкті, і будь-який зашитий шлях
       розійшовся б із дійсністю на першій же зміні складання. */
    let key = controller.lookupKey(forAsset: "assets/sounds/\(name).wav")
    guard let path = Bundle.main.path(forResource: key, ofType: nil) else { return }

    var id: SystemSoundID = 0
    let url = URL(fileURLWithPath: path) as CFURL
    guard AudioServicesCreateSystemSoundID(url, &id) == kAudioServicesNoError else { return }

    sounds[name] = id
    AudioServicesPlaySystemSound(id)
  }
}
