import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_location_dto.freezed.dart';
part 'item_location_dto.g.dart';

@freezed
abstract class ItemLocationDto with _$ItemLocationDto {
  const factory ItemLocationDto({
    required String id,
    @JsonKey(name: 'item_id') required String itemId,
    @JsonKey(name: 'godown_id') required String godownId,
    @JsonKey(name: 'created_at') required String createdAt, @JsonKey(name: 'updated_at') required String updatedAt, String? rack,
    String? shelf,
    @JsonKey(name: 'photo_url') String? photoUrl,
    @JsonKey(name: 'photo_taken_at') String? photoTakenAt,
  }) = _ItemLocationDto;

  factory ItemLocationDto.fromJson(Map<String, dynamic> json) =>
      _$ItemLocationDtoFromJson(json);
}

class PaginatedItemLocationsDto {
  const PaginatedItemLocationsDto({
    required this.locations,
    required this.meta,
  });

  factory PaginatedItemLocationsDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    return PaginatedItemLocationsDto(
      locations: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(ItemLocationDto.fromJson)
                .toList()
          : const [],
      meta: meta is Map<String, dynamic>
          ? PaginationMetaDto.fromJson(meta)
          : const PaginationMetaDto(page: 1, limit: 20, total: 0),
    );
  }

  final List<ItemLocationDto> locations;
  final PaginationMetaDto meta;
}
