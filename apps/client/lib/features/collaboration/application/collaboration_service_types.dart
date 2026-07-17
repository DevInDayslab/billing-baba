import 'package:billing_baba/features/collaboration/domain/models/role.dart';

/// Session context used for collaboration validations.
class CollaborationSessionContext {
  const CollaborationSessionContext({
    required this.currentUserPhone,
    required this.ownerPhone,
    required this.currentDeviceName,
  });

  final String currentUserPhone;
  final String ownerPhone;
  final String currentDeviceName;
}

/// Input for sending a member invitation.
class InviteMemberInput {
  const InviteMemberInput({
    required this.fullName,
    required this.phoneOrEmail,
    required this.role,
  });

  final String fullName;
  final String phoneOrEmail;
  final Role role;
}

/// Input for updating an existing business member.
class UpdateMemberInput {
  const UpdateMemberInput({
    required this.fullName,
    required this.phoneOrEmail,
    required this.role,
  });

  final String fullName;
  final String phoneOrEmail;
  final Role role;
}

class CollaborationValidationException implements Exception {
  const CollaborationValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CollaborationNotFoundException implements Exception {
  const CollaborationNotFoundException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CollaborationForbiddenException implements Exception {
  const CollaborationForbiddenException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CollaborationConflictException implements Exception {
  const CollaborationConflictException(this.message);

  final String message;

  @override
  String toString() => message;
}

String normalizeContact(String value) {
  final trimmed = value.trim().toLowerCase();
  if (trimmed.contains('@')) return trimmed;
  return trimmed.replaceAll(RegExp(r'\D'), '');
}
