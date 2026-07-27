import { categories, items, parties } from '../../../db/schema';
import { rowToWirePayload, wirePayloadToDomainValues } from './row-serializers';
import type { PgColumn, PgTable } from 'drizzle-orm/pg-core';

export type SyncedRowBase = {
  id: string;
  businessId: string;
  syncVersion: number;
  updatedAt: Date;
  deletedAt: Date | null;
  isDeleted: boolean;
  deviceId: string | null;
  createdAt: Date;
};

export type RowEntityDef = {
  entityType: string;
  table: PgTable;
  id: PgColumn;
  businessId: PgColumn;
  syncVersion: PgColumn;
  updatedAt: PgColumn;
  deletedAt: PgColumn;
  isDeleted: PgColumn;
  deviceId: PgColumn;
  createdAt: PgColumn;
  allowedColumns: readonly string[];
  toPayload: (row: Record<string, unknown>) => Record<string, unknown>;
  fromPayload: (payload: Record<string, unknown>) => Record<string, unknown>;
};

function defineEntity(input: {
  entityType: string;
  table: PgTable & {
    id: PgColumn;
    businessId: PgColumn;
    syncVersion: PgColumn;
    updatedAt: PgColumn;
    deletedAt: PgColumn;
    isDeleted: PgColumn;
    deviceId: PgColumn;
    createdAt: PgColumn;
  };
  allowedColumns: readonly string[];
}): RowEntityDef {
  const { table, allowedColumns, entityType } = input;
  return {
    entityType,
    table,
    id: table.id,
    businessId: table.businessId,
    syncVersion: table.syncVersion,
    updatedAt: table.updatedAt,
    deletedAt: table.deletedAt,
    isDeleted: table.isDeleted,
    deviceId: table.deviceId,
    createdAt: table.createdAt,
    allowedColumns,
    toPayload: (row) => rowToWirePayload(row),
    fromPayload: (payload) =>
      wirePayloadToDomainValues(payload, allowedColumns),
  };
}

/** MVP registered masters. Add entries as client cutovers land. */
export const ROW_ENTITIES: Record<string, RowEntityDef> = {
  categories: defineEntity({
    entityType: 'categories',
    table: categories,
    allowedColumns: ['name'],
  }),
  parties: defineEntity({
    entityType: 'parties',
    table: parties,
    allowedColumns: [
      'name',
      'legalName',
      'alias',
      'mobile',
      'email',
      'partyGroup',
      'areaCode',
      'partyType',
      'partyCategory',
      'pricingTier',
      'gstin',
      'stateCode',
      'areaId',
      'creditLimit',
      'openingBalance',
      'hiddenLedgerBalance',
      'profileImageUrl',
      'profileMediaAssetId',
      'connectedSince',
      'notes',
      'isActive',
    ],
  }),
  items: defineEntity({
    entityType: 'items',
    table: items,
    allowedColumns: [
      'name',
      'shortName',
      'alias',
      'searchKeywords',
      'description',
      'itemType',
      'hasStockTracking',
      'categoryId',
      'brandId',
      'hsnCode',
      'barcode',
      'baseUnit',
      'mrp',
      'isMrpOnly',
      'marketPrice',
      'salePrice',
      'purchasePrice',
      'reorderLevel',
      'defaultTaxRate',
      'primaryImageUrl',
    ],
  }),
};

export const REGISTERED_ROW_ENTITY_TYPES = Object.keys(
  ROW_ENTITIES,
) as [string, ...string[]];

export function getRowEntity(entityType: string): RowEntityDef | undefined {
  return ROW_ENTITIES[entityType];
}

export function isRegisteredRowEntity(entityType: string): boolean {
  return entityType in ROW_ENTITIES;
}

export function listRowEntities(): RowEntityDef[] {
  return Object.values(ROW_ENTITIES);
}
