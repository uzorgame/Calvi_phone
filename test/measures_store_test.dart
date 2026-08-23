import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/day_reader.dart';

/// Заміри сантиметром живуть у базі, а не в памʼяті екрана.
///
/// Раніше в базу їхала тільки вага. Талія, груди й біцепс лягали в список
/// всередині екрана: показувались в аналітиці, рахувались у стрічці, виглядали
/// як записані, і зникали з перезапуском. Людина дізнавалась про це не одразу, а
/// через місяць, коли прийшла подивитись на зміну.
void main() {
  late CalviDb db;

  setUp(() => db = CalviDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('замір переживає перезапуск', () async {
    await db.diaryDao.setMeasure(part: 'waist', cm: 88.5);

    final rows = await db.select(db.measurements).get();
    expect(rows, hasLength(1));
    expect(rows.single.part, 'waist');
    expect(rows.single.cm, 88.5);
  });

  test('другий замір за той самий день заміняє перший', () async {
    /* Правило те саме, що й для ваги. Людина, яка перемірялась двічі, хотіла
       виправити число, а не намалювати зубець на графіку. */
    await db.diaryDao.setMeasure(part: 'waist', cm: 88.5);
    await db.diaryDao.setMeasure(part: 'waist', cm: 87.0);

    final rows = await db.select(db.measurements).get();
    expect(rows, hasLength(1), reason: 'зʼявилась друга точка за один день');
    expect(rows.single.cm, 87.0);
  });

  test('різні частини тіла не витісняють одна одну', () async {
    await db.diaryDao.setMeasure(part: 'waist', cm: 88);
    await db.diaryDao.setMeasure(part: 'chest', cm: 104);

    expect(await db.select(db.measurements).get(), hasLength(2));
  });

  test('замір і вага складаються в один запис дня', () async {
    /* Людина міряє талію і зважується за один підхід, і в стрічці це один
       рядок, а не два: вага стоїть у картці вимірювань першим полем. */
    await db.diaryDao.setWeight(kg: 75);
    await db.diaryDao.setMeasure(part: 'waist', cm: 88);

    final stats = await DayReader(db).watchStats().first;

    expect(stats.measures, hasLength(1));
    expect(stats.measures.single['weightKg'], 75);
    expect(stats.measures.single['waist'], 88);
    expect(stats.measures.single.date, 0, reason: 'замір поїхав не в свій день');
  });

  test('замір їде на сервер', () async {
    /* Брудний рядок це те, за чим синхронізація впізнає незіслане. Без цього
       замір лишився б на телефоні назавжди. */
    await db.diaryDao.setMeasure(part: 'waist', cm: 88);
    expect(await db.syncDao.pendingMeasures(), hasLength(1));
  });

  test('порожньої стрічки на порожній базі', () async {
    final stats = await DayReader(db).watchStats().first;
    expect(stats.measures, isEmpty);
  });
}
