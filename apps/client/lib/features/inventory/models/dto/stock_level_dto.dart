import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_level_dto.freezed.dart';
part 'stock_level_dto.g.dart';

@freezed
abstract class StockLevelDto with _$StockLevelDto {
  const factory StockLevelDto({
    required String id,
    @JsonKey(name: 'item_id') required String itemId,
    @JsonKey(name: 'item_name') required String itemName,
    @JsonKey(name: 'godown_id') required String godownId,
    @JsonKey(name: 'godown_name') required String godownName,
    required String quantity,
    @JsonKey(name: 'average_cost') required String averageCost,
    @JsonKey(name: 'is_low_stock') required bool isLowStock,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    @JsonKey(name: 'reorder_level') String? reorderLevel,
  }) = _StockLevelDto;

  factory StockLevelDto.fromJson(Map<String, dynamic> json) =>
      _$StockLevelDtoFromJson(json);
}

class PaginatedStockLevelsDto {
  const PaginatedStockLevelsDto({
    required this.stockLevels,
    required this.meta,
  });

  factory PaginatedStockLevelsDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    return PaginatedStockLevelsDto(
      stockLevels: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(StockLevelDto.fromJson)
                .toList()
          : const [],
      meta: meta is Map<String, dynamic>
          ? PaginationMetaDto.fromJson(meta)
          : const PaginationMetaDto(page: 1, limit: 20, total: 0),
    );
  }

  final List<StockLevelDto> stockLevels;
  final PaginationMetaDto meta;
}
