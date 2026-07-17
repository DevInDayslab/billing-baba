import 'package:freezed_annotation/freezed_annotation.dart';

enum MemberStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('joined')
  joined,
}

extension MemberStatusX on MemberStatus {
  String get displayLabel => switch (this) {
    MemberStatus.pending => 'Pending',
    MemberStatus.joined => 'Joined',
  };
}
