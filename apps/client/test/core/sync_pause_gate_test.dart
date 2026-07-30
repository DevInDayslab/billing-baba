import 'package:billing_baba/core/sync/engine/sync_pause_gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pause increments generation and marks stale in-flight work', () {
    final gate = SyncPauseGate.instance;
    final before = gate.generation;
    gate.pause();
    expect(gate.isPaused, isTrue);
    expect(gate.isStale(before), isTrue);
    gate.resume();
    expect(gate.isPaused, isFalse);
  });
}
