import 'package:billing_baba/features/inventory/models/dto/unit_conversion_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/unit_dto.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';

abstract final class UnitMapper {
  static InventoryUnit fromListDto(UnitListDto dto) {
    return InventoryUnit(
      id: dto.id,
      fullName: dto.name,
      shortName: dto.shortName,
      symbol: dto.symbol,
      decimalPlaces: dto.decimalPlaces,
      isSystem: dto.isSystem,
      isActive: dto.isActive,
      conversionCount: dto.conversionCount,
    );
  }

  static InventoryUnit fromDetailDto(UnitDetailDto dto) {
    return InventoryUnit(
      id: dto.id,
      fullName: dto.name,
      shortName: dto.shortName,
      symbol: dto.symbol,
      decimalPlaces: dto.decimalPlaces,
      isSystem: dto.isSystem,
      isActive: dto.isActive,
      conversionCount: dto.conversions.length,
      conversions: dto.conversions.map(UnitConversionMapper.fromDto).toList(),
    );
  }
}

abstract final class UnitConversionMapper {
  static UnitConversion fromDto(UnitConversionDto dto) {
    return UnitConversion(
      id: dto.id,
      label: dto.label,
      factor: double.tryParse(dto.conversionFactor) ?? 0,
      fromUnitId: dto.fromUnitId,
      toUnitId: dto.toUnitId,
      toUnitName: dto.toUnitName,
    );
  }
}
