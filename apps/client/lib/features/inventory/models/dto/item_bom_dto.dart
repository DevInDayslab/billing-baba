import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_bom_dto.freezed.dart';
part 'item_bom_dto.g.dart';

@freezed
abstract class ItemBomRawItemDto with _$ItemBomRawItemDto {
  const factory ItemBomRawItemDto({
    required String id,
    required String name,
    @JsonKey(name: 'base_unit') required String baseUnit,
    @JsonKey(name: 'purchase_price') @Default('0') String purchasePrice,
  }) = _ItemBomRawItemDto;

  factory ItemBomRawItemDto.fromJson(Map<String, dynamic> json) =>
      _$ItemBomRawItemDtoFromJson(json);
}

@freezed
abstract class ItemBomMaterialDto with _$ItemBomMaterialDto {
  const factory ItemBomMaterialDto({
    required String id,
    @JsonKey(name: 'item_id') required String itemId,
    @JsonKey(name: 'raw_item_id') required String rawItemId,
    required String qty,
    @JsonKey(name: 'unit_id') required String unitId,
    @JsonKey(name: 'purchase_price') @Default('0') String purchasePrice,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'raw_item') ItemBomRawItemDto? rawItem,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ItemBomMaterialDto;

  factory ItemBomMaterialDto.fromJson(Map<String, dynamic> json) =>
      _$ItemBomMaterialDtoFromJson(json);
}

@freezed
abstract class ItemBomCostDto with _$ItemBomCostDto {
  const factory ItemBomCostDto({
    required String id,
    @JsonKey(name: 'item_id') required String itemId,
    required String description,
    @Default('0') String amount,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ItemBomCostDto;

  factory ItemBomCostDto.fromJson(Map<String, dynamic> json) =>
      _$ItemBomCostDtoFromJson(json);
}

@freezed
abstract class ItemBomDto with _$ItemBomDto {
  const factory ItemBomDto({
    @Default([]) List<ItemBomMaterialDto> materials,
    @Default([]) List<ItemBomCostDto> costs,
  }) = _ItemBomDto;

  factory ItemBomDto.fromJson(Map<String, dynamic> json) =>
      _$ItemBomDtoFromJson(json);
}
