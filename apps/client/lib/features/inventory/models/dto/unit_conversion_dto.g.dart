// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_conversion_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UnitConversionDto _$UnitConversionDtoFromJson(Map<String, dynamic> json) =>
    _UnitConversionDto(
      id: json['id'] as String,
      fromUnitId: json['from_unit_id'] as String,
      toUnitId: json['to_unit_id'] as String,
      conversionFactor: json['conversion_factor'] as String,
      label: json['label'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      fromUnitName: json['from_unit_name'] as String?,
      toUnitName: json['to_unit_name'] as String?,
    );

Map<String, dynamic> _$UnitConversionDtoToJson(_UnitConversionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'from_unit_id': instance.fromUnitId,
      'to_unit_id': instance.toUnitId,
      'conversion_factor': instance.conversionFactor,
      'label': instance.label,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'from_unit_name': instance.fromUnitName,
      'to_unit_name': instance.toUnitName,
    };
