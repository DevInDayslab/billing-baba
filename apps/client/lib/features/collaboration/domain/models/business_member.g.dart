// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BusinessMember _$BusinessMemberFromJson(Map<String, dynamic> json) =>
    _BusinessMember(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phoneOrEmail: json['phone_or_email'] as String,
      status: $enumDecode(_$MemberStatusEnumMap, json['status']),
      role: $enumDecode(_$RoleEnumMap, json['role']),
      invitedAt: DateTime.parse(json['invited_at'] as String),
      isOwner: json['is_owner'] as bool? ?? false,
      isCurrentUser: json['is_current_user'] as bool? ?? false,
      invitationId: json['invitation_id'] as String?,
      joinedAt: json['joined_at'] == null
          ? null
          : DateTime.parse(json['joined_at'] as String),
    );

Map<String, dynamic> _$BusinessMemberToJson(_BusinessMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'phone_or_email': instance.phoneOrEmail,
      'status': _$MemberStatusEnumMap[instance.status]!,
      'role': _$RoleEnumMap[instance.role]!,
      'invited_at': instance.invitedAt.toIso8601String(),
      'is_owner': instance.isOwner,
      'is_current_user': instance.isCurrentUser,
      'invitation_id': instance.invitationId,
      'joined_at': instance.joinedAt?.toIso8601String(),
    };

const _$MemberStatusEnumMap = {
  MemberStatus.pending: 'pending',
  MemberStatus.joined: 'joined',
  MemberStatus.left: 'left',
  MemberStatus.rejected: 'rejected',
  MemberStatus.expired: 'expired',
  MemberStatus.cancelled: 'cancelled',
};

const _$RoleEnumMap = {
  Role.secondaryAdmin: 'secondary_admin',
  Role.salesman: 'salesman',
  Role.biller: 'biller',
  Role.billerAndSalesman: 'biller_and_salesman',
  Role.accountant: 'accountant',
  Role.stockKeeper: 'stock_keeper',
  Role.accountantEditAccess: 'accountant_edit_access',
};
