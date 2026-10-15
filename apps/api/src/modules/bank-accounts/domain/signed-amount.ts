import type { MoneyPaise } from '../../gst-reports/core/gst-money';
import { parseMoneyToPaise } from '../../gst-reports/core/gst-money';

export type MovementDirection = 'deposit' | 'withdrawal';

export function signedPaiseForMovement(
  direction: MovementDirection,
  amount: string,
): MoneyPaise {
  const paise = parseMoneyToPaise(amount);
  return direction === 'deposit' ? paise : -paise;
}
