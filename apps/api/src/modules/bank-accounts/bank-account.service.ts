import { AppError } from '../../shared/errors/app-error';
import type { Database } from '../../db/client';
import { decideResolveAccount } from './domain/resolve-account-id-decision';
import type { PaymentModeForResolve } from './domain/resolve-account-id-decision';
import { normalizeIfsc, validateIfsc } from './domain/validate-ifsc';
import { BankAccountRepository } from './bank-account.repository';
import { todayIstDateKey } from './utils/ist-date';

export class BankAccountService {
  constructor(private readonly db: Database) {}

  private repo(): BankAccountRepository {
    return new BankAccountRepository(this.db);
  }

  async ensureCashAccount(businessId: string, userId?: string | null) {
    const existing = await this.repo().findCashAccount(businessId);
    if (existing) return existing;

    const dateKey = todayIstDateKey();
    return this.repo().insert({
      businessId,
      type: 'cash',
      displayName: 'Cash in hand',
      openingBalance: '0',
      openingBalanceAsOf: dateKey,
      isDefault: false,
      isActive: true,
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    });
  }

  async ensureDefaultBank(
    businessId: string,
    displayName = 'Primary Bank',
    openingBalanceAsOf?: string,
    userId?: string | null,
  ) {
    const existing = await this.repo().findDefaultBank(businessId);
    if (existing) return existing;

    const dateKey = openingBalanceAsOf ?? todayIstDateKey();
    return this.repo().insert({
      businessId,
      type: 'bank',
      displayName,
      bankName: displayName,
      openingBalance: '0',
      openingBalanceAsOf: dateKey,
      isDefault: true,
      isActive: true,
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    });
  }

  async resolveAccountId(
    businessId: string,
    paymentMode: PaymentModeForResolve,
    providedAccountId?: string | null,
    userId?: string | null,
  ): Promise<string> {
    const decision = decideResolveAccount(paymentMode, providedAccountId);

    if (decision.kind === 'use_provided') {
      const account = await this.repo().findById(
        businessId,
        decision.accountId,
      );
      if (!account) {
        throw new AppError('VALIDATION_ERROR', 'Invalid bank account', 400);
      }
      if (!account.isActive) {
        throw new AppError('VALIDATION_ERROR', 'Bank account is inactive', 400);
      }
      return account.id;
    }

    if (decision.kind === 'use_cash') {
      const cash = await this.ensureCashAccount(businessId, userId);
      return cash.id;
    }

    const bank = await this.ensureDefaultBank(businessId, 'Primary Bank', undefined, userId);
    return bank.id;
  }

  async list(businessId: string, includeInactive = false) {
    return this.repo().list(businessId, includeInactive);
  }

  async updateCashOpening(
    businessId: string,
    userId: string | undefined,
    input: { opening_balance: string; opening_balance_as_of?: string },
  ) {
    const cash = await this.ensureCashAccount(businessId, userId);
    const dateKey = input.opening_balance_as_of ?? cash.openingBalanceAsOf;
    const updated = await this.repo().update(businessId, cash.id, {
      openingBalance: input.opening_balance,
      openingBalanceAsOf: dateKey,
      updatedBy: userId ?? null,
    });
    if (!updated) {
      throw new AppError('NOT_FOUND', 'Cash account not found', 404);
    }
    return updated;
  }

  async createBank(
    businessId: string,
    userId: string | undefined,
    input: {
      display_name: string;
      bank_name?: string | null;
      account_number?: string | null;
      ifsc?: string | null;
      upi_id?: string | null;
      opening_balance?: string;
      opening_balance_as_of?: string;
      is_default?: boolean;
    },
  ) {
    if (input.ifsc && !validateIfsc(input.ifsc)) {
      throw new AppError('VALIDATION_ERROR', 'Invalid IFSC code', 422);
    }
    const dateKey = input.opening_balance_as_of ?? todayIstDateKey();
    if (input.is_default) {
      await this.clearDefaultBank(businessId);
    }
    return this.repo().insert({
      businessId,
      type: 'bank',
      displayName: input.display_name,
      bankName: input.bank_name ?? null,
      accountNumber: input.account_number ?? null,
      ifsc: input.ifsc ? normalizeIfsc(input.ifsc) : null,
      upiId: input.upi_id ?? null,
      openingBalance: input.opening_balance ?? '0',
      openingBalanceAsOf: dateKey,
      isDefault: input.is_default ?? false,
      isActive: true,
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    });
  }

  async updateBank(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: {
      display_name?: string;
      bank_name?: string | null;
      account_number?: string | null;
      ifsc?: string | null;
      upi_id?: string | null;
      opening_balance?: string;
      opening_balance_as_of?: string;
      is_default?: boolean;
      is_active?: boolean;
    },
  ) {
    const existing = await this.repo().findById(businessId, accountId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Bank account not found', 404);
    }
    if (existing.type === 'cash') {
      if (
        input.is_active === false ||
        input.display_name !== undefined
      ) {
        throw new AppError(
          'VALIDATION_ERROR',
          'Cash in hand account cannot be renamed or deactivated',
          422,
        );
      }
    }
    if (input.ifsc && !validateIfsc(input.ifsc)) {
      throw new AppError('VALIDATION_ERROR', 'Invalid IFSC code', 422);
    }
    if (input.is_default) {
      await this.clearDefaultBank(businessId);
    }
    const updated = await this.repo().update(businessId, accountId, {
      ...(input.display_name !== undefined
        ? { displayName: input.display_name }
        : {}),
      ...(input.bank_name !== undefined ? { bankName: input.bank_name } : {}),
      ...(input.account_number !== undefined
        ? { accountNumber: input.account_number }
        : {}),
      ...(input.ifsc !== undefined
        ? { ifsc: input.ifsc ? normalizeIfsc(input.ifsc) : null }
        : {}),
      ...(input.upi_id !== undefined ? { upiId: input.upi_id } : {}),
      ...(input.opening_balance !== undefined
        ? { openingBalance: input.opening_balance }
        : {}),
      ...(input.opening_balance_as_of !== undefined
        ? { openingBalanceAsOf: input.opening_balance_as_of }
        : {}),
      ...(input.is_default !== undefined ? { isDefault: input.is_default } : {}),
      ...(input.is_active !== undefined ? { isActive: input.is_active } : {}),
      updatedBy: userId ?? null,
    });
    if (!updated) {
      throw new AppError('NOT_FOUND', 'Bank account not found', 404);
    }
    return updated;
  }

  async deleteOrDeactivate(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    movementRepo: { hasMovementsForAccount: (b: string, a: string) => Promise<boolean> },
  ) {
    const existing = await this.repo().findById(businessId, accountId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Bank account not found', 404);
    }
    if (existing.type === 'cash') {
      throw new AppError(
        'VALIDATION_ERROR',
        'Cash in hand account cannot be deleted',
        422,
      );
    }
    const hasMovements = await movementRepo.hasMovementsForAccount(
      businessId,
      accountId,
    );
    if (hasMovements) {
      return this.updateBank(businessId, accountId, userId, {
        is_active: false,
      });
    }
    await this.repo().softDelete(businessId, accountId, userId);
    return null;
  }

  private async clearDefaultBank(businessId: string) {
    const current = await this.repo().findDefaultBank(businessId);
    if (current) {
      await this.repo().update(businessId, current.id, { isDefault: false });
    }
  }
}
