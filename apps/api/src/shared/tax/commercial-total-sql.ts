import type { AnyColumn } from 'drizzle-orm';
import { sql } from 'drizzle-orm';

/** SQL expression: document total minus TCS (for turnover / P&L reporting). */
export function sqlCommercialDocumentTotal(
  totalAmount: AnyColumn,
  tcsAmount: AnyColumn,
) {
  return sql<string>`(${totalAmount}::numeric - COALESCE(${tcsAmount}::numeric, 0))`;
}
