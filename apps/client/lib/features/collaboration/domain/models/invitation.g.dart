// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Invitation _$InvitationFromJson(Map<String, dynamic> json) => _Invitation(
  id: json['id'] as String,
  inviteCode: json['invite_code'] as String,
  memberId: json['member_id'] as String,
  fullName: json['full_name'] as String,
  phoneOrEmail: json['phone_or_email'] as String,
  role: $enumDecode(_$RoleEnumMap, json['role']),
  channel: $enumDecode(_$InvitationChannelEnumMap, json['channel']),
  sentAt: DateTime.parse(json['sent_at'] as String),
  expiresAt: DateTime.parse(json['expires_at'] as String),
  status: $enumDecode(_$InvitationStatusEnumMap, json['status']),
);

Map<String, dynamic> _$InvitationToJson(_Invitation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invite_code': instance.inviteCode,
      'member_id': instance.memberId,
      'full_name': instance.fullName,
      'phone_or_email': instance.phoneOrEmail,
      'role': _$RoleEnumMap[instance.role]!,
      'channel': _$InvitationChannelEnumMap[instance.channel]!,
      'sent_at': instance.sentAt.toIso8601String(),
      'expires_at': instance.expiresAt.toIso8601String(),
      'status': _$InvitationStatusEnumMap[instance.status]!,
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

const _$InvitationChannelEnumMap = {
  InvitationChannel.sms: 'sms',
  InvitationChannel.whatsapp: 'whatsapp',
  InvitationChannel.email: 'email',
};

const _$InvitationStatusEnumMap = {
  InvitationStatus.pending: 'pending',
  InvitationStatus.opened: 'opened',
  InvitationStatus.accepted: 'accepted',
  InvitationStatus.expired: 'expired',
  InvitationStatus.cancelled: 'cancelled',
  InvitationStatus.rejected: 'rejected',
  InvitationStatus.left: 'left',
};
