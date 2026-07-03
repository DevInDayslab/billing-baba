// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UnitListDto _$UnitListDtoFromJson(Map<String, dynamic> json) => _UnitListDto(
  id: json['id'] as String,
  name: json['name'] as String,
  shortName: json['short_name'] as String,
  decimalPlaces: (json['decimal_places'] as num).toInt(),
  isSystem: json['is_system'] as bool,
  isActive: json['is_active'] as bool,
  conversionCount: (json['conversion_count'] as num).toInt(),
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  symbol: json['symbol'] as String?,
);

Map<String, dynamic> _$UnitListDtoToJson(_UnitListDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'short_name': instance.shortName,
      'decimal_places': instance.decimalPlaces,
      'is_system': instance.isSystem,
      'is_active': instance.isActive,
      'conversion_count': instance.conversionCount,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'symbol': instance.symbol,
    };

_UnitDetailDto _$UnitDetailDtoFromJson(Map<String, dynamic> json) =>
    _UnitDetailDto(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['short_name'] as String,
      decimalPlaces: (json['decimal_places'] as num).toInt(),
      isSystem: json['is_system'] as bool,
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      symbol: json['symbol'] as String?,
      conversions:
          (json['conversions'] as List<dynamic>?)
              ?.map(
                (e) => UnitConversionDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UnitDetailDtoToJson(_UnitDetailDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'short_name': instance.shortName,
      'decimal_places': instance.decimalPlaces,
      'is_system': instance.isSystem,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'symbol': instance.symbol,
      'conversions': instance.conversions,
    };
