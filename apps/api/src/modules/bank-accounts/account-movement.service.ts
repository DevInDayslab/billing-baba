import type { Database } from '../../db/client';
import { AccountMovementRepository } from './account-movement.repository';
import type { MovementTypeLabel } from './domain/describe-movement';
import { NON_CASH_EXPENSE_SOURCE_TYPES } from './movement.constants';

export type MovementSourceSpec = {
  businessId: string;
  bankAccountId: string;
  direction: 'deposit' | 'withdrawal';
  amount: string;
  occurredAt: Date;
  movementType: MovementTypeLabel;
  referenceType: string;
  referenceId: string;
  leg?: number;
  partyId?: string | null;
  description: string;
  referenceNumber?: string | null;
};

type DbTx = Database;

export class AccountMovementService {
  constructor(private readonly db: DbTx) {}

  private repo(): AccountMovementRepository {
    return new AccountMovementRepository(this.db);
  }

  async recordForSource(spec: MovementSourceSpec): Promise<void> {
    await this.repo().voidByReference(
      spec.businessId,
      spec.referenceType,
      spec.referenceId,
      spec.leg ?? 0,
    );
    await this.repo().insertMovement({
      businessId: spec.businessId,
      bankAccountId: spec.bankAccountId,
      direction: spec.direction,
      amount: spec.amount,
      occurredAt: spec.occurredAt,
      movementType: spec.movementType,
      referenceType: spec.referenceType,
      referenceId: spec.referenceId,
      leg: spec.leg ?? 0,
      partyId: spec.partyId ?? null,
      description: spec.description,
      referenceNumber: spec.referenceNumber ?? null,
    });
  }

  async replaceForSource(spec: MovementSourceSpec): Promise<void> {
    await this.recordForSource(spec);
  }

  async voidForSource(
    businessId: string,
    referenceType: string,
    referenceId: string,
  ): Promise<void> {
    await this.repo().voidByReference(businessId, referenceType, referenceId);
  }

  shouldSkipExpenseMovement(sourceReferenceType: string | null | undefined): boolean {
    if (!sourceReferenceType) return false;
    return NON_CASH_EXPENSE_SOURCE_TYPES.has(sourceReferenceType);
  }
}

export function movementTypeForPayment(
  direction: 'received' | 'paid',
): MovementTypeLabel {
  return direction === 'received' ? 'payment_in' : 'payment_out';
}

export function movementDirectionForPayment(
  direction: 'received' | 'paid',
): 'deposit' | 'withdrawal' {
  return direction === 'received' ? 'deposit' : 'withdrawal';
}
