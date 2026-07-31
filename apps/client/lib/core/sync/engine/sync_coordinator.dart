import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/engine/device_identity.dart';
import 'package:billing_baba/core/sync/engine/sync_metadata_store.dart';
import 'package:billing_baba/core/sync/engine/sync_pause_gate.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/models/sync_result.dart';
import 'package:billing_baba/core/sync/models/sync_state.dart';
import 'package:billing_baba/core/sync/network/sync_api.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/crm/data/crm_sync.dart';
import 'package:billing_baba/features/inventory/data/brand_sync.dart';
import 'package:billing_baba/features/inventory/data/category_sync.dart';
import 'package:billing_baba/features/inventory/data/godown_sync.dart';
import 'package:billing_baba/features/inventory/data/item_sync.dart';
import 'package:billing_baba/features/inventory/data/stock_level_sync.dart';
import 'package:billing_baba/features/inventory/data/unit_sync.dart';
import 'package:billing_baba/features/parties/data/party_sync.dart';
import 'package:billing_baba/features/purchases/data/expense_sync.dart';
import 'package:billing_baba/features/purchases/data/purchase_document_sync.dart';
import 'package:billing_baba/features/sales/data/sales_document_sync.dart';
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
    this._brandSync,
    this._partySync,
    this._itemSync,
    this._unitSync,
    this._taxRateSync,
    this._godownSync,
    this._businessSettingsSync,
    this._salesDocumentSync,
    this._purchaseDocumentSync,
    this._leadSync,
    this._leadActivitySync,
    this._contactSync,
    this._contactActivitySync,
    this._dealSync,
    this._expenseSync,
    this._expenseCategorySync,
    this._stockLevelSync,
    Uuid? uuid,
    this.categoryEntityType = 'categories',
    this.brandEntityType = 'brands',
    this.partyEntityType = 'parties',
    this.itemEntityType = 'items',
    this.unitEntityType = 'unit_definitions',
    this.taxRateEntityType = 'tax_rates',
    this.godownEntityType = 'godowns',
    this.businessSettingsEntityType = 'business_settings',
    this.salesDocumentsEntityType = 'sales_documents',
    this.salesDocumentLinesEntityType = 'sales_document_lines',
    this.purchaseDocumentsEntityType = 'purchase_documents',
    this.purchaseDocumentLinesEntityType = 'purchase_document_lines',
    this.leadsEntityType = 'leads',
    this.leadActivitiesEntityType = 'lead_activities',
    this.contactsEntityType = 'contacts',
    this.contactActivitiesEntityType = 'contact_activities',
    this.dealsEntityType = 'deals',
    this.expensesEntityType = 'expenses',
    this.expenseCategoriesEntityType = 'expense_categories',
    this.stockLevelsEntityType = 'stock_levels',
  })  : _uuid = uuid ?? const Uuid();

  final SyncApi _api;
  final SyncQueue _queue;
  final SyncDeviceIdentity _identity;
  final SyncMetadataStore _metadata;
  final StorageService _storage;
  final CategorySync? _categorySync;
  final BrandSync? _brandSync;
  final PartySync? _partySync;
  final ItemSync? _itemSync;
  final UnitSync? _unitSync;
  final TaxRateSync? _taxRateSync;
  final GodownSync? _godownSync;
  final BusinessSettingsSync? _businessSettingsSync;
  final SalesDocumentSync? _salesDocumentSync;
  final PurchaseDocumentSync? _purchaseDocumentSync;
  final LeadSync? _leadSync;
  final LeadActivitySync? _leadActivitySync;
  final ContactSync? _contactSync;
  final ContactActivitySync? _contactActivitySync;
  final DealSync? _dealSync;
  final ExpenseSync? _expenseSync;
  final ExpenseCategorySync? _expenseCategorySync;
  final StockLevelSync? _stockLevelSync;
  final Uuid _uuid;
  final String categoryEntityType;
  final String brandEntityType;
  final String partyEntityType;
  final String itemEntityType;
  final String unitEntityType;
  final String taxRateEntityType;
  final String godownEntityType;
  final String businessSettingsEntityType;
  final String salesDocumentsEntityType;
  final String salesDocumentLinesEntityType;
  final String purchaseDocumentsEntityType;
  final String purchaseDocumentLinesEntityType;
  final String leadsEntityType;
  final String leadActivitiesEntityType;
  final String contactsEntityType;
  final String contactActivitiesEntityType;
  final String dealsEntityType;
  final String expensesEntityType;
  final String expenseCategoriesEntityType;
  final String stockLevelsEntityType;

  String get _pullEntityTypes =>
      '$categoryEntityType,$brandEntityType,$partyEntityType,$itemEntityType,'
      '$unitEntityType,$taxRateEntityType,$godownEntityType,'
      '$businessSettingsEntityType,$salesDocumentsEntityType,'
      '$salesDocumentLinesEntityType,$purchaseDocumentsEntityType,'
      '$purchaseDocumentLinesEntityType,$leadsEntityType,'
      '$leadActivitiesEntityType,$contactsEntityType,'
      '$contactActivitiesEntityType,$dealsEntityType,'
      '$expensesEntityType,$expenseCategoriesEntityType,'
      '$stockLevelsEntityType';

  bool _isRowEntity(String? type) =>
      type == categoryEntityType ||
      type == brandEntityType ||
      type == partyEntityType ||
      type == itemEntityType ||
      type == unitEntityType ||
      type == taxRateEntityType ||
      type == godownEntityType ||
      type == businessSettingsEntityType ||
      type == salesDocumentsEntityType ||
      type == salesDocumentLinesEntityType ||
      type == purchaseDocumentsEntityType ||
      type == purchaseDocumentLinesEntityType ||
      type == leadsEntityType ||
      type == leadActivitiesEntityType ||
      type == contactsEntityType ||
      type == contactActivitiesEntityType ||
      type == dealsEntityType ||
      type == expensesEntityType ||
      type == expenseCategoriesEntityType;

  bool _busy = false;
  int _lastMaxPushMutations = 100;

  int get lastMaxPushMutations => _lastMaxPushMutations;

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
    var commandsUploaded = 0;
    var rowsDownloaded = 0;
    var conflicts = 0;
    var failures = 0;

    try {
      if (SyncPauseGate.instance.isPaused) {
        return SyncResult.noop(message: 'Sync paused during business switch');
      }

      final syncGeneration = SyncPauseGate.instance.generation;

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
      _lastMaxPushMutations =
          _readInt(statusPayload['max_push_mutations']) ?? 100;
      final supportedPushEntities = _readSupportedPushEntities(statusPayload);
      final pullCursor = _metadata.pullCursorFor(businessId);
      final bootstrappedAt = _metadata.bootstrappedAtFor(businessId);
      final lastServerSchemaVersion =
          _metadata.lastServerSchemaVersionFor(businessId);
      final needsBootstrap = _needsBootstrap(
        businessId: businessId,
        pullCursor: pullCursor,
        bootstrappedAt: bootstrappedAt,
        localSchemaVersion: _metadata.localSchemaVersion,
        lastServerSchemaVersion: lastServerSchemaVersion,
        serverSchemaVersion: serverSchema,
      );

      await _queue.resetRunningToPending(businessId: businessId);
      await _queue.requeueRetryableFailures(businessId: businessId);

      // Empty DB / no cursor → pull from epoch until done.
      if (needsBootstrap) {
        try {
          await _metadata.setPullCursorFor(businessId, epochSyncCursor());
          final downloaded = await _pullAll(
            businessId: businessId,
            deviceId: deviceId,
            appVersion: appVersion,
            syncGeneration: syncGeneration,
          );
          rowsDownloaded += downloaded;
          await _metadata.setBootstrappedAtFor(businessId, DateTime.now().toUtc());
          if (serverSchema != null) {
            await _metadata.setLastServerSchemaVersionFor(businessId, serverSchema);
          }
        } on Object catch (error) {
          return _finishFailure(
            emit: emit,
            error: error,
            context: 'bootstrap',
          );
        }
      }

      final pending = await _safePendingJobs(businessId: businessId);
      final rowJobs = pending
          .where(
            (j) =>
                j.kind == SyncQueueKind.row &&
                j.businessId == businessId &&
                _isRowEntity(j.entityType) &&
                supportedPushEntities.contains(j.entityType) &&
                j.status == SyncQueueStatus.pending,
          )
          .toList()
        ..sort(_compareRowPushOrder);

      if (rowJobs.isNotEmpty) {
        try {
          for (var offset = 0; offset < rowJobs.length; offset += _lastMaxPushMutations) {
            if (SyncPauseGate.instance.isStale(syncGeneration)) {
              return SyncResult.noop(
                message: 'Sync aborted during business switch',
              );
            }
            final chunkEnd =
                (offset + _lastMaxPushMutations).clamp(0, rowJobs.length);
            final chunk = rowJobs.sublist(offset, chunkEnd);
            final pushStats = await _pushRowJobs(
              deviceId: deviceId,
              appVersion: appVersion,
              jobs: chunk,
            );
            rowsUploaded += pushStats.uploaded;
            conflicts += pushStats.conflicts;
            failures += pushStats.failures;
          }
          await _queue.clearCompleted(businessId: businessId);
        } on Object catch (error) {
          for (final job in rowJobs) {
            if (job.status == SyncQueueStatus.running) {
              await _queue.markFailed(
                job.id,
                reason: 'push failed: $error',
                nextRetryAt: _nextRetryAt(job.attemptCount),
              );
            }
          }
          return _finishFailure(
            emit: emit,
            error: error,
            context: 'push',
          );
        }
      }

      final documentRowBacklog =
          await _queue.listDocumentRowBacklog(businessId: businessId);
      final commandJobs = pending
          .where(
            (j) =>
                j.kind == SyncQueueKind.command &&
                j.businessId == businessId &&
                _isSupportedCommand(j.payload['command']?.toString()) &&
                j.status == SyncQueueStatus.pending &&
                !_commandBlockedByDocumentRowBacklog(j, documentRowBacklog),
          )
          .toList();

      if (commandJobs.isNotEmpty) {
        try {
          for (var offset = 0;
              offset < commandJobs.length;
              offset += _lastMaxPushMutations) {
            if (SyncPauseGate.instance.isStale(syncGeneration)) {
              return SyncResult.noop(
                message: 'Sync aborted during business switch',
              );
            }
            final chunkEnd =
                (offset + _lastMaxPushMutations).clamp(0, commandJobs.length);
            final chunk = commandJobs.sublist(offset, chunkEnd);
            final pushStats = await _pushCommandJobs(
              deviceId: deviceId,
              appVersion: appVersion,
              jobs: chunk,
            );
            commandsUploaded += pushStats.uploaded;
            conflicts += pushStats.conflicts;
            failures += pushStats.failures;
          }
          await _queue.clearCompleted(businessId: businessId);
        } on Object catch (error) {
          for (final job in commandJobs) {
            if (job.status == SyncQueueStatus.running) {
              await _queue.markFailed(
                job.id,
                reason: 'command push failed: $error',
                nextRetryAt: _nextRetryAt(job.attemptCount),
              );
            }
          }
          return _finishFailure(
            emit: emit,
            error: error,
            context: 'command push',
          );
        }
      }

      try {
        final downloaded = await _pullAll(
          businessId: businessId,
          deviceId: deviceId,
          appVersion: appVersion,
          syncGeneration: syncGeneration,
        );
        rowsDownloaded += downloaded;
      } on Object catch (error) {
        return _finishFailure(
          emit: emit,
          error: error,
          context: 'pull',
        );
      }

      final remaining = await _safePendingJobs(businessId: businessId);
      final message =
          'Sync complete (push=$rowsUploaded, commands=$commandsUploaded, '
          'pull=$rowsDownloaded, conflicts=$conflicts, failures=$failures)';

      try {
        LoggingService.instance.info('SyncCoordinator: $message');
      } on Object {
        // Logging may be unavailable in unit tests without dotenv.
      }

      final result = SyncResult(
        success: failures == 0,
        completedAt: DateTime.now().toUtc(),
        message: message,
        acceptedCount: rowsUploaded + commandsUploaded,
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

    final pushJobs = await _queue.remediateInvalidLineEntityIds(jobs);

    final mutations = <Map<String, dynamic>>[];
    for (final job in pushJobs) {
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

    final byMutation = {for (final job in pushJobs) job.mutationId: job};

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
        nextRetryAt: _isTransientPushError(item)
            ? _nextRetryAt(job.attemptCount)
            : null,
      );
      failures += 1;
    }

    return (uploaded: uploaded, conflicts: conflicts, failures: failures);
  }

  Future<({int uploaded, int conflicts, int failures})> _pushCommandJobs({
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
      final command = job.payload['command']?.toString() ?? '';
      mutations.add({
        'mutation_id': job.mutationId,
        'kind': 'command',
        'command': command,
        'command_id': job.commandId ?? job.mutationId,
        'payload': _commandPayload(job.payload),
        'client_updated_at': job.createdAt.toUtc().toIso8601String(),
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
      await _queue.markCompleted(job.id);
      uploaded += 1;
    }

    for (final item in _asList(response['replayed'])) {
      final mutationId = item['mutation_id']?.toString();
      final job = mutationId == null ? null : byMutation[mutationId];
      if (job == null) continue;
      await _queue.markCompleted(job.id);
      uploaded += 1;
    }

    for (final item in _asList(response['conflicts'])) {
      final mutationId = item['mutation_id']?.toString();
      final job = mutationId == null ? null : byMutation[mutationId];
      if (job == null) continue;
      await _queue.markConflict(
        job.id,
        reason: item['code']?.toString() ?? jsonEncode(item),
      );
      conflicts += 1;
    }

    for (final item in _asList(response['errors'])) {
      final mutationId = item['mutation_id']?.toString();
      final job = mutationId == null ? null : byMutation[mutationId];
      if (job == null) continue;
      final code = item['code']?.toString() ?? 'ERROR';
      await _queue.markFailed(
        job.id,
        reason: item['message']?.toString() ?? jsonEncode(item),
        nextRetryAt: code == 'IDEMPOTENCY_PAYLOAD_MISMATCH'
            ? null
            : _isTransientPushError(item)
                ? _nextRetryAt(job.attemptCount)
                : null,
      );
      failures += 1;
    }

    return (uploaded: uploaded, conflicts: conflicts, failures: failures);
  }

  static Map<String, dynamic> _commandPayload(Map<String, dynamic> payload) {
    final copy = Map<String, dynamic>.from(payload);
    copy.remove('command');
    return copy;
  }

  static bool _isSupportedCommand(String? command) {
    if (command == null || command.isEmpty) return false;
    return _supportedCommandKinds.contains(command);
  }

  /// Parents before children: sales_documents → sales_document_lines.
  static int _compareRowPushOrder(SyncJob a, SyncJob b) {
    final priority = a.priority.value.compareTo(b.priority.value);
    if (priority != 0) return priority;

    final rank = _rowPushDependencyRank(a.entityType)
        .compareTo(_rowPushDependencyRank(b.entityType));
    if (rank != 0) return rank;

    return a.createdAt.compareTo(b.createdAt);
  }

  static int _rowPushDependencyRank(String? entityType) {
    switch (entityType) {
      case 'sales_documents':
      case 'purchase_documents':
        return 1;
      case 'sales_document_lines':
      case 'purchase_document_lines':
        return 2;
      default:
        return 0;
    }
  }

  static bool _commandBlockedByDocumentRowBacklog(
    SyncJob command,
    List<SyncJob> backlog,
  ) {
    final documentId = command.entityId?.trim();
    if (documentId == null || documentId.isEmpty) return false;

    for (final job in backlog) {
      if (job.entityType == 'sales_documents' && job.entityId == documentId) {
        return true;
      }
      if (job.entityType == 'sales_document_lines') {
        final parentId = SyncJob.domainOnly(job.payload)['sales_document_id']
            ?.toString();
        if (parentId == documentId) return true;
      }
      if (job.entityType == 'purchase_documents' && job.entityId == documentId) {
        return true;
      }
      if (job.entityType == 'purchase_document_lines') {
        final parentId =
            SyncJob.domainOnly(job.payload)['purchase_document_id']?.toString();
        if (parentId == documentId) return true;
      }
    }
    return false;
  }

  /// One-time stock_levels bootstrap when stockLevelsReconciledAt is unset.
  ///
  /// Uses epoch cursor and stock_levels-only entity filter so rows older than the
  /// shared pull cursor are still received. Does not advance the global cursor.
  Future<int> _pullStockLevelsFromEpoch({
    required String businessId,
    required String deviceId,
    required String appVersion,
    required int syncGeneration,
  }) async {
    if (_stockLevelSync == null) return 0;
    if (_metadata.stockLevelsReconciledAtFor(businessId) != null) return 0;

    var downloaded = 0;
    var cursor = epochSyncCursor();
    var pages = 0;
    const maxPages = 50;
    const limit = 500;

    while (pages < maxPages) {
      if (SyncPauseGate.instance.isStale(syncGeneration)) {
        return downloaded;
      }

      pages += 1;
      final response = await _api.pull(
        deviceId: deviceId,
        appVersion: appVersion,
        cursor: cursor,
        limit: limit,
        entityTypes: stockLevelsEntityType,
      );

      if (SyncPauseGate.instance.isStale(syncGeneration)) {
        return downloaded;
      }

      final changes = _asList(response['changes']);
      downloaded += await _applyPullChanges(
        changes: changes,
        businessId: businessId,
      );

      final next = response['next_cursor']?.toString();
      if (next != null && next.isNotEmpty) {
        cursor = next;
      }

      final hasMore = response['has_more'] == true;
      if (!hasMore || changes.isEmpty) break;
    }

    await _metadata.setStockLevelsReconciledAtFor(
      businessId,
      DateTime.now().toUtc(),
    );
    return downloaded;
  }

  Future<int> _pullAll({
    required String businessId,
    required String deviceId,
    required String appVersion,
    required int syncGeneration,
  }) async {
    var downloaded = await _pullStockLevelsFromEpoch(
      businessId: businessId,
      deviceId: deviceId,
      appVersion: appVersion,
      syncGeneration: syncGeneration,
    );
    var cursor = _metadata.pullCursorFor(businessId) ?? epochSyncCursor();
    var pages = 0;
    const maxPages = 50;

    while (pages < maxPages) {
      if (SyncPauseGate.instance.isStale(syncGeneration)) {
        return downloaded;
      }

      pages += 1;
      final response = await _api.pull(
        deviceId: deviceId,
        appVersion: appVersion,
        cursor: cursor,
        limit: 200,
        entityTypes: _pullEntityTypes,
      );

      if (SyncPauseGate.instance.isStale(syncGeneration)) {
        return downloaded;
      }

      final changes = _asList(response['changes']);
      downloaded += await _applyPullChanges(
        changes: changes,
        businessId: businessId,
      );

      final next = response['next_cursor']?.toString();
      if (next != null && next.isNotEmpty) {
        cursor = next;
        await _metadata.setPullCursorFor(businessId, next);
      }

      final hasMore = response['has_more'] == true;
      if (!hasMore || changes.isEmpty) break;
    }

    return downloaded;
  }

  Future<int> _applyPullChanges({
    required List<Map<String, dynamic>> changes,
    required String businessId,
  }) async {
    var downloaded = 0;
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
      case 'brands':
        await _brandSync?.applyChange(
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
      case 'sales_documents':
      case 'sales_document_lines':
        await _salesDocumentSync?.applyChange(
          businessId: businessId,
          entityType: entityType,
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
          deviceId: deviceId,
          payload: payload,
        );
      case 'purchase_documents':
      case 'purchase_document_lines':
        await _purchaseDocumentSync?.applyChange(
          businessId: businessId,
          entityType: entityType,
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
          deviceId: deviceId,
          payload: payload,
        );
      case 'leads':
        await _leadSync?.applyChange(
          businessId: businessId,
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
          deviceId: deviceId,
          payload: payload,
        );
      case 'lead_activities':
        await _leadActivitySync?.applyChange(
          businessId: businessId,
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
          deviceId: deviceId,
          payload: payload,
        );
      case 'contacts':
        await _contactSync?.applyChange(
          businessId: businessId,
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
          deviceId: deviceId,
          payload: payload,
        );
      case 'contact_activities':
        await _contactActivitySync?.applyChange(
          businessId: businessId,
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
          deviceId: deviceId,
          payload: payload,
        );
      case 'deals':
        await _dealSync?.applyChange(
          businessId: businessId,
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
          deviceId: deviceId,
          payload: payload,
        );
      case 'expenses':
        await _expenseSync?.applyChange(
          businessId: businessId,
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
          deviceId: deviceId,
          payload: payload,
        );
      case 'expense_categories':
        await _expenseCategorySync?.applyChange(
          businessId: businessId,
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
          deviceId: deviceId,
          payload: payload,
        );
      case 'stock_levels':
        await _stockLevelSync?.applyChange(
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
      case 'brands':
        await _brandSync?.updateAckMeta(
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
      case 'sales_documents':
      case 'sales_document_lines':
        await _salesDocumentSync?.updateAckMeta(
          entityType: entityType,
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          deviceId: deviceId,
        );
      case 'purchase_documents':
      case 'purchase_document_lines':
        await _purchaseDocumentSync?.updateAckMeta(
          entityType: entityType,
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          deviceId: deviceId,
        );
      case 'leads':
        await _leadSync?.updateAckMeta(
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          deviceId: deviceId,
        );
      case 'lead_activities':
        await _leadActivitySync?.updateAckMeta(
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          deviceId: deviceId,
        );
      case 'contacts':
        await _contactSync?.updateAckMeta(
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          deviceId: deviceId,
        );
      case 'contact_activities':
        await _contactActivitySync?.updateAckMeta(
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          deviceId: deviceId,
        );
      case 'deals':
        await _dealSync?.updateAckMeta(
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          deviceId: deviceId,
        );
      case 'expenses':
        await _expenseSync?.updateAckMeta(
          entityId: entityId,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          deviceId: deviceId,
        );
      case 'expense_categories':
        await _expenseCategorySync?.updateAckMeta(
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

  Future<List<SyncJob>> _safePendingJobs({required String businessId}) async {
    try {
      return await _queue.listPending(businessId: businessId);
    } on Object {
      return const [];
    }
  }

  static DateTime _nextRetryAt(int attemptCount) {
    const baseSeconds = [1, 2, 4, 8, 16, 32];
    final index = attemptCount.clamp(0, baseSeconds.length - 1);
    return DateTime.now().toUtc().add(Duration(seconds: baseSeconds[index]));
  }

  static bool _isTransientPushError(Map<String, dynamic> item) {
    final code = item['code']?.toString().toUpperCase() ?? '';
    return code.contains('TIMEOUT') ||
        code.contains('BUSY') ||
        code.contains('UNAVAILABLE') ||
        code.contains('NETWORK');
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

  /// Entity types the server accepts on `/sync/push` (from `/sync/status`).
  static Set<String> _readSupportedPushEntities(
    Map<String, dynamic> statusPayload,
  ) {
    final raw = statusPayload['supported_entities'];
    if (raw is List) {
      final entities = raw
          .map((e) => e.toString())
          .where((s) => s.isNotEmpty)
          .toSet();
      if (entities.isNotEmpty) return entities;
    }
    return _fallbackPushEntityTypes;
  }

  /// Commands accepted by `/sync/push` (see api command-registry.ts).
  static const Set<String> _supportedCommandKinds = {
    'finalize_sale',
    'finalize_purchase',
    'finalize_credit_note',
    'finalize_debit_note',
  };

  /// Used when the server omits `supported_entities` (tests, older builds).
  static const Set<String> _fallbackPushEntityTypes = {
    'categories',
    'parties',
    'items',
    'unit_definitions',
    'tax_rates',
    'godowns',
    'business_settings',
    'sales_documents',
    'sales_document_lines',
    'purchase_documents',
    'purchase_document_lines',
  };

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
