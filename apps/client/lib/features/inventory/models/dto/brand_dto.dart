import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'brand_dto.freezed.dart';
part 'brand_dto.g.dart';

@freezed
abstract class BrandDto with _$BrandDto {
  const factory BrandDto({
    required String id,
    required String name,
    @JsonKey(name: 'item_count') required int itemCount,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _BrandDto;

  factory BrandDto.fromJson(Map<String, dynamic> json) =>
      _$BrandDtoFromJson(json);
}

class PaginatedBrandsDto {
  const PaginatedBrandsDto({
    required this.brands,
    required this.meta,
  });

  factory PaginatedBrandsDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    return PaginatedBrandsDto(
      brands: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(BrandDto.fromJson)
                .toList()
          : const [],
      meta: meta is Map<String, dynamic>
          ? PaginationMetaDto.fromJson(meta)
          : const PaginationMetaDto(page: 1, limit: 20, total: 0),
    );
  }

  final List<BrandDto> brands;
  final PaginationMetaDto meta;
}
