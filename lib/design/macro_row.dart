/// Ряд БЖВ: число з нормою через риску, кільце зі знаком, підпис капсом.
///
/// Одна розкладка на три екрани. На дні це три окремі картки, бо там кожен
/// макрос це власний лічильник із власною нормою на сьогодні. На тижні й на
/// аналітиці це середнє, тобто один факт «як воно годувало», тому клітинки
/// стоять під одним дахом. Розкладка при цьому та сама, і це головне: людина
/// вивчила її на головному екрані, і другий спосіб показати ті самі три
/// величини був би другим інтерфейсом.
library;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'icons.dart';
import 'ring.dart';
import 'theme.dart';

/// Одна клітинка: скільки набрано, скільки треба, чим це намалювати.
typedef MacroCell = ({String label, String icon, double value, int goal, Color colour});

class MacroRow extends StatelessWidget {
  const MacroRow({super.key, required this.cells});

  final List<MacroCell> cells;

  @override
  Widget build(BuildContext context) =>
      Row(children: [for (final m in cells) Expanded(child: _Cell(m))]);
}

class _Cell extends StatelessWidget {
  const _Cell(this.m);

  final MacroCell m;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      /* Стискається, а не ріжеться: на вузькому екрані й зі збільшеним
         системним шрифтом хвіст «/ 135 г» просто зникав, і людина бачила
         поточне число без цілі, до якої воно йде. */
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text.rich(
          TextSpan(
            text: '${m.value.round()}',
            children: [
              TextSpan(
                // Той самий хвіст, що на картках дня.
                text: L.of(context).macroOfGrams('${m.goal}${L.of(context).unitG}'),
                style: context.t.labelSmall?.copyWith(fontWeight: FontWeight.w400),
              ),
            ],
          ),
          maxLines: 1,
          style: context.t.headlineMedium?.copyWith(fontSize: 19, fontWeight: FontWeight.w700),
        ),
      ),
      const SizedBox(height: 8),
      CalviRing(
        progress: m.goal == 0 ? 0 : m.value / m.goal,
        size: 46,
        stroke: 5,
        color: m.colour,
        child: CalviIcon(m.icon, size: 15, color: m.colour),
      ),
      const SizedBox(height: 8),
      /* Зменшується, а не втрачає літери.
       *
       * Переносити не можна: другий рядок під однією клітинкою робить увесь ряд
       * вищим за інші дві. Тому тут стояло `overflow: clip`, і довге слово
       * впиралось у край клітинки: італійське «CARBOIDRATI» втрачало хвіст уже
       * на звичайному телефоні, польське «WĘGLOWODANY» на вузькому.
       *
       * `FittedBox` тримає ту саму висоту, бо зменшує шрифт усередині тієї ж
       * коробки. Тим мовам, чиє слово вміщається, він не робить нічого. */
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          m.label,
          maxLines: 1,
          softWrap: false,
          /* Підпис як у приладів: маленький і розріджений. Саме трекінг робить
             із нього підпис шкали, а не маленьке слово. */
          style: context.t.labelSmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 10 * 0.09,
          ),
        ),
      ),
    ],
  );
}
