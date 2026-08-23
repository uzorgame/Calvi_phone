import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Жодного напису українською просто в коді екрана.
///
/// Застосунок має дві мови, і зашитий рядок означає, що людина з англійською
/// побачить український посеред англійського екрана. Знайшлось саме так: «78%
/// пройдено» в аналітиці, «3 хв» під тренуванням, «620 з 2100» на головній
/// картці. Виглядає як дрібниця рівно доти, доки застосунок не показали
/// комусь за межами країни.
///
/// Дані сюди не входять: назви алергенів і страв лежать полями `nameUk`,
/// `groupUk`, `akaUk` поруч зі своїми англійськими, і це не зашитий текст, а
/// довідник, у якому обидві мови рівноправні.
void main() {
  test('в екранах немає написів повз переклад', () {
    final cyrillic = RegExp(r"'[^']*[а-яіїєґА-ЯІЇЄҐ][^']*'");
    final data = RegExp(r'(nameUk|groupUk|akaUk|labelUk|Uk):');
    final found = <String>[];

    for (final dir in ['lib/screens', 'lib/design']) {
      for (final file in Directory(dir).listSync(recursive: true)) {
        if (file is! File || !file.path.endsWith('.dart')) continue;

        final lines = file.readAsLinesSync();
        var inBlockComment = false;

        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          final trimmed = line.trimLeft();

          // Коментарі не рахуються: пояснення пишуться українською навмисно.
          if (inBlockComment) {
            if (trimmed.contains('*/')) inBlockComment = false;
            continue;
          }
          if (trimmed.startsWith('//')) continue;
          if (trimmed.startsWith('/*')) {
            if (!trimmed.contains('*/')) inBlockComment = true;
            continue;
          }
          if (trimmed.startsWith('*')) continue;
          if (data.hasMatch(line)) continue;

          if (cyrillic.hasMatch(line)) {
            found.add('${file.path}:${i + 1}  ${trimmed.trim()}');
          }
        }
      }
    }

    expect(found, isEmpty, reason: 'написи повз переклад:\n${found.join('\n')}');
  });

  test('довгого тире немає ніде', () {
    /* Домовленість про письмо в цьому проєкті: довге тире не вживаємо ніде.
       Сам символ тут кодом, а не собою: інакше перевірка спіткнулась би об себе. */
    const dash = '\u2014';
    final found = <String>[];

    for (final dir in ['lib', 'l10n', 'test']) {
      for (final file in Directory(dir).listSync(recursive: true)) {
        if (file is! File) continue;
        if (!file.path.endsWith('.dart') && !file.path.endsWith('.arb')) continue;

        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (lines[i].contains(dash)) found.add('${file.path}:${i + 1}');
        }
      }
    }

    expect(found, isEmpty, reason: 'довге тире тут:\n${found.join('\n')}');
  });
}
