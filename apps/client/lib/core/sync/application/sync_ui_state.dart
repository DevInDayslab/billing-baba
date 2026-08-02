import 'package:billing_baba/core/sync/application/sync_activity_log.dart';
import 'package:billing_baba/core/sync/models/sync_state.dart';

enum SyncCloudVisualState {
  synced,
  syncing,
  offline,
  pending,
  error,
}

enum ManualSyncVisualState {
  idle,
  syncing,
  completed,
  failed,
}

class SyncUiSnapshot {
  const SyncUiSnapshot({
    required this.lifecycle,
    required this.connectivity,
    required this.pendingRows,
    required this.pendingCommands,
    required this.queueSize,
    required this.currentOperation,
    required this.progress,
    required this.lastSyncTime,
    required this.lastError,
    required this.lastSyncDuration,
    required this.businessName,
    required this.deviceName,
    required this.pullCursor,
    required this.recentActivity,
    required this.cloudState,
    required this.manualSyncState,
    required this.isEngineRunning,
  });

  final SyncLifecycleState lifecycle;
  final SyncConnectivityStatus connectivity;
  final int pendingRows;
  final int pendingCommands;
  final int queueSize;
  final String? currentOperation;
  final String? progress;
  final DateTime? lastSyncTime;
  final String? lastError;
  final Duration? lastSyncDuration;
  final String businessName;
  final String deviceName;
  final String? pullCursor;
  final List<SyncActivityEntry> recentActivity;
  final SyncCloudVisualState cloudState;
  final ManualSyncVisualState manualSyncState;
  final bool isEngineRunning;

  bool get isOnline => connectivity == SyncConnectivityStatus.online;
  bool get isSyncing => lifecycle == SyncLifecycleState.syncing;
  bool get hasPendingWork => queueSize > 0;
  bool get hasError =>
      lifecycle == SyncLifecycleState.failed ||
      (lastError?.isNotEmpty ?? false);

  static const initial = SyncUiSnapshot(
    lifecycle: SyncLifecycleState.idle,
    connectivity: SyncConnectivityStatus.unknown,
    pendingRows: 0,
    pendingCommands: 0,
    queueSize: 0,
    currentOperation: 'Idle',
    progress: null,
    lastSyncTime: null,
    lastError: null,
    lastSyncDuration: null,
    businessName: '',
    deviceName: 'Desktop',
    pullCursor: null,
    recentActivity: [],
    cloudState: SyncCloudVisualState.synced,
    manualSyncState: ManualSyncVisualState.idle,
    isEngineRunning: false,
  );
}
