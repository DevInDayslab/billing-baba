import type {
  SaleFaAssetRecord,
  SaleFaBatchListRecord,
  SaleFaBatchRecord,
} from './sale-fa.types';

type AssetRow = {
  id: string;
  assetName: string;
  itemCode: string | null;
  assetCategory: string | null;
  serialNumber: string | null;
  salePrice: string;
  location: string | null;
  description: string | null;
  qty: string;
  taxRate: string;
  taxAmount: string;
  lineTotal: string;
  sortOrder: number;
  purchaseFixedAssetId: string | null;
};

export function toSaleFaAssetRecord(row: AssetRow): SaleFaAssetRecord {
  return {
    id: row.id,
    asset_name: row.assetName,
    item_code: row.itemCode,
    asset_category: row.assetCategory,
    serial_number: row.serialNumber,
    sale_price: row.salePrice,
    location: row.location,
    description: row.description,
    qty: row.qty,
    tax_rate: row.taxRate,
    tax_amount: row.taxAmount,
    line_total: row.lineTotal,
    sort_order: row.sortOrder,
    purchase_fixed_asset_id: row.purchaseFixedAssetId,
  };
}

export function toSaleFaBatchListRecord(row: {
  id: string;
  partyId: string;
  partyName: string;
  referenceNumber: string | null;
  saleDate: string;
  dueDate: string | null;
  paymentMode: string | null;
  totalAmount: string;
  balanceDue: string;
  status: string;
  createdAt: Date;
  updatedAt: Date;
}): SaleFaBatchListRecord {
  return {
    id: row.id,
    party_id: row.partyId,
    party_name: row.partyName,
    reference_number: row.referenceNumber,
    sale_date: row.saleDate,
    due_date: row.dueDate,
    payment_mode: row.paymentMode,
    total_amount: row.totalAmount,
    balance_due: row.balanceDue,
    status: row.status,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}

export function toSaleFaBatchRecord(
  batch: {
    id: string;
    partyId: string;
    partyName: string;
    referenceNumber: string | null;
    saleDate: string;
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
): SaleFaBatchRecord {
  return {
    id: batch.id,
    party_id: batch.partyId,
    party_name: batch.partyName,
    reference_number: batch.referenceNumber,
    sale_date: batch.saleDate,
    due_date: batch.dueDate,
    payment_mode: batch.paymentMode,
    subtotal: batch.subtotal,
    tax_amount: batch.taxAmount,
    total_amount: batch.totalAmount,
    balance_due: batch.balanceDue,
    status: batch.status,
    notes: batch.notes,
    description: batch.description,
    assets: assets.map(toSaleFaAssetRecord),
    created_at: batch.createdAt.toISOString(),
    updated_at: batch.updatedAt.toISOString(),
  };
}
