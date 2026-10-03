import { type SQL, sql } from 'drizzle-orm';
import { index, type PgColumn } from 'drizzle-orm/pg-core';

/** Partial index for incremental sync pull: `(business_id, updated_at)` active rows. */
export function syncPullIndex(
  tableName: string,
  businessId: PgColumn,
  updatedAt: PgColumn,
  isDeleted: PgColumn,
) {
  return index(`idx_${tableName}_sync_pull`)
    .on(businessId, updatedAt)
    .where(sql`${isDeleted} = false` as SQL);
}
