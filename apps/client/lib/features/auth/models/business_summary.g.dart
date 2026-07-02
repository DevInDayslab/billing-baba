// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BusinessSummary _$BusinessSummaryFromJson(Map<String, dynamic> json) =>
    _BusinessSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      gstin: json['gstin'] as String?,
    );

Map<String, dynamic> _$BusinessSummaryToJson(_BusinessSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'role': instance.role,
      'gstin': instance.gstin,
    };
