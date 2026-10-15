import { and, asc, eq, gte, lt, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { accountMovements } from '../../db/schema/bank-accounts/tables';

export type MovementInsert = typeof accountMovements.$inferInsert;

export class AccountMovementRepository {
  constructor(private readonly db: Database) {}

  movementFilters(
    businessId: string,
    bankAccountId: string,
    options?: { from?: Date; to?: Date; includeDeleted?: boolean },
  ) {
    const filters = [
      eq(accountMovements.businessId, businessId),
      eq(accountMovements.bankAccountId, bankAccountId),
    ];
    if (!options?.includeDeleted) {
      filters.push(eq(accountMovements.isDeleted, false));
    }
    if (options?.from) {
      filters.push(gte(accountMovements.occurredAt, options.from));
    }
    if (options?.to) {
      filters.push(lt(accountMovements.occurredAt, options.to));
    }
    return filters;
  }

  async hasMovementsForAccount(
    businessId: string,
    bankAccountId: string,
  ): Promise<boolean> {
    const [row] = await this.db
      .select({ id: accountMovements.id })
      .from(accountMovements)
      .where(
        and(
          eq(accountMovements.businessId, businessId),
          eq(accountMovements.bankAccountId, bankAccountId),
          eq(accountMovements.isDeleted, false),
        ),
      )
      .limit(1);
    return Boolean(row);
  }

  async listForAccount(
    businessId: string,
    bankAccountId: string,
    from?: Date,
    to?: Date,
  ) {
    return this.db
      .select()
      .from(accountMovements)
      .where(
        and(...this.movementFilters(businessId, bankAccountId, { from, to })),
      )
      .orderBy(
        asc(accountMovements.occurredAt),
        asc(accountMovements.createdAt),
        asc(accountMovements.id),
      );
  }

  async listAllForBusiness(businessId: string, bankAccountId: string) {
    return this.listForAccount(businessId, bankAccountId);
  }

  async voidByReference(
    businessId: string,
    referenceType: string,
    referenceId: string,
    leg?: number,
  ): Promise<void> {
    const filters = [
      eq(accountMovements.businessId, businessId),
      eq(accountMovements.referenceType, referenceType),
      eq(accountMovements.referenceId, referenceId),
      eq(accountMovements.isDeleted, false),
    ];
    if (leg !== undefined) {
      filters.push(eq(accountMovements.leg, leg));
    }
    await this.db
      .update(accountMovements)
      .set({ isDeleted: true, deletedAt: new Date() })
      .where(and(...filters));
  }

  async insertMovement(values: MovementInsert) {
    const [row] = await this.db
      .insert(accountMovements)
      .values(values)
      .returning();
    if (!row) throw new Error('Failed to insert movement');
    return row;
  }

  async sumSignedBefore(
    businessId: string,
    bankAccountId: string,
    before: Date,
    openingAsOf: Date,
  ): Promise<string> {
    const [row] = await this.db
      .select({
        net: sql<string>`COALESCE(SUM(
          CASE
            WHEN ${accountMovements.direction} = 'deposit'
            THEN ${accountMovements.amount}::numeric
            ELSE -${accountMovements.amount}::numeric
          END
        ), 0)`,
      })
      .from(accountMovements)
      .where(
        and(
          eq(accountMovements.businessId, businessId),
          eq(accountMovements.bankAccountId, bankAccountId),
          eq(accountMovements.isDeleted, false),
          gte(accountMovements.occurredAt, openingAsOf),
          lt(accountMovements.occurredAt, before),
        ),
      );
    return row?.net ?? '0';
  }
}
