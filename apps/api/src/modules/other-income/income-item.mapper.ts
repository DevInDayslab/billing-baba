import type { IncomeItemRecord, IncomeItemRow } from './income-item.types';

export function toIncomeItemRecord(row: IncomeItemRow): IncomeItemRecord {
  return {
    id: row.id,
    name: row.name,
    hsn_sac: row.hsnSac,
    price: row.price,
    price_is_tax_inclusive: row.priceIsTaxInclusive,
    tax_rate: row.taxRate,
    income_count: row.incomeCount,
    total_amount: row.totalAmount,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}
