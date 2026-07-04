import type {
  PurchaseFaAssetRecord,
  PurchaseFaBatchListRecord,
  PurchaseFaBatchRecord,
} from './purchase-fa.types';

type AssetRow = {
  id: string;
  assetName: string;
  assetCategory: string | null;
  serialNumber: string | null;
  purchasePrice: string;
  location: string | null;
  warrantyExpiry: string | null;
  description: string | null;
  qty: string;
  taxRate: string;
  taxAmount: string;
  lineTotal: string;
  sortOrder: number;
  purchaseDocumentId: string | null;
};

export function toPurchaseFaAssetRecord(row: AssetRow): PurchaseFaAssetRecord {
  return {
    id: row.id,
    asset_name: row.assetName,
    asset_category: row.assetCategory,
    serial_number: row.serialNumber,
    purchase_price: row.purchasePrice,
    location: row.location,
    warranty_expiry: row.warrantyExpiry,
    description: row.description,
    qty: row.qty,
    tax_rate: row.taxRate,
    tax_amount: row.taxAmount,
    line_total: row.lineTotal,
    sort_order: row.sortOrder,
    purchase_document_id: row.purchaseDocumentId,
  };
}

export function toPurchaseFaBatchListRecord(row: {
  id: string;
  partyId: string;
  partyName: string;
  referenceNumber: string | null;
  purchaseDate: string;
  dueDate: string | null;
  paymentMode: string | null;
  totalAmount: string;
  balanceDue: string;
  status: string;
  createdAt: Date;
  updatedAt: Date;
}): PurchaseFaBatchListRecord {
  return {
    id: row.id,
    party_id: row.partyId,
    party_name: row.partyName,
    reference_number: row.referenceNumber,
    purchase_date: row.purchaseDate,
    due_date: row.dueDate,
    payment_mode: row.paymentMode,
    total_amount: row.totalAmount,
    balance_due: row.balanceDue,
    status: row.status,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}

export function toPurchaseFaBatchRecord(
  batch: {
    id: string;
    partyId: string;
    partyName: string;
    referenceNumber: string | null;
    purchaseDate: string;
    dueDate: string | null;
    paymentMode: string | null;
    subtotal: string;
    taxAmount: string;
    totalAmount: string;
    balanceDue: string;
    status: string;
    notes: string | null;
    description: string | null;
    createdAt: Date;
    updatedAt: Date;
  },
  assets: AssetRow[],
): PurchaseFaBatchRecord {
  return {
    id: batch.id,
    party_id: batch.partyId,
    party_name: batch.partyName,
    reference_number: batch.referenceNumber,
    purchase_date: batch.purchaseDate,
    due_date: batch.dueDate,
    payment_mode: batch.paymentMode,
    subtotal: batch.subtotal,
    tax_amount: batch.taxAmount,
    total_amount: batch.totalAmount,
    balance_due: batch.balanceDue,
    status: batch.status,
    notes: batch.notes,
    description: batch.description,
    assets: assets.map(toPurchaseFaAssetRecord),
    created_at: batch.createdAt.toISOString(),
    updated_at: batch.updatedAt.toISOString(),
  };
}
