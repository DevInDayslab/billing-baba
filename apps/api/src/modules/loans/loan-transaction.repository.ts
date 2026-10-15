import { and, asc, count, desc, eq, gte, ilike, lte, or, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { loanAccounts, loanTransactions } from '../../db/schema/loans/tables';
import { toLoanTransactionRecord } from './loan-transaction.mapper';
import type {
  ListLoanTransactionsParams,
  LoanTransactionInsertValues,
  LoanTransactionRecord,
  LoanTransactionRow,
  LoanTransactionType,
  LoanTransactionUpdateValues,
} from './loan-transaction.types';

export class LoanTransactionRepository {
  constructor(private readonly db: Database) {}

  private selectFields() {
    return {
      id: loanTransactions.id,
      loanAccountId: loanTransactions.loanAccountId,
      loanAccountName: loanAccounts.name,
      transactionType: loanTransactions.transactionType,
      transactionDate: loanTransactions.transactionDate,
      principalAmount: loanTransactions.principalAmount,
      interestAmount: loanTransactions.interestAmount,
      chargesAmount: loanTransactions.chargesAmount,
      bankAccountId: loanTransactions.bankAccountId,
      description: loanTransactions.description,
      referenceNumber: loanTransactions.referenceNumber,
      createdAt: loanTransactions.createdAt,
      updatedAt: loanTransactions.updatedAt,
    };
  }

  private baseJoin() {
    return this.db
      .select(this.selectFields())
      .from(loanTransactions)
      .innerJoin(
        loanAccounts,
        eq(loanTransactions.loanAccountId, loanAccounts.id),
      );
  }

  async list(params: ListLoanTransactionsParams): Promise<{
    rows: LoanTransactionRecord[];
    total: number;
  }> {
    const filters = [
      eq(loanTransactions.businessId, params.businessId),
      eq(loanTransactions.isDeleted, false),
    ];

    if (params.loanAccountId) {
      filters.push(eq(loanTransactions.loanAccountId, params.loanAccountId));
    }
    if (params.transactionType) {
      filters.push(
        eq(
          loanTransactions.transactionType,
          params.transactionType as (typeof loanTransactions.transactionType.enumValues)[number],
        ),
      );
    }
    if (params.from) {
      filters.push(gte(loanTransactions.transactionDate, params.from));
    }
    if (params.to) {
      filters.push(lte(loanTransactions.transactionDate, params.to));
    }
    if (params.q) {
      filters.push(
        or(
          ilike(loanTransactions.description, `%${params.q}%`),
          ilike(loanTransactions.referenceNumber, `%${params.q}%`),
          ilike(loanAccounts.name, `%${params.q}%`),
        )!,
      );
    }

    const whereClause = and(...filters);
    const countResult = await this.db
      .select({ total: count() })
      .from(loanTransactions)
      .innerJoin(
        loanAccounts,
        eq(loanTransactions.loanAccountId, loanAccounts.id),
      )
      .where(whereClause);
    const total = Number(countResult[0]?.total ?? 0);

    const sortColumn =
      params.sort === 'created_at'
        ? loanTransactions.createdAt
        : loanTransactions.transactionDate;
    const orderBy =
      params.order === 'desc' ? desc(sortColumn) : asc(sortColumn);
    const offset = (params.page - 1) * params.limit;

    const rows = await this.baseJoin()
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map((row) =>
        toLoanTransactionRecord(row as LoanTransactionRow),
      ),
      total,
    };
  }

  async findById(
    businessId: string,
    transactionId: string,
  ): Promise<LoanTransactionRecord | null> {
    const [row] = await this.baseJoin()
      .where(
        and(
          eq(loanTransactions.id, transactionId),
          eq(loanTransactions.businessId, businessId),
          eq(loanTransactions.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? toLoanTransactionRecord(row as LoanTransactionRow) : null;
  }

  async loanAccountExists(
    businessId: string,
    loanAccountId: string,
  ): Promise<boolean> {
    const [row] = await this.db
      .select({ id: loanAccounts.id })
      .from(loanAccounts)
      .where(
        and(
          eq(loanAccounts.id, loanAccountId),
          eq(loanAccounts.businessId, businessId),
          eq(loanAccounts.isDeleted, false),
        ),
      )
      .limit(1);
    return Boolean(row);
  }

  async create(
    values: LoanTransactionInsertValues,
  ): Promise<LoanTransactionRecord> {
    const [row] = await this.db
      .insert(loanTransactions)
      .values({
        businessId: values.businessId,
        loanAccountId: values.loanAccountId,
        transactionType: values.transactionType,
        transactionDate: values.transactionDate,
        principalAmount: values.principalAmount ?? '0',
        interestAmount: values.interestAmount ?? '0',
        chargesAmount: values.chargesAmount ?? '0',
        bankAccountId: values.bankAccountId,
        description: values.description ?? null,
        referenceNumber: values.referenceNumber ?? null,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning({ id: loanTransactions.id });

    if (!row) {
      throw new Error('Failed to create loan transaction');
    }

    const created = await this.findById(values.businessId, row.id);
    if (!created) {
      throw new Error('Failed to load created loan transaction');
    }
    return created;
  }

  async update(
    businessId: string,
    transactionId: string,
    values: LoanTransactionUpdateValues,
  ): Promise<LoanTransactionRecord | null> {
    const [row] = await this.db
      .update(loanTransactions)
      .set({
        ...(values.loanAccountId !== undefined
          ? { loanAccountId: values.loanAccountId }
          : {}),
        ...(values.transactionType !== undefined
          ? {
              transactionType: values.transactionType as LoanTransactionType,
            }
          : {}),
        ...(values.transactionDate !== undefined
          ? { transactionDate: values.transactionDate }
          : {}),
        ...(values.principalAmount !== undefined
          ? { principalAmount: values.principalAmount }
          : {}),
        ...(values.interestAmount !== undefined
          ? { interestAmount: values.interestAmount }
          : {}),
        ...(values.chargesAmount !== undefined
          ? { chargesAmount: values.chargesAmount }
          : {}),
        ...(values.bankAccountId !== undefined
          ? { bankAccountId: values.bankAccountId }
          : {}),
        ...(values.description !== undefined
          ? { description: values.description }
          : {}),
        ...(values.referenceNumber !== undefined
          ? { referenceNumber: values.referenceNumber }
          : {}),
        ...(values.updatedBy !== undefined
          ? { updatedBy: values.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${loanTransactions.syncVersion} + 1`,
      })
      .where(
        and(
          eq(loanTransactions.id, transactionId),
          eq(loanTransactions.businessId, businessId),
          eq(loanTransactions.isDeleted, false),
        ),
      )
      .returning({ id: loanTransactions.id });

    if (!row) return null;
    return this.findById(businessId, transactionId);
  }

  async restoreFromRecycle(
    businessId: string,
    transactionId: string,
    userId: string | null,
  ): Promise<LoanTransactionRecord | null> {
    const [row] = await this.db
      .update(loanTransactions)
      .set({
        isDeleted: false,
        deletedAt: null,
        updatedBy: userId,
        updatedAt: new Date(),
        syncVersion: sql`${loanTransactions.syncVersion} + 1`,
      })
      .where(
        and(
          eq(loanTransactions.id, transactionId),
          eq(loanTransactions.businessId, businessId),
          eq(loanTransactions.isDeleted, true),
        ),
      )
      .returning({ id: loanTransactions.id });

    if (!row) return null;
    return this.findById(businessId, transactionId);
  }

  async purgeFromRecycle(
    businessId: string,
    transactionId: string,
  ): Promise<boolean> {
    const result = await this.db
      .delete(loanTransactions)
      .where(
        and(
          eq(loanTransactions.id, transactionId),
          eq(loanTransactions.businessId, businessId),
          eq(loanTransactions.isDeleted, true),
        ),
      )
      .returning({ id: loanTransactions.id });

    return result.length > 0;
  }

  async softDelete(
    businessId: string,
    transactionId: string,
    userId: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(loanTransactions)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedBy: userId,
        updatedAt: new Date(),
        syncVersion: sql`${loanTransactions.syncVersion} + 1`,
      })
      .where(
        and(
          eq(loanTransactions.id, transactionId),
          eq(loanTransactions.businessId, businessId),
          eq(loanTransactions.isDeleted, false),
        ),
      )
      .returning({ id: loanTransactions.id });

    return Boolean(row);
  }
}
