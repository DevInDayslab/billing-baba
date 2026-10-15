import { and, desc, eq } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { accountTransfers } from '../../db/schema/bank-accounts/tables';

export class AccountTransferRepository {
  constructor(private readonly db: Database) {}

  async create(values: typeof accountTransfers.$inferInsert) {
    const [row] = await this.db
      .insert(accountTransfers)
      .values(values)
      .returning();
    if (!row) throw new Error('Failed to create transfer');
    return row;
  }

  async findById(businessId: string, id: string) {
    const [row] = await this.db
      .select()
      .from(accountTransfers)
      .where(
        and(
          eq(accountTransfers.businessId, businessId),
          eq(accountTransfers.id, id),
          eq(accountTransfers.isDeleted, false),
        ),
      )
      .limit(1);
    return row ?? null;
  }

  async list(businessId: string) {
    return this.db
      .select()
      .from(accountTransfers)
      .where(
        and(
          eq(accountTransfers.businessId, businessId),
          eq(accountTransfers.isDeleted, false),
        ),
      )
      .orderBy(desc(accountTransfers.transferDate));
  }

  async softDelete(
    businessId: string,
    id: string,
    userId?: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(accountTransfers)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedBy: userId ?? null,
        updatedAt: new Date(),
      })
      .where(
        and(
          eq(accountTransfers.businessId, businessId),
          eq(accountTransfers.id, id),
          eq(accountTransfers.isDeleted, false),
        ),
      )
      .returning({ id: accountTransfers.id });
    return Boolean(row);
  }
}
