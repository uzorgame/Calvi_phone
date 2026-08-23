import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/daos/diary_dao.dart';
import 'package:calvi/data/local/day_reader.dart';
import 'package:calvi/data/remote/api.dart';
import 'package:calvi/data/remote/chat_repository.dart';
import 'package:calvi/data/remote/sync_mapping.dart';

/// Записане Норою має бути на телефоні одразу, а не після подорожі на VPS.
///
/// Дорога була така: телефон питає сервер, сервер пише в свою базу, телефон
/// окремим запитом забирає це назад. Дві мережі між словами «записала яєчню» і
/// появою яєчні в сніданку, і кожен збій на другій давав те саме: відповідь є,
/// запису немає. Саме це людина бачила двічі поспіль і назвала порожнім
/// сніданком.
void main() {
  late CalviDb db;

  setUp(() => db = CalviDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  const serverId = '11111111-2222-3333-4444-555555555555';

  /// Сервер, який відповідає одним записаним яйцем.
  http.Client answering({String id = serverId}) => MockClient((req) async {
    final body = {
      'text': 'Записала два яйця на сніданок.',
      'balance': 29,
      'logged': [
        {
          'id': id,
          'slot': 'breakfast',
          'day': DiaryDao.dayKey(DateTime.now()),
          'name': 'Два яйця',
          'kcal': 143,
          'grams': 110,
          'protein_g': 12.6,
          'fat_g': 9.6,
          'carbs_g': 0.8,
          'icon': 'egg',
          'from': 'reference',
        },
      ],
    };
    return http.Response(
      jsonEncode(body),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });

  test('страва зʼявляється в дні до будь-якої синхронізації', () async {
    final api = CalviApi(base: Uri.parse('https://x.test'), client: answering());
    await ChatRepository(db, api).send(text: 'два яйця', slot: 'breakfast');

    final day = await DayReader(db).read(DateTime.now());

    expect(day.meals, hasLength(1), reason: 'запис не дійшов до картки дня');
    expect(day.meals.single.kcal, 143);
    expect(day.totals.kcal, 143);
  });

  test('той самий запис із синхронізації не подвоюється', () async {
    /* Головна небезпека швидкого запису: рядок лягає двічі, і день показує
       подвійні калорії. Тримається на тому, що ідентифікатор один і той самий,
       а не на здогадках про назву. */
    final api = CalviApi(base: Uri.parse('https://x.test'), client: answering());
    await ChatRepository(db, api).send(text: 'два яйця', slot: 'breakfast');

    await db
        .into(db.meals)
        .insertOnConflictUpdate(
          mealFromChange({
            'id': serverId,
            'seq': 7,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
            'data': {
              'day': DiaryDao.dayKey(DateTime.now()),
              'at': DateTime.now().toUtc().toIso8601String(),
              'tz_offset_min': 180,
              'slot': 'breakfast',
              'name': 'Два яйця',
              'kcal': 143,
              'grams': 110,
              'protein_g': 12.6,
              'fat_g': 9.6,
              'carbs_g': 0.8,
              'icon': 'egg',
              'source': 'chat',
            },
          }),
        );

    final day = await DayReader(db).read(DateTime.now());
    expect(day.meals, hasLength(1), reason: 'та сама страва лягла двічі');
    expect(day.totals.kcal, 143);
  });

  test('рядок від сервера не їде на сервер назад', () async {
    /* Чистий, а не брудний: сервер уже його має. Брудний рядок поїхав би в
       наступному штовханні, і та сама їжа була б записана вдруге, тепер уже з
       іншим номером. */
    final api = CalviApi(base: Uri.parse('https://x.test'), client: answering());
    await ChatRepository(db, api).send(text: 'два яйця', slot: 'breakfast');

    expect(await db.syncDao.pendingMeals(), isEmpty);
  });

  test('страва лягає під ключем того дня, який питає екран', () async {
    /* Та сама розбіжність, що ховалась між телефоном і базою: рядок під ключем
       з часом і поясом не знаходиться жодним екраном. */
    final api = CalviApi(base: Uri.parse('https://x.test'), client: answering());
    await ChatRepository(db, api).send(text: 'два яйця', slot: 'breakfast');

    final row = await db.select(db.meals).getSingle();
    expect(row.day, DiaryDao.dayKey(DateTime.now()));
    expect(row.day.length, 10);
  });

  test('порожня відповідь нічого не пише', () async {
    final api = CalviApi(
      base: Uri.parse('https://x.test'),
      client: MockClient(
        (req) async => http.Response(
          jsonEncode({'text': 'Привіт.', 'balance': 30, 'logged': []}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );

    await ChatRepository(db, api).send(text: 'привіт', slot: 'breakfast');
    expect(await db.select(db.meals).get(), isEmpty);
  });
  test('страва лягає в ту картку, яку назвала людина', () async {
    /* Телефон клав рядок у ту картку, яка була відкрита на екрані. Людина
       казала «запиши на сніданок», сервер чесно писав у сніданок, а на телефоні
       страва зʼявлялась в обіді: відповідь і щоденник розходились на очах. */
    final api = CalviApi(base: Uri.parse('https://x.test'), client: answering());
    await ChatRepository(db, api).send(
      text: 'запиши на сніданок що я їв суші',
      // Відкрита картка обіду, а страва має піти в сніданок.
      slot: 'lunch',
    );

    final row = await db.select(db.meals).getSingle();
    expect(row.slot, 'breakfast', reason: 'запис пішов у відкриту картку');
  });

  test('названий час стає часом запису', () async {
    final at = DateTime.now().copyWith(
      hour: 8,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );

    final api = CalviApi(
      base: Uri.parse('https://x.test'),
      client: MockClient(
        (req) async => http.Response(
          jsonEncode({
            'text': 'Записала.',
            'balance': 29,
            'logged': [
              {
                'id': 'm-8',
                'slot': 'breakfast',
                'day': DiaryDao.dayKey(at),
                'at': at.toUtc().toIso8601String(),
                'name': 'суші',
                'kcal': 387,
                'grams': 220,
                'protein_g': 13,
                'fat_g': 14,
                'carbs_g': 53,
                'icon': 'sushi',
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );

    await ChatRepository(db, api).send(text: 'сьогодні о 8 ранку їв суші', slot: 'dinner');

    final row = await db.select(db.meals).getSingle();
    expect(row.at.hour, 8, reason: 'запис ліг на час надсилання, а не на названий');
    expect(row.slot, 'breakfast');
  });
}
