import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/day.dart';
import 'package:calvi/data/day_stats.dart';
import 'package:calvi/data/settings.dart';

/// Серія днів у нормі.
///
/// Набрати рівно норму неможливо, тому вдалий день це вікно, а не число. Ширина
/// в кожної цілі своя і несиметрична: тому, хто набирає, перебір допомагає, а
/// тому, хто худне, недобір не шкодить так само.
void main() {
  SettingsState profile({required Direction direction, int norm = 2000}) =>
      initialSettings().copyWith(direction: direction, kcalManual: norm);

  DayStats withDays(Map<int, int> kcalByDay) => DayStats(
    totals: {
      for (final e in kcalByDay.entries)
        e.key: DayTotals(kcal: e.value, protein: 0, fat: 0, carbs: 0),
    },
    water: const {},
    weights: const {},
    demo: false,
  );

  /* Вікно одне на застосунок: те саме, що фарбує кружечки в стрічці
     (`kcalSlack`). Доти серія мала власне, вужче, і тиждень зелених днів стояв
     над кільцем із нулем. */
  group('вікно вдалого дня', () {
    test('схуднути: від норми мінус 400 до самої норми', () {
      const norm = 2000;
      for (final (kcal, want) in [
        (2000, true),
        (1700, true),
        (1600, true),
        (2001, false),
        (1599, false),
        (1200, false),
      ]) {
        expect(
          dayHit(kcal: kcal, norm: norm, direction: Direction.lose),
          want,
          reason: '$kcal ккал при нормі $norm',
        );
      }
    });

    test('тримати: плюс-мінус 400', () {
      const norm = 2000;
      for (final (kcal, want) in [
        (2000, true),
        (2400, true),
        (1600, true),
        (2401, false),
        (1599, false),
      ]) {
        expect(
          dayHit(kcal: kcal, norm: norm, direction: Direction.keep),
          want,
          reason: '$kcal ккал',
        );
      }
    });

    test('набрати: норма і все, що вище', () {
      const norm = 2000;
      for (final (kcal, want) in [(2000, true), (2500, true), (3200, true), (1999, false)]) {
        expect(
          dayHit(kcal: kcal, norm: norm, direction: Direction.gain),
          want,
          reason: '$kcal ккал',
        );
      }
    });

    /* Тренування віднімається від зʼїденого, а норма стоїть на місці: день на
       2600 із пробіжкою на 700 це день на 1900. */
    test('спалене на тренуванні знімається зі зʼїденого', () {
      expect(dayHit(kcal: 2600, norm: 2000, direction: Direction.lose), isFalse);
      expect(dayHit(kcal: 2600, burned: 700, norm: 2000, direction: Direction.lose), isTrue);
      expect(dayOver(kcal: 2600, burned: 700, norm: 2000, direction: Direction.lose), isFalse);
    });
  });

  group('серія', () {
    test('рахується від учора і обривається на першому промаху', () {
      final stats = withDays({-1: 1900, -2: 1800, -3: 1750, -4: 2400, -5: 1900});
      expect(stats.streakOn(profile(direction: Direction.lose)), 3);
    });

    /* Сьогодні ще триває, тому подовжити серію воно не може: інакше число
       стрибало б після кожного обіду. */
    test('сьогоднішній день не подовжує серію', () {
      final stats = withDays({0: 1900, -1: 1900, -2: 1900});
      expect(
        stats.streakOn(profile(direction: Direction.lose)),
        2,
        reason: 'сьогодні дорахувалось до серії, хоч день ще не скінчився',
      );
    });

    /* А от обірвати вміє. Перебір необоротний: зʼїдене не роззʼїдається, і день,
       який перебрав об одинадцятій ранку, до вечора вдалим уже не стане. */
    test('перебір сьогодні обриває серію одразу', () {
      final stats = withDays({0: 2400, -1: 1900, -2: 1900});
      expect(
        stats.streakOn(profile(direction: Direction.lose)),
        0,
        reason: 'перебір уже стався, а серія показує вчорашнє число цілий день',
      );
    });

    test('те саме для тих, хто тримає вагу', () {
      final stats = withDays({0: 2500, -1: 2000, -2: 2000});
      expect(stats.streakOn(profile(direction: Direction.keep)), 0);

      final ok = withDays({0: 2400, -1: 2000, -2: 2000});
      expect(ok.streakOn(profile(direction: Direction.keep)), 2, reason: '2400 ще в межах +400');
    });

    /* Для набору перебору не існує: більше за ціль це і є ціль, тому сьогодні
       обірвати серію там нічим. */
    test('для набору перебір серію не обриває', () {
      final under = withDays({0: 2400, -1: 2200, -2: 2200});
      expect(under.streakOn(profile(direction: Direction.gain)), 2);

      final over = withDays({0: 3000, -1: 2200, -2: 2200});
      expect(over.streakOn(profile(direction: Direction.gain)), 2);
    });

    /* Спалене рахується і тут: серія бачить день так само, як кружечок. */
    test('тренування рятує день і в серії', () {
      final plain = withDays({-1: 2600, -2: 1900});
      expect(plain.streakOn(profile(direction: Direction.lose)), 0);

      final trained = DayStats(
        totals: {
          -1: const DayTotals(kcal: 2600, protein: 0, fat: 0, carbs: 0),
          -2: const DayTotals(kcal: 1900, protein: 0, fat: 0, carbs: 0),
        },
        burned: const {-1: 700},
        water: const {},
        weights: const {},
        demo: false,
      );
      expect(trained.streakOn(profile(direction: Direction.lose)), 2);
    });

    /* Недобір оборотний: до півночі ще можна доїсти, тому мовчимо. */
    test('недобір сьогодні серію не чіпає', () {
      final stats = withDays({0: 400, -1: 1900, -2: 1900});
      expect(stats.streakOn(profile(direction: Direction.lose)), 2);
    });

    /* Порожній день це не витриманий день, а забутий. */
    test('день без записів обриває серію', () {
      final stats = withDays({-1: 1900, -3: 1900, -4: 1900});
      expect(stats.streakOn(profile(direction: Direction.lose)), 1);
    });

    test('недоїдання не зараховується як успіх худнення', () {
      final stats = withDays({-1: 900, -2: 1900});
      expect(
        stats.streakOn(profile(direction: Direction.lose)),
        0,
        reason: 'тисяча під нормою це голодування, а не витриманий день',
      );
    });

    test('одна й та сама історія дає різну серію під різні цілі', () {
      final stats = withDays({-1: 2200, -2: 2100, -3: 2050});

      expect(stats.streakOn(profile(direction: Direction.keep)), 3, reason: 'усі три в межах 300');
      expect(stats.streakOn(profile(direction: Direction.lose)), 0, reason: 'усі три над нормою');
      expect(stats.streakOn(profile(direction: Direction.gain)), 3, reason: 'усі три в межах +500');
    });
  });
}
