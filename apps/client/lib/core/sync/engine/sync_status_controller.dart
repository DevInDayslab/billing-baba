import 'package:billing_baba/core/sync/engine/sync_engine.dart';
import 'package:billing_baba/core/sync/engine/sync_plan.dart';
import 'package:billing_baba/core/sync/engine/sync_scheduler.dart';
import 'package:billing_baba/core/sync/engine/sync_session.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/models/sync_state.dart';
import 'package:billing_baba/core/sync/queue/sync_queue_service.dart';

/// Non-UI controller exposing sync runtime status for shells / status indicators.
class SyncStatusController {
  SyncStatusController({
    required this._engine,
    required SyncQueueService queueService,
    required this._scheduler,
  }) : _queue = queueService;

  final SyncEngine _engine;
  final SyncQueueService _queue;
  final SyncScheduler _scheduler;

  SyncState get currentState => _engine.state;

  Stream<SyncState> get stateChanges => _engine.stateChanges;

  SyncSession? get currentSession => _engine.currentSession;

  SyncPlan? get currentPlan => _engine.currentPlan;

  DateTime? get lastSyncTime => _engine.state.lastSyncTime;

  DateTime? get nextScheduledSync =>
      _engine.state.nextScheduledSync ?? _scheduler.nextScheduledSync;

  String? get runningJob => _engine.state.runningJobId;

  String? get error => _engine.state.errorMessage;

  Future<int> get pendingJobs async {
    try {
      return await _queue.count();
    } on Object {
      return _engine.state.pendingJobs;
    }
  }

  Future<SyncJob?> peekRunningOrNext() async {
    try {
      return await _queue.peek();
    } on Object {
      return null;
    }
  }

  Future<void> requestSync() => _engine.syncNow();

  void requestSchedule() => _engine.schedule();
}
