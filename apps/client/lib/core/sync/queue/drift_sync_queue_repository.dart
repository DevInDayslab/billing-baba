import 'dart:convert';

import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/models/sync_queue_enums.dart';
import 'package:billing_baba/core/sync/queue/sync_queue_dao.dart';
import 'package:billing_baba/core/sync/queue/sync_queue_repository.dart';
import 'package:drift/drift.dart';

/// Drift-backed [SyncQueueRepository].
class DriftSyncQueueRepository implements SyncQueueRepository {
  DriftSyncQueueRepository(AppDatabase db) : _dao = SyncQueueDao(db);

  DriftSyncQueueRepository.withDao(this._dao);

  final SyncQueueDao _dao;

  @override
  Future<void> enqueue(SyncJob job) {
    return _dao.insert(_toCompanion(job));
  }

  @override
  Future<SyncJob?> dequeue() async {
    final row = await _dao.nextPending();
    if (row == null) return null;
    await _dao.markRunning(row.id);
    final updated = await _dao.getById(row.id);
    return updated == null ? null : _fromRow(updated);
  }

  @override
  Future<SyncJob?> peek() async {
    final row = await _dao.peek();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<SyncJob?> nextPending() async {
    final row = await _dao.nextPending();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> retry(String jobId) => _dao.retry(jobId);

  @override
  Future<void> markRunning(String jobId) => _dao.markRunning(jobId);

  @override
  Future<void> markCompleted(String jobId) => _dao.markCompleted(jobId);

  @override
  Future<void> markFailed(String jobId, {String? reason}) =>
      _dao.markFailed(jobId, reason: reason);

  @override
  Future<void> markConflict(String jobId, {String? reason}) =>
      _dao.markConflict(jobId, reason: reason);

  @override
  Future<void> cancel(String jobId) => _dao.cancel(jobId);

  @override
  Future<void> clearCompleted() async {
    await _dao.clearCompleted();
  }

  @override
  Future<void> clear() async {
    await _dao.clearAll();
  }

  @override
  Future<int> count() => _dao.pendingCount();

  @override
  Future<int> pendingCount() => _dao.pendingCount();

  @override
  Stream<int> streamPendingCount() => _dao.streamPendingCount();

  @override
  Future<List<SyncJob>> listPending() async {
    final rows = await _dao.listPending();
    return rows.map(_fromRow).toList();
  }

  @override
  Stream<List<SyncJob>> watchPending() {
    return _dao.watchPending().map((rows) => rows.map(_fromRow).toList());
  }

  SyncQueueCompanion _toCompanion(SyncJob job) {
    return SyncQueueCompanion.insert(
      id: job.id,
      mutationId: job.mutationId,
      kind: job.kind.wire,
      entityType: job.entityType,
      entityId: Value(job.entityId),
      operation: job.operation.wire,
      payload: jsonEncode(job.payload),
      businessId: job.businessId,
      deviceId: Value(job.deviceId),
      commandId: Value(job.commandId),
      status: job.status.wire,
      priority: Value(job.priority.value),
      attemptCount: Value(job.attemptCount),
      createdAt: job.createdAt.toUtc(),
      scheduledAt: Value(job.scheduledAt?.toUtc()),
      lastAttemptAt: Value(job.lastAttemptAt?.toUtc()),
      nextRetryAt: Value(job.nextRetryAt?.toUtc()),
      lastError: Value(job.lastError),
    );
  }

  SyncJob _fromRow(SyncQueueData row) {
    Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(row.payload);
      payload = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{'value': decoded};
    } on Object {
      payload = <String, dynamic>{'raw': row.payload};
    }

    return SyncJob(
      id: row.id,
      mutationId: row.mutationId,
      kind: SyncQueueKind.fromWire(row.kind),
      entityType: row.entityType,
      entityId: row.entityId,
      operation: SyncQueueOperation.fromWire(row.operation),
      payload: payload,
      businessId: row.businessId,
      deviceId: row.deviceId,
      commandId: row.commandId,
      status: SyncQueueStatus.fromWire(row.status),
      priority: SyncQueuePriority.fromValue(row.priority),
      attemptCount: row.attemptCount,
      createdAt: row.createdAt,
      scheduledAt: row.scheduledAt,
      lastAttemptAt: row.lastAttemptAt,
      nextRetryAt: row.nextRetryAt,
      lastError: row.lastError,
    );
  }
}
