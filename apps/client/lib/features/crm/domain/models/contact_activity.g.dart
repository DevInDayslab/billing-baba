// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContactActivity _$ContactActivityFromJson(Map<String, dynamic> json) =>
    _ContactActivity(
      id: json['id'] as String,
      contactId: json['contact_id'] as String,
      businessId: json['business_id'] as String,
      type: $enumDecode(_$ContactActivityTypeEnumMap, json['type']),
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

Map<String, dynamic> _$ContactActivityToJson(_ContactActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contact_id': instance.contactId,
      'business_id': instance.businessId,
      'type': _$ContactActivityTypeEnumMap[instance.type]!,
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

const _$ContactActivityTypeEnumMap = {
  ContactActivityType.call: 'call',
  ContactActivityType.email: 'email',
  ContactActivityType.meeting: 'meeting',
  ContactActivityType.note: 'note',
  ContactActivityType.statusChange: 'status_change',
};
