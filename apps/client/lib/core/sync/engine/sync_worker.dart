import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/core/sync/models/sync_result.dart';
import 'package:billing_baba/core/sync/network/sync_client.dart';
import 'package:billing_baba/core/sync/queue/sync_queue_processor.dart';

/// Executes a single sync pass. Placeholder — does not call the network yet.
class SyncWorker {
  SyncWorker({
    required this._client,
    required this._queueProcessor,
  });

  // Reserved for future push/pull/bootstrap orchestration.
  // ignore: unused_field
  final SyncClient _client;
  final SyncQueueProcessor _queueProcessor;

  Future<SyncResult> runFullSync() async {
    LoggingService.instance.info(
      'SyncWorker.runFullSync: noop (sync not implemented)',
    );
    await _queueProcessor.processNext();
    return SyncResult.noop();
  }
}
