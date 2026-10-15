import type { Database } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { parseMoney } from '../inventory/inventory.utils';
import { AccountMovementService } from './account-movement.service';
import { BankAccountRepository } from './bank-account.repository';
import { describeMovement } from './domain/describe-movement';
import { AccountAdjustmentRepository } from './account-adjustment.repository';
import { expenseDateToOccurredAt } from './utils/ist-date';

export class AccountAdjustmentService {
  constructor(private readonly db: Database) {}

  async create(
    businessId: string,
    userId: string | undefined,
    input: {
      bank_account_id: string;
      kind: 'increase' | 'decrease';
      amount: string;
      adjustment_date: string;
      notes?: string | null;
    },
  ) {
    if (parseMoney(input.amount) <= 0) {
      throw new AppError('VALIDATION_ERROR', 'Amount must be positive', 422);
    }

    const account = await new BankAccountRepository(this.db).findById(
      businessId,
      input.bank_account_id,
    );
    if (!account) {
      throw new AppError('NOT_FOUND', 'Bank account not found', 404);
    }

    const isIncrease = input.kind === 'increase';
    const movementType = isIncrease
      ? 'adjustment_increase'
      : 'adjustment_decrease';
    const direction = isIncrease ? 'deposit' : 'withdrawal';

    return this.db.transaction(async (tx) => {
      const repo = new AccountAdjustmentRepository(tx as unknown as Database);
      const movement = new AccountMovementService(tx as unknown as Database);
      const adjustment = await repo.create({
        businessId,
        bankAccountId: input.bank_account_id,
        kind: input.kind,
        amount: input.amount,
        adjustmentDate: input.adjustment_date,
        notes: input.notes ?? null,
        createdBy: userId ?? null,
        updatedBy: userId ?? null,
      });

      await movement.recordForSource({
        businessId,
        bankAccountId: input.bank_account_id,
        direction,
        amount: input.amount,
        occurredAt: expenseDateToOccurredAt(input.adjustment_date),
        movementType,
        referenceType: 'account_adjustment',
        referenceId: adjustment.id,
        leg: 0,
        description: describeMovement({ movementType, notes: input.notes }),
      });

      return adjustment;
    });
  }

  async delete(businessId: string, adjustmentId: string, userId?: string) {
    return this.db.transaction(async (tx) => {
      const repo = new AccountAdjustmentRepository(tx as unknown as Database);
      const movement = new AccountMovementService(tx as unknown as Database);
      const existing = await repo.findById(businessId, adjustmentId);
      if (!existing) {
        throw new AppError('NOT_FOUND', 'Adjustment not found', 404);
      }
      const deleted = await repo.softDelete(businessId, adjustmentId, userId);
      if (!deleted) {
        throw new AppError('NOT_FOUND', 'Adjustment not found', 404);
      }
      await movement.voidForSource(
        businessId,
        'account_adjustment',
        adjustmentId,
      );
    });
  }
}
