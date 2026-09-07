import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/legal.dart';
import '../../design/icons.dart';
import '../../design/shell.dart';
import '../menu.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../l10n/app_localizations.dart';

/// Умови користування і політика приватності, повним текстом усередині.
///
/// Раніше обидва рядки відкривали браузер. Так було чесно щодо розходження
/// текстів, але не щодо людини: без мережі прочитати те, з чим погодився,
/// неможливо, а магазин вимагає, щоб умови були доступні із самого застосунку.
///
/// Розходження вирішене інакше. Слова лежать в одному місці, у демці, і звідти
/// їх бере і сайт, і `tools/legal.mjs`, який пише `lib/data/legal.dart`. Правка
/// в одному файлі міняє всі три.
class LegalPanel extends StatelessWidget {
  const LegalPanel({super.key, required this.doc, this.onBack});

  final LegalDoc doc;

  /// Як панель закривається. Вона живе всередині налаштувань, а не поверх них.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return CalviScreen(
      trailing: const CalviMenuButton(),
      onBack: onBack,
      title: doc.title,
      foot: CalviButton(
        label: L.of(context).actionDone,
        onTap: () => (onBack ?? Navigator.of(context).pop)(),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              LegalText(doc: doc),
              const SizedBox(height: 28),
              _OnTheWeb(doc: doc),
            ],
          ),
        ),
      ],
    );
  }
}

/// Та сама редакція на сайті, посиланням у кінці документа.
///
/// Не «повна версія»: повна вона й тут, слово в слово з одного джерела. Адреса
/// потрібна для того, чого застосунок не вміє. Її можна переслати,
/// роздрукувати, відкрити на комп'ютері й комусь показати; на неї посилаються
/// магазини і листи. Документ, який існує лише всередині застосунку, не можна
/// нікому дати.
///
/// **У кінці, а не вгорі.** Посилання на початку читається як «справжній текст
/// десь там», і людина йде в браузер, не прочитавши того, що вже перед нею. У
/// кінці воно зустрічає того, хто дочитав.
///
/// **Карткою, а не підкресленим словом.** Після трьох екранів суцільної прози
/// око вже не бачить підкресленого рядка, а картка з рамкою читається як дія,
/// тобто саме тим, чим вона є. Той самий крій, що в рядках налаштувань.
class _OnTheWeb extends StatelessWidget {
  const _OnTheWeb({required this.doc});

  final LegalDoc doc;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => unawaited(
        launchUrl(Uri.parse(doc.url), mode: LaunchMode.externalApplication),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.fillSecondary,
          border: Border.all(color: c.cardBorder),
          borderRadius: BorderRadius.circular(CalviSize.rCard),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    L.of(context).legalOnTheWeb,
                    style: context.t.bodyLarge?.copyWith(
                      fontSize: CalviSize.fsBody,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  /* Адреса видима навмисно: посилання, під яким не видно, куди
                     воно веде, у юридичному документі виглядає рівно так, як не
                     треба. Без «https://»: воно нічого не додає і забирає
                     місце, якого на телефоні немає. */
                  Text(
                    doc.url.replaceFirst('https://', ''),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.t.labelSmall?.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.card),
              child: CalviIcon('chevron', size: 15, color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Сам текст документа, без рамки навколо.
///
/// Окремо від панелі, бо той самий документ показується двома способами: цілим
/// екраном із налаштувань і аркушем знизу на екрані входу. Два рендери одного
/// тексту розійшлися б у відступах першими, а в словах другими.
class LegalText extends StatelessWidget {
  const LegalText({super.key, required this.doc});

  final LegalDoc doc;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = context.t;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          doc.lede,
          style: t.bodyMedium?.copyWith(fontSize: CalviSize.fsBody, color: c.text, height: 1.5),
        ),
        const SizedBox(height: 8),
        Text(
          L.of(context).legalUpdated(doc.updated),
          style: t.labelSmall?.copyWith(color: c.faint),
        ),

        for (final part in doc.parts) ...[
          const SizedBox(height: 26),
          Text(part.h, style: t.titleMedium),
          if (part.p != null) ...[const SizedBox(height: 8), _Para(part.p!)],
          if (part.list != null) ...[
            const SizedBox(height: 8),
            for (final item in part.list!) _Bullet(item),
          ],
          if (part.tail != null) ...[const SizedBox(height: 8), _Para(part.tail!)],
        ],
      ],
    );
  }
}

/// Документ аркушем знизу, для екрана входу.
///
/// Людина ставить галочку згоди там, де немає навігації: вести її на окремий
/// екран означало б забрати з-під неї той самий екран, на якому вона щойно
/// збиралась увійти. Аркуш піднімається поверх і закривається туди ж.
Future<void> legalSheet(BuildContext context, LegalDoc doc) => calviSheet<void>(
  context,
  title: doc.title,
  doneLabel: L.of(context).actionClose,
  info: true,
  builder: (sheet) => ConstrainedBox(
    /* Три чверті екрана: аркуш має лишити видимим те, з чого його відкрили,
       інакше він читається як новий екран, а не як шухляда поверх. */
    constraints: BoxConstraints(maxHeight: MediaQuery.of(sheet).size.height * 0.75),
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 4, CalviSize.gutter, 16),
      child: LegalText(doc: doc),
    ),
  ),
);

/// Абзац документа. Читається довше за підпис під числом, тому інтерліньяж свій.
class _Para extends StatelessWidget {
  const _Para(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: context.t.labelSmall?.copyWith(fontWeight: FontWeight.w400, height: 1.6));
}

/// Пункт списку: крапка, жирний початок, продовження звичайним.
class _Bullet extends StatelessWidget {
  const _Bullet(this.item);

  final LegalItem item;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final style = context.t.labelSmall?.copyWith(fontWeight: FontWeight.w400, height: 1.6);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            // На висоту першого рядка, а не на середину пункту: пункт може бути
            // на три рядки, і крапка посередині читалась би як окремий знак.
            padding: const EdgeInsets.only(top: 8, right: 12, left: 2),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.faint),
            ),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  if (item.b != null)
                    TextSpan(
                      text: item.b,
                      style: TextStyle(color: c.text, fontWeight: FontWeight.w600),
                    ),
                  if (item.t != null) TextSpan(text: item.t),
                ],
              ),
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}
