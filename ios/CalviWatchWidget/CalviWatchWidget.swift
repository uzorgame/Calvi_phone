import SwiftUI
import WidgetKit

/// Ускладнення на циферблаті: кільце залишку з числом усередині, без слів.
///
/// Заради нього застосунок і ставлять на годинник: відповідь на «скільки
/// лишилось» без жодного дотику. Малюнок той самий, що в прототипі
/// `Demo_Watch`, екран «Циферблат»: кільце частки залишку на чорному, число
/// шрифтом застосунку. Дотик по колу відкриває Calvi.
@main
struct CalviWatchWidgetBundle: WidgetBundle {
  var body: some Widget {
    FaceWidget()
  }
}

struct FaceEntry: TimelineEntry {
  let date: Date
  let state: Face.State?
}

/* Оновлення приходять від застосунку, а не за розкладом: щойно телефон
   переслав нове число або годинник сам записав страву, застосунок кладе стан
   у ланцюжок ключів і просить перемалювати. Свого годинника ускладнення не
   тримає, бо порахувати новий день без даних воно не може. */
struct FaceProvider: TimelineProvider {
  func placeholder(in context: Context) -> FaceEntry {
    FaceEntry(date: .now, state: Face.State(left: 1160, norm: 2220))
  }

  func getSnapshot(in context: Context, completion: @escaping (FaceEntry) -> Void) {
    completion(FaceEntry(date: .now, state: context.isPreview ? placeholder(in: context).state : Face.read()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<FaceEntry>) -> Void) {
    completion(Timeline(entries: [FaceEntry(date: .now, state: Face.read())], policy: .never))
  }
}

struct FaceWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "calvi.face", provider: FaceProvider()) { entry in
      FaceView(state: entry.state)
    }
    .configurationDisplayName("Calvi")
    .description("kcal")
    .supportedFamilies([.accessoryCircular, .accessoryCorner])
  }
}

/// Кільце з числом. Пропорції з прототипу: радіус 44 і товщина 8 на сотні,
/// число близько чверті розміру кола, напівжирне, з тісним трекінгом.
struct FaceView: View {
  let state: Face.State?

  var body: some View {
    GeometryReader { g in
      let s = min(g.size.width, g.size.height)
      let stroke = s * 0.08
      ZStack {
        Circle()
          .stroke(.white.opacity(0.16), lineWidth: stroke)
        Circle()
          .trim(from: 0, to: part)
          .stroke(.white, style: StrokeStyle(lineWidth: stroke, lineCap: .round))
          .rotationEffect(.degrees(-90))
          .widgetAccentable()
        Text(number)
          .font(.custom("Onest-SemiBold", size: s * 0.23))
          .tracking(-0.02 * s * 0.23)
          .foregroundStyle(.white)
          .lineLimit(1)
          .minimumScaleFactor(0.6)
          .padding(.horizontal, stroke * 1.4)
      }
      .padding(stroke / 2)
      .frame(width: g.size.width, height: g.size.height)
    }
    .containerBackground(for: .widget) { Color.clear }
  }

  /// Частка залишку, як на прототипі: повне кільце зранку, порожнє, коли
  /// норму зʼїли. Перебір нижче за нуль не йде.
  private var part: CGFloat {
    guard let state, state.norm > 0 else { return 0 }
    return CGFloat(max(0, min(1, Double(state.left) / Double(state.norm))))
  }

  private var number: String {
    guard let state else { return "–" }
    return thousands(state.left)
  }

  /// Тисячі через звичайний пробіл, як усюди в застосунку. Мінус лишається
  /// на місці, бо перебір читається саме ним.
  private func thousands(_ n: Int) -> String {
    let digits = String(abs(n))
    var out = ""
    for (i, ch) in digits.enumerated() {
      if i > 0, (digits.count - i) % 3 == 0 { out += " " }
      out.append(ch)
    }
    return n < 0 ? "-\(out)" : out
  }
}
