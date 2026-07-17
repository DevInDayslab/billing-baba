import { and, asc, count, desc, eq, gte, lte, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import {
  loyaltyTransactions,
  parties,
  partyLoyaltyBalances,
} from '../../db/schema/crm/tables';
import { loyaltyRules } from '../../db/schema/settings/tables';
import type {
  LoyaltyBalanceRow,
  LoyaltyRulesRow,
  LoyaltyTransactionRecord,
  LoyaltyTransactionType,
} from './loyalty.types';

type DbTransaction = Parameters<Parameters<Database['transaction']>[0]>[0];
type DbExecutor = Database | DbTransaction;

function toTransactionRecord(row: {
  id: string;
  partyId: string;
  transactionType: LoyaltyTransactionType;
  points: string;
  balanceAfter: string;
  referenceId: string | null;
  referenceType: string | null;
  spendAmount: string | null;
  rupeesPerPoint: string | null;
  description: string | null;
  createdAt: Date;
}): LoyaltyTransactionRecord {
  return {
    id: row.id,
    party_id: row.partyId,
    transaction_type: row.transactionType,
    points: row.points,
    balance_after: row.balanceAfter,
    reference_id: row.referenceId,
    reference_type: row.referenceType,
    spend_amount: row.spendAmount,
    rupees_per_point: row.rupeesPerPoint,
    description: row.description,
    created_at: row.createdAt.toISOString(),
  };
}

export class LoyaltyRepository {
  constructor(private readonly db: Database) {}

  async findPartyType(
    executor: DbExecutor,
    businessId: string,
    partyId: string,
  ): Promise<'customer' | 'supplier' | 'both' | null> {
    const [row] = await executor
      .select({ partyType: parties.partyType })
      .from(parties)
      .where(
        and(
          eq(parties.businessId, businessId),
          eq(parties.id, partyId),
          eq(parties.isDeleted, false),
        ),
      )
      .limit(1);

    return row?.partyType ?? null;
  }

  async partyExists(
    executor: DbExecutor,
    businessId: string,
    partyId: string,
  ): Promise<boolean> {
    const partyType = await this.findPartyType(executor, businessId, partyId);
    return partyType !== null;
  }

  async findBalanceForUpdate(
    executor: DbExecutor,
    businessId: string,
    partyId: string,
  ): Promise<LoyaltyBalanceRow | null> {
    const [row] = await executor
      .select({
        id: partyLoyaltyBalances.id,
        partyId: partyLoyaltyBalances.partyId,
        pointsEarned: partyLoyaltyBalances.pointsEarned,
        pointsAvailable: partyLoyaltyBalances.pointsAvailable,
      })
      .from(partyLoyaltyBalances)
      .where(
        and(
          eq(partyLoyaltyBalances.businessId, businessId),
          eq(partyLoyaltyBalances.partyId, partyId),
          eq(partyLoyaltyBalances.isDeleted, false),
        ),
      )
      .limit(1)
      .for('update');

    return row ?? null;
  }

  async getBalance(
    businessId: string,
    partyId: string,
  ): Promise<LoyaltyBalanceRow | null> {
    const [row] = await this.db
      .select({
        id: partyLoyaltyBalances.id,
        partyId: partyLoyaltyBalances.partyId,
        pointsEarned: partyLoyaltyBalances.pointsEarned,
        pointsAvailable: partyLoyaltyBalances.pointsAvailable,
      })
      .from(partyLoyaltyBalances)
      .where(
        and(
          eq(partyLoyaltyBalances.businessId, businessId),
          eq(partyLoyaltyBalances.partyId, partyId),
          eq(partyLoyaltyBalances.isDeleted, false),
        ),
      )
      .limit(1);

    return row ?? null;
  }

  async createBalance(
    executor: DbExecutor,
    values: {
      businessId: string;
      partyId: string;
      pointsEarned: string;
      pointsAvailable: string;
      createdBy?: string | null;
      updatedBy?: string | null;
    },
  ): Promise<LoyaltyBalanceRow> {
    const [row] = await executor
      .insert(partyLoyaltyBalances)
      .values({
        businessId: values.businessId,
        partyId: values.partyId,
        pointsEarned: values.pointsEarned,
        pointsAvailable: values.pointsAvailable,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning({
        id: partyLoyaltyBalances.id,
        partyId: partyLoyaltyBalances.partyId,
        pointsEarned: partyLoyaltyBalances.pointsEarned,
        pointsAvailable: partyLoyaltyBalances.pointsAvailable,
      });

    if (!row) {
      throw new Error('Failed to create loyalty balance');
    }

    return row;
  }

  async updateBalance(
    executor: DbExecutor,
    balanceId: string,
    values: {
      pointsEarned: string;
      pointsAvailable: string;
      updatedBy?: string | null;
    },
  ): Promise<LoyaltyBalanceRow> {
    const [row] = await executor
      .update(partyLoyaltyBalances)
      .set({
        pointsEarned: values.pointsEarned,
        pointsAvailable: values.pointsAvailable,
        updatedBy: values.updatedBy ?? null,
        updatedAt: new Date(),
        syncVersion: sql`${partyLoyaltyBalances.syncVersion} + 1`,
      })
      .where(eq(partyLoyaltyBalances.id, balanceId))
      .returning({
        id: partyLoyaltyBalances.id,
        partyId: partyLoyaltyBalances.partyId,
        pointsEarned: partyLoyaltyBalances.pointsEarned,
        pointsAvailable: partyLoyaltyBalances.pointsAvailable,
      });

    if (!row) {
      throw new Error('Failed to update loyalty balance');
    }

    return row;
  }

  async insertTransaction(
    executor: DbExecutor,
    values: {
      businessId: string;
      partyId: string;
      transactionType: LoyaltyTransactionType;
      points: string;
      balanceAfter: string;
      referenceId?: string | null;
      referenceType?: string | null;
      spendAmount?: string | null;
      rupeesPerPoint?: string | null;
      description?: string | null;
      createdBy?: string | null;
    },
  ): Promise<void> {
    await executor.insert(loyaltyTransactions).values({
      businessId: values.businessId,
      partyId: values.partyId,
      transactionType: values.transactionType,
      points: values.points,
      balanceAfter: values.balanceAfter,
      referenceId: values.referenceId ?? null,
      referenceType: values.referenceType ?? null,
      spendAmount: values.spendAmount ?? null,
      rupeesPerPoint: values.rupeesPerPoint ?? null,
      description: values.description ?? null,
      createdBy: values.createdBy ?? null,
    });
  }

  async listTransactions(params: {
    businessId: string;
    partyId: string;
    page: number;
    limit: number;
    from?: string;
    to?: string;
    order: 'asc' | 'desc';
  }): Promise<{ rows: LoyaltyTransactionRecord[]; total: number }> {
    const filters = [
      eq(loyaltyTransactions.businessId, params.businessId),
      eq(loyaltyTransactions.partyId, params.partyId),
    ];

    if (params.from) {
      filters.push(gte(loyaltyTransactions.createdAt, new Date(params.from)));
    }
    if (params.to) {
      filters.push(lte(loyaltyTransactions.createdAt, new Date(params.to)));
    }

    const whereClause = and(...filters);
    const countResult = await this.db
      .select({ total: count() })
      .from(loyaltyTransactions)
      .where(whereClause);
    const total = Number(countResult[0]?.total ?? 0);

    const orderBy =
      params.order === 'asc'
        ? asc(loyaltyTransactions.createdAt)
        : desc(loyaltyTransactions.createdAt);

    const rows = await this.db
      .select({
        id: loyaltyTransactions.id,
        partyId: loyaltyTransactions.partyId,
        transactionType: loyaltyTransactions.transactionType,
        points: loyaltyTransactions.points,
        balanceAfter: loyaltyTransactions.balanceAfter,
        referenceId: loyaltyTransactions.referenceId,
        referenceType: loyaltyTransactions.referenceType,
        spendAmount: loyaltyTransactions.spendAmount,
        rupeesPerPoint: loyaltyTransactions.rupeesPerPoint,
        description: loyaltyTransactions.description,
        createdAt: loyaltyTransactions.createdAt,
      })
      .from(loyaltyTransactions)
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset((params.page - 1) * params.limit);

    return {
      rows: rows.map(toTransactionRecord),
      total,
    };
  }

  async findActiveRules(businessId: string): Promise<LoyaltyRulesRow | null> {
    const [row] = await this.db
      .select({
        id: loyaltyRules.id,
        rupeesPerPoint: loyaltyRules.rupeesPerPoint,
        isActive: loyaltyRules.isActive,
        updatedAt: loyaltyRules.updatedAt,
      })
      .from(loyaltyRules)
      .where(
        and(
          eq(loyaltyRules.businessId, businessId),
          eq(loyaltyRules.isDeleted, false),
        ),
      )
      .orderBy(desc(loyaltyRules.updatedAt))
      .limit(1);

    return row ?? null;
  }

  async createRules(
    businessId: string,
    values: {
      rupeesPerPoint: string;
      isActive: boolean;
      userId?: string | null;
    },
  ): Promise<LoyaltyRulesRow> {
    const [row] = await this.db
      .insert(loyaltyRules)
      .values({
        businessId,
        rupeesPerPoint: values.rupeesPerPoint,
        isActive: values.isActive,
        createdBy: values.userId ?? null,
        updatedBy: values.userId ?? null,
      })
      .returning({
        id: loyaltyRules.id,
        rupeesPerPoint: loyaltyRules.rupeesPerPoint,
        isActive: loyaltyRules.isActive,
        updatedAt: loyaltyRules.updatedAt,
      });

    if (!row) {
      throw new Error('Failed to create loyalty rules');
    }

    return row;
  }

  async updateRules(
    ruleId: string,
    values: {
      rupeesPerPoint?: string;
      isActive?: boolean;
      userId?: string | null;
    },
  ): Promise<LoyaltyRulesRow> {
    const [row] = await this.db
      .update(loyaltyRules)
      .set({
        ...(values.rupeesPerPoint !== undefined
          ? { rupeesPerPoint: values.rupeesPerPoint }
          : {}),
        ...(values.isActive !== undefined ? { isActive: values.isActive } : {}),
        updatedBy: values.userId ?? null,
        updatedAt: new Date(),
        syncVersion: sql`${loyaltyRules.syncVersion} + 1`,
      })
      .where(eq(loyaltyRules.id, ruleId))
      .returning({
        id: loyaltyRules.id,
        rupeesPerPoint: loyaltyRules.rupeesPerPoint,
        isActive: loyaltyRules.isActive,
        updatedAt: loyaltyRules.updatedAt,
      });

    if (!row) {
      throw new Error('Failed to update loyalty rules');
    }

    return row;
  }
}
