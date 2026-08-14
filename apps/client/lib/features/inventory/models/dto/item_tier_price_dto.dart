import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_tier_price_dto.freezed.dart';
part 'item_tier_price_dto.g.dart';

@freezed
abstract class ItemTierPriceDto with _$ItemTierPriceDto {
  const factory ItemTierPriceDto({
    required String id,
    @JsonKey(name: 'item_id') required String itemId,
    @JsonKey(name: 'pricing_tier') required String pricingTier,
    required double price,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ItemTierPriceDto;

  factory ItemTierPriceDto.fromJson(Map<String, dynamic> json) =>
      _$ItemTierPriceDtoFromJson(json);
}
