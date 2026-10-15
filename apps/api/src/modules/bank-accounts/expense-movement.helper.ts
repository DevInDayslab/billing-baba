import type { Database } from '../../db/client';
import type { ExpenseRecord } from '../purchases/expense.types';
import { describeMovement } from './domain/describe-movement';
import { AccountMovementService } from './account-movement.service';
import { BankAccountService } from './bank-account.service';
import { expenseDateToOccurredAt } from './utils/ist-date';

export async function syncExpenseMovement(
  db: Database,
  businessId: string,
  expense: ExpenseRecord,
  userId?: string | null,
): Promise<void> {
  const movementService = new AccountMovementService(db);
  if (
    movementService.shouldSkipExpenseMovement(expense.source_reference_type)
  ) {
    await movementService.voidForSource(businessId, 'expense', expense.id);
    return;
  }

  const mode = expense.payment_mode ?? 'cash';
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
    expense.bank_account_id ?? null,
    userId,
  );

  await movementService.replaceForSource({
    businessId,
    bankAccountId: accountId,
    direction: 'withdrawal',
    amount: expense.amount,
    occurredAt: expenseDateToOccurredAt(expense.expense_date),
    movementType: 'expense',
    referenceType: 'expense',
    referenceId: expense.id,
    leg: 0,
    partyId: expense.party_id,
    description: describeMovement({
      movementType: 'expense',
      partyName: null,
      notes: expense.description,
      referenceNumber: expense.reference_number,
    }),
    referenceNumber: expense.reference_number,
  });
}

export async function voidExpenseMovement(
  db: Database,
  businessId: string,
  expenseId: string,
): Promise<void> {
  await new AccountMovementService(db).voidForSource(
    businessId,
    'expense',
    expenseId,
  );
}
