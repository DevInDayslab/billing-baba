// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_history_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PriceHistoryDto _$PriceHistoryDtoFromJson(Map<String, dynamic> json) =>
    _PriceHistoryDto(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      itemName: json['item_name'] as String,
      price: json['price'] as String,
      createdAt: json['created_at'] as String,
      pricingTier: json['pricing_tier'] as String?,
      changedBy: json['changed_by'] as String?,
    );

Map<String, dynamic> _$PriceHistoryDtoToJson(_PriceHistoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_id': instance.itemId,
      'item_name': instance.itemName,
      'price': instance.price,
      'created_at': instance.createdAt,
      'pricing_tier': instance.pricingTier,
      'changed_by': instance.changedBy,
    };
