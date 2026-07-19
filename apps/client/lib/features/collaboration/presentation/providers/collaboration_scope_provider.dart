import 'package:billing_baba/features/auth/providers/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/models/business_model.dart'
    as business;
import 'package:billing_baba/features/collaboration/application/sync_share_live_sync_service.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_relationship.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_session.dart';
import 'package:billing_baba/features/collaboration/domain/role_permission_registry.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/company_directory_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/company_session_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/members_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/permission_service_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/sync_share_refresh_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reloads collaboration data when the active company changes and keeps
/// session state aligned with directory / member updates.
final collaborationScopeProvider = Provider<void>((ref) {
  ref.listen(companySessionProvider, (previous, next) {
    if (previous?.companyId == next?.companyId) return;
    ref.read(syncShareRefreshProvider.notifier).refresh(
          manual: false,
          trigger: SyncShareRefreshTrigger.companyChange,
        );
  });

  ref.listen(companyDirectoryProvider, (previous, next) {
    next.whenData((entries) => _guardSharedCompanySession(ref, entries));
  });

  ref.listen(membersProvider, (previous, next) {
    next.whenData((members) {
      final session = ref.read(companySessionProvider);
      if (session == null || session.isOwner) return;

      final currentMember =
          members.where((member) => member.isCurrentUser).firstOrNull;
      if (currentMember == null) {
        _guardSharedCompanySession(ref, ref.read(companyDirectoryProvider).asData?.value ?? []);
        return;
      }

      if (currentMember.role != session.role) {
        ref.read(companySessionProvider.notifier).setSession(
          session.copyWith(
            role: currentMember.role,
            permissionPreset: RolePermissionRegistry.presetFor(
              currentMember.role,
            ),
          ),
        );
        ref.invalidate(permissionServiceProvider);
      }
    });
  });
});

void _guardSharedCompanySession(
  Ref ref,
  List<CompanyListEntry> entries,
) {
  final session = ref.read(companySessionProvider);
  if (session == null || session.isOwner) return;

  final stillAccessible = entries.any(
    (entry) =>
        entry.id == session.companyId &&
        entry.source == CompanyListSource.collaborationApi &&
        !entry.relationship.isPending &&
        !entry.relationship.isExpired,
  );

  if (stillAccessible) return;

  ref.read(companySessionProvider.notifier).clear();
  _seedOwnerSession(ref);
  ref.invalidate(permissionServiceProvider);
}

void _seedOwnerSession(Ref ref) {
  if (ref.read(companySessionProvider) != null) return;

  final auth = ref.read(authProvider);
  if (auth.status != AuthStatus.authenticated) return;
  if (!authHasBusinessScope(auth)) return;

  final profile = ref.read(businessProfileProvider).value;
  if (profile == null) return;

  final user = auth.session!.user;
  ref.read(companySessionProvider.notifier).setSession(
    CompanySession.owner(
      entry: CompanyListEntry(
        id: profile.id,
        name: profile.name,
        relationship: CompanyRelationship.owner,
        syncStatus: business.SyncStatus.on,
        source: CompanyListSource.apiOwned,
        gstin: profile.gstin,
        phone: profile.phone,
        email: profile.email,
        address: profile.address,
      ),
      userId: user.id,
      userName: user.name ?? 'User',
      userPhone: user.phone ?? '',
    ),
  );
}
