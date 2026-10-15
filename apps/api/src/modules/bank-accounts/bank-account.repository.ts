import { and, asc, eq, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { bankAccounts } from '../../db/schema/bank-accounts/tables';

export type BankAccountRow = typeof bankAccounts.$inferSelect;

export class BankAccountRepository {
  constructor(private readonly db: Database) {}

  async findById(businessId: string, id: string): Promise<BankAccountRow | null> {
    const [row] = await this.db
      .select()
      .from(bankAccounts)
      .where(
        and(
          eq(bankAccounts.businessId, businessId),
          eq(bankAccounts.id, id),
          eq(bankAccounts.isDeleted, false),
        ),
      )
      .limit(1);
    return row ?? null;
  }

  async findCashAccount(businessId: string): Promise<BankAccountRow | null> {
    const [row] = await this.db
      .select()
      .from(bankAccounts)
      .where(
        and(
          eq(bankAccounts.businessId, businessId),
          eq(bankAccounts.type, 'cash'),
          eq(bankAccounts.isDeleted, false),
        ),
      )
      .limit(1);
    return row ?? null;
  }

  async findDefaultBank(businessId: string): Promise<BankAccountRow | null> {
    const [row] = await this.db
      .select()
      .from(bankAccounts)
      .where(
        and(
          eq(bankAccounts.businessId, businessId),
          eq(bankAccounts.type, 'bank'),
          eq(bankAccounts.isDefault, true),
          eq(bankAccounts.isActive, true),
          eq(bankAccounts.isDeleted, false),
        ),
      )
      .limit(1);
    return row ?? null;
  }

  async list(businessId: string, includeInactive = false) {
    const filters = [
      eq(bankAccounts.businessId, businessId),
      eq(bankAccounts.isDeleted, false),
    ];
    if (!includeInactive) {
      filters.push(eq(bankAccounts.isActive, true));
    }
    return this.db
      .select()
      .from(bankAccounts)
      .where(and(...filters))
      .orderBy(
        sql`CASE WHEN ${bankAccounts.type} = 'cash' THEN 0 ELSE 1 END`,
        asc(bankAccounts.displayName),
      );
  }

  async insert(
    values: typeof bankAccounts.$inferInsert,
  ): Promise<BankAccountRow> {
    const [row] = await this.db.insert(bankAccounts).values(values).returning();
    if (!row) throw new Error('Failed to create bank account');
    return row;
  }

  async update(
    businessId: string,
    id: string,
    patch: Partial<typeof bankAccounts.$inferInsert>,
  ): Promise<BankAccountRow | null> {
    const [row] = await this.db
      .update(bankAccounts)
      .set({
        ...patch,
        updatedAt: new Date(),
        syncVersion: sql`${bankAccounts.syncVersion} + 1`,
      })
      .where(
        and(
          eq(bankAccounts.id, id),
          eq(bankAccounts.businessId, businessId),
          eq(bankAccounts.isDeleted, false),
        ),
      )
      .returning();
    return row ?? null;
  }

  async softDelete(
    businessId: string,
    id: string,
    userId?: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(bankAccounts)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedAt: new Date(),
        updatedBy: userId ?? null,
        syncVersion: sql`${bankAccounts.syncVersion} + 1`,
      })
      .where(
        and(
          eq(bankAccounts.id, id),
          eq(bankAccounts.businessId, businessId),
          eq(bankAccounts.isDeleted, false),
        ),
      )
      .returning({ id: bankAccounts.id });
    return Boolean(row);
  }
}
