import 'package:flutter/material.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/meal.dart';
import 'package:calvi/data/local/database.dart';
import 'package:calvi/data/local/day_reader.dart';
import 'package:calvi/design/theme.dart';
import 'package:calvi/l10n/app_localizations.dart';
import 'package:calvi/screens/today/meal_card.dart';

/// Запис без чисел не вдає, ніби в ньому нуль калорій.
///
/// Це був найдорожчий різновид помилки на цьому екрані: рядок, за яким довідник
/// нічого не знайшов, лягав із впевненим нулем. Денний підсумок виходив
/// заниженим, а людина бачила число і вірила йому, бо виглядало все як робочий
/// екран.
void main() {
  test('рядок без жодного числа читається як «ще рахують»', () async {
    final db = CalviDb(NativeDatabase.memory());
    addTearDown(db.close);

    final reader = DayReader(db);
    final id = await reader.addTyped(slotId: 'dinner', text: 'Плов бабусин');

    var day = await reader.read(DateTime.now());
    var meal = day.meals.firstWhere((m) => m.id == id);
    expect(meal.pending, isTrue, reason: 'нуль калорій виданий за справжнє число');

    /* А щойно числа зʼявились, рядок перестає чекати: прапорець виводиться з
       самих чисел, тому окремо його гасити нема чого і нема чому розійтись. */
    await db.diaryDao.applyFood(
      id,
      kcal: 420,
      protein: 12,
      fat: 14,
      carbs: 58,
      grams: 400,
      canonicalName: 'плов',
      icon: 'plate',
    );

    day = await reader.read(DateTime.now());
    meal = day.meals.firstWhere((m) => m.id == id);
    expect(meal.pending, isFalse, reason: 'записана страва все ще чекає');
    expect(meal.kcal, 420);
  });

  test('вписане рукою не чекає нікого', () async {
    final db = CalviDb(NativeDatabase.memory());
    addTearDown(db.close);

    final reader = DayReader(db);
    final id = await reader.addManual(
      slotId: 'dinner',
      title: 'Плов',
      kcal: 480,
      grams: 350,
      protein: 20,
      fat: 15,
      carbs: 60,
    );

    final day = await reader.read(DateTime.now());
    final meal = day.meals.firstWhere((m) => m.id == id);

    expect(meal.pending, isFalse, reason: 'власні числа людини виглядають як очікування');
    expect((meal.kcal, meal.grams, meal.protein, meal.fat, meal.carbs), (480, 350, 20, 15, 60));
  });

  test('закладка питання переживає перезапуск і знаходить чернетку', () async {
    /* Закладка «чернетка чекає на це питання» жила в памʼяті екрана і губилась
       із перезапуском: відповідь про вагу записувала страву, а її вічно
       зайнятий двійник лишався в картці назавжди. Тепер вона в базі. */
    final db = CalviDb(NativeDatabase.memory());
    addTearDown(db.close);

    final reader = DayReader(db);
    final id = await reader.addTyped(slotId: 'dinner', text: 'три бутерброди із шинкою');

    await db.diaryDao.bindAsk(id, 'ask-7');
    expect(await db.diaryDao.draftForAsk('ask-7'), id, reason: 'закладка не знайшла чернетку');
    expect(
      await db.diaryDao.draftForAsk('ask-8'),
      isNull,
      reason: 'чуже питання знайшло чужу чернетку',
    );

    // Прибрана чернетка не воскресає через свою закладку.
    await db.diaryDao.removeMeal(id);
    expect(
      await db.diaryDao.draftForAsk('ask-7'),
      isNull,
      reason: 'закладка вказує на прибраний рядок',
    );
  });

  testWidgets('довге натискання по чернетці кличе прибирання, по записаному ні', (tester) async {
    Meal? erased;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: Scaffold(
          body: MealCard(
            slot: baseSlots['dinner']!,
            meals: const [
              Meal(
                id: 'a',
                icon: 'plate',
                title: 'Завислий',
                time: '10:12',
                slotId: 'dinner',
                pending: true,
              ),
              Meal(
                id: 'b',
                icon: 'plate',
                title: 'Порахований',
                time: '12:19',
                slotId: 'dinner',
                kcal: 320,
              ),
            ],
            open: true,
            onToggle: () {},
            onAdd: (_) {},
            onManual: (_) {},
            noraCan: true,
            onErase: (m) => erased = m,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    /* Записана страва це вже правда людини: зносити її довгим натисканням без
       меню було б надто легко. У чернетки ж іншого виходу немає. */
    await tester.longPress(find.text('Порахований'));
    await tester.pumpAndSettle();
    expect(erased, isNull, reason: 'довге натискання зносить порахований запис');

    await tester.longPress(find.text('Завислий'));
    await tester.pumpAndSettle();
    expect(erased?.id, 'a', reason: 'чернетку не можна прибрати');
  });

  testWidgets('картка малює очікування, а не нуль', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('uk'),
        theme: calviLightTheme,
        home: Scaffold(
          body: MealCard(
            slot: baseSlots['dinner']!,
            meals: const [
              Meal(
                id: 'x',
                icon: 'plate',
                title: 'Плов бабусин',
                time: '19:40',
                slotId: 'dinner',
                pending: true,
              ),
            ],
            open: true,
            onToggle: () {},
            onAdd: (_) {},
            onManual: (_) {},
            noraCan: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final l = await L.delegate.load(const Locale('uk'));
    expect(find.text('···'), findsOneWidget, reason: 'на місці невідомого числа стоїть число');
    expect(find.text(l.mealThinking), findsOneWidget);
    expect(find.text('0'), findsNothing, reason: 'нуль калорій усе ще малюється');
  });
}
