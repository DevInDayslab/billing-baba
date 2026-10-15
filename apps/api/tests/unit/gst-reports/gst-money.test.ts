import { describe, expect, test } from 'bun:test';
import {
  addPaise,
  formatPaise,
  parseMoneyToPaise,
} from '../../../src/modules/gst-reports/core/gst-money';

describe('gst-money', () => {
  test('parses and formats rupees', () => {
    expect(formatPaise(parseMoneyToPaise('236'))).toBe('236.00');
    expect(formatPaise(parseMoneyToPaise('236.5'))).toBe('236.50');
  });

  test('adds paise without float error', () => {
    expect(formatPaise(addPaise(parseMoneyToPaise('0.10'), parseMoneyToPaise('0.20')))).toBe(
      '0.30',
    );
  });

  test('B2CL threshold boundary', () => {
    const threshold = parseMoneyToPaise('250000');
    const below = parseMoneyToPaise('249999.99');
    const above = parseMoneyToPaise('250000.01');
    expect(below < threshold).toBe(true);
    expect(above > threshold).toBe(true);
  });
});
