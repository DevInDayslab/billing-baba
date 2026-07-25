import 'package:billing_baba/features/collaboration/application/collaboration_init_provider.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_repository_provider.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_service_types.dart';
import 'package:billing_baba/features/collaboration/application/sync_share_refresh_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/invitation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'invitations_provider.g.dart';

@Riverpod(keepAlive: true)
class Invitations extends _$Invitations {
  @override
  Future<List<Invitation>> build() async {
    ref.watch(collaborationInitProvider);
    final service = ref.watch(collaborationServiceProvider);
    return service.fetchInvitations();
  }

  Future<void> reload({bool showLoading = true}) async {
    if (showLoading) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() async {
      final service = ref.read(collaborationServiceProvider);
      return service.fetchInvitations();
    });
  }

  Future<Invitation> cancel(String invitationId) async {
    final service = ref.read(collaborationServiceProvider);
    final invitation = await service.cancelInvitation(invitationId);
    await ref.read(syncShareRefreshProvider.notifier).refreshAfterMutation();
    return invitation;
  }

  Future<Invitation> accept(String invitationId) async {
    final service = ref.read(collaborationServiceProvider);
    final invitation = await service.acceptInvitation(invitationId);
    await ref.read(syncShareRefreshProvider.notifier).refreshAfterMutation();
    return invitation;
  }

  Future<Invitation> reject(String invitationId) async {
    final service = ref.read(collaborationServiceProvider);
    final invitation = await service.rejectInvitation(invitationId);
    await ref.read(syncShareRefreshProvider.notifier).refreshAfterMutation();
    return invitation;
  }

  Future<Invitation> reinvite(String invitationId) async {
    final service = ref.read(collaborationServiceProvider);
    final invitation = await service.reinviteInvitation(invitationId);
    await ref.read(syncShareRefreshProvider.notifier).refreshAfterMutation();
    return invitation;
  }
}

class LastInvitationResult {
  const LastInvitationResult({
    required this.invitation,
    required this.memberName,
  });

  final Invitation invitation;
  final String memberName;
}

@Riverpod(keepAlive: true)
class LastInvitation extends _$LastInvitation {
  @override
  LastInvitationResult? build() => null;

  void set(LastInvitationResult result) => state = result;

  void clear() => state = null;

  Future<LastInvitationResult> invite(InviteMemberInput input) async {
    final service = ref.read(collaborationServiceProvider);
    final invitation = await service.inviteMember(input);
    final result = LastInvitationResult(
      invitation: invitation,
      memberName: input.fullName,
    );
    state = result;
    await ref.read(syncShareRefreshProvider.notifier).refreshAfterMutation();
    return result;
  }
}
