import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/core/sync/engine/sync_worker.dart';
import 'package:billing_baba/core/sync/models/sync_result.dart';

/// Coordinates a sync run request into [SyncWorker].
///
/// Currently a pass-through that never performs network sync.
class SyncRunner {
  SyncRunner(this._worker);

  final SyncWorker _worker;
  bool _busy = false;

  bool get isBusy => _busy;

  Future<SyncResult> run({bool force = false}) async {
    if (_busy && !force) {
      LoggingService.instance.info('SyncRunner: already busy — skipped');
      return SyncResult.noop(message: 'Sync already in progress');
    }
    _busy = true;
    try {
      return await _worker.runFullSync();
    } finally {
      _busy = false;
    }
  }
}
