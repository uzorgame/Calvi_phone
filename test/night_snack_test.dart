import 'package:calvi/data/meal.dart';
import 'package:flutter_test/flutter_test.dart';

/* Куди йде наступний запис за годиною.
 *
 * Уночі це перекус: те, що їдять о другій, сніданком не є, а найближчою за
 * годиною карткою інакше виходив саме він. Межа о пів на пʼяту, і сніданок о
 * пʼятій лишається сніданком. Решта дня як була: найближча картка за своєю
 * годиною. */

void main() {
  final slots = baseSlots.values.toList();
  DateTime at(int h, [int m = 0]) => DateTime(2026, 9, 5, h, m);

  test('від півночі до пів на пʼяту наступний запис іде в перекус', () {
    expect(nearestSlot(slots, at(0))?.id, 'snack');
    expect(nearestSlot(slots, at(2, 15))?.id, 'snack');
    expect(nearestSlot(slots, at(4, 29))?.id, 'snack');
  });

  test('о пів на пʼяту ніч закінчується, і це вже сніданок', () {
    expect(nearestSlot(slots, at(4, 30))?.id, 'breakfast');
    expect(nearestSlot(slots, at(5))?.id, 'breakfast');
    expect(nearestSlot(slots, at(8, 40))?.id, 'breakfast');
  });

  test('день як був: найближча картка за годиною', () {
    expect(nearestSlot(slots, at(13))?.id, 'lunch');
    expect(nearestSlot(slots, at(16))?.id, 'snack');
    expect(nearestSlot(slots, at(19, 30))?.id, 'dinner');
    expect(nearestSlot(slots, at(23, 50))?.id, 'dinner');
  });

  test('день без перекусу вночі бере найближчу картку, а не ламається', () {
    final noSnack = slots.where((s) => s.id != 'snack');
    expect(nearestSlot(noSnack, at(1))?.id, 'breakfast');
  });
}
