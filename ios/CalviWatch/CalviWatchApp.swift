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
enum Step: Equatable {
  case idle
  case hearing
  case analysing(String)
  case done([Dish])
  case dry
  case queued
  case trouble(String)
}

/// Годинниковий Calvi цілком: одна кнопка і те, що з неї виходить.
///
/// **Кегль не переноситься з макета, а береться з системи.** Макет мальований на
/// полотні 396 завширшки, а екран годинника 198 пунктів: числа звідти, взяті
/// напряму, дали б підписи по сім пунктів, тобто вдвічі дрібніші за все, що
/// малює watchOS. Тому тут стилі тексту системні: вони тримають ту саму
/// ієрархію і слухаються розміру шрифта, який людина поставила собі на годиннику.
///
/// Розміри самих тіл, навпаки, рахуються від ширини екрана, як у макеті: кільце
/// це 0.62 ширини і на сорок першому корпусі, і на сорок пʼятому.
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
    }
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
    case .dry:
      note(t.dryHead, t.dryBody)
        .onTapGesture { self.step = .idle }
    case .queued:
      note(t.queuedHead, t.queuedBody)
        .onTapGesture { self.step = .idle }
    case .trouble(let why):
      note(t.failHead, why).onTapGesture { self.step = .idle }
    }
  }

  // MARK: Кільце дня з кнопкою всередині

  /* Один круг несе і дію, і стан. Кільце каже, скільки норми лишилось, і його
     видно з відстані витягнутої руки; кнопка всередині це те єдине, заради чого
     застосунок відкривають. */
  private var idle: some View {
    VStack(spacing: 0) {
      Spacer(minLength: 0)

      Button {
        Task { await listen() }
      } label: {
        ZStack {
          Circle().stroke(Palette.track, lineWidth: w * 0.034)
          /* Зʼїдене, як на кільці дня в телефоні: порожній ранок це порожнє
             кільце, і воно наповнюється разом із днем. Залишок стоїть словами
             під кнопкою. */
          Circle()
            .trim(from: 0, to: max(0, min(1, 1 - Double(link.left) / Double(max(link.norm, 1)))))
            .stroke(Palette.ink, style: StrokeStyle(lineWidth: w * 0.034, lineCap: .round))
            .rotationEffect(.degrees(-90))
          Circle().fill(Palette.ink).padding(w * 0.111)
          Image(systemName: "mic.fill")
            .font(.system(size: w * 0.175))
            .foregroundStyle(Palette.ground)
        }
        .frame(width: w * 0.62, height: w * 0.62)
      }
      .buttonStyle(.plain)
      .disabled(!link.ready)

      Spacer(minLength: 0)

      Text(link.ready ? t.say : t.openPhone)
        .font(.headline)
        .foregroundStyle(Palette.ink)
        .multilineTextAlignment(.center)

      if link.ready {
        Text(String(format: t.leftOf, link.energyNum(link.left), link.energyText(link.norm)))
          .font(.caption2)
          .foregroundStyle(Palette.dim)
      }
    }
  }

  // MARK: Слухає

  private var hearing: some View {
    VStack(spacing: 0) {
      Spacer(minLength: 0)
      Meter(level: ears.level).frame(height: w * 0.3)
      Spacer(minLength: 0)

      Text(t.listening)
        .font(.headline)
        .foregroundStyle(Palette.ink)

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
      .frame(height: 3)
      .padding(.top, w * 0.02)
      .padding(.horizontal, w * 0.1)

      /* Одна широка кнопка. Скасування свайпом управо, як у всьому watchOS:
         друга кнопка поруч відібрала б половину ряду в головної дії заради
         того, що система і так уміє. */
      Button(t.done) { Task { await send() } }
        .font(.body.weight(.semibold))
        .foregroundStyle(Palette.ground)
        .frame(maxWidth: .infinity)
        .padding(.vertical, w * 0.036)
        .background(Palette.ink, in: Capsule())
        .buttonStyle(.plain)
        .padding(.top, w * 0.03)
    }
    // Стеля запису спрацювала: далі так само, як після «Готово».
    .onChange(of: ears.ended) { _, ended in
      if ended, step == .hearing { Task { await send() } }
    }
  }

  // MARK: Аналізує

  /* Почуте на екрані одразу, щойно сервер його повернув, ще до відповіді про
     їжу. Без підтвердження людина каже вдруге і отримує подвійний запис. Поки
     слова ще в дорозі, картки немає: порожні лапки читались би як «не почула». */
  private func analysing(_ heard: String) -> some View {
    VStack(spacing: 0) {
      if !heard.isEmpty {
        Card { Text("«\(heard)»").font(.footnote).foregroundStyle(Palette.ink) }
          .padding(.top, w * 0.05)
      }
      Spacer(minLength: 0)

      /* Індикатор це саме слово, а не значок поруч із ним: крутилка казала б те
         саме, тільки чужим голосом. */
      Text(t.analysing)
        .font(.title3.weight(.semibold))
        .foregroundStyle(Palette.dim)

      Spacer(minLength: 0)
    }
  }

  // MARK: Записала

  private func done(_ dishes: [Dish]) -> some View {
    VStack(alignment: .leading, spacing: w * 0.022) {
      HStack(spacing: 4) {
        Image(systemName: "checkmark")
        Text(t.logged)
      }
      .font(.headline)
      .foregroundStyle(Palette.good)

      ForEach(dishes) { dish in
        Card {
          VStack(alignment: .leading, spacing: 1) {
            Text(dish.name).font(.footnote.weight(.semibold)).foregroundStyle(Palette.ink)
            // In the units the phone shows: the same dish must not read
            // «340 г» on the wrist and «12.0 oz» in the pocket.
            Text("\(link.portionText(dish.grams)) · \(link.energyText(dish.kcal))")
              .font(.caption2)
              .foregroundStyle(Palette.dim)
          }
        }
      }

      Spacer(minLength: 0)

      VStack(spacing: 1) {
        Text(String(format: t.leftNow, link.energyText(link.left)))
          .font(.caption)
          .foregroundStyle(Palette.dim)

        /* Похвала не на кожен запис і не завжди. Слово, яке чуєш щоразу, стає
           частиною інтерфейсу, а сказане тому, хто щойно перебрав норму, це не
           підтримка, а брехня. */
        if logs % 5 == 0, link.left > 0 {
          Text(t.praise)
            .font(.caption2)
            .foregroundStyle(Palette.good)
        }
      }
      .frame(maxWidth: .infinity)
    }
  }

  private func note(_ head: String, _ say: String) -> some View {
    VStack {
      Spacer(minLength: 0)
      Card {
        VStack(alignment: .leading, spacing: 4) {
          Text(head).font(.headline).foregroundStyle(Palette.ink)
          Text(say).font(.caption2).foregroundStyle(Palette.dim)
        }
      }
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
      step = .queued
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

// MARK: Дрібниці

/// Шапка як у застосунку: назва чорнилом ліворуч, час тихим праворуч.
private struct Bar: View {
  private var w: CGFloat { WKInterfaceDevice.current().screenBounds.width }

  var body: some View {
    HStack {
      Text("Calvi")
        .font(.system(size: w * 0.081, weight: .bold))
        .tracking(-0.03 * w * 0.081)
        .foregroundStyle(Palette.ink)
      Spacer()
      Text(.now, style: .time)
        .font(.system(size: w * 0.071, weight: .medium).monospacedDigit())
        .foregroundStyle(Palette.dim)
    }
    .padding(.horizontal, w * 0.022)
    .padding(.bottom, w * 0.03)
  }
}

/// Біла картка з тінню: та сама, що скрізь у застосунку.
private struct Card<Content: View>: View {
  @ViewBuilder let content: Content

  var body: some View {
    content
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 10)
      .padding(.vertical, 8)
      .background(Palette.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
  }
}

/// Кольори застосунку, один в один із `tokens.css`.
enum Palette {
  static let ground = Color(red: 0.965, green: 0.965, blue: 0.973)
  static let card = Color.white
  static let ink = Color(red: 0.11, green: 0.11, blue: 0.118)
  static let dim = Color(red: 0.557, green: 0.557, blue: 0.576)
  static let track = Color(red: 0.937, green: 0.937, blue: 0.949)
  static let good = Color(red: 0.561, green: 0.682, blue: 0.529)
}

/// Тисячі нерозривним пробілом, як у застосунку.
func thousands(_ n: Int) -> String {
  let f = NumberFormatter()
  f.numberStyle = .decimal
  f.groupingSeparator = "\u{00a0}"
  return f.string(from: NSNumber(value: n)) ?? "\(n)"
}
