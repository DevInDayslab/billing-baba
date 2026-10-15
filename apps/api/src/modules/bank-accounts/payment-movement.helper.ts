import type { Database } from '../../db/client';
import { describeMovement } from './domain/describe-movement';
import {
  AccountMovementService,
  movementDirectionForPayment,
  movementTypeForPayment,
} from './account-movement.service';
import { BankAccountService } from './bank-account.service';

export async function recordPaymentMovement(
  db: Database,
  params: {
    businessId: string;
    paymentId: string;
    partyId: string;
    partyName?: string | null;
    direction: 'received' | 'paid';
    amount: string;
    paymentMode: string;
    paymentDate: Date;
    referenceNumber?: string | null;
    notes?: string | null;
    bankAccountId?: string | null;
    userId?: string | null;
  },
): Promise<void> {
  const bankService = new BankAccountService(db);
  const accountId = await bankService.resolveAccountId(
    params.businessId,
    params.paymentMode as
      | 'cash'
      | 'upi'
      | 'card'
      | 'cheque'
      | 'bank_transfer'
      | 'other',
    params.bankAccountId,
    params.userId,
  );

  const movementService = new AccountMovementService(db);
  await movementService.recordForSource({
    businessId: params.businessId,
    bankAccountId: accountId,
    direction: movementDirectionForPayment(params.direction),
    amount: params.amount,
    occurredAt: params.paymentDate,
    movementType: movementTypeForPayment(params.direction),
    referenceType: 'payment',
    referenceId: params.paymentId,
    leg: 0,
    partyId: params.partyId,
    description: describeMovement({
      movementType: movementTypeForPayment(params.direction),
      partyName: params.partyName,
      referenceNumber: params.referenceNumber,
      notes: params.notes,
    }),
    referenceNumber: params.referenceNumber ?? null,
  });
}

export async function voidPaymentMovement(
  db: Database,
  businessId: string,
  paymentId: string,
): Promise<void> {
  await new AccountMovementService(db).voidForSource(
    businessId,
    'payment',
    paymentId,
  );
}
