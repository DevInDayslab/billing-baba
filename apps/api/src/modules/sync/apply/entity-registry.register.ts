import {
  businessSettings,
  categories,
  godowns,
  items,
  parties,
  taxRates,
  unitDefinitions,
} from '../../../db/schema';
import { defineSyncedEntity, EntityRegistry } from './entity-registry';

const PARTY_COLUMNS = [
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
] as const;

const ITEM_COLUMNS = [
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
] as const;

const CATEGORY_COLUMNS = ['name'] as const;

const UNIT_COLUMNS = [
  'name',
  'shortName',
  'symbol',
  'decimalPlaces',
  'isSystem',
  'isActive',
] as const;

const GODOWN_COLUMNS = ['name', 'address', 'isDefault'] as const;

const SETTINGS_COLUMNS = [
  'valuationMethod',
  'defaultTaxType',
  'invoiceTerms',
  'enablePriceConflictAlerts',
  'creditLimitAction',
  'pricingTierLabels',
  'defaultInvoiceTaxRate',
] as const;

const TAX_COLUMNS = ['name', 'rate', 'isDefault'] as const;

/** Singleton registry for master-data row sync (milestone set). */
export const syncEntityRegistry = new EntityRegistry();

export function registerMasterDataEntities(
  registry: EntityRegistry = syncEntityRegistry,
): EntityRegistry {
  registry.register(
    defineSyncedEntity({
      entityType: 'parties',
      table: parties,
      allowedColumns: PARTY_COLUMNS,
    }),
  );
  registry.register(
    defineSyncedEntity({
      entityType: 'items',
      table: items,
      allowedColumns: ITEM_COLUMNS,
    }),
  );
  registry.register(
    defineSyncedEntity({
      entityType: 'categories',
      table: categories,
      allowedColumns: CATEGORY_COLUMNS,
    }),
  );
  registry.register(
    defineSyncedEntity({
      entityType: 'unit_definitions',
      table: unitDefinitions,
      allowedColumns: UNIT_COLUMNS,
    }),
  );
  registry.register(
    defineSyncedEntity({
      entityType: 'godowns',
      table: godowns,
      allowedColumns: GODOWN_COLUMNS,
    }),
  );
  registry.register(
    defineSyncedEntity({
      entityType: 'business_settings',
      table: businessSettings,
      allowedColumns: SETTINGS_COLUMNS,
    }),
  );
  registry.register(
    defineSyncedEntity({
      entityType: 'tax_rates',
      table: taxRates,
      allowedColumns: TAX_COLUMNS,
    }),
  );
  return registry;
}

// Register on module load.
registerMasterDataEntities();
