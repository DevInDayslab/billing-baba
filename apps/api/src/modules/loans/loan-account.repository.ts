import { and, asc, count, desc, eq, ilike, ne, or, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { loanAccounts, loanTransactions } from '../../db/schema/loans/tables';
import { toLoanAccountRecord } from './loan-account.mapper';
import type {
  ListLoanAccountsParams,
  LoanAccountInsertValues,
  LoanAccountRecord,
  LoanAccountRow,
  LoanAccountUpdateValues,
} from './loan-account.types';

export class LoanAccountRepository {
  constructor(private readonly db: Database) {}

  private selectFields() {
    return {
      id: loanAccounts.id,
      name: loanAccounts.name,
      lenderName: loanAccounts.lenderName,
      accountNumber: loanAccounts.accountNumber,
      description: loanAccounts.description,
      openingOutstanding: loanAccounts.openingOutstanding,
      openingBalanceAsOf: loanAccounts.openingBalanceAsOf,
      interestRate: loanAccounts.interestRate,
      termMonths: loanAccounts.termMonths,
      receivedBankAccountId: loanAccounts.receivedBankAccountId,
      createdAt: loanAccounts.createdAt,
      updatedAt: loanAccounts.updatedAt,
    };
  }

  async list(params: ListLoanAccountsParams): Promise<{
    rows: LoanAccountRecord[];
    total: number;
  }> {
    const filters = [
      eq(loanAccounts.businessId, params.businessId),
      eq(loanAccounts.isDeleted, false),
    ];

    if (params.q) {
      filters.push(
        or(
          ilike(loanAccounts.name, `%${params.q}%`),
          ilike(loanAccounts.lenderName, `%${params.q}%`),
          ilike(loanAccounts.accountNumber, `%${params.q}%`),
          ilike(loanAccounts.description, `%${params.q}%`),
        )!,
      );
    }

    const whereClause = and(...filters);
    const countResult = await this.db
      .select({ total: count() })
      .from(loanAccounts)
      .where(whereClause);
    const total = Number(countResult[0]?.total ?? 0);

    const sortColumn =
      params.sort === 'created_at'
        ? loanAccounts.createdAt
        : params.sort === 'opening_balance_as_of'
          ? loanAccounts.openingBalanceAsOf
          : loanAccounts.name;
    const orderBy =
      params.order === 'desc' ? desc(sortColumn) : asc(sortColumn);
    const offset = (params.page - 1) * params.limit;

    const rows = await this.db
      .select(this.selectFields())
      .from(loanAccounts)
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map((row) => toLoanAccountRecord(row as LoanAccountRow)),
      total,
    };
  }

  async findById(
    businessId: string,
    loanAccountId: string,
  ): Promise<LoanAccountRecord | null> {
    const [row] = await this.db
      .select(this.selectFields())
      .from(loanAccounts)
      .where(
        and(
          eq(loanAccounts.id, loanAccountId),
          eq(loanAccounts.businessId, businessId),
          eq(loanAccounts.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? toLoanAccountRecord(row as LoanAccountRow) : null;
  }

  async findActiveNameConflict(
    businessId: string,
    name: string,
    excludeLoanAccountId?: string,
  ): Promise<string | null> {
    const conditions = [
      eq(loanAccounts.businessId, businessId),
      eq(loanAccounts.isDeleted, false),
      sql`lower(${loanAccounts.name}) = lower(${name})`,
    ];
    if (excludeLoanAccountId) {
      conditions.push(ne(loanAccounts.id, excludeLoanAccountId));
    }

    const [row] = await this.db
      .select({ id: loanAccounts.id })
      .from(loanAccounts)
      .where(and(...conditions))
      .limit(1);

    return row?.id ?? null;
  }

  async countActiveTransactions(
    businessId: string,
    loanAccountId: string,
  ): Promise<number> {
    const [row] = await this.db
      .select({ total: count() })
      .from(loanTransactions)
      .where(
        and(
          eq(loanTransactions.loanAccountId, loanAccountId),
          eq(loanTransactions.businessId, businessId),
          eq(loanTransactions.isDeleted, false),
        ),
      );
    return Number(row?.total ?? 0);
  }

  async create(values: LoanAccountInsertValues): Promise<LoanAccountRecord> {
    const [row] = await this.db
      .insert(loanAccounts)
      .values({
        businessId: values.businessId,
        name: values.name,
        lenderName: values.lenderName ?? null,
        accountNumber: values.accountNumber ?? null,
        description: values.description ?? null,
        openingOutstanding: values.openingOutstanding ?? '0',
        openingBalanceAsOf: values.openingBalanceAsOf,
        interestRate: values.interestRate ?? null,
        termMonths: values.termMonths ?? null,
        receivedBankAccountId: values.receivedBankAccountId ?? null,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning({ id: loanAccounts.id });

    if (!row) {
      throw new Error('Failed to create loan account');
    }

    const created = await this.findById(values.businessId, row.id);
    if (!created) {
      throw new Error('Failed to load created loan account');
    }
    return created;
  }

  async update(
    businessId: string,
    loanAccountId: string,
    values: LoanAccountUpdateValues,
  ): Promise<LoanAccountRecord | null> {
    const [row] = await this.db
      .update(loanAccounts)
      .set({
        ...(values.name !== undefined ? { name: values.name } : {}),
        ...(values.lenderName !== undefined
          ? { lenderName: values.lenderName }
          : {}),
        ...(values.accountNumber !== undefined
          ? { accountNumber: values.accountNumber }
          : {}),
        ...(values.description !== undefined
          ? { description: values.description }
          : {}),
        ...(values.openingOutstanding !== undefined
          ? { openingOutstanding: values.openingOutstanding }
          : {}),
        ...(values.openingBalanceAsOf !== undefined
          ? { openingBalanceAsOf: values.openingBalanceAsOf }
          : {}),
        ...(values.interestRate !== undefined
          ? { interestRate: values.interestRate }
          : {}),
        ...(values.termMonths !== undefined
          ? { termMonths: values.termMonths }
          : {}),
        ...(values.receivedBankAccountId !== undefined
          ? { receivedBankAccountId: values.receivedBankAccountId }
          : {}),
        ...(values.updatedBy !== undefined
          ? { updatedBy: values.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${loanAccounts.syncVersion} + 1`,
      })
      .where(
        and(
          eq(loanAccounts.id, loanAccountId),
          eq(loanAccounts.businessId, businessId),
          eq(loanAccounts.isDeleted, false),
        ),
      )
      .returning({ id: loanAccounts.id });

    if (!row) return null;
    return this.findById(businessId, loanAccountId);
  }

  async softDelete(
    businessId: string,
    loanAccountId: string,
    userId: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(loanAccounts)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedBy: userId,
        updatedAt: new Date(),
        syncVersion: sql`${loanAccounts.syncVersion} + 1`,
      })
      .where(
        and(
          eq(loanAccounts.id, loanAccountId),
          eq(loanAccounts.businessId, businessId),
          eq(loanAccounts.isDeleted, false),
        ),
      )
      .returning({ id: loanAccounts.id });

    return Boolean(row);
  }
}
