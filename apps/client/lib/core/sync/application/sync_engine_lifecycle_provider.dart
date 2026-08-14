import 'dart:async';

import 'package:billing_baba/core/sync/engine/sync_pause_gate.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/command_sync/application/command_sync_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Starts the sync engine when a business-scoped session is active.
///
/// Covers cold start (stored JWT), company open, and provider invalidation
/// after a company switch.
final syncEngineLifecycleProvider = Provider<void>((ref) {
  var startInFlight = false;

  Future<void> tryStart() async {
    if (!ref.mounted || startInFlight) return;

    final auth = ref.read(authProvider);
    if (auth.status != AuthStatus.authenticated) return;
    if (!authHasBusinessScope(auth)) return;
    if (SyncPauseGate.instance.isPaused) return;

    startInFlight = true;
    try {
      await ensureSyncEngineStarted(ref);
    } finally {
      startInFlight = false;
    }
  }

  ref.listen(authProvider, (_, _) => unawaited(tryStart()));
  ref.listen(commandAwareSyncEngineProvider, (_, _) => unawaited(tryStart()));

  unawaited(Future.microtask(tryStart));
});

/// Ensures the sync runtime is started for the active business session.
Future<void> ensureSyncEngineStarted(
  Ref ref, {
  bool runInitialSync = true,
}) async {
  final engine = await ref.read(commandAwareSyncEngineProvider.future);
  final wasRunning = engine.isRunning;
  if (!wasRunning) {
    await engine.start();
  }
  if (runInitialSync && !wasRunning) {
    unawaited(engine.syncNow());
  }
}
