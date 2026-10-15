import {
  formatPaise,
  parseMoneyToPaise,
  subtractPaise,
} from '../../modules/gst-reports/core/gst-money';

/** Revenue / purchase turnover excluding TCS (GST base reporting). */
export function documentCommercialTotal(
  totalAmount: string,
  tcsAmount?: string | null,
): string {
  const total = parseMoneyToPaise(totalAmount);
  const tcs = parseMoneyToPaise(tcsAmount ?? '0');
  return formatPaise(subtractPaise(total, tcs));
}
