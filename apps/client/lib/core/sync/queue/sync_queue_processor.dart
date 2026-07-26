import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/models/sync_result.dart';
import 'package:billing_baba/core/sync/queue/sync_queue_service.dart';

/// Processes queue jobs. Placeholder — does not execute sync.
class SyncQueueProcessor {
  SyncQueueProcessor(this._queue);

  final SyncQueueService _queue;

  /// Peeks the queue and returns a no-op result without mutating persistence.
  Future<SyncResult> processNext() async {
    final pending = await _safeCount();
    LoggingService.instance.info(
      'SyncQueueProcessor: processNext skipped (pending=$pending)',
    );
    return SyncResult.noop(
      message: 'Queue processor idle — no push/pull yet',
    );
  }

  Future<int> _safeCount() async {
    try {
      return await _queue.count();
    } on Object {
      return 0;
    }
  }

  Future<SyncJob?> peek() async {
    try {
      return await _queue.peek();
    } on Object {
      return null;
    }
  }
}
