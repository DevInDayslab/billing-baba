import { and, desc, eq, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { taxDeposits } from '../../db/schema/withholding/tables';

export class TaxDepositRepository {
  constructor(private readonly db: Database) {}

  async create(values: typeof taxDeposits.$inferInsert) {
    const [row] = await this.db.insert(taxDeposits).values(values).returning();
    if (!row) throw new Error('Failed to create tax deposit');
    return row;
  }

  async list(businessId: string, kind?: 'tds' | 'tcs') {
    const filters = [
      eq(taxDeposits.businessId, businessId),
      eq(taxDeposits.isDeleted, false),
    ];
    if (kind) {
      filters.push(eq(taxDeposits.kind, kind));
    }
    return this.db
      .select()
      .from(taxDeposits)
      .where(and(...filters))
      .orderBy(desc(taxDeposits.depositDate));
  }

  async softDelete(
    businessId: string,
    depositId: string,
    userId?: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(taxDeposits)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedBy: userId ?? null,
        updatedAt: new Date(),
        syncVersion: sql`${taxDeposits.syncVersion} + 1`,
      })
      .where(
        and(
          eq(taxDeposits.businessId, businessId),
          eq(taxDeposits.id, depositId),
          eq(taxDeposits.isDeleted, false),
        ),
      )
      .returning({ id: taxDeposits.id });
    return Boolean(row);
  }

  async findById(businessId: string, depositId: string) {
    const [row] = await this.db
      .select()
      .from(taxDeposits)
      .where(
        and(
          eq(taxDeposits.businessId, businessId),
          eq(taxDeposits.id, depositId),
          eq(taxDeposits.isDeleted, false),
        ),
      )
      .limit(1);
    return row ?? null;
  }
}
