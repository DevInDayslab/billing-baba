// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'godown_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GodownDto _$GodownDtoFromJson(Map<String, dynamic> json) => _GodownDto(
  id: json['id'] as String,
  name: json['name'] as String,
  isDefault: json['is_default'] as bool,
  stockItemCount: (json['stock_item_count'] as num).toInt(),
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  address: json['address'] as String?,
);

Map<String, dynamic> _$GodownDtoToJson(_GodownDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'is_default': instance.isDefault,
      'stock_item_count': instance.stockItemCount,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'address': instance.address,
    };
