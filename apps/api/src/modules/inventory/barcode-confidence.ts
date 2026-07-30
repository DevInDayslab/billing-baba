const NON_DIGIT_PATTERN = /\D/g;
const BARCODE_LIKE_PATTERN = /^[\d\s-]+$/;

export function normalizeBarcode(barcode: string): string {
  return barcode.replace(NON_DIGIT_PATTERN, '');
}

export function isBarcodeLike(query: string): boolean {
  const trimmed = query.trim();
  if (!trimmed) return false;
  if (!BARCODE_LIKE_PATTERN.test(trimmed)) return false;
  return normalizeBarcode(trimmed).length >= 8;
}

export function isEligibleForExternalLookup(barcode: string): boolean {
  const digits = normalizeBarcode(barcode);
  if (digits.length < 8) return false;
  return hasValidGtinChecksum(digits);
}

export function hasValidGtinChecksum(barcode: string): boolean {
  const digits = normalizeBarcode(barcode);
  if (![8, 12, 13, 14].includes(digits.length)) {
    return false;
  }

  const body = digits.slice(0, -1);
  const checkDigit = Number(digits[digits.length - 1]);
  if (Number.isNaN(checkDigit)) return false;

  let sum = 0;
  for (let i = 0; i < body.length; i++) {
    const digit = Number(body[body.length - 1 - i]);
    if (Number.isNaN(digit)) return false;
    sum += digit * (i % 2 === 0 ? 3 : 1);
  }

  const calculated = (10 - (sum % 10)) % 10;
  return calculated === checkDigit;
}

export function isExactBarcodeMatch(
  scanned: string,
  candidate?: string | null,
): boolean {
  const expected = normalizeBarcode(scanned);
  if (!expected) return false;
  const actual = normalizeBarcode(candidate ?? '');
  return actual.length > 0 && actual === expected;
}
