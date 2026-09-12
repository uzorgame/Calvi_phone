import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:calvi/data/allergens.dart';
import 'package:calvi/data/day.dart';
import 'package:calvi/data/settings.dart' show Lang, langOptions;

/// Кожен рядок кожної мови, а не той екран, на який встигли натиснути.
///
/// Перевірка очима не масштабується: сім мов на два десятки екранів це сто
/// сорок знімків, і саме на сто сороковому око пропускає англійське слово.
/// Тому мови перевіряються там, де вони живуть: у зібраних `app_<мова>.arb`,
/// у довіднику алергенів і в назвах місяців. Ці три місця і є все, що
/// застосунок показує людині своєю мовою.
void main() {
  /// Мови, які застосунок пропонує людині. Береться з самого переліку, тому
  /// нова мова потрапляє під перевірку, щойно її туди додали.
  final langs = [
    for (final option in langOptions)
      if (option != Lang.system) option.name,
  ];

  const template = 'en';

  Map<String, dynamic> arb(String lang) {
    final file = File('lib/l10n/app_$lang.arb');
    expect(file.existsSync(), isTrue, reason: 'немає зібраного app_$lang.arb');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  /// Тільки рядки, які бачить людина: службові ключі з собачкою це опис для
  /// перекладача, а не напис.
  Map<String, String> visible(Map<String, dynamic> body) => {
    for (final e in body.entries)
      if (!e.key.startsWith('@') && e.value is String) e.key: e.value as String,
  };

  final cyrillic = RegExp(r'[Ѐ-ӿ]');
  final holder = RegExp(r'\{(\w+)[,}]');

  test('перелік мов і зібрані файли не розходяться', () {
    expect(langs, contains(template));
    expect(langs.length, greaterThan(1));
  });

  test('у кожній мові стільки ж ключів, скільки в шаблоні', () {
    final want = visible(arb(template)).keys.toSet();
    for (final lang in langs) {
      final have = visible(arb(lang)).keys.toSet();
      expect(want.difference(have), isEmpty, reason: '$lang: немає перекладу для цих ключів');
      expect(have.difference(want), isEmpty, reason: '$lang: зайві ключі, яких немає в шаблоні');
    }
  });

  /* Найдешевший спосіб зловити недоперекладений рядок: кирилиця в мові, яка
     нею не пишеться. Саме так виглядав би забутий український текст. */
  test('поза українською кирилиці немає', () {
    for (final lang in langs) {
      if (lang == 'uk') continue;
      final bad = <String>[];
      visible(arb(lang)).forEach((key, value) {
        if (cyrillic.hasMatch(value)) bad.add('$key: «$value»');
      });
      expect(bad, isEmpty, reason: '$lang: кирилиця в перекладі\n${bad.join('\n')}');
    }
  });

  test('жоден рядок не порожній', () {
    for (final lang in langs) {
      final empty = [
        for (final e in visible(arb(lang)).entries)
          if (e.value.trim().isEmpty) e.key,
      ];
      expect(empty, isEmpty, reason: '$lang: порожні рядки');
    }
  });

  /* Плейсхолдер, загублений при перекладі, це не косметика: замість ваги або
     дати людина побачить порожнє місце, і побачить його лише в тій мові. */
  test('плейсхолдери збігаються з шаблоном', () {
    final want = visible(arb(template));
    for (final lang in langs) {
      final have = visible(arb(lang));
      final bad = <String>[];
      want.forEach((key, english) {
        final a = holder.allMatches(english).map((m) => m.group(1)).toSet();
        final b = holder.allMatches(have[key] ?? '').map((m) => m.group(1)).toSet();
        if (a.length != b.length || !a.every(b.contains)) {
          bad.add('$key: очікували $a, маємо $b');
        }
      });
      expect(bad, isEmpty, reason: '$lang: плейсхолдери розійшлись\n${bad.join('\n')}');
    }
  });

  /* Довгий рядок, однаковий з англійським, майже завжди означає, що речення
     просто скопіювали. Короткі збіги законні: «kcal», «Pro», «HIIT».

     Довжина міряється по самих словах, без плейсхолдерів і розділових:
     «{protein} / {fat} / {carbs} g» має тридцять символів, а слово в ньому одне,
     і воно однакове в половині європейських мов. */
  test('довгі рядки не скопійовані з англійської', () {
    final want = visible(arb(template));
    for (final lang in langs) {
      if (lang == template) continue;
      final have = visible(arb(lang));
      final same = [
        for (final e in want.entries)
          if (e.value.replaceAll(holder, '').replaceAll(RegExp(r'[^\p{L}]', unicode: true), '').length > 25 &&
              have[e.key] == e.value)
            '${e.key}: «${e.value}»',
      ];
      expect(same, isEmpty, reason: '$lang: рядки лишились англійськими\n${same.join('\n')}');
    }
  });

  /* Умови користування і політика приватності існують англійською, і тільки нею.
   *
   * `lib/data/legal.dart` тримає по одній версії кожного документа, і її бачить
   * кожна мова, українська теж. Єдиний наш рядок усередині того вікна це «коли
   * оновлено», і він мусить лишатись англійським: перекладене «Zaktualizowano»
   * ставило одне слово мовою читача посеред англійського юридичного тексту, а
   * сам рядок дати виходив наполовину однією мовою, наполовину іншою.
   *
   * Так і сталося: шість доданих мов переклали його, поки цього не помітили. */
  test('рядок дати в юридичних документах усюди англійський', () {
    final want = visible(arb(template))['legalUpdated'];
    expect(want, 'Updated {date}');

    for (final lang in langs) {
      expect(
        visible(arb(lang))['legalUpdated'],
        want,
        reason: '$lang: документи існують лише англійською, отже і цей рядок теж',
      );
    }
  });

  /* Алергени живуть не в ARB, а у власному довіднику, і саме там мова колись
     мовчки падала в англійську. */
  test('кожен алерген має назву, групу і синоніми кожною мовою', () {
    final bad = <String>[];
    for (final a in allergens) {
      for (final lang in langs) {
        if (!a.names.containsKey(lang)) bad.add('${a.id}: немає назви для $lang');
        if (!a.groups.containsKey(lang)) bad.add('${a.id}: немає групи для $lang');
        if (!a.akas.containsKey(lang)) bad.add('${a.id}: немає списку синонімів для $lang');
      }
    }
    expect(bad, isEmpty, reason: bad.join('\n'));
  });

  test('назви алергенів поза українською без кирилиці', () {
    final bad = <String>[];
    for (final a in allergens) {
      for (final lang in langs) {
        if (lang == 'uk') continue;
        final name = a.names[lang] ?? '';
        final group = a.groups[lang] ?? '';
        final aka = (a.akas[lang] ?? const []).join(', ');
        if (cyrillic.hasMatch('$name $group $aka')) bad.add('${a.id} ($lang): $name / $group / $aka');
      }
    }
    expect(bad, isEmpty, reason: 'кирилиця в довіднику алергенів\n${bad.join('\n')}');
  });

  /* Рядок під назвою показує синоніми **своєї** мови. Саме тут була вада, коли
     під іспанською назвою стояло «земляний горіх, groundnut». */
  test('показані синоніми беруться з мови інтерфейсу', () {
    for (final lang in langs) {
      dataLang = lang;
      final peanut = allergenById('peanut')!;
      expect(
        peanut.akaShown,
        equals(peanut.akas[lang]),
        reason: '$lang: під назвою показується не свій список',
      );
    }
    dataLang = 'uk';
  });

  /* Зіставлювач складу, навпаки, шукає всіма мовами одразу: на іспанській банці
     буває `soy lecithin`, на українській теж. */
  test('пошук по складу бачить синоніми всіх мов', () {
    final soy = allergenById('soy')!;
    for (final lang in langs) {
      for (final word in soy.akas[lang] ?? const <String>[]) {
        expect(soy.aka, contains(word), reason: 'синонім «$word» ($lang) випав з пошуку');
      }
    }
  });

  /* Дати збираються не з ARB, а зі списків у `day.dart`, і мова, якої там
     немає, мовчки дістає англійську. */
  test('місяці й дні тижня є в кожній мові', () {
    final byLang = <String, String>{};
    for (final lang in langs) {
      dataLang = lang;
      final months = [for (var m = 1; m <= 12; m++) monthName(m)];
      final short = [for (var m = 1; m <= 12; m++) monthShort(m)];
      final week = weekdaysFromMonday(lang);

      expect(months.toSet().length, 12, reason: '$lang: назви місяців повторюються');
      expect(short.toSet().length, 12, reason: '$lang: скорочення місяців повторюються');
      expect(week.length, 7, reason: '$lang: не сім днів тижня');
      expect(week.toSet().length, 7, reason: '$lang: дні тижня повторюються');

      byLang[lang] = months.join('|');
    }
    dataLang = 'uk';

    /* Дві мови з однаковим списком місяців означають, що одна з них падає в
       іншу. Саме так виглядала іспанська до правки. */
    final seen = <String, String>{};
    byLang.forEach((lang, months) {
      final twin = seen[months];
      expect(twin, isNull, reason: '$lang і $twin мають однакові місяці, отже одна падає в іншу');
      seen[months] = lang;
    });
  });

  test('дата словами зібрана за правилами своєї мови', () {
    const want = {
      'en': '2 September',
      'uk': '2 вересня',
      'es': '2 de septiembre',
      'it': '2 settembre',
      'de': '2. September',
      'fr': '2 septembre',
      'pt': '2 de setembro',
      'pl': '2 września',
      /* Чеська ставить крапку після числа, як німецька, а місяць у родовому,
         як польська: «2. září». Обидва правила разом більше ніде не стоять. */
      'cs': '2. září',
    };
    for (final lang in langs) {
      dataLang = lang;
      expect(dayMonth(2, 9), want[lang], reason: '$lang: дата зібрана не за правилами мови');
    }
    dataLang = 'uk';
  });

  /* Мова, забута в нативному боці, не видно нізвідки.
   *
   * Дарт має перевірку ключів, а Swift і `Info.plist` не мають нічого: там мова
   * це рядок у словнику, і забутий рядок тихо падає в англійську. Так годинник
   * говорив би англійською на чеському телефоні, а App Store показував би на
   * одну мову менше, ніж застосунок уміє. Тому перелік мов звіряється з кожним
   * місцем, де він продубльований.
   *
   * Перевіряється текст файлів, а не зібраний застосунок: Swift на цій машині
   * не збирається, а розходження видно вже в рядках. */
  test('кожна мова застосунку є в нативних переліках', () {
    String text(String path) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: 'немає $path');
      return file.readAsStringSync();
    }

    final words = text('ios/CalviWatch/Words.swift');
    final bridge = text('ios/Runner/WatchBridge.swift');
    final plist = text('ios/Runner/Info.plist');
    final xcode = text('ios/watch_target.rb');

    for (final lang in langs) {
      expect(words, contains('"$lang": Words('), reason: '$lang: годинник не має своїх слів');
      expect(bridge, contains('"$lang": "$lang-'), reason: '$lang: годинник не має свого розпізнавача');
      expect(bridge, contains('"$lang": ['), reason: '$lang: телефон не відповість годиннику цією мовою');
      expect(plist, contains('<string>$lang</string>'), reason: '$lang: пакет про мову не оголошує');
      expect(xcode, contains(' $lang'), reason: '$lang: теки .lproj не підключено до цілі');
      expect(
        File('ios/Runner/$lang.lproj/InfoPlist.strings').existsSync(),
        isTrue,
        reason: '$lang: немає теки .lproj, і App Store мови не побачить',
      );
    }
  });
}
