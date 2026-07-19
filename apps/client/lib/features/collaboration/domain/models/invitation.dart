import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'invitation.freezed.dart';
part 'invitation.g.dart';

enum InvitationChannel {
  @JsonValue('sms')
  sms,
  @JsonValue('whatsapp')
  whatsapp,
  @JsonValue('email')
  email,
}

enum InvitationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('opened')
  opened,
  @JsonValue('accepted')
  accepted,
  @JsonValue('expired')
  expired,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('rejected')
  rejected,
  @JsonValue('left')
  left,
}

extension InvitationStatusX on InvitationStatus {
  String get displayLabel => switch (this) {
    InvitationStatus.pending => 'Pending',
    InvitationStatus.opened => 'Pending',
    InvitationStatus.accepted => 'Accepted',
    InvitationStatus.expired => 'Expired',
    InvitationStatus.cancelled => 'Cancelled',
    InvitationStatus.rejected => 'Rejected',
    InvitationStatus.left => 'Left',
  };

  bool get isActive =>
      this == InvitationStatus.pending || this == InvitationStatus.opened;

  bool get isPollable =>
      this == InvitationStatus.pending || this == InvitationStatus.opened;

  bool get isTerminal =>
      this == InvitationStatus.accepted ||
      this == InvitationStatus.rejected ||
      this == InvitationStatus.left ||
      this == InvitationStatus.expired ||
      this == InvitationStatus.cancelled;
}

@freezed
abstract class Invitation with _$Invitation {
  const factory Invitation({
    required String id,
    @JsonKey(name: 'invite_code') required String inviteCode,
    @JsonKey(name: 'member_id') required String memberId,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'phone_or_email') required String phoneOrEmail,
    required Role role,
    required InvitationChannel channel,
    @JsonKey(name: 'sent_at') required DateTime sentAt,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
    required InvitationStatus status,
  }) = _Invitation;

  factory Invitation.fromJson(Map<String, dynamic> json) =>
      _$InvitationFromJson(json);
}

extension InvitationX on Invitation {
  String get inviteLink => AppConfig.inviteLinkForCode(inviteCode);

  bool get isExpired =>
      status == InvitationStatus.expired ||
      ((status == InvitationStatus.pending ||
              status == InvitationStatus.opened) &&
          DateTime.now().isAfter(expiresAt));
}
