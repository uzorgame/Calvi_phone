import 'dart:math' as math;
import 'dart:ui';

import 'package:mobile_scanner/mobile_scanner.dart';

/// Скільки триває звірка, поки рамка тримається за код.
///
/// Півтори секунди, і жодною більше. Причина не в акуратності, а в тому, що
/// перше читання коду часто хибне на цифру-дві: тоді довідник чесно каже «не
/// знаю такого», а з другої спроби той самий код читається правильно і продукт
/// знаходиться. Одне читання це здогад, кілька однакових це відповідь.
const dwell = Duration(milliseconds: 1500);

/// Скільки однакових читань підряд достатньо, щоб не чекати всю звірку.
const sureHits = 6;

/// Скільки без жодного читання означає, що код пішов з кадру.
const lostAfter = Duration(milliseconds: 450);

/// Вікно читання: та сама рамка, що людина бачить.
///
/// Це головне тут. Сканер, якому дозволено читати весь кадр, ловить сусідню
/// пляшку, поки телефон ще їде до потрібної: махнув рукою, і в застосунку вже
/// чужий продукт. Читається рівно те, на що наведено.
///
/// Квадрат, а не смуга: QR квадратний, а штрихкод усередині квадрата теж
/// поміщається. Трохи вище центра, бо телефон тримають нахилено і рука закриває
/// низ кадру.
Rect readingWindow(Size view) {
  final side = view.shortestSide * 0.68;
  return Rect.fromCenter(
    center: Offset(view.width / 2, view.height * 0.42),
    width: side,
    height: side,
  );
}

/// Де на екрані лежить код, який щойно прочитали.
///
/// Кути приходять у системі координат кадру з камери, а намалювати рамку треба
/// поверх зображення, розтягнутого через [BoxFit.cover]. Перерахунок саме
/// такий, як робить сам `cover`: один спільний масштаб по обох осях, і те, що
/// не влізло, зрізається порівну з двох боків.
///
/// Порожньо означає «не знаю»: кутів немає, кадр порожній, або вийшло щось
/// явно не з цього екрана. Тоді рамка просто лишається на місці, і це чесніше,
/// ніж смикнути її кудись навмання.
Rect? codeRect(Barcode code, Size image, Size view) {
  if (code.corners.length < 3) return null;
  if (image.isEmpty || view.isEmpty) return null;

  var left = double.infinity;
  var top = double.infinity;
  var right = double.negativeInfinity;
  var bottom = double.negativeInfinity;

  for (final c in code.corners) {
    left = math.min(left, c.dx);
    top = math.min(top, c.dy);
    right = math.max(right, c.dx);
    bottom = math.max(bottom, c.dy);
  }
  if (right <= left || bottom <= top) return null;

  final scale = math.max(view.width / image.width, view.height / image.height);
  final dx = (view.width - image.width * scale) / 2;
  final dy = (view.height - image.height * scale) / 2;

  final out = Rect.fromLTRB(
    left * scale + dx,
    top * scale + dy,
    right * scale + dx,
    bottom * scale + dy,
  );

  // Явна нісенітниця: кадр повернутий не так, як ми думали, або кути з іншого
  // світу. Краще не рухати рамку, ніж поставити її за межі екрана.
  final canvas = Offset.zero & view;
  if (!canvas.inflate(view.shortestSide * 0.25).contains(out.center)) return null;
  if (out.width > view.width * 1.2 || out.height > view.height * 1.2) return null;

  return out;
}

/// Рамка, яку насправді малюють: не менша за розумну і не більша за екран.
///
/// Код може бути завбільшки з ніготь, і рамка на ньому виглядала б як пилинка,
/// а не як прицілювання. Тому вона обіймає код із запасом і не сходиться менше
/// певного розміру.
Rect frameFor(Rect code, Size view) {
  final want = math.max(code.longestSide * 1.35, view.shortestSide * 0.3);
  final side = math.min(want, view.shortestSide * 0.86);
  return Rect.fromCenter(center: code.center, width: side, height: side);
}

/// Що вирішила звірка: код, який бачили найчастіше.
///
/// Не останній і не перший, а саме найчастіший. Помилки читання випадкові й
/// різні, а правильне читання одне й те саме, тому воно й перемагає.
String? verdictOf(Map<String, int> votes) {
  String? best;
  var most = 0;
  for (final e in votes.entries) {
    if (e.value > most) {
      most = e.value;
      best = e.key;
    }
  }
  return best;
}
