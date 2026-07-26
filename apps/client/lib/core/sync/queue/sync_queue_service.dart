import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/models/sync_job_payload_meta.dart';
import 'package:billing_baba/core/sync/models/sync_queue_enums.dart';
import 'package:billing_baba/core/sync/queue/sync_queue_repository.dart';
import 'package:uuid/uuid.dart';

/// Application façade over [SyncQueueRepository].
///
/// Generates UUIDs and encodes payloads; does not expose Drift types.
class SyncQueueService {
  SyncQueueService(this._repository, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final SyncQueueRepository _repository;
  final Uuid _uuid;

  Future<void> enqueue(SyncJob job) => _repository.enqueue(job);

  Future<SyncJob?> dequeue() => _repository.dequeue();

  Future<SyncJob?> peek() => _repository.peek();

  Future<SyncJob?> nextPending() => _repository.nextPending();

  Future<void> retry(String jobId) => _repository.retry(jobId);

  Future<void> markRunning(String jobId) => _repository.markRunning(jobId);

  Future<void> markCompleted(String jobId) =>
      _repository.markCompleted(jobId);

  Future<void> markFailed(String jobId, {String? reason}) =>
      _repository.markFailed(jobId, reason: reason);

  Future<void> markConflict(String jobId, {String? reason}) =>
      _repository.markConflict(jobId, reason: reason);

  Future<void> cancel(String jobId) => _repository.cancel(jobId);

  Future<void> clearCompleted() => _repository.clearCompleted();

  Future<void> clear() => _repository.clear();

  Future<int> count() => _repository.count();

  Future<int> pendingCount() => _repository.pendingCount();

  Stream<int> streamPendingCount() => _repository.streamPendingCount();

  Future<List<SyncJob>> listPending() => _repository.listPending();

  Stream<List<SyncJob>> watchPending() => _repository.watchPending();

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
    final enriched = SyncJobPayloadMeta.withMeta(
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

  Future<SyncJob> enqueueMedia({
    required String businessId,
    required Map<String, dynamic> payload,
    String? deviceId,
    String? entityType,
    String? entityId,
    SyncQueuePriority priority = SyncQueuePriority.normal,
    String? mutationId,
  }) {
    return _enqueue(
      kind: SyncQueueKind.media,
      businessId: businessId,
      deviceId: deviceId,
      entityType: entityType ?? 'media',
      entityId: entityId,
      operation: SyncQueueOperation.uploadMedia,
      payload: payload,
      priority: priority,
      mutationId: mutationId,
    );
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
    await _repository.enqueue(job);
    return job;
  }
}
