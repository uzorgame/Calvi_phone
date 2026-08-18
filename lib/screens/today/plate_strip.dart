import 'package:flutter/material.dart';

import '../../data/chat.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';

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
        Text('думаю', style: context.t.labelSmall?.copyWith(fontSize: CalviSize.fsMicro)),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  '${plate.kcal}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.t.headlineMedium?.copyWith(fontSize: 19),
                ),
              ),
              const SizedBox(width: 6),
              Text('ккал', style: context.t.labelSmall?.copyWith(fontSize: CalviSize.fsMicro)),
              const Spacer(),
              if (plate.grams != null)
                Text(
                  'за ${plate.grams!.round()} г',
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
              for (final (i, cell) in const [('Б', 0), ('Ж', 1), ('В', 2)].indexed)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == 2 ? 0 : 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: c.fillSecondary,
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
                            style: context.t.labelSmall?.copyWith(fontSize: CalviSize.fsMicro),
                            children: [
                              TextSpan(
                                text: '${_grams(cell.$2)}',
                                style: context.t.titleMedium?.copyWith(fontSize: CalviSize.fsMicro),
                              ),
                              TextSpan(
                                text: ' г',
                                style: context.t.labelSmall?.copyWith(fontSize: CalviSize.fsMicro),
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
