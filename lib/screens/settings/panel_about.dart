import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../design/shell.dart';
import '../menu.dart';
import '../../design/theme.dart';
import '../../l10n/app_localizations.dart';

/// Хто зробив цей застосунок і яка це версія.
///
/// Потрібне не для краси. Людина, яка пише про поламку, першим ділом питається,
/// «яка у вас версія», і без цього екрана відповісти нічим: у налаштуваннях
/// стояв вписаний руками рядок «Calvi 0.1 · демо інтерфейсу», який застарів у
/// день першої збірки й відтоді просто брехав.
///
/// Версія читається із самого пакета, а не з константи в коді. Константу
/// забувають оновити рівно тоді, коли вона потрібна: у розпал випуску.
const developer = 'Nahreba Mykhailo';

/// Пошта підтримки. Та сама, що на сайті.
const supportEmail = 'calvi.labs@gmail.com';

class AboutPanel extends StatefulWidget {
  const AboutPanel({super.key, this.onBack});

  /// Як панель закривається. Вона живе всередині налаштувань, а не поверх них.
  final VoidCallback? onBack;

  @override
  State<AboutPanel> createState() => _AboutPanelState();
}

class _AboutPanelState extends State<AboutPanel> {
  /* Порожньо, поки пакет не відповів. Це кадр або два, і показувати в цей час
     нулі гірше, ніж не показувати нічого: нуль виглядає як відповідь. */
  String _version = '';

  @override
  void initState() {
    super.initState();
    unawaitedVersion();
  }

  Future<void> unawaitedVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _version = '${info.version} (${info.buildNumber})');
  }

  /* Пошта відкривається поштовим застосунком. Документи звідси прибрані: вони
     стоять власними рядками в налаштуваннях і повним текстом, а не посиланням у
     браузер. */
  Future<void> _open(String url) async {
    final at = Uri.parse(url);
    if (await canLaunchUrl(at)) {
      await launchUrl(at, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return CalviScreen(
      trailing: const CalviMenuButton(),
      onBack: widget.onBack,
      title: l.aboutTitle,
      foot: CalviButton(
        label: l.actionDone,
        onTap: () => (widget.onBack ?? Navigator.of(context).pop)(),
      ),
      children: [
        CalviSection(
          title: 'Calvi',
          bare: true,
          trail: 0,
          children: [
            CalviFacts(
              inset: false,
              rows: [
                (l.aboutVersion, _version.isEmpty ? '…' : _version),
                (l.aboutDeveloper, developer),
              ],
              note: l.aboutText,
            ),
          ],
        ),
        CalviSection(
          title: l.aboutContact,
          children: [
            CalviRow(
              icon: 'send',
              first: true,
              title: l.aboutWrite,
              value: supportEmail,
              onTap: () => _open('mailto:$supportEmail'),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Center(child: Text('© 2026 Calvi · $developer', style: context.t.labelSmall)),
        ),
      ],
    );
  }
}
