import 'package:flutter/material.dart';

import '../../data/chat.dart';
import '../../data/units.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../l10n/app_localizations.dart';

/// Кільце, поки Нора думає.
///
/// Знак застосунку, який крутиться за годинниковою. Стоїть у самій бульбашці, а
/// не збоку: коли відповідь приходить, бульбашка доростає з нього, а не виникає
/// з нічого поруч. Мовчазний чат на кілька секунд читається як «залагало», і це
/// найдешевша з усіх помилок, яку можна зробити в помічнику.
class Thinking extends StatefulWidget {
  const Thinking({super.key});

  @override
  State<Thinking> createState() => _ThinkingState();
}

class _ThinkingState extends State<Thinking> with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RotationTransition(
          turns: _spin,
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              /* Не крутиться сам, а провертається цілим: значення стале, і саме
                 тому кільце має розрив на місці, а не бігає всередині себе. Це
                 та сама фігура, що на іконці застосунку. */
              value: 0.72,
              strokeWidth: 2.4,
              strokeCap: StrokeCap.round,
              color: c.text,
              backgroundColor: c.text.withValues(alpha: 0.14),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          L.of(context).plateThinking,
          style: context.t.labelSmall?.copyWith(fontSize: CalviSize.fsMicro),
        ),
      ],
    );
  }
}

/// Числа страви окремою смужкою під словами Нори.
///
/// Число, вплетене в речення, читається як частина розмови, і його доводиться
/// вишукувати очима серед слів. Те саме число смужкою видно з одного погляду, і
/// одразу зрозуміло, де закінчується мова помічника і починаються дані.
class PlateStrip extends StatelessWidget {
  const PlateStrip({super.key, required this.plate});

  final MealPlate plate;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        /* Світліше за саму бульбашку, а не темніше: смужка має відділятись, але
           не важити більше за те, що Нора сказала. */
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          /* Кілька страв одним повідомленням: рядок на кожну над підсумком, щоб
             було видно, що саме вгадано для кожної. Назва зліва, вага тихо,
             калорії справа жирно, все в одну лінію: список читається як чек, а
             не як абзац. Одна страва йде без списку, рядок повторював би
             заголовок. Риска під рядками робить велике число внизу сумою, а не
             ще одним рядком. Кожна страва при цьому лежить у дні окремим
             записом: це картка в чаті, а не запис. */
          if (plate.items.length > 1) ...[
            for (final item in plate.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.t.bodyMedium?.copyWith(fontSize: CalviSize.fsCaption),
                      ),
                    ),
                    if (item.grams != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        l.mealGrams(dataUnits.porText(item.grams!)),
                        style: context.t.labelSmall?.copyWith(fontSize: CalviSize.fsMicro),
                      ),
                    ],
                    const SizedBox(width: 8),
                    /* Калорії в стовпчик: найкоротше число тримає ту саму
                       правую межу, що й тризначне, інакше око зʼїжджає. */
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 30),
                      child: Text(
                        '${item.kcal}',
                        textAlign: TextAlign.right,
                        style: context.t.titleMedium?.copyWith(fontSize: CalviSize.fsCaption),
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              height: 1,
              margin: const EdgeInsets.only(top: 3, bottom: 8),
              color: c.cardBorder,
            ),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  dataUnits.enNum(plate.kcal),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.t.headlineMedium?.copyWith(fontSize: 19),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                L.of(context).plateKcal(dataUnits.enLabel),
                style: context.t.labelSmall?.copyWith(fontSize: CalviSize.fsMicro),
              ),
              const Spacer(),
              /* Під списком підсумок підписаний «разом», а не вагою: грами
                 борщу з хлібом в одному числі нічого не кажуть, вони вже
                 стоять у рядках. */
              if (plate.items.length > 1)
                Text(
                  l.plateTotal,
                  style: context.t.labelSmall?.copyWith(fontSize: CalviSize.fsMicro),
                )
              else if (plate.grams != null)
                Text(
                  L.of(context).plateFor(dataUnits.porText(plate.grams!)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.t.labelSmall?.copyWith(fontSize: CalviSize.fsMicro),
                ),
            ],
          ),
          const SizedBox(height: 8),

          /* Три клітинки рівної ширини: око читає їх як рядок, а не як три різні
             речі, що випадково опинились поруч. Рівні саме тому, що ширина, яку
             дає вміст, робить із них сходинки. */
          Row(
            children: [
              /* Кожній клітинці її колір, той самий, що в кілець дня: білок
                 червонуватий, жири сині, вуглеводи жовті. Око вже вивчило цю
                 мову на головному екрані, і чат говорить нею ж. */
              for (final (i, cell) in [
                (l.macroProteinLetter, 0, c.protein),
                (l.macroFatLetter, 1, c.fats),
                (l.macroCarbsLetter, 2, c.carbs),
              ].indexed)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == 2 ? 0 : 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: cell.$3.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      /* Число буває тризначним, а клітинка вужча за третину
                         бульбашки. Без цього рядок переповнювався, і смужка
                         випирала за край: саме те, що видно на екрані як банер
                         поза телефоном. Зменшитись тут чесніше, ніж вилізти. */
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text.rich(
                          TextSpan(
                            text: '${cell.$1} ',
                            style: context.t.labelSmall?.copyWith(
                              fontSize: CalviSize.fsMicro,
                              color: cell.$3,
                              fontWeight: FontWeight.w600,
                            ),
                            children: [
                              /* Число теж у колір клітинки, як на картці
                                 сканера: два різні записи однієї речі поруч
                                 виглядали б як два різні інтерфейси. */
                              TextSpan(
                                text: '${_grams(cell.$2)}',
                                style: context.t.titleMedium?.copyWith(
                                  fontSize: CalviSize.fsMicro,
                                  color: cell.$3,
                                ),
                              ),
                              TextSpan(
                                // Macros stay in grams whatever the portions read in.
                                text: L.of(context).plateGrams(L.of(context).unitG),
                                style: context.t.labelSmall?.copyWith(
                                  fontSize: CalviSize.fsMicro,
                                  color: cell.$3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  int _grams(int which) => switch (which) {
    0 => plate.protein,
    1 => plate.fat,
    _ => plate.carbs,
  };
}
