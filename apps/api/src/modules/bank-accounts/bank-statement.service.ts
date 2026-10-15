import type { Database } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import {
  resolveRange,
  toPeriodMeta,
} from '../reports/repositories/reports.helpers';
import type { ReportExtendedQuery } from '../reports/reports.schema';
import { AccountMovementRepository } from './account-movement.repository';
import { BankAccountRepository } from './bank-account.repository';
import { buildAccountStatement } from './domain/build-account-statement';

export type BusinessBankStatementQuery = ReportExtendedQuery & {
  bank_account_id: string;
};

export class BankStatementService {
  constructor(private readonly db: Database) {}

  async getBusinessBankStatement(
    businessId: string,
    query: BusinessBankStatementQuery,
  ) {
    const accountRepo = new BankAccountRepository(this.db);
    const account = await accountRepo.findById(
      businessId,
      query.bank_account_id,
    );
    if (!account) {
      throw new AppError('NOT_FOUND', 'Bank account not found', 404);
    }

    const range = resolveRange(query);
    const movementRepo = new AccountMovementRepository(this.db);
    const rows = await movementRepo.listAllForBusiness(
      businessId,
      account.id,
    );

    const movements = rows.map((m) => ({
      id: m.id,
      direction: m.direction,
      amount: m.amount,
      occurredAt: m.occurredAt,
      createdAt: m.createdAt,
      description: m.description,
      referenceNumber: m.referenceNumber,
      movementType: m.movementType,
      referenceType: m.referenceType,
      referenceId: m.referenceId,
    }));

    const statement = buildAccountStatement({
      openingBalance: account.openingBalance,
      openingBalanceAsOf: account.openingBalanceAsOf,
      movements,
      rangeFrom: range.from,
      rangeTo: range.to,
    });

    const warnings: string[] = [];
    if (!account.isActive) {
      warnings.push('This account is inactive.');
    }

    return {
      meta: { period: toPeriodMeta(range) },
      account: {
        id: account.id,
        type: account.type,
        display_name: account.displayName,
        bank_name: account.bankName,
        opening_balance: account.openingBalance,
        opening_balance_as_of: account.openingBalanceAsOf,
      },
      summary: statement.summary,
      rows: statement.rows,
      warnings,
    };
  }
}
