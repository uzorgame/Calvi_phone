import AVKit
import SwiftUI
import WatchKit

@main
struct CalviWatchApp: App {
  var body: some Scene {
    WindowGroup {
      Watch()
    }
  }
}

/// Де зараз стоїть застосунок. Кожен стан це один екран і нічого більше.
enum Step: Hashable {
  case idle
  case hearing
  case analysing(String)
  case done([Dish])
  case dry
  /// Сказане чекає на мережу; слова на екрані, щоб було видно, що саме чекає.
  case queued(String)
  case trouble(String)
}

/// Годинниковий Calvi цілком: одна кнопка і те, що з неї виходить.
///
/// Макет це прототип 5200, і всі розміри тут його частки від ширини екрана:
/// кільце 0.62, шапка 0.081, картка 0.071. Полотно прототипу 396 пікселів, а
/// екран годинника 198 пунктів, і саме частки роблять їх одним малюнком.
struct Watch: View {
  @StateObject private var link = Link.shared
  @StateObject private var ears = Ears()
  @State private var step: Step = .idle

  /* Скільки записів людина вже зробила. Похвала рахується від нього, а не від
     випадку: слово, яке чуєш щоразу, перестає бути словом. */
  @AppStorage("logs") private var logs = 0

  /// Ширина екрана в пунктах. Від неї рахується все, що має форму.
  private var w: CGFloat { WKInterfaceDevice.current().screenBounds.width }

  /// Слова мовою застосунку на телефоні, а не системною мовою годинника.
  private var t: Words { Words.of(link.lang) }

  var body: some View {
    VStack(spacing: 0) {
      Bar()
      screen(for: step)
        /* Кожен екран приходить, як у прототипі: із прозорості, трохи знизу
           і трохи меншим. Ключ по стану навмисно: екран народжується заново,
           і разом із ним заново програються всі появи всередині. */
        .id(step)
        .transition(.opacity.combined(with: .offset(y: w * 0.03)).combined(with: .scale(scale: 0.965)))
    }
    .animation(Motion.ease(0.34), value: step)
    /* Від верху, а не по центру. Без цього рядка стос розміром із вміст стояв
       посеред екрана, шапка «падала» на третину вниз, а розпірки всередині
       екранів не мали чого розпирати. */
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    /* Поля з макета 5200: зверху менше, знизу більше, з боків найширше, бо кут
       екрана заокруглений і текст урівень із краєм підрізається склом. */
    .padding(.top, w * 0.075)
    .padding(.horizontal, w * 0.085)
    .padding(.bottom, w * 0.095)
    .ignoresSafeArea(edges: .top)
    .background(Palette.ground.ignoresSafeArea())
    /* Системний годинник watchOS білий і на світлому тлі невидимий, а свій час
       у шапці вже є. Штатного способу сховати системний немає; невидимий
       програвач відео змушує watchOS прибрати його самому, бо під відео час не
       показують. */
    .background(
      VideoPlayer(player: nil)
        .opacity(0)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    )
    /* Черга віддається тоді, коли зʼявився токен, а не тільки на відкритті.
     *
     * Доти це стояло в `task` без ключа: годинник, відкритий раніше, ніж
     * телефон устиг переслати токен, не віддавав чергу взагалі, і сказане на
     * пробіжці лежало до наступного запуску. */
    .task(id: link.token) {
      guard let token = link.token else { return }
      await Queue.flush(token: token, lang: link.lang)
    }
  }

  @ViewBuilder
  private func screen(for step: Step) -> some View {
    switch step {
    case .idle: idle
    case .hearing: hearing
    case .analysing(let heard): analysing(heard)

    /* Усе, що показує підсумок, повертається дотиком.
     *
     * Без цього застосунок був глухим кутом: після запису на екрані лишався
     * результат, і сказати друге речення можна було, тільки закривши застосунок
     * і відкривши наново. На телефоні це помітили б одразу, на годиннику це
     * взагалі вся взаємодія. */
    case .done(let dishes): done(dishes).onTapGesture { self.step = .idle }
    case .dry: dry.onTapGesture { self.step = .idle }
    case .queued(let heard): queued(heard).onTapGesture { self.step = .idle }
    case .trouble(let why):
      VStack(spacing: 0) {
        Spacer(minLength: 0)
        Note(head: t.failHead, say: why)
        Spacer(minLength: 0)
      }
      .onTapGesture { self.step = .idle }
    }
  }

  // MARK: Кільце дня з кнопкою всередині

  /* Один круг несе і дію, і стан. Кільце каже, скільки дня вже зʼїдено, і його
     видно з відстані витягнутої руки; кнопка всередині це те єдине, заради чого
     застосунок відкривають. */
  private var idle: some View {
    VStack(spacing: 0) {
      Spacer(minLength: 0)

      Button {
        Task { await listen() }
      } label: {
        ZStack {
          /* Зʼїдене, як на кільці дня в телефоні: порожній ранок це порожнє
             кільце, і воно наповнюється разом із днем. Залишок стоїть словами
             під кнопкою. */
          Ring(part: max(0, min(1, 1 - Double(link.left) / Double(max(link.norm, 1)))), width: w * 0.62)

          Circle()
            .fill(Palette.ink)
            .shadow(color: Palette.shade, radius: 10, y: 6)
            .padding(w * 0.111)
            .modifier(Pop(delay: 0.12))

          Mic().frame(width: w * 0.175, height: w * 0.175)
        }
        .frame(width: w * 0.62, height: w * 0.62)
      }
      .buttonStyle(Press(scale: 0.955))
      .disabled(!link.ready)

      Spacer(minLength: 0)

      Under {
        Text(link.ready ? t.say : t.openPhone)
          .font(Palette.font(w * 0.081, .semibold))
          .tracking(-0.02 * w * 0.081)
          .foregroundStyle(Palette.text)
          .multilineTextAlignment(.center)
        if link.ready {
          Text(String(format: t.leftOf, link.energyNum(link.left), link.energyText(link.norm)))
            .font(Palette.font(w * 0.066))
            .foregroundStyle(Palette.dim)
        }
      }
    }
  }

  // MARK: Слухає

  private var hearing: some View {
    VStack(spacing: 0) {
      Spacer(minLength: 0)
      Meter(level: ears.level).frame(width: w * 0.66, height: w * 0.3)
      Spacer(minLength: 0)

      Under {
        Text(t.listening)
          .font(Palette.font(w * 0.081, .semibold))
          .tracking(-0.02 * w * 0.081)
          .foregroundStyle(Palette.text)

        /* Скільки часу лишилось. Смужка наповнюється двадцять секунд, і коли
           вона повна, запис зупиняється і йде далі сам, як після «Готово».
           Без неї стеля була б невидимою: людина говорила б у вимкнений
           мікрофон і не знала про це. */
        GeometryReader { box in
          ZStack(alignment: .leading) {
            Capsule().fill(Palette.track)
            Capsule().fill(Palette.dim).frame(width: box.size.width * ears.elapsed)
          }
        }
        .frame(height: max(1.5, w * 0.0076))
        .padding(.top, w * 0.02)
        .padding(.horizontal, w * 0.1)
      }

      /* Одна широка кнопка. Скасування свайпом управо, як у всьому watchOS:
         друга кнопка поруч відібрала б половину ряду в головної дії заради
         того, що система і так уміє. */
      Button(t.done) { Task { await send() } }
        .font(Palette.font(w * 0.081, .semibold))
        .foregroundStyle(Palette.ground)
        .frame(maxWidth: .infinity)
        .padding(.vertical, w * 0.036)
        .background(Palette.ink, in: Capsule())
        .buttonStyle(Press(scale: 0.97))
        .padding(.top, w * 0.03)
        .modifier(Rise(delay: 0.26))
    }
    // Стеля запису спрацювала: далі так само, як після «Готово».
    .onChange(of: ears.ended) { _, ended in
      if ended, step == .hearing { Task { await send() } }
    }
  }

  // MARK: Аналізує

  /* Почуте на екрані одразу, щойно телефон його повернув, ще до відповіді про
     їжу. Без підтвердження людина каже вдруге і отримує подвійний запис. Поки
     слова ще в дорозі, картки немає: порожні лапки читались би як «не почула».
     Почуте не притиснуте до шапки: між ними лишається повітря, і речення
     читається як цитата, а не як другий рядок заголовка. */
  private func analysing(_ heard: String) -> some View {
    VStack(spacing: 0) {
      if !heard.isEmpty {
        Heard(text: heard).padding(.top, w * 0.1)
      }
      Spacer(minLength: 0)

      /* Слово і є індикатором: чорнило проходить крізь літери зліва направо,
         як погляд по рядку. Окремої крутилки поруч немає навмисно, бо вона
         казала б те саме вдруге. */
      Reading(text: t.analysing).modifier(Rise(delay: 0.16))

      Spacer(minLength: 0)
    }
  }

  // MARK: Записала

  private func done(_ dishes: [Dish]) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(spacing: w * 0.025) {
        Check().frame(width: w * 0.05, height: w * 0.05)
        Text(t.logged)
      }
      .font(Palette.font(w * 0.081, .semibold))
      .foregroundStyle(Palette.good)
      .padding(.bottom, w * 0.03)
      .modifier(Rise(delay: 0, length: 0.34))

      VStack(alignment: .leading, spacing: w * 0.022) {
        ForEach(Array(dishes.enumerated()), id: \.element.id) { i, dish in
          Card(horizontal: w * 0.042, vertical: w * 0.033, radius: w * 0.06) {
            VStack(alignment: .leading, spacing: w * 0.008) {
              Text(dish.name)
                .font(Palette.font(w * 0.071, .semibold))
                .tracking(-0.01 * w * 0.071)
                .foregroundStyle(Palette.text)
              // In the units the phone shows: the same dish must not read
              // «340 г» on the wrist and «12.0 oz» in the pocket.
              Text("\(link.portionText(dish.grams)) · \(link.energyText(dish.kcal))")
                .font(Palette.font(w * 0.066))
                .foregroundStyle(Palette.dim)
            }
          }
          .modifier(Rise(delay: 0.22 + Double(i) * 0.11, length: 0.42))
        }
      }

      Spacer(minLength: 0)

      /* Число не підміняється, а їде від старого до нового: рух тут і є
         відповіддю на «скільки з мене за це зняли». */
      VStack(spacing: w * 0.008) {
        Countdown(
          from: link.left + dishes.reduce(0) { $0 + $1.kcal },
          to: link.left,
          words: t.leftNow,
          number: { link.energyNum($0) },
          unit: link.energyUnit()
        )

        /* Похвала не на кожен запис і не завжди. Слово, яке чуєш щоразу, стає
           частиною інтерфейсу, а сказане тому, хто щойно перебрав норму, це не
           підтримка, а брехня. Зелена, як галочка вгорі. */
        if logs % 5 == 0, link.left > 0 {
          Text(t.praise)
            .font(Palette.font(w * 0.066, .medium))
            .foregroundStyle(Palette.good)
            .modifier(Rise(delay: 0.76, length: 0.42))
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.horizontal, w * 0.025)
      .modifier(Rise(delay: 0.2))
    }
  }

  // MARK: Токени скінчились, у черзі

  private var dry: some View {
    VStack(spacing: 0) {
      Spacer(minLength: 0)
      Note(head: t.dryHead, say: t.dryBody)
      Spacer(minLength: 0)
      Under {
        Text(String(format: t.leftNow, link.energyText(link.left)))
          .font(Palette.font(w * 0.066))
          .foregroundStyle(Palette.dim)
      }
    }
  }

  private func queued(_ heard: String) -> some View {
    VStack(spacing: 0) {
      Heard(text: heard)
      Spacer(minLength: 0)
      Note(head: t.queuedHead, say: t.queuedBody)
      Spacer(minLength: 0)
    }
  }

  // MARK: Дії

  private func listen() async {
    step = .hearing
    await ears.start(lang: link.lang)
    if let why = ears.trouble { step = .trouble(why) }
  }

  private func send() async {
    guard let file = ears.finish() else {
      step = .trouble(t.notHeard)
      return
    }
    guard let token = link.token else {
      step = .trouble(t.openPhone)
      return
    }

    /* Спершу слова від телефона, потім їжа від сервера. Почуте стає на екран,
       щойно воно є, а не разом із відповіддю про калорії. */
    step = .analysing("")

    let heard: String
    do {
      heard = try await link.hear(file, lang: link.lang)
    } catch LinkTrouble.far {
      /* Звук у чергу не кладеться: сказане без телефона поруч втратило б свій
         момент, а файл на годиннику нема де тримати. */
      step = .trouble(t.phoneFar)
      return
    } catch LinkTrouble.failed(let why) {
      step = .trouble(why)
      return
    } catch {
      step = .trouble(t.phoneSilent)
      return
    }

    /* Порожньо означає, що не почула нічого або почула не тією мовою. Мовчки
       вертатись на початок не можна: людина щойно говорила, і порожній екран
       читається як «застосунок зламався», а не як «скажи ще раз». */
    guard !heard.isEmpty else {
      step = .trouble(t.notHeard)
      return
    }

    step = .analysing(heard)

    /* Ключ належить реченню. Якщо відповідь не дійде і речення піде вдруге з
       черги, сервер побачить той самий ключ і не запише страву двічі. */
    let key = UUID().uuidString

    do {
      let answer = try await Nora.say(heard, key: key, token: token, lang: link.lang)
      logs += 1
      link.spend(answer.dishes.reduce(0) { $0 + $1.kcal })
      step = .done(answer.dishes)
    } catch NoraTrouble.dry {
      step = .dry
    } catch NoraTrouble.offline {
      Queue.add(heard, key: key)
      step = .queued(heard)
    } catch NoraTrouble.stale {
      /* Сервер не впізнав токен: людина вийшла на телефоні або токен протух.
         Годинник забуває його сам, і головний екран каже, що робити. */
      link.forget()
      step = .trouble(t.openPhone)
    } catch {
      step = .trouble(t.serverSilent)
    }
  }
}

// MARK: Частини екранів

/// Шапка як у застосунку: назва чорнилом ліворуч, час тихим праворуч.
private struct Bar: View {
  private var w: CGFloat { WKInterfaceDevice.current().screenBounds.width }

  var body: some View {
    HStack {
      Text("Calvi")
        .font(Palette.font(w * 0.081, .bold))
        .tracking(-0.03 * w * 0.081)
        .foregroundStyle(Palette.text)
      Spacer()
      Text(.now, style: .time)
        .font(Palette.font(w * 0.071, .medium).monospacedDigit())
        .foregroundStyle(Palette.dim)
    }
    .padding(.horizontal, w * 0.022)
    .padding(.bottom, w * 0.03)
  }
}

/// Нижній блок: підпис під кільцем чи метром. Приходить знизу з затримкою.
private struct Under<Content: View>: View {
  @ViewBuilder let content: Content
  private var w: CGFloat { WKInterfaceDevice.current().screenBounds.width }

  var body: some View {
    VStack(spacing: w * 0.008) { content }
      .frame(maxWidth: .infinity)
      .padding(.top, w * 0.03)
      .modifier(Rise(delay: 0.2))
  }
}

/// Біла картка з тінню: та сама, що скрізь у застосунку.
private struct Card<Content: View>: View {
  let horizontal: CGFloat
  let vertical: CGFloat
  let radius: CGFloat
  @ViewBuilder let content: Content

  var body: some View {
    content
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, horizontal)
      .padding(.vertical, vertical)
      .background(Palette.card, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
      .shadow(color: Palette.shade, radius: 10, y: 6)
      .shadow(color: Palette.shade.opacity(0.8), radius: 1, y: 1)
  }
}

/// Почуте, у лапках, як цитата.
private struct Heard: View {
  let text: String
  private var w: CGFloat { WKInterfaceDevice.current().screenBounds.width }

  var body: some View {
    Card(horizontal: w * 0.045, vertical: w * 0.038, radius: w * 0.07) {
      Text("«\(text)»")
        .font(Palette.font(w * 0.071))
        .lineSpacing(w * 0.071 * 0.35)
        .foregroundStyle(Palette.text)
    }
    .modifier(Rise())
  }
}

/// Картка з заголовком і поясненням: токени скінчились, у черзі, не вийшло.
private struct Note: View {
  let head: String
  let say: String
  private var w: CGFloat { WKInterfaceDevice.current().screenBounds.width }

  var body: some View {
    Card(horizontal: w * 0.042, vertical: w * 0.042, radius: w * 0.07) {
      VStack(alignment: .leading, spacing: w * 0.018) {
        Text(head)
          .font(Palette.font(w * 0.081, .semibold))
          .foregroundStyle(Palette.text)
        Text(say)
          .font(Palette.font(w * 0.066))
          .lineSpacing(w * 0.066 * 0.4)
          .foregroundStyle(Palette.dim)
      }
    }
    .modifier(Rise(delay: 0.08, length: 0.4))
  }
}

/// «Аналізую»: чорнило проходить крізь літери зліва направо, як погляд по рядку.
private struct Reading: View {
  let text: String
  private var w: CGFloat { WKInterfaceDevice.current().screenBounds.width }
  @State private var swept = false

  var body: some View {
    let label = Text(text)
      .font(Palette.font(w * 0.101, .semibold))
      .tracking(-0.02 * w * 0.101)

    label
      .foregroundStyle(Palette.faint)
      .overlay {
        GeometryReader { box in
          LinearGradient(
            stops: [
              .init(color: Palette.faint, location: 0),
              .init(color: Palette.faint, location: 0.38),
              .init(color: Palette.text, location: 0.5),
              .init(color: Palette.faint, location: 0.62),
              .init(color: Palette.faint, location: 1),
            ],
            startPoint: .leading,
            endPoint: .trailing
          )
          /* Утричі ширший за слово, з чорнилом посередині. Стартує зсунутим
             ліворуч на дві ширини, тобто чорнило за лівим краєм, і їде до
             нуля, тобто чорнило за правим: зліва направо, як погляд. */
          .frame(width: box.size.width * 3)
          .offset(x: swept ? 0 : -box.size.width * 2)
          .animation(.linear(duration: 1.9).repeatForever(autoreverses: false), value: swept)
        }
        .mask(label)
      }
      .onAppear { swept = true }
  }
}

/// Кільце дня: доріжка і зʼїдена частина, яка домальовується при появі.
private struct Ring: View {
  let part: Double
  let width: CGFloat
  @State private var drawn = false

  var body: some View {
    ZStack {
      Circle().stroke(Palette.track, lineWidth: width * 0.055)
      Circle()
        .trim(from: 0, to: drawn ? part : 0)
        .stroke(Palette.ink, style: StrokeStyle(lineWidth: width * 0.055, lineCap: .round))
        .rotationEffect(.degrees(-90))
        .animation(Motion.ease(0.9).delay(0.08), value: drawn)
    }
    .onAppear { drawn = true }
  }
}

/// Мікрофон із прототипу, штрихом, а не системна заливка.
private struct Mic: View {
  var body: some View {
    Canvas { paint, size in
      let k = size.width / 24
      var path = Path()
      path.addRoundedRect(
        in: CGRect(x: 9.2 * k, y: 3.5 * k, width: 5.6 * k, height: 10.6 * k),
        cornerSize: CGSize(width: 2.8 * k, height: 2.8 * k)
      )
      /* Чаша під капсулою: від правого краю через низ до лівого. У SwiftUI
         вісь y іде вниз, тому нуль градусів праворуч, дев'яносто внизу. */
      path.move(to: CGPoint(x: 18.2 * k, y: 11.2 * k))
      path.addArc(
        center: CGPoint(x: 12 * k, y: 11.2 * k), radius: 6.2 * k,
        startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false
      )
      path.move(to: CGPoint(x: 12 * k, y: 17.4 * k))
      path.addLine(to: CGPoint(x: 12 * k, y: 20.5 * k))
      paint.stroke(path, with: .color(Palette.ground), style: StrokeStyle(lineWidth: 1.7 * k, lineCap: .round, lineJoin: .round))
    }
  }
}

/// Галочка «Записала», малюється штрихом при появі.
private struct Check: View {
  @State private var drawn = false

  var body: some View {
    GeometryReader { box in
      let k = box.size.width / 24
      Path { p in
        p.move(to: CGPoint(x: 4 * k, y: 12.6 * k))
        p.addLine(to: CGPoint(x: 9.2 * k, y: 17.8 * k))
        p.addLine(to: CGPoint(x: 20 * k, y: 6.8 * k))
      }
      .trim(from: 0, to: drawn ? 1 : 0)
      .stroke(Palette.good, style: StrokeStyle(lineWidth: 2.6 * k, lineCap: .round, lineJoin: .round))
      .animation(Motion.ease(0.48).delay(0.12), value: drawn)
    }
    .onAppear { drawn = true }
  }
}

/// «лишилось N ккал», де N їде від старого залишку до нового.
private struct Countdown: View {
  let from: Int
  let to: Int
  let words: String
  let number: (Int) -> String
  let unit: String
  @State private var now: Int = 0
  private var w: CGFloat { WKInterfaceDevice.current().screenBounds.width }

  var body: some View {
    /* Формат «лишилось %@» ріжеться на слово і хвіст, число стоїть чорнилом
       між ними, як у прототипі. */
    let parts = words.components(separatedBy: "%@")
    HStack(spacing: 0) {
      Text(parts.first ?? "")
      Text(number(now))
        .font(Palette.font(w * 0.071, .semibold))
        .foregroundStyle(Palette.text)
        .monospacedDigit()
      Text(" \(unit)")
      Text(parts.count > 1 ? parts[1] : "")
    }
    .font(Palette.font(w * 0.066))
    .foregroundStyle(Palette.dim)
    .task {
      now = from
      let steps = 22
      for i in 1...steps {
        try? await Task.sleep(for: .milliseconds(50))
        let k = Double(i) / Double(steps)
        // Швидко на початку, мʼяко в кінці: рух читається як зупинка, а не як обрив.
        let e = 1 - pow(1 - k, 3)
        now = from + Int((Double(to - from) * e).rounded())
      }
      now = to
    }
  }
}

// MARK: Рух

/// Крива прототипу: `cubic-bezier(0.22, 0.61, 0.36, 1)`.
enum Motion {
  static func ease(_ length: Double) -> Animation {
    .timingCurve(0.22, 0.61, 0.36, 1, duration: length)
  }
}

/// Поява знизу: прозорість і зсув на 0.02 ширини, як `up` у прототипі.
private struct Rise: ViewModifier {
  var delay: Double = 0
  var length: Double = 0.38
  @State private var shown = false
  private var w: CGFloat { WKInterfaceDevice.current().screenBounds.width }

  func body(content: Content) -> some View {
    content
      .opacity(shown ? 1 : 0)
      .offset(y: shown ? 0 : w * 0.02)
      .animation(Motion.ease(length).delay(delay), value: shown)
      .onAppear { shown = true }
  }
}

/// Поява кнопки: з 0.8 до 1, як `pop` у прототипі.
private struct Pop: ViewModifier {
  var delay: Double = 0
  @State private var shown = false

  func body(content: Content) -> some View {
    content
      .opacity(shown ? 1 : 0)
      .scaleEffect(shown ? 1 : 0.8)
      .animation(Motion.ease(0.42).delay(delay), value: shown)
      .onAppear { shown = true }
  }
}

/// Дотик стискає кнопку, як `:active` у прототипі.
private struct Press: ButtonStyle {
  let scale: CGFloat

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? scale : 1)
      .animation(Motion.ease(0.18), value: configuration.isPressed)
  }
}

/// Кольори застосунку, один в один із `tokens.css`.
enum Palette {
  static let ground = Color(red: 0.965, green: 0.965, blue: 0.973)
  static let card = Color.white
  /// Текст: `--text`, майже чорний.
  static let text = Color(red: 0.039, green: 0.039, blue: 0.039)
  /// Кнопка, кільце, метр: `--button`.
  static let ink = Color(red: 0.11, green: 0.11, blue: 0.118)
  static let dim = Color(red: 0.557, green: 0.557, blue: 0.576)
  static let faint = Color(red: 0.706, green: 0.706, blue: 0.733)
  static let track = Color(red: 0.937, green: 0.937, blue: 0.949)
  static let good = Color(red: 0.561, green: 0.682, blue: 0.529)
  /// Тінь картки: `--shadow-card`.
  static let shade = Color(red: 0.063, green: 0.063, blue: 0.078).opacity(0.05)

  /// Шрифт застосунку, той самий Onest, що на телефоні; файли кладе в пакет
  /// `watch_target.rb`. Без них система підставить свій тієї ж ваги.
  static func font(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
    Font.custom("Onest", size: size).weight(weight)
  }
}

/// Тисячі нерозривним пробілом, як у застосунку.
func thousands(_ n: Int) -> String {
  let f = NumberFormatter()
  f.numberStyle = .decimal
  f.groupingSeparator = "\u{00a0}"
  return f.string(from: NSNumber(value: n)) ?? "\(n)"
}
