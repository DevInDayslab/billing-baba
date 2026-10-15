import type { Database } from '../../db/client';
import { AccountMovementService } from '../bank-accounts/account-movement.service';
import { BankAccountService } from '../bank-accounts/bank-account.service';
import { describeMovement } from '../bank-accounts/domain/describe-movement';
import { expenseDateToOccurredAt } from '../bank-accounts/utils/ist-date';

export async function recordTaxDepositMovement(
  db: Database,
  businessId: string,
  deposit: {
    id: string;
    amount: string;
    depositDate: string;
    challanSerial: string;
    bankAccountId: string | null;
  },
  userId?: string | null,
): Promise<void> {
  const bankService = new BankAccountService(db);
  const bankAccountId = await bankService.resolveAccountId(
    businessId,
    'bank_transfer',
    deposit.bankAccountId,
    userId,
  );

  await new AccountMovementService(db).recordForSource({
    businessId,
    bankAccountId,
    direction: 'withdrawal',
    amount: deposit.amount,
    occurredAt: expenseDateToOccurredAt(deposit.depositDate),
    movementType: 'tax_deposit',
    referenceType: 'tax_deposit',
    referenceId: deposit.id,
    leg: 0,
    description: describeMovement({
      movementType: 'tax_deposit',
      referenceNumber: deposit.challanSerial,
    }),
    referenceNumber: deposit.challanSerial,
  });
}

export async function voidTaxDepositMovement(
  db: Database,
  businessId: string,
  depositId: string,
): Promise<void> {
  await new AccountMovementService(db).voidForSource(
    businessId,
    'tax_deposit',
    depositId,
  );
}
