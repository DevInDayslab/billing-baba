import type { Database } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { parseMoney } from '../inventory/inventory.utils';
import { AccountMovementService } from './account-movement.service';
import { BankAccountRepository } from './bank-account.repository';
import { describeMovement } from './domain/describe-movement';
import { AccountTransferRepository } from './account-transfer.repository';
import { expenseDateToOccurredAt } from './utils/ist-date';

export class AccountTransferService {
  constructor(private readonly db: Database) {}

  async create(
    businessId: string,
    userId: string | undefined,
    input: {
      from_account_id: string;
      to_account_id: string;
      amount: string;
      transfer_date: string;
      notes?: string | null;
    },
  ) {
    if (input.from_account_id === input.to_account_id) {
      throw new AppError(
        'VALIDATION_ERROR',
        'From and to accounts must differ',
        422,
      );
    }
    if (parseMoney(input.amount) <= 0) {
      throw new AppError('VALIDATION_ERROR', 'Amount must be positive', 422);
    }

    const accounts = new BankAccountRepository(this.db);
    const from = await accounts.findById(businessId, input.from_account_id);
    const to = await accounts.findById(businessId, input.to_account_id);
    if (!from || !to) {
      throw new AppError('NOT_FOUND', 'Bank account not found', 404);
    }

    return this.db.transaction(async (tx) => {
      const repo = new AccountTransferRepository(tx as unknown as Database);
      const movement = new AccountMovementService(tx as unknown as Database);
      const transfer = await repo.create({
        businessId,
        fromAccountId: input.from_account_id,
        toAccountId: input.to_account_id,
        amount: input.amount,
        transferDate: input.transfer_date,
        notes: input.notes ?? null,
        createdBy: userId ?? null,
        updatedBy: userId ?? null,
      });

      const occurredAt = expenseDateToOccurredAt(input.transfer_date);
      const outDescription = describeMovement({
        movementType: 'transfer_out',
        notes: input.notes,
      });
      const inDescription = describeMovement({
        movementType: 'transfer_in',
        notes: input.notes,
      });

      await movement.recordForSource({
        businessId,
        bankAccountId: input.from_account_id,
        direction: 'withdrawal',
        amount: input.amount,
        occurredAt,
        movementType: 'transfer_out',
        referenceType: 'account_transfer',
        referenceId: transfer.id,
        leg: 0,
        description: outDescription,
      });
      await movement.recordForSource({
        businessId,
        bankAccountId: input.to_account_id,
        direction: 'deposit',
        amount: input.amount,
        occurredAt,
        movementType: 'transfer_in',
        referenceType: 'account_transfer',
        referenceId: transfer.id,
        leg: 1,
        description: inDescription,
      });

      return transfer;
    });
  }

  async delete(businessId: string, transferId: string, userId?: string) {
    return this.db.transaction(async (tx) => {
      const repo = new AccountTransferRepository(tx as unknown as Database);
      const movement = new AccountMovementService(tx as unknown as Database);
      const existing = await repo.findById(businessId, transferId);
      if (!existing) {
        throw new AppError('NOT_FOUND', 'Transfer not found', 404);
      }
      const deleted = await repo.softDelete(businessId, transferId, userId);
      if (!deleted) {
        throw new AppError('NOT_FOUND', 'Transfer not found', 404);
      }
      await movement.voidForSource(
        businessId,
        'account_transfer',
        transferId,
      );
    });
  }
}
