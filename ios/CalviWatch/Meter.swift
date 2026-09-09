import SwiftUI

/// Метр голосу: той самий, що на 5200, число в число.
///
/// Одинадцять крапель у ряд, склеєних фільтром: розмиття плюс різкий поріг по
/// прозорості. Те, що близько, зливається в одну масу з перетяжкою між
/// краплями, а те, що відірвалось, знову стає краплею. Це та сама механіка,
/// якою малюють ртуть, і саме вона відрізняє наш метр від синіх паличок
/// системного диктування. У SwiftUI вона є в `Canvas` як два фільтри поспіль.
///
/// Розміри, брижі, огинаюча і поява від середини повторюють `VoiceMeter.tsx`:
/// один макет, два полотна.
struct Meter: View {
  /// Гучність зараз, від нуля до одиниці.
  let level: Double

  /* Одинадцять товстих крапель, а не тринадцять тонких. Тонкі дають ріденький
     пунктир: між ними більше проміжку, ніж фільтр здатен склеїти. */
  private let bars = 11

  /// Висота краплі в спокої, часткою від ряду: рівно стільки робить із неї кульку.
  private static let seed = 0.114

  /// Секунди від появи. Від них рахуються брижі, огинаюча і народження ряду.
  @State private var phase: Double = 0

  /// Рівень, який бачить цикл. Сам `level` приходить ззовні на кожен кадр, а
  /// цикл живе один; без дзеркала він читав би значення з миті свого старту.
  @State private var now: Double = 0

  /* Кожна крапля тримає свою стелю, що осідає: звук піднімає її миттєво, а
     падає вона за кілька кадрів. Без цього метр не рухається, а мерехтить. */
  @State private var peaks: [Double] = Array(repeating: 0.114, count: 11)

  var body: some View {
    Canvas { paint, size in
      /* Фільтри складаються з кінця: спершу розмиття, тоді поріг. Розмиття
         близько до `stdDeviation` прототипу, поріг там, де половина прозорості
         вже стає тілом. */
      paint.addFilter(.alphaThreshold(min: 0.4, color: Palette.ink))
      paint.addFilter(.blur(radius: size.width * 0.019))

      paint.drawLayer { layer in
        // Крапля 0.045 ширини екрана в ряду 0.66: та сама частка від ряду.
        let dropWidth = size.width * (0.045 / 0.66)
        let gap = (size.width - dropWidth * Double(bars)) / Double(bars - 1)

        for i in 0..<bars {
          /* Краплі розкриваються від середини до країв: так ряд народжується
             одним рухом, а не одинадцятьма одночасними спалахами. */
          let born = max(0, min(1, (phase - offMid(i) * 5 * 0.024) / 0.42))
          let ease = 1 - pow(1 - born, 3)
          let scale = 0.6 + 0.4 * ease

          let h = size.height * peaks[i] * scale
          let w = dropWidth * scale
          let cx = Double(i) * (dropWidth + gap) + dropWidth / 2
          let drop = CGRect(x: cx - w / 2, y: size.height / 2 - h / 2, width: w, height: h)

          layer.opacity = ease
          layer.fill(Path(ellipseIn: drop), with: .color(Palette.ink))
        }
      }
    }
    .onChange(of: level) { _, v in now = v }
    .task {
      /* Свій годинник кадрів, бо метр живе і в тиші: хвиля йде вздовж ряду, і
         без неї він стояв би нерухомим огризком, поки людина мовчить. */
      while !Task.isCancelled {
        try? await Task.sleep(for: .milliseconds(50))
        phase += 0.05
        for i in 0..<bars {
          let want = max(calm(i), now * shape(i) * jitter(i))
          /* Стеля піднімається одразу, осідає поступово. Коефіцієнт це
             прототипні 0.82 на кадр, зведені до кроку в пʼятдесят мілісекунд. */
          peaks[i] = want > peaks[i] ? want : peaks[i] * 0.55 + want * 0.45
        }
      }
    }
  }

  /// Наскільки крапля далеко від середини, від нуля до одиниці.
  private func offMid(_ i: Int) -> Double {
    abs(Double(i) - Double(bars - 1) / 2) / (Double(bars - 1) / 2)
  }

  /// Середина несе більше за краї, як і малюють метр голосу.
  private func shape(_ i: Int) -> Double { 0.62 + 0.38 * (1 - offMid(i)) }

  /// Трохи різниці на кожну краплю, щоб це не був рівний горб.
  private func jitter(_ i: Int) -> Double { 0.7 + 0.3 * sin(phase * 11.1 + Double(i) * 1.7) }

  /* Метр дихає і в тиші. Хвиля біжить уздовж ряду, а не піднімає всі краплі
     разом: спільний рівень лишав би ряд рівним. Голос лягає поверх неї, тому
     тиша це брижі, а мова це та сама вода, що піднялась. */
  private func calm(_ i: Int) -> Double {
    0.17 + 0.06 * sin(phase * 1.61 + Double(i) * 0.62) + 0.03 * sin(phase * 4.76 - Double(i) * 0.9)
  }
}
