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
 *
 * Жодного свого слова в цьому файлі немає, і це навмисно. Розширення не бачить
 * ні локалі застосунку, ні перекладів, тому все, що людина тут читає, приходить
 * готовим рядком із Dart. Інакше виходило те, що й виходило: острівець говорив
 * українською в польському застосунку.
 */

/* Тло картки, і воно суцільне.
 *
 * Тут стояв чорний на 55 відсотків, тобто тла не було зовсім: картка
 * пропускала крізь себе те, що позаду. На замкненому екрані це непомітно, бо
 * система підкладає під неї свій темний шар, а в мить згортання застосунку та
 * сама картка малюється поверх домашнього екрана, і крізь неї просвічували
 * шпалери. На зелених шпалерах це виглядало як зелений спалах угорі екрана
 * щоразу, коли застосунок ішов у фон.
 *
 * Колір той самий, що в темних карток застосунку (`bezel`, 0xFF1A1A1C), і той
 * самий, що в смузі андроїдного сповіщення: одна річ в обох системах має
 * виглядати однією річчю. */
private let ink = Color(red: 0.102, green: 0.102, blue: 0.110)

/* Тло картки віддається контейнеру, а не кладеться під неї своїм прямокутником.
 *
 * Своє тло виглядало як тло рівно доти, доки система малювала картку тієї самої
 * форми. У перемикачі програм форма інша, кути заокруглені інакше, і наш
 * прямокутник вилазив з-під картки квадратними кутами за її межами. Видно це
 * було одразу: чорні кути поверх заокругленої картки.
 *
 * `containerBackground` це те саме тло, але оголошене системі: вона сама
 * розтягує його на весь контейнер і сама обрізає по його формі, хай якою вона
 * буде в цьому місці екрана. З iOS 17 це взагалі єдина правильна дорога, а
 * старіші лишаються зі своїм прямокутником, бо іншого способу там немає. */
private extension View {
  @ViewBuilder
  func ground(_ color: Color) -> some View {
    if #available(iOS 17.0, *) {
      containerBackground(color, for: .widget)
    } else {
      frame(maxWidth: .infinity).background(color)
    }
  }
}

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
    /* Відступ у півтовщини, і без нього кільце виглядало надкушеним.
     *
     * Обведення лягає по самій лінії кола, тобто половина товщини виходить за
     * межу рамки. У розгорнутому вигляді довкола є місце, і це нікому не
     * заважає, а в стислому рамка рівно така, як кільце: система зрізає все, що
     * виступило, і на телефоні збоку видно рівний зріз. Тепер малюнок цілком
     * усередині рамки, а рамка лишається того самого розміру. */
    .padding(width / 2)
    .frame(width: size, height: size)
  }
}

struct CalviLiveWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: CalviLiveAttributes.self) { context in
      LockScreenView(state: context.state)
        .activityBackgroundTint(ink)
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
            Text(context.state.shown)
              .font(.system(size: 30, weight: .bold))
              .monospacedDigit()
              .lineLimit(1)
              .minimumScaleFactor(0.6)
            /* Підпис приходить перекладом, а мови різної довжини: «kcal left»
               коротке, «kcal restantes» удвічі довше. Рядок, який не влазить,
               SwiftUI не обрізає, а вирівнює по центру, і тоді він вилазить за
               острівець з обох боків. Тому тут один рядок, який радше змаліє,
               ніж вилізе. */
            Text(context.state.caption)
              .font(.system(size: 12))
              .foregroundStyle(.white.opacity(0.6))
              .lineLimit(1)
              .minimumScaleFactor(0.7)
          }
          .padding(.trailing, 4)
        }
        DynamicIslandExpandedRegion(.bottom) {
          VStack(spacing: 8) {
            ProgressView(value: context.state.progress).tint(.white)

            /* Рядок про останній запис, слово в слово як у демці: назви страви
               немає, тільки калорії. Острівець висить на екрані весь день, і
               його бачить не тільки той, кому він призначений.
             *
             * Підпис має право змаліти, число не має: воно тут головне, і
             * дробити його переносом або підрізати наполовину гірше, ніж
             * зменшити слова поруч. Доти обидва стояли на повний розмір, разом
             * не вміщались, і рядок вилазив за край острівця з обох боків: у
             * підпису зрізало першу літеру, у числа останню. */
            HStack(spacing: 8) {
              Text(context.state.lastLabel)
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.6))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
              Spacer(minLength: 4)
              if !context.state.lastValue.isEmpty {
                Text(context.state.lastValue)
                  .font(.system(size: 12, weight: .semibold))
                  .monospacedDigit()
                  .lineLimit(1)
                  .fixedSize()
              }
            }
          }
          .padding(.top, 2)
          /* Заокруглення острівця зрізає кути, і текст, доведений до самого
             краю, читається обрізаним навіть тоді, коли він у межі влазить. */
          .padding(.horizontal, 6)
        }
      } compactLeading: {
        DayRing(progress: context.state.progress, size: 20, width: 4)
      } compactTrailing: {
        Text(context.state.shown)
          .font(.system(size: 15, weight: .semibold))
          .monospacedDigit()
          .lineLimit(1)
          .minimumScaleFactor(0.8)
      } minimal: {
        DayRing(progress: context.state.progress, size: 18, width: 4)
      }
      /* Обведення острівця темне, а не біле.
       *
       * Це єдине, що ми малюємо поверх екрана НАВКОЛО вирізу, і в анімації
       * появи система малює його не волосинкою, а свіченням. Біле свічення над
       * зеленою смугою шпалер і читалось як зелений спалах щоразу, коли
       * застосунок ішов у фон.
       *
       * Прибрати його зовсім не можна: поле приймає колір або порожнє, а
       * порожнє означає «візьми свій», тобто саме те, чого ми й позбуваємось.
       * Тому тут чистий чорний, той самий, яким система заливає сам острівець:
       * обведення перестає бути окремою річчю і зливається з ним. Чорнило
       * карток на два тони світліше, і на темних шпалерах його край усе одно
       * читався. */
      .keylineTint(Color.black)
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
          /* Назва застосунку тут не перекладається: це імʼя, і людина шукає
             очима саме його, хай якою мовою поставила застосунок. */
          Text("Calvi")
            .font(.system(size: 14, weight: .semibold))
          Text(state.lock)
            .font(.system(size: 12))
            .foregroundStyle(.white.opacity(0.6))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        }

        Spacer(minLength: 8)

        HStack(alignment: .firstTextBaseline, spacing: 4) {
          Text(state.shown)
            .font(.system(size: 24, weight: .bold))
            .monospacedDigit()
            .lineLimit(1)
            .fixedSize()
          Text(state.unit)
            .font(.system(size: 12))
            .foregroundStyle(.white.opacity(0.6))
            .lineLimit(1)
            .fixedSize()
        }
      }

      ProgressView(value: state.progress).tint(.white)
    }
    .padding(14)
    .foregroundStyle(.white)
    /* Тло тут, а не тільки в `activityBackgroundTint`: той модифікатор це
       побажання для замкненого екрана, і на кадри переходу воно не поширюється
       нічим. Форму і межі лишаємо системі. */
    .ground(ink)
  }
}

@main
struct CalviLiveBundle: WidgetBundle {
  var body: some Widget {
    CalviLiveWidget()
  }
}
