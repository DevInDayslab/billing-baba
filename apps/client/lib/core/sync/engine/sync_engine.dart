import 'dart:async';

import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/core/sync/engine/connectivity_monitor.dart';
import 'package:billing_baba/core/sync/engine/sync_coordinator.dart';
import 'package:billing_baba/core/sync/engine/sync_orchestration_phase.dart';
import 'package:billing_baba/core/sync/engine/sync_plan.dart';
import 'package:billing_baba/core/sync/engine/sync_scheduler.dart';
import 'package:billing_baba/core/sync/engine/sync_session.dart';
import 'package:billing_baba/core/sync/models/sync_result.dart';
import 'package:billing_baba/core/sync/models/sync_state.dart';

/// Owns the offline sync runtime lifecycle.
///
/// Orchestration order lives in [SyncCoordinator] — this class does not know
/// endpoint sequencing. Does **not** contain feature business logic.
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
  SyncSession? get currentSession => _coordinator.currentSession;
  SyncPlan? get currentPlan => _coordinator.currentPlan;

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
        orchestrationPhase: status == SyncConnectivityStatus.offline
            ? SyncOrchestrationPhase.offline
            : SyncOrchestrationPhase.idle,
        clearError: true,
      ),
    );

    LoggingService.instance.info(
      'SyncEngine initialized (autoSync=$_autoSyncEnabled)',
    );
  }

  /// Starts scheduler + connectivity handling. Still does not sync by default.
  Future<void> start({bool enableAutoSync = false}) async {
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

  /// Records a schedule intent. Does not execute network sync.
  /// Auto-sync remains disabled until a later milestone enables it.
  void schedule([
    SyncScheduleTrigger trigger = SyncScheduleTrigger.manualRefresh,
  ]) {
    _emit(
      _state.copyWith(
        nextScheduledSync: _scheduler.nextScheduledSync,
        lastResultMessage: 'Scheduled: $trigger (sync deferred)',
      ),
    );
    LoggingService.instance.info(
      'SyncEngine.schedule($trigger) — sync execution deferred',
    );
  }

  /// Manual sync: delegates workflow to [SyncCoordinator] (no push/pull yet).
  Future<SyncResult> syncNow() async {
    await initialize();

    final session = await _coordinator.orchestrate(
      currentState: _state,
      emit: (update) => _emit(update(_state)),
    );

    return session.result ??
        SyncResult.noop(message: 'Orchestration finished without result');
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
    // Intentionally do not call syncNow — auto-sync remains deferred.
    schedule(trigger);
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

    final phase = status == SyncConnectivityStatus.offline
        ? SyncOrchestrationPhase.offline
        : (_state.orchestrationPhase == SyncOrchestrationPhase.offline
            ? SyncOrchestrationPhase.idle
            : _state.orchestrationPhase);

    _emit(
      _state.copyWith(
        connectivity: status,
        lifecycle: lifecycle,
        orchestrationPhase: phase,
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
