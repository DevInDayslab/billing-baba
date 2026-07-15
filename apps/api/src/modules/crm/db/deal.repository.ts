import { and, count, desc, eq, gte, ilike, lte, or, sql } from 'drizzle-orm';
import type { Database } from '../../../db/client';
import { deals } from '../../../db/schema/crm/tables';
import { users } from '../../../db/schema/identity/tables';
import type {
  DealInsertValues,
  DealRecord,
  DealUpdateValues,
  ListDealsParams,
} from '../deal.types';

type DealRow = typeof deals.$inferSelect;

export class DealRepository {
  constructor(private readonly db: Database) {}

  async hasBusinessMembership(
    businessId: string,
    accountId: string,
  ): Promise<boolean> {
    const [membership] = await this.db
      .select({ id: users.id })
      .from(users)
      .where(
        and(
          eq(users.businessId, businessId),
          eq(users.accountId, accountId),
          eq(users.isActive, true),
          eq(users.isDeleted, false),
        ),
      )
      .limit(1);

    return Boolean(membership);
  }

  async list(params: ListDealsParams): Promise<{
    rows: DealRecord[];
    total: number;
  }> {
    const conditions = [
      eq(deals.businessId, params.businessId),
      eq(deals.isDeleted, false),
    ];

    if (params.q) {
      const pattern = `%${params.q}%`;
      conditions.push(
        or(
          ilike(deals.name, pattern),
          ilike(deals.accountName, pattern),
          ilike(deals.assignedTo, pattern),
        )!,
      );
    }

    if (params.accountName) {
      conditions.push(eq(deals.accountName, params.accountName));
    }

    if (params.assignedTo) {
      conditions.push(eq(deals.assignedTo, params.assignedTo));
    }

    if (params.stage) {
      conditions.push(eq(deals.stage, params.stage));
    }

    if (params.from) {
      conditions.push(gte(deals.createdAt, params.from));
    }

    if (params.to) {
      conditions.push(lte(deals.createdAt, params.to));
    }

    const whereClause = and(...conditions);

    const [totalRow] = await this.db
      .select({ total: count() })
      .from(deals)
      .where(whereClause);

    const offset = (params.page - 1) * params.limit;
    const rows = await this.db
      .select()
      .from(deals)
      .where(whereClause)
      .orderBy(desc(deals.createdAt))
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map(mapDealRow),
      total: Number(totalRow?.total ?? 0),
    };
  }

  async findById(
    businessId: string,
    dealId: string,
  ): Promise<DealRecord | null> {
    const [deal] = await this.db
      .select()
      .from(deals)
      .where(
        and(
          eq(deals.businessId, businessId),
          eq(deals.id, dealId),
          eq(deals.isDeleted, false),
        ),
      )
      .limit(1);

    return deal ? mapDealRow(deal) : null;
  }

  async create(values: DealInsertValues): Promise<DealRecord> {
    const [row] = await this.db
      .insert(deals)
      .values({
        id: values.id,
        businessId: values.businessId,
        name: values.name,
        stage: values.stage ?? 'qualification',
        accountName: values.accountName ?? null,
        assignedTo: values.assignedTo ?? null,
        amount: values.amount ?? '0',
        expectedCloseDate: values.expectedCloseDate ?? null,
        description: values.description ?? null,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning();

    if (!row) {
      throw new Error('Failed to create deal');
    }

    return mapDealRow(row);
  }

  async update(
    businessId: string,
    dealId: string,
    values: DealUpdateValues,
  ): Promise<DealRecord | null> {
    const [row] = await this.db
      .update(deals)
      .set({
        ...(values.name !== undefined ? { name: values.name } : {}),
        ...(values.stage !== undefined ? { stage: values.stage } : {}),
        ...(values.accountName !== undefined
          ? { accountName: values.accountName }
          : {}),
        ...(values.assignedTo !== undefined
          ? { assignedTo: values.assignedTo }
          : {}),
        ...(values.amount !== undefined ? { amount: values.amount } : {}),
        ...(values.expectedCloseDate !== undefined
          ? { expectedCloseDate: values.expectedCloseDate }
          : {}),
        ...(values.description !== undefined
          ? { description: values.description }
          : {}),
        ...(values.isDeleted !== undefined
          ? { isDeleted: values.isDeleted }
          : {}),
        ...(values.deletedAt !== undefined
          ? { deletedAt: values.deletedAt }
          : {}),
        updatedBy: values.updatedBy ?? null,
        updatedAt: sql`now()`,
        syncVersion: sql`${deals.syncVersion} + 1`,
      })
      .where(
        and(
          eq(deals.businessId, businessId),
          eq(deals.id, dealId),
          eq(deals.isDeleted, false),
        ),
      )
      .returning();

    return row ? mapDealRow(row) : null;
  }

  async softDelete(
    businessId: string,
    dealId: string,
    updatedBy?: string,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(deals)
      .set({
        isDeleted: true,
        deletedAt: sql`now()`,
        updatedBy: updatedBy ?? null,
        updatedAt: sql`now()`,
        syncVersion: sql`${deals.syncVersion} + 1`,
      })
      .where(
        and(
          eq(deals.businessId, businessId),
          eq(deals.id, dealId),
          eq(deals.isDeleted, false),
        ),
      )
      .returning({ id: deals.id });

    return Boolean(row);
  }
}

function mapDealRow(row: DealRow): DealRecord {
  return {
    id: row.id,
    business_id: row.businessId,
    name: row.name,
    stage: row.stage,
    account_name: row.accountName,
    assigned_to: row.assignedTo,
    amount: row.amount,
    expected_close_date: row.expectedCloseDate,
    description: row.description,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}
