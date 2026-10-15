export function resolveMoneyEntryBalanceDue(
  amount: string | null,
  balanceDue: string | null,
  paymentMode: string | null,
): number {
  const parsedAmount = Number(amount ?? 0);
  if (balanceDue != null && balanceDue !== '') {
    return Number(balanceDue);
  }
  if (paymentMode) {
    return 0;
  }
  return parsedAmount;
}

export function resolveMoneyEntryStatus(
  amount: string | null,
  balanceDue: string | null,
  paymentMode: string | null,
): 'paid' | 'partial' | 'pending' {
  const balance = resolveMoneyEntryBalanceDue(amount, balanceDue, paymentMode);
  if (balance <= 0) return 'paid';
  if (paymentMode) return 'partial';
  return 'pending';
}
