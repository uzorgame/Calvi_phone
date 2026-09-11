import ActivityKit
import SwiftUI
import WidgetKit

/* Живий запис дня на динамічному острівці.
 *
 * Система дає чотири вигляди, і жоден із них не наш вибір: вона сама вирішує,
 * який показати. Тут вони всі, у тому ж вигляді, що й на 5300:
 *
 *   * **compact** — дві половини обабіч вирізу: кільце і число;
 *   * **minimal** — коли активність не одна, від нашої лишається кільце;
 *   * **expanded** — дотик і утримання: число словами, смуга дня, останнє;
 *   * **замкнений екран** — банер під годинником.
 *
 * Малюється це на SwiftUI і тільки тут: із Flutter в острівець не потрапити
 * ніяк, бо система малює його власним процесом, поза застосунком.
 */

/// Кільце дня. Те саме, що на картці дня в застосунку, тільки без анімації
/// входу: активність малюється кадрами системи, а не нашими.
struct DayRing: View {
  let progress: Double
  let size: CGFloat
  let width: CGFloat

  var body: some View {
    ZStack {
      Circle()
        .stroke(Color.white.opacity(0.22), lineWidth: width)
      Circle()
        .trim(from: 0, to: max(0.001, min(1, progress)))
        .stroke(Color.white, style: StrokeStyle(lineWidth: width, lineCap: .round))
        .rotationEffect(.degrees(-90))
    }
    .frame(width: size, height: size)
  }
}

struct CalviLiveWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: CalviLiveAttributes.self) { context in
      LockScreenView(state: context.state)
        .activityBackgroundTint(Color.black.opacity(0.55))
        .activitySystemActionForegroundColor(Color.white)
    } dynamicIsland: { context in
      DynamicIsland {
        /* Розгорнутий. Кільце ліворуч, число з підписом праворуч, смуга дня
           знизу через усю ширину. Назви страви тут немає навмисно: острівець
           видно не лише тому, кому він призначений. */
        DynamicIslandExpandedRegion(.leading) {
          DayRing(progress: context.state.progress, size: 46, width: 6)
            .padding(.leading, 4)
        }
        DynamicIslandExpandedRegion(.trailing) {
          VStack(alignment: .trailing, spacing: 2) {
            Text("\(context.state.shown)")
              .font(.system(size: 30, weight: .bold))
              .monospacedDigit()
            Text(context.state.over ? "ккал перебір" : "ккал лишилось")
              .font(.system(size: 12))
              .foregroundStyle(.white.opacity(0.6))
          }
          .padding(.trailing, 4)
        }
        DynamicIslandExpandedRegion(.bottom) {
          VStack(spacing: 8) {
            ProgressView(value: context.state.progress).tint(.white)

            /* Рядок про останній запис, слово в слово як у демці: назви страви
               немає, тільки калорії. Острівець висить на екрані весь день, і
               його бачить не тільки той, кому він призначений. */
            HStack {
              Text(context.state.last == nil
                ? "сьогодні ще нічого не записано"
                : "останній прийом їжі")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.6))
              Spacer()
              if let last = context.state.last {
                Text("\(last) ккал")
                  .font(.system(size: 12, weight: .semibold))
                  .monospacedDigit()
              }
            }
          }
          .padding(.top, 2)
        }
      } compactLeading: {
        DayRing(progress: context.state.progress, size: 20, width: 4)
      } compactTrailing: {
        Text("\(context.state.shown)")
          .font(.system(size: 15, weight: .semibold))
          .monospacedDigit()
      } minimal: {
        DayRing(progress: context.state.progress, size: 18, width: 4)
      }
      .keylineTint(Color.white)
    }
  }
}

/* Замкнений екран і телефони без острівця.
 *
 * Той самий запис, але банером під годинником: коли екран замкнений, він
 * виглядає саме так навіть на телефоні з островом. */
struct LockScreenView: View {
  let state: CalviLiveAttributes.ContentState

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(spacing: 12) {
        DayRing(progress: state.progress, size: 34, width: 6)

        VStack(alignment: .leading, spacing: 2) {
          Text("Calvi")
            .font(.system(size: 14, weight: .semibold))
          Text(state.over ? "перебір за сьогодні" : "лишилось на сьогодні")
            .font(.system(size: 12))
            .foregroundStyle(.white.opacity(0.6))
        }

        Spacer(minLength: 8)

        HStack(alignment: .firstTextBaseline, spacing: 4) {
          Text("\(state.shown)")
            .font(.system(size: 24, weight: .bold))
            .monospacedDigit()
          Text("ккал")
            .font(.system(size: 12))
            .foregroundStyle(.white.opacity(0.6))
        }
      }

      ProgressView(value: state.progress).tint(.white)
    }
    .padding(14)
    .foregroundStyle(.white)
  }
}

@main
struct CalviLiveBundle: WidgetBundle {
  var body: some Widget {
    CalviLiveWidget()
  }
}
