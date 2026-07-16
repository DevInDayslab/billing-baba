import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'movement_dto.freezed.dart';
part 'movement_dto.g.dart';

@freezed
abstract class MovementDto with _$MovementDto {
  const factory MovementDto({
    required String id,
    @JsonKey(name: 'item_id') required String itemId,
    @JsonKey(name: 'item_name') required String itemName,
    @JsonKey(name: 'godown_id') required String godownId,
    @JsonKey(name: 'godown_name') required String godownName,
    @JsonKey(name: 'movement_type') required String movementType,
    @JsonKey(name: 'quantity_delta') required String quantityDelta,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'cost_per_unit') String? costPerUnit,
    @JsonKey(name: 'reference_id') String? referenceId,
    @JsonKey(name: 'reference_type') String? referenceType,
    @JsonKey(name: 'created_by') String? createdBy,
  }) = _MovementDto;

  factory MovementDto.fromJson(Map<String, dynamic> json) =>
      _$MovementDtoFromJson(json);
}

class PaginatedMovementsDto {
  const PaginatedMovementsDto({
    required this.movements,
    required this.meta,
  });

  factory PaginatedMovementsDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    return PaginatedMovementsDto(
      movements: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(MovementDto.fromJson)
                .toList()
          : const [],
      meta: meta is Map<String, dynamic>
          ? PaginationMetaDto.fromJson(meta)
          : const PaginationMetaDto(page: 1, limit: 20, total: 0),
    );
  }

  final List<MovementDto> movements;
  final PaginationMetaDto meta;
}
