import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'unit_conversion_dto.freezed.dart';
part 'unit_conversion_dto.g.dart';

@freezed
abstract class UnitConversionDto with _$UnitConversionDto {
  const factory UnitConversionDto({
    required String id,
    @JsonKey(name: 'from_unit_id') required String fromUnitId,
    @JsonKey(name: 'to_unit_id') required String toUnitId,
    @JsonKey(name: 'conversion_factor') required String conversionFactor,
    required String label,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    @JsonKey(name: 'from_unit_name') String? fromUnitName,
    @JsonKey(name: 'to_unit_name') String? toUnitName,
  }) = _UnitConversionDto;

  factory UnitConversionDto.fromJson(Map<String, dynamic> json) =>
      _$UnitConversionDtoFromJson(json);
}

class PaginatedUnitConversionsDto {
  const PaginatedUnitConversionsDto({
    required this.conversions,
    required this.meta,
  });

  factory PaginatedUnitConversionsDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    return PaginatedUnitConversionsDto(
      conversions: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(UnitConversionDto.fromJson)
                .toList()
          : const [],
      meta: meta is Map<String, dynamic>
          ? PaginationMetaDto.fromJson(meta)
          : const PaginationMetaDto(page: 1, limit: 20, total: 0),
    );
  }

  final List<UnitConversionDto> conversions;
  final PaginationMetaDto meta;
}
