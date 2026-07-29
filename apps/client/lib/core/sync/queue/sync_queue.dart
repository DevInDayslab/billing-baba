import 'dart:convert';

import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Single Drift-backed sync queue. Every mutation becomes one [SyncJob].
class SyncQueue {
  SyncQueue(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  Future<void> enqueue(SyncJob job) {
    return _db.into(_db.syncQueue).insert(_toCompanion(job));
  }

  Future<SyncJob> enqueueRowMutation({
    required String businessId,
    required String entityType,
    required String entityId,
    required SyncQueueOperation operation,
    required Map<String, dynamic> payload,
    String? deviceId,
    SyncQueuePriority priority = SyncQueuePriority.normal,
    String? mutationId,
    int baseSyncVersion = 0,
    DateTime? clientUpdatedAt,
  }) {
    assert(
      operation == SyncQueueOperation.create ||
          operation == SyncQueueOperation.update ||
          operation == SyncQueueOperation.delete,
      'Row mutations must use create/update/delete',
    );
    final enriched = SyncJob.withPayloadMeta(
      payload,
      baseSyncVersion: baseSyncVersion,
      clientUpdatedAt: clientUpdatedAt ?? DateTime.now().toUtc(),
    );
    return _enqueue(
      kind: SyncQueueKind.row,
      businessId: businessId,
      deviceId: deviceId,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: enriched,
      priority: priority,
      mutationId: mutationId,
    );
  }

  Future<SyncJob> enqueueCommand({
    required String businessId,
    required String command,
    required String commandId,
    required Map<String, dynamic> payload,
    String? deviceId,
    String? entityType,
    String? entityId,
    SyncQueuePriority priority = SyncQueuePriority.normal,
  }) {
    final body = <String, dynamic>{
      ...payload,
      'command': command,
    };
    return _enqueue(
      kind: SyncQueueKind.command,
      businessId: businessId,
      deviceId: deviceId,
      entityType: entityType ?? 'command',
      entityId: entityId,
      operation: SyncQueueOperation.command,
      payload: body,
      priority: priority,
      commandId: commandId,
      mutationId: commandId,
    );
  }

  Future<SyncJob?> peek() async {
    final row = await _nextPendingRow();
    return row == null ? null : _fromRow(row);
  }

  Future<SyncJob?> nextPending() async {
    final row = await _nextPendingRow();
    return row == null ? null : _fromRow(row);
  }

  Future<void> markRunning(String jobId) async {
    final row = await _getById(jobId);
    if (row == null) return;
    await _update(
      jobId,
      SyncQueueCompanion(
        status: Value(SyncQueueStatus.running.wire),
        lastAttemptAt: Value(DateTime.now().toUtc()),
        attemptCount: Value(row.attemptCount + 1),
      ),
    );
  }

  Future<void> markCompleted(String jobId) {
    return _update(
      jobId,
      const SyncQueueCompanion(
        status: Value('completed'),
        lastError: Value(null),
        nextRetryAt: Value(null),
      ),
    );
  }

  Future<void> markFailed(String jobId, {String? reason, DateTime? nextRetryAt}) {
    return _update(
      jobId,
      SyncQueueCompanion(
        status: Value(SyncQueueStatus.failed.wire),
        lastError: Value(reason),
        lastAttemptAt: Value(DateTime.now().toUtc()),
        nextRetryAt: Value(nextRetryAt),
      ),
    );
  }

  Future<void> markConflict(String jobId, {String? reason}) {
    return _update(
      jobId,
      SyncQueueCompanion(
        status: Value(SyncQueueStatus.conflict.wire),
        lastError: Value(reason),
        lastAttemptAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> retry(String jobId) {
    return _update(
      jobId,
      const SyncQueueCompanion(
        status: Value('pending'),
        lastError: Value(null),
        nextRetryAt: Value(null),
      ),
    );
  }

  Future<void> cancel(String jobId) {
    return _update(
      jobId,
      const SyncQueueCompanion(status: Value('cancelled')),
    );
  }

  Future<void> clearCompleted() async {
    await (_db.delete(_db.syncQueue)
          ..where(
            (t) =>
                t.status.equals(SyncQueueStatus.completed.wire) |
                t.status.equals(SyncQueueStatus.cancelled.wire),
          ))
        .go();
  }

  Future<void> clear() async {
    await _db.delete(_db.syncQueue).go();
  }

  Future<int> count() => pendingCount();

  Future<int> pendingCount({DateTime? now, String? businessId}) async {
    final rows = await listPending(now: now, businessId: businessId);
    return rows.length;
  }

  Stream<int> streamPendingCount({String? businessId}) {
    return watchPending(businessId: businessId).map((jobs) => jobs.length);
  }

  Future<List<SyncJob>> listPending({DateTime? now, String? businessId}) async {
    final rows = await _listPendingRows(now: now, businessId: businessId);
    return rows.map(_fromRow).toList();
  }

  Stream<List<SyncJob>> watchPending({String? businessId}) {
    return (_db.select(_db.syncQueue)
          ..where((t) {
            final statusMatch =
                t.status.equals(SyncQueueStatus.pending.wire);
            if (businessId == null || businessId.isEmpty) {
              return statusMatch;
            }
            return statusMatch & t.businessId.equals(businessId);
          })
          ..orderBy([
            (t) => OrderingTerm.asc(t.priority),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .watch()
        .map((rows) {
      final at = DateTime.now().toUtc();
      return rows
          .where((r) {
            final next = r.nextRetryAt;
            return next == null || !next.isAfter(at);
          })
          .map(_fromRow)
          .toList();
    });
  }

  /// Resets jobs stuck in `running` after a crash back to `pending`.
  Future<int> resetRunningToPending({String? businessId}) async {
    final query = _db.update(_db.syncQueue)
      ..where((t) {
        final running = t.status.equals(SyncQueueStatus.running.wire);
        if (businessId == null || businessId.isEmpty) return running;
        return running & t.businessId.equals(businessId);
      });
    return query.write(
      const SyncQueueCompanion(status: Value('pending')),
    );
  }

  /// Re-queues failed jobs whose [nextRetryAt] has elapsed.
  Future<int> requeueRetryableFailures({DateTime? now, String? businessId}) async {
    final at = now ?? DateTime.now().toUtc();
    final rows = await (_db.select(_db.syncQueue)
          ..where((t) {
            final failed = t.status.equals(SyncQueueStatus.failed.wire) &
                t.nextRetryAt.isNotNull() &
                t.nextRetryAt.isSmallerOrEqualValue(at);
            if (businessId == null || businessId.isEmpty) return failed;
            return failed & t.businessId.equals(businessId);
          }))
        .get();
    var count = 0;
    for (final row in rows) {
      await retry(row.id);
      count += 1;
    }
    return count;
  }

  Future<SyncJob> _enqueue({
    required SyncQueueKind kind,
    required String businessId,
    required String entityType,
    required SyncQueueOperation operation,
    required Map<String, dynamic> payload,
    required SyncQueuePriority priority,
    String? deviceId,
    String? entityId,
    String? mutationId,
    String? commandId,
  }) async {
    final id = _uuid.v4();
    final job = SyncJob(
      id: id,
      mutationId: mutationId ?? _uuid.v4(),
      kind: kind,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: payload,
      businessId: businessId,
      deviceId: deviceId,
      commandId: commandId,
      status: SyncQueueStatus.pending,
      priority: priority,
      createdAt: DateTime.now().toUtc(),
    );
    await enqueue(job);
    return job;
  }

  Future<SyncQueueData?> _getById(String id) {
    return (_db.select(_db.syncQueue)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> _update(String id, SyncQueueCompanion companion) async {
    await (_db.update(_db.syncQueue)..where((t) => t.id.equals(id)))
        .write(companion);
  }

  Future<SyncQueueData?> _nextPendingRow({DateTime? now, String? businessId}) {
    final at = now ?? DateTime.now().toUtc();
    return (_db.select(_db.syncQueue)
          ..where((t) {
            final pending = t.status.equals(SyncQueueStatus.pending.wire) &
                (t.nextRetryAt.isNull() |
                    t.nextRetryAt.isSmallerOrEqualValue(at));
            if (businessId == null || businessId.isEmpty) return pending;
            return pending & t.businessId.equals(businessId);
          })
          ..orderBy([
            (t) => OrderingTerm.asc(t.priority),
            (t) => OrderingTerm.asc(t.createdAt),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<SyncQueueData>> _listPendingRows({
    DateTime? now,
    String? businessId,
  }) {
    final at = now ?? DateTime.now().toUtc();
    return (_db.select(_db.syncQueue)
          ..where((t) {
            final pending = t.status.equals(SyncQueueStatus.pending.wire) &
                (t.nextRetryAt.isNull() |
                    t.nextRetryAt.isSmallerOrEqualValue(at));
            if (businessId == null || businessId.isEmpty) return pending;
            return pending & t.businessId.equals(businessId);
          })
          ..orderBy([
            (t) => OrderingTerm.asc(t.priority),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .get();
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

  Future<List<SyncJob>> listJobsForEntity(String entityId) async {
    final rows = await (_db.select(_db.syncQueue)
          ..where((t) => t.entityId.equals(entityId)))
        .get();
    return rows.map(_fromRow).toList();
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
