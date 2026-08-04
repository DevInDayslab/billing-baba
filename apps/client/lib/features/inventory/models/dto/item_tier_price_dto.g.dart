// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_tier_price_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemTierPriceDto _$ItemTierPriceDtoFromJson(Map<String, dynamic> json) =>
    _ItemTierPriceDto(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      pricingTier: json['pricing_tier'] as String,
      price: (json['price'] as num).toDouble(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$ItemTierPriceDtoToJson(_ItemTierPriceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_id': instance.itemId,
      'pricing_tier': instance.pricingTier,
      'price': instance.price,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
