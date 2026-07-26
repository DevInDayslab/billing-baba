import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/core/sync/engine/sync_engine.dart';
import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Initializes the offline sync runtime without starting entity synchronization.
///
/// Call once during app startup after [ProviderContainer] is ready.
/// Does not call [SyncEngine.start] or [SyncEngine.syncNow].
Future<SyncEngine> initializeSyncRuntime(ProviderContainer container) async {
  final engine = await container.read(syncEngineProvider.future);
  await engine.initialize();
  LoggingService.instance.info(
    'Offline sync runtime initialized (scheduler not started, auto sync off)',
  );
  return engine;
}
