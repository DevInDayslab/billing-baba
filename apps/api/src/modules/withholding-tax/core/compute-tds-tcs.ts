import {
  formatPaise,
  parseMoneyToPaise,
  zeroPaise,
} from '../../gst-reports/core/gst-money';

/** Round to nearest whole rupee (paise multiple of 100). */
export function computeTds(baseAmount: string, ratePercent: string): string {
  return computeWithholding(baseAmount, ratePercent);
}

export function computeTcs(baseAmount: string, ratePercent: string): string {
  return computeWithholding(baseAmount, ratePercent);
}

function computeWithholding(baseAmount: string, ratePercent: string): string {
  const base = parseMoneyToPaise(baseAmount);
  const rate = parseMoneyToPaise(ratePercent);
  if (base === zeroPaise() || rate === zeroPaise()) {
    return '0.00';
  }
  const taxPaise = (base * rate) / BigInt(10000);
  const rounded =
    taxPaise >= zeroPaise()
      ? ((taxPaise + BigInt(50)) / BigInt(100)) * BigInt(100)
      : ((taxPaise - BigInt(50)) / BigInt(100)) * BigInt(100);
  return formatPaise(rounded);
}
