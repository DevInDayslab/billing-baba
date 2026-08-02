import { categories, items, parties } from '../../../db/schema';
import {
  brands,
  godowns,
  stockLevels,
  unitDefinitions,
} from '../../../db/schema/inventory/tables';
import {
  contactActivities,
  contacts,
  deals,
  leadActivities,
  leads,
} from '../../../db/schema/crm/tables';
import {
  expenses,
  expenseCategories,
  purchaseDocumentLines,
  purchaseDocuments,
} from '../../../db/schema/purchases/tables';
import {
  salesDocumentLines,
  salesDocuments,
} from '../../../db/schema/sales/tables';
import { businessSettings, taxRates } from '../../../db/schema/settings/tables';
import { guardDraftDocumentRow } from './document-row-guards';
import { rowToWirePayload, wirePayloadToDomainValues } from './row-serializers';
import type { PgColumn, PgTable } from 'drizzle-orm/pg-core';
import type { ApplyOutcome, RowMutationInput } from './sync-apply.types';

export type SyncedRowBase = {
  id: string;
  businessId: string;
  syncVersion: number;
  updatedAt: Date;
  deletedAt: Date | null;
  isDeleted: boolean;
  deviceId: string | null;
  createdAt: Date;
  status?: string;
  documentType?: string;
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
  beforeApply?: (
    input: RowMutationInput,
    existing: SyncedRowBase | null,
  ) => ApplyOutcome | null;
  /** Server-derived rows: included in pull, rejected on push. */
  pullOnly?: boolean;
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
  unit_definitions: defineEntity({
    entityType: 'unit_definitions',
    table: unitDefinitions,
    allowedColumns: [
      'name',
      'shortName',
      'symbol',
      'decimalPlaces',
      'isSystem',
      'isActive',
    ],
  }),
  tax_rates: defineEntity({
    entityType: 'tax_rates',
    table: taxRates,
    allowedColumns: ['name', 'rate', 'isDefault'],
  }),
  godowns: defineEntity({
    entityType: 'godowns',
    table: godowns,
    allowedColumns: ['name', 'address', 'isDefault'],
  }),
  brands: defineEntity({
    entityType: 'brands',
    table: brands,
    allowedColumns: ['name'],
  }),
  leads: defineEntity({
    entityType: 'leads',
    table: leads,
    allowedColumns: [
      'name',
      'company',
      'phone',
      'email',
      'leadSource',
      'status',
      'assignedTo',
      'notes',
    ],
  }),
  lead_activities: defineEntity({
    entityType: 'lead_activities',
    table: leadActivities,
    allowedColumns: ['leadId', 'type', 'notes', 'addedBy'],
  }),
  contacts: defineEntity({
    entityType: 'contacts',
    table: contacts,
    allowedColumns: [
      'name',
      'firstName',
      'lastName',
      'salutation',
      'accountName',
      'phone',
      'email',
      'assignedTo',
      'title',
      'description',
    ],
  }),
  contact_activities: defineEntity({
    entityType: 'contact_activities',
    table: contactActivities,
    allowedColumns: ['contactId', 'type', 'notes', 'addedBy'],
  }),
  deals: defineEntity({
    entityType: 'deals',
    table: deals,
    allowedColumns: [
      'name',
      'stage',
      'accountName',
      'assignedTo',
      'amount',
      'expectedCloseDate',
      'description',
    ],
  }),
  expense_categories: defineEntity({
    entityType: 'expense_categories',
    table: expenseCategories,
    allowedColumns: ['name', 'categoryType', 'isSystem'],
  }),
  expenses: defineEntity({
    entityType: 'expenses',
    table: expenses,
    allowedColumns: [
      'categoryId',
      'partyId',
      'amount',
      'taxAmount',
      'taxRate',
      'description',
      'notes',
      'referenceNumber',
      'expenseDate',
      'paymentMode',
    ],
  }),
  business_settings: defineEntity({
    entityType: 'business_settings',
    table: businessSettings,
    allowedColumns: [
      'valuationMethod',
      'defaultTaxType',
      'invoiceTerms',
      'enablePriceConflictAlerts',
      'creditLimitAction',
      'pricingTierLabels',
      'defaultInvoiceTaxRate',
    ],
  }),
  sales_documents: {
    ...defineEntity({
      entityType: 'sales_documents',
      table: salesDocuments,
      allowedColumns: [
        'documentType',
        'status',
        'documentNumber',
        'documentSeries',
        'partyId',
        'isGstFormal',
        'partyStateCode',
        'subtotal',
        'discountTotal',
        'taxAmount',
        'totalAmount',
        'documentDate',
        'convertedFromId',
        'notes',
      ],
    }),
    beforeApply: guardDraftDocumentRow(['tax_invoice', 'sales_return', 'pos']),
  },
  sales_document_lines: defineEntity({
    entityType: 'sales_document_lines',
    table: salesDocumentLines,
    allowedColumns: [
      'salesDocumentId',
      'itemId',
      'quantity',
      'unit',
      'unitPrice',
      'marketPrice',
      'discountAmount',
      'taxType',
      'taxRate',
      'cgstAmount',
      'sgstAmount',
      'igstAmount',
      'lineTotal',
      'sortOrder',
    ],
  }),
  purchase_documents: {
    ...defineEntity({
      entityType: 'purchase_documents',
      table: purchaseDocuments,
      allowedColumns: [
        'documentType',
        'status',
        'documentNumber',
        'documentSeries',
        'partyId',
        'isGstFormal',
        'partyStateCode',
        'subtotal',
        'discountTotal',
        'taxAmount',
        'totalAmount',
        'documentDate',
        'convertedFromId',
        'supplierInvoiceNumber',
        'dueDate',
        'notes',
      ],
    }),
    beforeApply: guardDraftDocumentRow(['purchase_bill', 'purchase_return']),
  },
  purchase_document_lines: defineEntity({
    entityType: 'purchase_document_lines',
    table: purchaseDocumentLines,
    allowedColumns: [
      'purchaseDocumentId',
      'itemId',
      'quantity',
      'unit',
      'unitPrice',
      'discountAmount',
      'taxType',
      'taxRate',
      'cgstAmount',
      'sgstAmount',
      'igstAmount',
      'lineTotal',
      'sortOrder',
    ],
  }),
  stock_levels: {
    ...defineEntity({
      entityType: 'stock_levels',
      table: stockLevels,
      allowedColumns: [
        'itemId',
        'godownId',
        'quantity',
        'averageCost',
        'reorderLevel',
      ],
    }),
    pullOnly: true,
  },
};

export const REGISTERED_ROW_ENTITY_TYPES = Object.keys(ROW_ENTITIES) as [
  string,
  ...string[],
];

export function getRowEntity(entityType: string): RowEntityDef | undefined {
  return ROW_ENTITIES[entityType];
}

export function isRegisteredRowEntity(entityType: string): boolean {
  return entityType in ROW_ENTITIES;
}

export function isPullOnlyRowEntity(entityType: string): boolean {
  return ROW_ENTITIES[entityType]?.pullOnly === true;
}

export function listRowEntities(): RowEntityDef[] {
  return Object.values(ROW_ENTITIES);
}
