import type {
  ExpenseCategoryRecord,
  ExpenseCategoryRow,
} from './expense-category.types';

export function toExpenseCategoryRecord(
  row: ExpenseCategoryRow,
): ExpenseCategoryRecord {
  return {
    id: row.id,
    name: row.name,
    category_type: row.categoryType,
    is_system: row.isSystem,
    expense_count: row.expenseCount,
    total_amount: row.totalAmount,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}
