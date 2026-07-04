import type { ExpenseRecord, ExpenseRow } from './expense.types';

export function toExpenseRecord(row: ExpenseRow): ExpenseRecord {
  return {
    id: row.id,
    category_id: row.categoryId,
    category_name: row.categoryName,
    party_id: row.partyId,
    party_name: row.partyName,
    amount: row.amount,
    tax_amount: row.taxAmount,
    tax_rate: row.taxRate,
    description: row.description,
    notes: row.notes,
    reference_number: row.referenceNumber,
    attachments: row.attachments ?? [],
    expense_date: row.expenseDate,
    payment_mode: row.paymentMode,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}
