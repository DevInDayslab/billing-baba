import type { ExpenseRecord, ExpenseRow } from './expense.types';

export function toExpenseRecord(row: ExpenseRow): ExpenseRecord {
  return {
    id: row.id,
    category_id: row.categoryId,
    category_name: row.categoryName,
    expense_item_id: row.expenseItemId,
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
    bank_account_id: row.bankAccountId ?? null,
    source_reference_id: row.sourceReferenceId,
    source_reference_type: row.sourceReferenceType,
    loyalty_points: row.loyaltyPoints,
    due_date: row.dueDate,
    balance_due: row.balanceDue,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}
