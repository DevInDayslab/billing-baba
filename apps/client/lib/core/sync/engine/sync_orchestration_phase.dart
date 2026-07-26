/// Fine-grained orchestration phases owned by SyncCoordinator.
///
/// Coarse SyncLifecycleState still tracks idle/syncing/offline/failed.
enum SyncOrchestrationPhase {
  idle,
  checkingServer,
  registeringDevice,
  planning,
  ready,
  needsBootstrap,
  authenticationFailed,
  serverUnavailable,
  offline,
}
