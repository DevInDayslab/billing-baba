import type {
  LoanTransactionRecord,
  LoanTransactionRow,
} from './loan-transaction.types';

export function toLoanTransactionRecord(
  row: LoanTransactionRow,
): LoanTransactionRecord {
  return {
    id: row.id,
    loan_account_id: row.loanAccountId,
    loan_account_name: row.loanAccountName,
    transaction_type: row.transactionType,
    transaction_date: row.transactionDate,
    principal_amount: row.principalAmount,
    interest_amount: row.interestAmount,
    charges_amount: row.chargesAmount,
    bank_account_id: row.bankAccountId,
    description: row.description,
    reference_number: row.referenceNumber,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}
