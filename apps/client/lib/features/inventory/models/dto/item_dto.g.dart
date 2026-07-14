// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemListDto _$ItemListDtoFromJson(Map<String, dynamic> json) => _ItemListDto(
  id: json['id'] as String,
  name: json['name'] as String,
  itemType: json['item_type'] as String,
  hasStockTracking: json['has_stock_tracking'] as bool,
  baseUnit: json['base_unit'] as String,
  salePrice: json['sale_price'] as String,
  purchasePrice: json['purchase_price'] as String,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  description: json['description'] as String?,
  categoryId: json['category_id'] as String?,
  category: json['category'] == null
      ? null
      : CategorySummaryDto.fromJson(json['category'] as Map<String, dynamic>),
  brandId: json['brand_id'] as String?,
  brand: json['brand'] == null
      ? null
      : BrandSummaryDto.fromJson(json['brand'] as Map<String, dynamic>),
  hsnCode: json['hsn_code'] as String?,
  barcode: json['barcode'] as String?,
  baseUnitDetail: json['base_unit_detail'] == null
      ? null
      : BaseUnitSummaryDto.fromJson(
          json['base_unit_detail'] as Map<String, dynamic>,
        ),
  mrp: json['mrp'] as String?,
  marketPrice: json['market_price'] as String?,
  reorderLevel: json['reorder_level'] as String?,
  primaryImageUrl: json['primary_image_url'] as String?,
  quantity: json['quantity'] as String?,
  reservedQuantity: json['reserved_quantity'] as String?,
  availableForSale: json['available_for_sale'] as String?,
);

Map<String, dynamic> _$ItemListDtoToJson(_ItemListDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'item_type': instance.itemType,
      'has_stock_tracking': instance.hasStockTracking,
      'base_unit': instance.baseUnit,
      'sale_price': instance.salePrice,
      'purchase_price': instance.purchasePrice,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'description': instance.description,
      'category_id': instance.categoryId,
      'category': instance.category,
      'brand_id': instance.brandId,
      'brand': instance.brand,
      'hsn_code': instance.hsnCode,
      'barcode': instance.barcode,
      'base_unit_detail': instance.baseUnitDetail,
      'mrp': instance.mrp,
      'market_price': instance.marketPrice,
      'reorder_level': instance.reorderLevel,
      'primary_image_url': instance.primaryImageUrl,
      'quantity': instance.quantity,
      'reserved_quantity': instance.reservedQuantity,
      'available_for_sale': instance.availableForSale,
    };

_ItemDetailDto _$ItemDetailDtoFromJson(
  Map<String, dynamic> json,
) => _ItemDetailDto(
  id: json['id'] as String,
  name: json['name'] as String,
  itemType: json['item_type'] as String,
  hasStockTracking: json['has_stock_tracking'] as bool,
  baseUnit: json['base_unit'] as String,
  salePrice: json['sale_price'] as String,
  purchasePrice: json['purchase_price'] as String,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  description: json['description'] as String?,
  categoryId: json['category_id'] as String?,
  category: json['category'] == null
      ? null
      : CategorySummaryDto.fromJson(json['category'] as Map<String, dynamic>),
  brandId: json['brand_id'] as String?,
  brand: json['brand'] == null
      ? null
      : BrandSummaryDto.fromJson(json['brand'] as Map<String, dynamic>),
  hsnCode: json['hsn_code'] as String?,
  barcode: json['barcode'] as String?,
  baseUnitDetail: json['base_unit_detail'] == null
      ? null
      : BaseUnitSummaryDto.fromJson(
          json['base_unit_detail'] as Map<String, dynamic>,
        ),
  mrp: json['mrp'] as String?,
  marketPrice: json['market_price'] as String?,
  reorderLevel: json['reorder_level'] as String?,
  primaryImageUrl: json['primary_image_url'] as String?,
  quantity: json['quantity'] as String?,
  reservedQuantity: json['reserved_quantity'] as String?,
  availableForSale: json['available_for_sale'] as String?,
  tierPrices:
      (json['tier_prices'] as List<dynamic>?)
          ?.map((e) => TierPriceDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => ItemImageDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  locations:
      (json['locations'] as List<dynamic>?)
          ?.map(
            (e) => ItemLocationSummaryDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  openingStock: json['opening_stock'] == null
      ? null
      : OpeningStockDto.fromJson(json['opening_stock'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ItemDetailDtoToJson(_ItemDetailDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'item_type': instance.itemType,
      'has_stock_tracking': instance.hasStockTracking,
      'base_unit': instance.baseUnit,
      'sale_price': instance.salePrice,
      'purchase_price': instance.purchasePrice,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'description': instance.description,
      'category_id': instance.categoryId,
      'category': instance.category,
      'brand_id': instance.brandId,
      'brand': instance.brand,
      'hsn_code': instance.hsnCode,
      'barcode': instance.barcode,
      'base_unit_detail': instance.baseUnitDetail,
      'mrp': instance.mrp,
      'market_price': instance.marketPrice,
      'reorder_level': instance.reorderLevel,
      'primary_image_url': instance.primaryImageUrl,
      'quantity': instance.quantity,
      'reserved_quantity': instance.reservedQuantity,
      'available_for_sale': instance.availableForSale,
      'tier_prices': instance.tierPrices,
      'images': instance.images,
      'locations': instance.locations,
      'opening_stock': instance.openingStock,
    };
