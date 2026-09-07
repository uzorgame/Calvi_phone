import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/* Камери телефона, один раз за весь час роботи застосунку. Їх набір не
   міняється, а `availableCameras()` це окремий похід у платформу, і він стояв
   на шляху кожного перемикання режиму: видошукач народжується заново і питав
   те саме знову. */
List<CameraDescription>? _known;

/// The real viewfinder, when there is one.
///
/// Three states, and they look different on purpose. While the camera is
/// answering, a dark surface: the picture fades in over it the moment it is
/// there, and nothing painted stands in for it in between. When there is no
/// camera at all, the painted stand-in for good: that is what the web build
/// shows, what a denied permission falls back to, and what a phone without a
/// camera gets. The chrome around it works the same in all three.
///
/// The controller lives here rather than in the screen because it is the only
/// thing that has to be torn down on the way out, and a camera left running is a
/// camera the person can see in their status bar.
class LiveFeed extends StatefulWidget {
  const LiveFeed({
    super.key,
    required this.fallback,
    required this.loading,
    required this.onReady,
    this.onClosed,
  });

  /// Drawn for good when there is no camera to show: web, desktop, a refusal.
  final Widget fallback;

  /// Drawn while the camera is answering. Dark and quiet: the picture fades in
  /// over it, and a painted plate flashing here read as a glitch.
  final Widget loading;

  /// Handed the controller once it is running, so the screen can drive the torch
  /// and take the picture.
  final ValueChanged<CameraController?> onReady;

  /// Called once the camera is really released on the way out, so the next
  /// reader of the same lens can open it. A fixed delay guessed at this before,
  /// and guessed long.
  final VoidCallback? onClosed;

  @override
  State<LiveFeed> createState() => _LiveFeedState();
}

class _LiveFeedState extends State<LiveFeed> with WidgetsBindingObserver {
  CameraController? _cam;
  bool _tried = false;

  /// Between asking for the camera and getting it: the way out then has to wait
  /// for `_open` to finish and close what it opened.
  bool _opening = false;

  /// No camera will come: the stand-in is the whole picture.
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _open();
  }

  /* A camera held open while the app is in the background is a camera the system
     will take away, and taking it back is the app's job, not the system's. */
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _close();
    } else if (state == AppLifecycleState.resumed && _cam == null) {
      // Permission may have been granted in settings meanwhile: ask again.
      _failed = false;
      _open();
    }
  }

  Future<void> _open() async {
    // Desktop and web have no camera plugin worth asking; the stand-in is the
    // whole picture there.
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      _failed = true;
      return;
    }
    if (_tried && _cam != null) return;
    _tried = true;
    _opening = true;

    try {
      final cameras = _known ??= await availableCameras();
      if (!mounted) {
        _opening = false;
        widget.onClosed?.call();
        return;
      }
      if (cameras.isEmpty) throw StateError('no camera');
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final cam = CameraController(
        back,
        // Enough to read a label off a jar, and cheap enough to stay smooth.
        ResolutionPreset.high,
        enableAudio: false,
      );
      await cam.initialize();
      _opening = false;
      if (!mounted) {
        await cam.dispose();
        widget.onClosed?.call();
        return;
      }
      setState(() => _cam = cam);
      widget.onReady(cam);
    } catch (_) {
      /* Refused, busy, or absent. The stand-in takes the picture and the screen
         keeps working: a photo can still be chosen from the gallery. */
      _opening = false;
      if (!mounted) {
        widget.onClosed?.call();
        return;
      }
      setState(() => _failed = true);
      widget.onReady(null);
    }
  }

  void _close() {
    final cam = _cam;
    _cam = null;
    _tried = false;
    widget.onReady(null);
    if (mounted) setState(() {});
    cam?.dispose();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final cam = _cam;
    _cam = null;
    if (cam != null) {
      // Released for real, and only then the word to whoever waits for the lens.
      unawaited(cam.dispose().whenComplete(() => widget.onClosed?.call()));
    } else if (!_opening) {
      widget.onClosed?.call();
    }
    // Still opening: `_open` closes what it gets and says so itself.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return widget.fallback;
    final cam = _cam;
    if (cam == null || !cam.value.isInitialized) return widget.loading;

    /* Filled, not fitted, and never stretched.
       A preview letterboxed inside a black screen looks like a bug in the app
       rather than a difference between the sensor's shape and the phone's, so it
       covers. But covering only works if the box already has the picture's own
       proportions: the sensor reports its size lying down, and on a phone held
       upright those two numbers have to be swapped. Handed a box of the wrong
       shape, CameraPreview simply fills it, and the room comes out wide. */
    final preview = cam.value.previewSize;
    final upright = MediaQuery.orientationOf(context) == Orientation.portrait;
    final width = preview == null
        ? 3.0
        : upright
        ? preview.height
        : preview.width;
    final height = preview == null
        ? 4.0
        : upright
        ? preview.width
        : preview.height;

    /* The picture fades in over the dark rather than snapping on: the eye reads
       a snap as a cut and a fade as the camera opening. */
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(opacity: t, child: child),
      child: ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(width: width, height: height, child: CameraPreview(cam)),
        ),
      ),
    );
  }
}
