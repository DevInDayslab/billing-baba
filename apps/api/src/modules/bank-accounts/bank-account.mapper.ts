import type { BankAccountRow } from './bank-account.repository';

export function toBankAccountDto(row: BankAccountRow) {
  return {
    id: row.id,
    type: row.type,
    display_name: row.displayName,
    bank_name: row.bankName,
    account_number: row.accountNumber,
    ifsc: row.ifsc,
    upi_id: row.upiId,
    opening_balance: row.openingBalance,
    opening_balance_as_of: row.openingBalanceAsOf,
    is_default: row.isDefault,
    is_active: row.isActive,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}
