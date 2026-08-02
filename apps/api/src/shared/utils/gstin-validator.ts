/**
 * GSTIN validation using the official GST mod-36 checksum algorithm.
 * Checksum logic ported from the GSTN reference implementation.
 */

const CODEPOINT_CHARS = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

const PATTERN = /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$/;

const ERROR_EMPTY = 'GSTIN cannot be empty';
const ERROR_LENGTH = 'GSTIN must contain exactly 15 characters';
const ERROR_FORMAT = 'Invalid GSTIN format';
const ERROR_STATE_CODE = 'Invalid state code';
const ERROR_CHECKSUM = 'Invalid GSTIN checksum';

export interface GstinValidationResult {
  valid: boolean;
  error?: string;
}

export function normalize(gstin: string): string {
  return gstin.trim().toUpperCase();
}

export function isValid(gstin: string): boolean {
  return validate(gstin).valid;
}

export function validationError(gstin: string): string | undefined {
  return validate(gstin).error;
}

export function validate(gstin: string): GstinValidationResult {
  const trimmed = gstin.trim();
  if (trimmed.length === 0) {
    return { valid: false, error: ERROR_EMPTY };
  }

  const normalized = trimmed.toUpperCase();
  if (normalized.length !== 15) {
    return { valid: false, error: ERROR_LENGTH };
  }

  if (!validatePattern(normalized)) {
    return { valid: false, error: ERROR_FORMAT };
  }

  if (!validateStateCode(normalized)) {
    return { valid: false, error: ERROR_STATE_CODE };
  }

  if (!validateChecksum(normalized)) {
    return { valid: false, error: ERROR_CHECKSUM };
  }

  return { valid: true };
}

export function validatePattern(gstin: string): boolean {
  return PATTERN.test(gstin);
}

export function validateStateCode(gstin: string): boolean {
  if (gstin.length < 2) {
    return false;
  }
  const code = Number.parseInt(gstin.slice(0, 2), 10);
  if (Number.isNaN(code)) {
    return false;
  }
  return code >= 1 && code <= 38;
}

export function validateChecksum(gstin: string): boolean {
  if (gstin.length !== 15) {
    return false;
  }
  return gstin.charAt(14) === calculateChecksum(gstin.slice(0, 14));
}

export function calculateChecksum(gstin14Chars: string): string {
  const mod = CODEPOINT_CHARS.length;
  let factor = 2;
  let sum = 0;
  // Reference algorithm sums indices 0..length-2 on a 15-character GSTIN.
  const lastIndex =
    gstin14Chars.length >= 15
      ? gstin14Chars.length - 2
      : gstin14Chars.length - 1;

  for (let i = lastIndex; i >= 0; i--) {
    const char = gstin14Chars.charAt(i);
    const codePoint = CODEPOINT_CHARS.indexOf(char);
    if (codePoint < 0 || char === '') {
      throw new Error(`Invalid character in GSTIN: ${char}`);
    }

    let digit = factor * codePoint;
    factor = factor === 2 ? 1 : 2;
    digit = Math.floor(digit / mod) + (digit % mod);
    sum += digit;
  }

  const checkCodePoint = (mod - (sum % mod)) % mod;
  return CODEPOINT_CHARS.charAt(checkCodePoint);
}
