import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_supplier_dto.freezed.dart';
part 'item_supplier_dto.g.dart';

@freezed
abstract class ItemSupplierDto with _$ItemSupplierDto {
  const factory ItemSupplierDto({
    required String id,
    @JsonKey(name: 'item_id') required String itemId,
    @JsonKey(name: 'party_id') required String partyId,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ItemSupplierDto;

  factory ItemSupplierDto.fromJson(Map<String, dynamic> json) =>
      _$ItemSupplierDtoFromJson(json);
}
