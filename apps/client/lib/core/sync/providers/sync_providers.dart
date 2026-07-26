import 'dart:async';

import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/core/sync/engine/connectivity_monitor.dart';
import 'package:billing_baba/core/sync/engine/device_identity.dart';
import 'package:billing_baba/core/sync/engine/sync_coordinator.dart';
import 'package:billing_baba/core/sync/engine/sync_engine.dart';
import 'package:billing_baba/core/sync/engine/sync_metadata_store.dart';
import 'package:billing_baba/core/sync/engine/sync_plan.dart';
import 'package:billing_baba/core/sync/engine/sync_scheduler.dart';
import 'package:billing_baba/core/sync/engine/sync_session.dart';
import 'package:billing_baba/core/sync/engine/sync_status_controller.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/models/sync_state.dart';
import 'package:billing_baba/core/sync/network/sync_api.dart';
import 'package:billing_baba/core/sync/network/sync_client.dart';
import 'package:billing_baba/core/sync/network/sync_headers.dart';
import 'package:billing_baba/core/sync/offline/category_sync_applier.dart';
import 'package:billing_baba/core/sync/queue/drift_sync_queue_repository.dart';
import 'package:billing_baba/core/sync/queue/sync_queue_processor.dart';
import 'package:billing_baba/core/sync/queue/sync_queue_repository.dart';
import 'package:billing_baba/core/sync/queue/sync_queue_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityMonitorProvider = Provider<ConnectivityMonitor>((ref) {
  final monitor = ConnectivityMonitor();
  ref.onDispose(monitor.dispose);
  return monitor;
});

final syncQueueRepositoryProvider = Provider<SyncQueueRepository>((ref) {
  return DriftSyncQueueRepository(ref.watch(appDatabaseProvider));
});

/// Alias for [syncQueueRepositoryProvider].
final Provider<SyncQueueRepository> queueRepositoryProvider =
    syncQueueRepositoryProvider;

final syncQueueServiceProvider = Provider<SyncQueueService>((ref) {
  return SyncQueueService(ref.watch(syncQueueRepositoryProvider));
});

/// Alias for [syncQueueServiceProvider].
final Provider<SyncQueueService> queueServiceProvider = syncQueueServiceProvider;

final syncPendingCountProvider = StreamProvider<int>((ref) {
  return ref.watch(syncQueueRepositoryProvider).streamPendingCount();
});

/// Alias for [syncPendingCountProvider].
final StreamProvider<int> pendingCountProvider = syncPendingCountProvider;

final syncPendingJobsProvider = StreamProvider<List<SyncJob>>((ref) {
  return ref.watch(syncQueueRepositoryProvider).watchPending();
});

/// Alias for [syncPendingJobsProvider].
final StreamProvider<List<SyncJob>> pendingJobsProvider =
    syncPendingJobsProvider;

final syncQueueProcessorProvider = Provider<SyncQueueProcessor>((ref) {
  return SyncQueueProcessor(ref.watch(syncQueueServiceProvider));
});

final syncSchedulerProvider = Provider<SyncScheduler>((ref) {
  final scheduler = SyncScheduler();
  ref.onDispose(scheduler.dispose);
  return scheduler;
});

/// Async because [apiClientProvider] is a FutureProvider.
final syncClientProvider = FutureProvider<SyncClient>((ref) async {
  final apiClient = await ref.watch(apiClientProvider.future);
  final api = SyncApi(apiClient.dio);
  return SyncClient(
    api: api,
    headerProvider: const DefaultSyncHeaderProvider(),
  );
});

final syncDeviceIdentityProvider =
    FutureProvider<SyncDeviceIdentity>((ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  return SyncDeviceIdentity(storage);
});

final syncMetadataStoreProvider =
    FutureProvider<SyncMetadataStore>((ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  return SyncMetadataStore(storage);
});

final syncCoordinatorProvider = FutureProvider<SyncCoordinator>((ref) async {
  final client = await ref.watch(syncClientProvider.future);
  final storage = await ref.watch(storageServiceProvider.future);
  final identity = await ref.watch(syncDeviceIdentityProvider.future);
  final metadata = await ref.watch(syncMetadataStoreProvider.future);
  final db = ref.watch(appDatabaseProvider);
  final coordinator = SyncCoordinator(
    transport: SyncClientCoordinatorTransport(client),
    queueService: ref.watch(syncQueueServiceProvider),
    identity: identity,
    metadata: metadata,
    storage: storage,
    categoryApplier: CategorySyncApplier(db),
  );
  // Disposed by SyncEngine when the engine provider tears down.
  return coordinator;
});

final syncEngineProvider = FutureProvider<SyncEngine>((ref) async {
  final coordinator = await ref.watch(syncCoordinatorProvider.future);
  // SyncWorker / SyncRunner remain available via their providers for a later
  // milestone that drains the queue and executes push/pull.
  final engine = SyncEngine(
    connectivityMonitor: ref.watch(connectivityMonitorProvider),
    scheduler: ref.watch(syncSchedulerProvider),
    coordinator: coordinator,
  );

  ref.onDispose(() {
    unawaited(engine.dispose());
  });

  return engine;
});

final currentSyncSessionProvider = StreamProvider<SyncSession?>((ref) async* {
  final coordinator = await ref.watch(syncCoordinatorProvider.future);
  yield coordinator.currentSession;
  yield* coordinator.sessionChanges;
});

final currentSyncPlanProvider = StreamProvider<SyncPlan?>((ref) async* {
  final coordinator = await ref.watch(syncCoordinatorProvider.future);
  yield coordinator.currentPlan;
  yield* coordinator.planChanges;
});

/// Streams [SyncState] after the engine has been initialized at startup.
final syncStateProvider = StreamProvider<SyncState>((ref) async* {
  final engine = await ref.watch(syncEngineProvider.future);
  yield engine.state;
  yield* engine.stateChanges;
});

final syncStatusControllerProvider =
    FutureProvider<SyncStatusController>((ref) async {
  final engine = await ref.watch(syncEngineProvider.future);
  return SyncStatusController(
    engine: engine,
    queueService: ref.watch(syncQueueServiceProvider),
    scheduler: ref.watch(syncSchedulerProvider),
  );
});

final connectivityStatusProvider =
    StreamProvider<SyncConnectivityStatus>((ref) async* {
  final monitor = ref.watch(connectivityMonitorProvider);
  yield monitor.status;
  yield* monitor.onStatusChanged;
});
