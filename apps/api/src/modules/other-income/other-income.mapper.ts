import type { OtherIncomeRecord, OtherIncomeRow } from './other-income.types';

export function toOtherIncomeRecord(row: OtherIncomeRow): OtherIncomeRecord {
  return {
    id: row.id,
    category_id: row.categoryId,
    category_name: row.categoryName,
    income_item_id: row.incomeItemId,
    income_item_name: row.incomeItemName,
    amount: row.amount,
    quantity: row.quantity,
    tax_amount: row.taxAmount,
    tax_rate: row.taxRate,
    description: row.description,
    notes: row.notes,
    reference_number: row.referenceNumber,
    income_date: row.incomeDate,
    payment_mode: row.paymentMode,
    bank_account_id: row.bankAccountId ?? null,
    due_date: row.dueDate,
    balance_due: row.balanceDue,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}
