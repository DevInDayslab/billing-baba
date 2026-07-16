import { describe, expect, test } from 'bun:test';
import {
  calculateMovingAverageCost,
  formatConversionLabel,
  normalizeMoney,
  parseMoney,
} from '../../../src/modules/inventory/inventory.utils';

describe('inventory.utils', () => {
  test('normalizes and parses money values', () => {
    expect(normalizeMoney(undefined)).toBe('0');
    expect(normalizeMoney(' 12.50 ')).toBe('12.50');
    expect(parseMoney('10')).toBe(10);
  });

  test('calculates weighted moving average on stock-in', () => {
    expect(calculateMovingAverageCost('10', '100', '5', '120')).toBe(
      '106.6667',
    );
  });

  test('keeps average unchanged on stock-out', () => {
    expect(calculateMovingAverageCost('10', '100', '-2', '150')).toBe('100');
  });

  test('formats conversion labels', () => {
    expect(formatConversionLabel('Box', 'Piece', 12)).toBe('1 Box = 12 Piece');
  });
});
