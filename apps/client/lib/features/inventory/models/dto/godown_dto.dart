import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'godown_dto.freezed.dart';
part 'godown_dto.g.dart';

@freezed
abstract class GodownDto with _$GodownDto {
  const factory GodownDto({
    required String id,
    required String name,
    @JsonKey(name: 'is_default') required bool isDefault, @JsonKey(name: 'stock_item_count') required int stockItemCount, @JsonKey(name: 'created_at') required String createdAt, @JsonKey(name: 'updated_at') required String updatedAt, String? address,
  }) = _GodownDto;

  factory GodownDto.fromJson(Map<String, dynamic> json) =>
      _$GodownDtoFromJson(json);
}

class PaginatedGodownsDto {
  const PaginatedGodownsDto({
    required this.godowns,
    required this.meta,
  });

  factory PaginatedGodownsDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    return PaginatedGodownsDto(
      godowns: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(GodownDto.fromJson)
                .toList()
          : const [],
      meta: meta is Map<String, dynamic>
          ? PaginationMetaDto.fromJson(meta)
          : const PaginationMetaDto(page: 1, limit: 20, total: 0),
    );
  }

  final List<GodownDto> godowns;
  final PaginationMetaDto meta;
}
