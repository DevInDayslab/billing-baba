import 'dart:async';
import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/engine/bootstrap_decision.dart';
import 'package:billing_baba/core/sync/engine/device_identity.dart';
import 'package:billing_baba/core/sync/engine/sync_cursor.dart';
import 'package:billing_baba/core/sync/engine/sync_metadata_store.dart';
import 'package:billing_baba/core/sync/engine/sync_orchestration_phase.dart';
import 'package:billing_baba/core/sync/engine/sync_plan.dart';
import 'package:billing_baba/core/sync/engine/sync_session.dart';
import 'package:billing_baba/core/sync/models/sync_direction.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/models/sync_job_payload_meta.dart';
import 'package:billing_baba/core/sync/models/sync_queue_enums.dart';
import 'package:billing_baba/core/sync/models/sync_result.dart';
import 'package:billing_baba/core/sync/models/sync_state.dart';
import 'package:billing_baba/core/sync/network/sync_client.dart';
import 'package:billing_baba/core/sync/offline/category_sync_applier.dart';
import 'package:billing_baba/core/sync/queue/sync_queue_service.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// Transport used by the coordinator (register/status/push/pull).
abstract class SyncCoordinatorTransport {
  Future<Map<String, dynamic>> registerDevice({
    required String deviceId,
    required String platform,
    required String appVersion,
    required String deviceName,
  });

  Future<Map<String, dynamic>> status({
    required String deviceId,
    required String appVersion,
  });

  Future<Map<String, dynamic>> push({
    required String deviceId,
    required String appVersion,
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> pull({
    required String deviceId,
    required String appVersion,
    required String cursor,
    int? limit,
    String? entityTypes,
  });
}

/// Adapts [SyncClient] to [SyncCoordinatorTransport].
class SyncClientCoordinatorTransport implements SyncCoordinatorTransport {
  SyncClientCoordinatorTransport(this._client);

  final SyncClient _client;

  @override
  Future<Map<String, dynamic>> registerDevice({
    required String deviceId,
    required String platform,
    required String appVersion,
    required String deviceName,
  }) {
    return _client.registerDevice(
      deviceId: deviceId,
      platform: platform,
      appVersion: appVersion,
      deviceName: deviceName,
    );
  }

  @override
  Future<Map<String, dynamic>> status({
    required String deviceId,
    required String appVersion,
  }) {
    return _client.status(deviceId: deviceId, appVersion: appVersion);
  }

  @override
  Future<Map<String, dynamic>> push({
    required String deviceId,
    required String appVersion,
    required Map<String, dynamic> body,
  }) {
    return _client.push(
      deviceId: deviceId,
      appVersion: appVersion,
      body: body,
    );
  }

  @override
  Future<Map<String, dynamic>> pull({
    required String deviceId,
    required String appVersion,
    required String cursor,
    int? limit,
    String? entityTypes,
  }) {
    return _client.pull(
      deviceId: deviceId,
      appVersion: appVersion,
      cursor: cursor,
      limit: limit,
      entityTypes: entityTypes,
    );
  }
}

typedef SyncStateEmitter = void Function(
  SyncState Function(SyncState current) update,
);

/// Owns the synchronization workflow order.
///
/// First real entity path: push/pull `categories` only.
class SyncCoordinator {
  SyncCoordinator({
    required this._transport,
    required SyncQueueService queueService,
    required this._identity,
    required this._metadata,
    required this._storage,
    this._categoryApplier,
    Uuid? uuid,
    this.categoryEntityType = 'categories',
  })  : _queue = queueService,
        _uuid = uuid ?? const Uuid();

  final SyncCoordinatorTransport _transport;
  final SyncQueueService _queue;
  final SyncDeviceIdentity _identity;
  final SyncMetadataStore _metadata;
  final StorageService _storage;
  final CategorySyncApplier? _categoryApplier;
  final Uuid _uuid;
  final String categoryEntityType;

  final _sessionController = StreamController<SyncSession?>.broadcast();
  final _planController = StreamController<SyncPlan?>.broadcast();

  SyncSession? _currentSession;
  SyncPlan? _currentPlan;
  bool _busy = false;

  SyncSession? get currentSession => _currentSession;
  SyncPlan? get currentPlan => _currentPlan;

  Stream<SyncSession?> get sessionChanges => _sessionController.stream;
  Stream<SyncPlan?> get planChanges => _planController.stream;

  /// Runs register → status → minimal bootstrap → push categories → pull.
  Future<SyncSession> orchestrate({
    required SyncState currentState,
    required SyncStateEmitter emit,
  }) async {
    if (_busy) {
      final existing = _currentSession;
      if (existing != null && !existing.isFinished) return existing;
    }
    _busy = true;

    final session = SyncSession(
      sessionId: _uuid.v4(),
      startedAt: DateTime.now().toUtc(),
    );
    _setSession(session);

    try {
      if (currentState.connectivity == SyncConnectivityStatus.offline) {
        return _finish(
          session: session,
          phase: SyncOrchestrationPhase.offline,
          emit: emit,
          currentState: currentState,
          result: SyncResult.noop(message: 'Offline — sync skipped'),
          errorMessage: 'Device is offline',
        );
      }

      _emitPhase(
        emit,
        currentState,
        SyncOrchestrationPhase.checkingServer,
        lifecycle: SyncLifecycleState.syncing,
        runningJobId: session.sessionId,
        clearError: true,
      );

      _emitPhase(
        emit,
        currentState,
        SyncOrchestrationPhase.registeringDevice,
        lifecycle: SyncLifecycleState.syncing,
        runningJobId: session.sessionId,
      );

      final deviceId = await _identity.deviceId();
      final appVersion = await _identity.appVersion();

      try {
        await _transport.registerDevice(
          deviceId: deviceId,
          platform: _identity.platform(),
          appVersion: appVersion,
          deviceName: _identity.deviceName(),
        );
      } on Object catch (error) {
        return _finishTransportFailure(
          session: session,
          emit: emit,
          currentState: currentState,
          error: error,
          context: 'registerDevice',
        );
      }

      late final Map<String, dynamic> statusPayload;
      try {
        statusPayload = await _transport.status(
          deviceId: deviceId,
          appVersion: appVersion,
        );
      } on Object catch (error) {
        return _finishTransportFailure(
          session: session,
          emit: emit,
          currentState: currentState,
          error: error,
          context: 'status',
        );
      }

      _emitPhase(
        emit,
        currentState,
        SyncOrchestrationPhase.planning,
        lifecycle: SyncLifecycleState.syncing,
        runningJobId: session.sessionId,
      );

      final businessId = _storage.read(StorageKeys.lastOpenedBusinessId);
      final serverSchema = _readInt(statusPayload['schema_version']);

      var decision = BootstrapDecision.evaluate(
        businessId: businessId,
        pullCursor: _metadata.pullCursor,
        bootstrappedAt: _metadata.bootstrappedAt,
        localSchemaVersion: _metadata.localSchemaVersion,
        lastServerSchemaVersion: _metadata.lastServerSchemaVersion,
        serverSchemaVersion: serverSchema,
      );

      // Minimal bootstrap: seed cursor so categories push/pull can run.
      if (decision.needsBootstrap &&
          businessId != null &&
          businessId.isNotEmpty) {
        await _metadata.setBootstrappedAt(DateTime.now().toUtc());
        await _metadata.setPullCursor(epochSyncCursor());
        if (serverSchema != null) {
          await _metadata.setLastServerSchemaVersion(serverSchema);
        }
        decision = BootstrapDecision.ready;
      }

      final pending = await _safePendingJobs();
      final counts = _countByKind(pending);
      final categoryJobs = pending
          .where(
            (j) =>
                j.kind == SyncQueueKind.row &&
                j.entityType == categoryEntityType &&
                j.status == SyncQueueStatus.pending,
          )
          .toList();

      final plan = _buildPlan(
        decision: decision,
        pendingRowCount: counts.rows,
        pendingCommandCount: counts.commands,
        pendingMediaCount: counts.media,
        forceSteady: true,
      );
      _setPlan(plan);
      session.plan = plan;

      if (businessId == null || businessId.isEmpty) {
        return _finish(
          session: session,
          phase: SyncOrchestrationPhase.needsBootstrap,
          emit: emit,
          currentState: currentState,
          plan: plan,
          result: SyncResult(
            success: false,
            direction: SyncDirection.full,
            completedAt: DateTime.now().toUtc(),
            message: 'No business selected',
            errorCount: 1,
          ),
          errorMessage: 'No business selected',
        );
      }

      // Push categories queue jobs.
      if (categoryJobs.isNotEmpty) {
        try {
          await _pushCategoryJobs(
            session: session,
            deviceId: deviceId,
            appVersion: appVersion,
            jobs: categoryJobs,
          );
        } on Object catch (error) {
          for (final job in categoryJobs) {
            await _queue.markFailed(
              job.id,
              reason: 'push failed: $error',
            );
          }
          session.failures += categoryJobs.length;
          return _finishTransportFailure(
            session: session,
            emit: emit,
            currentState: currentState,
            error: error,
            context: 'push',
          );
        }
      }

      // Pull categories only.
      try {
        await _pullCategories(
          session: session,
          businessId: businessId,
          deviceId: deviceId,
          appVersion: appVersion,
        );
      } on Object catch (error) {
        return _finishTransportFailure(
          session: session,
          emit: emit,
          currentState: currentState,
          error: error,
          context: 'pull',
        );
      }

      final remaining = await _safePendingJobs();
      final message =
          'Sync complete (categories push=${categoryJobs.length}, '
          'conflicts=${session.conflicts}, failures=${session.failures})';

      try {
        LoggingService.instance.info(
          'SyncCoordinator: session=${session.sessionId} $message',
        );
      } on Object {
        // Logging may be unavailable in unit tests without dotenv.
      }

      return _finish(
        session: session,
        phase: SyncOrchestrationPhase.ready,
        emit: emit,
        currentState: currentState,
        plan: plan,
        result: SyncResult(
          success: session.failures == 0,
          direction: SyncDirection.full,
          completedAt: DateTime.now().toUtc(),
          message: message,
          acceptedCount: session.rowsUploaded,
          conflictCount: session.conflicts,
          errorCount: session.failures,
        ),
        pendingJobs: remaining.length,
      );
    } finally {
      _busy = false;
    }
  }

  Future<void> _pushCategoryJobs({
    required SyncSession session,
    required String deviceId,
    required String appVersion,
    required List<SyncJob> jobs,
  }) async {
    final mutations = <Map<String, dynamic>>[];
    for (final job in jobs) {
      await _queue.markRunning(job.id);
      mutations.add({
        'mutation_id': job.mutationId,
        'kind': 'row',
        'entity_type': job.entityType,
        'entity_id': job.entityId,
        'operation': job.operation.wire,
        'base_sync_version':
            SyncJobPayloadMeta.readBaseSyncVersion(job.payload),
        'payload': SyncJobPayloadMeta.domainOnly(job.payload),
        'client_updated_at':
            SyncJobPayloadMeta.readClientUpdatedAt(job.payload),
      });
    }

    final body = {
      'device_id': deviceId,
      'client_batch_id': _uuid.v4(),
      'mutations': mutations,
    };

    final response = await _transport.push(
      deviceId: deviceId,
      appVersion: appVersion,
      body: body,
    );

    final byMutation = {for (final job in jobs) job.mutationId: job};

    for (final item in _asList(response['accepted'])) {
      final mutationId = item['mutation_id']?.toString();
      final job = mutationId == null ? null : byMutation[mutationId];
      if (job == null) continue;
      final syncVersion = _readInt(item['sync_version']) ?? 1;
      final updatedAt = DateTime.tryParse(
            item['server_updated_at']?.toString() ?? '',
          )?.toUtc() ??
          DateTime.now().toUtc();
      await _categoryApplier?.updateAckMeta(
        entityId: job.entityId ?? '',
        syncVersion: syncVersion,
        updatedAt: updatedAt,
        deviceId: deviceId,
      );
      await _queue.markCompleted(job.id);
      session.rowsUploaded += 1;
    }

    for (final item in _asList(response['replayed'])) {
      final mutationId = item['mutation_id']?.toString();
      final job = mutationId == null ? null : byMutation[mutationId];
      if (job == null) continue;
      final syncVersion = _readInt(item['sync_version']);
      if (syncVersion != null && job.entityId != null) {
        final updatedAt = DateTime.tryParse(
              item['server_updated_at']?.toString() ?? '',
            )?.toUtc() ??
            DateTime.now().toUtc();
        await _categoryApplier?.updateAckMeta(
          entityId: job.entityId!,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          deviceId: deviceId,
        );
      }
      await _queue.markCompleted(job.id);
      session.rowsUploaded += 1;
    }

    for (final item in _asList(response['conflicts'])) {
      final mutationId = item['mutation_id']?.toString();
      final job = mutationId == null ? null : byMutation[mutationId];
      if (job == null) continue;
      // Do not overwrite Drift with server_payload.
      await _queue.markConflict(
        job.id,
        reason: jsonEncode(item),
      );
      session.conflicts += 1;
    }

    for (final item in _asList(response['errors'])) {
      final mutationId = item['mutation_id']?.toString();
      final job = mutationId == null ? null : byMutation[mutationId];
      if (job == null) continue;
      await _queue.markFailed(
        job.id,
        reason: item['message']?.toString() ?? jsonEncode(item),
      );
      session.failures += 1;
    }
  }

  Future<void> _pullCategories({
    required SyncSession session,
    required String businessId,
    required String deviceId,
    required String appVersion,
  }) async {
    final applier = _categoryApplier;
    if (applier == null) return;

    var cursor = _metadata.pullCursor ?? epochSyncCursor();
    var pages = 0;
    const maxPages = 20;

    while (pages < maxPages) {
      pages += 1;
      final response = await _transport.pull(
        deviceId: deviceId,
        appVersion: appVersion,
        cursor: cursor,
        limit: 200,
        entityTypes: categoryEntityType,
      );

      final changes = _asList(response['changes']);
      for (final change in changes) {
        final entityType = change['entity_type']?.toString();
        if (entityType != categoryEntityType) continue;
        final entityId = change['entity_id']?.toString();
        if (entityId == null) continue;
        final syncVersion = _readInt(change['sync_version']) ?? 1;
        final updatedAt = DateTime.tryParse(
              change['updated_at']?.toString() ?? '',
            )?.toUtc() ??
            DateTime.now().toUtc();
        final isDeleted = change['is_deleted'] == true;
        final deletedAt = DateTime.tryParse(
          change['deleted_at']?.toString() ?? '',
        )?.toUtc();
        final payload = change['payload'];
        await applier.applyChange(
          businessId: businessId,
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
          deviceId: change['device_id']?.toString(),
          payload: payload is Map<String, dynamic>
              ? payload
              : (payload is Map
                  ? Map<String, dynamic>.from(payload)
                  : null),
        );
        if (!isDeleted) {
          session.rowsDownloaded += 1;
        }
      }

      final next = response['next_cursor']?.toString();
      if (next != null && next.isNotEmpty) {
        cursor = next;
        await _metadata.setPullCursor(next);
      }

      final hasMore = response['has_more'] == true;
      if (!hasMore || changes.isEmpty) break;
    }
  }

  void dispose() {
    unawaited(_sessionController.close());
    unawaited(_planController.close());
  }

  SyncPlan _buildPlan({
    required BootstrapDecision decision,
    required int pendingRowCount,
    required int pendingCommandCount,
    required int pendingMediaCount,
    bool forceSteady = false,
  }) {
    final needsBootstrap = !forceSteady && decision.needsBootstrap;
    final steps = <SyncPlanStep>[
      SyncPlanStep.registerDevice,
      SyncPlanStep.fetchStatus,
    ];

    if (needsBootstrap) {
      steps.add(SyncPlanStep.bootstrap);
    } else {
      steps.addAll([
        SyncPlanStep.pushQueue,
        SyncPlanStep.pullChanges,
      ]);
    }
    steps.add(SyncPlanStep.complete);

    final willPush = !needsBootstrap && pendingRowCount > 0;
    final willPull = !needsBootstrap;

    return SyncPlan(
      planId: _uuid.v4(),
      createdAt: DateTime.now().toUtc(),
      steps: steps,
      needsBootstrap: needsBootstrap,
      willPush: willPush,
      willPull: willPull,
      willUploadMedia: false,
      pendingRowCount: pendingRowCount,
      pendingCommandCount: pendingCommandCount,
      pendingMediaCount: pendingMediaCount,
      reason: decision.reason,
    );
  }

  Future<SyncSession> _finishTransportFailure({
    required SyncSession session,
    required SyncStateEmitter emit,
    required SyncState currentState,
    required Object error,
    required String context,
  }) {
    final auth = _isAuthFailure(error);
    final phase = auth
        ? SyncOrchestrationPhase.authenticationFailed
        : SyncOrchestrationPhase.serverUnavailable;
    final message = '$context failed: $error';
    session.failures += 1;
    return Future.value(
      _finish(
        session: session,
        phase: phase,
        emit: emit,
        currentState: currentState,
        result: SyncResult(
          success: false,
          direction: SyncDirection.full,
          completedAt: DateTime.now().toUtc(),
          message: message,
          errorCount: 1,
        ),
        errorMessage: message,
      ),
    );
  }

  SyncSession _finish({
    required SyncSession session,
    required SyncOrchestrationPhase phase,
    required SyncStateEmitter emit,
    required SyncState currentState,
    required SyncResult result,
    SyncPlan? plan,
    String? errorMessage,
    int? pendingJobs,
  }) {
    session.finish(phase: phase, result: result, plan: plan);
    _setSession(session);

    final lifecycle = switch (phase) {
      SyncOrchestrationPhase.offline => SyncLifecycleState.offline,
      SyncOrchestrationPhase.authenticationFailed =>
        SyncLifecycleState.needsAuthentication,
      SyncOrchestrationPhase.serverUnavailable => SyncLifecycleState.failed,
      SyncOrchestrationPhase.ready ||
      SyncOrchestrationPhase.needsBootstrap ||
      SyncOrchestrationPhase.idle =>
        SyncLifecycleState.idle,
      _ => SyncLifecycleState.idle,
    };

    emit(
      (s) => s.copyWith(
        lifecycle: lifecycle,
        orchestrationPhase: phase,
        lastSyncTime: result.completedAt,
        pendingJobs: pendingJobs ?? s.pendingJobs,
        lastResultMessage: result.message,
        errorMessage: errorMessage,
        clearError: errorMessage == null,
        clearRunningJob: true,
        connectivity: currentState.connectivity,
      ),
    );
    return session;
  }

  void _emitPhase(
    SyncStateEmitter emit,
    SyncState currentState,
    SyncOrchestrationPhase phase, {
    required SyncLifecycleState lifecycle,
    String? runningJobId,
    bool clearError = false,
  }) {
    emit(
      (s) => s.copyWith(
        lifecycle: lifecycle,
        orchestrationPhase: phase,
        runningJobId: runningJobId,
        clearError: clearError,
        connectivity: currentState.connectivity,
      ),
    );
  }

  void _setSession(SyncSession? session) {
    _currentSession = session;
    if (!_sessionController.isClosed) {
      _sessionController.add(session);
    }
  }

  void _setPlan(SyncPlan? plan) {
    _currentPlan = plan;
    if (!_planController.isClosed) {
      _planController.add(plan);
    }
  }

  Future<List<SyncJob>> _safePendingJobs() async {
    try {
      return await _queue.listPending();
    } on Object {
      return const [];
    }
  }

  static ({int rows, int commands, int media}) _countByKind(
    List<SyncJob> jobs,
  ) {
    var rows = 0;
    var commands = 0;
    var media = 0;
    for (final job in jobs) {
      switch (job.kind) {
        case SyncQueueKind.row:
          rows++;
        case SyncQueueKind.command:
          commands++;
        case SyncQueueKind.media:
          media++;
      }
    }
    return (rows: rows, commands: commands, media: media);
  }

  static List<Map<String, dynamic>> _asList(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map<dynamic, dynamic>>()
        .map(Map<String, dynamic>.from)
        .toList();
  }

  static int? _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool _isAuthFailure(Object error) {
    if (error is DioException) {
      final code = error.response?.statusCode;
      if (code == 401 || code == 403) return true;
      final type = error.type;
      if (type == DioExceptionType.connectionTimeout ||
          type == DioExceptionType.sendTimeout ||
          type == DioExceptionType.receiveTimeout ||
          type == DioExceptionType.connectionError) {
        return false;
      }
    }
    final text = error.toString().toLowerCase();
    return text.contains('401') ||
        text.contains('unauthorized') ||
        text.contains('forbidden');
  }
}
