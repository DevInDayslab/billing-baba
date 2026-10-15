import { and, asc, eq, lt } from 'drizzle-orm';
import type { Database } from '../../../db/client';
import {
  loanAccounts,
  loanTransactions,
} from '../../../db/schema/loans/tables';
import { buildLoanStatement } from '../../loans/domain/build-loan-statement';
import { AppError } from '../../../shared/errors/app-error';
import type { LoanStatementQuery } from '../reports.schema';
import type { LoanStatementPayload } from '../reports.types';
import { resolveRange, toPeriodMeta } from './reports.helpers';

export class LoanReportsRepository {
  constructor(private readonly db: Database) {}

  async getLoanStatement(
    businessId: string,
    query: LoanStatementQuery,
  ): Promise<LoanStatementPayload> {
    const range = resolveRange(query);
    const loanAccountId = query.loan_account;

    const [account] = await this.db
      .select({
        id: loanAccounts.id,
        name: loanAccounts.name,
        openingOutstanding: loanAccounts.openingOutstanding,
        openingBalanceAsOf: loanAccounts.openingBalanceAsOf,
      })
      .from(loanAccounts)
      .where(
        and(
          eq(loanAccounts.businessId, businessId),
          eq(loanAccounts.id, loanAccountId),
          eq(loanAccounts.isDeleted, false),
        ),
      )
      .limit(1);

    if (!account) {
      throw new AppError(
        'LOAN_ACCOUNT_NOT_FOUND',
        'Loan account not found',
        404,
      );
    }

    const txRows = await this.db
      .select({
        id: loanTransactions.id,
        date: loanTransactions.transactionDate,
        transactionType: loanTransactions.transactionType,
        principalAmount: loanTransactions.principalAmount,
        interestAmount: loanTransactions.interestAmount,
        chargesAmount: loanTransactions.chargesAmount,
        description: loanTransactions.description,
        referenceNumber: loanTransactions.referenceNumber,
      })
      .from(loanTransactions)
      .where(
        and(
          eq(loanTransactions.businessId, businessId),
          eq(loanTransactions.loanAccountId, account.id),
          eq(loanTransactions.isDeleted, false),
          lt(
            loanTransactions.transactionDate,
            range.to.toISOString().slice(0, 10),
          ),
        ),
      )
      .orderBy(asc(loanTransactions.transactionDate));

    const rows = buildLoanStatement({
      openingOutstanding: account.openingOutstanding ?? '0',
      openingBalanceAsOf: account.openingBalanceAsOf,
      transactions: txRows.map((row) => ({
        id: row.id,
        date: row.date,
        transactionType: row.transactionType,
        principalAmount: row.principalAmount ?? '0',
        interestAmount: row.interestAmount ?? '0',
        chargesAmount: row.chargesAmount ?? '0',
        description: row.description,
        referenceNumber: row.referenceNumber,
      })),
      rangeFrom: range.from,
      rangeTo: range.to,
    });

    return {
      period: toPeriodMeta(range),
      loan_account: loanAccountId,
      party_id: account.id,
      rows,
    };
  }
}
