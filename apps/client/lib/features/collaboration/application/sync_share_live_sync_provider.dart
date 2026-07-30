import 'dart:async';

import 'package:billing_baba/features/collaboration/application/collaboration_scope_provider.dart';
import 'package:billing_baba/features/collaboration/application/sync_share_live_sync_service.dart';
import 'package:billing_baba/features/collaboration/application/sync_share_refresh_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads collaboration data once when the Sync & Share page opens.
///
/// Further updates are manual (header refresh button) or on company change.
/// Timed polling was removed — it hammered the API and froze checkout UIs.
final syncShareLiveSyncProvider = Provider<void>((ref) {
  ref.watch(collaborationScopeProvider);

  var disposed = false;

  // Side effects must not run during provider build (Riverpod assertion).
  unawaited(
    Future.microtask(() async {
      if (disposed) return;
      await ref
          .read(syncShareRefreshProvider.notifier)
          .refresh(
            trigger: SyncShareRefreshTrigger.pageOpen,
          );
    }),
  );

  ref.onDispose(() {
    disposed = true;
  });
});
