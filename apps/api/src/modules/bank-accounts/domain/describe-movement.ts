export type MovementTypeLabel =
  | 'payment_in'
  | 'payment_out'
  | 'expense'
  | 'transfer_in'
  | 'transfer_out'
  | 'adjustment_increase'
  | 'adjustment_decrease'
  | 'tax_deposit'
  | 'other_income'
  | 'loan_received'
  | 'loan_repayment'
  | 'loan_charges';

export function describeMovement(input: {
  movementType: MovementTypeLabel;
  partyName?: string | null;
  referenceNumber?: string | null;
  notes?: string | null;
}): string {
  const party = input.partyName?.trim();
  const ref = input.referenceNumber?.trim();
  const notes = input.notes?.trim();

  switch (input.movementType) {
    case 'payment_in':
      return party ? `Payment In - ${party}` : 'Payment In';
    case 'payment_out':
      return party ? `Payment Out - ${party}` : 'Payment Out';
    case 'expense':
      return notes ?? (party ? `Expense - ${party}` : 'Expense');
    case 'transfer_in':
      return notes ?? 'Transfer in';
    case 'transfer_out':
      return notes ?? 'Transfer out';
    case 'adjustment_increase':
      return notes ?? 'Balance increase';
    case 'adjustment_decrease':
      return notes ?? 'Balance decrease';
    case 'tax_deposit':
      return ref ? `Tax deposit - ${ref}` : 'Tax deposit';
    case 'other_income':
      return notes ?? 'Other income';
    case 'loan_received':
      return notes ?? 'Loan received';
    case 'loan_repayment':
      return notes ?? 'Loan repayment';
    case 'loan_charges':
      return notes ?? 'Loan charges';
    default:
      return notes ?? 'Transaction';
  }
}
