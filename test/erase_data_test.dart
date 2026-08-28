import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/app_scope.dart';
import 'package:calvi/data/chat.dart';
import 'package:calvi/data/local/chat_store.dart';
import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/day_reader.dart';
import 'package:calvi/data/local/profile_store.dart';
import 'package:calvi/data/remote/api.dart';
import 'package:calvi/data/settings.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/settings/panels_body.dart';

/// «Видалити дані»: чистий аркуш у тому самому акаунті.
///
/// На цій кнопці стоїть обіцянка з двох половин: зникає весь щоденник разом із
/// розмовою, а акаунт, токени і профіль лишаються. Перевіряються обидві, бо
/// зрада кожної з них своя: перша лишає людині чужі записи в «новому» житті,
/// друга тихо зносить їй акаунт.
void main() {
  group('місцева половина', () {
    test('щоденник і розмова йдуть, профіль і токени лишаються', () async {
      final db = CalviDb(NativeDatabase.memory());
      addTearDown(db.close);

      await DayReader(db).addTyped(slotId: 'lunch', text: 'борщ');
      await ChatStore(db).save(msg(from: MsgFrom.me, text: 'запиши борщ'));
      await ProfileStore(db).save(initialSettings());
      await db.syncDao.putTokens(balance: 7);

      await db.syncDao.clearDiary();

      final day = await DayReader(db).read(DateTime.now());
      expect(day.meals, isEmpty, reason: 'страви пережили стирання');

      final talk = await ChatStore(db).load();
      expect(talk, isEmpty, reason: 'розмова з Норою пережила стирання');

      expect(await ProfileStore(db).load(), isNotNull, reason: 'стирання щоденника знесло профіль');

      final tokens = await db.syncDao.watchTokens().first;
      expect(tokens?.balance, 7, reason: 'стирання щоденника зʼїло токени');
    });
  });

  group('кнопка в налаштуваннях', () {
    Widget wrap({Future<void> Function()? eraseAll}) => AppScope(
      s: initialSettings(),
      set: (_) {},
      meds: const [],
      setMeds: (_) {},
      eraseAll: eraseAll,
      child: MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: Scaffold(
          body: ProfilePanel(s: initialSettings(), set: (_) {}),
        ),
      ),
    );

    Future<void> reachErase(WidgetTester tester, L l) async {
      await tester.scrollUntilVisible(
        find.text(l.eraseDataTitle),
        160,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(l.eraseDataTitle));
      await tester.pumpAndSettle();
    }

    testWidgets('дорога до стирання веде через два аркуші', (tester) async {
      var erased = 0;
      await tester.pumpWidget(wrap(eraseAll: () async => erased++));
      final l = await L.delegate.load(const Locale('uk'));

      await reachErase(tester, l);

      // Перший аркуш пояснює, що зникне і що лишиться.
      expect(find.text(l.eraseAskTitle), findsOneWidget, reason: 'перший аркуш не відкрився');
      expect(erased, 0, reason: 'стерлось до першої згоди');
      await tester.tap(find.text(l.eraseAskCta));
      await tester.pumpAndSettle();

      // Другий існує рівно для речення про незворотність.
      expect(find.text(l.eraseSureTitle), findsOneWidget, reason: 'другий аркуш не відкрився');
      expect(erased, 0, reason: 'стерлось до другої згоди');
      await tester.tap(find.text(l.eraseSureCta));
      await tester.pumpAndSettle();

      expect(erased, 1, reason: 'дві згоди дані, а стирання не сталось');
      expect(find.text(l.eraseDone), findsOneWidget, reason: 'людині не сказали, що зроблено');
    });

    testWidgets('скасування на другому аркуші не стирає нічого', (tester) async {
      var erased = 0;
      await tester.pumpWidget(wrap(eraseAll: () async => erased++));
      final l = await L.delegate.load(const Locale('uk'));

      await reachErase(tester, l);
      await tester.tap(find.text(l.eraseAskCta));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l.actionCancel));
      await tester.pumpAndSettle();

      expect(erased, 0, reason: 'скасоване стирання все одно стерло');
      expect(find.text(l.eraseDone), findsNothing);
    });

    testWidgets('невдача сервера каже причину людськими словами', (tester) async {
      await tester.pumpWidget(wrap(eraseAll: () async => throw const ApiFailure.offline()));
      final l = await L.delegate.load(const Locale('uk'));

      await reachErase(tester, l);
      await tester.tap(find.text(l.eraseAskCta));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.eraseSureCta));
      await tester.pumpAndSettle();

      expect(
        find.text(l.eraseFailed(l.eraseNoNet)),
        findsOneWidget,
        reason: 'причина невдачі не дійшла до людини',
      );
      expect(find.text(l.eraseDone), findsNothing, reason: 'невдача вдала успіх');
    });

    testWidgets('без бази кнопка чесно мовчить', (tester) async {
      await tester.pumpWidget(wrap());
      final l = await L.delegate.load(const Locale('uk'));

      await reachErase(tester, l);
      await tester.tap(find.text(l.eraseAskCta));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.eraseSureCta));
      await tester.pumpAndSettle();

      // Ні паніки, ні фальшивого «стерто»: стирати в демо нема звідки.
      expect(find.text(l.eraseDone), findsNothing);
    });
  });
}
