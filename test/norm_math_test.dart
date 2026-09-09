import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/settings.dart';

/* Арифметика норми, перевірена перебором, а не прикладом.
 *
 * Формула коротка, і саме тому в неї легко внести помилку, яка на стандартному
 * профілі не видно нічого: вісімдесят кілограмів, двадцять шість років, сто
 * сімдесят вісім сантиметрів дають красиве число майже за будь-якого
 * коефіцієнта. Ламається воно на краях, і саме краї тут і проходяться.
 *
 * Перебір бере всі відповіді, які анкета взагалі дозволяє дати, і на кожній
 * звіряє три речі: базовий обмін із першоджерелом, підлогу норми і те, що
 * розкладка на макроси лишається можливою.
 */
void main() {
  /// Кожна відповідь, яку людина може дати в анкеті, у розумному кроці.
  Iterable<SettingsState> everyone() sync* {
    for (final sex in [Sex.m, Sex.f]) {
      for (var age = 16; age <= 90; age += 6) {
        for (var h = 140; h <= 210; h += 10) {
          for (var w = 40.0; w <= 180; w += 10) {
            for (final act in activityLevels) {
              for (final dir in Direction.values) {
                for (var pace = 0.2; pace <= 1.21; pace += 0.2) {
                  yield initialSettings().copyWith(
                    sex: sex,
                    age: age,
                    heightCm: h,
                    weightKg: w,
                    goalStartKg: w,
                    targetKg: dir == Direction.gain ? w + 6 : w - 6,
                    direction: dir,
                    pace: pace,
                    activity: act.v,
                  );
                }
              }
            }
          }
        }
      }
    }
  }

  test('базовий обмін це Міффлін-Сан Жеор, слово в слово', () {
    for (final s in everyone()) {
      /* Незалежний перерахунок із опублікованої формули 1990 року, а не виклик
         того самого коду: перевірка, яка питає код про код, погоджується з ним
         завжди, зокрема й тоді, коли він неправий. */
      final ref =
          10 * s.goalStartKg +
          6.25 * s.heightCm -
          5 * s.age +
          (s.sex == Sex.m ? 5 : -161);

      expect(
        bmr(s),
        closeTo(ref, 0.001),
        reason: '${s.sex.name} ${s.age} р, ${s.heightCm} см, ${s.goalStartKg} кг',
      );
    }
  });

  test('нижче за підлогу не опускає нікого', () {
    for (final s in everyone()) {
      final floor = s.sex == Sex.f ? 1200 : 1500;
      expect(calcKcal(s), greaterThanOrEqualTo(floor), reason: 'темп ${s.pace}, вага ${s.weightKg}');
    }
  });

  /* Головна перевірка цього файлу.
   *
   * Доти білок рахувався як 1.7 г на кілограм без стелі, і в 958 випадках із
   * 280 800 вуглеводи виходили відʼємними: у важкої людини з нормою на підлозі
   * сам білок коштував більше за всю норму. Найгірше було мінус вісімдесят
   * девʼять грамів, і це число зберігалось у профіль. */
  test('розкладка завжди можлива: вуглеводів не менше нуля', () {
    var tightest = 1e9;
    late SettingsState worst;

    for (final s in everyone()) {
      final m = macrosFor(s);
      expect(m.protein, greaterThan(0));
      expect(m.fat, greaterThan(0));
      expect(
        m.carbs,
        greaterThanOrEqualTo(0),
        reason:
            '${s.sex.name} ${s.age} р, ${s.heightCm} см, ${s.goalStartKg} кг, '
            'темп ${s.pace}: норма ${calcKcal(s)}, білок ${m.protein}, жири ${m.fat}',
      );

      if (m.carbs < tightest) {
        tightest = m.carbs.toDouble();
        worst = s;
      }
    }

    /* І не просто невідʼємні, а з запасом: 37% норми на вуглеводи це те, що
       лишається після стелі білка і частки жирів. Найтісніший випадок має бути
       помітно вищим за нуль, інакше стеля стоїть надто високо. */
    expect(
      tightest,
      greaterThan(20),
      reason: 'найтісніше: ${worst.goalStartKg} кг, норма ${calcKcal(worst)}',
    );
  });

  test('макроси сходяться в норму', () {
    for (final s in everyone()) {
      final m = macrosFor(s);
      final sum = m.protein * 4 + m.fat * 9 + m.carbs * 4;
      /* Три округлення до цілого грама дають кілька калорій різниці, і це
         нормально. Десяток, ні. */
      expect(sum, closeTo(calcKcal(s), 12), reason: 'норма ${calcKcal(s)}, разом $sum');
    }
  });

  test('стеля не чіпає звичайного профілю', () {
    // Стандартна людина анкети: 80 кг, 178 см, 26 років, помірна активність.
    final s = initialSettings().copyWith(
      sex: Sex.m,
      age: 26,
      heightCm: 178,
      weightKg: 80,
      goalStartKg: 80,
      targetKg: 74,
      direction: Direction.lose,
      pace: 0.5,
      activity: 1.55,
    );

    final m = macrosFor(s);
    expect(m.protein, 136, reason: '1.7 г на кілограм, стеля мовчить');
    expect(calcKcal(s), 2220);
  });
}
