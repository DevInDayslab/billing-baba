import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { BankAccountRepository } from '../bank-accounts/bank-account.repository';
import { LoanAccountRepository } from './loan-account.repository';
import type {
  CreateLoanAccountBody,
  ListLoanAccountsQuery,
  UpdateLoanAccountBody,
} from './loan-account.schema';
import type { LoanAccountRecord } from './loan-account.types';
import { LoansServiceBase } from './loans.base-service';

export class LoanAccountService extends LoansServiceBase {
  private readonly db: NonNullable<ReturnType<typeof getDb>>;
  private readonly repository: LoanAccountRepository;

  constructor() {
    super();
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.db = db;
    this.repository = new LoanAccountRepository(db);
  }

  async listLoanAccounts(
    businessId: string,
    accountId: string,
    query: ListLoanAccountsQuery,
  ): Promise<{
    data: LoanAccountRecord[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);
    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      q: query.q,
      sort: query.sort,
      order: query.order,
    });
    return {
      data: result.rows,
      meta: { page: query.page, limit: query.limit, total: result.total },
    };
  }

  async getLoanAccount(
    businessId: string,
    accountId: string,
    loanAccountId: string,
  ): Promise<LoanAccountRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    const loanAccount = await this.repository.findById(
      businessId,
      loanAccountId,
    );
    if (!loanAccount) {
      throw new AppError('NOT_FOUND', 'Loan account not found', 404);
    }
    return loanAccount;
  }

  async createLoanAccount(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreateLoanAccountBody,
  ): Promise<LoanAccountRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    const name = input.name.trim();
    await this.assertNameAvailable(businessId, name);
    if (input.received_bank_account_id) {
      await this.assertBankAccountExists(
        businessId,
        input.received_bank_account_id,
      );
    }

    return this.repository.create({
      businessId,
      name,
      lenderName: input.lender_name ?? null,
      accountNumber: input.account_number ?? null,
      description: input.description ?? null,
      openingOutstanding: input.opening_outstanding ?? '0',
      openingBalanceAsOf: input.opening_balance_as_of,
      interestRate: input.interest_rate ?? null,
      termMonths: input.term_months ?? null,
      receivedBankAccountId: input.received_bank_account_id ?? null,
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    });
  }

  async updateLoanAccount(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    loanAccountId: string,
    input: UpdateLoanAccountBody,
  ): Promise<LoanAccountRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, loanAccountId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Loan account not found', 404);
    }

    if (input.name !== undefined) {
      await this.assertNameAvailable(businessId, input.name.trim(), loanAccountId);
    }
    if (input.received_bank_account_id) {
      await this.assertBankAccountExists(
        businessId,
        input.received_bank_account_id,
      );
    }

    const updated = await this.repository.update(businessId, loanAccountId, {
      ...(input.name !== undefined ? { name: input.name.trim() } : {}),
      ...(input.lender_name !== undefined
        ? { lenderName: input.lender_name }
        : {}),
      ...(input.account_number !== undefined
        ? { accountNumber: input.account_number }
        : {}),
      ...(input.description !== undefined
        ? { description: input.description }
        : {}),
      ...(input.opening_outstanding !== undefined
        ? { openingOutstanding: input.opening_outstanding }
        : {}),
      ...(input.opening_balance_as_of !== undefined
        ? { openingBalanceAsOf: input.opening_balance_as_of }
        : {}),
      ...(input.interest_rate !== undefined
        ? { interestRate: input.interest_rate }
        : {}),
      ...(input.term_months !== undefined
        ? { termMonths: input.term_months }
        : {}),
      ...(input.received_bank_account_id !== undefined
        ? { receivedBankAccountId: input.received_bank_account_id }
        : {}),
      updatedBy: userId ?? null,
    });

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Loan account not found', 404);
    }
    return updated;
  }

  async deleteLoanAccount(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    loanAccountId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, loanAccountId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Loan account not found', 404);
    }

    const transactionCount = await this.repository.countActiveTransactions(
      businessId,
      loanAccountId,
    );
    if (transactionCount > 0) {
      throw new AppError(
        'LOAN_ACCOUNT_HAS_TRANSACTIONS',
        'Cannot delete loan account with existing transactions',
        422,
      );
    }

    const deleted = await this.repository.softDelete(
      businessId,
      loanAccountId,
      userId ?? null,
    );
    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Loan account not found', 404);
    }
  }

  private async assertNameAvailable(
    businessId: string,
    name: string,
    excludeLoanAccountId?: string,
  ): Promise<void> {
    const conflict = await this.repository.findActiveNameConflict(
      businessId,
      name,
      excludeLoanAccountId,
    );
    if (conflict) {
      throw new AppError(
        'DUPLICATE_LOAN_ACCOUNT',
        'A loan account with this name already exists',
        409,
      );
    }
  }

  private async assertBankAccountExists(
    businessId: string,
    bankAccountId: string,
  ): Promise<void> {
    const bankRepo = new BankAccountRepository(this.db);
    const account = await bankRepo.findById(businessId, bankAccountId);
    if (!account || !account.isActive) {
      throw new AppError('NOT_FOUND', 'Bank account not found', 404);
    }
  }
}
