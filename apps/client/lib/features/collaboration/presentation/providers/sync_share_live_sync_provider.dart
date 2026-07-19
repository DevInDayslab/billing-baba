import 'dart:async';

import 'package:billing_baba/features/collaboration/application/sync_share_live_sync_service.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/collaboration_scope_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/invitations_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/members_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/sync_share_refresh_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _syncSharePollInterval = Duration(seconds: 15);

/// Polls collaboration data while the Sync & Share page is visible.
final syncShareLiveSyncProvider = Provider<void>((ref) {
  ref.watch(collaborationScopeProvider);

  final backend = ref.read(syncShareLiveSyncBackendProvider);
  final connectivity = Connectivity();
  Timer? timer;
  var disposed = false;

  Future<void> silentRefresh({
    SyncShareRefreshTrigger trigger = SyncShareRefreshTrigger.poll,
  }) async {
    if (disposed) return;
    await ref
        .read(syncShareRefreshProvider.notifier)
        .refresh(manual: false, trigger: trigger);
  }

  Future<void> scheduleNextPoll() async {
    if (disposed) return;
    timer?.cancel();
    timer = null;

    if (!await backend.isOnline()) return;
    if (!ref.read(syncShareRefreshProvider.notifier).shouldPoll) return;

    timer = Timer(_syncSharePollInterval, () async {
      await silentRefresh();
      await scheduleNextPoll();
    });
  }

  // Initial load when page opens.
  unawaited(
    silentRefresh(trigger: SyncShareRefreshTrigger.pageOpen)
        .then((_) => scheduleNextPoll()),
  );

  // Resume polling when invitations/members gain pending rows.
  ref.listen(invitationsProvider, (_, __) => unawaited(scheduleNextPoll()));
  ref.listen(membersProvider, (_, __) => unawaited(scheduleNextPoll()));

  final subscription = connectivity.onConnectivityChanged.listen((result) async {
    if (disposed) return;
    if (result.contains(ConnectivityResult.none)) {
      timer?.cancel();
      timer = null;
      return;
    }
    await silentRefresh(trigger: SyncShareRefreshTrigger.connectivityRestored);
    await scheduleNextPoll();
  });

  ref.onDispose(() {
    disposed = true;
    timer?.cancel();
    unawaited(subscription.cancel());
  });
});
