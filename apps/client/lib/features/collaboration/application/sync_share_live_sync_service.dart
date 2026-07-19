import 'package:billing_baba/features/collaboration/application/collaboration_repository_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/invitation.dart';
import 'package:billing_baba/features/collaboration/domain/models/member_status.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/company_access_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/company_directory_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/invitations_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/members_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/permission_service_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/sync_status_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Why a refresh was requested. Useful for logging and future backends.
enum SyncShareRefreshTrigger {
  manual,
  pageOpen,
  windowFocus,
  appResume,
  companyChange,
  mutation,
  poll,
  connectivityRestored,
}

/// Pluggable backend for Sync & Share live updates.
///
/// Today this is implemented with polling. A WebSocket or SSE backend can
/// implement the same interface later without UI changes.
abstract class SyncShareLiveSyncBackend {
  Future<void> fetchUpdates(
    Ref ref, {
    required bool manual,
  });

  bool shouldPoll(Ref ref);

  Future<bool> isOnline();
}

/// Default ERP-style polling backend (Vyapar / Zoho Books pattern).
class PollingSyncShareLiveSyncBackend implements SyncShareLiveSyncBackend {
  PollingSyncShareLiveSyncBackend();

  final Connectivity _connectivity = Connectivity();

  @override
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  bool shouldPoll(Ref ref) {
    final invitations = ref.read(invitationsProvider);
    final hasPollableInvitations = invitations.maybeWhen(
      data: (items) => items.any((invitation) => invitation.status.isPollable),
      orElse: () => false,
    );
    if (hasPollableInvitations) return true;

    final members = ref.read(membersProvider);
    return members.maybeWhen(
      data: (items) => items.any(
        (member) => !member.isOwner && member.status == MemberStatus.pending,
      ),
      orElse: () => false,
    );
  }

  @override
  Future<void> fetchUpdates(
    Ref ref, {
    required bool manual,
  }) async {
    if (!await isOnline()) {
      if (manual) {
        throw const SyncShareRefreshOfflineException();
      }
      return;
    }

    final service = ref.read(collaborationServiceProvider);
    await service.refresh();

    await Future.wait([
      ref.read(membersProvider.notifier).reload(showLoading: false),
      ref.read(invitationsProvider.notifier).reload(showLoading: false),
      ref.read(syncStatusProvider.notifier).reload(showLoading: false),
      _reloadCompanyDirectory(ref),
    ]);

    ref.invalidate(companyAccessProvider);
    ref.invalidate(permissionServiceProvider);
  }

  Future<void> _reloadCompanyDirectory(Ref ref) async {
    ref.invalidate(companyDirectoryProvider);
    ref.invalidate(collaborationCompaniesProvider);
    await Future.wait([
      ref.read(companyDirectoryProvider.future),
      ref.read(collaborationCompaniesProvider.future),
    ]);
  }
}

class SyncShareRefreshOfflineException implements Exception {
  const SyncShareRefreshOfflineException();

  @override
  String toString() =>
      'You are offline. Showing cached data — try again when connected.';
}

final syncShareLiveSyncBackendProvider = Provider<SyncShareLiveSyncBackend>(
  (ref) => PollingSyncShareLiveSyncBackend(),
);
