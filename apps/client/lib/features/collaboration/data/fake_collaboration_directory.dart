import 'package:billing_baba/features/business/models/business_model.dart'
    as business;
import 'package:billing_baba/features/collaboration/application/collaboration_service_types.dart';
import 'package:billing_baba/features/collaboration/data/fake_collaboration_repository.dart' show FakeCollaborationRepository;
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_relationship.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_session.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:billing_baba/features/collaboration/domain/role_permission_registry.dart';

/// In-memory invitee-centric company directory for fake collaboration.
///
/// Persists across [FakeCollaborationRepository] instances so accept/reject
/// survives provider rebuilds.
class FakeCollaborationDirectory {
  FakeCollaborationDirectory._();

  static const sharmaTradersId = 'fake-sharma-traders';
  static const guptaStoreId = 'fake-gupta-store';
  static const expiredMartId = 'fake-expired-mart';

  static const sharmaInviteId = 'invite-shared-sharma';
  static const expiredInviteId = 'invite-shared-expired';

  static String? _currentCompanyId;
  static bool _seeded = false;

  static final List<_FakeCompanyRecord> _records = [];

  static void ensureSeeded(String currentUserPhone) {
    if (_seeded) return;
    _seeded = true;

    final normalizedPhone = normalizeContact(currentUserPhone);

    _records.addAll([
      _FakeCompanyRecord(
        id: sharmaTradersId,
        name: 'Sharma Traders',
        ownerName: 'Ramesh Sharma',
        ownerPhone: '+91 9876500001',
        relationship: CompanyRelationship.pendingInvite,
        role: Role.biller,
        invitationId: sharmaInviteId,
        invitationStatus: InvitationCardStatus.pending,
        syncStatus: business.SyncStatus.on,
        inviteePhone: normalizedPhone,
      ),
      _FakeCompanyRecord(
        id: guptaStoreId,
        name: 'Gupta General Store',
        ownerName: 'Suresh Gupta',
        ownerPhone: '+91 9876500002',
        relationship: CompanyRelationship.member,
        role: Role.salesman,
        syncStatus: business.SyncStatus.on,
        inviteePhone: normalizedPhone,
      ),
      _FakeCompanyRecord(
        id: expiredMartId,
        name: 'City Mart',
        ownerName: 'Anita Verma',
        ownerPhone: '+91 9876500003',
        relationship: CompanyRelationship.expiredInvite,
        role: Role.biller,
        invitationId: expiredInviteId,
        invitationStatus: InvitationCardStatus.expired,
        syncStatus: business.SyncStatus.off,
        inviteePhone: normalizedPhone,
      ),
    ]);
  }

  static void resetForTests() {
    _seeded = false;
    _currentCompanyId = null;
    _records.clear();
  }

  static List<CompanyListEntry> loadCompanies(String currentUserPhone) {
    ensureSeeded(currentUserPhone);
    final normalized = normalizeContact(currentUserPhone);
    return _records
        .where((r) => r.inviteePhone == normalized)
        .where((r) => r.invitationStatus?.isVisibleOnList ?? true)
        .map((r) => r.toEntry(isCurrent: r.id == _currentCompanyId))
        .toList();
  }

  static CompanySession? loadCurrentSession({
    required String currentUserPhone,
    required String userId,
    required String userName,
  }) {
    if (_currentCompanyId == null) return null;
    final record = _findRecord(_currentCompanyId!);
    if (record == null) return null;
    return _sessionFromRecord(
      record,
      userId: userId,
      userName: userName,
      userPhone: currentUserPhone,
    );
  }

  static CompanySession switchCompany({
    required String companyId,
    required String currentUserPhone,
    required String userId,
    required String userName,
  }) {
    ensureSeeded(currentUserPhone);
    final record = _findRecord(companyId);
    if (record == null) {
      throw const CollaborationNotFoundException('Company not found');
    }
    if (!record.relationship.canOpen) {
      throw const CollaborationForbiddenException(
        'Accept the invitation before opening this company',
      );
    }
    _currentCompanyId = companyId;
    return _sessionFromRecord(
      record,
      userId: userId,
      userName: userName,
      userPhone: currentUserPhone,
    );
  }

  static void leaveCompany(String companyId, String currentUserPhone) {
    ensureSeeded(currentUserPhone);
    final index = _records.indexWhere((r) => r.id == companyId);
    if (index == -1) return;

    final record = _records[index];
    if (record.relationship.isPending || record.relationship.isExpired) {
      return;
    }

    _records.removeAt(index);
    if (_currentCompanyId == companyId) {
      _currentCompanyId = null;
    }
  }

  static CompanyListEntry acceptInvitation({
    required String invitationId,
    required String currentUserPhone,
  }) {
    ensureSeeded(currentUserPhone);
    final index = _records.indexWhere((r) => r.invitationId == invitationId);
    if (index == -1) {
      throw const CollaborationNotFoundException('Invitation not found');
    }

    final record = _records[index];
    if (record.relationship.isExpired) {
      throw const CollaborationConflictException('Invitation has expired');
    }
    if (!record.relationship.isPending) {
      throw const CollaborationConflictException(
        'Invitation is no longer pending',
      );
    }

    final updated = record.copyWith(
      relationship: CompanyRelationship.member,
      invitationStatus: InvitationCardStatus.accepted,
    );
    _records[index] = updated;
    return updated.toEntry(isCurrent: updated.id == _currentCompanyId);
  }

  static void rejectInvitation({
    required String invitationId,
    required String currentUserPhone,
  }) {
    ensureSeeded(currentUserPhone);
    final index = _records.indexWhere((r) => r.invitationId == invitationId);
    if (index == -1) {
      throw const CollaborationNotFoundException('Invitation not found');
    }

    final record = _records[index];
    if (!record.relationship.isPending) {
      throw const CollaborationConflictException(
        'Invitation is no longer pending',
      );
    }

    _records.removeAt(index);
    if (_currentCompanyId == record.id) {
      _currentCompanyId = null;
    }
  }

  static void clearCurrentCompany() {
    _currentCompanyId = null;
  }

  static _FakeCompanyRecord? _findRecord(String id) {
    final index = _records.indexWhere((r) => r.id == id);
    if (index == -1) return null;
    return _records[index];
  }

  static CompanySession _sessionFromRecord(
    _FakeCompanyRecord record, {
    required String userId,
    required String userName,
    required String userPhone,
  }) {
    final entry = record.toEntry(isCurrent: true);
    final preset = record.role != null
        ? RolePermissionRegistry.presetFor(record.role!)
        : RolePermissionRegistry.presetFor(Role.biller);

    if (record.relationship.isOwner) {
      return CompanySession.owner(
        entry: entry,
        userId: userId,
        userName: userName,
        userPhone: userPhone,
      );
    }

    return CompanySession.shared(
      entry: entry,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      preset: preset,
    );
  }
}

class _FakeCompanyRecord {
  const _FakeCompanyRecord({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.ownerPhone,
    required this.relationship,
    required this.syncStatus,
    required this.inviteePhone,
    this.role,
    this.invitationId,
    this.invitationStatus,
  });

  final String id;
  final String name;
  final String ownerName;
  final String ownerPhone;
  final CompanyRelationship relationship;
  final Role? role;
  final String? invitationId;
  final InvitationCardStatus? invitationStatus;
  final business.SyncStatus syncStatus;
  final String inviteePhone;

  _FakeCompanyRecord copyWith({
    CompanyRelationship? relationship,
    InvitationCardStatus? invitationStatus,
  }) {
    return _FakeCompanyRecord(
      id: id,
      name: name,
      ownerName: ownerName,
      ownerPhone: ownerPhone,
      relationship: relationship ?? this.relationship,
      role: role,
      invitationId: invitationId,
      invitationStatus: invitationStatus ?? this.invitationStatus,
      syncStatus: syncStatus,
      inviteePhone: inviteePhone,
    );
  }

  CompanyListEntry toEntry({required bool isCurrent}) {
    return CompanyListEntry(
      id: id,
      name: name,
      ownerName: ownerName,
      ownerPhone: ownerPhone,
      relationship: relationship,
      role: role,
      invitationId: invitationId,
      invitationStatus: invitationStatus,
      syncStatus: syncStatus,
      source: CompanyListSource.collaborationFake,
      isCurrent: isCurrent,
    );
  }
}
