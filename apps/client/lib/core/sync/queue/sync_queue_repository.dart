import 'package:billing_baba/core/sync/models/sync_job.dart';

/// Persistence port for the offline sync queue.
abstract class SyncQueueRepository {
  Future<void> enqueue(SyncJob job);

  /// Marks the next pending job running and returns it.
  Future<SyncJob?> dequeue();

  Future<SyncJob?> peek();

  Future<SyncJob?> nextPending();

  Future<void> markRunning(String jobId);

  Future<void> retry(String jobId);

  Future<void> markCompleted(String jobId);

  Future<void> markFailed(String jobId, {String? reason});

  Future<void> markConflict(String jobId, {String? reason});

  Future<void> cancel(String jobId);

  Future<void> clearCompleted();

  Future<void> clear();

  Future<int> count();

  Future<int> pendingCount();

  Stream<int> streamPendingCount();

  Future<List<SyncJob>> listPending();

  Stream<List<SyncJob>> watchPending();
}
