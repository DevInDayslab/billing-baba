import { and, desc, eq } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { accountAdjustments } from '../../db/schema/bank-accounts/tables';

export class AccountAdjustmentRepository {
  constructor(private readonly db: Database) {}

  async create(values: typeof accountAdjustments.$inferInsert) {
    const [row] = await this.db
      .insert(accountAdjustments)
      .values(values)
      .returning();
    if (!row) throw new Error('Failed to create adjustment');
    return row;
  }

  async findById(businessId: string, id: string) {
    const [row] = await this.db
      .select()
      .from(accountAdjustments)
      .where(
        and(
          eq(accountAdjustments.businessId, businessId),
          eq(accountAdjustments.id, id),
          eq(accountAdjustments.isDeleted, false),
        ),
      )
      .limit(1);
    return row ?? null;
  }

  async list(businessId: string) {
    return this.db
      .select()
      .from(accountAdjustments)
      .where(
        and(
          eq(accountAdjustments.businessId, businessId),
          eq(accountAdjustments.isDeleted, false),
        ),
      )
      .orderBy(desc(accountAdjustments.adjustmentDate));
  }

  async softDelete(
    businessId: string,
    id: string,
    userId?: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(accountAdjustments)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedBy: userId ?? null,
        updatedAt: new Date(),
      })
      .where(
        and(
          eq(accountAdjustments.businessId, businessId),
          eq(accountAdjustments.id, id),
          eq(accountAdjustments.isDeleted, false),
        ),
      )
      .returning({ id: accountAdjustments.id });
    return Boolean(row);
  }
}
