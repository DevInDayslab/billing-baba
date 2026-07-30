import 'package:billing_baba/features/collaboration/application/collaboration_service_types.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_simulator.dart';
import 'package:billing_baba/features/collaboration/data/collaboration_repository.dart';
import 'package:billing_baba/features/collaboration/domain/models/business_member.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_access.dart';
import 'package:billing_baba/features/collaboration/domain/models/connected_device.dart';
import 'package:billing_baba/features/collaboration/domain/models/invitation.dart';
import 'package:billing_baba/features/collaboration/domain/models/member_status.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_preset.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:billing_baba/features/collaboration/domain/models/sync_status.dart';
import 'package:billing_baba/shared/utils/validators.dart';

class CollaborationService {
  CollaborationService(this._repository);

  final CollaborationRepository _repository;

  CollaborationSessionContext get _context => _repository.sessionContext;

  Future<void> initialize() => _repository.initialize();

  Future<List<BusinessMember>> fetchMembers() => _repository.fetchMembers();

  Future<List<ConnectedDevice>> fetchDevices() => _repository.fetchDevices();

  Future<List<Invitation>> fetchInvitations() => _repository.fetchInvitations();

  Future<CompanyAccess> fetchCompany() => _repository.fetchCompany();

  Future<SyncStatus> fetchSyncStatus() => _repository.fetchSyncStatus();

  PermissionPreset getPermissionPreset(Role role) =>
      _repository.getPermissionPreset(role);

  Future<Invitation> inviteMember(InviteMemberInput input) async {
    final formatted = _formatInput(input);
    final syncStatus = await _repository.fetchSyncStatus();
    if (syncStatus.isDisabled) {
      throw const CollaborationForbiddenException(
        'Enable cloud sync to invite members',
      );
    }
    _validateMemberInput(formatted.fullName, formatted.phoneOrEmail);
    _validateRole(formatted.role);
    await _validateInviteTarget(formatted.phoneOrEmail);

    final invitation = await _repository.inviteMember(formatted);
    CollaborationSimulator.inviteUser(
      name: formatted.fullName,
      role: formatted.role.displayLabel,
      contact: formatted.phoneOrEmail,
      invitationLink: invitation.inviteLink,
    );
    CollaborationSimulator.generateLink(link: invitation.inviteLink);
    return invitation;
  }

  Future<BusinessMember> updateMember(
    String id,
    UpdateMemberInput input,
  ) async {
    final formatted = _formatUpdateInput(input);
    _validateMemberInput(formatted.fullName, formatted.phoneOrEmail);
    _validateRole(formatted.role);

    final members = await _repository.fetchMembers();
    final existing = _findMember(members, id);
    _assertNotOwner(existing, action: 'update');

    if (normalizeContact(existing.phoneOrEmail) !=
        normalizeContact(formatted.phoneOrEmail)) {
      await _validateInviteTarget(formatted.phoneOrEmail, ignoreMemberId: id);
    }

    final updated = await _repository.updateMember(id, formatted);
    if (existing.role != formatted.role) {
      CollaborationSimulator.changeRole(
        name: formatted.fullName,
        from: existing.role,
        to: formatted.role,
      );
    } else {
      CollaborationSimulator.updateMember(
        name: formatted.fullName,
        role: formatted.role.displayLabel,
        contact: formatted.phoneOrEmail,
      );
    }
    return updated;
  }

  Future<void> removeMember(String id) async {
    final members = await _repository.fetchMembers();
    final existing = _findMember(members, id);
    _assertNotOwner(existing, action: 'remove');

    await _repository.removeMember(id);
    CollaborationSimulator.deleteMember(
      name: existing.fullName,
      contact: existing.phoneOrEmail,
    );
  }

  Future<BusinessMember> changeRole(String id, Role role) async {
    _validateRole(role);
    final members = await _repository.fetchMembers();
    final existing = _findMember(members, id);
    _assertNotOwner(existing, action: 'change role for');

    final updated = await _repository.changeRole(id, role);
    CollaborationSimulator.changeRole(
      name: existing.fullName,
      from: existing.role,
      to: role,
    );
    return updated;
  }

  Future<void> enableSync() async {
    final status = await _repository.fetchSyncStatus();
    if (status.isEnabled && status.state == CollaborationSyncState.enabled) {
      throw const CollaborationConflictException('Sync is already enabled');
    }
    await _repository.enableSync();
    CollaborationSimulator.enableSync();
  }

  Future<void> disableSync() async {
    final status = await _repository.fetchSyncStatus();
    if (!status.isEnabled || status.state == CollaborationSyncState.disabled) {
      throw const CollaborationConflictException('Sync is already disabled');
    }
    await _repository.disableSync();
    CollaborationSimulator.disableSync();
  }

  Future<void> logoutSync() async {
    await _repository.logoutSync();
    CollaborationSimulator.logout();
  }

  Future<SyncStatus> refresh() async {
    final status = await _repository.refresh();
    CollaborationSimulator.refresh(
      timestamp: (status.lastSyncedAt ?? DateTime.now()).toIso8601String(),
    );
    return status;
  }

  Future<Invitation> acceptInvitation(String invitationId) async {
    final invitation = await _repository.acceptInvitation(invitationId);
    CollaborationSimulator.acceptInvitation(
      name: invitation.fullName,
      link: invitation.inviteLink,
    );
    return invitation;
  }

  Future<Invitation> rejectInvitation(String invitationId) async {
    final invitation = await _repository.rejectInvitation(invitationId);
    CollaborationSimulator.rejectInvitation(
      name: invitation.fullName,
      link: invitation.inviteLink,
    );
    return invitation;
  }

  Future<Invitation> cancelInvitation(String invitationId) async {
    final invitation = await _repository.cancelInvitation(invitationId);
    CollaborationSimulator.cancelInvitation(
      name: invitation.fullName,
      link: invitation.inviteLink,
    );
    return invitation;
  }

  Future<Invitation> reinviteInvitation(String invitationId) async {
    final syncStatus = await _repository.fetchSyncStatus();
    if (syncStatus.isDisabled) {
      throw const CollaborationForbiddenException(
        'Enable cloud sync to invite members',
      );
    }

    final invitation = await _repository.reinviteInvitation(invitationId);
    CollaborationSimulator.inviteUser(
      name: invitation.fullName,
      role: invitation.role.displayLabel,
      contact: invitation.phoneOrEmail,
      invitationLink: invitation.inviteLink,
    );
    CollaborationSimulator.generateLink(link: invitation.inviteLink);
    return invitation;
  }

  String inviteLinkFor(Invitation invitation) => invitation.inviteLink;

  void shareViaWhatsApp(Invitation invitation) {
    CollaborationSimulator.shareWhatsApp(
      phone: invitation.phoneOrEmail,
      role: invitation.role.displayLabel,
      link: invitation.inviteLink,
    );
  }

  void shareViaEmail(Invitation invitation) {
    const subject = 'Invitation to collaborate on Billing Baba';
    final body =
        'You have been invited to collaborate on Billing Baba.\n\n'
        'Role: ${invitation.role.displayLabel}\n\n'
        'Invitation: ${invitation.inviteLink}';
    CollaborationSimulator.sendEmail(
      recipient: invitation.phoneOrEmail,
      subject: subject,
      body: body,
    );
  }

  void logCopyLink(Invitation invitation) {
    CollaborationSimulator.copyLink(link: invitation.inviteLink);
  }

  Future<void> _validateInviteTarget(
    String phoneOrEmail, {
    String? ignoreMemberId,
  }) async {
    final normalized = normalizeContact(phoneOrEmail);
    final self = normalizeContact(_context.currentUserPhone);
    final owner = normalizeContact(_context.ownerPhone);

    if (normalized == self) {
      throw const CollaborationValidationException(
        'You cannot invite yourself',
      );
    }

    if (normalized == owner) {
      throw const CollaborationValidationException(
        'The business owner already has access',
      );
    }

    final members = await _repository.fetchMembers();
    for (final member in members) {
      if (member.id == ignoreMemberId) continue;
      if (normalizeContact(member.phoneOrEmail) == normalized) {
        throw CollaborationValidationException(
          member.status == MemberStatus.joined
              ? 'A member with this contact already exists'
              : 'An invitation for this contact is already pending',
        );
      }
    }

    final invitations = await _repository.fetchInvitations();
    for (final invitation in invitations) {
      if (!invitation.status.isActive) continue;
      if (invitation.memberId == ignoreMemberId) continue;
      if (normalizeContact(invitation.phoneOrEmail) == normalized) {
        throw const CollaborationValidationException(
          'An invitation for this contact is already pending',
        );
      }
    }
  }

  void _validateMemberInput(String fullName, String phoneOrEmail) {
    final nameError = Validators.required(fullName, fieldName: 'Full name');
    if (nameError != null) {
      throw CollaborationValidationException(nameError);
    }

    final contact = phoneOrEmail.trim();
    if (contact.isEmpty) {
      throw const CollaborationValidationException(
        'Phone or email is required',
      );
    }

    if (contact.contains('@')) {
      final emailError = Validators.email(contact);
      if (emailError != null) {
        throw CollaborationValidationException(emailError);
      }
      return;
    }

    final digits = contact.replaceAll(RegExp(r'\D'), '');
    final localDigits = digits.length > 10 ? digits.substring(digits.length - 10) : digits;
    if (localDigits.length != 10) {
      throw const CollaborationValidationException(
        'Enter a valid 10-digit phone number or email address',
      );
    }
  }

  void _validateRole(Role role) {
    if (!Role.values.contains(role)) {
      throw const CollaborationValidationException('Invalid role selected');
    }
  }

  BusinessMember _findMember(List<BusinessMember> members, String id) {
    for (final member in members) {
      if (member.id == id) return member;
    }
    throw const CollaborationNotFoundException('Member not found');
  }

  void _assertNotOwner(BusinessMember member, {required String action}) {
    if (member.isOwner) {
      throw CollaborationForbiddenException(
        'Cannot $action the business owner',
      );
    }
    if (normalizeContact(member.phoneOrEmail) ==
        normalizeContact(_context.ownerPhone)) {
      throw CollaborationForbiddenException(
        'Cannot $action the business owner',
      );
    }
  }

  InviteMemberInput _formatInput(InviteMemberInput input) {
    return InviteMemberInput(
      fullName: input.fullName.trim(),
      phoneOrEmail: formatPhoneOrEmailContact(input.phoneOrEmail),
      role: input.role,
    );
  }

  UpdateMemberInput _formatUpdateInput(UpdateMemberInput input) {
    return UpdateMemberInput(
      fullName: input.fullName.trim(),
      phoneOrEmail: formatPhoneOrEmailContact(input.phoneOrEmail),
      role: input.role,
    );
  }
}
