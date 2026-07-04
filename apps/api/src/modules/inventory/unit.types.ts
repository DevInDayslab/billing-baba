export type UnitConversionRecord = {
  id: string;
  from_unit_id: string;
  to_unit_id: string;
  conversion_factor: string;
  label: string;
  created_at: string;
  updated_at: string;
};

export type UnitRecord = {
  id: string;
  name: string;
  short_name: string;
  symbol: string | null;
  decimal_places: number;
  is_system: boolean;
  is_active: boolean;
  conversions: UnitConversionRecord[];
  created_at: string;
  updated_at: string;
};

export type UnitListRecord = {
  id: string;
  name: string;
  short_name: string;
  symbol: string | null;
  decimal_places: number;
  is_system: boolean;
  is_active: boolean;
  conversion_count: number;
  created_at: string;
  updated_at: string;
};

export type PaginatedUnitsResponse = {
  data: UnitListRecord[];
  meta: { page: number; limit: number; total: number; totalPages: number };
};

export type UnitInsertValues = {
  businessId: string;
  name: string;
  shortName: string;
  symbol?: string | null;
  decimalPlaces: number;
  isSystem: boolean;
  isActive: boolean;
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type UnitUpdateValues = {
  name?: string;
  shortName?: string;
  symbol?: string | null;
  decimalPlaces?: number;
  isSystem?: boolean;
  isActive?: boolean;
  updatedBy?: string | null;
};

export type ListUnitsParams = {
  businessId: string;
  page: number;
  limit: number;
  q?: string;
  isActive?: boolean;
  sort: 'name' | 'short_name' | 'created_at';
  order: 'asc' | 'desc';
};

export type UnitRow = {
  id: string;
  name: string;
  shortName: string;
  symbol: string | null;
  decimalPlaces: number;
  isSystem: boolean;
  isActive: boolean;
  conversionCount: number;
  createdAt: Date;
  updatedAt: Date;
};

export type UnitConversionRow = {
  id: string;
  fromUnitId: string;
  toUnitId: string;
  conversionFactor: string;
  fromUnitName: string;
  toUnitName: string;
  createdAt: Date;
  updatedAt: Date;
};

export type UnitConversionRecordDto = {
  id: string;
  from_unit_id: string;
  to_unit_id: string;
  conversion_factor: string;
  label: string;
  from_unit_name: string;
  to_unit_name: string;
  created_at: string;
  updated_at: string;
};

export type PaginatedUnitConversionsResponse = {
  success: true;
  data: UnitConversionRecordDto[];
  meta: { page: number; limit: number; total: number };
};

export type UnitConversionInsertValues = {
  businessId: string;
  fromUnitId: string;
  toUnitId: string;
  conversionFactor: string;
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type UnitConversionUpdateValues = {
  fromUnitId?: string;
  toUnitId?: string;
  conversionFactor?: string;
  updatedBy?: string | null;
};

export type ListUnitConversionsParams = {
  businessId: string;
  page: number;
  limit: number;
  fromUnitId?: string;
  toUnitId?: string;
};
