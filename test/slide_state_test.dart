import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/design/slide.dart';
import 'package:calvi/l10n/app_localizations.dart';

/// Кільце навколо кнопки «назад» малювалось двічі на кожному екрані налаштувань.
///
/// Причина була не в самій кнопці. Перехід тримав екран усередині `Stack`, поки
/// тривав рух, а після завершення повертав його нагору без обгортки: для Flutter
/// це інше місце в дереві, стан дитини створювався наново, і все, що програється
/// при появі, програвалось удруге.
///
/// Тому перевіряється саме те, що ламалось: скільки разів дитина оживає.
class _Counter extends StatefulWidget {
  const _Counter({required this.onInit});

  final VoidCallback onInit;

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  @override
  void initState() {
    super.initState();
    widget.onInit();
  }

  @override
  Widget build(BuildContext context) => const SizedBox(width: 100, height: 100);
}

void main() {
  testWidgets('екран не оживає вдруге після завершення переходу', (tester) async {
    var births = 0;

    Widget app(Object value) => MaterialApp(
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      locale: const Locale('uk'),
      home: Slide(
        value: value,
        dir: 1,
        child: _Counter(onInit: () => births++),
      ),
    );

    await tester.pumpWidget(app('root'));
    expect(births, 1, reason: 'перша поява має бути рівно одна');

    // Той самий екран, але тепер із рухом: значення змінилось.
    await tester.pumpWidget(app('panel'));
    expect(births, 2, reason: 'інший екран це справді інший стан');

    // Дати переходу дограти до кінця і ще трохи.
    await tester.pumpAndSettle();
    expect(
      births,
      2,
      reason: 'після завершення переходу екран народився ще раз, і кільце малюється двічі',
    );
  });

  testWidgets('без руху перехід не чіпає стан узагалі', (tester) async {
    var births = 0;

    Widget app(Object value) => MaterialApp(
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      locale: const Locale('uk'),
      home: Slide(
        value: value,
        dir: 0,
        child: _Counter(onInit: () => births++),
      ),
    );

    await tester.pumpWidget(app('one'));
    await tester.pumpWidget(app('one'));
    await tester.pumpAndSettle();

    expect(births, 1);
  });

  testWidgets('повернення назад теж не подвоює', (tester) async {
    var births = 0;

    Widget app(Object value, int dir) => MaterialApp(
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      locale: const Locale('uk'),
      home: Slide(
        value: value,
        dir: dir,
        child: _Counter(onInit: () => births++),
      ),
    );

    await tester.pumpWidget(app('root', 1));
    await tester.pumpWidget(app('panel', 1));
    await tester.pumpAndSettle();
    await tester.pumpWidget(app('root', -1));
    await tester.pumpAndSettle();

    expect(births, 3, reason: 'корінь, панель, корінь: рівно три появи');
  });
}
