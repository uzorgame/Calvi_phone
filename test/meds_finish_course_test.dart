import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/day_reader.dart';
import 'package:calvi/data/local/meds_store.dart';
import 'package:calvi/data/meds.dart';
import 'package:calvi/data/notifications.dart';
import 'package:calvi/data/repeat.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/screens/meds/meds_screen.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// «Закінчити курс» замість «Видалити препарат».
///
/// Кнопка стирала препарат разом з історією: дні, коли людина його справді
/// пила, ставали такими, ніби вона не пила його ніколи. Тепер курс отримує
/// останній день, зникає з головного екрана і зі сповіщень, і лишається в
/// «Минулих» разом з усіма галочками.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));
  final week = today.subtract(const Duration(days: 7));
  final tomorrow = today.add(const Duration(days: 1));

  Med magnesium({String? end}) => Med(
    id: 'm1',
    name: 'Магній B6',
    dose: 2,
    form: MedForm.tab,
    remind: true,
    repeat: const DailyRepeat(),
    startDay: dayKeyOf(week),
    endDay: end,
    times: const [MedTime(at: '08:00', taken: false)],
  );

  group('база', () {
    late CalviDb db;
    late MedsStore meds;
    late DayReader days;

    setUp(() {
      db = CalviDb(NativeDatabase.memory());
      meds = MedsStore(db);
      days = DayReader(db);
    });
    tearDown(() => db.close());

    test('закінчений курс не зникає з бази і тягне за собою галочки', () async {
      await meds.save(magnesium());
      await meds.setTaken(medId: 'm1', at: '08:00', taken: true, on: week);
      await meds.setTaken(medId: 'm1', at: '08:00', taken: true, on: yesterday);

      // Так само, як тисне екран: останній день, не видалення.
      await meds.save(magnesium(end: dayKeyOf(today)));

      final back = await meds.load();
      expect(back, hasLength(1), reason: 'препарат зник із застосунку');
      expect(back.single.endDay, dayKeyOf(today));

      expect((await days.read(week)).medTakes, {
        'm1|08:00',
      }, reason: 'стерта історія тижневої давнини');
      expect((await days.read(yesterday)).medTakes, {'m1|08:00'}, reason: 'стерта вчорашня доза');
    });

    test('відновлення курсу знімає останній день', () async {
      await meds.save(magnesium(end: dayKeyOf(today)));
      final was = (await meds.load()).single;

      await meds.save(was.copyWith(clearEndDay: true));
      expect((await meds.load()).single.endDay, isNull);
    });
  });

  group('день', () {
    final done = magnesium(end: dayKeyOf(today));

    test('картка зникає назавтра, а сьогодні і в минулому лишається', () {
      /* Сьогодні це останній день курсу: дози, відмічені зранку, не мають
         зникати ввечері разом із натисканням кнопки. */
      expect(medsOn([done], today), hasLength(1), reason: 'останній день курсу пропав');
      expect(medsOn([done], yesterday), hasLength(1), reason: 'вчорашній день втратив препарат');
      expect(medsOn([done], week), hasLength(1), reason: 'минулий день втратив препарат');
      expect(medsOn([done], tomorrow), isEmpty, reason: 'картка лишилась назавтра');
    });

    test('кнопка закінчує курс сьогоднішнім днем', () {
      /* Через ту саму функцію, яку кличе екран. Тест, що будує препарат руками,
         не помітив, як правку в лямбді зʼїв форматувальник, і в збірку пішло
         «вчора»: сьогоднішня картка зникала разом із випитою зранку дозою. */
      final after = finishCourse([magnesium()], 'm1').single;
      expect(after.endDay, dayKeyOf(today));
      expect(reviveCourse([after], 'm1').single.endDay, isNull);
    });

    test('картка стоїть на кожному дні курсу, і після закінчення теж', () {
      /* Курс із 1 по 20 вересня, закінчений 20-го: усі двадцять днів лишаються
         днями курсу і показують, чи була доза прийнята саме тоді. */
      final start = today.subtract(const Duration(days: 19));
      final course = magnesium().copyWith(startDay: dayKeyOf(start));
      final closed = finishCourse([course], 'm1');

      for (var i = 0; i < 20; i++) {
        final at = start.add(Duration(days: i));
        expect(
          medsOnDay(closed, at, const {}),
          hasLength(1),
          reason: 'день ${dayKeyOf(at)} втратив картку',
        );
      }
      expect(medsOnDay(closed, tomorrow, const {}), isEmpty, reason: 'картка лишилась назавтра');
      expect(medsOnDay(closed, start.subtract(const Duration(days: 1)), const {}), isEmpty);
    });

    test('день із відміченою дозою тримає картку навіть поза розкладом', () {
      /* Людина могла випити не за графіком або змінити розклад посеред курсу.
         День, у якому доза стоїть, належить препарату незалежно від розкладу. */
      final wrongDay = today.weekday == DateTime.monday ? DateTime.tuesday : DateTime.monday;
      final weekly = magnesium().copyWith(repeat: WeekdayRepeat(days: [wrongDay]));

      expect(medsOnDay([weekly], today, const {}), isEmpty);
      expect(medsOnDay([weekly], today, const {'m1|08:00'}), hasLength(1));
    });

    test('у списку препаратів курс закривається того ж дня', () {
      expect(medsAhead([done]), isEmpty, reason: 'курс досі серед активних');
      expect(medsAhead([magnesium()]), hasLength(1), reason: 'живий курс зник');
    });
  });

  group('сповіщення', () {
    late _Spy spy;
    late Notifications bell;

    setUp(() {
      spy = _Spy();
      bell = Notifications(sink: spy);
    });

    test('закінчений курс більше не дзвонить', () async {
      await bell.reschedule(
        reminders: const [],
        meds: [magnesium(end: dayKeyOf(today))],
        medsRemind: true,
      );
      expect(spy.planned, isEmpty, reason: 'закритий курс лишився у черзі');
    });

    test('активний курс дзвонить, і закритий поруч йому не заважає', () async {
      await bell.reschedule(
        reminders: const [],
        meds: [
          magnesium(),
          magnesium(end: dayKeyOf(today)).copyWith(name: 'Вітамін D3'),
        ],
        medsRemind: true,
      );
      expect(spy.planned, hasLength(1));
      expect(spy.planned.single.title, 'Магній B6');
    });

    test('замовкає в той самий день, коли курс закінчено', () async {
      /* Кнопку тиснуть саме для того, щоб більше не нагадувало. Чекати до
         півночі означало б ще один дзвінок про те, що людина вже закрила. */
      await bell.reschedule(
        reminders: const [],
        meds: [magnesium(end: dayKeyOf(today))],
        medsRemind: true,
      );
      expect(spy.planned, isEmpty);
    });
  });

  group('екран', () {
    Future<void> open(WidgetTester tester, List<Med> meds, {void Function(String)? revive}) =>
        tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: L.localizationsDelegates,
            supportedLocales: L.supportedLocales,
            locale: const Locale('uk'),
            theme: calviLightTheme,
            home: MedsScreen(
              meds: meds,
              onToggle: (_, _) {},
              onSave: (_) {},
              onFinish: (_) {},
              onRevive: revive ?? (_) {},
            ),
          ),
        );

    testWidgets('курс «по понеділках» видно і в той день, коли його не пʼють', (tester) async {
      /* Він випадав з екрана цілком: сьогодні не приймається, тож у список не
         потрапляв, а закінченим не був, тож і в «Минулих» його не було. Людина
         заводила препарат у середу і бачила «Тут порожньо». */
      final wrongDay = today.weekday == DateTime.monday ? DateTime.tuesday : DateTime.monday;
      final weekly = magnesium().copyWith(repeat: WeekdayRepeat(days: [wrongDay]));

      await open(tester, [weekly]);
      await tester.pumpAndSettle();

      expect(find.text('Тут порожньо. Додай препарат, і я нагадаю в потрібний час.'), findsNothing);
      expect(find.text('Магній B6'), findsWidgets, reason: 'курс зник з екрана');
      expect(find.text('Сьогодні прийомів немає'), findsOneWidget);
    });

    testWidgets('закінчений курс лежить у «Минулих» і відкривається', (tester) async {
      await open(tester, [magnesium(end: dayKeyOf(today))]);
      await tester.pumpAndSettle();

      expect(find.text('Магній B6'), findsNothing, reason: 'закритий курс серед активних');

      await tester.tap(find.text('Минулі'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Магній B6'));
      await tester.pumpAndSettle();

      expect(find.text('Відновити курс'), findsOneWidget);
    });

    testWidgets('«Відновити курс» доповідає нагору', (tester) async {
      final revived = <String>[];
      await open(tester, [magnesium(end: dayKeyOf(today))], revive: revived.add);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Минулі'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Магній B6'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Відновити курс'));
      await tester.pumpAndSettle();

      expect(revived, ['m1']);
    });
  });
}

class _Spy implements NotificationSink {
  final planned = <({String title, String body, String from, Repeats repeats})>[];

  @override
  Future<void> ready() async {}

  @override
  Future<void> clearAll() async => planned.clear();

  @override
  Future<bool> ask() async => true;

  @override
  Future<bool> granted() async => true;

  @override
  set onTap(void Function(String from)? handler) {}

  @override
  Future<String?> launchedFrom() async => null;

  @override
  Future<void> put({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    required Repeats repeats,
    required String from,
  }) async {
    planned.add((title: title, body: body, from: from, repeats: repeats));
  }
}
