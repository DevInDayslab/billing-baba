// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_supplier_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemSupplierDto _$ItemSupplierDtoFromJson(Map<String, dynamic> json) =>
    _ItemSupplierDto(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      partyId: json['party_id'] as String,
      isDefault: json['is_default'] as bool? ?? false,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$ItemSupplierDtoToJson(_ItemSupplierDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_id': instance.itemId,
      'party_id': instance.partyId,
      'is_default': instance.isDefault,
      'sort_order': instance.sortOrder,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
