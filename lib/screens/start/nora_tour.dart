import 'package:flutter/material.dart';

import '../../design/icons.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../l10n/app_localizations.dart';

/// Що вміє Нора: один екран, сім рядків, без прокрутки.
///
/// Тут по черзі стояли дві крайності. Спершу список із кількох слів у рядку: він
/// перелічував можливості і нічого про них не казав. Потім тур на чотири картки
/// з абзацом на кожній: сказано було досить, але за чотири гортання, а гортати
/// після шести питань анкети ніхто не хоче.
///
/// Тут середина. Один екран, який видно цілком: рядок на вміння, у рядку назва
/// і одразу під нею те, як цим користуються. Нічого не ховається за «Далі» і
/// нічого не треба прокручувати, тому екран читається одним поглядом, а не
/// послідовністю.
///
/// **Фрази справжні.** Це ті самі підказки, які потім ідуть по колу в полі
/// вводу застосунку. Удруге людина побачить їх уже на місці, і вони спрацюють
/// як нагадування, а не як нова інформація.
///
/// Значків PREMIUM тут немає навмисно. Продавати підписку посеред знайомства
/// означає почати розмову з рахунку.
class NoraTour extends StatelessWidget {
  const NoraTour({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);

    /* Колір на рядок, щоб сім не злились в один стовпчик. Береться з тієї ж
       палітри, що БЖВ на головному екрані: інших кольорів у застосунку немає, і
       заводити їх заради одного екрана означало б розмити всю решту. */
    final can = <({String icon, Color tone, String what, String how})>[
      (icon: 'mic', tone: c.protein, what: l.tourVoice, how: l.tourVoiceHow),
      /* Камера робить три різні речі, і штрих-код тут не дрібниця: він єдиний
         дає числа з пачки, а не оцінку. */
      (icon: 'camera', tone: c.fats, what: l.tourCamera, how: l.tourCameraHow),
      (icon: 'note', tone: c.carbs, what: l.tourMore, how: l.tourMoreHow),
      /* Памʼять щоденника, не та сама, що постійна нижче. Ця про записи: якою
         була страва і скільки її було минулого разу. */
      (icon: 'history', tone: c.accent, what: l.tourDiary, how: l.tourDiaryHow),
      // А ця про людину: алергії, дієта, що не їсть. Живе між розмовами.
      (icon: 'brain', tone: c.success, what: l.tourMemory, how: l.tourMemoryHow),
      (icon: 'chart', tone: c.fats, what: l.tourWeek, how: l.tourWeekHow),
      /* Справжня можливість, а не обіцянка: у промті Нори є інструмент
         `app_guide`, і про екрани вона відповідає з нього, а не з памʼяті. */
      (icon: 'compass', tone: c.button, what: l.tourGuide, how: l.tourGuideHow),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CalviSize.gutter),
          child: Text(
            l.tourTitle,
            style: context.t.displayLarge?.copyWith(
              fontSize: 34,
              letterSpacing: 34 * -0.03,
              height: 1.12,
            ),
          ),
        ),
        const SizedBox(height: 20),

        /* Рядки розтягуються на всю висоту, що лишилась, а не стоять на своїй.
           Так екран заповнюється однаково і на високому телефоні, і на
           низькому, і прокрутки не зʼявляється ніде: сім рядків, які не
           вміщаються, це той самий список, тільки обрізаний. */
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: CalviSize.gutter),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [for (final x in can) _Row(icon: x.icon, tone: x.tone, what: x.what, how: x.how)],
            ),
          ),
        ),

        /* Кнопка на кінці не «Далі», а «Готово»: за нею вже щоденник, і
           обіцяти ще один крок означало б обманути на самому кінці. */
        Padding(
          padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 12, CalviSize.gutter, 16),
          child: CalviButton(label: l.actionDone, onTap: onDone),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.tone, required this.what, required this.how});

  final String icon;
  final Color tone;
  final String what;
  final String how;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // Той самий колір, тільки блідий: плитка має тримати знак, а не
            // сперечатися з ним за увагу.
            color: tone.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CalviIcon(icon, size: 20, color: tone),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                what,
                style: context.t.bodyLarge?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 2),
              /* Один рядок. Довший переносився б і ламав ритм семи однакових
                 рядків, а на низькому телефоні з'їв би висоту, якої немає. */
              Text(
                how,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.t.bodyMedium?.copyWith(
                  fontSize: CalviSize.fsMicro,
                  color: c.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
