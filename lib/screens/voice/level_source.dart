import 'dart:math' as math;

/// Where the meter gets its loudness from, in the range 0 to 1.
///
/// An interface and not a microphone call, so the overlay can be built, tested
/// and looked at without a plugin, and so the day a real analyser is wired in it
/// is one class and no changes to the screen.
abstract class LevelSource {
  /// Loudness at [elapsed] since the overlay opened.
  double level(Duration elapsed);

  void dispose() {}
}

/// A slow swell, for when there is no microphone to listen to.
///
/// A stand-in and named as one. The day a real analyser is wired in it replaces
/// this class and nothing else changes, which is the point of the interface: a
/// meter that dances to nothing teaches people that it means nothing, so the
/// fallback is deliberately calm rather than lively.
///
/// Two sines at unrelated periods rather than one: a single sine is a metronome,
/// and the eye reads a metronome as an animation instead of as sound.
class BreathingLevel implements LevelSource {
  const BreathingLevel();

  @override
  double level(Duration elapsed) {
    final t = elapsed.inMilliseconds.toDouble();
    return (0.28 + 0.24 * math.sin(t / 420) + 0.12 * math.sin(t / 137)).clamp(0.0, 1.0);
  }

  @override
  void dispose() {}
}
