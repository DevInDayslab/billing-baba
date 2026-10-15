import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import {
  syncLoanTransactionMovement,
  voidLoanTransactionMovement,
} from '../bank-accounts/loan-movement.helper';
import { BankAccountRepository } from '../bank-accounts/bank-account.repository';
import { LoanTransactionRepository } from './loan-transaction.repository';
import type {
  CreateLoanTransactionBody,
  ListLoanTransactionsQuery,
  UpdateLoanTransactionBody,
} from './loan-transaction.schema';
import type {
  LoanTransactionRecord,
  LoanTransactionType,
} from './loan-transaction.types';
import { LoansServiceBase } from './loans.base-service';

export class LoanTransactionService extends LoansServiceBase {
  private readonly db: NonNullable<ReturnType<typeof getDb>>;
  private readonly repository: LoanTransactionRepository;

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
    this.repository = new LoanTransactionRepository(db);
  }

  async listLoanTransactions(
    businessId: string,
    accountId: string,
    query: ListLoanTransactionsQuery,
  ): Promise<{
    data: LoanTransactionRecord[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);
    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      loanAccountId: query.loan_account_id,
      transactionType: query.transaction_type,
      from: query.from,
      to: query.to,
      q: query.q,
      sort: query.sort,
      order: query.order,
    });
    return {
      data: result.rows,
      meta: { page: query.page, limit: query.limit, total: result.total },
    };
  }

  async getLoanTransaction(
    businessId: string,
    accountId: string,
    transactionId: string,
  ): Promise<LoanTransactionRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    const txn = await this.repository.findById(businessId, transactionId);
    if (!txn) {
      throw new AppError('NOT_FOUND', 'Loan transaction not found', 404);
    }
    return txn;
  }

  async createLoanTransaction(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreateLoanTransactionBody,
  ): Promise<LoanTransactionRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.validateInput(businessId, input);

    const principal = input.principal_amount ?? '0';
    const interest = input.interest_amount ?? '0';
    const charges = input.charges_amount ?? '0';
    this.assertAmountsForType(input.transaction_type, principal, interest, charges);

    return this.db.transaction(async (tx) => {
      const repo = new LoanTransactionRepository(tx as unknown as typeof this.db);
      const txn = await repo.create({
        businessId,
        loanAccountId: input.loan_account_id,
        transactionType: input.transaction_type,
        transactionDate: input.transaction_date,
        principalAmount: principal,
        interestAmount: interest,
        chargesAmount: charges,
        bankAccountId: input.bank_account_id,
        description: input.description ?? null,
        referenceNumber: input.reference_number ?? null,
        createdBy: userId ?? null,
        updatedBy: userId ?? null,
      });

      await syncLoanTransactionMovement(
        tx as unknown as typeof this.db,
        businessId,
        txn,
      );
      return txn;
    });
  }

  async updateLoanTransaction(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    transactionId: string,
    input: UpdateLoanTransactionBody,
  ): Promise<LoanTransactionRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, transactionId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Loan transaction not found', 404);
    }

    const mergedType = input.transaction_type ?? existing.transaction_type;
    const principal = input.principal_amount ?? existing.principal_amount;
    const interest = input.interest_amount ?? existing.interest_amount;
    const charges = input.charges_amount ?? existing.charges_amount;
    this.assertAmountsForType(mergedType, principal, interest, charges);

    if (input.loan_account_id !== undefined) {
      await this.assertLoanAccountExists(businessId, input.loan_account_id);
    }
    if (input.bank_account_id !== undefined) {
      await this.assertBankAccountExists(businessId, input.bank_account_id);
    }

    return this.db.transaction(async (tx) => {
      const repo = new LoanTransactionRepository(tx as unknown as typeof this.db);
      const updated = await repo.update(businessId, transactionId, {
        ...(input.loan_account_id !== undefined
          ? { loanAccountId: input.loan_account_id }
          : {}),
        ...(input.transaction_type !== undefined
          ? { transactionType: input.transaction_type }
          : {}),
        ...(input.transaction_date !== undefined
          ? { transactionDate: input.transaction_date }
          : {}),
        ...(input.principal_amount !== undefined
          ? { principalAmount: input.principal_amount }
          : {}),
        ...(input.interest_amount !== undefined
          ? { interestAmount: input.interest_amount }
          : {}),
        ...(input.charges_amount !== undefined
          ? { chargesAmount: input.charges_amount }
          : {}),
        ...(input.bank_account_id !== undefined
          ? { bankAccountId: input.bank_account_id }
          : {}),
        ...(input.description !== undefined
          ? { description: input.description }
          : {}),
        ...(input.reference_number !== undefined
          ? { referenceNumber: input.reference_number }
          : {}),
        updatedBy: userId ?? null,
      });

      if (!updated) {
        throw new AppError('NOT_FOUND', 'Loan transaction not found', 404);
      }

      await syncLoanTransactionMovement(
        tx as unknown as typeof this.db,
        businessId,
        updated,
      );
      return updated;
    });
  }

  async deleteLoanTransaction(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    transactionId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, transactionId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Loan transaction not found', 404);
    }

    await this.db.transaction(async (tx) => {
      const repo = new LoanTransactionRepository(tx as unknown as typeof this.db);
      const deleted = await repo.softDelete(
        businessId,
        transactionId,
        userId ?? null,
      );
      if (!deleted) {
        throw new AppError('NOT_FOUND', 'Loan transaction not found', 404);
      }
      await voidLoanTransactionMovement(
        tx as unknown as typeof this.db,
        businessId,
        transactionId,
      );
    });
  }

  private async validateInput(
    businessId: string,
    input: CreateLoanTransactionBody,
  ): Promise<void> {
    await this.assertLoanAccountExists(businessId, input.loan_account_id);
    await this.assertBankAccountExists(businessId, input.bank_account_id);
  }

  private assertAmountsForType(
    transactionType: LoanTransactionType,
    principal: string,
    interest: string,
    charges: string,
  ): void {
    const p = Number(principal);
    const i = Number(interest);
    const c = Number(charges);

    if (transactionType === 'increase') {
      if (p <= 0) {
        throw new AppError(
          'INVALID_AMOUNT',
          'Principal amount must be greater than zero for loan increase',
          422,
        );
      }
      return;
    }

    if (transactionType === 'repayment') {
      if (p <= 0 && i <= 0) {
        throw new AppError(
          'INVALID_AMOUNT',
          'Repayment requires principal and/or interest greater than zero',
          422,
        );
      }
      return;
    }

    if (c <= 0) {
      throw new AppError(
        'INVALID_AMOUNT',
        'Charges amount must be greater than zero for loan charges',
        422,
      );
    }
  }

  private async assertLoanAccountExists(
    businessId: string,
    loanAccountId: string,
  ): Promise<void> {
    const exists = await this.repository.loanAccountExists(
      businessId,
      loanAccountId,
    );
    if (!exists) {
      throw new AppError('NOT_FOUND', 'Loan account not found', 404);
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

  async restoreLoanTransaction(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    transactionId: string,
  ): Promise<LoanTransactionRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    return this.db.transaction(async (tx) => {
      const repo = new LoanTransactionRepository(tx as unknown as typeof this.db);
      const restored = await repo.restoreFromRecycle(
        businessId,
        transactionId,
        userId ?? null,
      );
      if (!restored) {
        throw new AppError(
          'NOT_FOUND',
          'Deleted loan transaction not found',
          404,
        );
      }
      await syncLoanTransactionMovement(
        tx as unknown as typeof this.db,
        businessId,
        restored,
      );
      return restored;
    });
  }

  async purgeLoanTransaction(
    businessId: string,
    accountId: string,
    _userId: string | undefined,
    transactionId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);
    const purged = await this.repository.purgeFromRecycle(
      businessId,
      transactionId,
    );
    if (!purged) {
      throw new AppError('NOT_FOUND', 'Deleted loan transaction not found', 404);
    }
  }
}
