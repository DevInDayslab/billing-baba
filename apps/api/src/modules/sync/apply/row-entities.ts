import type { PgColumn, PgTable } from 'drizzle-orm/pg-core';
import { categories, items, parties } from '../../../db/schema';
import {
  contactActivities,
  contacts,
  deals,
  leadActivities,
  leads,
} from '../../../db/schema/crm/tables';
import {
  brands,
  godowns,
  itemAlternatives,
  itemBomCosts,
  itemBomMaterials,
  itemSuppliers,
  itemTierPrices,
  stockLevels,
  unitDefinitions,
} from '../../../db/schema/inventory/tables';
import { todos } from '../../../db/schema/notifications/tables';
import {
  incomeCategories,
  incomeItems,
  otherIncomes,
} from '../../../db/schema/other-income/tables';
import {
  loanAccounts,
  loanTransactions,
} from '../../../db/schema/loans/tables';
import {
  expenseCategories,
  expenseItems,
  expenses,
  purchaseDocumentLines,
  purchaseDocuments,
} from '../../../db/schema/purchases/tables';
import {
  salesDocumentLines,
  salesDocuments,
} from '../../../db/schema/sales/tables';
import { bankAccounts } from '../../../db/schema/bank-accounts/tables';
import { businessSettings, taxRates } from '../../../db/schema/settings/tables';
import {
  taxDeposits,
  withholdingTaxEntries,
  withholdingTaxSections,
} from '../../../db/schema/withholding/tables';
import { guardDraftDocumentRow } from './document-row-guards';
import { rowToWirePayload, wirePayloadToDomainValues } from './row-serializers';
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
      'pan',
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
  bank_accounts: defineEntity({
    entityType: 'bank_accounts',
    table: bankAccounts,
    allowedColumns: [
      'type',
      'displayName',
      'bankName',
      'accountNumber',
      'ifsc',
      'upiId',
      'openingBalance',
      'openingBalanceAsOf',
      'isDefault',
      'isActive',
    ],
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
  item_suppliers: defineEntity({
    entityType: 'item_suppliers',
    table: itemSuppliers,
    allowedColumns: ['itemId', 'partyId', 'isDefault', 'sortOrder'],
  }),
  item_bom_materials: defineEntity({
    entityType: 'item_bom_materials',
    table: itemBomMaterials,
    allowedColumns: [
      'itemId',
      'rawItemId',
      'qty',
      'unitId',
      'purchasePrice',
      'sortOrder',
    ],
  }),
  item_bom_costs: defineEntity({
    entityType: 'item_bom_costs',
    table: itemBomCosts,
    allowedColumns: ['itemId', 'description', 'amount', 'sortOrder'],
  }),
  item_alternatives: defineEntity({
    entityType: 'item_alternatives',
    table: itemAlternatives,
    allowedColumns: ['itemId', 'alternativeItemId', 'sortOrder'],
  }),
  item_tier_prices: defineEntity({
    entityType: 'item_tier_prices',
    table: itemTierPrices,
    allowedColumns: ['itemId', 'pricingTier', 'price'],
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
  todos: defineEntity({
    entityType: 'todos',
    table: todos,
    allowedColumns: [
      'title',
      'description',
      'priority',
      'category',
      'partyId',
      'dueDate',
      'reminderAt',
      'isCompleted',
      'completedAt',
      'isPinned',
      'linkedInvoiceId',
      'linkedPurchaseId',
      'linkedProductId',
      'attachmentIds',
    ],
  }),
  expense_categories: defineEntity({
    entityType: 'expense_categories',
    table: expenseCategories,
    allowedColumns: ['name', 'categoryType', 'isSystem'],
  }),
  expense_items: defineEntity({
    entityType: 'expense_items',
    table: expenseItems,
    allowedColumns: [
      'name',
      'hsnSac',
      'price',
      'priceIsTaxInclusive',
      'taxRate',
    ],
  }),
  expenses: defineEntity({
    entityType: 'expenses',
    table: expenses,
    allowedColumns: [
      'categoryId',
      'expenseItemId',
      'partyId',
      'amount',
      'taxAmount',
      'taxRate',
      'description',
      'notes',
      'referenceNumber',
      'expenseDate',
      'paymentMode',
      'bankAccountId',
    ],
  }),
  income_categories: defineEntity({
    entityType: 'income_categories',
    table: incomeCategories,
    allowedColumns: ['name', 'categoryType', 'isSystem'],
  }),
  income_items: defineEntity({
    entityType: 'income_items',
    table: incomeItems,
    allowedColumns: [
      'name',
      'hsnSac',
      'price',
      'priceIsTaxInclusive',
      'taxRate',
    ],
  }),
  other_incomes: defineEntity({
    entityType: 'other_incomes',
    table: otherIncomes,
    allowedColumns: [
      'categoryId',
      'incomeItemId',
      'amount',
      'quantity',
      'taxAmount',
      'taxRate',
      'description',
      'notes',
      'referenceNumber',
      'incomeDate',
      'paymentMode',
      'bankAccountId',
      'dueDate',
      'balanceDue',
    ],
  }),
  loan_accounts: defineEntity({
    entityType: 'loan_accounts',
    table: loanAccounts,
    allowedColumns: [
      'name',
      'lenderName',
      'accountNumber',
      'description',
      'openingOutstanding',
      'openingBalanceAsOf',
      'interestRate',
      'termMonths',
      'receivedBankAccountId',
    ],
  }),
  loan_transactions: defineEntity({
    entityType: 'loan_transactions',
    table: loanTransactions,
    allowedColumns: [
      'loanAccountId',
      'transactionType',
      'transactionDate',
      'principalAmount',
      'interestAmount',
      'chargesAmount',
      'bankAccountId',
      'description',
      'referenceNumber',
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
      'enableTds',
      'enableTcs',
    ],
  }),
  withholding_tax_sections: defineEntity({
    entityType: 'withholding_tax_sections',
    table: withholdingTaxSections,
    allowedColumns: [
      'kind',
      'code',
      'description',
      'rate',
      'applicableOn',
      'isActive',
      'isPreloaded',
    ],
  }),
  withholding_tax_entries: {
    ...defineEntity({
      entityType: 'withholding_tax_entries',
      table: withholdingTaxEntries,
      allowedColumns: [
        'kind',
        'direction',
        'sectionId',
        'sectionCode',
        'rate',
        'baseAmount',
        'taxAmount',
        'partyId',
        'partyPan',
        'partyName',
        'sourceType',
        'sourceId',
        'entryDate',
        'depositId',
        'certificateNo',
        'certificateDate',
      ],
    }),
    pullOnly: true,
  },
  tax_deposits: {
    ...defineEntity({
      entityType: 'tax_deposits',
      table: taxDeposits,
      allowedColumns: [
        'kind',
        'bsrCode',
        'challanSerial',
        'depositDate',
        'amount',
        'notes',
      ],
    }),
    pullOnly: true,
  },
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
        'tcsSectionId',
        'tcsRate',
        'tcsBaseAmount',
        'tcsAmount',
        'totalAmount',
        'documentDate',
        'convertedFromId',
        'originalDocumentId',
        'originalDocumentNumber',
        'originalDocumentDate',
        'supplyType',
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
      'cessRate',
      'cessAmount',
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
        'tcsSectionId',
        'tcsRate',
        'tcsBaseAmount',
        'tcsAmount',
        'totalAmount',
        'documentDate',
        'convertedFromId',
        'originalDocumentId',
        'originalDocumentNumber',
        'originalDocumentDate',
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
      'cessRate',
      'cessAmount',
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
