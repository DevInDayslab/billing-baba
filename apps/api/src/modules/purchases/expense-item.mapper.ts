import type { ExpenseItemRecord, ExpenseItemRow } from './expense-item.types';

export function toExpenseItemRecord(row: ExpenseItemRow): ExpenseItemRecord {
  return {
    id: row.id,
    name: row.name,
    hsn_sac: row.hsnSac,
    price: row.price,
    price_is_tax_inclusive: row.priceIsTaxInclusive,
    tax_rate: row.taxRate,
    expense_count: row.expenseCount,
    total_amount: row.totalAmount,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}
