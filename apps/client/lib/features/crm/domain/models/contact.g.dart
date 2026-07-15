// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Contact _$ContactFromJson(Map<String, dynamic> json) => _Contact(
  id: json['id'] as String,
  businessId: json['business_id'] as String,
  name: json['name'] as String,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  salutation: json['salutation'] as String?,
  accountName: json['account_name'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  assignedTo: json['assigned_to'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  syncVersion: (json['sync_version'] as num?)?.toInt() ?? 1,
  isDeleted: json['is_deleted'] as bool? ?? false,
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
  deviceId: json['device_id'] as String? ?? '',
  syncStatus: json['sync_status'] as String? ?? 'pending',
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ContactToJson(_Contact instance) => <String, dynamic>{
  'id': instance.id,
  'business_id': instance.businessId,
  'name': instance.name,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'salutation': instance.salutation,
  'account_name': instance.accountName,
  'phone': instance.phone,
  'email': instance.email,
  'assigned_to': instance.assignedTo,
  'title': instance.title,
  'description': instance.description,
  'sync_version': instance.syncVersion,
  'is_deleted': instance.isDeleted,
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
  'device_id': instance.deviceId,
  'sync_status': instance.syncStatus,
  'created_at': instance.createdAt.toIso8601String(),
};
