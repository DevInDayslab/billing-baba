/// Ordered steps the coordinator may include in a [SyncPlan].
enum SyncPlanStep {
  registerDevice,
  fetchStatus,
  bootstrap,
  pushQueue,
  pullChanges,
  media,
  complete,
}

/// Immutable plan generated before push/pull execution.
class SyncPlan {
  const SyncPlan({
    required this.planId,
    required this.createdAt,
    required this.steps,
    required this.needsBootstrap,
    required this.willPush,
    required this.willPull,
    required this.willUploadMedia,
    this.pendingRowCount = 0,
    this.pendingCommandCount = 0,
    this.pendingMediaCount = 0,
    this.reason,
  });

  final String planId;
  final DateTime createdAt;
  final List<SyncPlanStep> steps;
  final bool needsBootstrap;
  final bool willPush;
  final bool willPull;
  final bool willUploadMedia;
  final int pendingRowCount;
  final int pendingCommandCount;
  final int pendingMediaCount;
  final String? reason;

  SyncPlan copyWith({
    List<SyncPlanStep>? steps,
    bool? needsBootstrap,
    bool? willPush,
    bool? willPull,
    bool? willUploadMedia,
    int? pendingRowCount,
    int? pendingCommandCount,
    int? pendingMediaCount,
    String? reason,
  }) {
    return SyncPlan(
      planId: planId,
      createdAt: createdAt,
      steps: steps ?? this.steps,
      needsBootstrap: needsBootstrap ?? this.needsBootstrap,
      willPush: willPush ?? this.willPush,
      willPull: willPull ?? this.willPull,
      willUploadMedia: willUploadMedia ?? this.willUploadMedia,
      pendingRowCount: pendingRowCount ?? this.pendingRowCount,
      pendingCommandCount: pendingCommandCount ?? this.pendingCommandCount,
      pendingMediaCount: pendingMediaCount ?? this.pendingMediaCount,
      reason: reason ?? this.reason,
    );
  }
}
