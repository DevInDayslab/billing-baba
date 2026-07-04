import { formatConversionLabel } from './inventory.utils';
import type {
  UnitConversionRecord,
  UnitConversionRecordDto,
  UnitConversionRow,
  UnitListRecord,
  UnitRecord,
  UnitRow,
} from './unit.types';

export function toUnitListRecord(row: UnitRow): UnitListRecord {
  return {
    id: row.id,
    name: row.name,
    short_name: row.shortName,
    symbol: row.symbol,
    decimal_places: row.decimalPlaces,
    is_system: row.isSystem,
    is_active: row.isActive,
    conversion_count: row.conversionCount,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}

export function toUnitRecord(
  row: UnitRow,
  conversions: UnitConversionRow[],
): UnitRecord {
  return {
    ...toUnitListRecord(row),
    conversions: conversions.map(toUnitConversionRecord),
  };
}

export function toUnitConversionRecord(
  row: UnitConversionRow,
): UnitConversionRecord {
  const factor = Number(row.conversionFactor);
  return {
    id: row.id,
    from_unit_id: row.fromUnitId,
    to_unit_id: row.toUnitId,
    conversion_factor: row.conversionFactor,
    label: formatConversionLabel(row.fromUnitName, row.toUnitName, factor),
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}

export function toUnitConversionRecordDto(
  row: UnitConversionRow,
): UnitConversionRecordDto {
  const base = toUnitConversionRecord(row);
  return {
    ...base,
    from_unit_name: row.fromUnitName,
    to_unit_name: row.toUnitName,
  };
}
