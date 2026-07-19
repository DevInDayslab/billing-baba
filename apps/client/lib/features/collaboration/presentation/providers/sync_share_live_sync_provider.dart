import 'dart:async';

import 'package:billing_baba/features/collaboration/domain/models/invitation.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/collaboration_scope_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/company_access_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/invitations_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/members_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _syncSharePollInterval = Duration(seconds: 15);

/// Polls collaboration data while the Sync & Share page is visible.
final syncShareLiveSyncProvider = Provider<void>((ref) {
  ref.watch(collaborationScopeProvider);

  final connectivity = Connectivity();
  Timer? timer;
  var disposed = false;

  Future<bool> isOnline() async {
    final result = await connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  bool hasPollableInvitations() {
    final invitations = ref.read(invitationsProvider);
    return invitations.maybeWhen(
      data: (items) => items.any((invitation) => invitation.status.isPollable),
      orElse: () => false,
    );
  }

  Future<void> silentRefresh() async {
    if (disposed) return;
    if (!await isOnline()) return;

    try {
      await ref.read(membersProvider.notifier).reload(showLoading: false);
      if (disposed) return;
      await ref.read(invitationsProvider.notifier).reload(showLoading: false);
      if (disposed) return;
      ref.invalidate(companyAccessProvider);
    } catch (_) {
      // Background refresh failures keep existing cached data.
    }
  }

  Future<void> scheduleNextPoll() async {
    if (disposed) return;
    timer?.cancel();
    timer = null;

    if (!await isOnline()) return;
    if (!hasPollableInvitations()) return;

    timer = Timer(_syncSharePollInterval, () async {
      await silentRefresh();
      await scheduleNextPoll();
    });
  }

  unawaited(silentRefresh().then((_) => scheduleNextPoll()));

  final subscription = connectivity.onConnectivityChanged.listen((result) async {
    if (disposed) return;
    if (result.contains(ConnectivityResult.none)) {
      timer?.cancel();
      timer = null;
      return;
    }
    await silentRefresh();
    await scheduleNextPoll();
  });

  ref.onDispose(() {
    disposed = true;
    timer?.cancel();
    unawaited(subscription.cancel());
  });
});
