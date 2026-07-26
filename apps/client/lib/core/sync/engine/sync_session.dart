import 'package:billing_baba/core/sync/engine/sync_orchestration_phase.dart';
import 'package:billing_baba/core/sync/engine/sync_plan.dart';
import 'package:billing_baba/core/sync/models/sync_result.dart';

/// One synchronization run with push/pull metrics.
class SyncSession {
  SyncSession({
    required this.sessionId,
    required this.startedAt,
    this.terminalPhase = SyncOrchestrationPhase.idle,
  });

  final String sessionId;
  final DateTime startedAt;
  DateTime? finishedAt;

  int rowsUploaded = 0;
  int rowsDownloaded = 0;
  int commandsUploaded = 0;
  int mediaUploaded = 0;
  int failures = 0;
  int conflicts = 0;

  SyncOrchestrationPhase terminalPhase;
  SyncResult? result;
  SyncPlan? plan;

  Duration? get duration {
    final end = finishedAt;
    if (end == null) return null;
    return end.difference(startedAt);
  }

  bool get isFinished => finishedAt != null;

  void finish({
    required SyncOrchestrationPhase phase,
    required SyncResult result,
    SyncPlan? plan,
  }) {
    finishedAt = DateTime.now().toUtc();
    terminalPhase = phase;
    this.result = result;
    if (plan != null) this.plan = plan;
  }
}
