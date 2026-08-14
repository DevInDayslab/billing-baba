import 'dart:math';

import 'package:billing_baba/features/collaboration/application/collaboration_service_types.dart';
import 'package:billing_baba/features/collaboration/data/collaboration_invitation_api.dart';
import 'package:billing_baba/features/collaboration/data/collaboration_repository.dart';
import 'package:billing_baba/features/collaboration/data/fake_collaboration_directory.dart';
import 'package:billing_baba/features/collaboration/data/fake_collaboration_local_store.dart';
import 'package:billing_baba/features/collaboration/domain/models/business_member.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_access.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_session.dart';
import 'package:billing_baba/features/collaboration/domain/models/connected_device.dart';
import 'package:billing_baba/features/collaboration/domain/models/invitation.dart';
import 'package:billing_baba/features/collaboration/domain/models/member_status.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_preset.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:billing_baba/features/collaboration/domain/models/sync_status.dart';
import 'package:billing_baba/features/collaboration/domain/role_permission_registry.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Toggle to `true` to demo empty members/devices states.
const kCollaborationStartWithEmptyMembers = false;

class FakeCollaborationRepository implements CollaborationRepository {
  FakeCollaborationRepository({
    required this._sessionContext,
    required this._businessId,
    String? businessName,
    FakeCollaborationLocalStore? localStore,
    this._invitationApi,
  }) : _businessName = businessName ?? 'Sharma Traders',
       _localStore = localStore ?? FakeCollaborationLocalStore() {
    _syncStatus = _buildInitialSyncStatus();
    _devices.addAll(_seedDevices);
  }

  final CollaborationSessionContext _sessionContext;
  final String _businessId;
  final String _businessName;
  final FakeCollaborationLocalStore _localStore;
  final CollaborationInvitationApi? _invitationApi;

  final List<BusinessMember> _members = [];
  final List<Invitation> _invitations = [];
  final List<ConnectedDevice> _devices = [];
  late SyncStatus _syncStatus;
  bool _initialized = false;
  bool _loggedOut = false;

  static final _random = Random();

  @override
  CollaborationSessionContext get sessionContext => _sessionContext;

  void _seedData() {
    if (!kCollaborationStartWithEmptyMembers) {
      _members.addAll(_seedMembers);
      _invitations.addAll(_seedInvitations);
    }
  }

  Future<void> _persistState() {
    return _localStore.save(
      businessId: _businessId,
      members: _members,
      invitations: _invitations,
    );
  }

  Future<void> _upsertApiInvitation(Invitation invitation) async {
    final member = BusinessMember(
      id: invitation.memberId,
      fullName: invitation.fullName,
      phoneOrEmail: invitation.phoneOrEmail,
      status: MemberStatus.pending,
      role: invitation.role,
      invitationId: invitation.id,
      invitedAt: invitation.sentAt,
    );

    _members.removeWhere(
      (existing) =>
          normalizeContact(existing.phoneOrEmail) ==
          normalizeContact(member.phoneOrEmail),
    );
    _invitations.removeWhere(
      (existing) =>
          existing.memberId == member.id ||
          (normalizeContact(existing.phoneOrEmail) ==
                  normalizeContact(member.phoneOrEmail) &&
              existing.status.isActive),
    );

    _members.add(member);
    _invitations.add(invitation);
    await _persistState();
  }

  BusinessMember? _memberForInvitation(String invitationId) {
    for (final member in _members) {
      if (member.invitationId == invitationId) return member;
    }
    return null;
  }

  Invitation? _invitationById(String invitationId) {
    for (final invitation in _invitations) {
      if (invitation.id == invitationId) return invitation;
    }
    return null;
  }

  Invitation? _activeInvitationForContact(String phoneOrEmail) {
    final normalized = normalizeContact(phoneOrEmail);
    for (final invitation in _invitations) {
      if (!invitation.status.isActive) continue;
      if (normalizeContact(invitation.phoneOrEmail) == normalized) {
        return invitation;
      }
    }
    return null;
  }

  Future<bool> _syncInvitationStatusesFromApi() async {
    final api = _invitationApi;
    if (api == null) return false;

    var changed = false;
    for (final invitation in List<Invitation>.from(_invitations)) {
      if (!isApiInvitationId(invitation.id)) continue;
      if (invitation.inviteCode.isEmpty) continue;

      final isTerminal =
          invitation.status == InvitationStatus.accepted ||
          invitation.status == InvitationStatus.rejected ||
          invitation.status == InvitationStatus.cancelled ||
          invitation.status == InvitationStatus.expired;
      if (isTerminal) continue;

      try {
        final remoteStatus = await api.fetchInvitationStatus(
          invitation.inviteCode,
        );
        changed =
            _applyRemoteInvitationStatus(invitation, remoteStatus) || changed;
      } on DioException catch (error) {
        final statusCode = error.response?.statusCode;
        if (statusCode == 404 ||
            statusCode == 410 ||
            _errorCode(error) == 'INVITATION_EXPIRED') {
          changed =
              _applyRemoteInvitationStatus(invitation, 'expired') || changed;
        }
      }
    }
    return changed;
  }

  bool _applyRemoteInvitationStatus(
    Invitation invitation,
    String remoteStatus,
  ) {
    final inviteIndex = _invitations.indexWhere(
      (item) => item.id == invitation.id,
    );
    if (inviteIndex == -1) return false;

    final memberIndex = _members.indexWhere(
      (member) => member.id == invitation.memberId,
    );

    var changed = false;

    switch (remoteStatus) {
      case 'accepted':
        if (_invitations[inviteIndex].status != InvitationStatus.accepted) {
          _invitations[inviteIndex] = _invitations[inviteIndex].copyWith(
            status: InvitationStatus.accepted,
          );
          changed = true;
        }
        if (memberIndex != -1 &&
            _members[memberIndex].status != MemberStatus.joined) {
          _members[memberIndex] = _members[memberIndex].copyWith(
            status: MemberStatus.joined,
            joinedAt: DateTime.now(),
          );
          changed = true;
        }
      case 'rejected':
        changed =
            _closeInvitation(
              inviteIndex,
              memberIndex,
              InvitationStatus.rejected,
            ) ||
            changed;
      case 'cancelled':
        changed =
            _closeInvitation(
              inviteIndex,
              memberIndex,
              InvitationStatus.cancelled,
            ) ||
            changed;
      case 'expired':
        changed =
            _closeInvitation(
              inviteIndex,
              memberIndex,
              InvitationStatus.expired,
            ) ||
            changed;
      case 'opened':
      case 'pending':
        break;
    }

    return changed;
  }

  bool _closeInvitation(
    int inviteIndex,
    int memberIndex,
    InvitationStatus status,
  ) {
    var changed = false;
    if (_invitations[inviteIndex].status != status) {
      _invitations[inviteIndex] = _invitations[inviteIndex].copyWith(
        status: status,
      );
      changed = true;
    }
    if (memberIndex != -1 &&
        _members[memberIndex].status == MemberStatus.pending) {
      _members.removeAt(memberIndex);
      changed = true;
    }
    return changed;
  }

  String? _errorCode(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final errorBody = data['error'];
      if (errorBody is Map<String, dynamic>) {
        return errorBody['code'] as String?;
      }
    }
    return null;
  }

  Future<void> _loadOrSeedData() async {
    final stored = await _localStore.load(_businessId);
    if (stored != null) {
      _members
        ..clear()
        ..addAll(stored.members);
      _invitations
        ..clear()
        ..addAll(stored.invitations);
      return;
    }

    _seedData();
    await _persistState();
  }

  static final _seedMembers = [
    BusinessMember(
      id: 'member-1',
      fullName: 'Abhinav',
      phoneOrEmail: '+91 8077607209',
      status: MemberStatus.joined,
      role: Role.biller,
      invitationId: 'invite-1',
      invitedAt: DateTime.now().subtract(const Duration(days: 14)),
      joinedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    BusinessMember(
      id: 'member-2',
      fullName: 'Ishu Singh',
      phoneOrEmail: '+91 9876543210',
      status: MemberStatus.pending,
      role: Role.salesman,
      invitationId: 'invite-2',
      invitedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    BusinessMember(
      id: 'member-3',
      fullName: 'Priya Mehta',
      phoneOrEmail: 'priya@sharmatraders.com',
      status: MemberStatus.pending,
      role: Role.stockKeeper,
      invitationId: 'invite-3',
      invitedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static final _seedInvitations = [
    Invitation(
      id: 'invite-1',
      inviteCode: 'ABCD1001',
      memberId: 'member-1',
      fullName: 'Abhinav',
      phoneOrEmail: '+91 8077607209',
      role: Role.biller,
      channel: InvitationChannel.sms,
      sentAt: DateTime.now().subtract(const Duration(days: 14)),
      expiresAt: DateTime.now().add(const Duration(days: 1)),
      status: InvitationStatus.accepted,
    ),
    Invitation(
      id: 'invite-2',
      inviteCode: 'ABCD1002',
      memberId: 'member-2',
      fullName: 'Ishu Singh',
      phoneOrEmail: '+91 9876543210',
      role: Role.salesman,
      channel: InvitationChannel.sms,
      sentAt: DateTime.now().subtract(const Duration(days: 3)),
      expiresAt: DateTime.now().add(const Duration(days: 4)),
      status: InvitationStatus.pending,
    ),
    Invitation(
      id: 'invite-3',
      inviteCode: 'ABCD1003',
      memberId: 'member-3',
      fullName: 'Priya Mehta',
      phoneOrEmail: 'priya@sharmatraders.com',
      role: Role.stockKeeper,
      channel: InvitationChannel.email,
      sentAt: DateTime.now().subtract(const Duration(days: 1)),
      expiresAt: DateTime.now().add(const Duration(days: 6)),
      status: InvitationStatus.pending,
    ),
  ];

  static final _seedDevices = [
    ConnectedDevice(
      id: 'device-1',
      name: 'MacBook Pro',
      platform: DevicePlatform.macos,
      osName: 'macOS 15.0',
      appVersion: '1.0.0',
      lastSeenAt: DateTime.now(),
      isCurrentDevice: true,
      deviceSyncStatus: DeviceSyncStatus.synced,
    ),
    ConnectedDevice(
      id: 'device-2',
      name: 'Office Desktop',
      platform: DevicePlatform.windows,
      osName: 'Windows 11',
      appVersion: '1.0.0',
      lastSeenAt: DateTime.now().subtract(const Duration(hours: 2)),
      isOnline: false,
      deviceSyncStatus: DeviceSyncStatus.offline,
    ),
    ConnectedDevice(
      id: 'device-3',
      name: 'Warehouse Tablet',
      platform: DevicePlatform.android,
      osName: 'Android 14',
      appVersion: '1.0.0',
      lastSeenAt: DateTime.now().subtract(const Duration(minutes: 20)),
      deviceSyncStatus: DeviceSyncStatus.synced,
    ),
  ];

  SyncStatus _buildInitialSyncStatus() {
    return SyncStatus(
      lastSyncedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      pendingUploads: 2,
      pendingDownloads: 1,
      pendingChanges: 3,
      storageUsedMb: 248.5,
      currentDeviceName: _sessionContext.currentDeviceName,
      currentUserPhone: _sessionContext.currentUserPhone,
    );
  }

  Future<void> _delay([int minMs = 400, int maxMs = 800]) async {
    final ms = minMs + _random.nextInt(maxMs - minMs + 1);
    await Future<void>.delayed(Duration(milliseconds: ms));
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(6, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  InvitationChannel _channelFor(String phoneOrEmail) {
    if (phoneOrEmail.contains('@')) return InvitationChannel.email;
    return InvitationChannel.sms;
  }

  bool _expireStaleInvitations() {
    var changed = false;
    for (var i = 0; i < _invitations.length; i++) {
      final invite = _invitations[i];
      if (invite.status == InvitationStatus.pending &&
          DateTime.now().isAfter(invite.expiresAt)) {
        _invitations[i] = invite.copyWith(status: InvitationStatus.expired);
        changed = true;
        final memberIndex = _members.indexWhere((m) => m.id == invite.memberId);
        if (memberIndex != -1 &&
            _members[memberIndex].status == MemberStatus.pending) {
          _members.removeAt(memberIndex);
          changed = true;
        }
      }
    }
    return changed;
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    await _delay(200, 400);
    await _loadOrSeedData();
    if (_expireStaleInvitations()) {
      await _persistState();
    }
    _initialized = true;
  }

  @override
  Future<List<BusinessMember>> fetchMembers() async {
    await _delay(100, 200);
    if (await _syncInvitationStatusesFromApi()) {
      await _persistState();
    }
    if (_expireStaleInvitations()) {
      await _persistState();
    }
    return List<BusinessMember>.from(_members);
  }

  @override
  Future<List<ConnectedDevice>> fetchDevices() async {
    await _delay();
    if (_loggedOut || _syncStatus.isDisabled || !_syncStatus.isConnected) {
      return [];
    }
    return List<ConnectedDevice>.from(_devices);
  }

  @override
  Future<List<Invitation>> fetchInvitations() async {
    await _delay(100, 200);
    if (await _syncInvitationStatusesFromApi()) {
      await _persistState();
    }
    if (_expireStaleInvitations()) {
      await _persistState();
    }
    return List<Invitation>.from(_invitations);
  }

  @override
  Future<CompanyAccess> fetchCompany() async {
    await _delay(300, 500);
    final joinedCount = _members
        .where((m) => m.status == MemberStatus.joined)
        .length;
    return CompanyAccess(
      businessName: _businessName,
      ownerName: 'Business Owner',
      ownerPhone: _sessionContext.ownerPhone,
      totalMembers: joinedCount + 1,
      loggedInPhone: _sessionContext.currentUserPhone,
    );
  }

  @override
  Future<SyncStatus> fetchSyncStatus() async {
    await _delay();
    return _syncStatus;
  }

  @override
  Future<Invitation> inviteMember(InviteMemberInput input) async {
    if (_invitationApi != null) {
      await _delay(200, 400);
      final invitation = await _invitationApi.createInvitation(input);
      await _upsertApiInvitation(invitation);
      return invitation;
    }

    await _delay(500, 900);
    final memberId = 'member-${_uuid.v4()}';
    final invitationId = 'invite-${_uuid.v4()}';
    final inviteCode = _generateInviteCode();
    final now = DateTime.now();

    final member = BusinessMember(
      id: memberId,
      fullName: input.fullName.trim(),
      phoneOrEmail: formatPhoneOrEmailContact(input.phoneOrEmail),
      status: MemberStatus.pending,
      role: input.role,
      invitationId: invitationId,
      invitedAt: now,
    );

    final invitation = Invitation(
      id: invitationId,
      inviteCode: inviteCode,
      memberId: memberId,
      fullName: member.fullName,
      phoneOrEmail: member.phoneOrEmail,
      role: input.role,
      channel: _channelFor(input.phoneOrEmail),
      sentAt: now,
      expiresAt: now.add(const Duration(days: 7)),
      status: InvitationStatus.pending,
    );

    _members.add(member);
    _invitations.add(invitation);
    await _persistState();
    return invitation;
  }

  @override
  Future<BusinessMember> updateMember(
    String id,
    UpdateMemberInput input,
  ) async {
    await _delay();
    final index = _members.indexWhere((member) => member.id == id);
    if (index == -1) {
      throw const CollaborationNotFoundException('Member not found');
    }
    final updated = _members[index].copyWith(
      fullName: input.fullName.trim(),
      phoneOrEmail: formatPhoneOrEmailContact(input.phoneOrEmail),
      role: input.role,
    );
    _members[index] = updated;
    await _persistState();
    return updated;
  }

  @override
  Future<void> removeMember(String id) async {
    await _delay();
    final index = _members.indexWhere((member) => member.id == id);
    if (index == -1) {
      throw const CollaborationNotFoundException('Member not found');
    }
    final member = _members[index];
    _members.removeAt(index);
    _invitations.removeWhere(
      (invite) => invite.memberId == member.id && invite.status.isActive,
    );
    await _persistState();
  }

  @override
  Future<BusinessMember> changeRole(String id, Role role) async {
    await _delay();
    final index = _members.indexWhere((member) => member.id == id);
    if (index == -1) {
      throw const CollaborationNotFoundException('Member not found');
    }
    final updated = _members[index].copyWith(role: role);
    _members[index] = updated;
    await _persistState();
    return updated;
  }

  @override
  Future<void> enableSync() async {
    await _delay();
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
    );
    for (var i = 0; i < _devices.length; i++) {
      final device = _devices[i];
      _devices[i] = device.copyWith(
        isCurrentDevice: device.id == 'device-1',
        isOnline: device.id == 'device-1',
        deviceSyncStatus: device.id == 'device-1'
            ? DeviceSyncStatus.synced
            : DeviceSyncStatus.offline,
        lastSeenAt: device.id == 'device-1'
            ? DateTime.now()
            : device.lastSeenAt,
      );
    }
  }

  @override
  Future<void> disableSync() async {
    await _delay();
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
    await _delay();
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
    for (var i = 0; i < _devices.length; i++) {
      _devices[i] = _devices[i].copyWith(
        isCurrentDevice: false,
        isOnline: false,
        deviceSyncStatus: DeviceSyncStatus.offline,
      );
    }
  }

  @override
  Future<SyncStatus> refresh() async {
    _syncStatus = _syncStatus.copyWith(
      state: CollaborationSyncState.syncing,
      isSyncing: true,
      errorMessage: null,
    );
    await Future<void>.delayed(const Duration(milliseconds: 1500));
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
    for (var i = 0; i < _devices.length; i++) {
      final device = _devices[i];
      _devices[i] = device.copyWith(
        lastSeenAt: device.isCurrentDevice ? DateTime.now() : device.lastSeenAt,
        deviceSyncStatus: device.isOnline
            ? DeviceSyncStatus.synced
            : DeviceSyncStatus.offline,
      );
    }
    return _syncStatus;
  }

  @override
  Future<Invitation> acceptInvitation(String invitationId) async {
    await _delay();
    final index = _invitations.indexWhere(
      (invite) => invite.id == invitationId,
    );
    if (index == -1) {
      throw const CollaborationNotFoundException('Invitation not found');
    }
    final invite = _invitations[index];
    if (invite.status != InvitationStatus.pending) {
      throw const CollaborationConflictException(
        'Invitation is no longer pending',
      );
    }
    if (DateTime.now().isAfter(invite.expiresAt)) {
      _invitations[index] = invite.copyWith(status: InvitationStatus.expired);
      throw const CollaborationConflictException('Invitation has expired');
    }
    final updatedInvite = invite.copyWith(status: InvitationStatus.accepted);
    _invitations[index] = updatedInvite;

    final memberIndex = _members.indexWhere((m) => m.id == invite.memberId);
    if (memberIndex != -1) {
      _members[memberIndex] = _members[memberIndex].copyWith(
        status: MemberStatus.joined,
        joinedAt: DateTime.now(),
      );
    }
    await _persistState();
    return updatedInvite;
  }

  @override
  Future<Invitation> rejectInvitation(String invitationId) async {
    await _delay();
    final index = _invitations.indexWhere(
      (invite) => invite.id == invitationId,
    );
    if (index == -1) {
      throw const CollaborationNotFoundException('Invitation not found');
    }
    final invite = _invitations[index];
    if (invite.status != InvitationStatus.pending) {
      throw const CollaborationConflictException(
        'Invitation is no longer pending',
      );
    }
    final updatedInvite = invite.copyWith(status: InvitationStatus.rejected);
    _invitations[index] = updatedInvite;
    _members.removeWhere((member) => member.id == invite.memberId);
    await _persistState();
    return updatedInvite;
  }

  @override
  Future<Invitation> cancelInvitation(String invitationId) async {
    await _delay();
    final index = _invitations.indexWhere(
      (invite) => invite.id == invitationId,
    );
    if (index == -1) {
      throw const CollaborationNotFoundException('Invitation not found');
    }
    final invite = _invitations[index];
    if (invite.status != InvitationStatus.pending) {
      throw const CollaborationConflictException(
        'Invitation is no longer pending',
      );
    }
    final updatedInvite = invite.copyWith(status: InvitationStatus.cancelled);
    _invitations[index] = updatedInvite;
    _members.removeWhere((member) => member.id == invite.memberId);
    await _persistState();
    return updatedInvite;
  }

  @override
  Future<Invitation> reinviteInvitation(String invitationId) async {
    if (_invitationApi != null) {
      await _delay(200, 400);
      final member = _memberForInvitation(invitationId);
      if (member == null) {
        throw const CollaborationNotFoundException('Member not found');
      }

      final existingInvitation =
          _invitationById(invitationId) ??
          _activeInvitationForContact(member.phoneOrEmail);

      final newInvitation = await _invitationApi.resendInvitation(
        invitationId: invitationId,
        input: InviteMemberInput(
          fullName: member.fullName,
          phoneOrEmail: member.phoneOrEmail,
          role: member.role,
        ),
        existingInvitation: existingInvitation,
      );

      if (existingInvitation != null &&
          existingInvitation.id != newInvitation.id) {
        final index = _invitations.indexWhere(
          (invite) => invite.id == existingInvitation.id,
        );
        if (index != -1 && _invitations[index].status.isActive) {
          _invitations[index] = _invitations[index].copyWith(
            status: InvitationStatus.cancelled,
          );
        }
      }

      await _upsertApiInvitation(newInvitation);
      return newInvitation;
    }

    await _delay(500, 900);
    final index = _invitations.indexWhere(
      (invite) => invite.id == invitationId,
    );
    if (index == -1) {
      throw const CollaborationNotFoundException('Invitation not found');
    }

    final old = _invitations[index];
    if (old.status == InvitationStatus.accepted) {
      throw const CollaborationConflictException(
        'This member has already joined',
      );
    }

    final now = DateTime.now();
    final newInvitationId = 'invite-${_uuid.v4()}';
    final newInviteCode = _generateInviteCode();

    _invitations[index] = old.copyWith(status: InvitationStatus.cancelled);

    final newInvitation = Invitation(
      id: newInvitationId,
      inviteCode: newInviteCode,
      memberId: old.memberId,
      fullName: old.fullName,
      phoneOrEmail: old.phoneOrEmail,
      role: old.role,
      channel: old.channel,
      sentAt: now,
      expiresAt: now.add(const Duration(days: 7)),
      status: InvitationStatus.pending,
    );
    _invitations.add(newInvitation);

    final memberIndex = _members.indexWhere(
      (member) => member.id == old.memberId,
    );
    if (memberIndex != -1) {
      _members[memberIndex] = _members[memberIndex].copyWith(
        invitationId: newInvitationId,
        invitedAt: now,
        status: MemberStatus.pending,
      );
    }

    await _persistState();
    return newInvitation;
  }

  @override
  PermissionPreset getPermissionPreset(Role role) {
    return RolePermissionRegistry.presetFor(role);
  }

  @override
  PermissionPreset loadPermissions(Role role) => getPermissionPreset(role);

  @override
  Future<List<CompanyListEntry>> loadCompanies() async {
    await _delay(200, 400);
    return FakeCollaborationDirectory.loadCompanies(
      _sessionContext.currentUserPhone,
    );
  }

  @override
  Future<CompanySession?> loadCurrentCompany({
    required String userId,
    required String userName,
  }) async {
    await _delay(100, 200);
    return FakeCollaborationDirectory.loadCurrentSession(
      currentUserPhone: _sessionContext.currentUserPhone,
      userId: userId,
      userName: userName,
    );
  }

  @override
  Future<CompanySession> switchCompany({
    required String companyId,
    required String userId,
    required String userName,
  }) async {
    await _delay(300, 500);
    return FakeCollaborationDirectory.switchCompany(
      companyId: companyId,
      currentUserPhone: _sessionContext.currentUserPhone,
      userId: userId,
      userName: userName,
    );
  }

  @override
  Future<void> leaveCompany(String companyId) async {
    await _delay();
    FakeCollaborationDirectory.leaveCompany(
      companyId,
      _sessionContext.currentUserPhone,
    );
  }

  @override
  Future<CompanyListEntry> acceptCompanyInvitation(String invitationId) async {
    await _delay();
    return FakeCollaborationDirectory.acceptInvitation(
      invitationId: invitationId,
      currentUserPhone: _sessionContext.currentUserPhone,
    );
  }

  @override
  Future<void> rejectCompanyInvitation(String invitationId) async {
    await _delay();
    FakeCollaborationDirectory.rejectInvitation(
      invitationId: invitationId,
      currentUserPhone: _sessionContext.currentUserPhone,
    );
  }
}
