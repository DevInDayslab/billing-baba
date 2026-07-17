import 'dart:math';

import 'package:billing_baba/features/collaboration/application/collaboration_service_types.dart';
import 'package:billing_baba/features/collaboration/data/collaboration_repository.dart';
import 'package:billing_baba/features/collaboration/domain/models/business_member.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_access.dart';
import 'package:billing_baba/features/collaboration/domain/models/connected_device.dart';
import 'package:billing_baba/features/collaboration/domain/models/invitation.dart';
import 'package:billing_baba/features/collaboration/domain/models/member_status.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_preset.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:billing_baba/features/collaboration/domain/models/sync_status.dart';
import 'package:billing_baba/features/collaboration/domain/role_permission_registry.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Toggle to `true` to demo empty members/devices states.
const kCollaborationStartWithEmptyMembers = false;

class FakeCollaborationRepository implements CollaborationRepository {
  FakeCollaborationRepository({
    required CollaborationSessionContext sessionContext,
    String? businessName,
  }) : _sessionContext = sessionContext,
       _businessName = businessName ?? 'Sharma Traders' {
    _syncStatus = _buildInitialSyncStatus();
    _seedData();
  }

  final CollaborationSessionContext _sessionContext;
  final String _businessName;

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
    _devices.addAll(_seedDevices);
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
      isOnline: true,
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
      isOnline: true,
      deviceSyncStatus: DeviceSyncStatus.synced,
    ),
  ];

  SyncStatus _buildInitialSyncStatus() {
    return SyncStatus(
      state: CollaborationSyncState.enabled,
      isConnected: true,
      isEnabled: true,
      lastSyncedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      pendingUploads: 2,
      pendingDownloads: 1,
      conflictCount: 0,
      pendingChanges: 3,
      storageUsedMb: 248.5,
      storageTotalMb: 1024,
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
    return List.generate(8, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  InvitationChannel _channelFor(String phoneOrEmail) {
    if (phoneOrEmail.contains('@')) return InvitationChannel.email;
    return InvitationChannel.sms;
  }

  void _expireStaleInvitations() {
    for (var i = 0; i < _invitations.length; i++) {
      final invite = _invitations[i];
      if (invite.status == InvitationStatus.pending &&
          DateTime.now().isAfter(invite.expiresAt)) {
        _invitations[i] = invite.copyWith(status: InvitationStatus.expired);
        final memberIndex = _members.indexWhere((m) => m.id == invite.memberId);
        if (memberIndex != -1 &&
            _members[memberIndex].status == MemberStatus.pending) {
          _members.removeAt(memberIndex);
        }
      }
    }
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    await _delay(200, 400);
    _expireStaleInvitations();
    _initialized = true;
  }

  @override
  Future<List<BusinessMember>> fetchMembers() async {
    await _delay();
    _expireStaleInvitations();
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
    await _delay();
    _expireStaleInvitations();
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
    await _delay(500, 900);
    final memberId = 'member-${_uuid.v4()}';
    final invitationId = 'invite-${_uuid.v4()}';
    final inviteCode = _generateInviteCode();
    final now = DateTime.now();

    final member = BusinessMember(
      id: memberId,
      fullName: input.fullName.trim(),
      phoneOrEmail: input.phoneOrEmail.trim(),
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
      phoneOrEmail: input.phoneOrEmail.trim(),
      role: input.role,
    );
    _members[index] = updated;
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
    return updatedInvite;
  }

  @override
  PermissionPreset getPermissionPreset(Role role) {
    return RolePermissionRegistry.presetFor(role);
  }
}
