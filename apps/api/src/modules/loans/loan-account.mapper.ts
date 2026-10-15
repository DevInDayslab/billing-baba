import type { LoanAccountRecord, LoanAccountRow } from './loan-account.types';

export function toLoanAccountRecord(row: LoanAccountRow): LoanAccountRecord {
  return {
    id: row.id,
    name: row.name,
    lender_name: row.lenderName,
    account_number: row.accountNumber,
    description: row.description,
    opening_outstanding: row.openingOutstanding,
    opening_balance_as_of: row.openingBalanceAsOf,
    interest_rate: row.interestRate,
    term_months: row.termMonths,
    received_bank_account_id: row.receivedBankAccountId,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}
