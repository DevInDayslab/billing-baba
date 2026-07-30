// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategorySummaryDto _$CategorySummaryDtoFromJson(Map<String, dynamic> json) =>
    _CategorySummaryDto(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$CategorySummaryDtoToJson(_CategorySummaryDto instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_BrandSummaryDto _$BrandSummaryDtoFromJson(Map<String, dynamic> json) =>
    _BrandSummaryDto(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$BrandSummaryDtoToJson(_BrandSummaryDto instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_BaseUnitSummaryDto _$BaseUnitSummaryDtoFromJson(Map<String, dynamic> json) =>
    _BaseUnitSummaryDto(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['short_name'] as String,
      symbol: json['symbol'] as String?,
    );

Map<String, dynamic> _$BaseUnitSummaryDtoToJson(_BaseUnitSummaryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'short_name': instance.shortName,
      'symbol': instance.symbol,
    };

_TierPriceDto _$TierPriceDtoFromJson(Map<String, dynamic> json) =>
    _TierPriceDto(
      pricingTier: json['pricing_tier'] as String,
      price: json['price'] as String,
    );

Map<String, dynamic> _$TierPriceDtoToJson(_TierPriceDto instance) =>
    <String, dynamic>{
      'pricing_tier': instance.pricingTier,
      'price': instance.price,
    };

_ItemImageDto _$ItemImageDtoFromJson(Map<String, dynamic> json) =>
    _ItemImageDto(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String,
      sortOrder: (json['sort_order'] as num).toInt(),
      isPrimary: json['is_primary'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      mediumUrl: json['medium_url'] as String?,
      mediaAssetId: json['media_asset_id'] as String?,
    );

Map<String, dynamic> _$ItemImageDtoToJson(_ItemImageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'image_url': instance.imageUrl,
      'sort_order': instance.sortOrder,
      'is_primary': instance.isPrimary,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'thumbnail_url': instance.thumbnailUrl,
      'medium_url': instance.mediumUrl,
      'media_asset_id': instance.mediaAssetId,
    };

_ItemLocationSummaryDto _$ItemLocationSummaryDtoFromJson(
  Map<String, dynamic> json,
) => _ItemLocationSummaryDto(
  id: json['id'] as String,
  godownId: json['godown_id'] as String,
  rack: json['rack'] as String?,
  shelf: json['shelf'] as String?,
);

Map<String, dynamic> _$ItemLocationSummaryDtoToJson(
  _ItemLocationSummaryDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'godown_id': instance.godownId,
  'rack': instance.rack,
  'shelf': instance.shelf,
};

_OpeningStockGodownDto _$OpeningStockGodownDtoFromJson(
  Map<String, dynamic> json,
) => _OpeningStockGodownDto(
  godownId: json['godown_id'] as String,
  godownName: json['godown_name'] as String,
  quantity: json['quantity'] as String,
);

Map<String, dynamic> _$OpeningStockGodownDtoToJson(
  _OpeningStockGodownDto instance,
) => <String, dynamic>{
  'godown_id': instance.godownId,
  'godown_name': instance.godownName,
  'quantity': instance.quantity,
};

_OpeningStockDto _$OpeningStockDtoFromJson(Map<String, dynamic> json) =>
    _OpeningStockDto(
      totalQuantity: json['total_quantity'] as String,
      godowns:
          (json['godowns'] as List<dynamic>?)
              ?.map(
                (e) =>
                    OpeningStockGodownDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$OpeningStockDtoToJson(_OpeningStockDto instance) =>
    <String, dynamic>{
      'total_quantity': instance.totalQuantity,
      'godowns': instance.godowns,
    };
