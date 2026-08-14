import 'dart:async';

import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/core/sync/application/sync_activity_log.dart';
import 'package:billing_baba/core/sync/application/sync_ui_state.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/models/sync_state.dart';
import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/command_sync/application/command_sync_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final manualSyncVisualStateProvider =
    NotifierProvider<ManualSyncVisualStateNotifier, ManualSyncVisualState>(
      ManualSyncVisualStateNotifier.new,
    );

class ManualSyncVisualStateNotifier extends Notifier<ManualSyncVisualState> {
  Timer? _resetTimer;

  @override
  ManualSyncVisualState build() {
    ref.onDispose(() => _resetTimer?.cancel());
    return ManualSyncVisualState.idle;
  }

  void setSyncing() {
    _resetTimer?.cancel();
    state = ManualSyncVisualState.syncing;
  }

  void setCompleted() {
    _resetTimer?.cancel();
    state = ManualSyncVisualState.completed;
    _resetTimer = Timer(const Duration(seconds: 2), () {
      if (ref.mounted) state = ManualSyncVisualState.idle;
    });
  }

  void setFailed() {
    _resetTimer?.cancel();
    state = ManualSyncVisualState.failed;
    _resetTimer = Timer(const Duration(seconds: 3), () {
      if (ref.mounted) state = ManualSyncVisualState.idle;
    });
  }

  Future<void> syncNow() async {
    if (state == ManualSyncVisualState.syncing) return;
    setSyncing();
    final log = ref.read(syncActivityLogProvider.notifier);
    log.add('Sync requested');

    try {
      final engine = await ref.read(commandAwareSyncEngineProvider.future);
      final startedAt = DateTime.now();
      final result = await engine.syncNow();
      final duration = DateTime.now().difference(startedAt);

      if (result.success) {
        setCompleted();
        log.add(
          result.message ?? 'Sync complete',
          kind: SyncActivityKind.success,
        );
        if (result.acceptedCount > 0) {
          log.add(
            'Uploaded ${result.acceptedCount} row(s)',
            kind: SyncActivityKind.success,
          );
        }
        ref.read(_lastSyncDurationNotifierProvider.notifier).set(duration);
      } else {
        setFailed();
        log.add(
          result.message ?? 'Sync failed',
          kind: SyncActivityKind.error,
        );
      }
    } on Object catch (error) {
      setFailed();
      log.add('Sync failed: $error', kind: SyncActivityKind.error);
    }
  }
}

final _lastSyncDurationNotifierProvider =
    NotifierProvider<_LastSyncDurationNotifier, Duration?>(
      _LastSyncDurationNotifier.new,
    );

class _LastSyncDurationNotifier extends Notifier<Duration?> {
  @override
  Duration? build() => null;

  void set(Duration? duration) => state = duration;
}

final syncActivityWatcherProvider = Provider<void>((ref) {
  SyncLifecycleState? lastLifecycle;
  int? lastPendingCount;
  String? lastResultMessage;

  void recordFromState(SyncState state, int pendingCount) {
    final log = ref.read(syncActivityLogProvider.notifier);

    if (lastLifecycle != state.lifecycle) {
      switch (state.lifecycle) {
        case SyncLifecycleState.syncing:
          log.add('Synchronizing...');
        case SyncLifecycleState.offline:
          log.add('Waiting for connection', kind: SyncActivityKind.warning);
        case SyncLifecycleState.failed:
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            log.add(state.errorMessage!, kind: SyncActivityKind.error);
          }
        case SyncLifecycleState.idle:
          if (lastLifecycle == SyncLifecycleState.syncing &&
              state.lastResultMessage != null &&
              state.lastResultMessage != lastResultMessage) {
            final message = state.lastResultMessage!;
            lastResultMessage = message;
            if (message.contains('push=')) {
              log.add('Uploading rows');
            }
            if (message.contains('pull=')) {
              log.add('Downloading updates');
            }
            if (message.contains('Sync complete')) {
              log.add('Queue empty', kind: SyncActivityKind.success);
              invalidatePartyOutstandingIndex(ref);
              invalidateInventoryLists(ref);
            }
          }
        case SyncLifecycleState.paused:
        case SyncLifecycleState.conflict:
        case SyncLifecycleState.needsAuthentication:
          break;
      }
      lastLifecycle = state.lifecycle;
    }

    if (lastPendingCount != null &&
        lastPendingCount! > 0 &&
        pendingCount == 0) {
      log.add('Queue empty', kind: SyncActivityKind.success);
    }
    lastPendingCount = pendingCount;
  }

  ref.listen(syncStateProvider, (previous, next) {
    final pending = ref.read(_pendingCountsProvider);
    next.whenData((state) => recordFromState(state, pending.queueSize));
  });

  ref.listen(_pendingCountsProvider, (previous, next) {
    final state = ref.read(syncStateProvider).value;
    if (state != null) {
      recordFromState(state, next.queueSize);
    }
  });
});

class _PendingCounts {
  const _PendingCounts({
    required this.pendingRows,
    required this.pendingCommands,
    required this.queueSize,
  });

  final int pendingRows;
  final int pendingCommands;
  final int queueSize;
}

final _pendingCountsProvider = Provider<_PendingCounts>((ref) {
  final jobs = ref.watch(syncPendingJobsProvider).value ?? const <SyncJob>[];
  var rows = 0;
  var commands = 0;
  for (final job in jobs) {
    if (job.kind == SyncQueueKind.command) {
      commands++;
    } else {
      rows++;
    }
  }
  return _PendingCounts(
    pendingRows: rows,
    pendingCommands: commands,
    queueSize: jobs.length,
  );
});

final syncUiStateProvider = Provider<SyncUiSnapshot>((ref) {
  ref.watch(syncActivityWatcherProvider);

  final syncState = ref.watch(syncStateProvider).value ?? SyncState.initial;
  final pending = ref.watch(_pendingCountsProvider);
  final manualState = ref.watch(manualSyncVisualStateProvider);
  final business = ref.watch(sidebarBusinessProvider);
  final activity = ref.watch(syncActivityLogProvider);
  final lastDuration = ref.watch(_lastSyncDurationNotifierProvider);

  final metadata = ref.watch(syncMetadataStoreProvider).value;
  final identity = ref.watch(syncDeviceIdentityProvider).value;

  final cloudState = _resolveCloudState(
    syncState: syncState,
    pendingCount: pending.queueSize,
    manualState: manualState,
  );

  final currentOperation = switch (syncState.lifecycle) {
    SyncLifecycleState.syncing => _operationLabel(syncState.lastResultMessage),
    SyncLifecycleState.offline => 'Offline',
    SyncLifecycleState.failed => 'Failed',
    SyncLifecycleState.idle when pending.queueSize > 0 => 'Pending upload',
    _ => 'Idle',
  };

  return SyncUiSnapshot(
    lifecycle: syncState.lifecycle,
    connectivity: syncState.connectivity,
    pendingRows: pending.pendingRows,
    pendingCommands: pending.pendingCommands,
    queueSize: pending.queueSize,
    currentOperation: currentOperation,
    progress:
        syncState.connectivity == SyncConnectivityStatus.offline &&
            pending.queueSize > 0
        ? OfflineUiMessages.syncWhenOnline
        : syncState.lastResultMessage,
    lastSyncTime: syncState.lastSyncTime,
    lastError: syncState.errorMessage,
    lastSyncDuration: lastDuration,
    businessName: business.name,
    deviceName: identity?.deviceName() ?? 'Desktop',
    pullCursor: metadata?.pullCursor,
    recentActivity: activity,
    cloudState: cloudState,
    manualSyncState: manualState,
    isEngineRunning: syncState.isEngineRunning,
  );
});

SyncCloudVisualState _resolveCloudState({
  required SyncState syncState,
  required int pendingCount,
  required ManualSyncVisualState manualState,
}) {
  if (syncState.connectivity == SyncConnectivityStatus.offline ||
      syncState.lifecycle == SyncLifecycleState.offline) {
    return SyncCloudVisualState.offline;
  }
  if (syncState.lifecycle == SyncLifecycleState.failed ||
      (syncState.errorMessage?.isNotEmpty ?? false)) {
    return SyncCloudVisualState.error;
  }
  if (syncState.lifecycle == SyncLifecycleState.syncing ||
      manualState == ManualSyncVisualState.syncing) {
    return SyncCloudVisualState.syncing;
  }
  if (pendingCount > 0) {
    return SyncCloudVisualState.pending;
  }
  return SyncCloudVisualState.synced;
}

String _operationLabel(String? message) {
  if (message == null || message.isEmpty) return 'Synchronizing';
  if (message.toLowerCase().contains('push')) return 'Uploading...';
  if (message.toLowerCase().contains('pull')) return 'Downloading...';
  return message;
}
