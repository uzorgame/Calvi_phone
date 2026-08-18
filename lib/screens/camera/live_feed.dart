import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// The real viewfinder, when there is one.
///
/// The screen was drawn against a painted stand-in so the layout could be judged
/// without a device in hand, and that stand-in stays: it is what the web build
/// shows, what a denied permission falls back to, and what a phone without a
/// camera gets. The live picture is an improvement on it, not a replacement for
/// the screen around it.
///
/// The controller lives here rather than in the screen because it is the only
/// thing that has to be torn down on the way out, and a camera left running is a
/// camera the person can see in their status bar.
class LiveFeed extends StatefulWidget {
  const LiveFeed({super.key, required this.fallback, required this.onReady});

  /// Drawn until the camera answers, and for good if it never does.
  final Widget fallback;

  /// Handed the controller once it is running, so the screen can drive the torch
  /// and take the picture.
  final ValueChanged<CameraController?> onReady;

  @override
  State<LiveFeed> createState() => _LiveFeedState();
}

class _LiveFeedState extends State<LiveFeed> with WidgetsBindingObserver {
  CameraController? _cam;
  bool _tried = false;

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
      _open();
    }
  }

  Future<void> _open() async {
    // Desktop and web have no camera plugin worth asking; the stand-in is the
    // whole picture there.
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
    if (_tried && _cam != null) return;
    _tried = true;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty || !mounted) return;
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
      if (!mounted) {
        await cam.dispose();
        return;
      }
      setState(() => _cam = cam);
      widget.onReady(cam);
    } catch (_) {
      /* Refused, busy, or absent. The stand-in is already on screen and the
         screen keeps working: a picture can still be chosen from the gallery. */
      if (mounted) widget.onReady(null);
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
    _cam?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cam = _cam;
    if (cam == null || !cam.value.isInitialized) return widget.fallback;

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

    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(width: width, height: height, child: CameraPreview(cam)),
      ),
    );
  }
}
