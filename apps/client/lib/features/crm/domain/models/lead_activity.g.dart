// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeadActivity _$LeadActivityFromJson(Map<String, dynamic> json) =>
    _LeadActivity(
      id: json['id'] as String,
      leadId: json['lead_id'] as String,
      businessId: json['business_id'] as String,
      type: $enumDecode(_$LeadActivityTypeEnumMap, json['type']),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      notes: json['notes'] as String?,
      addedBy: json['added_by'] as String?,
      syncVersion: (json['sync_version'] as num?)?.toInt() ?? 1,
      isDeleted: json['is_deleted'] as bool? ?? false,
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      deviceId: json['device_id'] as String? ?? '',
      syncStatus: json['sync_status'] as String? ?? 'pending',
    );

Map<String, dynamic> _$LeadActivityToJson(_LeadActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lead_id': instance.leadId,
      'business_id': instance.businessId,
      'type': _$LeadActivityTypeEnumMap[instance.type]!,
      'updated_at': instance.updatedAt.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'notes': instance.notes,
      'added_by': instance.addedBy,
      'sync_version': instance.syncVersion,
      'is_deleted': instance.isDeleted,
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'device_id': instance.deviceId,
      'sync_status': instance.syncStatus,
    };

const _$LeadActivityTypeEnumMap = {
  LeadActivityType.call: 'call',
  LeadActivityType.email: 'email',
  LeadActivityType.meeting: 'meeting',
  LeadActivityType.note: 'note',
  LeadActivityType.statusChange: 'status_change',
};
