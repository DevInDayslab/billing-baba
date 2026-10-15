export type PaymentModeForResolve =
  | 'cash'
  | 'upi'
  | 'card'
  | 'cheque'
  | 'bank_transfer'
  | 'other';

/** Pure decision: should we use provided id, cash account, or default bank? */
export type ResolveAccountDecision =
  | { kind: 'use_provided'; accountId: string }
  | { kind: 'use_cash' }
  | { kind: 'use_default_bank' };

export function decideResolveAccount(
  paymentMode: PaymentModeForResolve,
  providedAccountId: string | null | undefined,
): ResolveAccountDecision {
  if (providedAccountId) {
    return { kind: 'use_provided', accountId: providedAccountId };
  }
  if (paymentMode === 'cash') {
    return { kind: 'use_cash' };
  }
  return { kind: 'use_default_bank' };
}
