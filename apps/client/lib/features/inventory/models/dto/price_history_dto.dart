import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_history_dto.freezed.dart';
part 'price_history_dto.g.dart';

@freezed
abstract class PriceHistoryDto with _$PriceHistoryDto {
  const factory PriceHistoryDto({
    required String id,
    @JsonKey(name: 'item_id') required String itemId,
    @JsonKey(name: 'item_name') required String itemName,
    required String price,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'pricing_tier') String? pricingTier,
    @JsonKey(name: 'changed_by') String? changedBy,
  }) = _PriceHistoryDto;

  factory PriceHistoryDto.fromJson(Map<String, dynamic> json) =>
      _$PriceHistoryDtoFromJson(json);
}

class PaginatedPriceHistoryDto {
  const PaginatedPriceHistoryDto({
    required this.records,
    required this.meta,
  });

  factory PaginatedPriceHistoryDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    return PaginatedPriceHistoryDto(
      records: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(PriceHistoryDto.fromJson)
                .toList()
          : const [],
      meta: meta is Map<String, dynamic>
          ? PaginationMetaDto.fromJson(meta)
          : const PaginationMetaDto(page: 1, limit: 20, total: 0),
    );
  }

  final List<PriceHistoryDto> records;
  final PaginationMetaDto meta;
}
