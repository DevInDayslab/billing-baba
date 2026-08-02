/// Prevents sync from running during business switch transitions.
///
/// [generation] increments on each [pause] so in-flight sync passes can detect
/// stale work and abort before applying cross-business data.
class SyncPauseGate {
  SyncPauseGate._();

  static final SyncPauseGate instance = SyncPauseGate._();

  bool _paused = false;
  int _generation = 0;

  bool get isPaused => _paused;

  /// Monotonic token bumped on every [pause].
  int get generation => _generation;

  void pause() {
    _paused = true;
    _generation++;
  }

  void resume() => _paused = false;

  bool isStale(int capturedGeneration) => capturedGeneration != _generation;
}
