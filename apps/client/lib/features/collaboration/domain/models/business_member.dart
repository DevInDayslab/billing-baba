import 'package:billing_baba/features/collaboration/domain/models/member_status.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'business_member.freezed.dart';
part 'business_member.g.dart';

@freezed
abstract class BusinessMember with _$BusinessMember {
  const factory BusinessMember({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'phone_or_email') required String phoneOrEmail,
    required MemberStatus status,
    required Role role,
    @JsonKey(name: 'invited_at') required DateTime invitedAt, @JsonKey(name: 'is_owner') @Default(false) bool isOwner,
    @JsonKey(name: 'is_current_user') @Default(false) bool isCurrentUser,
    @JsonKey(name: 'invitation_id') String? invitationId,
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
  }) = _BusinessMember;

  factory BusinessMember.fromJson(Map<String, dynamic> json) =>
      _$BusinessMemberFromJson(json);
}
