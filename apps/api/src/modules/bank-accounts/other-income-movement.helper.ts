import type { Database } from '../../db/client';
import type { OtherIncomeRecord } from '../other-income/other-income.types';
import { describeMovement } from './domain/describe-movement';
import { AccountMovementService } from './account-movement.service';
import { BankAccountService } from './bank-account.service';
import { expenseDateToOccurredAt } from './utils/ist-date';

export async function syncOtherIncomeMovement(
  db: Database,
  businessId: string,
  income: OtherIncomeRecord,
  userId?: string | null,
): Promise<void> {
  if (!income.payment_mode) {
    await new AccountMovementService(db).voidForSource(
      businessId,
      'other_income',
      income.id,
    );
    return;
  }

  const mode = income.payment_mode ?? 'cash';
  const bankService = new BankAccountService(db);
  const accountId = await bankService.resolveAccountId(
    businessId,
    mode as
      | 'cash'
      | 'upi'
      | 'card'
      | 'cheque'
      | 'bank_transfer'
      | 'other',
    income.bank_account_id ?? null,
    userId,
  );

  await new AccountMovementService(db).replaceForSource({
    businessId,
    bankAccountId: accountId,
    direction: 'deposit',
    amount: income.amount,
    occurredAt: expenseDateToOccurredAt(income.income_date),
    movementType: 'other_income',
    referenceType: 'other_income',
    referenceId: income.id,
    leg: 0,
    description: describeMovement({
      movementType: 'other_income',
      notes: income.description,
      referenceNumber: income.reference_number,
    }),
    referenceNumber: income.reference_number,
  });
}

export async function voidOtherIncomeMovement(
  db: Database,
  businessId: string,
  otherIncomeId: string,
): Promise<void> {
  await new AccountMovementService(db).voidForSource(
    businessId,
    'other_income',
    otherIncomeId,
  );
}
