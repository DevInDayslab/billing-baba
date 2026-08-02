import { describe, expect, test } from 'bun:test';
import {
  normalizeGstin,
  normalizeMobile,
  validateGstin,
  validateNormalizedMobile,
} from '../../../src/modules/parties/party.utils';

describe('party.utils', () => {
  test('normalizes Indian mobile numbers', () => {
    expect(normalizeMobile('9876543210')).toBe('9876543210');
    expect(normalizeMobile('+91 98765 43210')).toBe('9876543210');
    expect(normalizeMobile('09876543210')).toBe('9876543210');
  });

  test('validates normalized mobile numbers', () => {
    expect(validateNormalizedMobile(null)).toBe(true);
    expect(validateNormalizedMobile('9876543210')).toBe(true);
    expect(validateNormalizedMobile('12345')).toBe(false);
  });

  test('validates and normalizes GSTIN', () => {
    const gstin = '27AABCU9603R1ZN';
    expect(validateGstin(gstin)).toBe(true);
    expect(normalizeGstin(gstin.toLowerCase())).toBe(gstin);
    expect(validateGstin('INVALID')).toBe(false);
  });
});
