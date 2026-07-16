import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/unit_conversion_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'unit_dto.freezed.dart';
part 'unit_dto.g.dart';

@freezed
abstract class UnitListDto with _$UnitListDto {
  const factory UnitListDto({
    required String id,
    required String name,
    @JsonKey(name: 'short_name') required String shortName,
    @JsonKey(name: 'decimal_places') required int decimalPlaces,
    @JsonKey(name: 'is_system') required bool isSystem,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'conversion_count') required int conversionCount,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    String? symbol,
  }) = _UnitListDto;

  factory UnitListDto.fromJson(Map<String, dynamic> json) =>
      _$UnitListDtoFromJson(json);
}

@freezed
abstract class UnitDetailDto with _$UnitDetailDto {
  const factory UnitDetailDto({
    required String id,
    required String name,
    @JsonKey(name: 'short_name') required String shortName,
    @JsonKey(name: 'decimal_places') required int decimalPlaces,
    @JsonKey(name: 'is_system') required bool isSystem,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    String? symbol,
    @Default([]) List<UnitConversionDto> conversions,
  }) = _UnitDetailDto;

  factory UnitDetailDto.fromJson(Map<String, dynamic> json) =>
      _$UnitDetailDtoFromJson(json);
}

class PaginatedUnitsDto {
  const PaginatedUnitsDto({
    required this.units,
    required this.meta,
  });

  factory PaginatedUnitsDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    return PaginatedUnitsDto(
      units: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(UnitListDto.fromJson)
                .toList()
          : const [],
      meta: meta is Map<String, dynamic>
          ? PaginationMetaDto.fromJson(meta)
          : const PaginationMetaDto(page: 1, limit: 20, total: 0),
    );
  }

  final List<UnitListDto> units;
  final PaginationMetaDto meta;
}
