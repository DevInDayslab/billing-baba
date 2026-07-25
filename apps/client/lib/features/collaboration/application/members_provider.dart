import 'package:billing_baba/core/providers/business_scope_invalidation.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_repository_provider.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_service_types.dart';
import 'package:billing_baba/features/collaboration/domain/models/business_member.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:billing_baba/features/collaboration/domain/role_permission_registry.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_init_provider.dart';
import 'package:billing_baba/features/collaboration/application/company_session_provider.dart';
import 'package:billing_baba/features/collaboration/application/permission_service_provider.dart';
import 'package:billing_baba/features/collaboration/application/sync_share_refresh_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'members_provider.g.dart';

@Riverpod(keepAlive: true)
class Members extends _$Members {
  @override
  Future<List<BusinessMember>> build() async {
    ref.watch(collaborationInitProvider);
    final service = ref.watch(collaborationServiceProvider);
    return service.fetchMembers();
  }

  Future<void> reload({bool showLoading = true}) async {
    if (showLoading) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() async {
      final service = ref.read(collaborationServiceProvider);
      return service.fetchMembers();
    });
    _syncCurrentUserRoleFromMembers(state.asData?.value ?? []);
  }

  Future<BusinessMember> updateMember(
    String id,
    UpdateMemberInput input,
  ) async {
    final service = ref.read(collaborationServiceProvider);
    final member = await service.updateMember(id, input);
    await ref.read(syncShareRefreshProvider.notifier).refreshAfterMutation();
    return member;
  }

  Future<BusinessMember> changeRole(String id, Role role) async {
    final service = ref.read(collaborationServiceProvider);
    final member = await service.changeRole(id, role);
    await ref.read(syncShareRefreshProvider.notifier).refreshAfterMutation();
    return member;
  }

  Future<void> removeMember(String id) async {
    final members = state.asData?.value ?? [];
    final removed = members.where((member) => member.id == id).firstOrNull;

    final service = ref.read(collaborationServiceProvider);
    await service.removeMember(id);
    await ref.read(syncShareRefreshProvider.notifier).refreshAfterMutation();

    if (removed?.isCurrentUser ?? false) {
      await _handleCurrentUserRemoved();
    }
  }

  void _syncCurrentUserRoleFromMembers(List<BusinessMember> members) {
    final session = ref.read(companySessionProvider);
    if (session == null || session.isOwner) return;

    final currentMember =
        members.where((member) => member.isCurrentUser).firstOrNull;
    if (currentMember == null || currentMember.role == session.role) return;

    ref.read(companySessionProvider.notifier).setSession(
      session.copyWith(
        role: currentMember.role,
        permissionPreset: RolePermissionRegistry.presetFor(currentMember.role),
      ),
    );
    ref.invalidate(permissionServiceProvider);
  }

  Future<void> _handleCurrentUserRemoved() async {
    ref.read(companySessionProvider.notifier).clear();
    invalidateAllBusinessScopedProviders(ref, includeBusinessList: true);
    ref.invalidate(permissionServiceProvider);
    await ref.read(syncShareRefreshProvider.notifier).refreshAfterMutation();
  }
}
