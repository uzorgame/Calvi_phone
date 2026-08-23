import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:calvi/screens/camera/sight.dart';

/// Прицілювання сканера.
///
/// Три різні речі, і кожна виправляє свою біду. Вікно читання не дає зловити
/// сусідню пляшку, поки телефон ще їде до потрібної. Перерахунок кутів ставить
/// рамку саме на той код, який показують. А звірка голосами лікує те, через що
/// довідник казав «не знаю такого», а з другої спроби той самий продукт
/// знаходився: перше читання буває хибним на цифру.
void main() {
  const phone = Size(390, 844);

  Barcode at(Rect box) => Barcode(
    rawValue: '4820001234567',
    corners: [box.topLeft, box.topRight, box.bottomRight, box.bottomLeft],
  );

  group('вікно читання', () {
    test('квадратне і всередині екрана', () {
      final w = readingWindow(phone);

      expect(w.width, closeTo(w.height, 0.01), reason: 'QR квадратний');
      expect(w.left, greaterThan(0));
      expect(w.right, lessThan(phone.width));
      expect(w.top, greaterThan(0));
      expect(w.bottom, lessThan(phone.height));
    });

    test('займає далеко не весь кадр', () {
      final w = readingWindow(phone);
      final part = (w.width * w.height) / (phone.width * phone.height);

      /* Саме в цьому вся суть. Сканер, якому дозволено весь кадр, читає що
         завгодно на полиці, і рух рукою приносить чужий продукт. */
      expect(part, lessThan(0.25));
    });

    test('стоїть трохи вище центра', () {
      final w = readingWindow(phone);
      // Телефон тримають нахилено, і рука закриває низ кадру.
      expect(w.center.dy, lessThan(phone.height / 2));
    });
  });

  group('де на екрані код', () {
    test('код у центрі кадру лягає в центр екрана', () {
      // Кадр камери вужчий за екран, тому cover розтягне його по висоті.
      const image = Size(720, 1280);
      final box = Rect.fromCenter(center: const Offset(360, 640), width: 200, height: 200);

      final out = codeRect(at(box), image, phone)!;

      expect(out.center.dx, closeTo(phone.width / 2, 0.5));
      expect(out.center.dy, closeTo(phone.height / 2, 0.5));
      expect(out.width, closeTo(out.height, 0.5), reason: 'квадрат перестав бути квадратом');
    });

    test('cover обрізає порівну, а не розтягує', () {
      /* Кадр іншої форми, ніж екран. Якщо перерахунок піде по кожній осі
         окремо, квадратний код виїде прямокутником, і рамка на ньому сяде
         криво. */
      const image = Size(1280, 720);
      final box = Rect.fromCenter(center: const Offset(640, 360), width: 100, height: 100);

      final out = codeRect(at(box), image, phone)!;
      expect(out.width, closeTo(out.height, 0.5));
    });

    test('код без кутів не рухає рамку', () {
      const image = Size(720, 1280);
      expect(codeRect(const Barcode(rawValue: '1'), image, phone), isNull);
    });

    test('нісенітниця не викидає рамку за екран', () {
      const image = Size(10, 10);
      final box = Rect.fromLTRB(2000, 4000, 2100, 4100);
      expect(codeRect(at(box), image, phone), isNull);
    });
  });

  group('рамка на знайденому коді', () {
    test('обіймає код із запасом', () {
      final code = Rect.fromCenter(center: const Offset(195, 400), width: 80, height: 80);
      final f = frameFor(code, phone);

      expect(f.center, code.center);
      expect(f.width, greaterThan(code.width));
    });

    test('не сходиться в пилинку на дрібному коді', () {
      final tiny = Rect.fromCenter(center: const Offset(195, 400), width: 12, height: 12);
      final f = frameFor(tiny, phone);

      expect(f.width, greaterThanOrEqualTo(phone.shortestSide * 0.3));
    });

    test('не розповзається ширше за екран на великому', () {
      final huge = Rect.fromLTRB(0, 0, 380, 380);
      final f = frameFor(huge, phone);

      expect(f.width, lessThanOrEqualTo(phone.shortestSide * 0.86));
    });
  });

  group('звірка', () {
    test('перемагає найчастіше читання, а не останнє', () {
      /* Саме та біда, через яку довідник казав «не знаю такого». Одна цифра
         прочиталась хибно двічі з семи разів, і якби ми взяли останнє читання,
         пішли б шукати неіснуючий продукт. */
      const votes = {'4820001234567': 5, '4820001234561': 1, '4820001234560': 1};
      expect(verdictOf(votes), '4820001234567');
    });

    test('порожня звірка не дає вироку', () {
      expect(verdictOf(const {}), isNull);
    });

    test('одне читання теж відповідь, якщо іншого не було', () {
      expect(verdictOf(const {'4820001234567': 1}), '4820001234567');
    });

    test('звірка не довша за півтори секунди', () {
      expect(dwell, const Duration(milliseconds: 1500));
    });

    test('впевненість набирається швидше за повну звірку', () {
      /* Шість однакових читань це приблизно третина секунди на звичайній
         камері. Тримати після них телефон нерухомо ще секунду немає за чим. */
      expect(sureHits, greaterThan(2));
      expect(sureHits, lessThan(12));
    });
  });
}
