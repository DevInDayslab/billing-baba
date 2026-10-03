import { describe, expect, test } from 'bun:test';
import {
  calculateChecksum,
  isValid,
  validateChecksum,
  validatePattern,
  validateStateCode,
  validationError,
} from '../../../src/shared/utils/gstin-validator';

describe('gstin-validator', () => {
  const validGstin = '27AABCU9603R1ZN';

  test('valid GSTIN', () => {
    expect(isValid(validGstin)).toBe(true);
    expect(validationError(validGstin)).toBeUndefined();
  });

  test('empty string', () => {
    expect(isValid('')).toBe(false);
    expect(validationError('')).toBe('GSTIN cannot be empty');
  });

  test('too short', () => {
    expect(isValid('123412341234')).toBe(false);
    expect(validationError('123412341234')).toBe(
      'GSTIN must contain exactly 15 characters',
    );
  });

  test('too long', () => {
    expect(isValid('1234123412341234')).toBe(false);
    expect(validationError('1234123412341234')).toBe(
      'GSTIN must contain exactly 15 characters',
    );
  });

  test('invalid regex', () => {
    expect(isValid('47AAGCG4576J1A6')).toBe(false);
    expect(validationError('47AAGCG4576J1A6')).toBe('Invalid GSTIN format');
  });

  test('invalid state code', () => {
    expect(isValid('99AABCU9603R1ZM')).toBe(false);
    expect(validationError('99AABCU9603R1ZM')).toBe('Invalid state code');
  });

  test('invalid checksum', () => {
    expect(isValid('27AABCU9603R1Z8')).toBe(false);
    expect(validationError('27AABCU9603R1Z8')).toBe('Invalid GSTIN checksum');
  });

  test('lowercase input normalizes to valid', () => {
    expect(isValid('27aabCU9603R1ZN')).toBe(true);
  });

  test('leading and trailing spaces normalize to valid', () => {
    expect(isValid(' 27AABCU9603R1ZN ')).toBe(true);
  });

  test('calculateChecksum matches expected character', () => {
    expect(calculateChecksum('27AABCU9603R1Z')).toBe('N');
    expect(validGstin[14]).toBe(calculateChecksum(validGstin.slice(0, 14)));
  });

  test('validatePattern and validateStateCode helpers', () => {
    expect(validatePattern(validGstin)).toBe(true);
    expect(validateStateCode(validGstin)).toBe(true);
    expect(validateChecksum(validGstin)).toBe(true);
  });
});
