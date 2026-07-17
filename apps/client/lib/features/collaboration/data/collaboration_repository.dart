import 'package:billing_baba/features/collaboration/application/collaboration_service_types.dart';
import 'package:billing_baba/features/collaboration/domain/models/business_member.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_access.dart';
import 'package:billing_baba/features/collaboration/domain/models/connected_device.dart';
import 'package:billing_baba/features/collaboration/domain/models/invitation.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_preset.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:billing_baba/features/collaboration/domain/models/sync_status.dart';

/// Backend-ready contract for collaboration / sync & share operations.
///
/// Maps to future endpoints under `/collaboration/*`.
abstract class CollaborationRepository {
  Future<void> initialize();

  Future<List<BusinessMember>> fetchMembers();

  Future<List<ConnectedDevice>> fetchDevices();

  Future<List<Invitation>> fetchInvitations();

  Future<CompanyAccess> fetchCompany();

  Future<SyncStatus> fetchSyncStatus();

  Future<Invitation> inviteMember(InviteMemberInput input);

  Future<BusinessMember> updateMember(String id, UpdateMemberInput input);

  Future<void> removeMember(String id);

  Future<BusinessMember> changeRole(String id, Role role);

  Future<void> enableSync();

  Future<void> disableSync();

  Future<void> logoutSync();

  Future<SyncStatus> refresh();

  Future<Invitation> acceptInvitation(String invitationId);

  Future<Invitation> rejectInvitation(String invitationId);

  Future<Invitation> cancelInvitation(String invitationId);

  PermissionPreset getPermissionPreset(Role role);

  CollaborationSessionContext get sessionContext;
}
