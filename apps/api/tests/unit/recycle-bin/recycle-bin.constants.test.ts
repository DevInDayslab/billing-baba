import { describe, expect, test } from 'bun:test';
import {
  RECYCLE_BIN_RETENTION_DAYS,
  daysRemaining,
  isRecycleBinEntityType,
  recycleBinRetentionCutoff,
} from '../../../src/modules/recycle-bin/recycle-bin.constants';

describe('recycle bin constants', () => {
  test('recognizes supported entity types', () => {
    expect(isRecycleBinEntityType('sales_document')).toBe(true);
    expect(isRecycleBinEntityType('unknown')).toBe(false);
  });

  test('retention cutoff is 90 days ago', () => {
    const cutoff = recycleBinRetentionCutoff();
    const diffDays = Math.round(
      (Date.now() - cutoff.getTime()) / (24 * 60 * 60 * 1000),
    );
    expect(diffDays).toBe(RECYCLE_BIN_RETENTION_DAYS);
  });

  test('days remaining is non-negative', () => {
    const deletedAt = new Date();
    expect(daysRemaining(deletedAt)).toBeGreaterThan(0);
  });
});
