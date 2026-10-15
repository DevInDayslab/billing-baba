import { describe, expect, test } from 'bun:test';
import { dueDate } from '../../../src/modules/withholding-tax/core/due-date';

describe('dueDate', () => {
  test('non-March entry due 7th of next month (IST calendar)', () => {
    const entry = new Date('2025-04-15T12:00:00.000Z');
    const due = dueDate(entry, 'tds');
    expect(due.getUTCMonth()).toBe(4);
    expect(due.getUTCFullYear()).toBe(2025);
    expect(due.getUTCDate()).toBeGreaterThanOrEqual(6);
    expect(due.getUTCDate()).toBeLessThanOrEqual(7);
  });

  test('March entry due 30 April', () => {
    const entry = new Date('2025-03-10T12:00:00.000Z');
    const due = dueDate(entry, 'tcs');
    expect(due.getUTCMonth()).toBe(3);
    expect(due.getUTCFullYear()).toBe(2025);
    expect(due.getUTCDate()).toBeGreaterThanOrEqual(29);
    expect(due.getUTCDate()).toBeLessThanOrEqual(30);
  });
});
