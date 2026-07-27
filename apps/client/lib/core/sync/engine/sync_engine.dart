import 'dart:async';

import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/core/sync/engine/connectivity_monitor.dart';
import 'package:billing_baba/core/sync/engine/sync_coordinator.dart';
import 'package:billing_baba/core/sync/engine/sync_scheduler.dart';
import 'package:billing_baba/core/sync/models/sync_result.dart';
import 'package:billing_baba/core/sync/models/sync_state.dart';

/// Owns the offline sync runtime lifecycle and triggers.
///
/// Orchestration lives in [SyncCoordinator]. Triggers:
/// app startup, connectivity restored, manual refresh, periodic timer.
class SyncEngine {
  SyncEngine({
    required ConnectivityMonitor connectivityMonitor,
    required this._scheduler,
    required this._coordinator,
  }) : _connectivity = connectivityMonitor;

  final ConnectivityMonitor _connectivity;
  final SyncScheduler _scheduler;
  final SyncCoordinator _coordinator;

  final _stateController = StreamController<SyncState>.broadcast();
  SyncState _state = SyncState.initial;
  StreamSubscription<SyncConnectivityStatus>? _connectivitySub;
  bool _initialized = false;
  bool _running = false;
  bool _autoSyncEnabled = false;

  SyncState get state => _state;
  Stream<SyncState> get stateChanges => _stateController.stream;
  bool get isRunning => _running;
  bool get isInitialized => _initialized;
  SyncCoordinator get coordinator => _coordinator;

  /// Initializes monitors/scheduler. Does **not** run sync.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _scheduler.setCallback(_onScheduleTrigger);
    await _connectivity.start();
    _connectivitySub = _connectivity.onStatusChanged.listen(_onConnectivity);

    final status = await _connectivity.checkNow();
    _applyConnectivity(status, emitSchedule: false);

    _emit(
      _state.copyWith(
        isEngineRunning: false,
        lifecycle: status == SyncConnectivityStatus.offline
            ? SyncLifecycleState.offline
            : SyncLifecycleState.idle,
        clearError: true,
      ),
    );

    LoggingService.instance.info(
      'SyncEngine initialized (autoSync=$_autoSyncEnabled)',
    );
  }

  /// Starts scheduler + connectivity handling.
  Future<void> start({bool enableAutoSync = true}) async {
    await initialize();
    if (_running) return;
    _running = true;
    _autoSyncEnabled = enableAutoSync;
    _scheduler.start();
    _emit(_state.copyWith(isEngineRunning: true));
    LoggingService.instance.info(
      'SyncEngine started (autoSync=$_autoSyncEnabled)',
    );
  }

  Future<void> stop() async {
    _scheduler.stop();
    _running = false;
    _emit(
      _state.copyWith(
        isEngineRunning: false,
        lifecycle: SyncLifecycleState.paused,
        clearNextScheduled: true,
      ),
    );
    LoggingService.instance.info('SyncEngine stopped');
  }

  /// Manual sync request.
  void schedule([
    SyncScheduleTrigger trigger = SyncScheduleTrigger.manualRefresh,
  ]) {
    _emit(
      _state.copyWith(nextScheduledSync: _scheduler.nextScheduledSync),
    );
    if (_autoSyncEnabled || trigger == SyncScheduleTrigger.manualRefresh) {
      unawaited(syncNow());
    }
  }

  Future<SyncResult> syncNow() async {
    await initialize();

    return _coordinator.orchestrate(
      currentState: _state,
      emit: (update) => _emit(update(_state)),
    );
  }

  Future<void> dispose() async {
    await stop();
    await _connectivitySub?.cancel();
    await _connectivity.dispose();
    _scheduler.dispose();
    _coordinator.dispose();
    await _stateController.close();
  }

  void _onScheduleTrigger(SyncScheduleTrigger trigger) {
    _emit(
      _state.copyWith(nextScheduledSync: _scheduler.nextScheduledSync),
    );
    if (!_autoSyncEnabled) return;
    if (_state.connectivity == SyncConnectivityStatus.offline) return;
    unawaited(syncNow());
  }

  void _onConnectivity(SyncConnectivityStatus status) {
    _applyConnectivity(status, emitSchedule: true);
  }

  void _applyConnectivity(
    SyncConnectivityStatus status, {
    required bool emitSchedule,
  }) {
    final lifecycle = status == SyncConnectivityStatus.offline
        ? SyncLifecycleState.offline
        : (_state.lifecycle == SyncLifecycleState.offline
            ? SyncLifecycleState.idle
            : _state.lifecycle);

    _emit(
      _state.copyWith(
        connectivity: status,
        lifecycle: lifecycle,
      ),
    );
    if (emitSchedule) {
      _scheduler.onConnectivityChanged(status);
    }
  }

  void _emit(SyncState next) {
    _state = next;
    if (!_stateController.isClosed) {
      _stateController.add(next);
    }
  }
}
