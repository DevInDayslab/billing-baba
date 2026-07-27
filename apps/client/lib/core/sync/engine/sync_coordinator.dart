import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/engine/device_identity.dart';
import 'package:billing_baba/core/sync/engine/sync_metadata_store.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/models/sync_result.dart';
import 'package:billing_baba/core/sync/models/sync_state.dart';
import 'package:billing_baba/core/sync/network/sync_api.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/inventory/data/category_sync.dart';
import 'package:billing_baba/features/inventory/data/godown_sync.dart';
import 'package:billing_baba/features/inventory/data/item_sync.dart';
import 'package:billing_baba/features/inventory/data/unit_sync.dart';
import 'package:billing_baba/features/parties/data/party_sync.dart';
import 'package:billing_baba/features/settings/data/business_settings_sync.dart';
import 'package:billing_baba/features/settings/data/tax_rate_sync.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

typedef SyncStateEmitter = void Function(
  SyncState Function(SyncState current) update,
);

/// Owns the synchronization workflow: register → status → bootstrap → push → pull.
class SyncCoordinator {
  SyncCoordinator({
    required this._api,
    required this._queue,
    required this._identity,
    required this._metadata,
    required this._storage,
    this._categorySync,
    this._partySync,
    this._itemSync,
    this._unitSync,
    this._taxRateSync,
    this._godownSync,
    this._businessSettingsSync,
    Uuid? uuid,
    this.categoryEntityType = 'categories',
    this.partyEntityType = 'parties',
    this.itemEntityType = 'items',
    this.unitEntityType = 'unit_definitions',
    this.taxRateEntityType = 'tax_rates',
    this.godownEntityType = 'godowns',
    this.businessSettingsEntityType = 'business_settings',
  })  : _uuid = uuid ?? const Uuid();

  final SyncApi _api;
  final SyncQueue _queue;
  final SyncDeviceIdentity _identity;
  final SyncMetadataStore _metadata;
  final StorageService _storage;
  final CategorySync? _categorySync;
  final PartySync? _partySync;
  final ItemSync? _itemSync;
  final UnitSync? _unitSync;
  final TaxRateSync? _taxRateSync;
  final GodownSync? _godownSync;
  final BusinessSettingsSync? _businessSettingsSync;
  final Uuid _uuid;
  final String categoryEntityType;
  final String partyEntityType;
  final String itemEntityType;
  final String unitEntityType;
  final String taxRateEntityType;
  final String godownEntityType;
  final String businessSettingsEntityType;

  String get _pullEntityTypes =>
      '$categoryEntityType,$partyEntityType,$itemEntityType,'
      '$unitEntityType,$taxRateEntityType,$godownEntityType,'
      '$businessSettingsEntityType';

  bool _isRowEntity(String? type) =>
      type == categoryEntityType ||
      type == partyEntityType ||
      type == itemEntityType ||
      type == unitEntityType ||
      type == taxRateEntityType ||
      type == godownEntityType ||
      type == businessSettingsEntityType;

  bool _busy = false;

  /// Runs one full sync pass. Returns a [SyncResult].
  Future<SyncResult> orchestrate({
    required SyncState currentState,
    required SyncStateEmitter emit,
  }) async {
    if (_busy) {
      return SyncResult.noop(message: 'Sync already in progress');
    }
    _busy = true;

    var rowsUploaded = 0;
    var rowsDownloaded = 0;
    var conflicts = 0;
    var failures = 0;

    try {
      if (currentState.connectivity == SyncConnectivityStatus.offline) {
        emit(
          (s) => s.copyWith(
            lifecycle: SyncLifecycleState.offline,
            lastResultMessage: 'Offline — sync skipped',
            errorMessage: 'Device is offline',
          ),
        );
        return SyncResult.noop(message: 'Offline — sync skipped');
      }

      emit(
        (s) => s.copyWith(
          lifecycle: SyncLifecycleState.syncing,
          clearError: true,
        ),
      );

      final deviceId = await _identity.deviceId();
      final appVersion = await _identity.appVersion();

      try {
        await _api.registerDevice(
          deviceId: deviceId,
          platform: _identity.platform(),
          appVersion: appVersion,
          deviceName: _identity.deviceName(),
        );
      } on Object catch (error) {
        return _finishFailure(
          emit: emit,
          error: error,
          context: 'registerDevice',
        );
      }

      late final Map<String, dynamic> statusPayload;
      try {
        statusPayload = await _api.status(
          deviceId: deviceId,
          appVersion: appVersion,
        );
      } on Object catch (error) {
        return _finishFailure(
          emit: emit,
          error: error,
          context: 'status',
        );
      }

      final businessId = _storage.read(StorageKeys.lastOpenedBusinessId);
      if (businessId == null || businessId.isEmpty) {
        emit(
          (s) => s.copyWith(
            lifecycle: SyncLifecycleState.idle,
            lastResultMessage: 'No business selected',
            errorMessage: 'No business selected',
          ),
        );
        return SyncResult(
          success: false,
          completedAt: DateTime.now().toUtc(),
          message: 'No business selected',
          errorCount: 1,
        );
      }

      final serverSchema = _readInt(statusPayload['schema_version']);
      final needsBootstrap = _needsBootstrap(
        businessId: businessId,
        pullCursor: _metadata.pullCursor,
        bootstrappedAt: _metadata.bootstrappedAt,
        localSchemaVersion: _metadata.localSchemaVersion,
        lastServerSchemaVersion: _metadata.lastServerSchemaVersion,
        serverSchemaVersion: serverSchema,
      );

      // Empty DB / no cursor → pull from epoch until done.
      if (needsBootstrap) {
        try {
          await _metadata.setPullCursor(epochSyncCursor());
          final downloaded = await _pullAll(
            businessId: businessId,
            deviceId: deviceId,
            appVersion: appVersion,
          );
          rowsDownloaded += downloaded;
          await _metadata.setBootstrappedAt(DateTime.now().toUtc());
          if (serverSchema != null) {
            await _metadata.setLastServerSchemaVersion(serverSchema);
          }
        } on Object catch (error) {
          return _finishFailure(
            emit: emit,
            error: error,
            context: 'bootstrap',
          );
        }
      }

      final pending = await _safePendingJobs();
      final rowJobs = pending
          .where(
            (j) =>
                j.kind == SyncQueueKind.row &&
                _isRowEntity(j.entityType) &&
                j.status == SyncQueueStatus.pending,
          )
          .toList();

      if (rowJobs.isNotEmpty) {
        try {
          final pushStats = await _pushRowJobs(
            deviceId: deviceId,
            appVersion: appVersion,
            jobs: rowJobs,
          );
          rowsUploaded += pushStats.uploaded;
          conflicts += pushStats.conflicts;
          failures += pushStats.failures;
        } on Object catch (error) {
          for (final job in rowJobs) {
            await _queue.markFailed(job.id, reason: 'push failed: $error');
          }
          return _finishFailure(
            emit: emit,
            error: error,
            context: 'push',
          );
        }
      }

      try {
        final downloaded = await _pullAll(
          businessId: businessId,
          deviceId: deviceId,
          appVersion: appVersion,
        );
        rowsDownloaded += downloaded;
      } on Object catch (error) {
        return _finishFailure(
          emit: emit,
          error: error,
          context: 'pull',
        );
      }

      final remaining = await _safePendingJobs();
      final message =
          'Sync complete (push=$rowsUploaded, pull=$rowsDownloaded, '
          'conflicts=$conflicts, failures=$failures)';

      try {
        LoggingService.instance.info('SyncCoordinator: $message');
      } on Object {
        // Logging may be unavailable in unit tests without dotenv.
      }

      final result = SyncResult(
        success: failures == 0,
        completedAt: DateTime.now().toUtc(),
        message: message,
        acceptedCount: rowsUploaded,
        conflictCount: conflicts,
        errorCount: failures,
      );

      emit(
        (s) => s.copyWith(
          lifecycle: SyncLifecycleState.idle,
          lastSyncTime: result.completedAt,
          pendingJobs: remaining.length,
          lastResultMessage: message,
          clearError: true,
          clearRunningJob: true,
        ),
      );
      return result;
    } finally {
      _busy = false;
    }
  }

  void dispose() {}

  bool _needsBootstrap({
    required String? businessId,
    required String? pullCursor,
    required DateTime? bootstrappedAt,
    required int localSchemaVersion,
    required int? lastServerSchemaVersion,
    required int? serverSchemaVersion,
  }) {
    if (businessId == null || businessId.isEmpty) return true;
    if (bootstrappedAt == null || pullCursor == null || pullCursor.isEmpty) {
      return true;
    }
    if (serverSchemaVersion != null &&
        lastServerSchemaVersion != null &&
        serverSchemaVersion > lastServerSchemaVersion) {
      return true;
    }
    if (serverSchemaVersion != null &&
        serverSchemaVersion > localSchemaVersion &&
        lastServerSchemaVersion == null) {
      return true;
    }
    return false;
  }

  Future<({int uploaded, int conflicts, int failures})> _pushRowJobs({
    required String deviceId,
    required String appVersion,
    required List<SyncJob> jobs,
  }) async {
    var uploaded = 0;
    var conflicts = 0;
    var failures = 0;

    final mutations = <Map<String, dynamic>>[];
    for (final job in jobs) {
      await _queue.markRunning(job.id);
      mutations.add({
        'mutation_id': job.mutationId,
        'kind': 'row',
        'entity_type': job.entityType,
        'entity_id': job.entityId,
        'operation': job.operation.wire,
        'base_sync_version': SyncJob.readBaseSyncVersion(job.payload),
        'payload': SyncJob.domainOnly(job.payload),
        'client_updated_at': SyncJob.readClientUpdatedAt(job.payload),
      });
    }

    final response = await _api.push(
      deviceId: deviceId,
      appVersion: appVersion,
      body: {
        'device_id': deviceId,
        'client_batch_id': _uuid.v4(),
        'mutations': mutations,
      },
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
      await _applyAck(
        entityType: job.entityType,
        entityId: job.entityId ?? '',
        syncVersion: syncVersion,
        updatedAt: updatedAt,
        deviceId: deviceId,
      );
      await _queue.markCompleted(job.id);
      uploaded += 1;
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
        await _applyAck(
          entityType: job.entityType,
          entityId: job.entityId!,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          deviceId: deviceId,
        );
      }
      await _queue.markCompleted(job.id);
      uploaded += 1;
    }

    for (final item in _asList(response['conflicts'])) {
      final mutationId = item['mutation_id']?.toString();
      final job = mutationId == null ? null : byMutation[mutationId];
      if (job == null) continue;
      // Keep local row; do not overwrite with server_payload.
      await _queue.markConflict(job.id, reason: jsonEncode(item));
      conflicts += 1;
    }

    for (final item in _asList(response['errors'])) {
      final mutationId = item['mutation_id']?.toString();
      final job = mutationId == null ? null : byMutation[mutationId];
      if (job == null) continue;
      await _queue.markFailed(
        job.id,
        reason: item['message']?.toString() ?? jsonEncode(item),
      );
      failures += 1;
    }

    return (uploaded: uploaded, conflicts: conflicts, failures: failures);
  }

  Future<int> _pullAll({
    required String businessId,
    required String deviceId,
    required String appVersion,
  }) async {
    var downloaded = 0;
    var cursor = _metadata.pullCursor ?? epochSyncCursor();
    var pages = 0;
    const maxPages = 50;

    while (pages < maxPages) {
      pages += 1;
      final response = await _api.pull(
        deviceId: deviceId,
        appVersion: appVersion,
        cursor: cursor,
        limit: 200,
        entityTypes: _pullEntityTypes,
      );

      final changes = _asList(response['changes']);
      for (final change in changes) {
        final entityType = change['entity_type']?.toString();
        final entityId = change['entity_id']?.toString();
        if (entityType == null || entityId == null) continue;

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
        final payloadMap = payload is Map<String, dynamic>
            ? payload
            : (payload is Map ? Map<String, dynamic>.from(payload) : null);

        await _applyChange(
          entityType: entityType,
          businessId: businessId,
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
          deviceId: change['device_id']?.toString(),
          payload: payloadMap,
        );
        if (!isDeleted) downloaded += 1;
      }

      final next = response['next_cursor']?.toString();
      if (next != null && next.isNotEmpty) {
        cursor = next;
        await _metadata.setPullCursor(next);
      }

      final hasMore = response['has_more'] == true;
      if (!hasMore || changes.isEmpty) break;
    }

    return downloaded;
  }

  Future<void> _applyChange({
    required String entityType,
    required String businessId,
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    required bool isDeleted,
    DateTime? deletedAt,
    String? deviceId,
    Map<String, dynamic>? payload,
  }) async {
    switch (entityType) {
      case 'categories':
        await _categorySync?.applyChange(
          businessId: businessId,
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
          deviceId: deviceId,
          payload: payload,
        );
      case 'parties':
        await _partySync?.applyChange(
          businessId: businessId,
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
          deviceId: deviceId,
          payload: payload,
        );
      case 'items':
        await _itemSync?.applyChange(
          businessId: businessId,
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
          deviceId: deviceId,
          payload: payload,
        );
      case 'unit_definitions':
        await _unitSync?.applyChange(
          businessId: businessId,
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
          deviceId: deviceId,
          payload: payload,
        );
      case 'tax_rates':
        await _taxRateSync?.applyChange(
          businessId: businessId,
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
          deviceId: deviceId,
          payload: payload,
        );
      case 'godowns':
        await _godownSync?.applyChange(
          businessId: businessId,
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
          deviceId: deviceId,
          payload: payload,
        );
      case 'business_settings':
        await _businessSettingsSync?.applyChange(
          businessId: businessId,
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
          deviceId: deviceId,
          payload: payload,
        );
      default:
        // Unknown entity — ignore until that entity ships.
        break;
    }
  }

  Future<void> _applyAck({
    required String entityType,
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    String? deviceId,
  }) async {
    switch (entityType) {
      case 'categories':
        await _categorySync?.updateAckMeta(
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          deviceId: deviceId,
        );
      case 'parties':
        await _partySync?.updateAckMeta(
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          deviceId: deviceId,
        );
      case 'items':
        await _itemSync?.updateAckMeta(
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          deviceId: deviceId,
        );
      case 'unit_definitions':
        await _unitSync?.updateAckMeta(
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          deviceId: deviceId,
        );
      case 'tax_rates':
        await _taxRateSync?.updateAckMeta(
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          deviceId: deviceId,
        );
      case 'godowns':
        await _godownSync?.updateAckMeta(
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          deviceId: deviceId,
        );
      case 'business_settings':
        await _businessSettingsSync?.updateAckMeta(
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          deviceId: deviceId,
        );
      default:
        break;
    }
  }

  Future<SyncResult> _finishFailure({
    required SyncStateEmitter emit,
    required Object error,
    required String context,
  }) {
    final auth = _isAuthFailure(error);
    final lifecycle = auth
        ? SyncLifecycleState.needsAuthentication
        : SyncLifecycleState.failed;
    final message = '$context failed: $error';
    emit(
      (s) => s.copyWith(
        lifecycle: lifecycle,
        lastResultMessage: message,
        errorMessage: message,
        clearRunningJob: true,
      ),
    );
    return Future.value(
      SyncResult(
        success: false,
        completedAt: DateTime.now().toUtc(),
        message: message,
        errorCount: 1,
      ),
    );
  }

  Future<List<SyncJob>> _safePendingJobs() async {
    try {
      return await _queue.listPending();
    } on Object {
      return const [];
    }
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
    }
    final text = error.toString().toLowerCase();
    return text.contains('401') ||
        text.contains('unauthorized') ||
        text.contains('forbidden');
  }
}
