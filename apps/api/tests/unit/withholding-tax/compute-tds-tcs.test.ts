import { describe, expect, test } from 'bun:test';
import {
  computeTcs,
  computeTds,
} from '../../../src/modules/withholding-tax/core/compute-tds-tcs';

describe('computeTds / computeTcs', () => {
  test('returns zero for empty base or rate', () => {
    expect(computeTds('0', '1')).toBe('0.00');
    expect(computeTds('1000', '0')).toBe('0.00');
    expect(computeTcs('1000', '0')).toBe('0.00');
  });

  test('rounds to nearest whole rupee', () => {
    expect(computeTds('1000', '1')).toBe('10.00');
    expect(computeTds('1004', '1')).toBe('10.00');
    expect(computeTds('1005', '1')).toBe('10.00');
    expect(computeTds('1006', '1')).toBe('10.00');
    expect(computeTds('1009', '1')).toBe('10.00');
    expect(computeTds('1010', '1')).toBe('10.00');
  });

  test('194Q rate 0.1% on large base', () => {
    expect(computeTds('500000', '0.1')).toBe('500.00');
  });

  test('TCS 206C(1H) 0.1%', () => {
    expect(computeTcs('123456', '0.1')).toBe('123.00');
  });
});
