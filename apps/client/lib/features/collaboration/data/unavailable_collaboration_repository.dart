import 'package:billing_baba/features/collaboration/application/collaboration_service_types.dart';
import 'package:billing_baba/features/collaboration/data/collaboration_repository.dart';
import 'package:billing_baba/features/collaboration/domain/models/business_member.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_access.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_session.dart';
import 'package:billing_baba/features/collaboration/domain/models/connected_device.dart';
import 'package:billing_baba/features/collaboration/domain/models/invitation.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_preset.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:billing_baba/features/collaboration/domain/models/sync_status.dart';
import 'package:billing_baba/features/collaboration/domain/role_permission_registry.dart';

/// Read-only placeholder used while the API client is still loading.
class UnavailableCollaborationRepository implements CollaborationRepository {
  UnavailableCollaborationRepository({
    required this._sessionContext,
    required String businessId,
    required this._businessName,
  });

  final CollaborationSessionContext _sessionContext;
  final String _businessName;

  static final _unavailable =
      StateError('Collaboration API is not ready yet');

  @override
  CollaborationSessionContext get sessionContext => _sessionContext;

  @override
  Future<void> initialize() async {}

  @override
  Future<List<BusinessMember>> fetchMembers() async => const [];

  @override
  Future<List<ConnectedDevice>> fetchDevices() async => const [];

  @override
  Future<List<Invitation>> fetchInvitations() async => const [];

  @override
  Future<CompanyAccess> fetchCompany() async {
    return CompanyAccess(
      businessName: _businessName,
      ownerName: 'Business Owner',
      ownerPhone: _sessionContext.ownerPhone,
      totalMembers: 1,
      loggedInPhone: _sessionContext.currentUserPhone,
    );
  }

  @override
  Future<SyncStatus> fetchSyncStatus() async {
    return const SyncStatus(
      state: CollaborationSyncState.offline,
      isConnected: false,
      isEnabled: false,
    );
  }

  @override
  Future<Invitation> inviteMember(InviteMemberInput input) => throw _unavailable;

  @override
  Future<BusinessMember> updateMember(String id, UpdateMemberInput input) =>
      throw _unavailable;

  @override
  Future<void> removeMember(String id) => throw _unavailable;

  @override
  Future<BusinessMember> changeRole(String id, Role role) => throw _unavailable;

  @override
  Future<void> enableSync() => throw _unavailable;

  @override
  Future<void> disableSync() => throw _unavailable;

  @override
  Future<void> logoutSync() => throw _unavailable;

  @override
  Future<SyncStatus> refresh() => fetchSyncStatus();

  @override
  Future<Invitation> acceptInvitation(String invitationId) => throw _unavailable;

  @override
  Future<Invitation> rejectInvitation(String invitationId) => throw _unavailable;

  @override
  Future<Invitation> cancelInvitation(String invitationId) => throw _unavailable;

  @override
  Future<Invitation> reinviteInvitation(String invitationId) => throw _unavailable;

  @override
  PermissionPreset getPermissionPreset(Role role) =>
      RolePermissionRegistry.presetFor(role);

  @override
  PermissionPreset loadPermissions(Role role) =>
      RolePermissionRegistry.presetFor(role);

  @override
  Future<List<CompanyListEntry>> loadCompanies() async => const [];

  @override
  Future<CompanySession?> loadCurrentCompany({
    required String userId,
    required String userName,
  }) async =>
      null;

  @override
  Future<CompanySession> switchCompany({
    required String companyId,
    required String userId,
    required String userName,
  }) =>
      throw _unavailable;

  @override
  Future<void> leaveCompany(String companyId) => throw _unavailable;

  @override
  Future<CompanyListEntry> acceptCompanyInvitation(String invitationId) =>
      throw _unavailable;

  @override
  Future<void> rejectCompanyInvitation(String invitationId) => throw _unavailable;
}
