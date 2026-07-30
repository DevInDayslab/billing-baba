import 'package:billing_baba/features/business/models/business_model.dart'
    as business;
import 'package:billing_baba/features/collaboration/application/collaboration_service_types.dart';
import 'package:billing_baba/features/collaboration/data/collaboration_api.dart';
import 'package:billing_baba/features/collaboration/data/collaboration_cache.dart';
import 'package:billing_baba/features/collaboration/data/collaboration_repository.dart';
import 'package:billing_baba/features/collaboration/domain/models/business_member.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_access.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_relationship.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_session.dart';
import 'package:billing_baba/features/collaboration/domain/models/connected_device.dart';
import 'package:billing_baba/features/collaboration/domain/models/invitation.dart';
import 'package:billing_baba/features/collaboration/domain/models/member_status.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_preset.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:billing_baba/features/collaboration/domain/models/sync_status.dart';
import 'package:billing_baba/features/collaboration/domain/role_permission_registry.dart';
import 'package:dio/dio.dart';

class BackendCollaborationRepository implements CollaborationRepository {
  BackendCollaborationRepository({
    required this._api,
    required this._companyId,
    required this._companyName,
    required this._sessionContext,
    CollaborationCache? cache,
  }) : _cache = cache ?? CollaborationCache();

  final CollaborationApi _api;
  final String _companyId;
  final String _companyName;
  final CollaborationSessionContext _sessionContext;
  final CollaborationCache _cache;

  SyncStatus _syncStatus = const SyncStatus();
  bool _initialized = false;
  bool _loggedOut = false;

  CollaborationCompanyCache get _companyCache => _cache.company(_companyId);

  @override
  CollaborationSessionContext get sessionContext => _sessionContext;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _syncStatus = _buildInitialSyncStatus();
    _initialized = true;
  }

  @override
  Future<List<BusinessMember>> fetchMembers() async {
    try {
      final members = await _api.listMembers();
      _companyCache.replaceMembers(members);
      _markOnlineIfEnabled();
      return List<BusinessMember>.from(members);
    } on DioException {
      _markOfflineIfEnabled();
      if (_companyCache.members.isNotEmpty) {
        return List<BusinessMember>.from(_companyCache.members);
      }
      final invitations = await fetchInvitations();
      final members = _membersFromInvitations(invitations);
      _companyCache.replaceMembers(members);
      return members;
    }
  }

  @override
  Future<List<Invitation>> fetchInvitations() async {
    try {
      final invitations = await _api.listInvitations();
      _companyCache.replaceInvitations(invitations);
      _markOnlineIfEnabled();
      return List<Invitation>.from(invitations);
    } on DioException {
      _markOfflineIfEnabled();
      return List<Invitation>.from(_companyCache.invitations);
    }
  }

  @override
  Future<List<ConnectedDevice>> fetchDevices() async {
    if (_loggedOut || _syncStatus.isDisabled || !_syncStatus.isConnected) {
      return [];
    }
    return [
      ConnectedDevice(
        id: 'current-device',
        name: _sessionContext.currentDeviceName,
        platform: DevicePlatform.desktop,
        osName: 'Desktop',
        appVersion: '1.0.0',
        lastSeenAt: DateTime.now(),
        isCurrentDevice: true,
        deviceSyncStatus: DeviceSyncStatus.synced,
      ),
    ];
  }

  @override
  Future<CompanyAccess> fetchCompany() async {
    try {
      final members = await fetchMembers();
      BusinessMember? owner;
      for (final member in members) {
        if (member.isOwner) {
          owner = member;
          break;
        }
      }
      final joinedCount =
          members.where((member) => member.status == MemberStatus.joined).length;
      final access = CompanyAccess(
        businessName: _companyName,
        ownerName: owner?.fullName ?? 'Business Owner',
        ownerPhone: owner?.phoneOrEmail ?? _sessionContext.ownerPhone,
        totalMembers: joinedCount,
        loggedInPhone: _sessionContext.currentUserPhone,
      );
      _companyCache.replaceCompanyAccess(access);
      return access;
    } on DioException {
      final cached = _companyCache.companyAccess;
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<SyncStatus> fetchSyncStatus() async => _syncStatus;

  @override
  Future<Invitation> inviteMember(InviteMemberInput input) async {
    final invitation = await _api.createInvitation(input);
    await _refreshInvitationsCache();
    return invitation;
  }

  @override
  Future<BusinessMember> updateMember(
    String id,
    UpdateMemberInput input,
  ) async {
    final existing = await _memberById(id);
    if (existing == null) {
      throw const CollaborationNotFoundException('Member not found');
    }
    if (existing.isOwner) {
      throw const CollaborationForbiddenException(
        'The business owner cannot be edited',
      );
    }

    final contactChanged =
        normalizeContact(existing.phoneOrEmail) !=
        normalizeContact(input.phoneOrEmail);
    final nameChanged = existing.fullName.trim() != input.fullName.trim();
    if (contactChanged || nameChanged) {
      throw const CollaborationValidationException(
        'Contact details cannot be changed. Remove the member and send a new invitation.',
      );
    }

    return changeRole(id, input.role);
  }

  @override
  Future<void> removeMember(String id) async {
    final member = await _memberById(id);
    if (member == null) {
      throw const CollaborationNotFoundException('Member not found');
    }
    if (member.isOwner) {
      throw const CollaborationForbiddenException(
        'The business owner cannot be removed',
      );
    }

    await _api.removeMember(id);
    await _refreshMembersAndInvitationsCache();
  }

  @override
  Future<BusinessMember> changeRole(String id, Role role) async {
    final member = await _memberById(id);
    if (member == null) {
      throw const CollaborationNotFoundException('Member not found');
    }
    if (member.isOwner) {
      throw const CollaborationForbiddenException(
        'The business owner role cannot be changed',
      );
    }

    final updated = await _api.updateMemberRole(id, role);
    await _refreshMembersAndInvitationsCache();
    return updated;
  }

  Future<BusinessMember?> _memberById(String id) async {
    final members = _companyCache.members.isNotEmpty
        ? _companyCache.members
        : await fetchMembers();
    for (final member in members) {
      if (member.id == id) return member;
    }
    return null;
  }

  BusinessMember? _memberByInvitationId(
    List<BusinessMember> members,
    String invitationId,
  ) {
    for (final member in members) {
      if (member.invitationId == invitationId) return member;
    }
    return null;
  }

  Invitation? _invitationById(String invitationId) {
    for (final invitation in _companyCache.invitations) {
      if (invitation.id == invitationId) return invitation;
    }
    return null;
  }

  CompanyListEntry? _companyEntryById(
    List<CompanyListEntry> companies,
    String companyId,
  ) {
    for (final entry in companies) {
      if (entry.id == companyId) return entry;
    }
    return null;
  }

  CompanyListEntry? _companyEntryByInvitationId(
    List<CompanyListEntry> companies,
    String invitationId,
  ) {
    for (final entry in companies) {
      if (entry.invitationId == invitationId) return entry;
    }
    return null;
  }

  @override
  Future<void> enableSync() async {
    if (_syncStatus.isEnabled &&
        _syncStatus.state == CollaborationSyncState.enabled) {
      throw const CollaborationConflictException('Sync is already enabled');
    }
    _loggedOut = false;
    _syncStatus = _syncStatus.copyWith(
      state: CollaborationSyncState.enabled,
      isConnected: true,
      isEnabled: true,
      isSyncing: false,
      errorMessage: null,
      lastSyncedAt: DateTime.now(),
      currentDeviceName: _sessionContext.currentDeviceName,
      currentUserPhone: _sessionContext.currentUserPhone,
    );
  }

  @override
  Future<void> disableSync() async {
    if (!_syncStatus.isEnabled ||
        _syncStatus.state == CollaborationSyncState.disabled) {
      throw const CollaborationConflictException('Sync is already disabled');
    }
    _syncStatus = _syncStatus.copyWith(
      state: CollaborationSyncState.disabled,
      isConnected: false,
      isEnabled: false,
      isSyncing: false,
      pendingUploads: 0,
      pendingDownloads: 0,
    );
  }

  @override
  Future<void> logoutSync() async {
    _loggedOut = true;
    _syncStatus = _syncStatus.copyWith(
      state: CollaborationSyncState.disabled,
      isConnected: false,
      isEnabled: false,
      isSyncing: false,
      pendingUploads: 0,
      pendingDownloads: 0,
      pendingChanges: 0,
      conflictCount: 0,
    );
  }

  @override
  Future<SyncStatus> refresh() async {
    _syncStatus = _syncStatus.copyWith(
      state: CollaborationSyncState.syncing,
      isSyncing: true,
      errorMessage: null,
    );
    try {
      await fetchInvitations();
      if (_loggedOut || !_syncStatus.isEnabled) {
        _syncStatus = _syncStatus.copyWith(
          state: CollaborationSyncState.disabled,
          isSyncing: false,
          isConnected: false,
        );
        return _syncStatus;
      }
      _syncStatus = _syncStatus.copyWith(
        state: CollaborationSyncState.enabled,
        isSyncing: false,
        isConnected: true,
        lastSyncedAt: DateTime.now(),
        pendingUploads: 0,
        pendingDownloads: 0,
        pendingChanges: 0,
        conflictCount: 0,
      );
      return _syncStatus;
    } on DioException {
      _syncStatus = _syncStatus.copyWith(
        state: CollaborationSyncState.offline,
        isSyncing: false,
        isConnected: false,
      );
      return _syncStatus;
    }
  }

  @override
  Future<Invitation> acceptInvitation(String invitationId) async {
    throw const CollaborationForbiddenException(
      'Accept invitations from the business list or invite link.',
    );
  }

  @override
  Future<Invitation> rejectInvitation(String invitationId) async {
    throw const CollaborationForbiddenException(
      'Reject invitations from the business list or invite link.',
    );
  }

  @override
  Future<Invitation> cancelInvitation(String invitationId) async {
    final invitation = await _api.cancelInvitation(invitationId);
    await _refreshInvitationsCache();
    return invitation;
  }

  @override
  Future<Invitation> reinviteInvitation(String invitationId) async {
    final members = _companyCache.members.isNotEmpty
        ? _companyCache.members
        : await fetchMembers();
    final member = _memberByInvitationId(members, invitationId);
    if (member == null) {
      throw const CollaborationNotFoundException('Member not found');
    }

    final existingInvitation = _invitationById(invitationId);

    final invitation = await _api.resendInvitation(
      invitationId: invitationId,
      input: InviteMemberInput(
        fullName: member.fullName,
        phoneOrEmail: member.phoneOrEmail,
        role: member.role,
      ),
      existingInvitation: existingInvitation,
    );
    await _refreshInvitationsCache();
    return invitation;
  }

  @override
  PermissionPreset getPermissionPreset(Role role) =>
      RolePermissionRegistry.presetFor(role);

  @override
  PermissionPreset loadPermissions(Role role) => getPermissionPreset(role);

  @override
  Future<List<CompanyListEntry>> loadCompanies() async {
    try {
      final shared = await _api.listSharedCompanies();
      final pending = await _api.listPendingInvitations();
      final companies = [
        ...shared.map(_mapSharedCompany),
        ...pending.map(_mapPendingInvitation),
      ];
      _cache.directory.replaceCompanies(companies);
      return companies;
    } on CollaborationNotFoundException {
      // Collaboration routes are not deployed yet — owned companies still work.
      return const [];
    } on DioException {
      return List<CompanyListEntry>.from(_cache.directory.companies);
    }
  }

  @override
  Future<CompanySession?> loadCurrentCompany({
    required String userId,
    required String userName,
  }) async {
    return null;
  }

  @override
  Future<CompanySession> switchCompany({
    required String companyId,
    required String userId,
    required String userName,
  }) async {
    final companies = _cache.directory.companies.isNotEmpty
        ? _cache.directory.companies
        : await loadCompanies();
    final entry = _companyEntryById(companies, companyId);
    if (entry == null) {
      throw const CollaborationNotFoundException('Company not found');
    }
    if (!entry.relationship.canOpen) {
      throw const CollaborationForbiddenException(
        'Accept the invitation before opening this company',
      );
    }

    final role = entry.role ?? Role.biller;
    return CompanySession.shared(
      entry: entry,
      userId: userId,
      userName: userName,
      userPhone: _sessionContext.currentUserPhone,
      preset: RolePermissionRegistry.presetFor(role),
    );
  }

  @override
  Future<void> leaveCompany(String companyId) async {
    final companies = _cache.directory.companies.isNotEmpty
        ? _cache.directory.companies
        : await loadCompanies();
    final entry = _companyEntryById(companies, companyId);
    final memberId = entry?.memberId;
    if (memberId == null || memberId.isEmpty) {
      throw const CollaborationNotFoundException('Company membership not found');
    }
    await _api.leaveCompany(memberId);
    _cache.clearDirectory();
    await loadCompanies();
  }

  @override
  Future<CompanyListEntry> acceptCompanyInvitation(String invitationId) async {
    final companies = _cache.directory.companies.isNotEmpty
        ? _cache.directory.companies
        : await loadCompanies();
    final entry = _companyEntryByInvitationId(companies, invitationId);
    final inviteCode = entry?.inviteCode;
    if (entry == null || inviteCode == null || inviteCode.isEmpty) {
      throw const CollaborationNotFoundException('Invitation not found');
    }

    await _api.acceptInvitationByToken(inviteCode);
    _cache.clearDirectory();
    final refreshed = await loadCompanies();
    for (final updated in refreshed) {
      if (updated.id == entry.id) {
        return updated;
      }
    }
    return entry.copyWith(
      relationship: CompanyRelationship.member,
      invitationStatus: InvitationCardStatus.accepted,
    );
  }

  @override
  Future<void> rejectCompanyInvitation(String invitationId) async {
    final companies = _cache.directory.companies.isNotEmpty
        ? _cache.directory.companies
        : await loadCompanies();
    final entry = _companyEntryByInvitationId(companies, invitationId);
    final inviteCode = entry?.inviteCode;
    if (entry == null || inviteCode == null || inviteCode.isEmpty) {
      throw const CollaborationNotFoundException('Invitation not found');
    }

    await _api.rejectInvitationByToken(inviteCode);
    _cache.clearDirectory();
    await loadCompanies();
  }

  Future<void> _refreshMembersAndInvitationsCache() async {
    try {
      final members = await _api.listMembers();
      _companyCache.replaceMembers(members);
    } on DioException {
      // Keep cached members on background refresh failure.
    }
    try {
      final invitations = await _api.listInvitations();
      _companyCache.replaceInvitations(invitations);
    } on DioException {
      // Keep cached invitations on background refresh failure.
    }
  }

  Future<void> _refreshInvitationsCache() async {
    await _refreshMembersAndInvitationsCache();
  }

  List<BusinessMember> _membersFromInvitations(List<Invitation> invitations) {
    final members = <BusinessMember>[];
    for (final invitation in invitations) {
      switch (invitation.status) {
        case InvitationStatus.pending:
        case InvitationStatus.opened:
          members.add(
            BusinessMember(
              id: invitation.memberId,
              fullName: invitation.fullName,
              phoneOrEmail: invitation.phoneOrEmail,
              status: MemberStatus.pending,
              role: invitation.role,
              invitationId: invitation.id,
              invitedAt: invitation.sentAt,
            ),
          );
        case InvitationStatus.accepted:
        case InvitationStatus.left:
          members.add(
            BusinessMember(
              id: invitation.memberId,
              fullName: invitation.fullName,
              phoneOrEmail: invitation.phoneOrEmail,
              status: MemberStatus.joined,
              role: invitation.role,
              invitationId: invitation.id,
              invitedAt: invitation.sentAt,
              joinedAt: invitation.sentAt,
            ),
          );
        case InvitationStatus.rejected:
        case InvitationStatus.cancelled:
        case InvitationStatus.expired:
          break;
      }
    }
    return members;
  }

  CompanyListEntry _mapSharedCompany(Map<String, dynamic> json) {
    return CompanyListEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerName: json['owner_name'] as String?,
      ownerPhone: json['owner_phone'] as String?,
      relationship: _relationshipFromApi(json['relationship'] as String?),
      role: _roleFromApi(json['role'] as String?),
      memberId: json['member_id'] as String?,
      syncStatus: _syncStatusFromApi(json['sync_status'] as String?),
      source: CompanyListSource.collaborationApi,
      logoUrl: json['logo_url'] as String?,
    );
  }

  CompanyListEntry _mapPendingInvitation(Map<String, dynamic> json) {
    return CompanyListEntry(
      id: json['company_id'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      ownerName: json['owner_name'] as String?,
      ownerPhone: json['owner_phone'] as String?,
      relationship: _relationshipFromApi(json['relationship'] as String?),
      role: _roleFromApi(json['role'] as String?),
      invitationId: json['invitation_id'] as String? ?? json['id'] as String?,
      inviteCode: json['invite_code'] as String?,
      invitationStatus: _invitationCardStatusFromApi(
        json['invitation_status'] as String?,
      ),
      syncStatus: _syncStatusFromApi(json['sync_status'] as String?),
      source: CompanyListSource.collaborationApi,
      logoUrl: json['logo_url'] as String?,
    );
  }

  CompanyRelationship _relationshipFromApi(String? value) {
    return switch (value) {
      'owner' => CompanyRelationship.owner,
      'secondary_admin' => CompanyRelationship.secondaryAdmin,
      'member' => CompanyRelationship.member,
      'pending_invite' => CompanyRelationship.pendingInvite,
      'expired_invite' => CompanyRelationship.expiredInvite,
      _ => CompanyRelationship.member,
    };
  }

  Role? _roleFromApi(String? value) {
    if (value == null) return null;
    return Role.values.cast<Role?>().firstWhere(
      (role) => role != null && _roleToApi(role) == value,
      orElse: () => null,
    );
  }

  InvitationCardStatus? _invitationCardStatusFromApi(String? value) {
    return switch (value) {
      'pending' => InvitationCardStatus.pending,
      'accepted' => InvitationCardStatus.accepted,
      'rejected' => InvitationCardStatus.rejected,
      'cancelled' => InvitationCardStatus.cancelled,
      'expired' => InvitationCardStatus.expired,
      _ => null,
    };
  }

  business.SyncStatus _syncStatusFromApi(String? value) {
    return value == 'off' ? business.SyncStatus.off : business.SyncStatus.on;
  }

  String _roleToApi(Role role) => switch (role) {
    Role.secondaryAdmin => 'secondary_admin',
    Role.salesman => 'salesman',
    Role.biller => 'biller',
    Role.billerAndSalesman => 'biller_and_salesman',
    Role.accountant => 'accountant',
    Role.stockKeeper => 'stock_keeper',
    Role.accountantEditAccess => 'accountant_edit_access',
  };

  void _markOfflineIfEnabled() {
    if (_loggedOut || !_syncStatus.isEnabled) return;
    _syncStatus = _syncStatus.copyWith(
      state: CollaborationSyncState.offline,
      isConnected: false,
      isSyncing: false,
    );
  }

  void _markOnlineIfEnabled() {
    if (_loggedOut || !_syncStatus.isEnabled) return;
    _syncStatus = _syncStatus.copyWith(
      state: CollaborationSyncState.enabled,
      isConnected: true,
      isSyncing: false,
      lastSyncedAt: DateTime.now(),
      errorMessage: null,
    );
  }

  SyncStatus _buildInitialSyncStatus() {
    return SyncStatus(
      currentDeviceName: _sessionContext.currentDeviceName,
      currentUserPhone: _sessionContext.currentUserPhone,
      lastSyncedAt: DateTime.now(),
    );
  }
}
