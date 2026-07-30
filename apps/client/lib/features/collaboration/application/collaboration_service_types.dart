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

/// Formats phone contacts as `+91 9876543210`. Emails are lowercased and trimmed.
String formatPhoneOrEmailContact(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return trimmed;
  if (trimmed.contains('@')) return trimmed.toLowerCase();

  var digits = trimmed.replaceAll(RegExp(r'\D'), '');

  if (digits.length == 11 && digits.startsWith('0')) {
    digits = digits.substring(1);
  }

  if (digits.length == 12 && digits.startsWith('91')) {
    digits = digits.substring(2);
  }

  if (digits.length == 10) {
    return '+91 $digits';
  }

  if (digits.length > 10 && digits.startsWith('91')) {
    final local = digits.substring(2);
    if (local.length == 10) {
      return '+91 $local';
    }
  }

  return trimmed.startsWith('+') ? trimmed : '+$digits';
}

/// Returns the last 10 digits from a phone contact string.
String localPhoneDigits(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length <= 10) return digits;
  return digits.substring(digits.length - 10);
}

/// Returns true when [value] looks like a phone number (not email).
bool isPhoneContact(String value) => !value.trim().contains('@');

final _apiInvitationIdPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  caseSensitive: false,
);

/// True for invitation IDs persisted by the collaboration API (plain UUID).
bool isApiInvitationId(String id) {
  if (id.startsWith('invite-') || id.startsWith('member-')) return false;
  return _apiInvitationIdPattern.hasMatch(id);
}
