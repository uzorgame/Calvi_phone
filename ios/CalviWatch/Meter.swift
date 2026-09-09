import SwiftUI

/// Метр голосу: та сама рідина, що в застосунку на телефоні.
///
/// На вебі краплі склеює фільтр із розмиття і різкого порогу по прозорості. На
/// годиннику фільтрів такої ваги дозволити собі не можна: екран малює процесор,
/// якого вистачає рівно на те, щоб не садити батарею. Тому тут малюється не
/// одинадцять окремих смуг, а **одна замкнена крива**, чий верхній край іде по
/// їхніх висотах, а нижній дзеркалить його.
///
/// Виходить те саме тіло, тільки дешевше: жодного розмиття, жодного шару, один
/// шлях за кадр.
struct Meter: View {
  /// Гучність зараз, від нуля до одиниці.
  let level: Double

  /// Скільки вершин у ряду. Непарне, щоб середина була вершиною, а не западиною.
  private let peaks = 11

  @State private var phase: Double = 0

  var body: some View {
    Canvas { paint, size in
      paint.fill(Path(blob(in: size)), with: .color(Palette.ink))
    }
    .task {
      /* Свій годинник кадрів, бо метр живе і в тиші: хвиля йде вздовж ряду, і
         без неї він стояв би нерухомим огризком, поки людина мовчить. */
      while !Task.isCancelled {
        try? await Task.sleep(for: .milliseconds(50))
        phase += 0.05
      }
    }
  }

  /// Висоти вершин: голос поверх повільних брижів.
  private func heights() -> [Double] {
    (0..<peaks).map { i in
      let off = abs(Double(i) - Double(peaks - 1) / 2) / (Double(peaks - 1) / 2)

      // Середина несе більше за краї, як і малюють метр голосу.
      let shape = 0.62 + 0.38 * (1 - off)
      let jitter = 0.7 + 0.3 * sin(phase * 11 + Double(i) * 1.7)

      /* Метр дихає і в тиші. Хвиля біжить уздовж ряду, а не піднімає всі вершини
         разом: спільний рівень лишав би ряд рівним. */
      let calm = 0.17 + 0.06 * sin(phase * 1.6 + Double(i) * 0.62)

      return max(calm, level * shape * jitter)
    }
  }

  /// Замкнена крива по вершинах, згладжена по серединах відрізків.
  private func blob(in size: CGSize) -> CGPath {
    let h = heights()
    let step = size.width / Double(peaks - 1)
    let mid = size.height / 2
    // Найтонше місце лишається помітним: нуль перетворив би тишу на порожнечу.
    let cap = size.height / 2 - 3

    let top = (0..<peaks).map { CGPoint(x: Double($0) * step, y: mid - cap * h[$0]) }
    let bottom = (0..<peaks).reversed().map { CGPoint(x: Double($0) * step, y: mid + cap * h[$0]) }

    let path = CGMutablePath()
    smooth(path, through: top, start: true)
    smooth(path, through: bottom, start: false)
    path.closeSubpath()
    return path
  }

  /* Через середини відрізків, а не через самі точки: ламана з гострими кутами
     читається як шум навіть там, де його немає. Те саме згладжування, що на
     кривій ваги в застосунку. */
  private func smooth(_ path: CGMutablePath, through points: [CGPoint], start: Bool) {
    guard let first = points.first else { return }
    if start { path.move(to: first) } else { path.addLine(to: first) }

    for i in 1..<points.count {
      let a = points[i - 1]
      let b = points[i]
      path.addQuadCurve(
        to: CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2),
        control: a
      )
      if i == points.count - 1 { path.addLine(to: b) }
    }
  }
}
