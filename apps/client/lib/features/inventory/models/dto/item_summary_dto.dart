import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_summary_dto.freezed.dart';
part 'item_summary_dto.g.dart';

@freezed
abstract class CategorySummaryDto with _$CategorySummaryDto {
  const factory CategorySummaryDto({
    required String id,
    required String name,
  }) = _CategorySummaryDto;

  factory CategorySummaryDto.fromJson(Map<String, dynamic> json) =>
      _$CategorySummaryDtoFromJson(json);
}

@freezed
abstract class BrandSummaryDto with _$BrandSummaryDto {
  const factory BrandSummaryDto({
    required String id,
    required String name,
  }) = _BrandSummaryDto;

  factory BrandSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$BrandSummaryDtoFromJson(json);
}

@freezed
abstract class BaseUnitSummaryDto with _$BaseUnitSummaryDto {
  const factory BaseUnitSummaryDto({
    required String id,
    required String name,
    @JsonKey(name: 'short_name') required String shortName,
    String? symbol,
  }) = _BaseUnitSummaryDto;

  factory BaseUnitSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$BaseUnitSummaryDtoFromJson(json);
}

@freezed
abstract class TierPriceDto with _$TierPriceDto {
  const factory TierPriceDto({
    @JsonKey(name: 'pricing_tier') required String pricingTier,
    required String price,
  }) = _TierPriceDto;

  factory TierPriceDto.fromJson(Map<String, dynamic> json) =>
      _$TierPriceDtoFromJson(json);
}

@freezed
abstract class ItemImageDto with _$ItemImageDto {
  const factory ItemImageDto({
    required String id,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'sort_order') required int sortOrder,
    @JsonKey(name: 'is_primary') required bool isPrimary,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _ItemImageDto;

  factory ItemImageDto.fromJson(Map<String, dynamic> json) =>
      _$ItemImageDtoFromJson(json);
}

@freezed
abstract class ItemLocationSummaryDto with _$ItemLocationSummaryDto {
  const factory ItemLocationSummaryDto({
    required String id,
    @JsonKey(name: 'godown_id') required String godownId,
    String? rack,
    String? shelf,
  }) = _ItemLocationSummaryDto;

  factory ItemLocationSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$ItemLocationSummaryDtoFromJson(json);
}

@freezed
abstract class OpeningStockGodownDto with _$OpeningStockGodownDto {
  const factory OpeningStockGodownDto({
    @JsonKey(name: 'godown_id') required String godownId,
    @JsonKey(name: 'godown_name') required String godownName,
    required String quantity,
  }) = _OpeningStockGodownDto;

  factory OpeningStockGodownDto.fromJson(Map<String, dynamic> json) =>
      _$OpeningStockGodownDtoFromJson(json);
}

@freezed
abstract class OpeningStockDto with _$OpeningStockDto {
  const factory OpeningStockDto({
    @JsonKey(name: 'total_quantity') required String totalQuantity,
    @Default([]) List<OpeningStockGodownDto> godowns,
  }) = _OpeningStockDto;

  factory OpeningStockDto.fromJson(Map<String, dynamic> json) =>
      _$OpeningStockDtoFromJson(json);
}
