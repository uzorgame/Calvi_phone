import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/profile_store.dart';
import 'package:calvi/data/remote/api.dart';
import 'package:calvi/data/remote/chat_repository.dart';
import 'package:calvi/data/remote/sync_mapping.dart';
import 'package:calvi/data/settings.dart';

/// Памʼять доходить від Нори до сторінки памʼяті й переживає перезапуск.
///
/// Досі памʼять була екраном без сховища: сторінка є, рядок «Памʼятати: …» в
/// підказці моделі є, а між ними немає нічого. Людина казала «запамʼятай, що
/// мене звати Міша», Нора ввічливо обіцяла і не мала куди це подіти.
void main() {
  late CalviDb db;

  setUp(() => db = CalviDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('запамʼятане з відповіді доходить до відповіді', () async {
    final api = CalviApi(
      base: Uri.parse('https://x.test'),
      client: MockClient(
        (req) async => http.Response(
          jsonEncode({
            'text': 'Запамʼятала.',
            'balance': 29,
            'logged': [],
            'remembered': [
              {'id': 'n1', 'text': 'звати Міша', 'pinned': true, 'name': 'Міша'},
            ],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );

    final answer = await ChatRepository(
      db,
      api,
    ).send(text: 'запамʼятай, що мене звати Міша', slot: 'lunch');

    expect(answer.remembered, hasLength(1));
    expect(answer.remembered.single.text, 'звати Міша');
    expect(answer.remembered.single.name, 'Міша');
  });

  test('памʼять переживає перезапуск', () async {
    final store = ProfileStore(db);
    await store.save(
      emptySettings().copyWith(
        memory: const [Memo(id: 'n1', text: 'не їсть свинину', pinned: true)],
        addressAs: 'Міша',
      ),
    );

    final back = (await store.load())!;
    expect(back.memory, hasLength(1));
    expect(back.memory.single.text, 'не їсть свинину');
    expect(back.memory.single.pinned, true);
    expect(back.addressAs, 'Міша');
  });

  test('памʼять їде на сервер і назад тим самим списком', () async {
    final store = ProfileStore(db);
    await store.save(
      emptySettings().copyWith(
        memory: const [Memo(id: 'n1', text: 'звати Міша', pinned: true)],
        addressAs: 'Міша',
      ),
    );

    final row = await db.select(db.profile).getSingle();
    final wire = profileToWire(row);

    expect(wire['address_as'], 'Міша');
    expect((wire['memory'] as List).single['text'], 'звати Міша');

    /* І назад: те, що приїхало з сервера, має лягти на диск без втрат. */
    await db
        .into(db.profile)
        .insertOnConflictUpdate(
          profileFromWire({
            ...wire,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          }, id: row.id),
        );

    final back = (await store.load())!;
    expect(back.memory.single.text, 'звати Міша');
    expect(back.addressAs, 'Міша');
  });

  test('порожня памʼять не ламає читання', () async {
    final store = ProfileStore(db);
    await store.save(emptySettings());

    final back = (await store.load())!;
    expect(back.memory, isEmpty);
    expect(back.addressAs, isNull);
  });

  test('зіпсований рядок памʼяті це порожня памʼять, а не падіння', () async {
    final store = ProfileStore(db);
    await store.save(emptySettings());
    await db.customStatement("update profile set memory = 'не json'");

    final back = (await store.load())!;
    expect(back.memory, isEmpty);
  });
}
