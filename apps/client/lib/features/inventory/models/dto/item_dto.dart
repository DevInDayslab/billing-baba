import 'package:billing_baba/features/inventory/models/dto/item_summary_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_dto.freezed.dart';
part 'item_dto.g.dart';

@freezed
abstract class ItemListDto with _$ItemListDto {
  const factory ItemListDto({
    required String id,
    required String name,
    @JsonKey(name: 'item_type') required String itemType,
    @JsonKey(name: 'has_stock_tracking') required bool hasStockTracking,
    @JsonKey(name: 'base_unit') required String baseUnit,
    @JsonKey(name: 'sale_price') required String salePrice,
    @JsonKey(name: 'purchase_price') required String purchasePrice,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    String? description,
    @JsonKey(name: 'category_id') String? categoryId,
    CategorySummaryDto? category,
    @JsonKey(name: 'brand_id') String? brandId,
    BrandSummaryDto? brand,
    @JsonKey(name: 'hsn_code') String? hsnCode,
    String? barcode,
    @JsonKey(name: 'base_unit_detail') BaseUnitSummaryDto? baseUnitDetail,
    String? mrp,
    @JsonKey(name: 'market_price') String? marketPrice,
    @JsonKey(name: 'reorder_level') String? reorderLevel,
    @JsonKey(name: 'primary_image_url') String? primaryImageUrl,
    String? quantity,
    @JsonKey(name: 'reserved_quantity') String? reservedQuantity,
    @JsonKey(name: 'available_for_sale') String? availableForSale,
  }) = _ItemListDto;

  factory ItemListDto.fromJson(Map<String, dynamic> json) =>
      _$ItemListDtoFromJson(json);
}

@freezed
abstract class ItemDetailDto with _$ItemDetailDto {
  const factory ItemDetailDto({
    required String id,
    required String name,
    @JsonKey(name: 'item_type') required String itemType,
    @JsonKey(name: 'has_stock_tracking') required bool hasStockTracking,
    @JsonKey(name: 'base_unit') required String baseUnit,
    @JsonKey(name: 'sale_price') required String salePrice,
    @JsonKey(name: 'purchase_price') required String purchasePrice,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    String? description,
    @JsonKey(name: 'category_id') String? categoryId,
    CategorySummaryDto? category,
    @JsonKey(name: 'brand_id') String? brandId,
    BrandSummaryDto? brand,
    @JsonKey(name: 'hsn_code') String? hsnCode,
    String? barcode,
    @JsonKey(name: 'base_unit_detail') BaseUnitSummaryDto? baseUnitDetail,
    String? mrp,
    @JsonKey(name: 'market_price') String? marketPrice,
    @JsonKey(name: 'reorder_level') String? reorderLevel,
    @JsonKey(name: 'primary_image_url') String? primaryImageUrl,
    String? quantity,
    @JsonKey(name: 'reserved_quantity') String? reservedQuantity,
    @JsonKey(name: 'available_for_sale') String? availableForSale,
    @JsonKey(name: 'tier_prices') @Default([]) List<TierPriceDto> tierPrices,
    @Default([]) List<ItemImageDto> images,
    @Default([]) List<ItemLocationSummaryDto> locations,
    @JsonKey(name: 'opening_stock') OpeningStockDto? openingStock,
  }) = _ItemDetailDto;

  factory ItemDetailDto.fromJson(Map<String, dynamic> json) =>
      _$ItemDetailDtoFromJson(json);
}

class PaginatedItemsDto {
  const PaginatedItemsDto({
    required this.items,
    required this.meta,
  });

  factory PaginatedItemsDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    return PaginatedItemsDto(
      items: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(ItemListDto.fromJson)
                .toList()
          : const [],
      meta: meta is Map<String, dynamic>
          ? PaginationMetaDto.fromJson(meta)
          : const PaginationMetaDto(page: 1, limit: 20, total: 0),
    );
  }

  final List<ItemListDto> items;
  final PaginationMetaDto meta;
}
