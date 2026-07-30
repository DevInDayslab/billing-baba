import 'package:freezed_annotation/freezed_annotation.dart';

enum MemberStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('joined')
  joined,
  @JsonValue('left')
  left,
  @JsonValue('rejected')
  rejected,
  @JsonValue('expired')
  expired,
  @JsonValue('cancelled')
  cancelled,
}

extension MemberStatusX on MemberStatus {
  String get displayLabel => switch (this) {
    MemberStatus.pending => 'Pending',
    MemberStatus.joined => 'Joined',
    MemberStatus.left => 'Left',
    MemberStatus.rejected => 'Rejected',
    MemberStatus.expired => 'Expired',
    MemberStatus.cancelled => 'Cancelled',
  };

  bool get isPending => this == MemberStatus.pending;

  bool get isJoined => this == MemberStatus.joined;

  bool get isTerminal =>
      this == MemberStatus.joined ||
      this == MemberStatus.left ||
      this == MemberStatus.rejected ||
      this == MemberStatus.expired ||
      this == MemberStatus.cancelled;

  bool get canReinvite =>
      this == MemberStatus.left ||
      this == MemberStatus.rejected ||
      this == MemberStatus.expired ||
      this == MemberStatus.cancelled;
}
