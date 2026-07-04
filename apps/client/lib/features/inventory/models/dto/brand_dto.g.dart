// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BrandDto _$BrandDtoFromJson(Map<String, dynamic> json) => _BrandDto(
  id: json['id'] as String,
  name: json['name'] as String,
  itemCount: (json['item_count'] as num).toInt(),
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$BrandDtoToJson(_BrandDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'item_count': instance.itemCount,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
