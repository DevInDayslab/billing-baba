import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/models/sync_queue_enums.dart';
import 'package:drift/drift.dart';

/// Drift accessors for the shared `sync_queue` table.
///
/// No Dio / SyncApi — persistence only.
class SyncQueueDao {
  SyncQueueDao(this._db);

  final AppDatabase _db;

  Future<void> insert(SyncQueueCompanion row) {
    return _db.into(_db.syncQueue).insert(row);
  }

  Future<bool> updateFields(String id, SyncQueueCompanion companion) async {
    final count = await (_db.update(_db.syncQueue)
          ..where((t) => t.id.equals(id)))
        .write(companion);
    return count > 0;
  }

  Future<bool> deleteById(String id) async {
    final count = await (_db.delete(_db.syncQueue)
          ..where((t) => t.id.equals(id)))
        .go();
    return count > 0;
  }

  Future<SyncQueueData?> getById(String id) {
    return (_db.select(_db.syncQueue)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Next runnable pending job: priority ASC, then createdAt ASC.
  Future<SyncQueueData?> nextPending({DateTime? now}) {
    final at = now ?? DateTime.now().toUtc();
    return (_db.select(_db.syncQueue)
          ..where(
            (t) =>
                t.status.equals(SyncQueueStatus.pending.wire) &
                (t.nextRetryAt.isNull() |
                    t.nextRetryAt.isSmallerOrEqualValue(at)),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.priority),
            (t) => OrderingTerm.asc(t.createdAt),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<SyncQueueData?> peek({DateTime? now}) => nextPending(now: now);

  Future<int> pendingCount({DateTime? now}) async {
    final at = now ?? DateTime.now().toUtc();
    final rows = await (_db.select(_db.syncQueue)
          ..where(
            (t) =>
                t.status.equals(SyncQueueStatus.pending.wire) &
                (t.nextRetryAt.isNull() |
                    t.nextRetryAt.isSmallerOrEqualValue(at)),
          ))
        .get();
    return rows.length;
  }

  Stream<int> streamPendingCount({DateTime? Function()? clock}) {
    return (_db.select(_db.syncQueue)
          ..where((t) => t.status.equals(SyncQueueStatus.pending.wire)))
        .watch()
        .map((rows) {
      final at = clock?.call() ?? DateTime.now().toUtc();
      return rows.where((r) {
        final next = r.nextRetryAt;
        return next == null || !next.isAfter(at);
      }).length;
    });
  }

  Future<List<SyncQueueData>> listPending({DateTime? now}) {
    final at = now ?? DateTime.now().toUtc();
    return (_db.select(_db.syncQueue)
          ..where(
            (t) =>
                t.status.equals(SyncQueueStatus.pending.wire) &
                (t.nextRetryAt.isNull() |
                    t.nextRetryAt.isSmallerOrEqualValue(at)),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.priority),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .get();
  }

  Stream<List<SyncQueueData>> watchPending({DateTime? Function()? clock}) {
    return (_db.select(_db.syncQueue)
          ..where((t) => t.status.equals(SyncQueueStatus.pending.wire))
          ..orderBy([
            (t) => OrderingTerm.asc(t.priority),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .watch()
        .map((rows) {
      final at = clock?.call() ?? DateTime.now().toUtc();
      return rows.where((r) {
        final next = r.nextRetryAt;
        return next == null || !next.isAfter(at);
      }).toList();
    });
  }

  Future<void> markRunning(String id) async {
    final row = await getById(id);
    if (row == null) return;
    await updateFields(
      id,
      SyncQueueCompanion(
        status: Value(SyncQueueStatus.running.wire),
        lastAttemptAt: Value(DateTime.now().toUtc()),
        attemptCount: Value(row.attemptCount + 1),
      ),
    );
  }

  Future<void> markCompleted(String id) {
    return updateFields(
      id,
      const SyncQueueCompanion(
        status: Value('completed'),
        lastError: Value(null),
        nextRetryAt: Value(null),
      ),
    );
  }

  Future<void> markFailed(
    String id, {
    String? reason,
    DateTime? nextRetryAt,
  }) {
    return updateFields(
      id,
      SyncQueueCompanion(
        status: Value(SyncQueueStatus.failed.wire),
        lastError: Value(reason),
        lastAttemptAt: Value(DateTime.now().toUtc()),
        nextRetryAt: Value(nextRetryAt),
      ),
    );
  }

  Future<void> markConflict(String id, {String? reason}) {
    return updateFields(
      id,
      SyncQueueCompanion(
        status: Value(SyncQueueStatus.conflict.wire),
        lastError: Value(reason),
        lastAttemptAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> retry(String id) {
    return updateFields(
      id,
      const SyncQueueCompanion(
        status: Value('pending'),
        lastError: Value(null),
        nextRetryAt: Value(null),
      ),
    );
  }

  Future<void> cancel(String id) {
    return updateFields(
      id,
      const SyncQueueCompanion(
        status: Value('cancelled'),
      ),
    );
  }

  Future<int> clearCompleted() {
    return (_db.delete(_db.syncQueue)
          ..where(
            (t) =>
                t.status.equals(SyncQueueStatus.completed.wire) |
                t.status.equals(SyncQueueStatus.cancelled.wire),
          ))
        .go();
  }

  Future<int> clearAll() => _db.delete(_db.syncQueue).go();
}
