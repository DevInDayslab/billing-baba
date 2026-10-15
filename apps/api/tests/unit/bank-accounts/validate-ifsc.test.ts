import { describe, expect, test } from 'bun:test';
import { normalizeIfsc, validateIfsc } from '../../../src/modules/bank-accounts/domain/validate-ifsc';

describe('validateIfsc', () => {
  test('accepts valid IFSC', () => {
    expect(validateIfsc('HDFC0001234')).toBe(true);
    expect(normalizeIfsc('hdfc0001234')).toBe('HDFC0001234');
  });

  test('rejects invalid IFSC', () => {
    expect(validateIfsc('HDFC001234')).toBe(false);
    expect(validateIfsc('HDFC00012345')).toBe(false);
  });
});
