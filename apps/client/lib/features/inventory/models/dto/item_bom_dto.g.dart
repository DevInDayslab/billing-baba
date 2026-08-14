// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_bom_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemBomRawItemDto _$ItemBomRawItemDtoFromJson(Map<String, dynamic> json) =>
    _ItemBomRawItemDto(
      id: json['id'] as String,
      name: json['name'] as String,
      baseUnit: json['base_unit'] as String,
      purchasePrice: json['purchase_price'] as String? ?? '0',
    );

Map<String, dynamic> _$ItemBomRawItemDtoToJson(_ItemBomRawItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'base_unit': instance.baseUnit,
      'purchase_price': instance.purchasePrice,
    };

_ItemBomMaterialDto _$ItemBomMaterialDtoFromJson(Map<String, dynamic> json) =>
    _ItemBomMaterialDto(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      rawItemId: json['raw_item_id'] as String,
      qty: json['qty'] as String,
      unitId: json['unit_id'] as String,
      purchasePrice: json['purchase_price'] as String? ?? '0',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      rawItem: json['raw_item'] == null
          ? null
          : ItemBomRawItemDto.fromJson(
              json['raw_item'] as Map<String, dynamic>,
            ),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$ItemBomMaterialDtoToJson(_ItemBomMaterialDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_id': instance.itemId,
      'raw_item_id': instance.rawItemId,
      'qty': instance.qty,
      'unit_id': instance.unitId,
      'purchase_price': instance.purchasePrice,
      'sort_order': instance.sortOrder,
      'raw_item': instance.rawItem,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_ItemBomCostDto _$ItemBomCostDtoFromJson(Map<String, dynamic> json) =>
    _ItemBomCostDto(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      description: json['description'] as String,
      amount: json['amount'] as String? ?? '0',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$ItemBomCostDtoToJson(_ItemBomCostDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_id': instance.itemId,
      'description': instance.description,
      'amount': instance.amount,
      'sort_order': instance.sortOrder,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_ItemBomDto _$ItemBomDtoFromJson(Map<String, dynamic> json) => _ItemBomDto(
  materials:
      (json['materials'] as List<dynamic>?)
          ?.map((e) => ItemBomMaterialDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  costs:
      (json['costs'] as List<dynamic>?)
          ?.map((e) => ItemBomCostDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ItemBomDtoToJson(_ItemBomDto instance) =>
    <String, dynamic>{'materials': instance.materials, 'costs': instance.costs};
