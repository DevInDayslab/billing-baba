/** Normalize Indian mobile numbers to 10-digit storage format. */
export function normalizeMobile(
  mobile: string | undefined | null,
): string | null {
  if (!mobile?.trim()) {
    return null;
  }

  const digits = mobile.replace(/\D/g, '');

  if (digits.length === 10) {
    return digits;
  }

  if (digits.length === 12 && digits.startsWith('91')) {
    return digits.slice(2);
  }

  if (digits.length === 11 && digits.startsWith('0')) {
    return digits.slice(1);
  }

  return digits.length > 0 ? digits : null;
}

export function validateNormalizedMobile(mobile: string | null): boolean {
  if (mobile === null) {
    return true;
  }

  return /^\d{10}$/.test(mobile);
}

export function validateGstin(gstin: string | undefined | null): boolean {
  if (!gstin?.trim()) {
    return true;
  }

  return /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$/.test(
    gstin.trim().toUpperCase(),
  );
}

export function normalizeGstin(
  gstin: string | undefined | null,
): string | null {
  if (!gstin?.trim()) {
    return null;
  }

  return gstin.trim().toUpperCase();
}

export function normalizeMoney(value: string | undefined): string {
  if (!value?.trim()) {
    return '0';
  }

  return value.trim();
}

export { resolveStateCode, resolveStateName } from '../business/business.utils';
