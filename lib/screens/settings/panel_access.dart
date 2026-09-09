import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../design/shell.dart';
import '../../l10n/app_localizations.dart';
import '../menu.dart';

/// What the app may touch on this phone, and where to change it.
///
/// Four rows, each with its state and one tap to act on it. The phone asks for
/// a permission the first time it is needed, and after that the only place to
/// change the answer is the system settings; this panel is the door to them,
/// so nobody has to hunt for Calvi in a list of apps.
///
/// The watch is why this panel exists. It records what was said and the phone
/// turns it into words with the speech recogniser, which needs the same
/// permission dictation asks for. Someone who never dictated on the phone has
/// never been asked, and the watch has no way to ask: a background app cannot
/// show the sheet. The answer is given here.
class AccessPanel extends StatefulWidget {
  const AccessPanel({super.key, this.onBack});

  /// How the panel closes: settings put their list back, no route pops.
  final VoidCallback? onBack;

  @override
  State<AccessPanel> createState() => _AccessPanelState();
}

class _AccessPanelState extends State<AccessPanel> with WidgetsBindingObserver {
  final _status = <Permission, PermissionStatus>{};

  static const _rows = [
    (Permission.microphone, 'mic'),
    (Permission.speech, 'note'),
    (Permission.camera, 'camera'),
    (Permission.notification, 'bell'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _read();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /* The person comes back from the system settings: what they changed there
     must show here without a second visit. */
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _read();
  }

  Future<void> _read() async {
    for (final (permission, _) in _rows) {
      final now = await permission.status;
      if (!mounted) return;
      setState(() => _status[permission] = now);
    }
  }

  /* Not asked yet: ask, and the system shows its sheet. Anything else: the
     system settings, because the sheet is shown once and never again, and
     turning a granted permission off is only possible there. */
  Future<void> _tap(Permission permission) async {
    /* Asked fresh, not from the cache: the person may have just come back
       from the system settings, and a stale "not asked" would show the sheet
       that iOS no longer shows, so the tap would do nothing. */
    final now = await permission.status;
    if (now.isDenied) {
      await permission.request();
    } else {
      await openAppSettings();
    }
    await _read();
  }

  String _word(L l, Permission permission) {
    final now = _status[permission];
    if (now == null) return '…';
    if (now.isGranted || now.isLimited || now.isProvisional) return l.accessOn;
    if (now.isPermanentlyDenied || now.isRestricted) return l.accessOff;
    return l.accessAsk;
  }

  String _title(L l, Permission permission) => switch (permission) {
    Permission.microphone => l.accessMic,
    Permission.speech => l.accessSpeech,
    Permission.camera => l.accessCamera,
    _ => l.accessNotify,
  };

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return CalviScreen(
      trailing: const CalviMenuButton(),
      onBack: widget.onBack,
      title: l.setAccess,
      foot: CalviButton(label: l.actionDone, onTap: () => (widget.onBack ?? Navigator.of(context).pop)()),
      children: [
        CalviSection(
          children: [
            for (final (i, (permission, icon)) in _rows.indexed)
              CalviRow(
                icon: icon,
                first: i == 0,
                title: _title(l, permission),
                value: _word(l, permission),
                onTap: () => _tap(permission),
              ),
          ],
        ),
        CalviNote(l.accessNote),
      ],
    );
  }
}
