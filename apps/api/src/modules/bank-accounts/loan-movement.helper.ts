import type { Database } from '../../db/client';
import type { LoanTransactionRecord } from '../loans/loan-transaction.types';
import { describeMovement } from './domain/describe-movement';
import { AccountMovementService } from './account-movement.service';
import { expenseDateToOccurredAt } from './utils/ist-date';

function totalCashAmount(txn: LoanTransactionRecord): string {
  const principal = Number(txn.principal_amount ?? 0);
  const interest = Number(txn.interest_amount ?? 0);
  const charges = Number(txn.charges_amount ?? 0);
  if (txn.transaction_type === 'increase') {
    return String(principal);
  }
  if (txn.transaction_type === 'repayment') {
    return String(principal + interest);
  }
  return String(charges);
}

export async function syncLoanTransactionMovement(
  db: Database,
  businessId: string,
  txn: LoanTransactionRecord,
): Promise<void> {
  const amount = totalCashAmount(txn);
  if (Number(amount) <= 0) {
    await new AccountMovementService(db).voidForSource(
      businessId,
      'loan_transaction',
      txn.id,
    );
    return;
  }

  const movementType =
    txn.transaction_type === 'increase'
      ? 'loan_received'
      : txn.transaction_type === 'repayment'
        ? 'loan_repayment'
        : 'loan_charges';

  const direction = txn.transaction_type === 'increase' ? 'deposit' : 'withdrawal';

  await new AccountMovementService(db).replaceForSource({
    businessId,
    bankAccountId: txn.bank_account_id,
    direction,
    amount,
    occurredAt: expenseDateToOccurredAt(txn.transaction_date),
    movementType,
    referenceType: 'loan_transaction',
    referenceId: txn.id,
    leg: 0,
    description: describeMovement({
      movementType,
      notes: txn.description,
      referenceNumber: txn.reference_number,
    }),
    referenceNumber: txn.reference_number,
  });
}

export async function voidLoanTransactionMovement(
  db: Database,
  businessId: string,
  transactionId: string,
): Promise<void> {
  await new AccountMovementService(db).voidForSource(
    businessId,
    'loan_transaction',
    transactionId,
  );
}
