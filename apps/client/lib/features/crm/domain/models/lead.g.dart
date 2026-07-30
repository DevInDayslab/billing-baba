// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Lead _$LeadFromJson(Map<String, dynamic> json) => _Lead(
  id: json['id'] as String,
  businessId: json['business_id'] as String,
  name: json['name'] as String,
  updatedAt: DateTime.parse(json['updated_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  company: json['company'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  leadSource: $enumDecodeNullable(_$LeadSourceEnumMap, json['lead_source']),
  status:
      $enumDecodeNullable(_$LeadStatusEnumMap, json['status']) ??
      LeadStatus.newLead,
  assignedTo: json['assigned_to'] as String?,
  notes: json['notes'] as String?,
  syncVersion: (json['sync_version'] as num?)?.toInt() ?? 1,
  isDeleted: json['is_deleted'] as bool? ?? false,
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
  deviceId: json['device_id'] as String? ?? '',
  syncStatus: json['sync_status'] as String? ?? 'pending',
);

Map<String, dynamic> _$LeadToJson(_Lead instance) => <String, dynamic>{
  'id': instance.id,
  'business_id': instance.businessId,
  'name': instance.name,
  'updated_at': instance.updatedAt.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'company': instance.company,
  'phone': instance.phone,
  'email': instance.email,
  'lead_source': _$LeadSourceEnumMap[instance.leadSource],
  'status': _$LeadStatusEnumMap[instance.status]!,
  'assigned_to': instance.assignedTo,
  'notes': instance.notes,
  'sync_version': instance.syncVersion,
  'is_deleted': instance.isDeleted,
  'deleted_at': instance.deletedAt?.toIso8601String(),
  'device_id': instance.deviceId,
  'sync_status': instance.syncStatus,
};

const _$LeadSourceEnumMap = {
  LeadSource.googleAds: 'google_ads',
  LeadSource.referral: 'referral',
  LeadSource.website: 'website',
  LeadSource.walkIn: 'walk_in',
  LeadSource.other: 'other',
};

const _$LeadStatusEnumMap = {
  LeadStatus.newLead: 'new',
  LeadStatus.contacted: 'contacted',
  LeadStatus.qualified: 'qualified',
  LeadStatus.converted: 'converted',
  LeadStatus.lost: 'lost',
};
