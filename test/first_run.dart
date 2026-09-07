import 'package:flutter_test/flutter_test.dart';

/* Прохід першого запуску, спільний для тестів, які перевіряють не його.
 *
 * До дня звідси йде півтора десятка тестів, і доти кожен ніс власну копію
 * цього проходу. Порядок екранів змінився один раз, і зламались вони всі
 * одночасно, кожен своїм рядком. Тепер порядок описаний в одному місці, і
 * наступна зміна коштуватиме однієї правки.
 */

/// Вітання догралось і саме пішло далі. За ним стоїть вхід.
///
/// Кнопок на вітанні немає: воно нічого не питає. Тому тут не дотик, а час.
Future<void> welcomeOut(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
}

/// Від першого кадру до дня, дорогою того, хто не заводить акаунта.
///
/// Вхід стоїть першим, тому «далі без акаунту» тут не кінець, а початок: за ним
/// іде анкета з семи екранів і знайомство з Норою.
Future<void> toDay(WidgetTester tester) async {
  await welcomeOut(tester);

  await tester.tap(find.text('Далі без акаунту'));
  await tester.pumpAndSettle();

  // Про тебе, Одиниці, Вага, Ціль, Темп, Спосіб життя, Норма.
  // Settle rather than a fixed pump: the switcher keeps the outgoing step in
  // the tree for the length of the slide, and two «Далі» is an ambiguous tap.
  for (var i = 0; i < 7; i++) {
    await tester.tap(find.text('Далі'));
    await tester.pumpAndSettle();
  }

  // Остання картка: що вміє Нора. За нею вже щоденник.
  await tester.tap(find.text('Готово'));
  /* Спершу такт, тоді до спокою. Сам по собі `pumpAndSettle` тут не досить:
     день заходить із затримкою, і поки вона не минула, доводити до спокою
     нічого. А без нього стрічка дат ще не стала на місце, і тест, який тицяє в
     число, не влучає нікуди. */
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}
