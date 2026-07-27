import 'package:billing_baba/core/sync/engine/sync_engine.dart';
import 'package:billing_baba/core/sync/engine/sync_scheduler.dart';
import 'package:billing_baba/core/sync/models/sync_result.dart';
import 'package:billing_baba/core/sync/models/sync_state.dart';
import 'package:billing_baba/features/command_sync/application/command_sync_runner.dart';

/// Composes row sync ([SyncEngine]) with command push without modifying core sync.
class CommandAwareSyncEngine {
  CommandAwareSyncEngine({
    required this._engine,
    required this._commandRunner,
  });

  final SyncEngine _engine;
  final CommandSyncRunner _commandRunner;

  SyncEngine get engine => _engine;
  SyncState get state => _engine.state;
  Stream<SyncState> get stateChanges => _engine.stateChanges;
  bool get isRunning => _engine.isRunning;
  bool get isInitialized => _engine.isInitialized;

  Future<void> initialize() => _engine.initialize();
  Future<void> start({bool enableAutoSync = true}) =>
      _engine.start(enableAutoSync: enableAutoSync);
  Future<void> stop() => _engine.stop();
  void schedule([
    SyncScheduleTrigger trigger = SyncScheduleTrigger.manualRefresh,
  ]) =>
      _engine.schedule(trigger);
  Future<void> dispose() => _engine.dispose();

  Future<SyncResult> syncNow() async {
    final rowResult = await _engine.syncNow();
    final commandResult = await _commandRunner.runPending();
    if (commandResult.message?.contains('No pending command jobs') ?? false) {
      return rowResult;
    }
    return SyncResult(
      success: rowResult.success && commandResult.success,
      completedAt: DateTime.now().toUtc(),
      message:
          '${rowResult.message ?? 'Row sync'}; ${commandResult.message ?? 'Command sync'}',
      acceptedCount: rowResult.acceptedCount + commandResult.acceptedCount,
      conflictCount: rowResult.conflictCount + commandResult.conflictCount,
      errorCount: rowResult.errorCount + commandResult.errorCount,
    );
  }
}
