import type {
  IncomeCategoryRecord,
  IncomeCategoryRow,
} from './income-category.types';

export function toIncomeCategoryRecord(
  row: IncomeCategoryRow,
): IncomeCategoryRecord {
  return {
    id: row.id,
    name: row.name,
    category_type: row.categoryType,
    is_system: row.isSystem,
    income_count: row.incomeCount,
    total_amount: row.totalAmount,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}
