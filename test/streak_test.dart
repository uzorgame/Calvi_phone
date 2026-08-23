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

  group('вікно вдалого дня', () {
    test('схуднути: від норми мінус 300 до самої норми', () {
      const norm = 2000;
      for (final (kcal, want) in [
        (2000, true),
        (1700, true),
        (1850, true),
        (2001, false),
        (1699, false),
        (1200, false),
      ]) {
        expect(
          dayHit(kcal: kcal, norm: norm, direction: Direction.lose),
          want,
          reason: '$kcal ккал при нормі $norm',
        );
      }
    });

    test('тримати: плюс-мінус 300', () {
      const norm = 2000;
      for (final (kcal, want) in [
        (2000, true),
        (2300, true),
        (1700, true),
        (2301, false),
        (1699, false),
      ]) {
        expect(
          dayHit(kcal: kcal, norm: norm, direction: Direction.keep),
          want,
          reason: '$kcal ккал',
        );
      }
    });

    test('набрати: від норми до плюс 500', () {
      const norm = 2000;
      for (final (kcal, want) in [(2000, true), (2500, true), (2501, false), (1999, false)]) {
        expect(
          dayHit(kcal: kcal, norm: norm, direction: Direction.gain),
          want,
          reason: '$kcal ккал',
        );
      }
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
      final stats = withDays({0: 2400, -1: 2000, -2: 2000});
      expect(stats.streakOn(profile(direction: Direction.keep)), 0);

      final ok = withDays({0: 2250, -1: 2000, -2: 2000});
      expect(ok.streakOn(profile(direction: Direction.keep)), 2, reason: '2250 ще в межах +300');
    });

    /* Для набору верхня межа інша, але правило те саме: понад +500 необоротно. */
    test('для набору обриває тільки понад плюс 500', () {
      final under = withDays({0: 2400, -1: 2200, -2: 2200});
      expect(under.streakOn(profile(direction: Direction.gain)), 2);

      final over = withDays({0: 2600, -1: 2200, -2: 2200});
      expect(over.streakOn(profile(direction: Direction.gain)), 0);
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
