import 'package:billing_baba/core/sync/engine/sync_orchestration_phase.dart';

/// Coarse connectivity for the sync runtime.
enum SyncConnectivityStatus {
  online,
  offline,
  unknown,
}

/// High-level lifecycle state of the offline sync runtime.
enum SyncLifecycleState {
  idle,
  offline,
  syncing,
  paused,
  failed,
  conflict,
  needsAuthentication,
}

/// Immutable snapshot of sync runtime status.
class SyncState {
  const SyncState({
    this.lifecycle = SyncLifecycleState.idle,
    this.connectivity = SyncConnectivityStatus.unknown,
    this.orchestrationPhase = SyncOrchestrationPhase.idle,
    this.isEngineRunning = false,
    this.lastSyncTime,
    this.nextScheduledSync,
    this.pendingJobs = 0,
    this.runningJobId,
    this.errorMessage,
    this.lastResultMessage,
  });

  final SyncLifecycleState lifecycle;
  final SyncConnectivityStatus connectivity;
  final SyncOrchestrationPhase orchestrationPhase;
  final bool isEngineRunning;
  final DateTime? lastSyncTime;
  final DateTime? nextScheduledSync;
  final int pendingJobs;
  final String? runningJobId;
  final String? errorMessage;
  final String? lastResultMessage;

  static const initial = SyncState();

  bool get isOnline => connectivity == SyncConnectivityStatus.online;

  SyncState copyWith({
    SyncLifecycleState? lifecycle,
    SyncConnectivityStatus? connectivity,
    SyncOrchestrationPhase? orchestrationPhase,
    bool? isEngineRunning,
    DateTime? lastSyncTime,
    DateTime? nextScheduledSync,
    int? pendingJobs,
    String? runningJobId,
    String? errorMessage,
    String? lastResultMessage,
    bool clearRunningJob = false,
    bool clearError = false,
    bool clearNextScheduled = false,
  }) {
    return SyncState(
      lifecycle: lifecycle ?? this.lifecycle,
      connectivity: connectivity ?? this.connectivity,
      orchestrationPhase: orchestrationPhase ?? this.orchestrationPhase,
      isEngineRunning: isEngineRunning ?? this.isEngineRunning,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      nextScheduledSync: clearNextScheduled
          ? null
          : (nextScheduledSync ?? this.nextScheduledSync),
      pendingJobs: pendingJobs ?? this.pendingJobs,
      runningJobId: clearRunningJob
          ? null
          : (runningJobId ?? this.runningJobId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastResultMessage: lastResultMessage ?? this.lastResultMessage,
    );
  }
}
