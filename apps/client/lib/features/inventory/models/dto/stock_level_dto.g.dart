// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_level_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StockLevelDto _$StockLevelDtoFromJson(Map<String, dynamic> json) =>
    _StockLevelDto(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      itemName: json['item_name'] as String,
      godownId: json['godown_id'] as String,
      godownName: json['godown_name'] as String,
      quantity: json['quantity'] as String,
      averageCost: json['average_cost'] as String,
      isLowStock: json['is_low_stock'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      reorderLevel: json['reorder_level'] as String?,
    );

Map<String, dynamic> _$StockLevelDtoToJson(_StockLevelDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_id': instance.itemId,
      'item_name': instance.itemName,
      'godown_id': instance.godownId,
      'godown_name': instance.godownName,
      'quantity': instance.quantity,
      'average_cost': instance.averageCost,
      'is_low_stock': instance.isLowStock,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'reorder_level': instance.reorderLevel,
    };
