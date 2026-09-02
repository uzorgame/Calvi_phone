import 'package:flutter/material.dart';

import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../l10n/app_localizations.dart';

/* Аркуш «дані відновлено».
 *
 * Показується одразу після входу, якщо акаунт стояв у черзі на видалення і
 * цей вхід зняв його з черги. Одна кнопка, бо тут нічого не питають: записи
 * вже повернулись. Два речення, і друге головне: вхід скасував видалення, і
 * якщо людина справді хотіла піти, просити доведеться знову. Без цього вона
 * була б певна, що акаунт зникає, а він живе. */
Future<void> showRestoredSheet(BuildContext context) {
  final l = L.of(context);
  return calviSheet<void>(
    context,
    title: l.restoredTitle,
    info: true,
    doneLabel: l.restoredOk,
    builder: (sheet) => Padding(
      padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 4, CalviSize.gutter, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.restoredBody1, style: sheet.t.bodyMedium),
          const SizedBox(height: 10),
          Text(l.restoredBody2, style: sheet.t.bodyMedium),
        ],
      ),
    ),
  );
}
